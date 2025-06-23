--[[
    Serialization.luau
    ------------------
    Provides functions to serialize Roblox Instances into a compact binary format.
    Handles general, instance, and string properties, and supports recursive serialization.
    
    Functions:
    - Serialization.SingleInstance: Serializes a SingleInstance instance.
    - Serialization.Recursive: Serializes an instance and its descendants.
    - Serialization.RecursiveWithDiffs: Serializes with diff/caching support.
    - Serialization.SetClassMap: Sets the class mapping for serialization.
]]

local classMap

-- Public
local Serialization = {}

local writestring = buffer.writestring
local writeu16 = buffer.writeu16
local writeu8 = buffer.writeu8

--[[
    Serializes a SingleInstance instance into the buffer.
    Skips properties with default values for compactness.
    - data: buffer to write to
    - offset: current write position
    - instance: Instance to serialize
    - instancesIdMap: map of Instance to id
    - lastInstanceIdMapped: last used id
    Returns new offset after writing.
]]
function Serialization.SingleInstance(
	data: buffer,
	offset: number,
	instance: Instance,
	instancesIdMap: { [Instance]: number },
	lastInstanceIdMapped: number
)
	local instanceClassName = instance.ClassName
	local instanceClassMap = classMap[instanceClassName]
	if not instanceClassMap then
		return offset
	end

	local classId = instanceClassMap[1]
	-- Write class id
	writeu16(data, offset, classId)
	offset += 2

	-- Add instance to the id map table so it can be referenced by instance properties
	lastInstanceIdMapped += 1
	instancesIdMap[instance] = lastInstanceIdMapped

	-- Serialize general properties
	do
		-- Reserve space for total general properties count
		local totalGeneralPropertiesPosition = offset
		offset += 1

		-- General properties
		local totalGeneralProperties = 0
		for propName, propData in instanceClassMap[2] do
			local propValue = instance[propName]
			-- Skip if property value is defaulted
			if propValue == propData[2] then
				continue
			end

			local propId, propSerializer = propData[1], propData[3]
			-- Write property id
			writeu8(data, offset, propId)
			offset += 1

			-- Serialize property value into the data buffer and get the new offset
			offset = propSerializer(data, offset, propValue)
			totalGeneralProperties += 1
		end

		-- Write total general properties count
		writeu8(data, totalGeneralPropertiesPosition, totalGeneralProperties)
		offset += 1
	end

	-- Serializing instance properties
	do
		-- Reserve space for total instance properties count
		local totalInstancePropertiesPosition = offset
		offset += 1

		-- Instance properties
		local totalInstanceProperties = 0
		for propName, propData in instanceClassMap[3] do
			local value = instancesIdMap[instance[propName]]
			if value == propData[2] then
				continue
			end

			-- Write property id
			writeu8(data, offset, propData[1])
			offset += 1

			-- Write property value
			writeu16(data, offset, value)
			offset += 2

			totalInstanceProperties += 1
		end

		-- Write total instance properties count
		writeu8(data, totalInstancePropertiesPosition, totalInstanceProperties)
		offset += 1
	end

	-- Serializing string properties
	do
		-- Reserve space for total string properties count
		local totalStringPropertiesPosition = offset
		offset += 1

		-- Write name property if not default
		-- Also initializes totalStringProperties with 0 when name is default and 1 when it needed to be serialized
		local name = instance.Name
		local totalStringProperties
		if name == instanceClassName then
			totalStringProperties = 0
		else
			-- Write name property id
			-- Name property id is always 1
			writeu8(data, offset, 1)
			offset += 1

			-- Write name as string
			writestring(data, offset, name)
			offset += #name

			totalStringProperties = 1
		end

		-- Iter string properties
		for propName, propData in instanceClassMap[4] do
			local value = instance[propName]
			if value == propData[2] then
				continue
			end

			-- Write property id
			writeu8(data, offset, propData[1])
			offset += 1

			-- Write property value as string
			writestring(data, offset, value)
			offset += #value

			totalStringProperties += 1
		end

		-- Write total string properties count
		writeu8(data, totalStringPropertiesPosition, totalStringProperties)
		offset += 1
	end

	return offset
end

local SingleInstance = Serialization.SingleInstance

--[[
    Recursively serializes an instance and all its descendants.
    Calls SingleInstance for each instance, then serializes children.
]]
local function Recursive(data: buffer, offset: number, obj: Instance, instancesIdMap, lastInstanceIdMapped)
	offset = SingleInstance(data, offset, obj, instancesIdMap, lastInstanceIdMapped)

	local children = obj:GetChildren()
	writeu16(data, offset, #children)
	offset += 2

	for _, child in children do
		offset = Recursive(data, offset, child, instancesIdMap, lastInstanceIdMapped)
	end

	return offset
end

Serialization.Recursive = Recursive

--[[
    Serializes an instance with diff/caching support for efficient storage.
    alreadySerialized: table of already serialized properties for diffing.
    - data: buffer to write to
    - offset: current write position
    - obj: Instance to serialize
    - instancesIdMap: map of Instance to id
    - lastInstanceIdMapped: last used id
    - alreadySerialized: cache for diffing
    Returns new offset after writing.
]]
local function SingleInstanceWithDiffs(
	data: buffer,
	offset: number,
	obj: Instance,
	instancesIdMap: { [Instance]: number },
	lastInstanceIdMapped: number,
	alreadySerialized: { [number]: { [number]: any } }
)
	local className = obj.ClassName
	local classData = classMap[className]
	if not classData then
		return offset
	end

	local classId = classData[1]
	-- Write class id
	writeu16(data, offset, classId)
	offset += 2

	-- Add instance to the id map table so it can be referenced by instance properties
	lastInstanceIdMapped += 1
	instancesIdMap[obj] = lastInstanceIdMapped

	local myStringPropSection = {}

	-- Write name property if not default
	local name = obj.Name
	local totalProperties
	if name == className then
		totalProperties = 0
	else
		myStringPropSection[1] = name

		-- Write name property id (always 1)
		writeu8(data, offset, 1)
		offset += 1

		-- Write name as string
		writestring(data, offset, name)
		offset += #name

		totalProperties = 1
	end

	-- General properties (non-instance, non-string)
	local myGeneralPropSection = {}
	for propName, propData in classData[2] do
		local value = obj[propName]
		-- Skip if property value is defaulted
		if value == propData[2] then
			continue
		end

		myGeneralPropSection[propData[1]] = { value, propData[3] }
	end

	-- Instance properties (references to other instances)
	local myInstancePropSection = {}
	for propName, propData in classData[3] do
		local value = instancesIdMap[obj[propName]]
		if value == propData[2] then
			continue
		end

		myInstancePropSection[propData[1]] = value
	end

	-- String properties (other than Name)
	for propName, propData in classData[4] do
		local value = obj[propName]
		if value == propData[2] then
			continue
		end

		myStringPropSection[propData[1]] = value
	end

	local myPropSections = { myGeneralPropSection, myStringPropSection, myInstancePropSection }

	-- Find the best match in already serialized instances for diffing
	local best: {}
	local bestScore = 0
	for i, that in alreadySerialized do
		for thatPropSectionIndex, thatPropSection in that[2] do
			local myPropSection = myPropSections[thatPropSectionIndex]
			if i == classId then
				local thatScore = 0
				for p, pv in thatPropSection do
					if myPropSection[p] == pv then
						thatScore += 1
					end
				end

				if thatScore > bestScore then
					best, bestScore = that, thatScore
				end
			end
		end
	end

	-- Store cached data only after the iteration above so it doesn't include itself
	alreadySerialized[classId] = {
		lastInstanceIdMapped,
		myPropSections,
	}

	-- Write best match instance map id (0 if none)
	writeu8(data, offset, best and best[1] or 0)
	offset += 1

	-- Only write properties that are not in the best match
	if best then
		local bestPropSections = best[2]
		-- General properties
		for propId, prop in bestPropSections[1] do
			local value = prop[1]
			if value ~= myGeneralPropSection[propId] then
				writeu8(data, offset, propId)
				offset += 1

				offset = prop[2](data, offset, value)
				totalProperties += 1
			end
		end

		-- String properties
		for propId, value in bestPropSections[2] do
			if value ~= myStringPropSection[propId] then
				writeu8(data, offset, propId)
				offset += 1

				writestring(data, offset, value)
				offset += #value
				totalProperties += 1
			end
		end

		-- Instance properties
		for propId, value in bestPropSections[3] do
			if value ~= myInstancePropSection[propId] then
				writeu8(data, offset, propId)
				offset += 1

				writeu16(data, offset, value)
				offset += 2
				totalProperties += 1
			end
		end
	else
		-- Write all properties if no best match
		for propId, prop in myGeneralPropSection do
			writeu8(data, offset, propId)
			offset += 1

			offset = prop[2](data, offset, prop[1])
		end

		for propId, value in myStringPropSection do
			writeu8(data, offset, propId)
			offset += 1

			local len = #value
			writeu8(data, offset, len)
			offset += 1

			writestring(data, offset, value)
			offset += len
		end

		for propId, value in myInstancePropSection do
			writeu8(data, offset, propId)
			offset += 1

			writeu16(data, offset, value)
			offset += 2
		end
	end

	return offset
end

local function RecursiveWithDiffs(
	data: buffer,
	offset: number,
	obj: Instance,
	instancesIdMap,
	lastInstanceIdMapped,
	alreadySerialized: { [Instance]: { [number]: any } }
)
	offset = SingleInstanceWithDiffs(data, offset, obj, instancesIdMap, lastInstanceIdMapped, alreadySerialized)

	local children = obj:GetChildren()
	writeu16(data, offset, #children)
	offset += 2

	for _, child in children do
		offset = RecursiveWithDiffs(data, offset, child, instancesIdMap, lastInstanceIdMapped, alreadySerialized)
	end

	return offset
end

Serialization.RecursiveWithDiffs = RecursiveWithDiffs

function Serialization.SetClassMap(newClassMap: {})
	classMap = newClassMap
end

return Serialization

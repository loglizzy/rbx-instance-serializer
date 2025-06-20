local ClassMapper = require(script.Parent.ClassMapper)
local rblxAPIDump = require(script.Parent.Parent.modules["roblox-api-dumper"]).fetchAndDecodeDump()

-- Generate the class serialization mapping
local classMap = ClassMapper.GenerateMapping(rblxAPIDump)

-- Public
local Serializers = {}

local writestring = buffer.writestring
local writeu16 = buffer.writeu16
local writeu8 = buffer.writeu8
function Serializers.Single(
	data: buffer,
	offset: number,
	obj: Instance,
	instancesIdMap: { [Instance]: number },
	lastInstanceIdMapped: number
)
	local className = obj.ClassName
	local classData = classMap[className]
	if not classData then
		return offset
	end

	local classId = classData[1]
	writeu16(data, offset, classId)
	offset += 2

	lastInstanceIdMapped += 1
	instancesIdMap[obj] = lastInstanceIdMapped

	-- Write name property
	local name = obj.Name
	local totalProperties
	if name == className then
		totalProperties = 0
	else
		writeu8(data, offset, 1)
		offset += 1

		writestring(data, offset, name)
		offset += #name

		totalProperties = 1
	end

	-- Reserve space for total properties count
	local totalPropertiesPosition = offset
	offset += 1

	-- General properties
	for propName, propData in classData[2] do
		local value = obj[propName]
		if value == propData[2] then
			continue
		end

		local id, serializer = propData[1], propData[3]
		writeu8(data, offset, id)
		offset += 1

		offset = serializer(data, offset, value)
		totalProperties += 1
	end

	-- Instance properties
	for propName, propData in classData[3] do
		local value = instancesIdMap[obj[propName]]
		if value == propData[2] then
			continue
		end

		writeu8(data, offset, propData[1])
		offset += 1

		writeu16(data, offset, value)
		offset += 2

		totalProperties += 1
	end

	-- String properties
	for propName, propData in classData[4] do
		local value = obj[propName]
		if value == propData[2] then
			continue
		end

		writeu8(data, offset, propData[1])
		offset += 1

		writestring(data, offset, value)
		offset += #value

		totalProperties += 1
	end

	writeu8(data, totalPropertiesPosition, totalProperties)
	offset += 1

	return offset
end

local Single = Serializers.Single
local function Recursive(data: buffer, offset: number, obj: Instance, instancesIdMap, lastInstanceIdMapped)
	offset = Single(data, offset, obj, instancesIdMap, lastInstanceIdMapped)

	local children = obj:GetChildren()
	writeu16(data, offset, #children)
	offset += 2

	for _, child in children do
		offset = Recursive(data, offset, child, instancesIdMap, lastInstanceIdMapped)
	end

	return offset
end

Serializers.Recursive = Recursive

local function SingleWithDiffs(
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
	writeu16(data, offset, classId)
	offset += 2

	lastInstanceIdMapped += 1
	instancesIdMap[obj] = lastInstanceIdMapped

	local myStringPropSection = {}

	-- Write name property
	local name = obj.Name
	local totalProperties
	if name == className then
		totalProperties = 0
	else
		myStringPropSection[1] = name

		writeu8(data, offset, 1)
		offset += 1

		writestring(data, offset, name)
		offset += #name

		totalProperties = 1
	end

	-- General properties
	local myGeneralPropSection = {}
	for propName, propData in classData[2] do
		local value = obj[propName]
		if value == propData[2] then
			continue
		end

		myGeneralPropSection[propData[1]] = { value, propData[3] }
	end

	-- Instance properties
	local myInstancePropSection = {}
	for propName, propData in classData[3] do
		local value = instancesIdMap[obj[propName]]
		if value == propData[2] then
			continue
		end

		myInstancePropSection[propData[1]] = value
	end

	-- String properties
	for propName, propData in classData[4] do
		local value = obj[propName]
		if value == propData[2] then
			continue
		end

		myStringPropSection[propData[1]] = value
	end

	local myPropSections = { myGeneralPropSection, myStringPropSection, myInstancePropSection }

	-- Find the best match in already serialized instances
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

	-- Store cached date only after the iteration above so it doesn't include itself
	alreadySerialized[classId] = {
		lastInstanceIdMapped,
		myPropSections,
	}

	-- Write best match instance map id
	writeu8(data, offset, best and best[1] or 0)
	offset += 1

	-- Only write properties that are not in the best match
	if best then
		local bestPropSections = best[2]
		for propId, prop in bestPropSections[1] do
			local value = prop[1]
			if value ~= myGeneralPropSection[propId] then
				writeu8(data, offset, propId)
				offset += 1

				offset = prop[2](data, offset, value)
				totalProperties += 1
			end
		end

		for propId, value in bestPropSections[2] do
			if value ~= myStringPropSection[propId] then
				writeu8(data, offset, propId)
				offset += 1

				writestring(data, offset, value)
				offset += #value
				totalProperties += 1
			end
		end

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
		for propId, prop in myGeneralPropSection do
			writeu8(data, offset, propId)
			offset += 1

			offset = prop[2](data, offset, prop[1])
		end

		for propId, value in myStringPropSection do
			writeu8(data, offset, propId)
			offset += 1

			writestring(data, offset, value)
			offset += #value
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
	offset = SingleWithDiffs(data, offset, obj, instancesIdMap, lastInstanceIdMapped, alreadySerialized)

	local children = obj:GetChildren()
	writeu16(data, offset, #children)
	offset += 2

	for _, child in children do
		offset = RecursiveWithDiffs(data, offset, child, instancesIdMap, lastInstanceIdMapped, alreadySerialized)
	end

	return offset
end

Serializers.RecursiveWithDiffs = RecursiveWithDiffs

return Serializers

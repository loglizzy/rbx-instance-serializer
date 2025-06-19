local valueTypesSerializers = require(script.Parent.ValueTypeSerializers)

-- Tags that indicate properties that shouldn't be serialized
local READ_ONLY_TAG = "ReadOnly"
local NOT_SCRIPTABLE_TAG = "NotScriptable"

-- Private
-- Checks if a property has forbidden tags (ReadOnly or NotScriptable)
local function isForbiddenTag(tags: { string })
	for _, tag in tags do
		if tag == READ_ONLY_TAG or tag == NOT_SCRIPTABLE_TAG then
			return true
		end
	end
	return false
end

local function CheckIndex(o, i)
	local v = o[i]
	o[i] = v
	return v
end

-- Maps a single class's properties and creates its serialization information
local function MapClass(classMap: any, class: any, classSuper: string, classId: number)
	-- Try creating an instance of the class
	-- used to determine default values for properties
	local className = class.Name
	local ok, classInstance = pcall(Instance.new, className)
	classInstance = ok and classInstance

	local properties = {}

	-- Track instance-type properties separately
	local instanceProperties = {}

	-- Track string-type properties separately
	local stringProperties = {
		Name = { 1, className },
	}

	local propCount = 1
	-- Iterate through all class members to find serializable properties
	for _, property in class.Members do
		local valueType = property.ValueType
		if not valueType then
			continue
		end

		-- Skip properties with forbidden tags or restricted security settings
		if property.Tags and isForbiddenTag(property.Tags) then
			continue
		end

		-- Skip properties that are not readable or writable
		local security = property.Security
		if security.Read ~= "None" or security.Write ~= "None" then
			continue
		end

		-- Skip base properties
		local propertyName = property.Name
		if propertyName == "Parent" then
			continue
		end

		local propertyDefault
		if classInstance then
			local ok, res = pcall(CheckIndex, classInstance, propertyName)
			-- Skip property if it cannot be accessed
			if not ok then
				continue
			end

			propertyDefault = res
		end

		-- Determine the appropriate serializer for the property type
		local serializer
		local valueTypeName = valueType.Name
		if valueType.Category == "Class" then
			-- For properties with instance value
			propCount += 1
			instanceProperties[propertyName] = { propCount, propertyDefault }
		elseif valueTypeName == "string" then
			-- For string properties
			propCount += 1
			stringProperties[propertyName] = { propCount, propertyDefault }
		else
			-- For any other properties
			serializer = valueTypesSerializers[valueTypeName]
			if serializer == nil then
				continue
			end

			propCount += 1
			properties[propertyName] = {
				propCount,
				propertyDefault,
				serializer,
			}
		end
	end

	if classInstance then
		classInstance:Destroy()
	end

	classSuper = classMap[classSuper]
	-- Inherit properties from super class
	if classSuper then
		for i, v in classSuper[2] do
			properties[i] = v
		end

		for i, v in classSuper[3] do
			instanceProperties[i] = v
		end

		for i, v in classSuper[4] do
			stringProperties[i] = v
		end
	end

	return {
		classId,
		properties,
		instanceProperties,
		stringProperties,
	}
end

-- Maps classes that have their superclass already mapped
local function MapClassesWithSuper(classList: { any }, mappedSupers: {}, classMap: {}, classCount: number)
	local notMapped = {}
	for _, class in classList do
		local classSuper = class.Superclass
		if mappedSupers[classSuper] then
			local className = class.Name

			mappedSupers[className] = true
			classCount += 1
			classMap[class.Name] = MapClass(classMap, class, classSuper, classCount)
		else
			table.insert(notMapped, class)
		end
	end

	return notMapped, classCount
end

-- Public
local ClassMapper = {}

-- Generates a mapping of all classes and their serializable properties
function ClassMapper.GenerateMapping(apiDump: any)
	local classMap = {
		["<<<ROOT>>>"] = {
			[2] = {},
			[3] = {},
			[4] = {},
		},
	}
	local mappedSupers = {
		["<<<ROOT>>>"] = true,
	}

	-- Multiple passes to ensure inheritance chain is properly processed
	local notMapped = table.clone(apiDump.Classes)
	local classCount = 0
	notMapped, classCount = MapClassesWithSuper(notMapped, mappedSupers, classMap, classCount)
	notMapped, classCount = MapClassesWithSuper(notMapped, mappedSupers, classMap, classCount)
	notMapped, classCount = MapClassesWithSuper(notMapped, mappedSupers, classMap, classCount)

	return classMap
end

return ClassMapper

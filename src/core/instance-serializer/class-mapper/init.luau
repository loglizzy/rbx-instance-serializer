--[[
    class-mapper/init.luau
    ----------------------
    Responsible for mapping Roblox class metadata for serialization and deserialization.
    Builds property maps for each class, including inheritance, and provides mapping utilities.
    
    Functions:
    - MapClass: Maps a single class's properties and serialization info.
    - MapClassesWithSuper: Maps classes whose superclasses are already mapped.
    - ClassMapper.GenerateMapping: Generates the full class/property mapping for the serializer.
]]

local serializing = script.Parent.serializing
local valueTypesSerializers = require(serializing.values.Serializers)
local valueTypesDeserializers = require(serializing.values.Deserializers)

local robloxApiDumper = require(script["roblox-api-dumper"])

-- Tags that indicate properties that shouldn't be serialized
local READ_ONLY_TAG = "ReadOnly"
local NOT_SCRIPTABLE_TAG = "NotScriptable"

-- Checks if a property has forbidden tags (ReadOnly or NotScriptable)
local function isForbiddenTag(tags: { string })
	for _, tag in tags do
		if tag == READ_ONLY_TAG or tag == NOT_SCRIPTABLE_TAG then
			return true
		end
	end
	return false
end

-- Helper to safely access and cache property values
local function CheckIndex(o, i)
	local v = o[i]
	o[i] = v
	return v
end

local instanceNew = Instance.new

--[[
    Maps a single class's properties and creates its serialization information.
    Handles inheritance, default values, and property type mapping.
    Returns serialization and deserialization mapping tables.
]]
local function MapClass(classMap: {}, deserialClassMap: {}, class: any, classSuper: string, classId: number)
	-- Try creating an instance of the class to determine default values
	local className = class.Name
	local ok, classInstance = pcall(Instance.new, className)
	classInstance = ok and classInstance

	local properties = {}
	local idMappedProperties = {}

	-- Track instance-type properties separately
	local instanceProperties = {}
	local idMappedInstanceProperties = {}

	-- Track string-type properties separately
	local stringProperties = {}
	local idMappedStringProperties = {
		[1] = "Name",
	}

	local classSuper = classMap[classSuper]
	local propCount = classSuper and classSuper[5] or 0
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
		if propertyName == "Parent" or propertyName == "Name" then
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
			idMappedInstanceProperties[propCount] = propertyName
		elseif valueTypeName == "string" then
			-- For string properties
			propCount += 1
			stringProperties[propertyName] = { propCount, propertyDefault }
			idMappedStringProperties[propCount] = propertyName
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

			local deserializer = valueTypesDeserializers[valueTypeName]
			idMappedProperties[propCount] = {
				propertyName,
				deserializer,
			}
		end
	end

	if classInstance then
		classInstance:Destroy()
	end

	-- Inherit properties from super class
	if classSuper then
		-- Inherit serialization mappings
		for i, v in classSuper[2] do
			properties[i] = v
		end

		for i, v in classSuper[3] do
			instanceProperties[i] = v
		end

		for i, v in classSuper[4] do
			stringProperties[i] = v
		end

		-- Inherit deserialization mappings
		local superDeserialClassMap = deserialClassMap[classSuper[1]]
		if superDeserialClassMap then
			for i, v in superDeserialClassMap[2] do
				idMappedProperties[i] = v
			end

			for i, v in superDeserialClassMap[3] do
				idMappedInstanceProperties[i] = v
			end

			for i, v in superDeserialClassMap[4] do
				idMappedStringProperties[i] = v
			end
		end
	end

	return {
		{
			classId,
			properties,
			instanceProperties,
			stringProperties,
			propCount,
		},
		{
			function ()
				return instanceNew(className)
			end,
			idMappedProperties,
			idMappedInstanceProperties,
			idMappedStringProperties,
		},
	}
end

--[[
    Maps classes that have their superclass already mapped.
    Returns a list of classes not yet mapped and the updated class count.
]]
local function MapClassesWithSuper(
	classList: { any },
	mappedSupers: {},
	classMap: {},
	deserialClassMap: {},
	classCount: number
)
	local notMapped = {}
	for _, class in classList do
		local classSuper = class.Superclass
		if mappedSupers[classSuper] then
			local className = class.Name

			mappedSupers[className] = true
			classCount += 1

			local map = MapClass(classMap, deserialClassMap, class, classSuper, classCount)
			classMap[class.Name] = map[1]
			deserialClassMap[classCount] = map[2]
		else
			table.insert(notMapped, class)
		end
	end

	return notMapped, classCount
end

-- Public API for class mapping
local ClassMapper = {}

--[[
    Generates a mapping of all classes and their serializable properties.
    Returns classMap and deserialClassMap for use in serialization/deserialization.
]]
function ClassMapper.GenerateMapping()
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
	
	local apiDump = robloxApiDumper.fetchAndDecodeDump()
	local notMapped = table.clone(apiDump.Classes)
	local classCount = 0
	local deserialClassMap = {}
	-- Multiple passes to ensure inheritance chain is properly processed
	notMapped, classCount = MapClassesWithSuper(notMapped, mappedSupers, classMap, deserialClassMap, classCount)
	notMapped, classCount = MapClassesWithSuper(notMapped, mappedSupers, classMap, deserialClassMap, classCount)
	notMapped, classCount = MapClassesWithSuper(notMapped, mappedSupers, classMap, deserialClassMap, classCount)

	return classMap, deserialClassMap
end

return ClassMapper

local valueTypesSerializers = require(script.Parent.ValueTypeSerializers)
local format = require(script.Parent.Parent.format)

-- Constants for binary packing formats
local PROPERTY_ID_FORMAT = format.PROPERTY_ID
local CLASS_ID_FORMAT = format.CLASS_ID
local TOTAL_PROPERTIES_FORMAT = format.TOTAL_PROPERTIES

-- Tags that indicate properties that shouldn't be serialized
local READ_ONLY_TAG = "ReadOnly"
local NOT_SCRIPTABLE_TAG = "NotScriptable"

-- Private Functions
-- Checks if a property has forbidden tags (ReadOnly or NotScriptable)
local function isForbiddenTag(tags: { string })
	for _, tag in tags do
		if tag == READ_ONLY_TAG or tag == NOT_SCRIPTABLE_TAG then
			return true
		end
	end
	return false
end

-- Initialize with Name property as it's always included
local baseStringProperties = {
	Name = 1
}

-- Maps a single class's properties and creates its serialization information
local baseProperties = {}
local function MapClass(classMap: any, class: any, classSuper: string, classId: number)
	local properties = {}

	-- Track instance-type properties separately
	local instanceProperties = {}

	-- Track string-type properties separately
	local stringProperties = table.clone(baseStringProperties)

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

		local security = property.Security
		if security.Read ~= "None" or security.Write ~= "None" then
			continue
		end

		local propertyName = property.Name
		if propertyName == "Name" or propertyName == "Parent" then
			continue
		end

		-- Determine the appropriate serializer for the property type
		local serializer
		local valueTypeName = valueType.Name
		if valueType.Category == "Class" then
			-- For properties with instance value
			propCount += 1
			instanceProperties[propertyName] = propCount
		elseif valueTypeName == "string" then
			propCount += 1
			stringProperties[propertyName] = propCount
		else
			-- For any other properties
			serializer = valueTypesSerializers[valueTypeName]
			if serializer == nil then
				continue
			end

			propCount += 1
			properties[propertyName] = {
				propCount,
				serializer,
			}
		end
	end

	-- Inherit properties from superclass
	for i, v in classMap[classSuper][2] do
		properties[i] = v
	end

	for i, v in classMap[classSuper][3] do
		instanceProperties[i] = v
	end

	for i, v in classMap[classSuper][4] do
		stringProperties[i] = v
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

-- Public API
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

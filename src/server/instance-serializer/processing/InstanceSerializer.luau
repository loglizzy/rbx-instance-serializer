local ClassMapper = require(script.Parent.ClassMapper)
local rblxAPIDump = require(script.Parent.Parent.modules["roblox-api-dumper"]).fetchAndDecodeDump()
local format = require(script.Parent.Parent.format)

-- Generate the class serialization mapping
local classMap = ClassMapper.GenerateMapping(rblxAPIDump)

-- Constants
local INSTANCE_ID_FORMAT = format.INSTANCE_ID
local TOTAL_CHILDREN_FORMAT = format.TOTAL_CHILDREN

-- Public
local InstanceSerializer = {}

function InstanceSerializer.Single(obj: Instance, instancesIdMap: { [Instance]: number }, lastInstanceIdMapped: number)
	local classData = classMap[obj.ClassName]
	if not classData then
		return ""
	end

	lastInstanceIdMapped += 1
	instancesIdMap[obj] = lastInstanceIdMapped

	local data = classData[1]
	for propName, propData in classData[2] do
		local id, serializer = propData[1], propData[2]
		data ..= id .. serializer(obj[propName])
	end

	for className, id in classData[3] do
		local value = instancesIdMap[obj[className]]
		if not value then
			continue
		end

		data ..= id .. string.pack(INSTANCE_ID_FORMAT, value)
	end

	return data
end

local Single = InstanceSerializer.Single
local function Recursive(obj: Instance, instancesIdMap, lastInstanceIdMapped)
	local data = Single(obj, instancesIdMap, lastInstanceIdMapped)

	local children = obj:GetChildren()
	data ..= string.pack(TOTAL_CHILDREN_FORMAT, #children)

	for _, child in children do
		data ..= Recursive(child, instancesIdMap, lastInstanceIdMapped)
	end

	return data
end

InstanceSerializer.Recursive = Recursive

return InstanceSerializer

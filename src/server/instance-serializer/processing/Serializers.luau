local ClassMapper = require(script.Parent.ClassMapper)
local rblxAPIDump = require(script.Parent.Parent.modules["roblox-api-dumper"]).fetchAndDecodeDump()
local format = require(script.Parent.Parent.format)

-- Generate the class serialization mapping
local classMap = ClassMapper.GenerateMapping(rblxAPIDump)

-- Public
local InstanceSerializer = {}

local writestring = buffer.writestring
local writeu16 = buffer.writeu16
function InstanceSerializer.Single(
	data: buffer,
	offset: number,
	obj: Instance,
	instancesIdMap: { [Instance]: number },
	lastInstanceIdMapped: number
)
	local classData = classMap[obj.ClassName]
	if not classData then
		return offset
	end

	lastInstanceIdMapped += 1
	instancesIdMap[obj] = lastInstanceIdMapped

	for propName, propData in classData[2] do
		local id, serializer = propData[1], propData[2]
		
		writeu16(data, offset, id)
		offset += 2
		
		offset = serializer(data, offset, obj[propName])
	end

	for propName, propId in classData[3] do
		local value = instancesIdMap[obj[propName]]
		if not value then
			continue
		end

		writeu16(data, offset, propId)
		offset += 2

		writeu16(data, offset, value)
		offset += 2
	end

	for propName, propId in classData[4] do
		local value = obj[propName]
		if not value then
			continue
		end

		writeu16(data, offset, propId)
		offset += 2

		writestring(data, offset, value)
		offset += #value
	end

	return offset
end

local Single = InstanceSerializer.Single
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

InstanceSerializer.Recursive = Recursive

return InstanceSerializer

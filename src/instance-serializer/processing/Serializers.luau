local ClassMapper = require(script.Parent.ClassMapper)
local rblxAPIDump = require(script.Parent.Parent.modules["roblox-api-dumper"]).fetchAndDecodeDump()

-- Generate the class serialization mapping
local classMap = ClassMapper.GenerateMapping(rblxAPIDump)

-- Public
local InstanceSerializer = {}

local writestring = buffer.writestring
local writeu16 = buffer.writeu16
local writeu8 = buffer.writeu8
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
		local value = obj[propName]
		if value == propData[2] then
			continue
		end
		
		local id, serializer = propData[1], propData[3]
		writeu8(data, offset, id)
		offset += 1

		offset = serializer(data, offset, value)
	end

	for propName, propData in classData[3] do
		local value = instancesIdMap[obj[propName]]
		if value == propData[2] then
			continue
		end

		writeu8(data, offset, propData[1])
		offset += 1

		writeu16(data, offset, value)
		offset += 2
	end

	for propName, propData in classData[4] do
		local value = obj[propName]
		if value == propData[2] then
			continue
		end

		writeu8(data, offset, propData[1])
		offset += 1

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

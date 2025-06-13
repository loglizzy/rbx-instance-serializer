-- Private
local InstanceSerializer = require(script.processing.InstanceSerializer)
local Single = InstanceSerializer.Single
local Recursive = InstanceSerializer.Recursive

-- Public
local InstanceSerializer = {}

function InstanceSerializer.Single(instance: Instance)
	local instancesIdMap = { [instance] = 0 }
	return Single(instance, instancesIdMap, 0)
end

function InstanceSerializer.Recursive(instance: Instance)
	local instancesIdMap = { [instance] = 0 }
	local data = buffer.create(10000000)
	local offset = 0
	offset = Recursive(data, offset, instance, instancesIdMap, 0)

	return buffer.readstring(data, 0, offset)
end

return InstanceSerializer

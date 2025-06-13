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

function InstanceSerializer.Recursive(rootInstance: Instance)
	local instancesIdMap = { [rootInstance] = 0 }
	return Recursive(rootInstance, instancesIdMap, 0)
end

return InstanceSerializer

-- Private
local Serializers = require(script.processing.Serializers)
local Single = Serializers.Single
local Recursive = Serializers.Recursive


-- Hello
-- Public
local InstanceSerializer = {}

local instanceAllocation = 200
function InstanceSerializer.Single(instance: Instance)
	local data = buffer.create(instanceAllocation)
	local instancesIdMap = { [instance] = 0 }
	return Single(data, instance, instancesIdMap, 0)
end

function InstanceSerializer.Recursive(instance: Instance)
	local allocation = #instance:GetDescendants() * instanceAllocation
	local data = buffer.create(allocation)

	local instancesIdMap = { [instance] = 0 }
	local offset = Recursive(data, 0, instance, instancesIdMap, 0)

	return buffer.readstring(data, 0, offset)
end

return InstanceSerializer

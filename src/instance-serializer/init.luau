-- Private
local Serializers = require(script.processing.Serializers)
local Single = Serializers.Single
local Recursive = Serializers.Recursive

-- Public
local InstanceSerializer = {}

local instanceAllocation = 200
local create = buffer.create
function InstanceSerializer.Single(instance: Instance)
	local data = create(instanceAllocation)
	local instancesIdMap = { [instance] = 0 }
	return Single(data, instance, instancesIdMap, 0)
end

local readstring = buffer.readstring
function InstanceSerializer.Recursive(instance: Instance)
	local allocation = #instance:GetDescendants() * instanceAllocation
	local data = create(allocation)

	local instancesIdMap = { [instance] = 0 }
	local offset = Recursive(data, 0, instance, instancesIdMap, 0)

	return readstring(data, 0, offset)
end

return InstanceSerializer

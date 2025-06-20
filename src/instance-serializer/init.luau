-- Private
local Serializers = require(script.processing.Serializers)

-- Public
local InstanceSerializer = {}

local instanceAllocation = 200
local create = buffer.create
local Single = Serializers.Single
local readstring = buffer.readstring
function InstanceSerializer.Single(instance: Instance)
	local data = create(instanceAllocation)
	local instancesIdMap = { [instance] = 0 }

	return readstring(data, 0, Single(data, 0, instance, instancesIdMap, 0))
end

local Recursive = Serializers.Recursive
function InstanceSerializer.Recursive(instance: Instance)
	local allocation = #instance:GetDescendants() * instanceAllocation
	local data = create(allocation)

	local instancesIdMap = { [instance] = 0 }
	local offset = Recursive(data, 0, instance, instancesIdMap, 0)

	return readstring(data, 0, offset)
end

-- Slower speed, smaller output size
local RecursiveWithDiffs = Serializers.RecursiveWithDiffs
function InstanceSerializer.RecursiveWithDiffs(instance: Instance)
	local allocation = #instance:GetDescendants() * instanceAllocation
	local data = create(allocation)

	local instancesIdMap = { [instance] = 1 }
	local offset = RecursiveWithDiffs(data, 0, instance, instancesIdMap, 1, {})

	return readstring(data, 0, offset)
end

return InstanceSerializer

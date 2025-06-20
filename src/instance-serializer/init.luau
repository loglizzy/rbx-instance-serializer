-- Private
local ClassMapper = require(script["pre-processing"].ClassMapper)
local classMap, deserialClassMap = ClassMapper.GenerateMapping()

local Serialization = require(script.processing.Serialization)
Serialization.SetClassMap(classMap)

local Deserialization = require(script.processing.Deserialization)
Deserialization.SetClassMap(deserialClassMap)

-- Public
local InstanceSerializer = {}

local instanceAllocation = 300
local create = buffer.create
local Single = Serialization.Single
local readstring = buffer.readstring
function InstanceSerializer.Single(instance: Instance)
	local data = create(instanceAllocation)
	local instancesIdMap = { [instance] = 0 }

	return readstring(data, 0, Single(data, 0, instance, instancesIdMap, 0))
end

local Recursive = Serialization.Recursive
function InstanceSerializer.Recursive(instance: Instance)
	local allocation = #instance:GetDescendants() * instanceAllocation
	local data = create(allocation)

	local instancesIdMap = { [instance] = 0 }
	local offset = Recursive(data, 0, instance, instancesIdMap, 0)

	return readstring(data, 0, offset)
end

-- Slower speed, smaller output size
local RecursiveWithDiffs = Serialization.RecursiveWithDiffs
function InstanceSerializer.RecursiveWithDiffs(instance: Instance)
	local allocation = #instance:GetDescendants() * instanceAllocation
	local data = create(allocation)

	local instancesIdMap = { [instance] = 1 }
	local offset = RecursiveWithDiffs(data, 0, instance, instancesIdMap, 1, {})

	return readstring(data, 0, offset)
end

function InstanceSerializer.DeSingle(serial: string)
	local data = buffer.fromstring(serial)
	local instance = Deserialization.DeSingle(data, 0)

	return instance
end

return InstanceSerializer

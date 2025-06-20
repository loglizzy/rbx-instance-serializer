-- Private
local ClassMapper = require(script["class-mapper"])
local classMap, deserialClassMap = ClassMapper.GenerateMapping()

local instanceSerialization = require(script.serializing.instance.Serialization)
instanceSerialization.SetClassMap(classMap)

local instanceDeserialization = require(script.serializing.instance.Deserialization)
instanceDeserialization.SetClassMap(deserialClassMap)

-- Public
local InstanceSerializer = {}

local instanceAllocation = 300
local create = buffer.create
local Single = instanceSerialization.Single
local readstring = buffer.readstring
function InstanceSerializer.Single(instance: Instance)
	local data = create(instanceAllocation)
	local instancesIdMap = { [instance] = 0 }

	return readstring(data, 0, Single(data, 0, instance, instancesIdMap, 0))
end

local Recursive = instanceSerialization.Recursive
function InstanceSerializer.Recursive(instance: Instance)
	local allocation = #instance:GetDescendants() * instanceAllocation
	local data = create(allocation)

	local instancesIdMap = { [instance] = 0 }
	local offset = Recursive(data, 0, instance, instancesIdMap, 0)

	return readstring(data, 0, offset)
end

-- Slower speed, smaller output size
local RecursiveWithDiffs = instanceSerialization.RecursiveWithDiffs
function InstanceSerializer.RecursiveWithDiffs(instance: Instance)
	local allocation = #instance:GetDescendants() * instanceAllocation
	local data = create(allocation)

	local instancesIdMap = { [instance] = 1 }
	local offset = RecursiveWithDiffs(data, 0, instance, instancesIdMap, 1, {})

	return readstring(data, 0, offset)
end

function InstanceSerializer.DeSingle(serial: string)
	local data = buffer.fromstring(serial)
	local instance = instanceDeserialization.DeSingle(data, 0)

	return instance
end

return InstanceSerializer

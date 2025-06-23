-- Private
local modules = script.modules
local ClassMapper = require(modules["class-mapper"])
local classMap, deserialClassMap = ClassMapper.GenerateMapping()

local instanceSerialization, instanceDeserialization = unpack(require(modules["instance-serialization"]))
instanceSerialization.SetClassMap(classMap)
instanceDeserialization.SetDeserialClassMap(deserialClassMap)

-- Public
local InstanceSerializer = {}

local instanceAllocation = 240
local create = buffer.create
local SingleInstance = instanceSerialization.SingleInstance
local readstring = buffer.readstring
function InstanceSerializer.SingleInstance(instance: Instance)
	local data = create(instanceAllocation)
	local instancesIdMap = { [instance] = 0 }

	return readstring(data, 0, SingleInstance(data, 0, instance, instancesIdMap, 0))
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

function InstanceSerializer.DeSingleInstance(serial: string)
	local data = buffer.fromstring(serial)
	local instance = instanceDeserialization.DeSingleInstance(data, 0)

	return instance
end

return InstanceSerializer

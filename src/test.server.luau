local InstanceSerializer = require(script.Parent["instance-serializer"])

local model = workspace:FindFirstChildOfClass("Model")

local serializationFunctions = {
	single = InstanceSerializer.Single,
	recursive = InstanceSerializer.Recursive,
	recursiveWithDiffs = InstanceSerializer.RecursiveWithDiffs,
}
local function TestSerialization()
	print("model has", #model:GetDescendants(), "child instances")
	for i, serializeFn in serializationFunctions do
		local start = os.clock()
		local output = serializeFn(model)
		local elapsed = os.clock() - start

		warn(i)
		print(#output, "b")
		print(#output / 1000, "kb")
		print(#output / 1000000, "mb")
		print(elapsed, "secs")
	end
end

TestSerialization()

-- Unserialization
local function TestDeserialization()
	local serial = InstanceSerializer.Single(model)
	local instance = InstanceSerializer.DeSingle(serial)
	print(instance)

	instance.Parent = workspace
end

model = workspace.Part
TestDeserialization()

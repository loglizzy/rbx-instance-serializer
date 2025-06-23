local ServerScriptService = game:GetService("ServerScriptService")
local InstanceSerializer = require(ServerScriptService.lib)

local target = workspace:FindFirstChildOfClass("Model") or workspace:FindFirstAncestorOfClass("Folder")
assert(target, "Missing Model or Folder at workspace for testing, please grab anyone from the toolbox.")
print("Model has", #target:GetDescendants(), "child instances")

local serializationTests = {
	{"SingleInstance(only selected instance and nothing else)", InstanceSerializer.SingleInstance},
	{"Recursive(instance + descendants)", InstanceSerializer.Recursive},
	{"RecursiveWithDiffs(Recursive function + size reduction)", InstanceSerializer.RecursiveWithDiffs},
}

print("Testing each serialization function...")
for i, test in serializationTests do
	local testName, testFunction = unpack(test)

	local start = os.clock()
	local output = testFunction(target)
	local elapsed = os.clock() - start

	warn(testName)
	print(#output, "b")
	print(#output / 1000, "kb")
	print(#output / 1000000, "mb")
	print(elapsed, "secs")
end

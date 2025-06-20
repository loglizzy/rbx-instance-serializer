local InstanceSerializer = require(script.Parent["instance-serializer"])

local model = workspace:FindFirstChildOfClass("Model")
print("model has", #model:GetDescendants(), "child instances")
for i, serializeFn in InstanceSerializer do
	local start = os.clock()
	local output = serializeFn(model)
	local elapsed = os.clock() - start

    warn(i)
	print(#output, "b")
	print(#output / 1000, "kb")
	print(#output / 1000000, "mb")
	print(elapsed, "secs")
end

task.wait(1)

local InstanceSerializer = require(script.Parent["instance-serializer"])
local Recursive = InstanceSerializer.Recursive

local model = workspace:FindFirstChildOfClass("Model")
print(#model:GetDescendants(), "child instances")

local start = os.clock()
local output = Recursive(model)
local elapsed = os.clock() - start

print(#output, "b")
print(#output/1000, "kb")
print(#output/1000000, "mb")
print(elapsed, "secs")

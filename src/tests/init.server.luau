local target = workspace:FindFirstChildOfClass("Model") or workspace:FindFirstAncestorOfClass("Folder")
assert(target, "Missing Model or Folder at workspace for testing, please grab anyone from the toolbox.")

print("Target has", #target:GetDescendants(), "child instances.")

-- Run all tests
local tests = script:GetChildren()
for i, test in tests do
    print()
	print("TEST", test.Name)
	require(test)(target)
end

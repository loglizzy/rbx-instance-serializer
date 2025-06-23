local ServerScriptService = game:GetService("ServerScriptService")
local InstanceSerializer = require(ServerScriptService.lib)

local serializationTests = {
	{ "SingleInstance(only selected instance and nothing else)", InstanceSerializer.SingleInstance },
	{ "Recursive(instance + descendants)", InstanceSerializer.Recursive },
	{ "RecursiveWithDiffs(Recursive function + size reduction)", InstanceSerializer.RecursiveWithDiffs },
}

return function(target: Instance)
	for i, test in serializationTests do
		local testName, testFunction = unpack(test)

		local start = os.clock()
		local output = testFunction(target)
		local elapsed = os.clock() - start

		warn(testName)
		print(#output, "bytes/characters")
		print(elapsed, "secs")
	end
end

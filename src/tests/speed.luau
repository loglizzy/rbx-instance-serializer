local ServerScriptService = game:GetService("ServerScriptService")
local InstanceSerializer = require(ServerScriptService.lib)

local SingleInstance = InstanceSerializer.SingleInstance
local clock = os.clock
local steps, stepsLabel = 1_000_000, "1 million"
local billion = 1_000_000_000
return function(target: Instance)
	local elapsed = 0
    local lowest = math.huge
	for i = 1, steps do
		local start = clock()
		SingleInstance(target)

		local took = clock() - start
        if took < lowest then
            lowest = took
        end

        elapsed += took
	end

	warn(`Speed overview after serializing {stepsLabel} times:`)
	print(`Time took to serialize all:`, elapsed)
	local avarage = elapsed / steps
	print("Avarage time per serialization:", avarage)
    print("Lowest time in all:", lowest)

    warn("Minutes needed to serialize 1 billion instances:")
    print("Using the avarage speed:", (avarage * billion) / 60)
	print("Using the best speed reached:", (lowest * billion) / 60)
end

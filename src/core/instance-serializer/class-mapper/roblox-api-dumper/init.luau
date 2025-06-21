local Types = require(script.types)
type APIDump = Types.APIDump

local RLBXAPIDumper = {}
local HttpService = game:GetService("HttpService")
local localDumpModule = script.dump
function RLBXAPIDumper.fetchAndDecodeDump(fromWeb: boolean?): APIDump
	if fromWeb then
		-- Fetching api dump from the web
		-- This gets the latest dump from the Roblox Client Tracker repository
		local APIDump = HttpService:GetAsync(
			"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json"
		)
		APIDump = HttpService:JSONDecode(APIDump)

		return APIDump :: APIDump
	else
		return require(localDumpModule)
	end
end

return RLBXAPIDumper

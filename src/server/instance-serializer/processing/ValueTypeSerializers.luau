local format = require(script.Parent.Parent.format)
local INT_FORMAT = format.INT
local VECTOR_3_FORMAT = format.INT
local COLOR_3_FORMAT = format.COLOR_3
local UDIM_2_FORMAT = format.UDIM_2
local CFRAME_FORMAT = format.CFRAME
local UDIM_FORMAT = format.INT
local ENUM_FORMAT = format.ENUM

local stringPack = string.pack
local min = math.min
return {
	int = function(x)
		return stringPack(INT_FORMAT, x)
	end,
	Vector3 = function(x: Vector3)
		return stringPack(VECTOR_3_FORMAT, x.X, x.Y, x.Z)
	end,
	bool = function(x: boolean)
		return x and "\1" or "\0"
	end,
	Color3 = function(x: Color3)
		return stringPack(COLOR_3_FORMAT, min(255, x.R * 255), min(255, x.G * 255), min(255, x.B * 255))
	end,
	UDim2 = function(x: UDim2)
		return stringPack(UDIM_2_FORMAT, x.X.Scale, x.X.Offset, x.Y.Scale, x.Y.Offset)
	end,
	CFrame = function(x: CFrame)
		local pos = x.Position
		local look = x.LookVector
		return stringPack(CFRAME_FORMAT, pos.X, pos.Y, pos.Z, look.X, look.Y, look.Z)
	end,
	UDim = function(x: UDim)
		return stringPack(UDIM_FORMAT, x.Scale, x.Offset)
	end,
	BrickColor = function(x: BrickColor)
		return stringPack(ENUM_FORMAT, x.Number)
	end,
	Vector2 = function(x: Vector2)
		return stringPack("ff", x.X, x.Y)
	end,
	NumberSequence = function(x: NumberSequence)
		local result = stringPack("i", #x.Keypoints)
		for _, keypoint in x.Keypoints do
			result ..= stringPack("fff", keypoint.Time, keypoint.Value, keypoint.Envelope)
		end
		return result
	end,
	NumberRange = function(x: NumberRange)
		return stringPack("ff", x.Min, x.Max)
	end,
}

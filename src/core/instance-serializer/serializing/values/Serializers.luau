--[[
    Serializers.luau
    ----------------
    Provides serializer functions for various Roblox value types.
    Each function writes a value of a specific type to a buffer at a given offset.
    Returns the new offset after writing.
]]

local writei32 = buffer.writei32
local writef32 = buffer.writef32
local writeu8 = buffer.writeu8

return {
	-- Serializes an integer value (4 bytes)
	int = function(b: buffer, o: number, x: number)
		writei32(b, o, x)
		return o + 4
	end,
	-- Serializes a Vector3 value (3 floats)
	Vector3 = function(b: buffer, o: number, x: Vector3)
		writef32(b, o, x.X)
		o += 4
		writef32(b, o, x.Y)
		o += 4
		writef32(b, o, x.Z)
		return o + 4
	end,
	-- Serializes a boolean value (1 byte)
	bool = function(b: buffer, o: number, x: boolean)
		writeu8(b, o, if x then 1 else 0)
		return o + 1
	end,
	-- Serializes a Color3 value (3 bytes, 0-255)
	Color3 = function(b: buffer, o: number, x: Color3)
		writeu8(b, o, x.R * 255)
		o += 1
		writeu8(b, o, x.G * 255)
		o += 1
		writeu8(b, o, x.B * 255)
		return o + 1
	end,
	-- Serializes a UDim2 value (4 floats)
	UDim2 = function(b: buffer, o: number, x: UDim2)
		writef32(b, o, x.X.Scale)
		o += 4
		writef32(b, o, x.X.Offset)
		o += 4
		writef32(b, o, x.Y.Scale)
		o += 4
		writef32(b, o, x.Y.Offset)
		return o + 4
	end,
	-- Serializes a CFrame value (position + quaternion, 7 floats)
	CFrame = function(b: buffer, o: number, x: CFrame)
		local x, y, z, qX, qY, qZ, qW = x:GetComponents()
		writef32(b, o, x)
		o += 4
		writef32(b, o, y)
		o += 4
		writef32(b, o, z)
		o += 4
		writef32(b, o, qX)
		o += 4
		writef32(b, o, qY)
		o += 4
		writef32(b, o, qZ)
		o += 4
		writef32(b, o, qW)
		return o + 4
	end,
	-- Serializes a UDim value (scale, offset)
	UDim = function(b: buffer, o: number, x: UDim)
		writef32(b, o, x.Scale)
		o += 4
		writef32(b, o, x.Offset)
		return o + 4
	end,
	-- Serializes a BrickColor value (as int)
	BrickColor = function(b: buffer, o: number, x: BrickColor)
		writei32(b, o, x.Number)
		return o + 4
	end,
	-- Serializes a Vector2 value (2 floats)
	Vector2 = function(b: buffer, o: number, x: Vector2)
		writef32(b, o, x.X)
		o += 4
		writef32(b, o, x.Y)
		return o + 4
	end,
	-- Serializes a NumberSequence value (count + keypoints)
	NumberSequence = function(b: buffer, o: number, x: NumberSequence)
		writei32(b, o, #x.Keypoints)
		o += 4
		for _, keypoint in x.Keypoints do
			writef32(b, o, keypoint.Time)
			o += 4
			writef32(b, o, keypoint.Value)
			o += 4
			writef32(b, o, keypoint.Envelope)
			o += 4
		end
		return o
	end,
	-- Serializes a NumberRange value (min, max)
	NumberRange = function(b: buffer, o: number, x: NumberRange)
		writef32(b, o, x.Min)
		o += 4
		writef32(b, o, x.Max)
		return o + 4
	end,
}

local format = require(script.Parent.Parent.format)

local min = math.min
return {
	int = function(b: buffer, o: number, x: number)
		buffer.writei32(b, o, x)
		return o + 4
	end,
	Vector3 = function(b: buffer, o: number, x: Vector3)
		buffer.writef32(b, o, x.X)
		o += 4
		buffer.writef32(b, o, x.Y)
		o += 4
		buffer.writef32(b, o, x.Z)
		return o + 4
	end,
	bool = function(b: buffer, o: number, x: boolean)
		buffer.writeu8(b, o, if x then 1 else 0)
		return o + 1
	end,
	Color3 = function(b: buffer, o: number, x: Color3)
		buffer.writeu8(b, o, min(255, x.R * 255))
		o += 1
		buffer.writeu8(b, o, min(255, x.G * 255))
		o += 1
		buffer.writeu8(b, o, min(255, x.B * 255))
		return o + 1
	end,
	UDim2 = function(b: buffer, o: number, x: UDim2)
		buffer.writef32(b, o, x.X.Scale)
		o += 4
		buffer.writef32(b, o, x.X.Offset)
		o += 4
		buffer.writef32(b, o, x.Y.Scale)
		o += 4
		buffer.writef32(b, o, x.Y.Offset)
		return o + 4
	end,
	CFrame = function(b: buffer, o: number, x: CFrame)
		local pos = x.Position
		local look = x.LookVector
		buffer.writef32(b, o, pos.X)
		o += 4
		buffer.writef32(b, o, pos.Y)
		o += 4
		buffer.writef32(b, o, pos.Z)
		o += 4
		buffer.writef32(b, o, look.X)
		o += 4
		buffer.writef32(b, o, look.Y)
		o += 4
		buffer.writef32(b, o, look.Z)
		return o + 4
	end,
	UDim = function(b: buffer, o: number, x: UDim)
		buffer.writef32(b, o, x.Scale)
		o += 4
		buffer.writef32(b, o, x.Offset)
		return o + 4
	end,
	BrickColor = function(b: buffer, o: number, x: BrickColor)
		buffer.writei32(b, o, x.Number)
		return o + 4
	end,
	Vector2 = function(b: buffer, o: number, x: Vector2)
		buffer.writef32(b, o, x.X)
		o += 4
		buffer.writef32(b, o, x.Y)
		return o + 4
	end,
	NumberSequence = function(b: buffer, o: number, x: NumberSequence)
		buffer.writei32(b, o, #x.Keypoints)
		o += 4
		for _, keypoint in x.Keypoints do
			buffer.writef32(b, o, keypoint.Time)
			o += 4
			buffer.writef32(b, o, keypoint.Value)
			o += 4
			buffer.writef32(b, o, keypoint.Envelope)
			o += 4
		end
		return o
	end,
	NumberRange = function(b: buffer, o: number, x: NumberRange)
		buffer.writef32(b, o, x.Min)
		o += 4
		buffer.writef32(b, o, x.Max)
		return o + 4
	end,
}

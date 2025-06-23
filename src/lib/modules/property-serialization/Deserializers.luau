--[[
    Deserializers.luau
    ------------------
    Provides deserializer functions for various Roblox value types.
    Each function reads a value of a specific type from a buffer at a given offset.
    Returns the value and the new offset after reading.
]]

local readi32 = buffer.readi32
local readf32 = buffer.readf32
local readu8 = buffer.readu8

return {
    -- Deserializes an integer value (4 bytes)
    int = function(b: buffer, o: number)
        return readi32(b, o), o + 4
    end,
    -- Deserializes a Vector3 value (3 floats)
    Vector3 = function(b: buffer, o: number)
        local x = readf32(b, o)
        o += 4
        local y = readf32(b, o)
        o += 4
        local z = readf32(b, o)
        return Vector3.new(x, y, z), o + 4
    end,
    -- Deserializes a boolean value (1 byte)
    bool = function(b: buffer, o: number)
        return readu8(b, o) ~= 0, o + 1
    end,
    -- Deserializes a Color3 value (3 bytes, 0-255)
    Color3 = function(b: buffer, o: number)
        local r = readu8(b, o) / 255
        o += 1
        local g = readu8(b, o) / 255
        o += 1
        local b_ = readu8(b, o) / 255
        return Color3.new(r, g, b_), o + 1
    end,
    -- Deserializes a UDim2 value (4 floats)
    UDim2 = function(b: buffer, o: number)
        local xScale = readf32(b, o)
        o += 4
        local xOffset = readf32(b, o)
        o += 4
        local yScale = readf32(b, o)
        o += 4
        local yOffset = readf32(b, o)
        return UDim2.new(xScale, xOffset, yScale, yOffset), o + 4
    end,
    -- Deserializes a CFrame value (position + quaternion, 7 floats)
    CFrame = function(b: buffer, o: number)
        local x = readf32(b, o)
        o += 4
        local y = readf32(b, o)
        o += 4
        local z = readf32(b, o)
        o += 4
        local qX = readf32(b, o)
        o += 4
        local qY = readf32(b, o)
        o += 4
        local qZ = readf32(b, o)
        o += 4
        local qW = readf32(b, o)
        return CFrame.new(x, y, z, qX, qY, qZ, qW), o + 4
    end,
    -- Deserializes a UDim value (scale, offset)
    UDim = function(b: buffer, o: number)
        local scale = readf32(b, o)
        o += 4
        local offset = readf32(b, o)
        return UDim.new(scale, offset), o + 4
    end,
    -- Deserializes a BrickColor value (as int)
    BrickColor = function(b: buffer, o: number)
        local num = readi32(b, o)
        return BrickColor.new(num), o + 4
    end,
    -- Deserializes a Vector2 value (2 floats)
    Vector2 = function(b: buffer, o: number)
        local x = readf32(b, o)
        o += 4
        local y = readf32(b, o)
        return Vector2.new(x, y), o + 4
    end,
    -- Deserializes a NumberSequence value (count + keypoints)
    NumberSequence = function(b: buffer, o: number)
        local count = readi32(b, o)
        o += 4
        local keypoints = table.create(count)
        for i = 1, count do
            local time = readf32(b, o)
            o += 4
            local value = readf32(b, o)
            o += 4
            local envelope = readf32(b, o)
            o += 4
            keypoints[i] = NumberSequenceKeypoint.new(time, value, envelope)
        end
        return NumberSequence.new(keypoints), o
    end,
    -- Deserializes a NumberRange value (min, max)
    NumberRange = function(b: buffer, o: number)
        local min = readf32(b, o)
        o += 4
        local max = readf32(b, o)
        return NumberRange.new(min, max), o + 4
    end,
}

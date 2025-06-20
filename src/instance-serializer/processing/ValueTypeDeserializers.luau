local readi32 = buffer.readi32
local readf32 = buffer.readf32
local readu8 = buffer.readu8

return {
    int = function(b: buffer, o: number)
        return readi32(b, o), o + 4
    end,
    Vector3 = function(b: buffer, o: number)
        local x = readf32(b, o)
        o += 4
        local y = readf32(b, o)
        o += 4
        local z = readf32(b, o)
        return Vector3.new(x, y, z), o + 4
    end,
    bool = function(b: buffer, o: number)
        return readu8(b, o) ~= 0, o + 1
    end,
    Color3 = function(b: buffer, o: number)
        local r = readu8(b, o) / 255
        o += 1
        local g = readu8(b, o) / 255
        o += 1
        local b_ = readu8(b, o) / 255
        return Color3.new(r, g, b_), o + 1
    end,
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
    UDim = function(b: buffer, o: number)
        local scale = readf32(b, o)
        o += 4
        local offset = readf32(b, o)
        return UDim.new(scale, offset), o + 4
    end,
    BrickColor = function(b: buffer, o: number)
        local num = readi32(b, o)
        return BrickColor.new(num), o + 4
    end,
    Vector2 = function(b: buffer, o: number)
        local x = readf32(b, o)
        o += 4
        local y = readf32(b, o)
        return Vector2.new(x, y), o + 4
    end,
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
    NumberRange = function(b: buffer, o: number)
        local min = readf32(b, o)
        o += 4
        local max = readf32(b, o)
        return NumberRange.new(min, max), o + 4
    end,
}

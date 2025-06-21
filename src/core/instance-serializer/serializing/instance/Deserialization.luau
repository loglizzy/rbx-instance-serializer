--[[
    Deserialization.luau
    --------------------
    Provides functions to deserialize Roblox Instances from a compact binary format.
    Handles general, instance, and string properties, and supports mapping for fast instantiation.
    
    Functions:
    - Deserialization.DeSingle: Deserializes a single instance from buffer.
    - Deserialization.SetClassMap: Sets the class mapping for deserialization.
]]

local deserialClassMap: {}

-- Public
local Deserialization = {}

local readu16 = buffer.readu16
local readu8 = buffer.readu8
local readstring = buffer.readstring

-- Deserializes a single instance from the buffer.
-- data: buffer to read from
-- offset: current read position
-- Returns the deserialized instance and new offset.
function Deserialization.DeSingle(data: buffer, offset: number)
    -- Read class id
    local classId = readu16(data, offset)
    offset += 2

    local instanceDeserialClassMap = deserialClassMap[classId]

    -- Create the instance using the precompiled Instance.new(className) function
    local instance: Instance = instanceDeserialClassMap[1]()

    -- Read the total number of general properties
    local totalGeneralProperties = readu8(data, offset)
    offset += 1
    
    -- Deserialize general properties
    local generalDeserialClassMap = instanceDeserialClassMap[2]
    for _ = 1, totalGeneralProperties do
        -- Read the property ID
        local propId = readu8(data, offset)
        offset += 1

        local propMap = generalDeserialClassMap[propId]
        local propName, propDeserializer = propMap[1], propMap[2]
        local propValue
        propValue, offset = propDeserializer(data, offset, instanceDeserialClassMap[2])
        
        -- Update the instance property with the deserialized value
        instance[propName] = propValue
    end

    -- Read the total number of string properties
    local totalStringProperties = readu8(data, offset)
    offset += 1

    -- Deserialize string properties
    local stringDeserialClassMap = instanceDeserialClassMap[3]
    for _ = 1, totalStringProperties do
        -- Read property id
        local propId = readu8(data, offset)
        offset += 1

        -- Read the length of the string value
        local propStringValueLen = readu8(data, offset)
        offset += 1

        local propName = stringDeserialClassMap[propId]
        -- Update the instance property with the following string value
        instance[propName] = readstring(data, offset, propStringValueLen)
        offset += propStringValueLen
    end

    return instance, offset
end

-- Sets the deserialization class map for fast instance creation.
function Deserialization.SetClassMap(newDeserialClassMap: {})
	deserialClassMap = newDeserialClassMap
end

return Deserialization
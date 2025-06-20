local deserialClassMap: {}

-- Public
local Deserialization = {}

local readu16 = buffer.readu16
local readu8 = buffer.readu8
local readstring = buffer.readstring
function Deserialization.DeSingle(data: buffer, offset: number)
    local classId = readu16(data, offset)
    offset += 2

    local instanceDeserialClassMap = deserialClassMap[classId]

    -- Create the instance using the precompiled Instance.new(className) function
    local instance: Instance = instanceDeserialClassMap[1]()

    -- General properties
    local totalGeneralProperties = readu8(data, offset)
    offset += 1

    local generalClassMap = instanceDeserialClassMap[2]
    for i = 1, totalGeneralProperties do
        local propId = readu8(data, offset)
        offset += 1

        local propMap = generalClassMap[propId]
        local propName, propDeserializer = propMap[1], propMap[2]
        local propValue
        propValue, offset = propDeserializer(data, offset, instanceDeserialClassMap[2])
        
        instance[propName] = propValue
    end

    return instance, offset
end

function Deserialization.SetClassMap(newDeserialClassMap: {})
	deserialClassMap = newDeserialClassMap
end

return Deserialization
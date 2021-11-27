local _, Addon = ...

local Utils = Addon.Utils

function Utils:isArray(obj)
end

function Utils.isTable(obj)
end

function Utils:objKeys(obj)
    local keys={}
    local n=0
    for k,v in pairs(obj) do
        n=n+1
        keys[n]=k
    end

    return keys
end

function Utils:arrMap(arr, callback)
    local result = {}
    for i=1, #arr do
        local item = callback(arr[i], i)
        result[i] = item
    end
    return result
end

function Utils:arrForEach(arr, callback)
    for i=1, #arr do
        callback(arr[i], i)
    end
end


function Utils:arrPush(arr, item)
    table.insert(arr, item)
end


local _, Addon = ...

local Utils = Addon.Utils

function Utils:isArray(obj)
end

function Utils.isTable(obj)
end

function Utils:objKeys(obj)
    local keys = {}
    local n = 0
    for k,v in pairs(obj) do
        n = n + 1
        keys[n] = k
    end

    return keys
end

function Utils:objUpdateObj(obj, updateObj)
    for k,v in pairs(updateObj) do
        obj[k] = v
    end
end

function Utils:objDeepCopy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do
        res[Utils:objDeepCopy(k)] = Utils:objDeepCopy(v)
    end
    return res
end

function Utils:objShadowCopy(obj)
    local orig_type = type(obj)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(obj) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = obj
    end
    return copy
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

function Utils:arrSortBy(arr, key, reverse)
    if reverse == nil then
        reverse = false
    end
    local result = Utils:objShadowCopy(arr)
    local getVal = nil
    if type(key) == 'function' then
        getVal = key
    else
        getVal = function(item) return item[key] end
    end

    local function compare(a, b)
        if reverse then
            return getVal(a) > getVal(b)
        else
            return getVal(a) < getVal(b)
        end
    end
    table.sort(result, compare)

    return result
end

function Utils:arrFilter(arr, condFunc)
    local result = {}
    Utils:arrForEach(arr, function(item)
        if condFunc(item) then
            Utils:arrPush(result, item)
        end
    end)
    return result
end

function Utils:arrSlice(arr, startIdx, endIdx)
    local sliced = {}

    endIdx = endIdx - 1  -- 切片集合左闭右开，跟其它语言一样
    if endIdx > #arr then
        endIdx = #arr
    end

    for i=startIdx, endIdx do
        sliced[#sliced+1] = arr[i]
    end

    return sliced
end

function Utils:arrFind(arr, condFunc)
    for i=1, #arr do
        local item = arr[i]
        if condFunc(item) then
            return item
        end
    end
    return nil
end

function Utils:arrIndexBy(arr, key)
    local index = {}

    local getKey = nil
    if type(key) == 'function' then
        getKey = key
    else
        getKey = function(item) return item[key] end
    end

    self:arrForEach(arr, function(item)
        local keyVal = getKey(item)
        index[keyVal] = item
    end)

    return index
end

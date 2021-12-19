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

function Utils:arrChunkBySize(arr, size)
    local chunks = {}
    local chunk = {}
    Utils:arrPush(chunks, chunk)
    Utils:arrForEach(arr, function(item)
        Utils:arrPush(chunk, item)
        if #chunk == size then
            chunk = {}
            Utils:arrPush(chunks, chunk)
        end
    end)

    return chunks
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

function Utils:strJoin(arr, delimiter)
   local len = #arr
   if len == 0 then
      return ""
   end
   local string = arr[1]
   for i = 2, len do
      string = string .. delimiter .. arr[i]
   end
   return string
end

function Utils:strSplit(str, delimiter)
   local list = {}
   local pos = 1
   if strfind("", delimiter, 1) then -- this would result in endless loops
      error("delimiter matches empty string!")
   end
   while 1 do
      local first, last = strfind(str, delimiter, pos)
      if first then -- found?
         tinsert(list, strsub(str, pos, first-1))
         pos = last+1
      else
         tinsert(list, strsub(str, pos))
         break
      end
   end
   return list
end

function Utils:strStartsWith(str, Start)
    return string.sub(str,1, string.len(Start))==Start
end


local base64 = {}
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' -- You will need this for encoding/decoding
-- encoding
function base64.enc(data)
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function base64.dec(data)
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

Utils.base64 = base64
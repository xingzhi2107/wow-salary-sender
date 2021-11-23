RaidManager = LibStub('AceAddon-3.0'):NewAddon('RaidManager', 'AceConsole-3.0')
local AceGUI = LibStub("AceGUI-3.0")
local AceEvent = LibStub('AceEvent-3.0')
local AceSerializer = LibStub('AceSerializer-3.0')
addonName = ...

local SCALE_LENGTH = 10

RaidManager.DEFAULT_CONFIG = {}

-- context:
-- db的存储现在没有问题了，现在缺的是：
--   1. 一种好用编码方式，把salary-calc计算出来的结果导入进db. base64貌似有问题，ace的方案由容易被修改。wa的方案不知道是怎样的？
--      a. js计算出结果，转成lua。然后再将lua代码base64编码. ps. 估计也可以是js->json->base64, 见http://regex.info/code/JSON.lua
--      b. 实现一个输入框，输入base64
--      c. 解码
--      d. 用loadString来获取输入结果
--
--   2. 一个好的UI来预览这些数据

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

local testIdx = 1;
RaidManager.slashOptions = {
    name = addonName,
    type = 'group',
    args = {
        ping = {
            name = 'ping',
            desc = 'ping addon is loaded',
            type = 'execute',
            func = function ()
                RaidManager:Print(addonName .. '启用中')
            end
        },
        sendsalary = {
            name = 'sendsalary',
            desc = '工资邮寄',
            type = 'execute',
            func = function()
                RaidManager:SendCurrSalaryMail()
            end
        },
       test = {
          name = 'test',
          desc = 'test',
          type = 'execute',
          func = function()
              local salaries = RaidManager.db.global.salaries
              salaries[testIdx] = {
                  name = '迷雾卡夫卡',
                  salary = 172 + testIdx,
              }
              testIdx = testIdx + 1
             RaidManager:DisplayTotalSalary()
          end
       }
    }
}

function RaidManager:OnInitialize()
    RaidManager:Print(addonName .. '初始化...')
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, RaidManager.slashOptions, {"raidm"})
    RaidManager:Print(addonName .. '初始化成功！')
    self.db = LibStub("AceDB-3.0"):New("RaidManagerDB")
    local salaries = RaidManager.db.global.salaries
    if not salaries then
        RaidManager.db.global.salaries = {}
    end
    local code = [[
    emailConfig = {}
    emailConfig.title = 'test'
    ]]
    local f = loadstring(code)
    f()
    RaidManager:Print('测试global配置：' .. (base64.enc(TableToStr(emailConfig)) or ''))
    RaidManager:Print('测试global配置：MTIzNA==')
end

function RaidManager:OnEnable(args)
    RaidManager:Print(addonName .. '已启用')
end

function RaidManager:OnDisable(args)
    RaidManager:Print(addonName .. '已禁用')
end

function RaidManager:ShowSetup ()
end

MemberInfo = {}

function MemberInfo:new(name, subgroup, level, classCode, zone, online, isDead, role, isML)
    local o ={
        name = name,
        subgroup = subgroup,
        classCode = classCode,
        zone = zone,
        online = online,
        isDead = isDead,
        role = role,
        isML = isML,
    }

    setmetatable(o, self)
    self.__index = self
    return o
end


-- utils
local function setDefault(obj, key, defaultVal)
    if obj[key] then
        return obj[key]
    else
        obj[key] = defaultVal
        return defaultVal
    end
end

local function arrayShift(obj)
    if #obj == 0 then return nil end
    local element = table.remove(obj, 1)
    return element
end


local sents = {
}

local names = {

}

local currIndex = 1;

function RaidManager:SendCurrSalaryMail()
    if currIndex > #names then
        RaidManager:Print('所有人的工资发送完毕');
        return;
    end
    local player = names[currIndex];
    local salaries = player.salaries
    local player_salary = 0
    local note = '[' .. player.name ..']工资明细: '
    for j = 1, #salaries do
        salary_item = salaries[j]
        note = note .. salary_item.note .. ': ' .. salary_item.value .. ', '
        player_salary = player_salary + salary_item.value
    end
    note = note .. '  共计:  ' .. player_salary
    local subject = "11月21日，毒蛇神殿"
    local body = "基本工资：(17800) / 25 = 712G" .. note
    local unit = 100 * 100; -- 1g
    local salary = player_salary * unit;
    RaidManager:Print('准备给' .. player.name .. '发送工资. ' .. note);
    SetSendMailMoney(salary)
    SendMail(player.name, subject, body)
end

function RaidManager:DisplayTotalSalary()
    local totalSalary = 0
    for i=1, #names do
        local player = names[i];
        local salaries = player.salaries
        local player_salary = 0
        local note = '[' .. player.name ..']工资明细: '
        for j = 1, #salaries do
            local salary_item = salaries[j]
            note = note .. salary_item.note .. ': ' .. salary_item.value .. ', '
            player_salary = player_salary + salary_item.value
        end
        note = note .. '  共计:  ' .. player_salary
        RaidManager:Print(note)
        totalSalary = player_salary + totalSalary
    end

    local salaryGroupByNote = {}
    for i=1, #names do
        local player = names[i];
        local salaries = player.salaries
        for j = 1, #salaries do
            local salary_item = salaries[j]
            local note = salary_item.note
            if not salaryGroupByNote[note] then
                salaryGroupByNote[note] = {}
            end
            local salaries_in_note = salaryGroupByNote[note]
            salaries_in_note[#salaries_in_note+1] = salary_item
        end
    end

    for note, salary_items in pairs(salaryGroupByNote) do
        local noteTotal = 0
        for i=1, #salary_items do
            local salary_item = salary_items[i]
            noteTotal = noteTotal + salary_item.value
        end
        RaidManager:Print(note .. '人数： ' .. #salary_items .. ': ' .. noteTotal)
    end

    RaidManager:Print('人数：' .. #names)
    RaidManager:Print('全部工资总计：' .. totalSalary)
end

AceEvent:RegisterEvent("MAIL_SEND_SUCCESS", function(e)
    if currIndex > #names then
        RaidManager:Print('所有人的工资发送完毕');
        return;
    end
    local player = names[currIndex];
    local name = player.name;
    RaidManager:Print('给' .. name .. '的工资发送成功！');
    currIndex = currIndex + 1;
end)

AceEvent:RegisterEvent("MAIL_FAILED", function(e)
    if currIndex > #names then
        RaidManager:Print('所有人的工资发送完毕');
        return;
    end
    local m = names[currIndex];
    local name = m.name;
    RaidManager:Print('给' .. name .. '的工资发送失败！可能超过每天发送的上限 或者 G不够。');
end)

function ToStringEx(value)
    if type(value)=='table' then
       return TableToStr(value)
    elseif type(value)=='string' then
        return "\'"..value.."\'"
    else
       return tostring(value)
    end
end

function TableToStr(t)
    if t == nil then return "" end
    local retstr= "{"

    local i = 1
    for key,value in pairs(t) do
        local signal = ","
        if i==1 then
          signal = ""
        end

        if key == i then
            retstr = retstr..signal..ToStringEx(value)
        else
            if type(key)=='number' or type(key) == 'string' then
                retstr = retstr..signal..'['..ToStringEx(key).."]="..ToStringEx(value)
            else
                if type(key)=='userdata' then
                    retstr = retstr..signal.."*s"..TableToStr(getmetatable(key)).."*e".."="..ToStringEx(value)
                else
                    retstr = retstr..signal..key.."="..ToStringEx(value)
                end
            end
        end

        i = i+1
    end

     retstr = retstr.."}"
     return retstr
end

function StrToTable(str)
    if str == nil or type(str) ~= "string" then
        return
    end

    return loadstring("return " .. str)()
end
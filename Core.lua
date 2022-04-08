local addonName, Addon = ...

local Libs = Addon.Libs
local AceAddon = Libs.AceAddon
local AceEvent = Libs.AceEvent
local AceGUI = Libs.AceGUI
local DB = Addon.DB
local access = Addon.access
RaidManager = AceAddon:NewAddon('RaidManager', 'AceConsole-3.0')

local SCALE_LENGTH = 10
local Utils = Addon.Utils
local Frames = Addon.UI.Frames
local ItemToChar = Addon.ItemToChar
local type2Items = Addon.type2Items

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
       },
        list = {
            name = 'list',
            desc = '显示活动列表',
            type = 'execute',
            func = function()
                RaidManager:RenderListFrame()
            end
        },
        archive = {
            name = 'archive',
            desc = '归档材料到小号仓库',
            type = 'execute',
            func = function()
                RaidManager:ArchiveItems()
            end
        },
        pick = {
            name = 'pick',
            desc = '从银行取出材料',
            type = 'execute',
            func = function()
                RaidManager:PickItemsFromBank()
            end
        }
    }
}

function RaidManager:OnInitialize()
    RaidManager:Print(addonName .. '初始化...')
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, RaidManager.slashOptions, {"raidm"})
    DB:initDB()
    RaidManager:Print(addonName .. '初始化成功！')
end

function RaidManager:OnEnable(args)
    RaidManager:Print(addonName .. '已启用')
end

function RaidManager:OnDisable(args)
    RaidManager:Print(addonName .. '已禁用')
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

function RaidManager:RenderListFrame()
    local result = access.EventAccess:queryEvents()
    if RaidManager.listFrame and RaidManager.listFrame:IsShown() then
        AceGUI:Release(RaidManager.listFrame)
    end
    local function onClickImport(newEventInfo)
        RaidManager:HandleImportEvent(newEventInfo)
    end
    local function onClickItem(eventInfo)
        RaidManager.currEvent = eventInfo
        RaidManager:RenderListFrame()
    end

    local function onTestModeChanged(isTestMode)
        RaidManager.currEvent = nil
        RaidManager:RenderListFrame()
    end
    local function onClearTestData()
        DB:resetTestData()
        RaidManager.currEvent = nil
        RaidManager:RenderListFrame()
    end
    local currEvent = RaidManager.currEvent
    if currEvent == nil and #result.events > 0 then
        currEvent = result.events[1]
    end
    RaidManager.listFrame = Frames:EventListFrame({
        eventInfos = result.events,
        onImportSuccess = onClickImport,
        onClickItem = onClickItem,
        currEvent = currEvent,
        onTestModeChanged = onTestModeChanged,
        onClearTestData = onClearTestData,
    })
end

function RaidManager:HandleImportEvent(newEventInfo)
    access.EventAccess:importEvent(newEventInfo)
    RaidManager:RenderListFrame()
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

--AceEvent:RegisterEvent("MAIL_SEND_SUCCESS", function(e)
--    if currIndex > #names then
--        RaidManager:Print('所有人的工资发送完毕');
--        return;
--    end
--    local player = names[currIndex];
--    local name = player.name;
--    RaidManager:Print('给' .. name .. '的工资发送成功！');
--    currIndex = currIndex + 1;
--end)
--
--AceEvent:RegisterEvent("MAIL_FAILED", function(e)
--    if currIndex > #names then
--        RaidManager:Print('所有人的工资发送完毕');
--        return;
--    end
--    local m = names[currIndex];
--    local name = m.name;
--    RaidManager:Print('给' .. name .. '的工资发送失败！可能超过每天发送的上限 或者 G不够。');
--end)

local function containerForEach(bagIdStart, bagIdEnd, callback)
    for bagId = bagIdStart, bagIdEnd do
        local slotsCount = GetContainerNumSlots(bagId)
        for slot = 1, slotsCount do
            local itemId = GetContainerItemID(bagId, slot)
            callback(bagId, slot, itemId)
        end
    end
end

local function buildChar2Locations(bagIdStart, bagIdEnd)
    local type2Locations = {}
    containerForEach(bagIdStart, bagIdEnd, function(bagId, slot, itemId)
        if not itemId then
            return
        end
        local iName, iLink, iRarity, iLevel, iMinLevel, iType, iSubType, iStackCount, iEquipLoc, iIcon, iSellPrice, iClassID, iSubClassID, bType, eID, iSetID, isCraftingReagent = GetItemInfo(itemId)
        local itemLoc = ItemLocation:CreateFromBagAndSlot(bagId, slot)

        if C_Item.IsBound(itemLoc) then
            return
        end

        local char = ItemToChar[itemId]
        if not char then
            -- 所有未绑定的装备都给附魔号
            if iEquipLoc and iRarity > 1 then
                char = type2Items['魔'].character;
            end
        end

        if not char then
            return
        end

        if not type2Locations[char] then
            type2Locations[char] = {}
        end
        local locations = type2Locations[char]
        Utils:arrPush(locations, {
            bagId = bagId,
            slot = slot,
            itemId = itemId,
        })
    end)
    return type2Locations
end

function RaidManager:ArchiveItems()
    print('builod')
    local type2Locations = buildChar2Locations(0, 4)

    for char, locations in pairs(type2Locations) do
        C_FriendList.AddFriend(char)
        local chunks = Utils:arrChunkBySize(locations, 12)
        local chunk = chunks[1] -- 下一步再实现循环
        Utils:arrForEach(chunk, function(location)
            UseContainerItem(location.bagId, location.slot)
        end)
        -- Utils:arrForEach(chunks, function(chunk)
        --    Utils:arrForEach(chunk, function(location)
        --        UseContainerItem(location.bagId, location.slot)
        --    end)
        -- end)
        SendMail(char, '材料', '')
        return -- 发送玩一封，直接推出。往后再抽象出连续发送邮件的工具函数。
    end
end

function RaidManager:PickItemsFromBank()
    local type2Locations = buildChar2Locations(5, 11)
    for char, locations in pairs(type2Locations) do
        Utils:arrForEach(locations, function(location)
            UseContainerItem(location.bagId, location.slot)
        end)
    end
end

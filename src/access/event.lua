-- example
-- local event = {
--     id = "234332",
--     title = "毒蛇神殿",
--     eventTime = 1637762732,
--     emailBody = "装备总收入：233,234G\nBoss击杀总数：4\n补贴总支出：323.32。",
--     importTime = 1637763732,
--     isCompleted = false,
--     timeRemoved = 0,
--     salaries = {
--         1 = {
--             uuid = "3823-234823-23",
--             eventId = "234332"
--             name = "迷雾卡夫卡",
--             total = 100,
--             detailItem = {
--                 1 = {
--                     item = "基本工资(4/4)",
--                     salary = 138.34
--                 },
--                 2 = {
--                     item = "罚款",
--                     salary = -38.34
--                 },
--             },
--             optLogs = {
--                 1 = "2021-11-28 18:00:32 邮寄失败。 G币不够。",
--                 2 = "2021-11-28 18:00:33 邮寄失败。 G币不够。",
--                 3 = "2021-11-28 18:10:34 邮寄失败。 邮寄次数达到上限。",
--                 4 = "2021-11-28 18:11:34 手动删除",
--                 5 = "2021-11-28 18:12:34 手动恢复",
--                 6 = "2021-11-28 18:12:34 手动标记为已邮寄",
--             }
--             timeRemoved = 0,
--             timeSent = 0,
--         },
--     }
-- }
local _, Addon = ...

local EventAccess = {}
Addon.access.EventAccess = EventAccess
local Utils = Addon.Utils
local DB = Addon.DB

function EventAccess:queryEvents(opts)
    if opts == nil then
        opts = {}
    end

    local defaultOpts = {
        offset = 0,
        pageSize = 50,
        filterCompleted = false,
        showRemoved = false,
    }
    Utils:objUpdateObj(opts, defaultOpts)

    -- no more data
    if opts.nexOffset == -1 then
        return {}
    end

    local eventsTbl = DB:getTable('events')
    local allEvents = Utils:arrSortBy(eventsTbl, 'eventTime', true)
    if opts.filterCompleted then
        allEvents = Utils:arrFilter(allEvents, function(item) return (not item.isCompleted) end)
    end
    if not opts.showRemoved then
        allEvents = Utils:arrFilter(allEvents, function(item) return item.timeRemoved == 0 end)
    end

    local startIdx = opts.offset
    local endIdx = startIdx + opts.pageSize
    local targetEvents = Utils:arrSlice(allEvents, startIdx, endIdx)
    local nexOffset = endIdx
    if #targetEvents < opts.pageSize then
        nexOffset = -1
    end

    return {
        nexOffset = nexOffset,
        events = Utils:objDeepCopy(targetEvents),
    }
end

function EventAccess:importEvent(newEvent)
    local eventsTbl = DB:getTable('events')

    local mockId = #eventsTbl + 1
    local mockTime = 1609430400 + 3600 * 24 * mockId * 2
    local mockNewEvent = {
        id = mockId,
        title = "毒蛇神殿: " .. mockId,
        eventTime = mockTime,
        emailBody = "装备总收入：233,234G\nBoss击杀总数：4\n补贴总支出：323.32。",
        importTime = mockTime + 3600,
        isCompleted = false,
        timeRemoved = 0,
        salaries = {
            {
                uuid = mockId .. "1",
                eventId = mockId,
                name = "迷雾卡夫卡",
                total = 100,
                detailItem = {
                    {
                        item = "基本工资(4/4)",
                        salary = 138.34
                    },
                    {
                        item = "罚款",
                        salary = -38.34
                    },
                },
                optLogs = {
                    "2021-11-28 18:00:32 邮寄失败。 G币不够。",
                    "2021-11-28 18:00:33 邮寄失败。 G币不够。",
                    "2021-11-28 18:10:34 邮寄失败。 邮寄次数达到上限。",
                    "2021-11-28 18:11:34 手动删除",
                    "2021-11-28 18:12:34 手动恢复",
                    "2021-11-28 18:12:34 手动标记为已邮寄",
                },
                timeRemoved = 0,
                timeSent = 0,
            },
        }
    }

    newEvent = mockNewEvent
    Utils:arrPush(eventsTbl, newEvent)
end

function EventAccess:removeEvent()
end

function EventAccess:recoveryEvent()
end

function EventAccess:successSendSalary(eventId, salaryId)
end

function EventAccess:failedSendSalary(eventId, salaryId, reason)
end

function EventAccess:markSalarySent(eventId, salaryId)
end

function EventAccess:removeSalary(eventId, salaryId)
end

function EventAccess:recoverySalary(eventId, salaryId)
end

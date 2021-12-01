local _, Addon = ...

local EventAccess = {}
Addon.access.EventAccess = EventAccess
local Utils = Addon.Utils
local DB = Addon.DB
local Libs = Addon.Libs
local AceEvent = Libs.AceEvent
local AceTimer = Libs.AceTimer
local EventManager = Addon.EventManager


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

function EventAccess:importEvent(newEventInfo)
    local eventsTbl = DB:getTable('events')
    newEventInfo.importTime = time()

    local existsEvent = Utils:arrFind(eventsTbl, function(item) return item.id == newEventInfo.id  end)
    if existsEvent then
        print('导入失败，该活动数据已存在！')
        return
    end

    Utils:arrPush(eventsTbl, newEventInfo)
end

function EventAccess:removeEvent()
end

function EventAccess:recoveryEvent()
end

function EventAccess:sendSalary(eventId, salaryId)
    local hasEmailPending = C_Mail.IsCommandPending()
    if hasEmailPending then
        print('发送失败，正在发送其它邮件，请稍后重试！')
        return false
    end

    if self.sendingSalary ~= nil then
        print('发送失败，已经有一封工资邮件正在发送，请稍后重试！')
        return false
    end
    local eventsTbl = DB:getTable('events')
    local id2Event = Utils:arrIndexBy(eventsTbl, 'id')
    local event = id2Event[eventId]
    if not event then
        print('发送失败，未找到相应的活动。活动ID：' .. eventId)
        return false
    end

    local id2Salary = Utils:arrIndexBy(event.salaries, 'uuid')
    local salary = id2Salary[salaryId]
    if not salary then
        print('发送失败，未找到相应的工资。活动ID：' .. eventId .. '，工资ID：' .. salaryId)
        return false
    end

    if salary.timeSent ~= 0 then
        print('发送失败，该工资已经邮寄，请勿重复邮寄。活动ID：' .. eventId .. '，工资ID：' .. salaryId)
        return false
    end

    if salary.timeRemoved ~= 0 then
        print('发送失败，该工资已被删除，请勿邮寄。活动ID：' .. eventId .. '，工资ID：' .. salaryId)
        return false
    end


    local note = '[' .. salary.name ..']工资明细: \n\n'
    Utils:arrForEach(salary.detailItems, function(detailItem)
        note = note .. detailItem.item .. ': ' .. detailItem.value .. ', \n\n'
    end)
    note = note .. '共计:  ' .. salary.total
    local dateTimeStr = date('%Y-%m-%d', event.eventTime)
    local subject = dateTimeStr .. "，" .. event.title
    local body = event.emailBody .. "\n\n" .. note
    local unit = 100 * 100 -- 1g
    local sendMoney = salary.total * unit;
    local balance = GetMoney()
    if sendMoney > balance then
        print('发送失败，余额不足。活动ID：' .. eventId .. '，工资ID：' .. salaryId)
        return false
    end

    local mailCost = GetSendMailPrice()
    sendMoney = sendMoney - mailCost
    body = body .. "\n\n邮费：" .. mailCost .. "铜"

    if Addon.IS_TEST_MODE then
        subject = "[测试] " ..  subject
        sendMoney = 1
    end

    self.sendingSalary = salary
    SetSendMailMoney(sendMoney)
    local to = salary.name .. '-' .. salary.server
    SendMail(to, subject, body)

    return true
end

function EventAccess:successSentCurrSalary()
    local salary = self.sendingSalary
    self.sendingSalary = nil
    RaidManager:Print('给' .. salary.name .. '的工资发送成功！')
    salary.timeSent = time()
    EventManager:Fire('OnSendSalarySuccess', Utils:objDeepCopy(salary))
    if self.autoNext then
        AceTimer:ScheduleTimer(function()
            EventAccess:sendNextSalary(salary.eventId, true)
        end, 1)
    end
end

function EventAccess:failedSendCurrSalary()
    local salary = self.sendingSalary
    self.sendingSalary = nil
    self.autoNext = false
    RaidManager:Print('给' .. salary.name .. '的工资发送失败！可能超过每天发送的上限 或者 G不够。');
    EventManager:Fire('OnSendSalaryFailed', Utils:objDeepCopy(salary))
end


function EventAccess:sendNextSalary(eventId, autoNext)
    local hasEmailPending = C_Mail.IsCommandPending()
    if hasEmailPending then
        print('发送失败，正在发送其它邮件，请稍后重试！')
        return false
    end

    if self.sendingSalary ~= nil then
        print('发送失败，已经有一封工资邮件正在发送，请稍后重试！')
        return false
    end
    local eventsTbl = DB:getTable('events')
    local id2Event = Utils:arrIndexBy(eventsTbl, 'id')
    local event = id2Event[eventId]
    if not event then
        print('发送失败，未找到相应的活动。活动ID：' .. eventId)
        return false
    end
    local needSendSalaries = Utils:arrFilter(event.salaries, function(item) return item.timeSent == 0 end)
    if #needSendSalaries > 0 then
        self.autoNext = autoNext
        local toSendSalary = needSendSalaries[1]
        EventAccess:sendSalary(eventId, toSendSalary.uuid)
    end
end

function EventAccess:markSalarySent(eventId, salaryId)
end

function EventAccess:removeSalary(eventId, salaryId)
end

function EventAccess:recoverySalary(eventId, salaryId)
end


AceEvent:RegisterEvent("MAIL_SEND_SUCCESS", function(e)
    EventAccess:successSentCurrSalary()
end)

AceEvent:RegisterEvent("MAIL_FAILED", function(e)
    EventAccess:failedSendCurrSalary()
end)

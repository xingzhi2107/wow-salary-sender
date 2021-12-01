local _, Addon = ...
local Libs = Addon.Libs
local AceGUI = Libs.AceGUI
local Frames = Addon.UI.Frames
local Com = Addon.UI.Components
local Utils = Addon.Utils
local access = Addon.access
local EventManager = Addon.EventManager
local AceTimer = Libs.AceTimer

function Com:EventDetailContainer(eventInfo)
    if eventInfo == nil then
        return  nil
    end

    local root = AceGUI:Create('InlineGroup')
    root:SetWidth(620)
    root:SetHeight(520)
    root:SetLayout('Fill')

    local scroll = AceGUI:Create('ScrollFrame')
    scroll:SetLayout('List')
    root:AddChild(scroll)

    local title = AceGUI:Create('Label')
    title:SetText('活动：' .. eventInfo.title)

    local dateTime = AceGUI:Create('Label')
    local dateTimeStr = date('%Y-%m-%d %H:%M:%S', eventInfo.eventTime)
    dateTime:SetText('时间：' .. dateTimeStr)

    local sendAllBtn = AceGUI:Create('Button')
    sendAllBtn:SetText('邮寄所有工资')
    sendAllBtn:SetWidth(200)
    local autoSending = false
    sendAllBtn:SetCallback('OnClick', function()
        AceTimer:CancelAllTimers()
        if autoSending then
            autoSending = false
            sendAllBtn:SetText('邮寄所有工资')
        else
            autoSending = true
            sendAllBtn:SetText('暂停')
            access.EventAccess:sendNextSalary(eventInfo.id, true)
        end
    end)

    local emailBody = AceGUI:Create('MultiLineEditBox')
    emailBody:SetLabel("邮件内容：")
    emailBody:SetText(eventInfo.emailBody)
    emailBody:SetNumLines(7)
    emailBody:SetDisabled(true)
    emailBody:SetWidth(500)

    scroll:AddChild(title)
    scroll:AddChild(dateTime)
    scroll:AddChild(emailBody)
    scroll:AddChild(sendAllBtn)

    local salariesEl = AceGUI:Create('InlineGroup')
    salariesEl:SetLayout('Flow')
    salariesEl:SetWidth(578)
    scroll:AddChild(salariesEl)
    for i=1, #eventInfo.salaries do
        local salaryInfo = eventInfo.salaries[i]
        local idxLabel = AceGUI:Create('Label')
        idxLabel:SetText('序号：' .. i)
        idxLabel:SetWidth(80)

        local name = AceGUI:Create('Label')
        name:SetText('角色名：' .. salaryInfo.name)
        name:SetWidth(200)

        local salaryEl = AceGUI:Create('Label')
        salaryEl:SetText('工资：' .. salaryInfo.total .. 'G')
        salaryEl:SetWidth(150)

        local action = Com:SendSalaryBtn(eventInfo.id, salaryInfo)
        salariesEl:AddChild(idxLabel)
        salariesEl:AddChild(name)
        salariesEl:AddChild(salaryEl)
        salariesEl:AddChild(action)
    end

    return root
end

function Com:SendSalaryBtn(eventId, salary)
    local action = AceGUI:Create('Button')
    local sent = salary.timeSent ~= 0
    action:SetWidth(100)
    if not sent then
        action:SetText('邮寄')
        action:SetCallback('OnClick', function()
            if sent then
                return
            end

            local sending = access.EventAccess:sendSalary(eventId, salary.uuid)
            if sending then
                action:SetText('邮寄中...')
                action:SetDisabled(true)
            end
        end)
    else
        action:SetText('已邮寄')
        action:SetDisabled(true)
    end

    local unsub1 = EventManager:On('OnSendSalarySuccess', function(justSentSalary)
        if justSentSalary.uuid ~= salary.uuid then
            return
        end
        action:SetText('已邮寄')
        action:SetDisabled(true)
        sent = true
    end)
    local unsub2 = EventManager:On('OnSendSalaryFailed', function(justSentSalary)
        if justSentSalary.uuid ~= salary.uuid then
            return
        end
        action:SetText('邮寄')
        action:SetDisabled(false)
    end)

    action:SetCallback('OnRelease', function()
        unsub1()
        unsub2()
    end)


    return action
end

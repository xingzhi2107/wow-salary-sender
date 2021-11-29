function RaidManager:ShowSalaryManager()
    local taskTitle = nil
    local frame = AceGUI:Create("Frame")
    frame:SetTitle('团队工资邮寄管理')
    frame:SetCallback('OnClose', function (widget) AceGUI:Release(widget) end)
    frame:SetLayout('Flow')
    local status = '创建中'
    frame:SetStatusText(status)
    local scrollContainer = AceGUI:Create('SimpleGroup')
    scrollContainer:SetFullWidth(true)
    scrollContainer:SetFullHeight(true)
    scrollContainer:SetLayout('Fill')
    frame:AddChild(scrollContainer)
    local scroll = AceGUI:Create('ScrollFrame')
    scroll:SetLayout('List')
    scrollContainer:AddChild(scroll)

    -- salaries select
    local salaries = RaidManager.db.global.salaries
    local selectContainer = AceGUI:Create('InlineGroup')
    selectContainer:SetLayout("Flow")
    local dropdown = AceGUI:Create("Dropdown")
    dropdown:SetLabel('选择工资记录')
    dropdown:SetText("<空>")
    dropdown:SetList({[1]="张三",[2]="李四",[3]="王五"})
    dropdown:SetWidth(15*SCALE_LENGTH)
    dropdown:SetHeight(SCALE_LENGTH)
    local newSalaryEditor = RaidManager:renderEditField({
        label = '新建',
        width = 20 * SCALE_LENGTH,
        OnEnterPressed = function(widget, event, text)
            local salaries = RaidManager.db.global.salaries
            local newSalary = {
                title = text
            }
            salaries[#salaries + 1] = newSalary
            RaidManager:Print('保存成功: ' .. RaidManager.db.global.test)
        end
    })
    selectContainer:AddChild(newSalaryEditor)
    selectContainer:AddChild(dropdown)
    scroll:AddChild(selectContainer)

    -- content
    local emailContainer = AceGUI:Create("InlineGroup")
    emailContainer:SetLayout('List')
    emailContainer:SetTitle('邮件')
    emailContainer:SetFullWidth(true)
    emailContainer:SetHeight(20 * SCALE_LENGTH)
    emailContainer.noAutoHeight = true
    local subjectField = RaidManager:renderEditField({
        label = '标题',
        width = 400,
        OnEnterPressed = function(widget, event, text)
            RaidManager.db.global.test = text
            RaidManager:Print('保存成功: ' .. RaidManager.db.global.test)
        end
    })
    local bodyField = RaidManager:renderTextareField({
        label = '内容',
        width = 400,
        numLines = 5,
    })
    emailContainer:AddChild(subjectField)
    emailContainer:AddChild(bodyField)
    scroll:AddChild(emailContainer)

    -- members content
    local membersGroup = RaidManager:renderMembers()
    local membersContainer = AceGUI:Create("InlineGroup")
    membersContainer:SetTitle('最终工资')
    membersContainer:SetFullWidth(true)
    membersContainer:AddChild(membersGroup)
    scroll:AddChild(membersContainer)
end


function RaidManager:renderMembers()
    local membersContainer = AceGUI:Create('SimpleGroup')
    membersContainer:SetLayout('Flow')
    membersContainer:SetWidth(15 * 4.5 * SCALE_LENGTH)
    membersContainer:SetHeight(15 * 5.5 * SCALE_LENGTH)

    for i=1, 8 do
        local partyEl = RaidManager:rednerParty(i)
        membersContainer:AddChild(partyEl)
    end

    return membersContainer
end


function RaidManager:rednerParty(partyNO)
    local members = self.partyToMembers[partyNO]
    members = members or {}
    local party = AceGUI:Create("InlineGroup")
    party:SetLayout("List")
    party:SetTitle(partyNO .. '队')
    party:SetWidth(15*SCALE_LENGTH)
    party:SetHeight(27*SCALE_LENGTH)
    party.noAutoHeight = true

    for i=1, #members do
        local member = members[i]
        memberEl = RaidManager:renderEditField({
            label = member.name,
            iniVal = 0,
            width = 12 * SCALE_LENGTH,
        })
        party:AddChild(memberEl)
    end

    return party
end


function RaidManager:rednerSimpleGroup()
    local simpleGroup = AceGUI:Create('SimpleGroup')
    return simpleGroup
end

function RaidManager:renderEditField(meta)
    local val = meta.iniVal
    local editbox = AceGUI:Create('EditBox')
    local width = meta.width or 200
    editbox:SetLabel(meta.label)
    editbox:SetWidth(width)
    editbox:SetText(val)
    if meta.height then
        editbox:SetHeight(meta.height)
    end
    if meta.OnEnterPressed then
        editbox:SetCallback('OnEnterPressed', meta.OnEnterPressed)
    end

    return editbox
end


function RaidManager:renderTextareField(meta)
    local val = meta.iniVal or ''
    local editbox = AceGUI:Create('MultiLineEditBox')
    local width = meta.width or 200
    editbox:SetLabel(meta.label)
    editbox:SetWidth(width)
    editbox:SetText(val)
    if meta.height then
        editbox:SetHeight(meta.height)
    end
    if meta.numLines then
        editbox:SetNumLines(meta.numLines)
    end
    editbox:SetCallback('OnEnterPressed', function(widget, event, text) val = text end)

    return editbox
end


function RaidManager:renderTankSubsidy()
    local tankContainer = AceGUI:Create('InlineGroup')
    tankContainer:SetTitle('坦克')
    tankContainer:SetWidth(20 * SCALE_LENGTH)
    tankContainer:SetLayout('List')

    for i=1, 4 do
        tankContainer:AddChild(RaidManager:renderSubsidyItem({}))
    end

    return tankContainer
end


function RaidManager:renderHealerSubsidy()
    local container = AceGUI:Create('InlineGroup')
    container:SetTitle('治疗')
    container:SetWidth(20 * SCALE_LENGTH)
    container:SetLayout('List')

    for i=1, 10 do
        container:AddChild(RaidManager:renderSubsidyItem({}))
    end

    return container
end

function RaidManager:renderDPSSubsidy()
    local container = AceGUI:Create('InlineGroup')
    container:SetTitle('DPS')
    container:SetWidth(20 * SCALE_LENGTH)
    container:SetLayout('List')

    for i=1, 5 do
        container:AddChild(RaidManager:renderSubsidyItem({}))
    end

    return container
end


function RaidManager:renderSubsidyItem(info)
    local group = AceGUI:Create('SimpleGroup')
    group:SetLayout('Flow')

    local select = AceGUI:Create('Dropdown')
    select:SetList({[1]="张三",[2]="李四"})
    select:SetValue(1)
    select:SetWidth(9 * SCALE_LENGTH)

    local subsidy = RaidManager:renderEditField({
        iniVal = 0,
        width = 8 * SCALE_LENGTH
    })

    group:AddChild(select)
    group:AddChild(subsidy)

    return group
end

RaidManager = LibStub('AceAddon-3.0'):NewAddon('RaidManager', 'AceConsole-3.0')
local AceGUI = LibStub("AceGUI-3.0")
local AceEvent = LibStub('AceEvent-3.0')
addonName = ...

local SCALE_LENGTH = 10

PlayerClassEnum = {
    WARRIOR = 'WARRIOR',  --战士
    ROGUE   = 'ROGUE',    --盗贼
    MAGE    = 'MAGE',     --法师
    PRIEST  = 'PRIEST',   --牧师
    WARLOCK = 'WARLOCK',  --术士
    HUNTER  = 'HUNTER',   --猎人
    SHAMAN  = 'SHAMAN',   --萨满
    DRUID   = 'DRUID',    --德鲁伊
    PALADIN = 'PALADIN'   --圣骑士
}

RaidRoles = {
    MAINTANK = 'MAINTANK',  -- 坦克
    HEALER   = 'HEALER',    -- 治疗
    DPS      = 'DPS',       -- DPS
}


RaidManager.DEFAULT_CONFIG = {}

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
        ntask = {
            name = 'ntask',
            desc = 'create new task',
            type = 'execute',
            func = function ()
                RaidManager:createTask()
            end

        },
        salary = {
            name = 'salary',
            desc = '工资邮寄管理',
            type = 'execute',
            func = function()
                RaidManager:RefreshMembers()
                RaidManager:ShowSalaryManager()
            end
        }
    }
}

function RaidManager:OnInitialize()
    RaidManager:Print(addonName .. '初始化...')
    LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, RaidManager.slashOptions, {"raidm"})
    RaidManager:Print(addonName .. '初始化成功！')
end

function RaidManager:OnEnable(args)
    RaidManager:Print(addonName .. '已启用')
end

function RaidManager:OnDisable(args)
    RaidManager:Print(addonName .. '已禁用')
end

function RaidManager:createTask ()
    local taskTitle = nil
    local frame = AceGUI:Create("Frame")
    frame:SetTitle('团队管理')
    frame:SetStatusText('启用中')
    frame:SetCallback('OnClose', function (widget) AceGUI:Release(widget) end)
    frame:SetLayout('Flow')

    local editbox = AceGUI:Create('EditBox')
    editbox:SetLabel("任务名称")
    editbox:SetWidth(200)
    editbox:SetCallback('OnEnterPressed', function(widget, event, text) taskTitle = text end)
    frame:AddChild(editbox)

    local button = AceGUI:Create("Button")
    button:SetText('保存')
    button:SetWidth(80)
    button:SetCallback('OnClick', function(widget, event) RaidManager:Print('任务保存成功！' .. taskTitle) end)
    frame:AddChild(button)
end

function RaidManager:ShowSetup ()
end

function RaidManager:DrawMemberGroups ()
    -- 绘制团队配置,根据T、治疗、远程DPS、近战dps分组划开。
end

function RaidManager:DrawTaskManager()
    -- 绘制任务管理与分配
    -- 任务：坦克拉怪的标记、LR凝神的顺序、FS羊的标记。另外有一些特殊任务，比如某些特定boss、小怪的任务分配、看MT的治疗分配。
end


function RaidManager:AutoGroup()
    -- 自动分组
    -- 设置多种分组方案：1. 初始分组，4个MT在1、2组，优先QS、XD看T的血， 每组尽量一个ss，如果没有就小D，如果没有就空着， 近战组zs、lr + 其它物理攻击 + 一个ms/xd/qs；
    --                 2. bwl老一分组，分4个组
    --                 3. 分G的时候，根据T、治疗、DPS分组 
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

function RaidManager:RefreshMembers()
    local members = {}
    local partyToMembers = {}
    for i = 1, 40 do
        local name, rank, subgroup, level, class, classCode, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
        if name then
            local memberInfo = MemberInfo:new(name, subgroup, level, classCode, zone, online, isDead, role, isML)
            members[#members+1] = memberInfo
            if not partyToMembers[subgroup] then
                partyToMembers[subgroup] = {}
            end
            local subgroupMembers = partyToMembers[subgroup]
            subgroupMembers[#subgroupMembers+1] = memberInfo
        end
    end
    self.members = members
    self.partyToMembers = partyToMembers
    globalPTM = partyToMembers
end

function RaidManager:DisplayMembers()
    local members = RaidManager.members
    for i=1, #members do
        local member = members[i]
        RaidManager:Print(member.name)
    end
end


function RaidManager:AutoGroupByDefault()
    local members = RaidManager.members
    local classGroups = {
    }
    for i=1, #members do
        local member = members[i]
        if member.role == RaidRoles.MAINTANK then -- 主坦克 当作一个单独的职业
            classArray = setDefault(classGroups, RaidRoles.MAINTANK, {})
        else
            classArray = setDefault(classGroups, member.classCode, {})
        end
        classArray[#classArray+1] = member;
    end

    local raidGroups = {} -- 团队分组，从1-8
    local mainTanks = classGroups[RaidRoles.MAINTANK]
    for i=1, #mainTanks do
    end
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


local sents = {}

local names = {
}

local currIndex = 1;


function RaidManager:SendCurrSalaryMail()
    if currIndex > #names then
        RaidManager:Print('所有人的工资发送完毕');
        return;
    end
    local m = names[currIndex];
    local name = m.name;
    if m.sent then
        RaidManager:Print('给' .. name '的工资发送失败！已经发过了，不要重复发。');
        return;
    end
    local subject = "TAQ治疗补贴"
    local body = "治疗补贴：100。没收到工资请找 ‘非洲的娘娘’。"
    -- local unit = 1; -- 1铜
    local unit = 100 * 100; -- 1g
    local salary = 100 * unit;
    RaidManager:Print('准备给' .. name .. '发送工资');
    SetSendMailMoney(salary)
    SendMail(name, subject, body)
end

AceEvent:RegisterEvent("MAIL_SEND_SUCCESS", function(e)
    if currIndex > #names then
        RaidManager:Print('所有人的工资发送完毕');
        return;
    end
    local m = names[currIndex];
    local name = m.name;
    RaidManager:Print('给' .. name .. '的工资发送成功！');
    m.sent = true;
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

    -- email content
    local emailContainer = AceGUI:Create("InlineGroup")
    emailContainer:SetLayout('List')
    emailContainer:SetTitle('邮件')
    emailContainer:SetFullWidth(true)
    emailContainer:SetHeight(20*SCALE_LENGTH)
    emailContainer.noAutoHeight = true
    local subjectField = RaidManager:renderEditField({
        label = '标题',
        width = 400,
    })
    local bodyField = RaidManager:renderTextareField({
        label = '内容',
        width = 400,
        numLines = 5,
    })
    emailContainer:AddChild(subjectField)
    emailContainer:AddChild(bodyField)
    scroll:AddChild(emailContainer)

    scroll:AddChild(RaidManager:renderSubsidy())

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
    editbox:SetCallback('OnEnterPressed', function(widget, event, text) val = text end)

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


function RaidManager:renderSubsidy()
    local subSidyContainer = AceGUI:Create("InlineGroup")
    subSidyContainer:SetTitle('补贴')
    subSidyContainer:SetFullWidth(true)
    subSidyContainer:SetLayout('Flow')

    subSidyContainer:AddChild(RaidManager:renderTankSubsidy())
    subSidyContainer:AddChild(RaidManager:renderHealerSubsidy())
    subSidyContainer:AddChild(RaidManager:renderDPSSubsidy())

    return subSidyContainer
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

RaidManager = LibStub('AceAddon-3.0'):NewAddon('RaidManager', 'AceConsole-3.0')
local AceGUI = LibStub("AceGUI-3.0")
 addonName = ...

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
        test = {
            name = 'test',
            desc = 'trigger test function',
            type = 'execute',
            func = function() 
                RaidManager:RefreshMembers()
                RaidManager:DisplayMembers()
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
    members = {}
    for i = 1, 40 do
        local name, rank, subgroup, level, class, classCode, zone, online, isDead, role, isML = GetRaidRosterInfo(i);
        if name then
            local memberInfo = MemberInfo:new(name, subgroup, level, classCode, zone, online, isDead, role, isML)
            members[#members+1] = memberInfo
        end
    end
    self.members = members
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




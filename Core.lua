RaidManager = LibStub('AceAddon-3.0'):NewAddon('RaidManager', 'AceConsole-3.0')
local AceGUI = LibStub("AceGUI-3.0")
local AceEvent = LibStub('AceEvent-3.0')
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
                RaidManager:SendCurrSalaryMail()
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


local sents = {
    {
        name = "忙着可爱",
        sent = false,
    },
    {
        name = "喝诶黑嘚讴豆",
        sent = false,
    },
    {
        name = "Deathcomes",
        sent = false,
    },
    {
        name = "宝宝骑神",
        sent = false,
    },
    {
        name = "冰飞",
        sent = false,
    },
    {
        name = "暗夜沧海",
        sent = false,
    },
    {
        name = "糖三勺",
        sent = false,
    },
    {
        name = "风火雷星",
        sent = false,
    },
    {
        name = "撸个串串",
        sent = false,
    },
    {
        name = "朝天子",
        sent = false,
    },
    {
        name = "只会递刀子",
        sent = false,
    },
    {
        name = "脆皮啼",
        sent = false,
    },
    {
        name = "希水",
        sent = false,
    },
    {
        name = "喊王山黄喊得",
        sent = false,
    },
    {
        name = "毛毛猪",
        sent = false,
    },
    {
        name = "流云舞雪",
        sent = false,
    },
    {
        name = "哆啦晓静",
        sent = false,
    },
    {
        name = "雪舞幽兰",
        sent = false,
    },
    {
        name = "燕子的夏天",
        sent = false,
    },
    {
        name = "抓不住",
        sent = false,
    },
    {
        name = "白垩圣骑",
        sent = false,
    },
    {
        name = "抗霸子",
        sent = false,
    },
    {
        name = "非洲的娘娘",
        sent = false,
    },
    {
        name = "幸运的兔脚",
        sent = false,
    },
    {
        name = "Tranzan",
        sent = false,
    },
    {
        name = "弄夜",
        sent = false,
    },
    {
        name = "单刷三中路",
        sent = false,
    },
    {
        name = "小凶器",
        sent = false,
    },
    {
        name = "星夜乱舞",
        sent = false,
    },
    {
        name = "波记",
        sent = false,
    },
    {
        name = "羊过小龍女",
        sent = false,
    },
    {
        name = "百威治百病",
        sent = false,
    },
    {
        name = "Ayanamirei",
        sent = false,
    },
    {
        name = "硬榔头",
        sent = false,
    },
    {
        name = "冰火佩佩",
        sent = false,
    },
    {
        name = "雨玲珑",
        sent = false,
    },
    {
        name = "佘大宝",
        sent = false,
    },
    {
        name = "飛騰",
        sent = false,
    },

}

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
    local subject = "[正式邮件]周五小克工资"
    local body = "小克工资：15000 / 38 = 394。没收到工资请找 ‘非洲的娘娘’。"
    -- local unit = 1; -- 1铜
    local unit = 100 * 100; -- 1g
    local salary = 394 * unit;
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
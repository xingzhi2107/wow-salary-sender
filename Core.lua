RaidManager = LibStub('AceAddon-3.0'):NewAddon('RaidManager', 'AceConsole-3.0')
local AceGUI = LibStub("AceGUI-3.0")
local AceEvent = LibStub('AceEvent-3.0')
addonName = ...

local SCALE_LENGTH = 10

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
    RaidManager:Print('测试global配置：' .. (RaidManager.db.global.test or ''))
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
    {
        name = '凍顶乌龙',
        salaries = {
            {
                note = '基本工资(1/4)',
                value = 178,
            },
        },
    },
    {
        name = '毛毛猪',
        salaries = {
            {
                note = '基本工资(3/4)',
                value = 534,
            },
        },
    },
    {
        name = '忙着可爱',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '喜宝丶',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '飛騰',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '糖三勺',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '一曲一生缘',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '暖阳与猫',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '唐萍淑',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '指上青芜',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '佘宝宝',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '吖米娃娃',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '沁园',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '黎明挽歌',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '五月未央',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '黑色记忆',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '朱缳',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '冰飞',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = '雪漫天',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
    {
        name = 'Roseonly',
        salaries = {
            {
                note = '基本工资(4/4)',
                value = 712,
            },
        },
    },
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
    local subject = "11月21日，毒蛇神殿[测试]"
    local body = "基本工资：(17800) / 25 = 712. 插件测试邮件，只有7银12铜。" .. note
    local unit = 100 * 100; -- 1g
    unit = 1;
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
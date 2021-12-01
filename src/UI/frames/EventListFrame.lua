local _, Addon = ...
local Libs = Addon.Libs
local AceGUI = Libs.AceGUI
local Frames = Addon.UI.Frames
local Com = Addon.UI.Components
local Utils = Addon.Utils

function Frames:EventListFrame(props)
    local eventInfos = props.eventInfos
    local onImportSuccess = props.onImportSuccess
    local onTestModeChanged = props.onTestModeChanged
    local onClearTestData = props.onClearTestData
    local onClickItem = props.onClickItem
    local currEventInfo = props.currEvent

    local frame = AceGUI:Create("Frame")
    frame:SetTitle('活动列表')
    frame:SetCallback('OnClose', function (widget) AceGUI:Release(widget) end)
    frame:SetLayout('Flow')
    frame:SetWidth(960)
    frame:SetHeight(600)
    frame:EnableResize(false)

    -- 画UI
    -- 左边一个scroll flow，显示所有活动
    -- 右边的scroll flow显示活动的信息
    local eventListContainer = AceGUI:Create('InlineGroup')
    eventListContainer:SetWidth(300)
    eventListContainer:SetHeight(520)
    eventListContainer:SetLayout('Fill')
    frame:AddChild(eventListContainer)
    local scroll = AceGUI:Create('ScrollFrame')
    scroll:SetLayout('List')
    eventListContainer:AddChild(scroll)

    local testModeCheckbox = AceGUI:Create('CheckBox')
    testModeCheckbox:SetLabel('测试模式')
    testModeCheckbox:SetType('checkbox')
    testModeCheckbox:SetValue(Addon.IS_TEST_MODE)
    testModeCheckbox:SetCallback('OnValueChanged', function()
        local isTestMode = testModeCheckbox:GetValue();
        Addon.IS_TEST_MODE = isTestMode;
        onTestModeChanged(isTestMode);
    end)
    scroll:AddChild(testModeCheckbox)

    if Addon.IS_TEST_MODE then
        local resetTestDataBtn = AceGUI:Create('Button')
        resetTestDataBtn:SetText('清除测试数据')
        resetTestDataBtn:SetCallback('OnClick', function()
            onClearTestData()
        end)
        scroll:AddChild(resetTestDataBtn)
    end

    local importBtn = AceGUI:Create('Button')
    importBtn:SetText('导入')
    importBtn:SetCallback('OnClick', function()
        Frames:ImportEventFrame({
            onImportSuccess = onImportSuccess,
        })
    end)
    scroll:AddChild(importBtn)

    local eventDetailContainer = nil
    Utils:arrForEach(eventInfos, function(eventInfo)
        local eventItem = Com:EventListItem(eventInfo, onClickItem)
        scroll:AddChild(eventItem)
    end)

    eventDetailContainer = Com:EventDetailContainer(currEventInfo)
    if eventDetailContainer then
        frame:AddChild(eventDetailContainer)
    end

    return frame
end
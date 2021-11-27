local _, Addon = ...
local Libs = Addon.Libs
local AceGUI = Libs.AceGUI
local Frames = Addon.UI.Frames
local Com = Addon.UI.Components
local Utils = Addon.Utils

function Frames:EventListFrame(props)
    local eventInfos = props.eventInfos
    local onClickImport = props.onClickImport

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

    local importBtn = AceGUI:Create('Button')
    importBtn:SetText('导入')
    importBtn:SetCallback('OnClick', function()
        onClickImport(frame)
    end)
    scroll:AddChild(importBtn)

    Utils:arrForEach(eventInfos, function(eventInfo)
        local eventItem = Com:EventListItem(eventInfo)
        scroll:AddChild(eventItem)
    end)

    local eventDetailContainer = AceGUI:Create('InlineGroup')
    eventDetailContainer:SetWidth(620)
    eventDetailContainer:SetHeight(520)
    eventDetailContainer:SetLayout('Fill')
    frame:AddChild(eventDetailContainer)
    local detailScroll = AceGUI:Create('ScrollFrame')
    detailScroll:SetLayout('List')
    eventDetailContainer:AddChild(detailScroll)
    for i = 50,1,-1
    do
        local btn = AceGUI:Create('Button')
        btn:SetText('迷雾卡夫卡 175G')
        detailScroll:AddChild(btn)
    end

    return frame
end
local _, Addon = ...
local Libs = Addon.Libs
local AceGUI = Libs.AceGUI
local Components = Addon.UI.Components

function Components:EventListItem(eventInfo, onClick)
    local title = eventInfo.title
    local id = eventInfo.id
    local eventTime = eventInfo.eventTime
    local eventDate = date('%Y-%m-%d', eventTime)
    local btnText = string.format('%s %s', eventDate, title)
    local btn = AceGUI:Create('Button')
    btn:SetText(btnText)
    btn:SetWidth(250)
    btn:SetCallback('OnClick', function()
        if onClick then
            onClick(eventInfo)
        end
    end)

    return btn
end

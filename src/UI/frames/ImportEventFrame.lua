local _, Addon = ...
local Libs = Addon.Libs
local AceGUI = Libs.AceGUI
local Frames = Addon.UI.Frames
local Com = Addon.UI.Components
local Utils = Addon.Utils
local JSON = Addon.JSON

function Frames:ImportEventFrame(props)
    local onImportSuccess = props.onImportSuccess

    local frame = AceGUI:Create("Frame")
    frame:SetTitle('导入活动')
    frame:SetCallback('OnClose', function (widget) AceGUI:Release(widget) end)
    frame:SetLayout('Flow')
    frame:SetWidth(960)
    frame:SetHeight(600)
    frame:EnableResize(false)

    local inputEditbox = AceGUI:Create('MultiLineEditBox')
    inputEditbox:SetNumLines(30)
    inputEditbox:SetWidth(900)
    inputEditbox:SetCallback('OnEnterPressed', function()
        local humanityBase64Content = inputEditbox:GetText()
        local lines = Utils:strSplit(humanityBase64Content, '\n')
        lines = Utils:arrFilter(lines, function(line)
            return not Utils:strStartsWith(line, '--')
        end)
        local base64Content = Utils:strJoin(lines, '')
        local jsonContent = Utils.base64.dec(base64Content)
        local result = JSON.decode(jsonContent)
        onImportSuccess(result);
        frame:Release();
    end)

    frame:AddChild(inputEditbox)

    return frame
end

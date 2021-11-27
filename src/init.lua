local _, Addon = ...

Addon.Utils = {}

Addon.Libs = {
    AceAddon = _G.LibStub('AceAddon-3.0'),
    AceGUI = _G.LibStub('AceGUI-3.0'),
    AceEvent = _G.LibStub('AceEvent-3.0'),
}

Addon.UI = {
    Components = {},
    Frames = {}
}
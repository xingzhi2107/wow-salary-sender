local _, Addon = ...

Addon.Utils = {}

Addon.Libs = {
    AceAddon = _G.LibStub('AceAddon-3.0'),
    AceGUI = _G.LibStub('AceGUI-3.0'),
    AceEvent = _G.LibStub('AceEvent-3.0'),
    AceDB = _G.LibStub('AceDB-3.0'),
}

Addon.DB = {
}

Addon.access = {
}

Addon.UI = {
    Components = {},
    Frames = {}
}

-- Addon.ENV = 'PROD'
Addon.ENV = 'DEV'

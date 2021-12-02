local _, Addon = ...

Addon.Utils = {}
-- json utils
Addon.JSON = nil

Addon.Libs = {
    AceAddon = _G.LibStub('AceAddon-3.0'),
    AceGUI = _G.LibStub('AceGUI-3.0'),
    AceEvent = _G.LibStub('AceEvent-3.0'),
    AceDB = _G.LibStub('AceDB-3.0'),
    AceTimer = _G.LibStub('AceTimer-3.0'),
}

Addon.DB = {
}

Addon.access = {
}

Addon.UI = {
    Components = {},
    Frames = {}
}

Addon.IS_TEST_MODE = false

Addon.EventManager = {}
Addon.Events = {}

Addon.ItemToChar = {}
Addon.type2Items = {}

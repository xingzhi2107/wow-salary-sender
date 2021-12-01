local _, Addon = ...


local DB = Addon.DB
local Libs = Addon.Libs
local AceDB = Libs.AceDB

function DB:initDB()
   local db = AceDB:New("RaidManagerDB")
   DB.db = db;
end


function DB:getTable(tableName)
    tableName = DB:_getKey(tableName)
    local db = DB.db;
    local tbl = db.global[tableName]
    if not tbl then
        db.global[tableName] = {}
        tbl = db.global[tableName]
    end

    return tbl
end

function DB:_getKey(tableName)
    if Addon.IS_TEST_MODE then
        return 'test-' .. tableName
    else
        return 'prod-' .. tableName
    end
end

function DB:resetTestData()
    if not Addon.IS_TEST_MODE then
        return
    end
    local eventsKey = DB:_getKey('events')
    local db = DB.db;
    db.global[eventsKey] = {}
end
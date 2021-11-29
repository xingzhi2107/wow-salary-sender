local _, Addon = ...


local DB = Addon.DB
local Libs = Addon.Libs
local AceDB = Libs.AceDB
local ENV = Addon.ENV

function DB:initDB()
   local db = AceDB:New("RaidManagerDB")
   DB.db = db;
    --local eventsKey = ENV .. '-' .. 'events'
    --db.global[eventsKey] = {}
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
    return ENV .. '-' .. tableName
end

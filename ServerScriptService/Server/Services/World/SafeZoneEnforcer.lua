-- @ScriptType: Script
-- SafeZoneEnforcer: Server script that monitors player positions and sets InSafeZone attribute
-- Location: ServerScriptService/Server/Services/World/SafeZoneEnforcer.lua
-- Sprint 1 - First-Session Survival

local RS = game:GetService("ReplicatedStorage")
local SafeZoneUtils = require(RS.Modules.Custom.SafeZoneUtils)

-- Start monitoring all player positions for SafeZone entry/exit
SafeZoneUtils.StartEnforcement()

print("[SafeZoneEnforcer] Started - PvP disabled in SafeZone areas")

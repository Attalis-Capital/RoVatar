-- @ScriptType: ModuleScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VFXHandler = {}

for _, Module in ipairs(script:GetChildren()) do
	VFXHandler[Module.Name] = require(Module)
end

local remoteEvent = ReplicatedStorage.Events.Remote.CastEffect


function VFXHandler:PlayOnServer(...)
	remoteEvent:FireServer(...)
end

function VFXHandler:PlayOnClient(plr, ...)
	remoteEvent:FireClient(plr, ...)
end



--If Client side
if game:GetService("RunService"):IsClient() then

	function VFXHandler:PlayEffect(plr, typ, ...)
		if VFXHandler[typ] then
			VFXHandler[typ](plr, ...)
		else
			print(typ, "Effect Type not found.")
		end
	end

	remoteEvent.OnClientEvent:Connect(function(typ, ...)
		VFXHandler:PlayEffect(game.Players.LocalPlayer, typ, ...)
	end)
	
else --Else Server side

	function VFXHandler:PlayEffect(plr, typ, ...)
		if VFXHandler[typ] then
			VFXHandler[typ](plr, ...)
		else
			print(typ, "Effect Type not found.")
		end
	end

	local VALID_EFFECTS = {Fist=true, AirKick=true, EarthStomp=true, FireDropKick=true, WaterStance=true, Boomerang=true, MeteoriteSword=true, LevelUp=true}
	local ABILITY_COOLDOWNS = {AirKick=5, EarthStomp=5, FireDropKick=5, WaterStance=5, Boomerang=3}
	local FIST_MIN_GAP = 0.3
	local lastFist = {}

	remoteEvent.OnServerEvent:Connect(function(plr, typ, ...)
		if not VALID_EFFECTS[typ] then return end

		-- Fist rate limiting (M1 spam prevention)
		if typ == "Fist" then
			local now = tick()
			if lastFist[plr.UserId] and (now - lastFist[plr.UserId]) < FIST_MIN_GAP then return end
			lastFist[plr.UserId] = now
		end

		-- Ability cooldowns
		local cd = ABILITY_COOLDOWNS[typ]
		if cd then
			local attr = "CD_" .. typ
			if plr:GetAttribute(attr) then return end
			plr:SetAttribute(attr, true)
			task.delay(cd, function() plr:SetAttribute(attr, nil) end)
		end

		VFXHandler:PlayEffect(plr, typ, ...)
	end)

	-- Clean up Fist rate limit tracking
	game.Players.PlayerRemoving:Connect(function(plr)
		lastFist[plr.UserId] = nil
	end)
end



return VFXHandler
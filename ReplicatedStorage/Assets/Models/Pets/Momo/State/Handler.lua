-- @ScriptType: Script
local Replicator = script.Parent.ReplicateState
local HRP = script.Parent.Parent.PrimaryPart

Replicator.OnServerEvent:Connect(function(plr, State)
	-- Validate that this player owns this pet
	if not script.Parent.Parent.Name:match("^" .. tostring(plr.UserId)) then
		return
	end

	script.Parent.Value = State

	if State == "Show" then
		HRP.Transparency = 0
		HRP.Smoke:Emit(10)
	elseif State == "Hide" then
		HRP.Transparency = 1
		HRP.Smoke:Emit(10)
	end
end)

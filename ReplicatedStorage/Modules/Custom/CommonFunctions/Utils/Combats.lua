-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local CD = require(RS.Modules.Custom.Constants)

return {
	RefreshCombatControls = function(plr :Player, combatStats)

		local combatF = plr:FindFirstChild("CombatStats") or Instance.new("Folder", plr)
		combatF.Name = "CombatStats"

		for name, val in pairs(combatStats) do
			local kk = nil
			if(typeof(val) == "number") then
				kk = "NumberValue"
			elseif(typeof(val) == "string") then
				kk = "StringValue"
			end

			local element = combatF:FindFirstChild(name) or Instance.new(kk, combatF)
			element.Name = name
			element.Value = val
		end

		local StatesF = plr:FindFirstChild("States") or Instance.new("Folder", plr)
		StatesF.Name = "States"

		for Key, State in pairs(CD.StateTypes) do
			local StateS = StatesF:FindFirstChild(State) or Instance.new("StringValue", StatesF)
			StateS.Name = State
		end

		if not plr:FindFirstChild("isBlocking") then
			local value = Instance.new("BoolValue")
			value.Name = "isBlocking"
			value.Parent = plr
		end

		local CombatMechanics = plr:FindFirstChild("CombatMechanics") or Instance.new("Folder", plr) do
			CombatMechanics.Name = "CombatMechanics"

			-- Some Debounces and Combo Used in Fist and Meteorite Sword 
			local Debounce = CombatMechanics:FindFirstChild("Debounce") or Instance.new("BoolValue", CombatMechanics) do
				Debounce.Name = "Debounce"
			end

			local Combo = CombatMechanics:FindFirstChild("Combo") or Instance.new("NumberValue", CombatMechanics) do
				if Combo.Name ~= "Combo" then
					Combo.Name = "Combo"
					Combo.Value = 1
				end
			end

			local doingCombo = CombatMechanics:FindFirstChild("doingCombo") or Instance.new("NumberValue", CombatMechanics) do 
				doingCombo.Name = "doingCombo"
			end

			local canHit = CombatMechanics:FindFirstChild("canHit") or Instance.new("BoolValue", CombatMechanics) do
				if canHit.Name ~= "canHit" then
					canHit.Name = "canHit"
					canHit.Value = true
				end
			end
		end

		local Progression = plr:FindFirstChild("Progression") or Instance.new("Folder", plr) do
			Progression.Name = "Progression"

			-----[READ & WRITE]
			local EXP = Progression:FindFirstChild("EXP") or Instance.new("NumberValue", Progression) do
				EXP.Name = "EXP"
			end

			-----[READ ONLY]
			local LEVEL = Progression:FindFirstChild("LEVEL") or Instance.new("NumberValue", Progression) do
				LEVEL.Name = "LEVEL"
			end

		end

	end,
}

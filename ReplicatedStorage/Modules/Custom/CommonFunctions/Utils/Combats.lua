-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local CD = require(RS.Modules.Custom.Constants)

return {
	RefreshCombatControls = function(plr :Player, combatStats)

		local combatF = plr:FindFirstChild("CombatStats") or Instance.new("Folder", plr)
		combatF.Name = "CombatStats"

		-- Whitelist of allowed stat names with expected types and constraints
		local ALLOWED_STATS = {
			Strength = { type = "number", min = 0, max = 100, maxDelta = 30 },
			Stamina  = { type = "number", min = 0, max = 100, maxDelta = 30 },
			EXP      = { type = "number", min = 0, onlyIncrease = true },
		}

		for name, val in pairs(combatStats) do
			-- Reject stat names not in the whitelist
			local rule = ALLOWED_STATS[name]
			if not rule then
				warn("[CombatStats] Rejected unknown stat '" .. tostring(name) .. "' from player " .. plr.Name)
				continue
			end

			-- Validate that the value type matches what is expected
			if typeof(val) ~= rule.type then
				warn("[CombatStats] Rejected stat '" .. name .. "': expected " .. rule.type .. ", got " .. typeof(val) .. " from player " .. plr.Name)
				continue
			end

			-- For numeric values, apply constraints
			if rule.type == "number" then
				-- Clamp to min/max range if defined
				if rule.min then
					val = math.max(rule.min, val)
				end
				if rule.max then
					val = math.min(rule.max, val)
				end

				local existing = combatF:FindFirstChild(name)

				-- Max delta check: reject if change exceeds allowed delta per update
				if rule.maxDelta and existing then
					local delta = math.abs(val - existing.Value)
					if delta > rule.maxDelta then
						warn("[CombatStats] Rejected stat '" .. name .. "': delta " .. delta .. " exceeds max " .. rule.maxDelta .. " from player " .. plr.Name)
						continue
					end
				end

				-- EXP should only increase, never decrease from client
				if rule.onlyIncrease and existing and val < existing.Value then
					warn("[CombatStats] Rejected stat '" .. name .. "': value cannot decrease from client, player " .. plr.Name)
					continue
				end
			end

			local kk = nil
			if typeof(val) == "number" then
				kk = "NumberValue"
			elseif typeof(val) == "string" then
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

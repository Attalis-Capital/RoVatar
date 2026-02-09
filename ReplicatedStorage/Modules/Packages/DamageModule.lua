-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local FXFolder = RS:WaitForChild("FX")
local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")

local Modules = RS:WaitForChild("Modules")
local Remotes = RS:WaitForChild("Remotes")

local Replicate = Remotes:WaitForChild("Replicate")
local Misc = require(Modules:WaitForChild("Misc"))

local module = {}

-- FIX: Block PvP damage in safe zones (Sprint 1)
local function isPvPBlocked(attackerPlayer: Player, targetHumanoid: Humanoid): boolean
	local targetChar = targetHumanoid.Parent
	if not targetChar then return false end

	-- Allow PvE always
	local targetPlayer = Players:GetPlayerFromCharacter(targetChar)
	if not targetPlayer then
		return false -- NPC target
	end

	-- Block if either player is in safe zone
	if attackerPlayer:GetAttribute("InSafeZone") then
		return true
	end
	if targetPlayer:GetAttribute("InSafeZone") then
		return true
	end

	-- Block if target has spawn protection ForceField
	if targetChar:FindFirstChildOfClass("ForceField") then
		return true
	end

	return false
end

module.OnHit = function(player, humanoid, Damage, isBlockBreak)
	if not player then return end
	local char = player.Character
	if not char then return end
	if char:FindFirstChild("ForceField") then return end

	-- FIX: Check SafeZone PvP protection
	if isPvPBlocked(player, humanoid) then
		return
	end
	
		--and not char:FindFirstChild("Disabled")
	if humanoid and not humanoid.Parent:FindFirstChild("Immune") and not CS:HasTag(humanoid.Parent, "PerfectBlock") then

		local hitP = FXFolder:FindFirstChild("HitPart")
		local hitFX = hitP.PunchHitFX:Clone()
		local blockFX = hitP.PunchBlockFX:Clone()
		hitFX.Parent = humanoid.Parent.HumanoidRootPart
		blockFX.Parent = humanoid.Parent.HumanoidRootPart

		local isEnemyBlocking

		local isPlayer = game.Players:FindFirstChild(humanoid.Parent.Name)

		if isPlayer then
			isEnemyBlocking = isPlayer:WaitForChild("isBlocking")
		else
			isEnemyBlocking = humanoid.Parent:WaitForChild("isBlocking")
			humanoid.Parent.Target.Value = player.Name
		end

		if isEnemyBlocking then
			if isEnemyBlocking.Value then
				if not humanoid.Parent:FindFirstChild("Blade", true) then
					local blockbar = humanoid.Parent:FindFirstChild("BlockBar")
					if blockbar then
						if not isBlockBreak then
							blockbar.Value -= (Damage * 0.75)
						else
							blockbar.Value = 0

							humanoid:TakeDamage(Damage)
							Replicate:FireAllClients("DamageIndicator", humanoid.Parent, Damage, "Normal")

							local isIdle = humanoid.Parent:FindFirstChild("Idle")
							if isIdle then
								if isIdle.Value then
									isIdle.Value = false
								end
							end

							local Killers = humanoid.Parent:FindFirstChild("Killers")
							if Killers then
								local lPlr = Killers:FindFirstChild(player.Name)
								if not lPlr then
									local lPlrDMG = Instance.new("NumberValue")
									lPlrDMG.Name = player.Name
									lPlrDMG.Value = Damage
									lPlrDMG.Parent = Killers
								else
									lPlr.Value += Damage
								end
							else
								local KillersFolder = Instance.new("Folder")
								KillersFolder.Name = "Killers"
								KillersFolder.Parent = humanoid.Parent

								local lPlrDMG = Instance.new("NumberValue")
								lPlrDMG.Name = player.Name
								lPlrDMG.Value = Damage
								lPlrDMG.Parent = KillersFolder
							end
						end
					else
						local blockbar = humanoid.Parent:FindFirstChild("BlockBar")
						if blockbar then
							if not isBlockBreak then
								blockbar.Value -= (Damage * 0.5)
							else
								blockbar.Value = 0

								humanoid:TakeDamage(Damage)
								Replicate:FireAllClients("DamageIndicator", humanoid.Parent, Damage, "Normal")

								local isIdle = humanoid.Parent:FindFirstChild("Idle")
								if isIdle then
									if isIdle.Value then
										isIdle.Value = false
									end
								end

								local Killers = humanoid.Parent:FindFirstChild("Killers")
								if Killers then
									local lPlr = Killers:FindFirstChild(player.Name)
									if not lPlr then
										local lPlrDMG = Instance.new("NumberValue")
										lPlrDMG.Name = player.Name
										lPlrDMG.Value = Damage
										lPlrDMG.Parent = Killers
									else
										lPlr.Value += Damage
									end
								else
									local KillersFolder = Instance.new("Folder")
									KillersFolder.Name = "Killers"
									KillersFolder.Parent = humanoid.Parent

									local lPlrDMG = Instance.new("NumberValue")
									lPlrDMG.Name = player.Name
									lPlrDMG.Value = Damage
									lPlrDMG.Parent = KillersFolder
								end
							end
						end
					end

					local isIdle = humanoid.Parent:FindFirstChild("Idle")
					if isIdle then
						if isIdle.Value then
							isIdle.Value = false
						end
					end
				else
					humanoid:TakeDamage(Damage)
					Replicate:FireAllClients("DamageIndicator", humanoid.Parent, Damage, "Normal")

					local isIdle = humanoid.Parent:FindFirstChild("Idle")
					if isIdle then
						if isIdle.Value then
							isIdle.Value = false
						end
					end

					local Killers = humanoid.Parent:FindFirstChild("Killers")
					if Killers then
						local lPlr = Killers:FindFirstChild(player.Name)
						if not lPlr then
							local lPlrDMG = Instance.new("NumberValue")
							lPlrDMG.Name = player.Name
							lPlrDMG.Value = Damage
							lPlrDMG.Parent = Killers
						else
							lPlr.Value += Damage
						end
					else
						local KillersFolder = Instance.new("Folder")
						KillersFolder.Name = "Killers"
						KillersFolder.Parent = humanoid.Parent

						local lPlrDMG = Instance.new("NumberValue")
						lPlrDMG.Name = player.Name
						lPlrDMG.Value = Damage
						lPlrDMG.Parent = KillersFolder
					end
				end
			end
		end

		game.Debris:AddItem(hitFX, 2)
		game.Debris:AddItem(blockFX, 2)
	elseif humanoid and CS:HasTag(humanoid.Parent, "PerfectBlock") then
		local pbAnim = humanoid:LoadAnimation(script.Animations.PerfectBlock)
		pbAnim:Play()
		Misc.InsertDisabled(char, 3)

		CS:RemoveTag(humanoid.Parent, "PerfectBlock")

		local sfx1 = RS.Sounds.PerfectBlock1:Clone()
		local sfx2 = RS.Sounds.PerfectBlock2:Clone()

		sfx1.Parent = char.HumanoidRootPart
		sfx2.Parent = char.HumanoidRootPart

		sfx1:Play()
		sfx2:Play()

		local pbFX = RS.FX.Block.Perfect:Clone()
		pbFX.Parent = char.HumanoidRootPart

		pbFX.Block:Emit(2)
		pbFX.Glow:Emit(1)
		pbFX.Lens:Emit(5)
		pbFX.Ring:Emit(5)
		pbFX.Wave:Emit(5)  

		game.Debris:AddItem(sfx1, 1)
		game.Debris:AddItem(sfx2, 1)

		task.delay(3, function()
			pbAnim:Stop()
			if pbFX then
				pbFX:Destroy()
			end
		end)
	end
end

return module

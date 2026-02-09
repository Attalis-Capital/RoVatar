-- @ScriptType: ModuleScript

local Tween = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local Players = game:GetService("Players")

----- Script refs
local Modules = RS.Modules
local zonePlus = require(Modules.Packages.Zone)
local Misc = require(Modules.Packages.Misc)
local Costs = require(script.Parent.Parent.Costs)
local Constants = require(script.Parent.Parent.Constants)
local SFXHandler = require(script.Parent.Parent.SFXHandler)

----- Obj refs
local Hitboxes = RS.Hitboxes
local Replicate = RS.Remotes.Replicate

----- Values
local MeteoriteSwordStamina = Costs.MeteoriteSwordStamina
local MeteoriteSwordXP = Costs.MeteoriteSwordXP

----- Variables
local Air = false

local M1ImmunityTag = "Immunity"
local AirImmunityTag = "AirDown"

return function(Player, Action, isHoldingSpace)

	local Character = Player.Character
	local Humanoid = Character.Humanoid	
	local HRP = Character.HumanoidRootPart

	local pStrength = Player.CombatStats.Strength.Value
	local isBlocking = Player:WaitForChild("isBlocking")

	local M1Damage = 7.1 * (1 + (pStrength * 0.015))
	local M1StunDuration = 1

	local Disabled = false --Character:FindFirstChild("Disabled")

	local M1Debounce = Player.CombatMechanics.Debounce
	local Combo = Player.CombatMechanics.Combo
	local doingCombo = Player.CombatMechanics.doingCombo
	local canHit = Player.CombatMechanics.canHit

	if Action == "Attack" and Humanoid.Health > 0 then
		if not M1Debounce.Value and not isBlocking.Value and not Disabled then
			M1Debounce.Value = true
			local hit = {}

			Player.CombatStats.Stamina.Value -= MeteoriteSwordStamina

			local Animations = {
				[1] = Humanoid:LoadAnimation(script.Animations.A1),
				[2] = Humanoid:LoadAnimation(script.Animations.A2),
				[3] = Humanoid:LoadAnimation(script.Animations.A3),
				[4] = Humanoid:LoadAnimation(script.Animations.A4),
				[5] = Humanoid:LoadAnimation(script.Animations.A5),

			}


			local function createHitbox()
				coroutine.wrap(function()
					local Direction = 0
					local Length = 0.2
					local DashSpeed = 10

					local BV = Instance.new("BodyVelocity")
					BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), (Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(Direction), 0)).lookVector * DashSpeed
					BV.Parent = HRP
					game.Debris:AddItem(BV, Length)
				end)()

				local hitboxTemp = Hitboxes.Combat.M1:Clone()
				hitboxTemp.CFrame = HRP.CFrame
				hitboxTemp.Parent = HRP

				local weld = Instance.new("Weld")
				weld.Part0 = HRP
				weld.Part1 = hitboxTemp
				weld.C1 = require(hitboxTemp.weldCF)
				weld.Parent = hitboxTemp

				local hitboxZone = zonePlus.new(hitboxTemp)
				hitboxZone:setAccuracy("Precise")

				for i, v in pairs(hitboxZone:getParts()) do
					if v.Parent ~= Character then
						if v.Parent:FindFirstChild("Humanoid") and not hit[v.Parent.Name] then
							
							if not v.Parent:FindFirstChild("Immune") 
								--and not Character:FindFirstChild("Disabled") 
								and not Character:FindFirstChild("Immune") 
								and not CS:HasTag(v.Parent, M1ImmunityTag) 
								and not CS:HasTag(v.Parent, AirImmunityTag) 
								and (v.Parent:HasTag(Constants.Tags.PlayerAvatar)
									or v.Parent:HasTag(Constants.Tags.NPCAI))
							then
								if canHit.Value then
									canHit.Value = false
									CS:AddTag(v.Parent, M1ImmunityTag)
									table.insert(hit, v.Parent.Name)
									local isPlayer = Players:FindFirstChild(v.Parent.Name)
									local isBlocking
									spawn(function()
										if v.Parent:FindFirstChild("IsAttacking") then 
											v.Parent.IsAttacking.Value = true
											wait(1)
											v.Parent.IsAttacking.Value = false
										end

									end)

									if isPlayer then
										isBlocking = isPlayer.isBlocking
									else
										isBlocking = v.Parent.isBlocking
										v.Parent.Target.Value = Player.Name
										v.Parent.Idle.Value = false
									end

									if not CS:HasTag(v.Parent, "Perfect Block") then
										if isBlocking.Value and HRP.CFrame.lookVector:Dot(v.Parent.HumanoidRootPart.CFrame.lookVector) < 0.7 then

											local blockBar = v.Parent:FindFirstChild("BlockBar")
											if blockBar then
												Replicate:FireAllClients("Combat", "HitFX", v.Parent.HumanoidRootPart, "Block Hit")
												blockBar.Value -= M1Damage

												coroutine.wrap(function()
													local BV = Instance.new("BodyVelocity")
													BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Character.HumanoidRootPart.CFrame.lookVector * 10
													BV.Parent = v.Parent.HumanoidRootPart
													game.Debris:AddItem(BV, 0.16)
												end)()
											end

										else
											local eHum = v.Parent.Humanoid

											local Exp = Player.Progression:FindFirstChild("EXP")
											if Exp then
												Exp.Value += MeteoriteSwordXP
											end

											-- SafeZone: block PvP if either player is in safe zone
											local blockPvP = isPlayer and (Character:GetAttribute("InSafeZone") or v.Parent:GetAttribute("InSafeZone"))
											if blockPvP then return end
											eHum:TakeDamage(M1Damage)

											local LastDamage = eHum.Parent:FindFirstChild("DamageBy") or Instance.new('ObjectValue', eHum.Parent)
											LastDamage.Name = "DamageBy"
											LastDamage.Value = Player.Character
											LastDamage:SetAttribute("Weapon", Constants.Weapons.MeteoriteSword)

											Replicate:FireAllClients("Combat", "HitFX", v.Parent.HumanoidRootPart, "Blade Hit")
											Replicate:FireClient(Player, "CamShake", HRP.Position, 3, 100)

											if isPlayer then
												Replicate:FireClient(isPlayer, "CamShake", v.Parent.HumanoidRootPart.Position, 3, 100)
											else
												local killers = v.Parent:FindFirstChild("Killers")
												if killers then
													local pVal = killers:FindFirstChild(Player.Name)
													if pVal then
														pVal.Value += M1Damage
													else
														pVal = Instance.new("NumberValue")
														pVal.Name =  Player.Name
														pVal.Value = M1Damage
														pVal.Parent = killers
													end
												else
													killers = Instance.new("Folder")
													killers.Name = "Killers"
													killers.Parent = v.Parent

													local pVal = Instance.new("NumberValue")
													pVal.Name =  Player.Name
													pVal.Value = M1Damage
													pVal.Parent = killers
												end
											end

											if doingCombo.Value < 4 then
												coroutine.wrap(function()
													local BV = Instance.new("BodyVelocity")
													BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Character.HumanoidRootPart.CFrame.lookVector * 20
													BV.Parent = eHum.Parent.HumanoidRootPart
													game.Debris:AddItem(BV, 0.1)
												end)()

												Misc.InsertDisabled(v.Parent, M1StunDuration)

											elseif doingCombo.Value == 4 then
												if not isHoldingSpace then
													coroutine.wrap(function()
														local BV = Instance.new("BodyVelocity")
														BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Character.HumanoidRootPart.CFrame.lookVector * 20
														BV.Parent = eHum.Parent.HumanoidRootPart
														game.Debris:AddItem(BV, 0.1)
													end)()

													Misc.InsertDisabled(v.Parent, M1StunDuration)

												else
													coroutine.wrap(function()
														local BV = Instance.new("BodyVelocity")
														BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Character.HumanoidRootPart.CFrame.lookVector * 20
														BV.Parent = eHum.Parent.HumanoidRootPart
														game.Debris:AddItem(BV, 0.1)
													end)()

													Misc.InsertDisabled(v.Parent, M1StunDuration)

												end
											elseif doingCombo.Value == 5 then
												if not Air then
													Misc.Ragdoll(v.Parent, M1StunDuration + 0.5)
													coroutine.wrap(function()
														local BV = Instance.new("BodyVelocity")
														BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Character.HumanoidRootPart.CFrame.lookVector * 40
														BV.Parent = eHum.Parent.HumanoidRootPart
														game.Debris:AddItem(BV, 0.15)
													end)()

													CS:AddTag(v.Parent, AirImmunityTag)

													task.delay(2.3, function()
														CS:RemoveTag(v.Parent, AirImmunityTag)
													end)
												else
													Misc.Ragdoll(v.Parent, M1StunDuration + 0.5)
													coroutine.wrap(function()
														local BV = Instance.new("BodyVelocity")
														BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Character.HumanoidRootPart.CFrame.lookVector * 40
														BV.Parent = eHum.Parent.HumanoidRootPart
														game.Debris:AddItem(BV, 0.15)
													end)()

													CS:AddTag(v.Parent, AirImmunityTag)

													task.delay(2.3, function()
														CS:RemoveTag(v.Parent, AirImmunityTag)
													end)



												end
											end
										end
									else


									end


									task.delay(0.2, function()
										canHit.Value = true
										CS:RemoveTag(v.Parent, M1ImmunityTag)
									end)
								end

							end
						end
					end
				end

				game.Debris:AddItem(hitboxTemp, .3)

			end

			if Combo.Value == 1 then
				Combo.Value = 2
				doingCombo.Value = 1
				Animations[doingCombo.Value]:Play(.05, 0.8, 1.4)

				game.Debris:AddItem(SFXHandler:PlayAlong(Constants.SFXs.Sword_Swing, Character), 3)

				Animations[doingCombo.Value]:GetMarkerReachedSignal("Hit"):Once(function()

					createHitbox()

				end)

				Animations[doingCombo.Value]:GetMarkerReachedSignal("DBReset"):Once(function()
					M1Debounce.Value = false
				end)

				task.delay(1.5, function()
					if Combo.Value == 2 then
						Combo.Value = 1
						doingCombo.Value = 0
					end
				end)
			elseif Combo.Value == 2 then
				Combo.Value = 3

				game.Debris:AddItem(SFXHandler:PlayAlong(Constants.SFXs.Sword_Swing, Character), 3)

				doingCombo.Value = 2
				Animations[doingCombo.Value]:Play(.05, 0.8, 1.4)

				Animations[doingCombo.Value]:GetMarkerReachedSignal("Hit"):Once(function()

					createHitbox()

				end)

				Animations[doingCombo.Value]:GetMarkerReachedSignal("DBReset"):Once(function()
					M1Debounce.Value = false
				end)

				task.delay(1.5, function()
					if Combo.Value == 3 then
						Combo.Value = 1
						doingCombo.Value = 0
					end
				end)
			elseif Combo.Value == 3 then
				game.Debris:AddItem(SFXHandler:PlayAlong(Constants.SFXs.Sword_Swing, Character), 3)

				Combo.Value = 4
				doingCombo.Value = 3
				Animations[doingCombo.Value]:Play(.05, 0.8, 1.4)

				Animations[doingCombo.Value]:GetMarkerReachedSignal("Hit"):Once(function()

					createHitbox()

				end)

				Animations[doingCombo.Value]:GetMarkerReachedSignal("DBReset"):Once(function()
					M1Debounce.Value = false
				end)

				task.delay(1.5, function()
					if Combo.Value == 4 then
						Combo.Value = 1
						doingCombo.Value = 0
					end
				end)
			elseif Combo.Value == 4 then
				Combo.Value = 5
				doingCombo.Value = 4

				game.Debris:AddItem(SFXHandler:PlayAlong(Constants.SFXs.Sword_Swing, Character), 3)
				Animations[doingCombo.Value]:Play(.05, 0.8, 1.4)

				Animations[doingCombo.Value]:GetMarkerReachedSignal("Hit"):Once(function()

					createHitbox()

				end)

				Animations[doingCombo.Value]:GetMarkerReachedSignal("DBReset"):Once(function()
					M1Debounce.Value = false
				end)



				task.delay(1.5, function()
					if Combo.Value == 5 then
						Combo.Value = 1
						doingCombo.Value = 0
					end
				end)
			elseif Combo.Value == 5 then
				Combo.Value = 1
				doingCombo.Value = 5

				game.Debris:AddItem(SFXHandler:PlayAlong(Constants.SFXs.Sword_Swing, Character), 3)

				Animations[doingCombo.Value]:Play(.05, 0.8, 1.4)

				Animations[doingCombo.Value]:GetMarkerReachedSignal("Hit"):Once(function()

					createHitbox()

				end)

				Animations[doingCombo.Value]:GetMarkerReachedSignal("End"):Once(function()
					task.delay(1.2, function()
						Combo.Value = 1
						doingCombo.Value = 0
						M1Debounce.Value = false
					end)
				end)
			end
		end

	elseif Action == "Block" and Humanoid.Health > 0 then
		if not M1Debounce.Value and not Disabled then
			isBlocking.Value = true
		end

	elseif Action == "Unblock" then
		isBlocking.Value = false
	end

end
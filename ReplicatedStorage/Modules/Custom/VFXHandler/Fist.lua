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
local FistStamina = Costs.FistStamina
local FistXP = Costs.FistXP

----- Variables
local Air = false

local M1ImmunityTag = "Immunity"
local AirImmunityTag = "AirDown"


return function(plr :Player, action, isHoldingSpace)
	--print("play fist:",action)
	local Char = plr.Character
	local Humanoid = Char.Humanoid	
	local HRP = Char.HumanoidRootPart

	local pStrength = plr.CombatStats.Strength.Value
	local isBlocking = plr:WaitForChild("isBlocking")

	local M1Damage = 7.1 * (1 + (pStrength * 0.015))
	local M1StunDuration = 1

	local Disabled = false -- Char:FindFirstChild("Disabled")
	
	local M1Debounce = plr.CombatMechanics.Debounce
	local Combo = plr.CombatMechanics.Combo
	local doingCombo = plr.CombatMechanics.doingCombo
	local canHit = plr.CombatMechanics.canHit
	
	if action == "Attack" and Humanoid.Health > 0 then
		
		if not M1Debounce.Value and not isBlocking.Value and not Disabled then

			plr.CombatStats.Stamina.Value -= FistStamina
			
			local hit = {}
			M1Debounce.Value = true

			local Animations = {
				[1] = Humanoid.Animator:LoadAnimation(script.Animations.Fist.A1),
				[2] = Humanoid.Animator:LoadAnimation(script.Animations.Fist.A2),
				[3] = Humanoid.Animator:LoadAnimation(script.Animations.Fist.A3),
				[4] = Humanoid.Animator:LoadAnimation(script.Animations.Fist.A4),
				[5] = Humanoid.Animator:LoadAnimation(script.Animations.Fist.A5),
				[6] = Humanoid.Animator:LoadAnimation(script.Animations.Fist.A6),
			}

			local function createHitbox()
				coroutine.wrap(function()
					local Direction = 0
					local Length = 0.2
					local DashSpeed = 10

					local BV = Instance.new("BodyVelocity")
					BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), (Char.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(Direction), 0)).lookVector * DashSpeed
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
					if v.Parent ~= Char then
						if v.Parent:FindFirstChild("Humanoid") and not hit[v.Parent.Name] then
							if not v.Parent:FindFirstChild("Immune") 
								--and not Char:FindFirstChild("Disabled") 
								and not Char:FindFirstChild("Immune") 
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
										local IsAttacking = v.Parent:FindFirstChild("IsAttacking")
										if IsAttacking then 
											IsAttacking.Value = true
											wait(1)
											IsAttacking.Value = false
										end
									end)

									if isPlayer then
										isBlocking = isPlayer.isBlocking
									else
										isBlocking = v.Parent.isBlocking
										v.Parent.Target.Value = plr.Name
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
													BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Char.HumanoidRootPart.CFrame.lookVector * 10
													BV.Parent = v.Parent.HumanoidRootPart
													game.Debris:AddItem(BV, 0.16)
												end)()
											end

										elseif v.Parent.Humanoid.Health > 0 then
											local eHum = v.Parent.Humanoid

											local Exp = plr.Progression:FindFirstChild("EXP")
											if Exp then
												Exp.Value += FistXP
											end
											eHum:TakeDamage(M1Damage)

											local LastDamage = eHum.Parent:FindFirstChild("DamageBy") or Instance.new('ObjectValue', eHum.Parent)
											LastDamage.Name = "DamageBy"
											LastDamage.Value = plr.Character
											LastDamage:SetAttribute("Weapon", Constants.Weapons.Fist)

											Replicate:FireAllClients("Combat", "HitFX", v.Parent.HumanoidRootPart, "Basic Hit")
											Replicate:FireClient(plr, "CamShake", HRP.Position, 3, 100)

											if isPlayer then
												Replicate:FireClient(isPlayer, "CamShake", v.Parent.HumanoidRootPart.Position, 3, 100)
											else
												local killers = v.Parent:FindFirstChild("Killers")
												if killers then
													local pVal = killers:FindFirstChild(plr.Name)
													if pVal then
														pVal.Value += M1Damage
													else
														pVal = Instance.new("NumberValue")
														pVal.Name =  plr.Name
														pVal.Value = M1Damage
														pVal.Parent = killers
													end
												else
													killers = Instance.new("Folder")
													killers.Name = "Killers"
													killers.Parent = v.Parent

													local pVal = Instance.new("NumberValue")
													pVal.Name =  plr.Name
													pVal.Value = M1Damage
													pVal.Parent = killers
												end
											end

											if doingCombo.Value < 5 then
												coroutine.wrap(function()
													local BV = Instance.new("BodyVelocity")
													BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Char.HumanoidRootPart.CFrame.lookVector * 20
													BV.Parent = eHum.Parent.HumanoidRootPart
													game.Debris:AddItem(BV, 0.1)
												end)()

												Misc.InsertDisabled(v.Parent, M1StunDuration)

											elseif doingCombo.Value == 5 then
												if not isHoldingSpace then
													coroutine.wrap(function()
														local BV = Instance.new("BodyVelocity")
														BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Char.HumanoidRootPart.CFrame.lookVector * 20
														BV.Parent = eHum.Parent.HumanoidRootPart
														game.Debris:AddItem(BV, 0.1)
													end)()

													Misc.InsertDisabled(v.Parent, M1StunDuration)

												else
													coroutine.wrap(function()
														local BV = Instance.new("BodyVelocity")
														BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Char.HumanoidRootPart.CFrame.lookVector * 20
														BV.Parent = eHum.Parent.HumanoidRootPart
														game.Debris:AddItem(BV, 0.1)
													end)()

													Misc.InsertDisabled(v.Parent, M1StunDuration)

												end
											elseif doingCombo.Value == 6 then
												if not Air then
													Misc.Ragdoll(v.Parent, M1StunDuration + 0.5)
													coroutine.wrap(function()
														local BV = Instance.new("BodyVelocity")
														BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Char.HumanoidRootPart.CFrame.lookVector * 40
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
														BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Char.HumanoidRootPart.CFrame.lookVector * 40
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

				task.delay(1, function()
					if Combo.Value == 2 then
						Combo.Value = 1
						doingCombo.Value = 0
					end
				end)
			elseif Combo.Value == 2 then
				Combo.Value = 3
				doingCombo.Value = 2

				task.delay(1, function()
					if Combo.Value == 3 then
						Combo.Value = 1
						doingCombo.Value = 0
					end
				end)

			elseif Combo.Value == 3 then
				Combo.Value = 4
				doingCombo.Value = 3

				task.delay(1, function()
					if Combo.Value == 4 then
						Combo.Value = 1
						doingCombo.Value = 0
					end
				end)
			elseif Combo.Value == 4 then
				Combo.Value = 5
				doingCombo.Value = 4

				task.delay(1, function()
					if Combo.Value == 5 then
						Combo.Value = 1
						doingCombo.Value = 0
					end
				end)
			elseif Combo.Value == 5 then
				Combo.Value = 6
				doingCombo.Value = 5

				task.delay(1, function()
					if Combo.Value == 5 then
						Combo.Value = 1
						doingCombo.Value = 0
					end
				end)

			elseif Combo.Value == 6 then
				Combo.Value = 1
				doingCombo.Value = 6

				task.delay(.5, function()
					Combo.Value = 1
					doingCombo.Value = 0
					M1Debounce.Value = false
				end)

			end

			game.Debris:AddItem(SFXHandler:PlayAlong(Constants.SFXs.Fist_Swing, Char), 3)

			Animations[doingCombo.Value]:Play(.05, 0.8, 2)
			task.delay(.15, function()
				createHitbox()
			end)

			if doingCombo.Value ~= 6 then
				task.delay(.5, function()
					M1Debounce.Value = false
				end)
			end

		end

	elseif action == "Block" and Humanoid.Health > 0 then
		if not M1Debounce.Value then --and not Disabled then --:Karna: (TASK_ID) : 1018
			isBlocking.Value = true
		end
		
	elseif action == "Unblock" then
		isBlocking.Value = false
	end
end
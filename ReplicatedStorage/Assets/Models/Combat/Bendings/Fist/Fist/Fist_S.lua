-- @ScriptType: Script
-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CS = game:GetService("CollectionService")

-- FOLDERS --
local Remotes = RS.Remotes
local Modules = RS.Modules
local Hitboxes = RS.Hitboxes
local Sounds = RS.Assets.SFXs.Sounds

-- MODULES --
local zonePlus = require(Modules.Packages.Zone)
local Misc = require(Modules.Packages.Misc)

-- REMOTES --
local attackRemote = script.Parent:WaitForChild("Attack")
local Replicate = Remotes.Replicate

-- VARIABLES --
local M1Debounce = false
local Equipped = script.Parent:WaitForChild("Equipped")
local Air = false
local Combo = 1
local doingCombo = 0

local hit = {}
local canHit = true
local currHitbox
local M1ImmunityTag = "Immunity"
local AirImmunityTag = "AirDown"

-- FUNCTIONS --
-- DISABLED: Old Bendings system retired in favour of VFXHandler dispatch
attackRemote.OnServerEvent:Connect(function(Player, Action, isHoldingSpace)
	if true then return end -- Security: disable legacy handler

	local Character = Player.Character
	local Humanoid = Character.Humanoid	
	local HRP = Character.HumanoidRootPart
	local pStrength = Player:FindFirstChild("CombatStats").Strength.Value
	local isBlocking = Player:WaitForChild("isBlocking")
	local b2 = Player.Character:WaitForChild("BlockTime")
	local M1Damage = 7.1 * (1 + (pStrength * 0.015))
	local M1StunDuration = 1

	local Disabled = Character:FindFirstChild("Disabled")
	
	if Action == "Attack" and Humanoid.Health > 0 and Equipped.Value == true then
		if not M1Debounce and not isBlocking.Value and not Disabled then
			M1Debounce = true

			 local Animations = {
				[1] = Humanoid:LoadAnimation(script.Parent.Animations.A1),
				[2] = Humanoid:LoadAnimation(script.Parent.Animations.A2),
				[3] = Humanoid:LoadAnimation(script.Parent.Animations.A3),
				[4] = Humanoid:LoadAnimation(script.Parent.Animations.A4),
				[5] = Humanoid:LoadAnimation(script.Parent.Animations.A5),
				[6] = Humanoid:LoadAnimation(script.Parent.Animations.A6),
			}
			if	Character:FindFirstChild("Stamina").Value >= 6 then
				Character:FindFirstChild("Stamina").Value = 	Character:FindFirstChild("Stamina").Value -6
			end



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
							if not v.Parent:FindFirstChild("Immune") and not Character:FindFirstChild("Disabled") and not Character:FindFirstChild("Immune") and not CS:HasTag(v.Parent, M1ImmunityTag) and not CS:HasTag(v.Parent, AirImmunityTag) then
								if canHit then
									canHit = false
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
											-- SafeZone: block PvP damage if either player is in safe zone
											local blockPvP = isPlayer and (Character:GetAttribute("InSafeZone") or v.Parent:GetAttribute("InSafeZone"))
											if blockPvP then return end
											local eHum = v.Parent.Humanoid

											Player.CombatStats:FindFirstChild("EXP").Value = 	Player.CombatStats:FindFirstChild("EXP").Value +5
												eHum:TakeDamage(M1Damage)


												Replicate:FireAllClients("Combat", "HitFX", v.Parent.HumanoidRootPart, "Basic Hit")
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

											if doingCombo < 5 then
												coroutine.wrap(function()
													local BV = Instance.new("BodyVelocity")
													BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Character.HumanoidRootPart.CFrame.lookVector * 20
													BV.Parent = eHum.Parent.HumanoidRootPart
													game.Debris:AddItem(BV, 0.1)
												end)()

												Misc.InsertDisabled(v.Parent, M1StunDuration)
										
											elseif doingCombo == 5 then
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
											elseif doingCombo == 6 then
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
										canHit = true
										CS:RemoveTag(v.Parent, M1ImmunityTag)
									end)
								end

							end
						end
					end
				end

				game.Debris:AddItem(hitboxTemp, .3)

			end

			if Combo == 1 then
				Combo = 2
				doingCombo = 1
				Animations[doingCombo]:Play(.05, 0.8, 1.4)
				
				local sfx = RS.Sounds3.Swing:Clone()
				sfx.Parent = Character
				sfx:Play()
	
				game.Debris:AddItem(sfx,3)
				Animations[doingCombo]:GetMarkerReachedSignal("Hit"):Connect(function()
			
						createHitbox()
			
				end)

				Animations[doingCombo]:GetMarkerReachedSignal("DBReset"):Connect(function()
					M1Debounce = false
				end)

				task.delay(1.5, function()
					if Combo == 2 then
						Combo = 1
						doingCombo = 0
					end
				end)
			elseif Combo == 2 then
				Combo = 3
				local sfx2 = RS.Sounds3.Swing:Clone()
				sfx2.Parent = Character
				sfx2:Play()
				game.Debris:AddItem(sfx2,3)
				doingCombo = 2
				Animations[doingCombo]:Play(.05, 0.8, 1.4)

				Animations[doingCombo]:GetMarkerReachedSignal("Hit"):Connect(function()
					
						createHitbox()
				
				end)

				Animations[doingCombo]:GetMarkerReachedSignal("DBReset"):Connect(function()
					M1Debounce = false
				end)

				task.delay(1.5, function()
					if Combo == 3 then
						Combo = 1
						doingCombo = 0
					end
				end)
			elseif Combo == 3 then
				local sfx3 = RS.Sounds3.Swing:Clone()
				sfx3.Parent = Character
				sfx3:Play()
				game.Debris:AddItem(sfx3,3)
				Combo = 4
				doingCombo = 3
				Animations[doingCombo]:Play(.05, 0.8, 1.4)

				Animations[doingCombo]:GetMarkerReachedSignal("Hit"):Connect(function()
					
						createHitbox()
				
				end)

				Animations[doingCombo]:GetMarkerReachedSignal("DBReset"):Connect(function()
					M1Debounce = false
				end)

				task.delay(1.5, function()
					if Combo == 4 then
						Combo = 1
						doingCombo = 0
					end
				end)
			elseif Combo == 4 then
				Combo = 5
				doingCombo = 4
				local sfx4 = RS.Sounds3.Swing:Clone()
				sfx4.Parent = Character
				sfx4:Play()
				game.Debris:AddItem(sfx4,3)
				
					Animations[doingCombo]:Play(.05, 0.8, 1.4)

					Animations[doingCombo]:GetMarkerReachedSignal("Hit"):Connect(function()
						
							createHitbox()
					
					end)

					Animations[doingCombo]:GetMarkerReachedSignal("DBReset"):Connect(function()
						M1Debounce = false
					end)
				


				task.delay(1.5, function()
					if Combo == 5 then
						Combo = 1
						doingCombo = 0
					end
				end)
			elseif Combo == 5 then
				Combo = 6
				doingCombo = 5
				local sfx4 = RS.Sounds3.Swing:Clone()
				sfx4.Parent = Character
				sfx4:Play()
				game.Debris:AddItem(sfx4,3)

				Animations[doingCombo]:Play(.05, 0.8, 1.4)

				Animations[doingCombo]:GetMarkerReachedSignal("Hit"):Connect(function()

					createHitbox()

				end)

				Animations[doingCombo]:GetMarkerReachedSignal("DBReset"):Connect(function()
					M1Debounce = false
				end)



				task.delay(1.5, function()
					if Combo == 5 then
						Combo = 1
						doingCombo = 0
					end
				end)
			elseif Combo == 6 then
				Combo = 1
				doingCombo = 6
				local sfx5 = RS.Sounds3.Swing:Clone()
				sfx5.Parent = Character
				sfx5:Play()
				game.Debris:AddItem(sfx5,3)

				Animations[doingCombo]:Play(.05, 0.8, 1.4)

				Animations[doingCombo]:GetMarkerReachedSignal("Hit"):Connect(function()

					createHitbox()

				end)

				Animations[doingCombo]:GetMarkerReachedSignal("End"):Connect(function()
					task.delay(1.5, function()
						Combo = 1
						doingCombo = 0
						M1Debounce = false
					end)
				end)
			

			end
		end

	elseif Action == "Equip" and Humanoid.Health > 0 then
		Equipped.Value = true
	elseif Action == "Unequip" then
		Equipped.Value = false
	elseif Action == "Block" and Humanoid.Health > 0 then
		if not M1Debounce and not Disabled and Equipped.Value == true then
		b2.Value = true
			isBlocking.Value = true
		end
	elseif Action == "Unblock" then
		isBlocking.Value = false
		b2.Value = false
		
	end
	
end)

-- @ScriptType: ModuleScript

local Tween = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")
local Debris = game:GetService("Debris")

local Modules = RS.Modules
local misc = require(Modules.Packages.Misc)
local Costs = require(script.Parent.Parent.Costs)
local Constants = require(Modules.Custom.Constants)

----Assets ref
local Effect = RS.Assets.VFXs.Water.Shock1
local Effect3 = RS.Assets.VFXs.Water.Shock2
local Effect4 = RS.Assets.VFXs.Water.Shock3
local Effect2 = RS.Assets.VFXs.Water.Ground
local HitBox = RS.Assets.VFXs.Water.HitBox

local DamageCalc = require(RS.Modules.Custom.CommonFunctions.Utils.DamageCalc)
local ElementXp = require(RS.Modules.Custom.CommonFunctions.Utils.ElementXp)

----Costs
local WaterStanceStamina = Costs.WaterStanceStamina
local WaterStanceXp = Costs.WaterStanceXp
local WaterStanceLvl = Costs.WaterStanceLvl
local WaterStanceDamageRange = Costs.WaterStanceDamageRange
local WaterStanceElementXp = Costs.WaterStanceElementXp


return function(plr, typ, direction, mouseaim)

	if(typ == "Weld") then
		-- Server-side stamina + level check
		if plr.Character:FindFirstChild("Stamina").Value < WaterStanceStamina then return end
		if plr.Progression.LEVEL.Value < WaterStanceLvl then return end
		plr.Character:FindFirstChild("Stamina").Value -= WaterStanceStamina

		--Weld
		local char = plr.Character
		local hrp = char.PrimaryPart

		--print("CALLLLLL1")
		
		local _hitBox = HitBox:Clone()
		_hitBox.Parent = hrp
		_hitBox.Name = "_hitBox"
		_hitBox.Anchored = true
		_hitBox.CFrame = hrp.CFrame
		
		local FX2 = Effect2:Clone()
		FX2.Anchored = true
		FX2.CanCollide = false
		FX2.Parent = hrp
		FX2.CFrame = hrp.CFrame * CFrame.new(0,-1,0)
		local tweenInfo5 = TweenInfo.new(
			0.7, -- Time
			Enum.EasingStyle.Bounce, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			0, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)

		local hum = char:FindFirstChild("Humanoid")
		--hum.MaxHealth += 50
		--hum.Health += 10
		
		---Effect3
		local FX3 = Effect3:Clone()
		FX3.Anchored = true
		FX3.CanCollide = false
		FX3.Parent = hrp
		FX3.CFrame = hrp.CFrame
		FX3.Orientation = Vector3.new(43.838, -90, -0)
		local tweenzy = Tween:Create(FX3, tweenInfo5, { Size = Vector3.new(19.986, 2.681, 28.743) })
		tweenzy:Play()

		Debris:AddItem(tweenzy, tweenzy.TweenInfo.Time+.1)

		---Effect4
		local FX34 = Effect4:Clone()
		FX34.Anchored = true
		FX34.CanCollide = false
		FX34.Parent = hrp
		FX34.CFrame = hrp.CFrame
		FX34.Orientation = Vector3.new(88.596, 90, 180)
		local tweenzsy = Tween:Create(FX34, tweenInfo5, { Size = Vector3.new(26.598, 33.073, 25.33) })
		tweenzsy:Play()
		
		Debris:AddItem(tweenzsy, tweenzsy.TweenInfo.Time+.1)
		
		---Effect
		local FX = Effect:Clone()
		FX.Anchored = true
		FX.CanCollide = false
		FX.Parent = hrp
		FX.CFrame = hrp.CFrame
		FX.Orientation = Vector3.new(35.671, 90, 180)
		local tweenzs1y = Tween:Create(FX, tweenInfo5, { Size = Vector3.new(19.986, 2.681, 28.743) })
		tweenzs1y:Play()
		
		Debris:AddItem(tweenzs1y, tweenzs1y.TweenInfo.Time+.1)
		
		local part = FX
		local part2 = FX2
		local tweenInfo2 = TweenInfo.new(
			3, -- Time
			Enum.EasingStyle.Bounce, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			-1, -- RepeatCount (when less than zero the tween will loop indefinitely)
			true, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		
		local tweenz = Tween:Create(part2, tweenInfo2, { Size = Vector3.new(34.942, 3.014, 30.253) })
		local tweenz1 = Tween:Create(FX3, tweenInfo2, { Size = Vector3.new(26.942, 3.014, 33.253) })
		local tweenz2 = Tween:Create(FX34, tweenInfo2, { Size = Vector3.new(34.942, 38.014, 30.253) })
		local tweenz3 = Tween:Create(FX, tweenInfo2, { Size = Vector3.new(25.942, 3.014, 35.253) })
		tweenz:Play()
		spawn(function()
			wait(1)
			tweenz2:Play()
			tweenz3:Play()
			tweenz1:Play()
			
			Debris:AddItem(tweenz,3.2)
			Debris:AddItem(tweenz1,3.2)
			Debris:AddItem(tweenz2,3.2)
			Debris:AddItem(tweenz3,3.2)
			
			local object = FX3 --Path to what object you're tweening
			local info = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0) -- -1 is for repeat count which will be infinite, false is for bool reverses which means it will not go backwards
			local goals = {Orientation = Vector3.new(0, 360, 0)} --Rotating it 360 degrees will make it go back to the original starting point, and with an infinite repeat count, it will go forever.
			local tween = Tween:Create(object, info, goals)
			tween:Play()

			local object23 = FX34 --Path to what object you're tweening
			local info23 = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0) -- -1 is for repeat count which will be infinite, false is for bool reverses which means it will not go backwards
			local goals23 = {Orientation = Vector3.new(0, 360, 0)} --Rotating it 360 degrees will make it go back to the original starting point, and with an infinite repeat count, it will go forever.
			local tween23 = Tween:Create(object23, info23, goals23)
			tween23:Play()

			local object234 = FX --Path to what object you're tweening
			local info234 = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1, false, 0) -- -1 is for repeat count which will be infinite, false is for bool reverses which means it will not go backwards
			local goals234 = {Orientation = Vector3.new(0, 360, 0)} --Rotating it 360 degrees will make it go back to the original starting point, and with an infinite repeat count, it will go forever.
			local tween234 = Tween:Create(object234, info234, goals234)
			tween234:Play()
			
			Debris:AddItem(tween, 11)
			Debris:AddItem(tween23, 11)
			Debris:AddItem(tween234, 11)
		end)

		local Hits = {}
		task.spawn(function()
			_hitBox.Touched:Connect(function(hit)
				local eChar = hit.Parent
				local hum2 = eChar:FindFirstChild("Humanoid")
				local hrp2 = eChar:FindFirstChild("HumanoidRootPart")

				if hum2 and eChar ~= char then
					if not hum2:FindFirstChild(plr.Name) and (eChar:HasTag(Constants.Tags.PlayerAvatar) 
						or eChar:HasTag(Constants.Tags.NPCAI)) then
						if Hits[eChar] then
							return
						else
							Hits[eChar] = true
						end
						
						local Exp = plr.Progression:FindFirstChild("EXP")
						if Exp then
							Exp.Value += WaterStanceXp
						end
						ElementXp.Award(plr, "Water", WaterStanceElementXp)

						hrp2.CFrame = CFrame.lookAt(hrp2.Position, _hitBox.Position) * CFrame.Angles(0, math.pi, 0)
						misc.Ragdoll(eChar, 1.5)

						misc.StrongKnockback(hrp2, 35, 45, 0.15, _hitBox)
						misc.UpKnockback(hrp2, 35, 65, 0.15, _hitBox)

						local baseDamage = math.random(WaterStanceDamageRange.X, WaterStanceDamageRange.Y)
						local Damage = DamageCalc.Calculate(baseDamage, DamageCalc.GetPlayerLevel(plr), DamageCalc.GetElementLevel(plr, "Water"))
						hum2:TakeDamage(Damage)

						local LastDamage = hum2.Parent:FindFirstChild("DamageBy") or Instance.new('ObjectValue', hum2.Parent)
						LastDamage.Name = "DamageBy"
						LastDamage.Value = plr.Character
						LastDamage:SetAttribute("Weapon", Constants.Weapons.Water)

						task.delay(1.5, function()
							Hits[eChar] = nil
						end)
					end
				end
				wait(6)
				if _hitBox then
					_hitBox:Destroy()
				end
			end)
		end)
		
	else
		--RE

		--if	plr.Character:FindFirstChild("Stamina").Value < WaterStanceStamina then return end
		--plr.Character:FindFirstChild("Stamina").Value -= WaterStanceStamina
		
		local char = plr.Character
		local hum = char:WaitForChild("Humanoid")
		local hrp = char:WaitForChild'HumanoidRootPart'
		local FX = hrp:FindFirstChild("Ground")
		FX.CanCollide = false

		local FX2 = hrp:FindFirstChild("Shock1")
		local FX3 = hrp:FindFirstChild("Shock2")
		local FX4 = hrp:FindFirstChild("Shock3")
		
		local FX5 = hrp:FindFirstChild("_hitBox")
		if FX5 then
			FX5:Destroy()
		end
		local tweenInfo = TweenInfo.new(
			1, -- Time
			Enum.EasingStyle.Bounce, -- EasingStyle
			Enum.EasingDirection.Out, -- EasingDirection
			0, -- RepeatCount (when less than zero the tween will loop indefinitely)
			false, -- Reverses (tween will reverse once reaching it's goal)
			0 -- DelayTime
		)
		
		print("[WaterS] decreasing ", hum.MaxHealth - 50, hum.Health - 10)
		--hum.MaxHealth -= 50
		--hum.Health -= 10
		
		local T1 = Tween:Create(FX, tweenInfo, { Size = Vector3.new(0.1,0.1,0.1) })
		local T2 = Tween:Create(FX2, tweenInfo, { Size = Vector3.new(0.1,0.1,0.1) })
		local T3 = Tween:Create(FX3, tweenInfo, { Size = Vector3.new(0.1,0.1,0.1) })
		local T4 = Tween:Create(FX4, tweenInfo, { Size = Vector3.new(0.1,0.1,0.1) })
		
		
		local T5 = Tween:Create(FX, tweenInfo, { Transparency = 1 })
		local T6 = Tween:Create(FX2, tweenInfo, { Transparency = 1 })
		local T7 = Tween:Create(FX3, tweenInfo, { Transparency = 1 })
		local T8 = Tween:Create(FX4, tweenInfo, { Transparency = 1 })
		
		T1:Play()
		T2:Play()
		T3:Play()
		T4:Play()
		T5:Play()
		T6:Play()
		T7:Play()
		T8:Play()
		
		Debris:AddItem(T1, T1.TweenInfo.Time+.1)
		Debris:AddItem(T2, T2.TweenInfo.Time+.1)
		Debris:AddItem(T3, T3.TweenInfo.Time+.1)
		Debris:AddItem(T4, T4.TweenInfo.Time+.1)
		Debris:AddItem(T5, T5.TweenInfo.Time+.1)
		Debris:AddItem(T6, T6.TweenInfo.Time+.1)
		Debris:AddItem(T7, T7.TweenInfo.Time+.1)
		Debris:AddItem(T8, T8.TweenInfo.Time+.1)
		
		FX.Anchored = false
		
		Debris:AddItem(FX,.5)
		Debris:AddItem(FX2,.5)
		Debris:AddItem(FX3,.5)
		Debris:AddItem(FX4,.5)
	end

end
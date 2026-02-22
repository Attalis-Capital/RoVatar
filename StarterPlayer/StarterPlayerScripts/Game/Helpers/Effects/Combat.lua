-- @ScriptType: ModuleScript
local Combat = {}
-- SERVICES --
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

-- FOLDERS --
local Modules = RS.Modules
local CS = game:GetService("CollectionService")
-- MODULES --
local rocksModule = require(Modules.Packages.RocksModule)
local debrisModule = require(Modules.Packages.Debris)

-- FUNCTIONS --
local function RoundNumber(num)
	return(math.floor(num+0.5))
end
local AirImmunityTag = "AirDown"
local Misc = require(Modules.Packages.Misc)

Combat.Perform = function(Action, Variable2, Variable3)
	--print('Combat Test ', Action, Variable2, Variable3)
	if Action == "AirDown" then
		local TargetPosition = Variable2
		local Character = Variable3
		rocksModule.Ground(TargetPosition, 10, Vector3.new(2, 2, 2), {workspace.Debris, Character}, 5, false, 2.5)
		rocksModule.BlockExplosion(CFrame.new(TargetPosition) * CFrame.new(0, 1, 0), 0.3, 0.7, 1, 1, false)
		debrisModule.sphereExp(TargetPosition, 10, 20, Color3.fromRGB(255, 255, 255))
		
		local sfx = script.Sounds.Slam:Clone()
		sfx.Parent = Character.HumanoidRootPart
		sfx:Play()
		game.Debris:AddItem(sfx, 1)
		
		
	elseif Action == "HitFX" then
		local Target = Variable2
		local Type = Variable3
		
		if Target ~= nil then
			
				
			if Type == "Basic Hit" then
				local hitFX = script.FX["Basic Hit"].Attachment:Clone()
				hitFX.Parent = Target

				local sfx = script.Sounds.SwordHit1:Clone()
				sfx.Parent = hitFX
				sfx:Play()
				game.Debris:AddItem(sfx,3)
				for i, v in pairs(hitFX:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(v:GetAttribute("EmitCount"))
					elseif v:IsA("PointLight") then
						v.Brightness = 0
						v.Range = 0
						TS:Create(v, TweenInfo.new(0.1), {Brightness = 1, Range = 10}):Play()
						task.delay(0.15, function()
							TS:Create(v, TweenInfo.new(0.1), {Brightness = 0, Range = 0}):Play()
						end)
					end
				end

				game.Debris:AddItem(hitFX, 2)

			elseif Type == "Blade Hit" then
				local hitFX = script.FX["Blade Hit"].Attachment:Clone()
				hitFX.Parent = Target

				local sfx = script.Sounds.Sword1:Clone()
				sfx.Parent = hitFX
				sfx:Play()
				game.Debris:AddItem(sfx,3)
				for i, v in pairs(hitFX:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(v:GetAttribute("EmitCount"))
					elseif v:IsA("PointLight") then
						v.Brightness = 0
						v.Range = 0
						TS:Create(v, TweenInfo.new(0.1), {Brightness = 1, Range = 10}):Play()
						task.delay(0.15, function()
							TS:Create(v, TweenInfo.new(0.1), {Brightness = 0, Range = 0}):Play()
						end)
					end
				end
				
				game.Debris:AddItem(hitFX, 2)
				
			elseif Type == "Block Break" then
				local fx = script.FX["Block Break"].Attachment:Clone()
				fx.Parent = Target
				
				local sfx = script.Sounds.BlockBreak:Clone()
				sfx.Parent = fx
				sfx:Play()
				local bh = script.FX["Block Break"].BillboardGui:Clone()
				
			
				bh.Parent = Target
				local hum = Target.Parent:FindFirstChild("Humanoid")
		
				
				
				local TweenService = game:GetService("TweenService")
				task.spawn(function()
					local willTween = bh.PB:TweenSize(
						UDim2.new(0, 500, 0, 55),  -- endSize (required)
						Enum.EasingDirection.Out,    -- easingDirection (default Out)
						Enum.EasingStyle.Back,      -- easingStyle (default Quad)
						0.6,                          -- time (default: 1)
						false,                       -- should this tween override ones in-progress? (default: false)
						nil                    -- a function to call when the tween completes (default: nil)
					)
					task.wait(0.8)
					local willTween2 = bh.PB:TweenSize(
						UDim2.new(0, 500, 0, 0),  -- endSize (required)
						Enum.EasingDirection.In,    -- easingDirection (default Out)
						Enum.EasingStyle.Sine,      -- easingStyle (default Quad)
						0.5,                          -- time (default: 1)
						false,                       -- should this tween override ones in-progress? (default: false)
						nil                    -- a function to call when the tween completes (default: nil)
					)

				end)


				game.Debris:AddItem(bh,5)
				for i, v in pairs(fx:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(v:GetAttribute("EmitCount"))
					elseif v:IsA("PointLight") then
						v.Brightness = 0
						v.Range = 0
						TS:Create(v, TweenInfo.new(0.1), {Brightness = 1, Range = 10}):Play()
						task.delay(0.15, function()
							TS:Create(v, TweenInfo.new(0.1), {Brightness = 0, Range = 0}):Play()
						end)
					end
				end
			
				

			elseif Type == "Block Hit" then
				local fx = script.FX["Block Hit"].Attachment:Clone()
				fx.Parent = Target
				
				local sfx = script.Sounds.BlockHit:Clone()
				sfx.Parent = fx
				sfx:Play()
				local bh = script.FX["Block Hit"].BillboardGui:Clone()
				
				bh.Parent = Target
				local TweenService = game:GetService("TweenService")
				task.spawn(function()
					local willTween = bh.PB:TweenSize(
						UDim2.new(0, 500, 0, 25),  -- endSize (required)
						Enum.EasingDirection.Out,    -- easingDirection (default Out)
						Enum.EasingStyle.Back,      -- easingStyle (default Quad)
						0.35,                          -- time (default: 1)
						false,                       -- should this tween override ones in-progress? (default: false)
						nil                    -- a function to call when the tween completes (default: nil)
					)
					task.wait(0.4)
					local willTween2 = bh.PB:TweenSize(
						UDim2.new(0, 500, 0, 0),  -- endSize (required)
						Enum.EasingDirection.In,    -- easingDirection (default Out)
						Enum.EasingStyle.Sine,      -- easingStyle (default Quad)
						0.3,                          -- time (default: 1)
						false,                       -- should this tween override ones in-progress? (default: false)
						nil                    -- a function to call when the tween completes (default: nil)
					)

				end)


				game.Debris:AddItem(bh,5)
				for i, v in pairs(fx:GetChildren()) do
					if v:IsA("ParticleEmitter") then
						v:Emit(v:GetAttribute("EmitCount"))
					elseif v:IsA("PointLight") then
						v.Brightness = 0
						v.Range = 0
						TS:Create(v, TweenInfo.new(0.1), {Brightness = 1, Range = 10}):Play()
						task.delay(0.15, function()
							TS:Create(v, TweenInfo.new(0.1), {Brightness = 0, Range = 0}):Play()
						end)
					end
				end
			end
		end
	
		
	end
end

return Combat
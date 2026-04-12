-- @ScriptType: ModuleScript
local RSS = game:GetService("RunService")
local Tween = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")

local VFXs = RS.Assets.VFXs
local LevelUp = VFXs.LevelUp

if(RSS:IsClient()) then
	return function(plr:Player, upLevel:IntValue)
		--print('Showing Level Up ')
		local fr = LevelUp:Clone()
		fr.Parent = workspace
		fr.CFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
		game.Debris:AddItem(fr, 3)
		fr.Particles:Emit(fr.Particles:GetAttribute("EmitCount"))

		spawn(function()
			for i, v in pairs(fr.ParticleAttachment:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(v:GetAttribute("EmitCount"))
				else
					Tween:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0.75, Range = 20}):Play()
					task.delay(0.26, function()
						Tween:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0}):Play()
					end)
				end
			end

		end)
	end
else
	return function(plr:Player, upLevel:IntValue)
		--print('Showing Level Up ')
		local fr = LevelUp:Clone()
		fr.Parent = workspace
		fr.CFrame = plr.Character.HumanoidRootPart.CFrame
		game.Debris:AddItem(fr, 3)
		fr.Particles:Emit(fr.Particles:GetAttribute("EmitCount"))

		spawn(function()
			for i, v in pairs(fr.ParticleAttachment:GetChildren()) do
				if v:IsA("ParticleEmitter") then
					v:Emit(v:GetAttribute("EmitCount"))
				else
					Tween:Create(v, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0.75, Range = 20}):Play()
					task.delay(0.26, function()
						Tween:Create(v, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Brightness = 0, Range = 0}):Play()
					end)
				end
			end

		end)
	end
end

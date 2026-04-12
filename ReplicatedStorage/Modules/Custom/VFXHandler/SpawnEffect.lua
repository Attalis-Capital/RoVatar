-- @ScriptType: ModuleScript
local Tween = game:GetService("TweenService")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")

local VFXs = RS.Assets.VFXs
local SpawnEffect = VFXs.SpawnEffect

return function(char:Instance)
	--print('Showing character spawn effect')
	local fr = SpawnEffect:Clone()
	fr.Parent = workspace
	fr.Position = char.HumanoidRootPart.CFrame.Position
	game.Debris:AddItem(fr, 1.5)
	
end
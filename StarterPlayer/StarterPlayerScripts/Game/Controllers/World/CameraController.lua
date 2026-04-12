-- @ScriptType: ModuleScript
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

local Knit = require(RS.Packages.Knit)

local Modules = RS.Modules

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Camera --
local camera = workspace.CurrentCamera

local CameraShaker = require(Modules.Packages.CameraShaker)

local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value, function(shakeCFrame)
	camera.CFrame = camera.CFrame * shakeCFrame
end)

camShake:Start()

local HandHeldCameraPositions = workspace.Scripted_Items.Camera.HandHeldPositions

local CameraController = Knit.CreateController {
	Name = "CameraController",
}


-------------------------------->>>>>>>>> Private Methods <<<<<<<<<<-------------------------------


local function OnCharacterUpdated(newChar:Model)
	character = newChar
	BindHumanoidHealth()
end

function BindHumanoidHealth()
	local healthhumanoid = character:WaitForChild("Humanoid").Health
	character.Humanoid.HealthChanged:Connect(function(health)
		if healthhumanoid > health then
			if workspace:GetAttribute("GameStarted") then
				camShake:Shake(CameraShaker.Presets.Bump)
			end
		end
		healthhumanoid = health
	end)
end


-------------------------------->>>>>>>>> Public Methods <<<<<<<<<<-------------------------------
function CameraController:ShakeCam(typ)
	if workspace:GetAttribute("GameStarted") then
		camShake:Shake(CameraShaker.Presets[typ])
	end
end

-------------
local TweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, 0, true)
local Tween = nil
local playing = false

function CameraController:HandHeldView(enable)
	if true then return end
	
	if enable then
		if playing then return end -- Prevent re-enabling if already playing
		playing = true

		local Children = HandHeldCameraPositions:GetChildren()
		local CameraPart = Children[math.random(1, #Children)]

		camera.CFrame = CameraPart.CFrame
		camera.CameraType = Enum.CameraType.Scriptable

		-- Tween Effect
		local random = Random.new()
		local function getNewCFrame()
			local CF = CameraPart.CFrame
			local newCF = CF * CFrame.Angles(
				math.rad(random:NextNumber(-3, 3)),
				math.rad(random:NextNumber(-1, 1)),
				math.rad(0)
			)
			return newCF
		end

		task.spawn(function()
			while playing do
				local CF = getNewCFrame()
				Tween = TweenService:Create(camera, tweenInfo, {CFrame = CF})
				Tween:Play()

				Tween.Completed:Wait()
				Tween:Destroy()
				task.wait(1)
			end
		end)
	else
		if not playing then return end -- Prevent re-disabling if already stopped
		playing = false

		if Tween then Tween:Destroy() end

		local Head = player.Character.Head
		
		local camCFrame = camera.CFrame
		local camDistance = camCFrame.p - Head.Position
	
		local newPos = player.Character.Head.Position + camDistance
		local cameraCFrame = CFrame.new(newPos, newPos + camCFrame.LookVector)
		
		camera.CameraSubject = player.Character:WaitForChild("Humanoid")
		local tween = TweenService:Create(camera, TweenInfo.new(0.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {CFrame = cameraCFrame})
		tween:Play()
		camera.CameraType = Enum.CameraType.Custom
		tween.Completed:Connect(function()
			--camera.CameraSubject = player.Character:WaitForChild("Humanoid")
			tween:Destroy()
		end)
		
		------ 
		local GUI = Instance.new("ScreenGui", player.PlayerGui)
		GUI.IgnoreGuiInset = true
		GUI.ResetOnSpawn = false
		GUI.DisplayOrder = 100
		local Frame = Instance.new("Frame", GUI)
		Frame.Size = UDim2.new(1, 0, 1, 0)
		Frame.AnchorPoint = Vector2.new(.5, .5)
		Frame.Position = UDim2.new(.5, 0, .5, 0)
		Frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		
		local tween1 = TweenService:Create(Frame, TweenInfo.new(0.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
		tween1:Play()
		game.Debris:AddItem(tween1, 0.15)
		task.delay(tween.TweenInfo.Time, function()
			local tween2 = TweenService:Create(Frame, TweenInfo.new(.75, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
			tween2:Play()
			game.Debris:AddItem(tween2, .76)
			game.Debris:AddItem(GUI, .76)
		end)
	end
end

function CameraController:KnitInit()

end

function CameraController:KnitStart()
	BindHumanoidHealth()
	player.CharacterAdded:Connect(OnCharacterUpdated)
end

return CameraController
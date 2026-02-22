-- @ScriptType: ModuleScript
local Debris = game:GetService("Debris")
local Camera = game.Workspace.CurrentCamera
local RS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local CustomModules = RS.Modules.Custom
local Costs = require(CustomModules.Costs)
local CT = require(CustomModules.CustomTypes)
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)
local SFXHandler = require(CustomModules.SFXHandler)

local GameElements = RS.GameElements
local DefaultCameraFOV = GameElements.Configs.CameraFOV
local DefaultCameraMinDist = GameElements.Configs.CameraMinDist
local DefaultCameraMaxDist = GameElements.Configs.CameraMaxDist

local player = game.Players.LocalPlayer
local Character = player.Character or player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChild("Humanoid")

-----------
local TransportF = workspace.Scripted_Items.Transports
local MyVehiclesF = TransportF:FindFirstChild(player.Name)
local Glider = Component.new({Tag = player.UserId.."Glider", Ancestors = {workspace}})

------ Other scripts
-->>> Services
local TransportService --= Knit.GetService("TransportService")

-->>> Controllers
local UiController = Knit.GetController("UIController")
local InputController = Knit.GetController("InputController")
local PlayerController = Knit.GetController("PlayerController")
local CharacterController = Knit.GetController("CharacterController")

local CoolDownGui
------ Variables

-- Constants
local IND = tostring(0 / 0)

-- Configurations

local Configurations = {
	AangGlider = {
		GyroAngle = 0.09---math.pi/2
	},
	
	KorraGlider = {
		GyroAngle = -0.09
	}
}

local GyroAngle = 0
local ThrustPart = nil

local Y = 1
local Speed = 0
local MinSpeed = 1
local MaxSpeed = 500

local BasePower = 1
local SprintPower = 2

local Power = BasePower

-- To manage slowly acceleration at start.
local CurrentSpeed = 0
local Acceleration = 5 -- adjust for faster/slower ramp-up

------------- Helper ------------

local Animations = {
	Character = {
		Fly = script.Animations.R15Fly,
		Land = script.Animations.Land
	},
}

local Controls = {
	["Sprint1"] = {
		keys = {Enum.KeyCode.LeftShift, Enum.KeyCode.ButtonL2},
		actionName = "Sprint1",	
		touch = {
			Image = "rbxassetid://15606592264",
			Text = "",
		},
	},
}

----------------------***************** Private Methods **********************----------------------

local function CharacterAdded(character)
	Character = character
	Humanoid = Character:WaitForChild("Humanoid")
end
player.CharacterAdded:Connect(CharacterAdded)

local function SprintCallback(actionName, inputState, inputObject)
	if (actionName == Controls.Sprint1.actionName) then
		if (inputState == Enum.UserInputState.Begin) then
			Power = SprintPower
		elseif (inputState == Enum.UserInputState.End) then
			Power = BasePower
		end
	end
end

local function BindSprint()
	
	local inputData : CT.InputDataType = {}
	inputData.KeyCodes = {}
	inputData.UiData = {}
	inputData.KeyCodes = Controls.Sprint1.keys
	inputData.UiData.Image = Controls.Sprint1.touch.Image
	
	InputController:BindMultipleInputs(inputData, Controls.Sprint1.actionName, SprintCallback)
	
end

local function UnBindSprint()
	InputController:UnBindInput(Controls.Sprint1.keys[1], Controls.Sprint1.actionName)
end

---------<<<<<<<<<<<< Common
function GetMassOf(model)
	if model:IsA("BasePart") then
		return model:GetMass()
	else
		local mass = 0
		for _, ch in pairs(model:GetChildren()) do
			mass = mass + GetMassOf(ch)
		end
		return mass
	end
end

function Slerp(t, a, b)
	local om = math.acos(math.min(1, a:Dot(b)))
	if om < 0.01 then
		return ((1 - t) * a + t * b)
	else
		return ((math.sin((1 - t) * om ) / math.sin(om)) * a + (math.sin(t * om) / math.sin(om)) * b)
	end
end

--------->>>>>>>>>>>> Common
local Flying = false
local function _engine(dt) -- call in heartbeat or loop
	if Flying then
		local moveDir = (Camera.CFrame * CFrame.Angles(0.6, 0.6, 0.6))
		local theta = math.acos(DesiredFlightCFrame.lookVector:Dot(moveDir.lookVector))
		local frac = math.min(1, (1.5 * dt / theta))
		local unit = Slerp(frac, DesiredFlightCFrame.lookVector, moveDir.lookVector)

		DesiredFlightCFrame = CFrame.new(Camera.CFrame.p, ThrustPart.Position)

		if unit and unit.X and unit.Y and unit.Z and
			(tostring(unit.X) ~= IND and tostring(unit.Y) ~= IND and tostring(unit.Z) ~= IND) then

			local velo = ThrustPart.Velocity * 1.2
			local veloXZ = (velo - Vector3.new(0, velo.y, 0))
			local dir = DesiredFlightCFrame.lookVector
			local dirXZ = (dir - Vector3.new(0, dir.y, 0)).unit

			FlyingGyro.CFrame = DesiredFlightCFrame
				* CFrame.Angles(0, 0, ThrustPart.RotVelocity.y/3 * (1-math.abs(dir.y)^2)) 
				* CFrame.Angles(GyroAngle, 0, 0)

			local headingForceFactor = -dir.y  -- heading up => negative force
			local liftForceFactor = dir.y      -- heading up => positive lift
			local forwardsSpeed = math.max(0, velo.magnitude)
			local weight = (GetMassOf(Character) * 20 * 9.81)
			local dragForce = ((velo.magnitude/10)^2 * weight)
			local dragForceY = ((velo.y/15)^2 * weight)
			local dragForceXZ = ((veloXZ.magnitude/35)^2 * weight)

			local suspendFactor = 0
			if dir.y < 0 then
				suspendFactor = (-dir.y)^2
			end
			
			local force = Vector3.new(0, weight * (1.0 - suspendFactor + 0.3 * liftForceFactor), 0)
				+ (dirXZ * Speed * (weight * 1.0 * math.max(0, (0.5 * headingForceFactor+0.6))))
			- (veloXZ.unit * dragForceXZ)
			- (Vector3.new(0, velo.y, 0).unit * (dragForceY / Speed) * .2)
			if tostring(force.X) ~= IND and tostring(force.Y) ~= IND and tostring(force.Z) ~= IND then
				---- Clamping Values
				local X = math.clamp(force.X , -2000, 2000)
				local Y = math.clamp(force.Y, -2000, 2000)
				local Z = math.clamp(force.Z, -2000, 2000)
				local F = Vector3.new(X, Y, Z )
				
				FlyingForce.Force = force
			end
		end
	else
		warn("ERROR!", " Not Flying...")
	end
end

function Glider:Begin()

	if Flying then return else warn("Already Flying...") end

	Character = game.Players.LocalPlayer.Character
	Humanoid = Character:FindFirstChild("Humanoid")

	wait(0.2)
	
	Humanoid.Jump = true
	Flying = true
	Humanoid.Sit = true
	
	Camera.CameraSubject = self.Focus
	Camera.CameraType = Enum.CameraType.Track
	player.CameraMinZoomDistance = 20
	task.defer(function()
		player.CameraMinZoomDistance = 20 --DefaultCameraMinDist.Value
	end)
	
	
	-- Play Animations Tracks
	self.AnimationTrack:Play()
	SFXHandler:PlayAlong(Constants.SFXs.Glider_Wind, self.Focus)
	
	---- Creating Gyros Align
	FlyingGyro = Instance.new("AlignOrientation")
	FlyingGyro.Mode = Enum.OrientationAlignmentMode.OneAttachment
	FlyingGyro.Attachment0 = self.Focus.ForceAttachment
	FlyingGyro.MaxTorque = 1000
	FlyingGyro.CFrame = self.Focus.CFrame
	FlyingGyro.Parent = self.Focus

	---- Creating Vector Force
	FlyingForce = Instance.new("VectorForce")
	FlyingForce.Attachment0 = self.Focus.ForceAttachment
	FlyingForce.ApplyAtCenterOfMass = true
	FlyingForce.Force = Vector3.zero
	FlyingForce.RelativeTo = Enum.ActuatorRelativeTo.World
	FlyingForce.Parent =  self.Focus

	DesiredFlightCFrame = (self.Focus.CFrame * CFrame.Angles(0, 0, 0.5))
	
	-- Setup Engine
	self.Engine = _engine
	
end

function Glider:End()
	Flying = false

	self.Engine = nil

	-- Resetup to original
	Camera.CameraSubject = Character
	Camera.CameraType = Enum.CameraType.Custom
	Camera.FieldOfView = DefaultCameraFOV.Value
	player.CameraMinZoomDistance = DefaultCameraMinDist.Value
	player.CameraMaxZoomDistance = 15
	task.defer(function()
		player.CameraMaxZoomDistance = DefaultCameraMaxDist.Value
	end)


	SFXHandler:Stop(Constants.SFXs.Glider_Wind, self.Focus)
	self.AnimationTrack:Stop()
	self.AnimationTrack:Destroy()
	
	Humanoid.Sit = false
	Humanoid.Jump = true
	
	self.Focus.RotVelocity = Vector3.new(0,0,0)
	Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	
	self.LandAnimationTrack:Play()
	self.LandAnimationTrack.Stopped:Connect(function()
		self.LandAnimationTrack:Destroy()
	end)
end

function Glider:Attach()
	local function weldAttachments(attach1, attach2)
		local weld = Instance.new("Motor6D")
		weld.Part0 = attach1.Parent
		weld.Part1 = attach2.Parent
		weld.C0 = attach1.CFrame
		weld.C1 = attach2.CFrame
		weld.Parent = attach2.Parent
		return weld
	end

	local Att2 = self.Instance.Handle:FindFirstChildOfClass("Attachment")
	local Att1 = Character:FindFirstChild(Att2.Name, true)
	weldAttachments(Att1, Att2)
end

function Glider:BindTouchEvent()
	-->>> Disconect Conn
	local function Disconnect(conn)
		if conn then
			conn:Disconnect()
		end
	end
	Disconnect(self.Conn)
	
	---- Glider Triger
	local Trigger = self.Instance.Handle.Trigger
	local Filter = {Character, self.Instance}
	
	-- Binding touch connection
	self.Conn = Trigger.Touched:Connect(function(part)
		for _, Exception in pairs(Filter) do
			if not part:IsDescendantOf(Exception) and part.Name ~= "Trigger" then
				--print("Touched with ", part)
				Disconnect(self.Conn)
				---- Fire Event for DeSpawning Glider
				TransportService.DeSpawnVehicle:Fire(self.Instance.Name)
			end
		end
	end)

end

----------------------***************** Public Methods **********************----------------------
function Glider:Start()
	warn(self," Starting...")
	
	---- Setup Services Reference
	TransportService = Knit.GetService("TransportService")
	
	CoolDownGui = UiController:GetGui(Constants.UiScreenTags.CoolDownGui, 5)

	self.Conn = nil
	self.Focus = self.Instance.Handle
	self.Type = self.Instance:GetAttribute("Type")
	
	_G.Flying = self.Type
	
	self.SpeedValue = script.Configuration.Speed[self.Type]
	
	self.AnimationTrack = Humanoid.Animator:LoadAnimation(Animations.Character.Fly)
	self.LandAnimationTrack = Humanoid.Animator:LoadAnimation(Animations.Character.Land)
	
	Humanoid.Jump = true
	
	ThrustPart = self.Focus 
	GyroAngle = Configurations[self.Type].GyroAngle
	
	PlayerController:ToggleControls(false)
	CharacterController:ToggleControls(false)
	
	BindSprint()
	
	self:Begin()
	task.delay(.5, function()
		self:BindTouchEvent()
	end)
end

function Glider:Stop()
	print(self, "<Stop Glider>")
	
	-- Show Cooldown timer for ReEquip Glider
	CoolDownGui:StartCoolDown(Costs.VehicleCoolDown, Constants.Items.Glider.Name)
	delay(Costs.VehicleCoolDown, function()
		_G.Flying = nil
	end)
	
	self:End()
	UnBindSprint()
	
	CharacterController:ToggleControls(true)
	PlayerController:ToggleControls(true)
	
end

function Glider:HeartbeatUpdate(dt)
	
	if self.Engine then
		
		--Speed = self.SpeedValue.Value
		
		--Speed *= Power
		
		--Speed = math.clamp(Speed, MinSpeed, MaxSpeed)
		
		
		local targetSpeed = self.SpeedValue.Value * Power
		targetSpeed = math.clamp(targetSpeed, MinSpeed, MaxSpeed)

		-- Smooth acceleration towards targetSpeed
		if CurrentSpeed < targetSpeed then
			CurrentSpeed = math.min(CurrentSpeed + Acceleration * dt, targetSpeed)
		elseif CurrentSpeed > targetSpeed then
			CurrentSpeed = math.max(CurrentSpeed - Acceleration * dt, targetSpeed)
		end

		-- Use CurrentSpeed instead of instant speed
		Speed = CurrentSpeed
		
		
		
		
		self.Engine(dt)
	end
	
end

return Glider
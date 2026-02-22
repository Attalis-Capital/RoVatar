-- @ScriptType: ModuleScript
local Debris = game:GetService("Debris")
local Camera = game.Workspace.CurrentCamera
local RS = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local Costs = require(RS.Modules.Custom.Costs)
local Constants = require(RS.Modules.Custom.Constants)
local SFXHandler = require(RS.Modules.Custom.SFXHandler)

local GameElements = RS.GameElements
local DefaultCameraFOV = GameElements.Configs.CameraFOV
local DefaultCameraMinDist = GameElements.Configs.CameraMinDist
local DefaultCameraMaxDist = GameElements.Configs.CameraMaxDist

local player = game.Players.LocalPlayer
local Character = player.Character
local Humanoid :Humanoid = Character:FindFirstChild("Humanoid")

local TransportF = workspace.Scripted_Items.Transports
local MyVehiclesF = TransportF:FindFirstChild(player.Name)
local Appa = Component.new({Tag = player.UserId.."Appa", Ancestors = {workspace}})

------ Other scripts
---->> Services
local TransportService

---->> Controllers
local UIController = Knit.GetController("UIController")
local PlayerController = Knit.GetController("CharacterController")
local CharacterController = Knit.GetController("PlayerController")
------ Variables

local CoolDownGui

-- Constants
local IND = tostring(0 / 0)

local JumpPower = 50; --Humanoid.JumpPower
-- Configurations

local GyroAngle = 0
local ThrustPart = nil

local FlyingGyro
local FlyingForce
local DesiredFlightCFrame

local Yaxis
local ENGINESTARTTIME = tick()
------------- Helper ------------
local Animations = {
	Appa = {
		Fly = script.Animations.Appa.Fly,
		--Idle = script.Animations.Appa.Idle
	},
	
	Character = {
		Fly = script.Animations.Character.Fly,
		Land = script.Animations.Character.Land,
	},
}

----------------------***************** Private Methods **********************----------------------


local function CharacterAdded(character)
	Character = character or player.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild('Humanoid')
	--print("CHARACTER ADDED ")	
	--Appa:Destroy()
	
end
player.CharacterAdded:Connect(CharacterAdded)

---------<<<<<<<<<<<< Common
function GetMassOf(model)
	if model:IsA("BasePart") or model:IsA("MeshPart") or model:IsA('VehicleSeat') then
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

local function setupProximity(self)

	local Proxi = Instance.new("ProximityPrompt", self.Handle)
	Proxi.ObjectText = `Ride {Constants.Items.Appa.Name}`
	Proxi.ActionText = "Sit"
	Proxi.MaxActivationDistance = 250
	Proxi.RequiresLineOfSight = false
	Proxi.HoldDuration = .5
	Proxi.Triggered:Connect(function()
		-- Send Sit event to transport service and network owner or Animation
		--print("[APPA] BEGIN")
		self:Begin()
	end)

	self.Proximity = Proxi

end

local function LandingAnimation(self)
	local animConn
	animConn = Humanoid.StateChanged:Connect(function(old, new)
		if new == Enum.HumanoidStateType.Landed then
			animConn:Disconnect()
			self.CharAnimTracks.Land:Play()

			task.delay(1, function()
				self.CharAnimTracks.Land:Destroy()
			end)
		end
	end)
end

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
			
			Yaxis = velo.y
			
			local YForce = (Vector3.new(0, velo.y, 0).unit * (dragForceY / Speed) * .5)
			
			if (tick() - ENGINESTARTTIME) <= 3 then
				YForce = Vector3.new(0,-500,0)
			end
			
			local force = Vector3.new(0, weight * (1.0 - suspendFactor + 0.3 * liftForceFactor), 0)
				+ (dirXZ * Speed * (weight * 1.0 * math.max(0, (0.5 * headingForceFactor+0.6))))
			- (veloXZ.unit * dragForceXZ)
			- YForce
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


function Appa:Begin()
	
	if Flying then return else warn("Already Flying...") end
	
	task.delay(2, function() self:BindTouchEvent() end)
	
	Flying = true
	
	Character = game.Players.LocalPlayer.Character
	Humanoid = Character:FindFirstChild("Humanoid")
	
	Camera.FieldOfView = 85
	player.CameraMinZoomDistance = 90
	task.defer(function()
		player.CameraMinZoomDistance = 45
	end)
	
	PlayerController:ToggleControls(false)
	CharacterController:ToggleControls(false)
	
	ENGINESTARTTIME = tick()
	
	-- Play Animations Tracks
	self.AppaAnimTracks.Fly:Play()
	SFXHandler:PlayAlong(Constants.SFXs.Appa_Wind, self.Seat)
	-- Disable Proximity
	self.Proximity.Enabled = false
	self.Seat:Sit(Humanoid)
	Humanoid.JumpPower = 0
	
	wait(0.2)
	
	ThrustPart.Anchored = false
	
	self.CharAnimTracks.Fly:Play()

	--Humanoid.Sit = true
	Camera.CameraSubject = self.Focus
	Camera.CameraType = Enum.CameraType.Track
	
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

function Appa:End()
	print(self, "[APPA] End")
	
	Flying = false
	--_G.Flying = false
	
	-- Resetup to original
	Camera.CameraSubject = Character
	Camera.CameraType = Enum.CameraType.Custom
	Camera.FieldOfView = DefaultCameraFOV.Value
	player.CameraMinZoomDistance = DefaultCameraMinDist.Value
	player.CameraMaxZoomDistance = 15
	task.defer(function()
		player.CameraMaxZoomDistance = DefaultCameraMaxDist.Value
	end)
	
	self.Engine = nil
	
	self.CharAnimTracks.Fly:Stop()
	self.AppaAnimTracks.Fly:Stop()
	
	self.AppaAnimTracks.Fly:Destroy()
	self.CharAnimTracks.Fly:Destroy()

	Humanoid.Sit = false
	Humanoid.JumpPower = JumpPower
	Humanoid.Jump = true
	--self.Proximity.Enabled = true
	
	for i, v in pairs({FlyingGyro, FlyingForce}) do
		if v and v.Parent then
			Debris:AddItem(v, 0)
		end
	end
	
	--PlayerController:ToggleControls(true)
	--CharacterController:ToggleControls(true)
	
	self.Focus.RotVelocity = Vector3.new(0,0,0)
	Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
end

local Conn = nil
function Appa:BindTouchEvent()

	-->>> Disconect Conn
	local function Disconnect(conn)
		if conn then
			conn:Disconnect()
		end
	end
	Disconnect(Conn)

	---- Glider Triger
	local Trigger = self.Instance:WaitForChild("Handle")
	local Filter = {Character, self.Instance}

	--print("[NALU] Touch EVENT BINDED! ")
	---- Binding touch connection
	Conn = Trigger.Touched:Connect(function(part)
		for _, Exception in pairs(Filter) do
			if not part:IsDescendantOf(Exception) and part.Name ~= "Trigger" then
				--print("Touched with ", part)
				Disconnect(Conn)
				---- Fire Event for DeSpawning Glider
				--print("[NALU] DeSpawning Vehicle ", self.Instance)
				local name = self.Instance.Name or "Nalu"
				TransportService.DeSpawnVehicle:Fire(name)
			end
		end
	end)

end

----------------------***************** Public Methods **********************----------------------

function Appa:Start()
	warn(self," [NALU] Starting...")
	
	_G.Flying = Constants.VehiclesType.Appa
	
	---- Setup Service Ref.
	TransportService = Knit.GetService("TransportService")
	CoolDownGui = UIController:GetGui(Constants.UiScreenTags.CoolDownGui, 5)

	self.Seat = self.Instance:WaitForChild('Seat')
	self.Focus = self.Instance:WaitForChild("Focus")
	self.Handle = self.Instance:WaitForChild("Handle")
	self.RiderAnimator = Character:WaitForChild'Humanoid'.Animator
	self.Animator = self.Instance:WaitForChild'AnimationController'.Animator
	self.SpeedValue = script.Configuration.Speed

	setupProximity(self)

	self.AppaAnimTracks = {}
	for _, Animation in pairs(Animations.Appa) do
		self.AppaAnimTracks[Animation.Name] = self.Animator:LoadAnimation(Animation)
	end
	
	self.CharAnimTracks = {}
	for _, Animation in pairs(Animations.Character) do
		self.CharAnimTracks[Animation.Name] = self.RiderAnimator:LoadAnimation(Animation)
	end
	
	ThrustPart = self.Focus
	
	task.delay(.35, function()
		if not Flying then
			ThrustPart.Anchored = true	
		end
	end)
	
	task.delay(10, function()
		-- Player Not Sitting on NALU, will Despawn Automatically...
		if not Flying then
			local name = self.Instance.Name or "Nalu"
			TransportService.DeSpawnVehicle:Fire(name)
		end
	end)

	warn(self," [NALU] ALL DONE")
end

function Appa:Stop()
	CoolDownGui:StartCoolDown(Costs.VehicleCoolDown, Constants.Items.Appa.Name)
	delay(Costs.VehicleCoolDown, function()
		_G.Flying = nil
	end)
	
	if Flying then
		LandingAnimation(self)
		PlayerController:ToggleControls(true)
		CharacterController:ToggleControls(true)
	end
	
	self:End()
	
end

function Appa:HeartbeatUpdate(dt)
	
	if self.Engine then
		
		Speed = self.SpeedValue.Value
		
		self.Engine(dt)
		
		local speed = math.clamp(Yaxis, 0.05, 1)
		self.AppaAnimTracks.Fly:AdjustSpeed(speed)
	end
	
end

return Appa
-- @ScriptType: ModuleScript
local Momo = {}

local RunS = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local CT = require(RS.Modules.Custom.CustomTypes)
local Constants = require(RS.Modules.Custom.Constants)
local CF = require(RS.Modules.Custom.CommonFunctions)
local SwimController = require(RS.Modules.Packages.SwimController)

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local player = game.Players.LocalPlayer
local Momo = Component.new({Tag = player.UserId.."Momo", Ancestors = {workspace}})

local MAX_TELEPORT_DIST = 80
local ORBIT_SPEED = 0.3

function Momo:UpdateState()
	self.State.Changed:Connect(function(value)
		self.State.ReplicateState:FireServer(value)
	end)
end

function Momo:Setup()
	-- animations
	local Animations = script.Animations
	local walk = Animations.Walk
	local jump = Animations.Jump
	local idle = Animations.Idle

	---- Load Animations
	self.AnimationTrack = {}

	self.AnimationTrack.Walk = self.Hum:LoadAnimation(walk)
	self.AnimationTrack.Jump = self.Hum:LoadAnimation(jump)
	self.AnimationTrack.Idle = self.Hum:LoadAnimation(idle)

	self.currentAnim = nil
end

function Momo:PlayAnim(animName: string)
	if self.currentAnim == animName then
		return
	end
	-- Stop current animation
	if self.currentAnim and self.AnimationTrack and self.AnimationTrack[self.currentAnim] then
		self.AnimationTrack[self.currentAnim]:Stop()
	end
	-- Play new animation
	self.currentAnim = animName
	if self.AnimationTrack and self.AnimationTrack[animName] then
		self.AnimationTrack[animName]:Play()
	end
end

function Momo:Despawn()
	if self.Body.Transparency == 0 then
		self.Body.Transparency = 1
		self.Smoke:Emit(10)
		self.State.Value = "Hide"
		-- Stop animation while hidden
		if self.currentAnim and self.AnimationTrack and self.AnimationTrack[self.currentAnim] then
			self.AnimationTrack[self.currentAnim]:Stop()
		end
		self.currentAnim = nil
	end
end

function Momo:Spawn()
	if self.Body.Transparency == 1 then
		self.Body.Transparency = 0
		self.Smoke:Emit(10)
		self.State.Value = "Show"
		-- Restart idle animation
		self:PlayAnim("Idle")
	end
end

function Momo:Follow()
	local circleRadius = 10
	local baseHeight = 2.5

	local targetCircleRadius = 15
	local minRadius = 10
	local maxRadius = 20
	local radiusChangeSpeed = 0.05
	local radiusChangeInterval = 3
	local timeSinceLastChange = 0

	self:Spawn()

	local function Lerp(num, goal, i)
		return num + (goal-num)*i
	end

	local Target
	RunS:BindToRenderStep("PetFollow", Enum.RenderPriority.Character.Value, function(dt)
		if player.Character then
			Target = player.Character.PrimaryPart
		end

		if not Target then
			return
		end

		-- Despawn during flight or swimming, respawn on ground
		if _G.Flying then
			self:Despawn()
			return
		end
		if SwimController.Swimming then
			self:Despawn()
			return
		end
		self:Spawn()

		timeSinceLastChange = timeSinceLastChange + dt

		-- Smoothly adjust circle radius towards target
		circleRadius = Lerp(circleRadius, targetCircleRadius, radiusChangeSpeed)

		-- Change the target radius at intervals
		if timeSinceLastChange >= radiusChangeInterval then
			targetCircleRadius = math.random(minRadius, maxRadius)
			timeSinceLastChange = 0
		end

		-- Circular orbit using tick()
		local angle = tick() * ORBIT_SPEED
		local offsetPos = CFrame.Angles(0, angle, 0) * Vector3.new(circleRadius, 0, 0)
		local targetPos = Target.Position + offsetPos

		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {self.Instance, player.Character}

		-- Ground Raycast to keep pet grounded
		local groundRayResult = workspace:Raycast(targetPos + Vector3.new(0, 5, 0), Vector3.new(0, -30, 0), rayParams)

		if groundRayResult then
			targetPos = Vector3.new(targetPos.X, groundRayResult.Position.Y + baseHeight, targetPos.Z)
		end

		-- Distance-based teleport if pet strays too far
		local dist = (self.Body.Position - Target.Position).Magnitude
		if dist > MAX_TELEPORT_DIST then
			local behind = Target.Position - Target.CFrame.LookVector * 5 + Vector3.new(0, baseHeight, 0)
			self.Body.CFrame = CFrame.new(behind)
		end

		-- Move the pet smoothly to the target position
		self.Body.BodyPosition.Position = targetPos

		-- Rotate the pet to face the player
		local lookVector = (not _G.Flying or _G.Flying == Constants.VehiclesType.Appa) and Target.CFrame.LookVector or Target.CFrame.UpVector
		self.Body.BodyGyro.CFrame = CFrame.lookAlong(self.Body.Position, lookVector)

		-- Animation state machine
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then
			local state = humanoid:GetState()
			if state == Enum.HumanoidStateType.Jumping or state == Enum.HumanoidStateType.Freefall then
				self:PlayAnim("Jump")
			elseif humanoid.MoveDirection.Magnitude > 0.1 then
				self:PlayAnim("Walk")
			else
				self:PlayAnim("Idle")
			end
		end
	end)
end

function Momo:Start()
	local Pet = self.Instance

	-- Nil-guard PrimaryPart
	if not Pet.PrimaryPart then
		warn("[Momo] PrimaryPart missing on pet instance, aborting")
		return
	end

	self.Hum = Pet:WaitForChild("Humanoid")
	self.State = Pet.State
	self.Body = Pet.PrimaryPart
	self.Smoke = Pet.PrimaryPart.Smoke

	self:Setup()
	self:PlayAnim("Idle")
	self:Follow()
	self:UpdateState()
end

function Momo:Stop()
	RunS:UnbindFromRenderStep("PetFollow")
	-- Stop all animation tracks and clean up
	if self.AnimationTrack then
		for _, track in pairs(self.AnimationTrack) do
			track:Stop()
		end
		self.AnimationTrack = nil
	end
	self.currentAnim = nil
end

return Momo

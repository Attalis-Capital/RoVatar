-- @ScriptType: ModuleScript
local module = {}
local Players = game:GetService("Players")

local a0 = Instance.new("Attachment")
local s0 = Instance.new("BallSocketConstraint")
local nc = Instance.new("NoCollisionConstraint")

------------------------------------ >>>>>>>>. Setup Rogdoll methods .<<<<<<< ----------------------------------
local SOCKET_SETTINGS_R15 = {
	head = {MaxFrictionTorque = 150, UpperAngle = 15, TwistLowerAngle = -15, TwistUpperAngle = 15}, 
	upperTorso = {MaxFrictionTorque = 50, UpperAngle = 20, TwistLowerAngle = -10, TwistUpperAngle = 30},  
	lowerTorso = {MaxFrictionTorque = 50, UpperAngle = 20, TwistLowerAngle = 0, TwistUpperAngle = 30},  
	upperArms = {MaxFrictionTorque = 150, UpperAngle = 90, TwistLowerAngle = -45, TwistUpperAngle = 45},  
	lowerArms = {MaxFrictionTorque = 150, UpperAngle = 0, TwistLowerAngle = -5, TwistUpperAngle = 65},  
	upperLegs = {MaxFrictionTorque = 150, UpperAngle = 40, TwistLowerAngle = -5, TwistUpperAngle = 20},  
	lowerLegs = {MaxFrictionTorque = 150, UpperAngle = 0, TwistLowerAngle = -45, TwistUpperAngle = 10},  
	handsFeets = {MaxFrictionTorque = 50, UpperAngle = 10, TwistLowerAngle = -45, TwistUpperAngle = 25},  
}

local function limbManager(limbName)
	local rigUpperArms = {"RightUpperArm", "LeftUpperArm"}
	local rigLowerArms = {"RightLowerArm", "LeftLowerArm"}
	local rigUpperLegs = {"RightUpperLeg", "LeftUpperLeg"}
	local rigLowerLegs = {"RightLowerLeg", "LeftLowerLeg"}
	local rigHandsFeets = {"RightHand", "LeftHand", "RightFoot", "LeftFoot"}
	if limbName == "Head" then 
		return "head"
	elseif limbName == "UpperTorso" then 
		return "upperTorso"
	elseif limbName == "LowerTorso" then 
		return "lowerTorso"
	elseif table.find(rigUpperArms, limbName) then
		return "upperArms"
	elseif table.find(rigLowerArms, limbName) then
		return "lowerArms"
	elseif table.find(rigUpperLegs, limbName) then
		return "upperLegs"
	elseif table.find(rigLowerLegs, limbName) then
		return "lowerLegs"
	elseif table.find(rigHandsFeets, limbName) then
		return "handsFeets"
	else 
		return nil
	end
end

local function noCollideR15(character) 
	local nc1 = nc:Clone()
	local nc2 = nc:Clone()
	local nc3 = nc:Clone()
	local nc4 = nc:Clone()
	local nc5 = nc:Clone()
	local nc6 = nc:Clone()
	local nc7 = nc:Clone()
	local nc8 = nc:Clone()

	nc1.Part0 = character.RightFoot
	nc1.Part1 = character.RightUpperLeg
	nc1.Parent = character.RightUpperLeg

	nc2.Part0 = character.RightUpperLeg
	nc2.Part1 = character.UpperTorso
	nc2.Parent = character.UpperTorso

	nc3.Part0 = character.RightLowerLeg
	nc3.Part1 = character.UpperTorso
	nc3.Parent = character.UpperTorso

	nc4.Part0 = character.LeftFoot
	nc4.Part1 = character.LeftUpperLeg
	nc4.Parent = character.LeftUpperLeg

	nc5.Part0 = character.LeftUpperLeg
	nc5.Part1 = character.UpperTorso
	nc5.Parent = character.UpperTorso

	nc6.Part0 = character.LeftLowerLeg
	nc6.Part1 = character.UpperTorso
	nc6.Parent = character.UpperTorso

	nc7.Part0 = character.LeftHand
	nc7.Part1 = character.LeftUpperArm
	nc7.Parent = character.LeftHand

	nc8.Part0 = character.RightHand
	nc8.Part1 = character.RightUpperArm
	nc8.Parent = character.RightHand
end

----------------------------------- >>>>>>>>. Ragdoll Builder .<<<<<<< ---------------------------------------
local RagdollCounterSys = script.Configuration
local lDModeOn

local function ragdollMe(character)	
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.AutoRotate = false	
	character.HumanoidRootPart.CollisionGroup = "Body"
	character.HumanoidRootPart.CanCollide = false

	if RagdollCounterSys.charactersDied.Value >= RagdollCounterSys.charactersDiedMax.Value then
		task.wait(0.1 * RagdollCounterSys.charactersDied.Value)
	end

	if RagdollCounterSys.ragdollsLdEnable.Value == true then 
		if character.UpperTorso then
			for i,motor6d in pairs(character.UpperTorso:GetChildren()) do
				if motor6d:IsA("Motor6D") then	
					motor6d.Parent.CollisionGroup = "Body"
					motor6d.Parent.CanTouch = false
					motor6d:Destroy()
				end	
			end		
		end

		if character.LeftFoot then
			for i,motor6d in pairs(character.LeftFoot:GetChildren()) do
				if motor6d:IsA("Motor6D") then	
					motor6d.Parent.CollisionGroup = "Body"
					motor6d.Parent.CanTouch = true
					motor6d:Destroy()
				end	
			end		
		end

		if character.RightFoot then
			for i,motor6d in pairs(character.RightFoot:GetChildren()) do
				if motor6d:IsA("Motor6D") then	
					motor6d.Parent.CollisionGroup = "Body"
					motor6d.Parent.CanTouch = true
					motor6d:Destroy()
				end	
			end		
		end

		if character.Head then
			for i,motor6d in pairs(character.Head:GetChildren()) do
				if motor6d:IsA("Motor6D") then	--Getting motor6D joints as joints. Their parents are the parts. 
					motor6d.Parent.CollisionGroup = "Body"
					motor6d.Parent.CanTouch = true
					motor6d:Destroy()
				end	
			end		
		end
	else --If LD mode is off
		RagdollCounterSys.ragdollsExisted.Value += 1
		for i,limbs in pairs(character:GetChildren()) do
			for i,motor6d in pairs(limbs:GetChildren()) do
				if motor6d:IsA("Motor6D") then	--Getting motor6D joints as joints. Their parents are the parts. 
					motor6d.Parent.CollisionGroup = "Body"
					--print("Rookstun ", motor6d.Parent.CollisionGroup, " ", motor6d.Parent.CollisionGroupId, " ", motor6d.Parent)
					motor6d.Parent.CanCollide = true
					motor6d:Destroy()
				end	
			end
		end
	end
end

local function activateVelocity(character)
	character.HumanoidRootPart.AngularVelocity.Enabled = true
	character.HumanoidRootPart.LinearVelocity.Enabled = true
	if character:FindFirstChild("LeftUpperLeg") and character:FindFirstChild("RightUpperLeg") then
		character.LeftUpperLeg.AngularVelocity.Enabled = true
		character.RightUpperLeg.AngularVelocity.Enabled = true
	end
	
	task.spawn(function()	
		if character:FindFirstChild("DamageBy") then
			local Killer = character.DamageBy.Value
			print("Killer Found ")
			if Killer then
				print("Killer Damage ")
				local BV = Instance.new("BodyVelocity")
				BV.MaxForce, BV.Velocity = Vector3.new(5e4, 5e2, 5e4), Killer.HumanoidRootPart.CFrame.lookVector * 50
				BV.Parent = character.HumanoidRootPart
				game.Debris:AddItem(BV, 0.1)
			end
		end
	end)
	
end

local function deactivateVelocity(character)
	character.HumanoidRootPart.AngularVelocity.Enabled = false
	character.HumanoidRootPart.LinearVelocity.Enabled = false
	if character:FindFirstChild("LeftUpperLeg") and character:FindFirstChild("RightUpperLeg") then
		character.LeftUpperLeg.AngularVelocity.Enabled = false
		character.RightUpperLeg.AngularVelocity.Enabled = false
	end
end

local function ragdollFreeze(character, state)
	if character and RagdollCounterSys.ragdollFreezeEnable.Value and state == Enum.HumanoidStateType.Dead then
		local upperTorso = character:WaitForChild("UpperTorso")
		repeat 
			local lastPos = upperTorso.Position
			wait(RagdollCounterSys.ragdollFreezeTime.Value) --Time left before it checks body.
			local newPos = upperTorso.Position
			local distanceDiff = (lastPos - newPos).magnitude 		--print("DistanceDiff", distanceDiff)
		until distanceDiff < 2 		--Distance a body must be close from its original check to be anchored

		for i,v in pairs(character:GetChildren()) do
			if v:IsA("MeshPart") then
				v.Anchored = true
			end
		end
		local Root = character:FindFirstChild("HumanoidRootPart")
		if Root then
			Root.Anchored = true
		end
	end
	if RagdollCounterSys.ragdollsExisted.Value ~= 0  then
		RagdollCounterSys.ragdollsExisted.Value -= 1
	end
end

local function resyncClothes(character)
	for i,v in pairs(character:GetChildren()) do --Hack. Refreshes and resyncs layered clothing.
		if v:IsA("Accessory") then
			for i2,v2 in pairs(v.Handle:GetChildren()) do 
				if v2:IsA("WrapLayer") then
					local refWT = Instance.new("WrapTarget")
					refWT.Parent = v2.Parent
					refWT:Destroy()
					refWT.Parent = nil
				end
			end
		end
	end
end

local function stopAnims(humanoid)
	local AnimTrack = humanoid:GetPlayingAnimationTracks()
	for i, track in pairs (AnimTrack) do
		track:Stop()
	end
end

------------------------------------------- >>>>>>>>. Public methods .<<<<<<<< -----------------------------------------
function module:Setup(character)
	
	character.Humanoid.AutomaticScalingEnabled = false
	character.Humanoid.BreakJointsOnDeath = false
	character.HumanoidRootPart.CanCollide = false
	character.HumanoidRootPart.CustomPhysicalProperties = PhysicalProperties.new(0.0001,0,0,0,0)
	character.HumanoidRootPart.CollisionGroup = "Players"
	--print(character.Name)
	--print(character.HumanoidRootPart.CollisionGroup)

	local lv = Instance.new("LinearVelocity")
	lv.Attachment0 = character.HumanoidRootPart.RootRigAttachment
	lv.VectorVelocity = Vector3.new(0,50,-8000) --At least any must be >0 to wake physics
	lv.MaxForce = 8000
	lv.RelativeTo = "Attachment0"
	lv.Parent = character.HumanoidRootPart
	lv.Enabled = false

	local av = Instance.new("AngularVelocity")
	av.Attachment0 = character.LeftUpperLeg.LeftKneeRigAttachment
	av.AngularVelocity = Vector3.new(0,10,0) 
	av.MaxTorque = 1000
	av.RelativeTo = "Attachment0"
	av.ReactionTorqueEnabled = false
	av.Parent = character.LeftUpperLeg
	av.Enabled = false

	local av2 = Instance.new("AngularVelocity")
	av2.Attachment0 = character.RightUpperLeg.RightKneeRigAttachment
	av2.AngularVelocity = Vector3.new(0,10,0) 
	av2.MaxTorque = 1000
	av2.RelativeTo = "Attachment0"
	av2.ReactionTorqueEnabled = false
	av2.Parent = character.RightUpperLeg
	av2.Enabled = false

	local av3 = Instance.new("AngularVelocity")
	av3.Attachment0 = character.HumanoidRootPart.RootRigAttachment
	av3.AngularVelocity = Vector3.new(0,math.random(-10,10),math.random(-10,10)) 
	av3.MaxTorque = 2000
	av3.RelativeTo = "Attachment0"
	av3.ReactionTorqueEnabled = false
	av3.Parent = character.HumanoidRootPart
	av3.Enabled = false

	for i,limb in pairs(character:GetDescendants()) do
		if limb:IsA("Accessory") then
			limb.Handle.CanCollide = false
			limb.Handle.CollisionGroup = "Players"
			limb.Handle.CanTouch = false
			limb.Handle.Massless = true
		end

		local motor6d = limb
		if motor6d:IsA("Motor6D") then	

			local nc0 = nc:Clone()
			local socket = s0:Clone()
			local a1 = a0:Clone()
			local a2 = a0:Clone()

			a1.Parent = motor6d.Part0
			a2.Parent = motor6d.Part1
			a1.CFrame = motor6d.C0
			a2.CFrame = motor6d.C1

			motor6d.Parent.CollisionGroup = "Players"
			motor6d.Parent.CustomPhysicalProperties = PhysicalProperties.new(5,0.7,0.5,100,100)
			nc0.Part0 = motor6d.Part0
			nc0.Part1 = motor6d.Part1
			nc0.Parent = motor6d.Parent

			socket.Attachment0 = a1
			socket.Attachment1 = a2
			socket.LimitsEnabled = true
			socket.TwistLimitsEnabled = true
			socket.Parent = motor6d.Parent

			local limbMgr = limbManager(motor6d.Parent.Name)
			if limbMgr ~= nil then

				local limbDir = SOCKET_SETTINGS_R15[limbMgr]
				for key,value in pairs (limbDir) do
					if socket[key] then
						socket[key] = value
					end
				end
			end
		end

	end
	
	noCollideR15(character)
end

function module:Ragdoll(char)
	stopAnims(char.Humanoid)
	activateVelocity(char)
	ragdollMe(char)
	resyncClothes(char)
	task.wait() --Without this physics may not activate on platformstand
	deactivateVelocity(char)
	ragdollFreeze(char, char.Humanoid:GetState())
end

function module:Unragdoll(char)
	
end

return module
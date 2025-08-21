-- @ScriptType: ModuleScript
local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local CS = game:GetService("CollectionService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local Helper = require(script.Helper)
local CF = require(RS.Modules.Custom.CommonFunctions)
local NPCModule = require(RS.Assets.Scripts.NPCModule)
local Constants = require(RS.Modules.Custom.Constants)

local NPCAI = Component.new({Tag = "NPCAI"})
print("[Setup NPC] Tags ", NPCAI)
----Elements
local ActionStates = {
	["Idle"] = "Idle", --Means no worries, keep following own path
	["Chasing"] = "Chasing",
	["Attacking"] = "Attacking",
	["Blocking"] = "Blocking",
	["Knocked"] = "Knocked",
}

local Accuracies = {
	[1] = "Low",
	[2] = "Medium",
	[3] = "High",
	[4] = "Precise",
}

local Level_Colors = {
	[1] = Color3.fromRGB(141, 204, 136),
	[2] = Color3.fromRGB(219, 215, 123),
	[3] = Color3.fromRGB(222, 150, 124),
	[4] = Color3.fromRGB(215, 79, 98),
}

--- Templates 
local Templates = script.Templates
local InfoGuiT = Templates.InfoGui
local BlockBarGuiT = Templates.BlockBar

---- Configurations
local RespawnTime = 5
local MinAttackDistance = 4
------ Other Services
local QuestDataService = Knit.GetService("QuestDataService")
local PlayerDataService = Knit.GetService("PlayerDataService")
--------------------------------------->>>>. Data Manage and Update .<<<<----------------------------------------
local function __updateKills(self)
	local DamageBy = self.Instance:FindFirstChild('DamageBy')
	if DamageBy then
		----
		local Attacker = DamageBy.Value
		print("[Quest] Attacker ", Attacker)
		if Attacker then
			local player = Players:GetPlayerFromCharacter(Attacker)
			if player then
				PlayerDataService:UpdateKills(player)
				QuestDataService.UpdateQuest:Fire(player, Constants.QuestObjectives.Kill, self.Type)
				QuestDataService.UpdateQuest:Fire(player, Constants.QuestObjectives.Combined, self.Type)
			end
		else
			warn("[Last Attacker] not found!")
		end
	else
		warn("[Damage By] not found!")
	end
end


local function __updateDeaths(Player :Player)
	if not Player then 
		warn("[Player Not found! ]")
		return 
	end

	PlayerDataService:UpdateDeath(Player)
end


local function _onDied(self)
	local character = self.Instance
	print("[Character] NPC Died", character)

	NPCModule.BloodFX(character)
	__updateKills(self)
	__updateDeaths(Players:GetPlayerFromCharacter(character))

end
--------------------------------------->>>>. Data Manage and Update .<<<<----------------------------------------


---------------------------------------->>>>. Local Common methods .<<<<-----------------------------------------
function NPCAI:SetupBlocking()
	local isBlocking = self.Instance.isBlocking

	local PreBlock = self.Humanoid:LoadAnimation(script.Templates.Animations.PreBlock)
	local BlockingIdle = self.Humanoid:LoadAnimation(script.Templates.Animations.BlockingIdle)

	self.IsBlockBroken = false
	self.BlockConn = isBlocking.Changed:Connect(function()
		if isBlocking.Value then

			PreBlock:Play()
			BlockingIdle:Play()

			local blockBar = Instance.new("IntValue")
			blockBar.Name = "BlockBar"

			blockBar.Value = self.blockHealth
			blockBar.Parent = self.Instance

			self.Humanoid.WalkSpeed = 8
			self.Humanoid.JumpPower = 20

			CS:AddTag(self.Instance, "Perfect Block")
			task.delay(0.2, function()
				CS:RemoveTag(self.Instance, "Perfect Block")
			end)
			
			self.BlockBarGui.Enabled = true
			self.BlockBarGui.Bar.Meter.Size = UDim2.fromScale(1, 1)
			
			self.blockBarConn = blockBar.Changed:Connect(function(newValue)
				local healthChange = newValue/self.blockHealth
				self.BlockBarGui.Bar.Meter:TweenSize(UDim2.new(healthChange,0,1,0),Enum.EasingDirection.Out,Enum.EasingStyle.Back,.25, true)
				
				if newValue <= 0 and not self.IsBlockBroken then
					self.IsBlockBroken = true
					self.BlockBarGui.Enabled = false
					NPCModule.Block(self.Instance)

					blockBar:Destroy()
					PreBlock:Stop()		
					BlockingIdle:Stop()
					self:ToggleBlock(false)

					task.delay(1.5, function()
						self.IsBlockBroken = false
						self.Humanoid.WalkSpeed = 16
						self.Humanoid.JumpPower = 50
					end)
				end
			end)

		else
			PreBlock:Stop()
			BlockingIdle:Stop()

			self.blockBarConn:Disconnect()
			self.BlockBarGui.Enabled = false
			local blockBar = self.Instance:FindFirstChild("BlockBar")
			if blockBar then blockBar:Destroy() end
			if not self.IsBlockBroken then
				self.Humanoid.WalkSpeed = 16
				self.Humanoid.JumpPower = 50
			end
		end
		
		self.InfoGui.Enabled = not self.BlockBarGui.Enabled
	end)
end

function NPCAI:ToggleBlock(enable)
	if enable then
		if (not self.IsBlockBroken) and 
			(not self.Instance:FindFirstChild("RagdollConstraints")) and 
			(not self.Instance:FindFirstChild("Ragdoll")) then
			
			self.Instance.isBlocking.Value = true
		end
	else 
		self.Instance.isBlocking.Value = false
	end
end

local function Disconnect(Conn)
	if Conn then
		Conn:Disconnect()
	end
end

local function StopMoving(self)
	if self.Instance then
		self.Humanoid:MoveTo(self.Root.Position)
	end
end


---------------------------------------->>>>. Specific Instance methods .<<<<-----------------------------------------
-- Regenerates health every frame based on delta time
function NPCAI:HealthRegenationUpdate(dt)
	local REGEN_RATE = 1 / 100 -- Regenerate this fraction of MaxHealth per second
	local Humanoid = self.Humanoid
	if not Humanoid then return end

	if Humanoid.Health < Humanoid.MaxHealth then
		local regenAmount = dt * REGEN_RATE * Humanoid.MaxHealth
		Humanoid.Health = math.min(Humanoid.Health + regenAmount, Humanoid.MaxHealth)
	end
end

function NPCAI:DestroyNPC()
	Disconnect(self.TargetDied)
	Disconnect(self.RunConn)
	StopMoving(self)

	self.Instance:Destroy()
end

function NPCAI:SetupObjects()
	local Parent = self.Instance

	-- Air
	local Air = Instance.new("BoolValue", Parent)
	Air.Name = "Air"
	Air.Value = false

	---- BlockBar
	--local BlockBar = Instance.new('IntValue', Parent)
	--BlockBar.Name  = "BlockBar"
	--BlockBar.Value = 100

	-- BlockTime
	local BlockTime = Instance.new("BoolValue", Parent)
	BlockTime.Name = "BlockTime"
	BlockTime.Value = false

	-- Combo 
	local Combo = Instance.new("IntValue", Parent)
	Combo.Name = "Combo"
	Combo.Value = 1

	-- DC
	local DC = Instance.new("IntValue", Parent)
	DC.Name = "DC"
	DC.Value = 0

	-- Status
	local Status = Instance.new("IntValue", Parent)
	Status.Name = "Status"
	Status.Value = 0

	-- Idle 
	local Idle = Instance.new("BoolValue", Parent)
	Idle.Name = "Idle"
	Idle.Value = true

	-- IsAttacking
	local IsAttacking = Instance.new("BoolValue", Parent)
	IsAttacking.Name = "IsAttacking"
	IsAttacking.Value = false

	-- Knocked
	local Knocked = Instance.new("BoolValue", Parent)
	Knocked.Name = "Knocked"
	Knocked.Value = false

	-- PBTime
	local PBTime = Instance.new("BoolValue", Parent)
	PBTime.Name = "PBTime"
	PBTime.Value = false

	-- Target
	local Target = Instance.new("StringValue", Parent)
	Target.Name = "Target"
	Target.Value = "None"

	-- canAttack
	local canAttack = Instance.new("BoolValue", Parent)
	canAttack.Name = 'canAttack'
	canAttack.Value = true

	-- canHit
	local canHit = Instance.new("BoolValue", Parent)
	canHit.Name = 'canHit'
	canHit.Value = true

	-- iFrames
	local iFrames = Instance.new("BoolValue", Parent)
	iFrames.Name = 'iFrames'
	iFrames.Value = false

	-- canHit
	local isBlocking = Instance.new("BoolValue", Parent)
	isBlocking.Name = 'isBlocking'
	isBlocking.Value = false

	-- Spawning Health Gui 
	if not Parent.Head:FindFirstChild("InfoGui") then
		local InfoGui = InfoGuiT:Clone()
		InfoGui.Parent = Parent.Head
		InfoGui.Adornee = Parent.Head
	end
	
	-- Spawning Block bar Gui 
	if not Parent.UpperTorso:FindFirstChild("BlockBar") then
		local BlockBar = BlockBarGuiT:Clone()
		BlockBar.Parent = Parent.UpperTorso
		
		self.BlockBarGui = BlockBar.Gui
	end

	
	-- Updating Animation Script
	--[[
		* [Clear if Already Exists]
		-- Less probability to found 
	]]	
	local AnimateS = Parent:FindFirstChild("Animate")
	if AnimateS then
		AnimateS:Destroy()
	end

	--[[
		* [Re-Cloning the Animate Script]
	]]
	local Animate = Templates.Animate:Clone()
	Animate.Parent = Parent
	Animate.Enabled = true

end

function NPCAI:Setup()
	--Setup Ragdoll Tags
	self.Instance.ChildAdded:Connect(function(child)
		if child.Name == "Ragdoll" then
			if not CS:HasTag(self.Instance, "Ragdoll") then
				CS:AddTag(self.Instance, "Ragdoll")
			end
		elseif child.Name == "onFire" then
			if not CS:HasTag(self.Instance, "onFire") then
				CS:AddTag(self.Instance, "onFire")
			end
		elseif child.Name == "Disabled" then
			self.Humanoid.WalkSpeed = 0
			self.Humanoid.JumpPower = 0
		end
	end)

	self.Instance.ChildRemoved:Connect(function(child)
		if child.Name == "Ragdoll" then
			if CS:HasTag(self.Instance, "Ragdoll") then
				CS:RemoveTag(self.Instance, "Ragdoll")
			end
		elseif child.Name == "onFire" then
			if CS:HasTag(self.Instance, "onFire") then
				CS:RemoveTag(self.Instance, "onFire")
			end
		elseif child.Name == "Disabled" then
			if not self.Instance:FindFirstChild("Disabled") then
				self.Humanoid.WalkSpeed = 14
				self.Humanoid.JumpPower = 50
			end
		end
	end)

	--Setup OverHead GUI
	self.BlockDelayThread = nil
	self.DamageDelayThread = nil
	local lastHealth = self.Humanoid.Health

	self.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		local healthChange = self.Humanoid.Health/self.Humanoid.MaxHealth
		local healthColor = Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(60,255,0),healthChange)
		if self.Humanoid.Health <= 0 then
			self.InfoGui.Base.Health.Meter:TweenSize(UDim2.new(healthChange,0,1,0),"In","Linear",1)
			task.delay(.2, function()
				self.InfoGui.Base.Health.Meter.BackgroundTransparency = 1
			end)
		else
			self.InfoGui.Base.Health.Meter:TweenSize(UDim2.new(healthChange,0,1,0),"In","Linear",1)
		end
		self.InfoGui.Base.Health.Meter.BackgroundColor3 = healthColor

		if self.Humanoid.Health < lastHealth then

			lastHealth = self.Humanoid.Health
			self.RecentDamage = true
			if self.DamageDelayThread then task.cancel(self.DamageDelayThread) end
			self.DamageDelayThread = task.delay(.5, function()
				self.RecentDamage = false
			end)

			if not self.Target then
				-- if someone is not in Trigger Zone
				self:ToggleBlock(true)

				if self.BlockDelayThread then task.cancel(self.BlockDelayThread) end
				self.BlockDelayThread = task.delay(3, function()
					self:ToggleBlock(false)
				end)
			end

		end
	end)

	self.DiedConn = nil
	local isBlocking = self.Instance.isBlocking
	self.DiedConn = self.Humanoid.Died:Connect(function()
		print("Died Event ",self.Instance, self.Humanoid.Health)
		self.DiedConn:Disconnect()
		_onDied(self)
		
		if isBlocking.Value then
			isBlocking.Value = false
			 self.BlockBarGui.Enabled = false
		end
		
		NPCModule.Ragdoll(self.Instance) -- will wait for ragdollFreezeTime - 2sec
		NPCModule.Respawn(self.Instance, RespawnTime, self.OriginCF)
		self:DestroyNPC()

	end)

	self.InfoGui.Base.Info.LevelLabel.Text = self.Level
	self.InfoGui.Base.Info.LevelLabelShadow.Text = self.Level
	self.InfoGui.Base.Info.NameLabel.Text = Constants.NPCsType[self.Type] or " "
	self.InfoGui.Base.Info.NameLabelShadow.Text = Constants.NPCsType[self.Type] or " "
	self.InfoGui.Base.Info.LevelLabelShadow.BackgroundColor3 = Level_Colors[self.Level]
	
	self.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	self.Humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
	
	NPCModule.Setup(self.Instance)
end

function NPCAI:Start()
	-- Setting UP all Object Values
	self:SetupObjects()
	
	---References
	self.Type = self.Instance:GetAttribute("Type") or "Dummy"
	self.Level = self.Instance:GetAttribute("Level") or 1
	self.Accuracy = Accuracies[self.Level]
	
	self.Root = self.Instance.PrimaryPart
	self.Humanoid = self.Instance.Humanoid
	self.InfoGui = self.Instance.Head.InfoGui
	self.PathPoints = self.Instance.PathPoints
	self.OriginCF = self.Root.CFrame
	self.Trigger = self.Instance.Area.Trigger
	
	---Setup Parameters
	self.blockHealth = math.clamp((self.Humanoid.MaxHealth / 4) * self.Level, self.Humanoid.MaxHealth * .4, self.Humanoid.MaxHealth)
	--self.blockHealth = math.clamp((self.Humanoid.MaxHealth / 4) * self.Level), 50, 100)

	self.TICK = tick()
	self.BLOCKTICK = tick()

	self.RecentDamage = false

	self:Setup()
	self:SetupBlocking()
	self:UpdateActionState(ActionStates.Idle)

	self:FollowPath()
	
	if self.Type ~= "FireBender_MiniBoss" then
		CF.PlayerData.RandomizeNPCAppearance(self.Instance)
	end

end

function NPCAI:Stop()
	print(self, 'Stop')
	--self:DestroyNPC()
end
------------------- NPC Actions ----------------------

function NPCAI:Idle()
	Disconnect(self.TargetDied)
	Disconnect(self.RunConn)
	StopMoving(self)
end

function NPCAI:Attack()
	if (self.Instance and not self.Instance:FindFirstChild("Ragdoll")) then
		local damage = Helper.GetDamageRange(self.TargetPlayerLevel)
		NPCModule.Attack(self.Instance, self.Humanoid, 'Combat', self.Accuracy, damage)
	end
end

--[[NPC Difficulty Based on

--Rate of Attack player level
--Damage Per punch player level
--Block Probabality player level

--Accuracy npc level

--Speed
--

]]

function NPCAI:Chasing(dt)
	local Target = self.Target
	
	
	local FinalPos = Target.HumanoidRootPart.Position
	local SelfPos = self.Root.Position
	local isBlocking = self.Instance.isBlocking
	FinalPos = Vector3.new(FinalPos.X, SelfPos.Y, FinalPos.Z)  -- Ensure NPC stays on the same vertical level

	local attackCoolDown = Helper.GetAttackCoolDown(self.TargetPlayerLevel)
	local blockCoolDown = Helper.GetBlockCoolDown(self.TargetPlayerLevel)

	local Distance = (FinalPos - SelfPos).Magnitude
	
	-- Check attack range
	if Distance < MinAttackDistance and self.TargetHumanoid.Health > 0 and not self.Target:FindFirstChild("Ragdoll") then
		if (tick() - self.TICK) > attackCoolDown then
			self.TICK = tick()

			-- Block if recently damaged and probability check passes (with cooldown of 5 seconds)
			if self.RecentDamage and math.random() <= self.BlockProbability and (tick() - self.BLOCKTICK) > blockCoolDown then
				self.BLOCKTICK = tick()
				self:ToggleBlock(true)
			end

			-- Attack only if not blocking
			if not isBlocking.Value then
				self:Attack()
			end
		end
	end
	
	-- Unblock if blocking time exceeds 3 seconds
	if isBlocking.Value and (tick() - self.BLOCKTICK) > blockCoolDown - 2 then
		self:ToggleBlock(false)
	end
	
	-- Move towards the target if not disabled or blocked
	if not self.Instance:FindFirstChild('Disabled') then
		-- If blocking, stand ground but rotate to face target
		if isBlocking.Value then
			self.Humanoid:MoveTo(self.Root.Position)  -- Stay in place while blocking
			self.Root.CFrame = CFrame.lookAt(self.Root.Position, FinalPos)
		else
			self.Humanoid:MoveTo(FinalPos)  -- Move towards the target
		end

		-- Always rotate to face the target, whether moving or blocking
	end
end

function NPCAI:FollowPath()

	self:UpdateActionState(ActionStates.Idle)

	Disconnect(self.TargetDied)
	Disconnect(self.RunConn)
	StopMoving(self) -- Stop Player from moving

	local path = self.PathPoints:GetChildren()

	local pathStage = 1
	self.RunConn = RunService.Heartbeat:Connect(function()
		if self.Humanoid.Health > 0 then
			if(self.ActionState == ActionStates.Idle) then
				local part :Part = path[pathStage]

				self.Humanoid:MoveTo(part.Position)
				local FinalPos = Vector3.new(part.Position.X, self.Root.Position.Y, part.Position.Z)
				local SelfPos = self.Root.Position

				local Distance = (FinalPos - SelfPos).Magnitude

				if Distance < 1 then
					if pathStage == #path then
						pathStage = 1
					else
						pathStage += 1
					end
				end

			end
		end
	end)

end

function NPCAI:UpdateActionState(newState:string)
	if(newState == ActionStates.Idle) then
		self.Humanoid.WalkSpeed = 12
	else
		self.Humanoid.WalkSpeed = 16
	end

	self.ActionState = newState
end

function NPCAI:HeartbeatUpdate(Delta:number)
	-- Get Target in Area
	local lastTarget = self.Target
	self.Target = Helper.GetTarget(self.Instance, self.Trigger, self.Root)
	
	if self.Target then
		-- Calling in loop
		if self.ActionState ~= ActionStates.Chasing then
			self:UpdateActionState(ActionStates.Chasing)
		end
		
		if lastTarget ~= self.Target then
			self.TargetHumanoid = self.Target.Humanoid
			self.TargetPlayerLevel = Helper.GetTargetPlayerLevel(self.Target)
			
			if self.Type == "FireBender_MiniBoss" then
				self.TargetPlayerLevel = math.clamp(self.TargetPlayerLevel, 50, 100)
			end
			
			self.BlockProbability = Helper.GetBlockProbability(self.TargetPlayerLevel)
		end
		
		self:Chasing()
	elseif self.ActionState ~= ActionStates.Idle then
		-- Call only one time
		self:FollowPath()
		if self.Instance.isBlocking.Value then
			self:ToggleBlock(false)
		end
	end
	
	--self:HealthRegenationUpdate()
	
end

return NPCAI
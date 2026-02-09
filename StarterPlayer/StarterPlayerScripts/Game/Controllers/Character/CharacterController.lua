-- @ScriptType: ModuleScript
local Debris = game:GetService("Debris")
local RunS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local RS = game:GetService("ReplicatedStorage")
local CAS = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local Knit = require(RS.Packages.Knit)

local Costs = require(RS.Modules.Custom.Costs)
local Constants = require(RS.Modules.Custom.Constants)
local VFXHandler = require(RS.Modules.Custom.VFXHandler)
local CF = require(RS.Modules.Custom.CommonFunctions)
local SFXHandler = require(RS.Modules.Custom.SFXHandler)
local CustomTypes = require(RS.Modules.Custom.CustomTypes)
local NotificationData = require(RS.Modules.Custom.NotificationData)
local AutoTarget = require(RS.Modules.Custom.AutoTarget)

local player :Player & CustomTypes.PlayerDataModel = game.Players.LocalPlayer
local Mouse = player:GetMouse()

local DefaultFOV = 70
---------> Other scripts
local CharacterService
local TransportService

local CoolDownGui
local PlayerMenuGui
local NotificationGui

local UiController
local InputController
local CameraController
local AnimationController

------ Controls KeysBinds
local CustomControls = {
	["Sprint"] = {
		actionName = "Sprint",
		keys = {Enum.KeyCode.LeftShift},
		touchButton = true,
		touch = {
			Image = "rbxassetid://15606592264",
			Text = "",
		},
	},

	["Fist"] = {
		actionName = "Fist",
		keys = {Enum.UserInputType.MouseButton1},
		touchButton = true,
		touch = {
			Image = "",
			Text = "Fist",
		},
	},
	["Block"] = {
		actionName = "Block",
		keys = {Enum.KeyCode.Q},
		touchButton = true,
		touch = {
			Image = "",
			Text = "Block",
		},
	},

	["AirBending"] = {
		actionName = "AirBending",
		keys = {Enum.KeyCode.One},
		touchButton = false, -- Handling Input on UI For mobile
		touch = {
			Image = "",
			Text = "",
		},
	},
	["FireBending"] = {
		actionName = "FireBending",
		keys = {Enum.KeyCode.Two},
		touchButton = false, -- Handling Input on UI For mobile
		touch = {
			Image = "",
			Text = "",
		},
	},
	["EarthBending"] = {
		actionName = "EarthBending",
		keys = {Enum.KeyCode.Three},
		touchButton = false, -- Handling Input on UI For mobile
		touch = {
			Image = "",
			Text = "",
		},
	},
	["WaterBending"] = {
		actionName = "WaterBending",
		keys = {Enum.KeyCode.Four},
		touchButton = false, -- Handling Input on UI For mobile
		touch = {
			Image = "",
			Text = "",
		},
	},

	["Meditate"] = {
		actionName = "Meditate",
		keys = {Enum.KeyCode.N},
		touchButton = true,
		touch = {
			Image = "rbxassetid://18244820580",
			Text = "",
		},
	},

	["Boomerang"] = {
		actionName = "Boomerang",
		keys = {Enum.KeyCode.Five},
		touchButton = false,
		touch = {
			Image = "",
			Text = "",
		},
	},

	["MeteoriteSword"] = {
		actionName = "MeteoriteSword",
		keys = {Enum.KeyCode.Six},
		touchButton = false,
		touch = {
			Image = "",
			Text = "",
		},
	}
}
table.freeze(CustomControls)

--- types
type ControlsType = {
	actionName :string,
	keys :{},
	touchButton :boolean,
	touch : {
		Image : string,
		Text :string,
	}
}

local CharacterController = Knit.CreateController {
	Name = "CharacterController",
}

------ Variables
local Connections = {}

---- Key for sprinting logic in PC [Sprint will disable with the same key that enables the sprint] 
local initiateRunKey = nil
local finalRunKey = nil

_G.SelectedCombat = nil
_G.ActiveBending = "None"
local isAttacking :BoolValue

local moveState : string
local meditateState :string

local StrengthValue : NumberValue 
local StaminaValue : NumberValue

local char :Model = player.Character or player.CharacterAdded:Wait()
local humanoid :Humanoid = char:WaitForChild("Humanoid") 
local root = char:WaitForChild("HumanoidRootPart")

------- Cool Down Timers
local SprintCoolDown = Costs.SprintCoolDown
local BlockCoolDownTime = Costs.BlockCoolDown

local BendingCoolDown = Costs.Air
------- Debounces[Flags]

--@ 
_G.Flying = false
local BlockDebounce = true

--@ Bending
local waterIC = false
local airDebounce = 1
local earthDebounce = 1
local fireDebounce = 1
local waterDebounce = 1
local BoomerangDebounce = 1

local SwordActivated = false
local BoomerangActivated = false
-------------------------------->>>>>>>>>  <<<<<<<<<<-------------------------------
-- Helper function to manage AnimationController
local function manageAnimation(anim, shouldPlay)
	if shouldPlay then
		AnimationController:PlayAnimation(anim)
	else
		AnimationController:Stop(anim)
	end
end

-- Helper function to manage FOV tween
local function manageFovTween(newFov)
	local properties = { FieldOfView = newFov }
	local info = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0.1)
	local tween = game:GetService("TweenService"):Create(game.Workspace.CurrentCamera, info, properties)
	tween:Play()
	game.Debris:AddItem(tween, info.Time + 0.1)
end

local function MoveStateChanged(newState)
	moveState = newState
	if newState == Constants.MoveStates.Running then
		manageAnimation({ AnimState = Constants.AvatarAnimtions.Running }, true)
		local orgWalkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = 27.5
		manageFovTween(DefaultFOV + 10)
	else
		manageAnimation({ AnimState = Constants.AvatarAnimtions.Running }, false)

		humanoid.WalkSpeed = 16
		manageFovTween(DefaultFOV)
		if moveState == Constants.MoveStates.Running then
			Sprint(false)
			
		end
	end
end

local function MeditateStateChanged(newState)
	meditateState = newState
	if newState == Constants.MeditateStates.Meditate then
		PlayerController:ToggleControls(false)
		--char.PrimaryPart.Anchored = true
		manageAnimation({ AnimState = Constants.AvatarAnimtions.Meditate }, true)
	else
		manageAnimation({ AnimState = Constants.AvatarAnimtions.Meditate }, false)
		--char.PrimaryPart.Anchored = false
		PlayerController:ToggleControls(true)
	end
end

local function InitStates()

	Connections["States"] = {}
	Connections.States.Move = player.States.Move:GetPropertyChangedSignal("Value"):Connect(function()
		MoveStateChanged(player.States.Move.Value)
	end)
	Connections.States.Meditate = player.States.Meditate:GetPropertyChangedSignal("Value"):Connect(function()
		MeditateStateChanged(player.States.Meditate.Value)
	end)

	Connections["Stats"] = {}
	Connections["Stats"] = player.CombatStats.Stamina:GetPropertyChangedSignal("Value"):Connect(function()
		if player.CombatStats.Stamina.Value <= 0 then
			Running(false)
		end
	end)
	
	StaminaValue = player.CombatStats.Stamina
	StrengthValue = player.CombatStats.Strength
	
	player.Progression.LEVEL:GetPropertyChangedSignal("Value"):Connect(function()
		RefillStats()
		
		local notificationName = "Level"..player.Progression.LEVEL.Value
		if NotificationData[notificationName] then
			NotificationGui:ShowMessage(NotificationData[notificationName])
		end
	end)
	
end

function InitStats()
	---------------- Stamina

	local Data : CustomTypes.StatsDataType = {}
	Data.Min = 0
	Data.Factor = Costs.StaminaRegenerationRate
	Data.State = Constants.MoveStates.Walk
	Data.StateType = Constants.StateTypes.Move
	Data.Max = player.CombatStats.MaxStamina.Value
	Data.Current = player.CombatStats.Stamina.Value

	CharacterService.UpdateState:Fire(Data)
	-------------- Strength MANA?
	Data = {}
	Data.Min = 0
	Data.Factor = 0--.025 --.01
	Data.State = Constants.MeditateStates.Idle
	Data.StateType = Constants.StateTypes.Meditate
	Data.Max = 100
	Data.Current = player.CombatStats.Strength.Value
	
	meditateState = Constants.MeditateStates.Idle
	
	CharacterService.UpdateState:Fire(Data)
end

function RefillStats()
	---------------- Stamina
	
	if moveState == Constants.MoveStates.Running then -- Toggle
		Sprint(false)
	end
	
	local Data : CustomTypes.StatsDataType = {}
	Data.Min = 0
	Data.Factor = Costs.StaminaRegenerationRate
	Data.State = Constants.MoveStates.Walk
	Data.StateType = Constants.StateTypes.Move
	Data.Max = player.CombatStats.MaxStamina.Value
	Data.Current = 100

	CharacterService.UpdateState:Fire(Data)
	-------------- Strength MANA?
	Data = {}
	Data.Min = 0
	Data.Factor = 0 --.01
	Data.State = Constants.MeditateStates.Idle
	Data.StateType = Constants.StateTypes.Meditate
	Data.Max = 100
	Data.Current = 100

	meditateState = Constants.MeditateStates.Idle

	CharacterService.UpdateState:Fire(Data)
	CharacterService.RefillHealth:Fire()
end

function InitAttributes()
	isAttacking = char:WaitForChild("IsAttacking")
	char:GetAttributeChangedSignal("State"):Connect(function(_state)
		local _state = char:GetAttribute("State")
		if _state ~= "walk" then
			Running(false)
		end
		
		if _state ~= "idle" then
			if player.isBlocking.Value then
				Block(false)
			end
		end
		
	end)
end

function OnCharacterAdded(newChar:Model)
	char = newChar or player.CharacterAdded:Wait()
	humanoid = newChar:WaitForChild("Humanoid")
	root = newChar:WaitForChild("HumanoidRootPart")

	InitAttributes()
	
	RefillStats()
	
	if _G.ActiveBending ~= "None" then
		_G.SelectedCombat(false)
	end

	if _G.SelectedCombat then
		PlayerMenuGui:ToggleSelection(false)
		_G.SelectedCombat = nil
	end

	--unEquip boomerang
	ToggleBoomerang(false)
	--UnEquip
	ToggleSword(false)

	--Jump State Controller
	newChar.ChildAdded:Connect(function()
		--:Karna: (TASK_ID) : 1047
		--if newChar:FindFirstChild("noJump") then
		--	newChar.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		--else
		--	newChar.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		--end
		
		if newChar:FindFirstChild("Disabled") then
			print("Meditate Checking ", meditateState)
			if meditateState == Constants.MeditateStates.Meditate then
				Meditate(false)
			end
		end
		
	end)

	newChar.ChildRemoved:Connect(function()
		--:Karna: (TASK_ID) : 1047
		--if newChar:FindFirstChild("noJump") then
		--	newChar.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
		--else
		--	newChar.Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		--end
	end)
end

local function BTNEFF(button : ImageButton, enable) -- Button Effect
	if button then
		if enable then
			button.ImageColor3 = Color3.new(0, 70, 255)
		else
			button.ImageColor3 = Color3.new(1, 1, 1)
		end
	end
end

local function CloseAllScreens()
	local includeList = {
		Constants.UiScreenTags.QuestGui, 
		Constants.UiScreenTags.SettingsGui, 
		Constants.UiScreenTags.StoreGui,
		Constants.UiScreenTags.GamePassGui, 
		Constants.UiScreenTags.MapGui,
		Constants.UiScreenTags.ShopGui,
		Constants.UiScreenTags.ControlsGuideGui,
	}
	
	local openedUI = UiController:GetOpenedUI(includeList)
	if openedUI then
		--print("TOGGGLING ", openedUI, screen)
		UiController:ToggleScreen(openedUI, false)
	end
end

-------------------------------------------------------------------------------------------
-------- Bending Focus Controls

local PlayerGui = player:WaitForChild("PlayerGui")
local TargetGui = PlayerGui:WaitForChild("TARGETGUI")

local TargetIcon:ImageLabel = TargetGui.Target

----- WorkSpace Items
local Beam = workspace.Terrain.Trajectory
local STARTATTACH = workspace.Terrain.Start
local ENDATTACH = workspace.Terrain.End
--Beam.Transparency = NumberSequence.new(1)

local camera = workspace.CurrentCamera

--- Camera Zooms
local DefaultMinZOOM, DefaultMaxZOOM = player.CameraMinZoomDistance, player.CameraMaxZoomDistance
local MinZOOM, MaxZOOM =  6, 12

-- RayCasting Data
local RayCastLength = 200

---- Private Functions
local function MakeSomethingTween(newFov, Offset, CameraMinDis, CameraMaxDis)

	local info = TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0.1)

	-- Tween for FieldOfView
	local propertiesFov = { FieldOfView = newFov }
	local tweenFov = TweenService:Create(camera, info, propertiesFov)
	tweenFov:Play()
	Debris:AddItem(tweenFov, info.Time + 0.1)

	-- Tween for CameraOffset
	local propertiesOffset = { CameraOffset = Offset }
	local tweenOffset = TweenService:Create(humanoid, info, propertiesOffset)
	tweenOffset:Play()
	Debris:AddItem(tweenOffset, info.Time + 0.1)

	-- Tween for CameraMaxZoomDistance and CameraMinZoomDistance
	local propertiesZoom = { CameraMaxZoomDistance = CameraMaxDis, CameraMinZoomDistance = CameraMinDis }
	local tweenZoom = TweenService:Create(player, info, propertiesZoom)
	tweenZoom:Play()
	Debris:AddItem(tweenZoom, info.Time + 0.1)
end

local thread = nil
local function ToggleCamera(enable)
	if enable then
		if thread then
			task.cancel(thread)
		end
		UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		UIS.MouseIconEnabled = false
		humanoid.AutoRotate = false
		RunS:BindToRenderStep("MouseLock", Enum.RenderPriority.Character.Value - 5, function()
			local X, y, Z = camera.CFrame.Rotation:ToEulerAnglesYXZ()
			root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, y, 0 )
		end)
	else
		if thread then
			task.cancel(thread)
		end
		thread = task.delay(1, function()
			humanoid.AutoRotate = true
		end)
		UIS.MouseIconEnabled = true
		UIS.MouseBehavior = Enum.MouseBehavior.Default
		RunS:UnbindFromRenderStep("MouseLock")
	end
end

local IsFocusOn = false
local Highlight = nil
local Target = nil --NPC if in focus.
local IsCharacterBetweenTargets = false

-- Sprint 2: Auto-target helper. Uses manual Target if available,
-- falls back to AutoTarget nearest enemy, then Mouse position.
local function GetTargetPosition()
	if Target then
		return Target.Position
	end
	-- Auto-target fallback: find nearest enemy
	local autoPos = AutoTarget.FindNearestPosition(char, RayCastLength)
	if autoPos then
		return autoPos
	end
	return Mouse.Hit.Position
end

local function ToggleFocusView(enable)
	if enable then
		-- Setup Camera
		if IsFocusOn then return end
		IsFocusOn = true

		---- Creating Elements on RunTime
		--Hightlight
		Highlight = Instance.new('Highlight')
		Highlight.FillTransparency = 1
		Highlight.OutlineColor = Color3.fromRGB(255, 76, 75)

		MakeSomethingTween(55, Vector3.new(0, 2, 0), MinZOOM, MaxZOOM)
		ToggleCamera(true)

		TargetIcon.Visible = true
		
		CloseAllScreens()
		
		-- Precompute constant values
		local renderPriority = Enum.RenderPriority.Character.Value
		local raycastParams = RaycastParams.new()
		raycastParams.RespectCanCollide = true
		Beam.Enabled = true
		RunS:BindToRenderStep("RayCast", renderPriority, function()
			local cameraCFrame = camera.CFrame

			local raycastResult = workspace:Raycast(cameraCFrame.Position, cameraCFrame.LookVector * RayCastLength, raycastParams)

			local targetPosition = nil
			local mousePosition = Vector3.new(Mouse.Hit.Position.X, Mouse.Hit.Position.Y, Mouse.Hit.Position.Z)

			Target = nil
			IsCharacterBetweenTargets = false
			
			if raycastResult then
				
				local instance = raycastResult.Instance
				local parent = instance.Parent

				if parent:IsA("Model") and (instance:IsDescendantOf(workspace.Scripted_Items.NPCs.Attacking) or game.Players:FindFirstChild(instance.Name)) then
					if parent:HasTag("NPCAI") or parent:HasTag("PlayerAvatar") then

						local StartPosition = char.PrimaryPart.Position - Vector3.new(0, 3,0)
						local EndPosition = parent.PrimaryPart.Position - Vector3.new(0, 3, 0)

						Beam.Enabled = true

						STARTATTACH.CFrame = CFrame.lookAt(StartPosition, EndPosition)
						ENDATTACH.CFrame = CFrame.lookAt(EndPosition, StartPosition)

						local modelChild = parent:FindFirstChildWhichIsA("Model")
						if modelChild then
							Highlight.Parent = modelChild
						else
							Highlight.Parent = workspace.Terrain
						end
					else
						Highlight.Parent = parent
					end
					Target = instance
					TargetIcon.ImageColor3 = Color3.fromRGB(255, 43, 14)					
				else
					Beam.Enabled = false
					Target = nil
					Highlight.Parent = workspace.Terrain
					TargetIcon.ImageColor3 = Color3.fromRGB(241, 245, 255)
				end
				
				if instance:IsDescendantOf(char) and parent:IsA("Model") then
					IsCharacterBetweenTargets = true
				end
				
				local dis = (root.Position - mousePosition).Magnitude
				if dis < 6 then
					IsCharacterBetweenTargets = true	
				end
				
				targetPosition = raycastResult.Position
			else
				Target = nil
				Highlight.Parent = workspace.Terrain
				TargetIcon.ImageColor3 = Color3.fromRGB(241, 245, 255)
				Beam.Enabled = false
			end

		end)

	else
		Beam.Enabled = false
		TargetIcon.Visible = false

		ToggleCamera(false)
		RunS:UnbindFromRenderStep("RayCast")
		MakeSomethingTween(70, Vector3.new(0, 0, 0), DefaultMinZOOM, DefaultMaxZOOM)

		IsFocusOn = false

		if Highlight then Highlight:Destroy() end
		if root:FindFirstChild("END") then root.END:Destroy() end
	end
end

-------------------------------------------------------------------------------------------

local function UpdateStrengthOnServer(value)
	local combats = {Strength = value}
	CharacterService.UpdateStats:Fire(combats)
end

local function UpdateStaminOnServer(value)
	local combats = {Strength = value}
	CharacterService.UpdateStats:Fire(combats)
end

------------------------------------- >>> Combat <<< ------------------------------------

function ToggleBoomerang(enable)
	if enable and not BoomerangActivated then
		BoomerangActivated = true
		CharacterService.ToggleWeapon:Fire(true, Constants.GameInventory.Weapons.Boomerang)
	elseif not enable and BoomerangActivated then
		-- Disable Boomerang
		BoomerangActivated = false
		CharacterService.ToggleWeapon:Fire(false, Constants.GameInventory.Weapons.Boomerang)
	end
end

function ToggleSword(enable)
	if enable and not SwordActivated then
		SwordActivated = true
		local data :CustomTypes.AnimationDataType = {}
		data.AnimState = Constants.AvatarAnimtions.Sheathe
		local track :AnimationTrack = AnimationController:PlayAnimation(data)

		CharacterService.ToggleWeapon:Fire(true, Constants.GameInventory.Weapons.MeteoriteSword)
	elseif not enable and SwordActivated then
		-- Disable Sword
		SwordActivated = false
		local data :CustomTypes.AnimationDataType = {}
		data.AnimState = Constants.AvatarAnimtions.Unsheathe
		local track :AnimationTrack = AnimationController:PlayAnimation(data)
		CharacterService.ToggleWeapon:Fire(false, Constants.GameInventory.Weapons.MeteoriteSword)
	end
end

------------------------------------- >>> Combat <<< ------------------------------------
---- Meditate
function Meditate(enable)
	VFXHandler:PlayOnServer(Constants.VFXs.Meditation, false)

	if enable then
		local isBlocking :BoolValue = player.isBlocking
		if not isBlocking.Value and char:GetAttribute("State") == "idle" then
			local plrData : CustomTypes.PlayerDataModel = _G.PlayerData

			local Data : CustomTypes.StatsDataType = {}
			Data.Min = 0
			Data.Factor = .1
			Data.State = Constants.MeditateStates.Meditate
			Data.StateType = Constants.StateTypes.Meditate
			Data.Max = 100
			--Karna: Task_Id :1086 
			Data.Current = StrengthValue.Value --plrData.ActiveProfile.Data.CombatStats.Strength
			
			meditateState = Constants.MeditateStates.Meditate
			
			CharacterService.UpdateState:Fire(Data)
			VFXHandler:PlayOnServer(Constants.VFXs.Meditation, true)

			SFXHandler:Play(Constants.SFXs.Meditation_Activate, true)
			SFXHandler:Play(Constants.SFXs.Meditation, true)
		end
	else

		local plrData : CustomTypes.PlayerDataModel = _G.PlayerData

		local Data : CustomTypes.StatsDataType = {}
		Data.Min = 0
		Data.Factor = 0--.01
		Data.State = Constants.MeditateStates.Idle
		Data.StateType = Constants.StateTypes.Meditate
		Data.Max = 100
		Data.Current = player.CombatStats.Strength.Value
		
		meditateState = Constants.MeditateStates.Idle
		
		CharacterService.UpdateState:Fire(Data)
		VFXHandler:PlayOnServer(Constants.VFXs.Meditation, false)

		SFXHandler:Play(Constants.SFXs.Meditation_Deactivate, true)
		SFXHandler:Stop(Constants.SFXs.Meditation)
	end
end

---------------------------- Running ------------------------------------
local runLastTime = tick()
local MoveDebounce = true

function Sprint(enable)
	local touchButton = CAS:GetButton(CustomControls.Sprint.actionName)
	if enable then

		local _state = char:GetAttribute("State")
		if _state ~= "walk" then
			return
		end 
		
		if moveState ~= Constants.MoveStates.Running and meditateState ~= Constants.MeditateStates.Meditate then
			--print("[Test Sprint] Enabling ", MoveDebounce)
			if MoveDebounce and StaminaValue.Value > 1 then
				MoveDebounce = false
				moveState = Constants.MoveStates.Running

				local plrData : CustomTypes.PlayerDataModel = _G.PlayerData

				local Data : CustomTypes.StatsDataType = {}
				Data.Min = 0
				Data.Factor = -Costs.StaminaDecrementRate
				Data.State = Constants.MoveStates.Running
				Data.StateType = Constants.StateTypes.Move
				Data.Max = player.CombatStats.MaxStamina.Value
				Data.Current = player.CombatStats.Stamina.Value --plrData.ActiveProfile.Data.CombatStats.Stamina

				CharacterService.UpdateState:Fire(Data)

				-------* Sprint effect toggle on UI
				BTNEFF(touchButton, true)

			end
			
		end
	else

		if not MoveDebounce then
			CoolDownGui:StartCoolDown(SprintCoolDown, "Sprint")
			task.delay(SprintCoolDown, function()
				MoveDebounce = true
			end)
		end

		local plrData : CustomTypes.PlayerDataModel = _G.PlayerData

		local Data : CustomTypes.StatsDataType = {}
		Data.Min = 0
		Data.Factor = Costs.StaminaRegenerationRate
		Data.State = Constants.MoveStates.Walk
		Data.StateType = Constants.StateTypes.Move
		Data.Max = player.CombatStats.MaxStamina.Value
		Data.Current = player.CombatStats.Stamina.Value --plrData.ActiveProfile.Data.CombatStats.Stamina

		moveState = Constants.MoveStates.Walk

		CharacterService.UpdateState:Fire(Data)

		initiateRunKey = nil

		-------* Sprint effect toggle on UI
		BTNEFF(touchButton, false)
		if StaminaValue.Value <= 1 then
			local data :CustomTypes.NotificationDataType = NotificationData.InsufficientStamina
			NotificationGui:ShowMessage(data)		
		end
	end
end

function Running(enable)
	local now = tick()
	local difference = (now - runLastTime)
	if enable then
		Sprint(true)

		if difference <= 0.25 then
			--Sprint(true)
		end
	else
		if moveState == Constants.MoveStates.Running then
			Sprint(false)
			
		end
		runLastTime = tick()
	end

end

---------------------------- Running ------------------------------------

---------------------------- Block - Combat ---------------------------------
function Block(enable)
	
	local isBlocking :BoolValue = player.isBlocking
	if enable then
		if humanoid.Health > 0 and meditateState ~= Constants.MeditateStates.Meditate then
			VFXHandler:PlayOnServer(Constants.VFXs.Fist, "Block")
			player.isBlocking.Value = true
			
			PlayerController:ToggleControls(false)
			PlayerController:ToggleControls(true)
		end
	else
		if isBlocking.Value then
			VFXHandler:PlayOnServer(Constants.VFXs.Fist, "Unblock")
		end
	end
end

---------------------------- Block - Combat ------------------------------------

---------------------------- Fist - Combat ------------------------------------
function Fist()
	if humanoid.Health > 0 then
		if meditateState ~= Constants.MeditateStates.Meditate then
			if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
				VFXHandler:PlayOnServer(Constants.VFXs.Fist, "Attack", true)
			else
				VFXHandler:PlayOnServer(Constants.VFXs.Fist, "Attack", false)
			end

			task.spawn(function()
				local noJumpValue = Instance.new("BoolValue")
				noJumpValue.Name = "noJump"
				noJumpValue.Parent = char
				game.Debris:AddItem(noJumpValue, 1.4)
			end)
		end
	end
end

---------------------------- Fist - Combat ------------------------------------
---------------------------- AirKick - Bending ------------------------------------

function AirBending(enable:boolean)

	if(enable) then
		if(isAttacking.Value) then return end
		if(airDebounce ~= 1) then return end

		if (meditateState ~= Constants.MeditateStates.Meditate) and (_G.ActiveBending == "None" or _G.ActiveBending ~= "Airkick") then
			if StaminaValue.Value < Costs.AirKickStamina then 
				local data :CustomTypes.NotificationDataType = NotificationData.InsufficientStamina
				NotificationGui:ShowMessage(data)
				return
			end

			-- Karna: TBC
			--if player.Progression.LEVEL.Value < Costs.AirKickLvl then return end
		else
			return
		end

		if StrengthValue.Value < Costs.AirKickStrength then 
			local data :CustomTypes.NotificationDataType = NotificationData.EnergyDepleted_Alert
			NotificationGui:ShowMessage(data)
			CharacterController:AirBending()
			return 
		end
		--StrengthValue.Value -= Costs.AirKickStrength

		_G.ActiveBending = "Airkick"
		airDebounce = 2

		ToggleFocusView(true)

	else

		if(airDebounce ~= 2) then return end

		airDebounce = 3
		ToggleFocusView(false)

		local slide = Instance.new("BodyVelocity")
		slide.MaxForce = Vector3.new(1,0,1) * 30000	
		slide.Name = "Sld"
		slide.Parent = char.PrimaryPart
		slide.Velocity = char.PrimaryPart.CFrame.lookVector * 30
		game.Debris:AddItem(slide, 0.6)

		--Play Sound
		local _sound = SFXHandler:Play(Constants.SFXs.AirKick_Push, true)
		Debris:AddItem(_sound, 4)
		
		local data :CustomTypes.AnimationDataType = {}
		data.AnimState = Constants.AvatarAnimtions.AirKick
		AnimationController:PlayAnimation(data)

		if StrengthValue.Value < Costs.AirKickStrength then 
			PlayerMenuGui:ToggleSelection(false)
			_G.SelectedCombat = nil
			
			local data :CustomTypes.NotificationDataType = NotificationData.EnergyDepleted_Alert
			NotificationGui:ShowMessage(data)
		end

		local mousepos = Mouse.Hit
		local targetPosition = GetTargetPosition()
		wait(0.25)
		if (targetPosition - char.PrimaryPart.Position).Magnitude < RayCastLength and humanoid.Health ~= 0 then
			VFXHandler:PlayOnServer(Constants.VFXs.AirKick, mousepos, targetPosition)
			UpdateStrengthOnServer(StrengthValue.Value - Costs.AirKickStrength)
		end

		PlayerMenuGui:CoolDown(Constants.GameInventory.Abilities.AirBending.Id, Costs.Abilities)
		CharacterController:AirBending()
		
		_G.ActiveBending = "None"
		task.delay(Costs.Abilities, function()
			airDebounce = 1
		end)
		
		
		--Camera Shake
		CameraController:ShakeCam(Constants.CamPresets.Explosion)
	end
end

----------------------------- AirKick - Bending --------------------------------------
---------------------------- EarthStomp - Bending ------------------------------------

function EarthBending(enable:boolean)
	--print("EarthBending", enable)
	if(enable) then

		if(isAttacking.Value) then return end
		if(earthDebounce ~= 1) then return end

		if (meditateState ~= Constants.MeditateStates.Meditate) and (_G.ActiveBending == "None" or _G.ActiveBending ~= "EarthStomp") then
			if StaminaValue.Value < Costs.EarthStompStamina then 
				local data :CustomTypes.NotificationDataType = NotificationData.InsufficientStamina
				NotificationGui:ShowMessage(data)
				return 
			end
			-- Karna: TBC
			--if player.Progression.LEVEL.Value < Costs.EarthStompLvl then return end
			if not isAttacking.Value then

			end
		else
			return
		end

		if StrengthValue.Value < Costs.EarthStompStrength then 
			local data :CustomTypes.NotificationDataType = NotificationData.EnergyDepleted_Alert
			NotificationGui:ShowMessage(data)
			CharacterController:EarthBending()
			return 
		end

		_G.ActiveBending = "EarthStomp"
		earthDebounce = 2

		if earthDebounce == 2 then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(0,1e8,0)
			BodyVelocity.Velocity = char.PrimaryPart.CFrame.UpVector * 0
			BodyVelocity.Parent = char.PrimaryPart

			game.Debris:AddItem(BodyVelocity,0.3)
			--local function anchor()
			--	char.PrimaryPart.Anchored = true
			--end
			--delay(0.3,anchor)
		end

		ToggleFocusView(true)

	else
		if(earthDebounce ~= 2) then return end
		earthDebounce = 3
		ToggleFocusView(false)
		
		--Play Animation
		local data :CustomTypes.AnimationDataType = {}
		data.AnimState = Constants.AvatarAnimtions.EarthStomp
		local track :AnimationTrack = AnimationController:PlayAnimation(data)

		--track:AdjustSpeed(0)
	
		
		--StrengthValue.Value -= Costs.EarthStompStrength	
		AnimationController:GetTrack(Constants.AvatarAnimtions.EarthStomp):AdjustSpeed(1)
		SFXHandler:Play(Constants.SFXs.EarthStomp_Thrust)
		
		--Fire on server
		local mousepos = Mouse.Hit
		local targetPosition = GetTargetPosition()
		if (targetPosition - char.PrimaryPart.Position).Magnitude < RayCastLength and humanoid.Health ~= 0 and not IsCharacterBetweenTargets then
			VFXHandler:PlayOnServer(Constants.VFXs.EarthStomp, mousepos, targetPosition)
			UpdateStrengthOnServer(StrengthValue.Value - Costs.EarthStompStrength)
		end

		--Camera Shake
		CameraController:ShakeCam(Constants.CamPresets.Explosion)

		if StrengthValue.Value < Costs.EarthStompStrength then 
			PlayerMenuGui:ToggleSelection(false)
			_G.SelectedCombat = nil
			
			local data :CustomTypes.NotificationDataType = NotificationData.EnergyDepleted_Alert
			NotificationGui:ShowMessage(data)
		end

		PlayerMenuGui:CoolDown(Constants.GameInventory.Abilities.EarthBending.Id, Costs.Abilities)
		CharacterController:EarthBending()
		_G.ActiveBending = "None"
		task.delay(Costs.Abilities, function()
			earthDebounce = 1
		end)
	end
end

---------------------------- EarthStomp - Bending ------------------------------------
---------------------------- FireDropKick - Bending ----------------------------------

function FireBending(enable:boolean)
	--print("FireBending", enable)
	if(enable) then

		if(fireDebounce ~= 1) then return end

		if (meditateState ~= Constants.MeditateStates.Meditate) and (_G.ActiveBending == "None" or _G.ActiveBending ~= "FireDropKick") then
			if StaminaValue.Value < Costs.FireDropKickStamina then 
				local data :CustomTypes.NotificationDataType = NotificationData.InsufficientStamina
				NotificationGui:ShowMessage(data)
				return
			end

			-- Karna :TBC
			--if player.Progression.LEVEL.Value < Costs.FireDropKickLvl then return end

			if isAttacking.Value then
				return
			end
		else
			return
		end

		if StrengthValue.Value < Costs.FireDropKickStrength then 
			local data :CustomTypes.NotificationDataType = NotificationData.EnergyDepleted_Alert
			NotificationGui:ShowMessage(data)
			CharacterController:FireBending()
			return
		end
		--StrengthValue.Value -= Costs.FireDropKickStrength	

		_G.ActiveBending = "FireDropKick"
		fireDebounce = 2

		ToggleFocusView(true)
	else
		if(fireDebounce ~= 2) then return end
		fireDebounce = 3

		ToggleFocusView(false)
		
		local data :CustomTypes.AnimationDataType = {}
		data.AnimState = Constants.AvatarAnimtions.FireDropKick
		local track :AnimationTrack = AnimationController:PlayAnimation(data)
		track:AdjustSpeed(0)
		--Play Aniamation
		AnimationController:GetTrack(Constants.AvatarAnimtions.FireDropKick):AdjustSpeed(1)

		--Apply forces
		local slide = Instance.new("BodyVelocity")
		slide.MaxForce = Vector3.new(1,0,1) *30000	
		slide.Name = "Sld"
		slide.Parent = char.PrimaryPart
		slide.Velocity = char.PrimaryPart.CFrame.lookVector * 30
		Debris:AddItem(slide, 0.6)

		local slide3 = Instance.new("BodyVelocity")
		slide3.MaxForce = Vector3.new(1,0,1) *30000	
		slide3.Name = "Sld3"
		slide3.Parent = char.PrimaryPart
		slide3.Velocity = char.PrimaryPart.CFrame.upVector * 123
		Debris:AddItem(slide3, 0.6)

		--Play sound
		local _sound = SFXHandler:Play(Constants.SFXs.FireDropKick_Launch, true)
		game.Debris:AddItem(_sound, 3)
		wait(0.5)
		--Fire on Server
		local mousepos = Mouse.Hit
		local targetPosition = GetTargetPosition()
		
		if (targetPosition - char.PrimaryPart.Position).Magnitude < RayCastLength and humanoid.Health ~= 0 then
			VFXHandler:PlayOnServer(Constants.VFXs.FireDropKick, mousepos, targetPosition)
			UpdateStrengthOnServer(StrengthValue.Value - Costs.FireDropKickStrength)
		end

		--Camera Shake
		CameraController:ShakeCam(Constants.CamPresets.Explosion)

		if StrengthValue.Value < Costs.FireDropKickStrength then 
			PlayerMenuGui:ToggleSelection(false)
			_G.SelectedCombat = nil
			
			local data :CustomTypes.NotificationDataType = NotificationData.EnergyDepleted_Alert
			NotificationGui:ShowMessage(data)
		end

		PlayerMenuGui:CoolDown(Constants.GameInventory.Abilities.FireBending.Id, Costs.Abilities)
		CharacterController:FireBending()
		
		_G.ActiveBending = "None"
		task.delay(Costs.Abilities, function()
			fireDebounce = 1
		end)
		
	
	end
end

---------------------------- FireDropKick - Bending -----------------------------------
----------------------------- WaterStance - Bending -----------------------------------

function WaterBending(enable:boolean) ---- Blocking

	if(enable) then

		if(isAttacking.Value) then return end
		if(waterDebounce ~= 1) then return end
		
		if moveState == Constants.MoveStates.Running then -- Toggle
			Sprint(false)
		end
		
		
		if (meditateState ~= Constants.MeditateStates.Meditate) and (_G.ActiveBending == "None" or _G.ActiveBending ~= "WaterStance") then
			if StaminaValue.Value < Costs.WaterStanceStamina then 
				local data :CustomTypes.NotificationDataType = NotificationData.InsufficientStamina
				NotificationGui:ShowMessage(data)
				return
			end
		else
			return
		end


		if StrengthValue.Value < Costs.WaterStanceStrength then 
			local data :CustomTypes.NotificationDataType = NotificationData.EnergyDepleted_Alert
			NotificationGui:ShowMessage(data)
			CharacterController:WaterBending()
			return
		end
		
		UpdateStrengthOnServer(StrengthValue.Value - Costs.WaterStanceStrength)
		--StrengthValue.Value -= Costs.WaterStanceStrength	

		_G.ActiveBending = "WaterStance"
		waterDebounce = 2

		task.spawn(function()
			waterIC = true
			task.wait(1.5)
			waterIC = false
		end)

		local data :CustomTypes.AnimationDataType = {}
		data.AnimState = Constants.AvatarAnimtions.WaterStance
		local track :AnimationTrack = AnimationController:PlayAnimation(data)

		spawn(function()
			wait(1)

			VFXHandler:PlayOnServer(Constants.VFXs.WaterStance, "Weld")
			SFXHandler:Play(Constants.SFXs.WaterBend_Stand, true)
		end)
		spawn(function()
			wait(1.55)

			SFXHandler:Play(Constants.SFXs.WaterBend_GroundSlam, true)
		end)
		spawn(function()
			wait(1.6) 
			track:AdjustSpeed(0)
		end)

		--Apply force on character
		if waterDebounce == 2 then
			local BodyVelocity = Instance.new("BodyVelocity")
			BodyVelocity.MaxForce = Vector3.new(0,1e8,0)
			BodyVelocity.Velocity = char.PrimaryPart.CFrame.UpVector * 0
			BodyVelocity.Parent = char.PrimaryPart
			Debris:AddItem(BodyVelocity,0.3)

			local function anchor()
				char.PrimaryPart.Anchored = true
			end
			task.delay(0.3, anchor)
		end

		--Rotate towards mouse pos
		local con = nil
		con = RunS.RenderStepped:Connect(function()
			if waterDebounce == 2 then
				local lookAt = Vector3.new(Mouse.Hit.x, char.PrimaryPart.CFrame.y, Mouse.Hit.z)
				char.PrimaryPart.CFrame = CFrame.lookAt(char.PrimaryPart.Position, lookAt)
			else
				con:Disconnect()
			end
		end)

	else
		if(waterDebounce ~= 2) then return end

		--print("[Water] waterIC REPEATING...", waterIC)

		if StrengthValue.Value < Costs.WaterStanceStrength then 
			PlayerMenuGui:ToggleSelection(false)
			_G.SelectedCombat = nil
			
			local data :CustomTypes.NotificationDataType = NotificationData.EnergyDepleted_Alert
			NotificationGui:ShowMessage(data)
		end

		repeat wait(.5) until waterIC == false
		waterDebounce = 3

		--print("[Water] WaterDebounce FALSE")

		--Play Aniamation
		AnimationController:GetTrack(Constants.AvatarAnimtions.WaterStance):AdjustSpeed(1)
		char.PrimaryPart.Anchored = false
		
		wait(1)
		--print("[Water] PlayOnServer")
		--Send event on Server
		local mousepos = Mouse.Hit
		VFXHandler:PlayOnServer(Constants.VFXs.WaterStance, "RE", mousepos, Mouse.Hit.p)

		PlayerMenuGui:CoolDown(Constants.GameInventory.Abilities.WaterBending.Id, Costs.Abilities)
		CharacterController:WaterBending()
		_G.ActiveBending = "None"
		task.delay(Costs.Abilities, function()
			waterDebounce = 1
		end)
		
		--Stop Sound
		SFXHandler:Stop(Constants.SFXs.WaterBend_Stand)
		SFXHandler:Stop(Constants.SFXs.WaterBend_GroundSlam)
		
		--print("[Water] PrimaryPart.Anchored")
		local data :CustomTypes.AnimationDataType = {}
		data.AnimState = Constants.AvatarAnimtions.WaterStance
		local track :AnimationTrack = AnimationController:Stop(data)
		
	end
end

---------------------------- WaterStance - Bending ------------------------------------

function MeteoriteSword(enable)

	if humanoid.Health > 0 then
		if meditateState ~= Constants.MeditateStates.Meditate then
			
			if StaminaValue.Value < Costs.MeteoriteSwordStamina then
				local data :CustomTypes.NotificationDataType = NotificationData.InsufficientStamina
				NotificationGui:ShowMessage(data)
				return
			end
			
			if humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
				VFXHandler:PlayOnServer(Constants.VFXs.MeteoriteSword, "Attack", true)
			else
				VFXHandler:PlayOnServer(Constants.VFXs.MeteoriteSword, "Attack", false)
			end

			task.spawn(function()
				local noJumpValue = Instance.new("BoolValue")
				noJumpValue.Name = "noJump"
				noJumpValue.Parent = char
				game.Debris:AddItem(noJumpValue, 1.4)
			end)
		end
	end

end

function Boomerang(enable)
	if(enable) then
		if(isAttacking.Value) then return end
		if(BoomerangDebounce ~= 1) then return end

		if not (moveState == Constants.MoveStates.Running) and (meditateState ~= Constants.MeditateStates.Meditate) and _G.ActiveBending == "None" then
			if StaminaValue.Value < Costs.BoomerangStamina then 
				local data :CustomTypes.NotificationDataType = NotificationData.InsufficientStamina
				NotificationGui:ShowMessage(data)
				return 
			end
		else
			return
		end

		if StrengthValue.Value < Costs.BoomerangStrength then 
			local data :CustomTypes.NotificationDataType = NotificationData.EnergyDepleted_Alert
			NotificationGui:ShowMessage(data)
			
			return 
		end
		UpdateStrengthOnServer(StrengthValue.Value -Costs.BoomerangStrength)
		--StrengthValue.Value -= Costs.BoomerangStrength
		char.PrimaryPart.Anchored = true
		local data :CustomTypes.AnimationDataType = {}
		data.AnimState = Constants.AvatarAnimtions.BoomerangHold
		local track :AnimationTrack = AnimationController:PlayAnimation(data)
		task.delay(.2, function()
			if BoomerangDebounce == 2 then
				track:AdjustSpeed(0)
			end
		end)

		_G.ActiveBending = "Boomerang"
		BoomerangDebounce = 2

		ToggleFocusView(true)
	else

		if(BoomerangDebounce ~= 2) then return end

		BoomerangDebounce = 3
		ToggleFocusView(false)

		--Play Sound
		SFXHandler:Play(Constants.SFXs.Boomerang)
		AnimationController:GetTrack(Constants.AvatarAnimtions.BoomerangHold):AdjustSpeed(1)

		wait(0.25)
		local mousepos = Mouse.Hit
		local targetPosition = GetTargetPosition()
		VFXHandler:PlayOnServer(Constants.VFXs.Boomerang, mousepos, targetPosition)
		task.delay(.5, function()
			char.PrimaryPart.Anchored = false
		end)
		--Camera Shake
		CameraController:ShakeCam(Constants.CamPresets.Explosion)

		--Karna: Stop Sound
		--spawn(function()
		--	wait(4)
		--	SFXHandler:Stop(Constants.SFXs.AirKick_Push)
		--end)

		-- Deselecting Bending if strenght not enough for second round

		if StrengthValue.Value < Costs.BoomerangStrength then 
			PlayerMenuGui:ToggleSelection(false)
			_G.SelectedCombat = nil
			
			local data :CustomTypes.NotificationDataType = NotificationData.EnergyDepleted_Alert
			NotificationGui:ShowMessage(data)
		end

		PlayerMenuGui:CoolDown(Constants.GameInventory.Weapons.Boomerang, Costs.BoomerangCoolDown)
		task.delay(Costs.BoomerangCoolDown, function()
			_G.ActiveBending = "None"
			BoomerangDebounce = 1
		end)
	end
end

-------------------------->>>>>>>>>>>....... CONTROLS ........<<<<<<<<<<<<------------------------
local Container = {
	-----* Running
	[CustomControls.Sprint.actionName] = {
		[Enum.UserInputState.Begin] = function(inputObject :InputObject)

			if _G.ActiveBending == "WaterStance" then
				warn("Bending Active Can't sprint! ")
				return
			end

			--------- KeyCode Type
			if inputObject.UserInputType == Enum.UserInputType.Touch then -- Mobile

				if moveState == Constants.MoveStates.Running then -- Toggle
					Sprint(false)
					
				else
					local Speed = char.PrimaryPart.AssemblyLinearVelocity.Magnitude

					if math.ceil(Speed) > 1 then
						Sprint(true)
					end
				end
			else -- PC

				if moveState ~= Constants.MoveStates.Running and meditateState ~= Constants.MeditateStates.Meditate then

					if initiateRunKey == nil then
						initiateRunKey = inputObject.KeyCode
					elseif initiateRunKey ~= inputObject.KeyCode then
						initiateRunKey = inputObject.KeyCode
						return
					end

					Running(true)
				end
			end
		end,
		[Enum.UserInputState.End] = function(inputObject :InputObject, button :ImageButton)
			if inputObject.UserInputType == Enum.UserInputType.Keyboard then
				if initiateRunKey and (initiateRunKey == inputObject.KeyCode) then
					Running(false)
				end
			end
		end,
	},

	-----* Fist Attack
	[CustomControls.Fist.actionName] = {
		[Enum.UserInputState.Begin] = function(inputObject :InputObject, button :ImageButton)
			if not _G.SelectedCombat then
				if _G.ActiveBending == "None" then
					--if StaminaValue.Value < Costs.FistStamina then return end
					Fist()
				end
			else
				_G.SelectedCombat(true)
			end
		end,

		[Enum.UserInputState.End] = function(inputObject :InputObject)
			if _G.SelectedCombat and _G.SelectedCombat ~= MeteoriteSword then
				_G.SelectedCombat(false)
			end
		end
	},

	-----* Block-Unblock
	[CustomControls.Block.actionName] = {
		[Enum.UserInputState.Begin] = function(inputObject :InputObject)
			if not (moveState == Constants.MoveStates.Running) and _G.ActiveBending == "None" then
				Block(true)
			end
		end,
		[Enum.UserInputState.End] = function(inputObject :InputObject)
			Block(false)
		end,
	},

	-----* Meditate Enable/Disable
	[CustomControls.Meditate.actionName] = {
		[Enum.UserInputState.Begin] = function(inputObject :InputObject)
			if not (moveState == Constants.MoveStates.Running) and _G.ActiveBending == "None" then
				Meditate(true)
			end
		end,
		[Enum.UserInputState.End] = function(inputObject :InputObject)
			Meditate(false)
		end,
	},

	-----* AirBending
	[CustomControls.AirBending.actionName] = {
		[Enum.UserInputState.Begin] = function(inputObject :InputObject, button :ImageButton)
			--CharacterController:AirBending(true)		
		end,
		[Enum.UserInputState.End] = function(inputObject :InputObject, button :ImageButton)
			CharacterController:AirBending(false)
		end,
	},

	-----* WaterBending
	[CustomControls.WaterBending.actionName] = {
		[Enum.UserInputState.Begin] = function(inputObject :InputObject, button :ImageButton)
			--CharacterController:WaterBending(true)
		end,
		[Enum.UserInputState.End] = function(inputObject :InputObject, button :ImageButton)
			CharacterController:WaterBending(false)
		end,
	},

	-----* FireBending
	[CustomControls.FireBending.actionName] = {
		[Enum.UserInputState.Begin] = function(inputObject :InputObject, button :ImageButton)
			--CharacterController:FireBending(true)
		end,
		[Enum.UserInputState.End] = function(inputObject :InputObject, button :ImageButton)
			CharacterController:FireBending(false)
		end,
	},

	-----* EarthBending
	[CustomControls.EarthBending.actionName] = {
		[Enum.UserInputState.Begin] = function(inputObject :InputObject, button :ImageButton)
			--CharacterController:EarthBending(true)
		end,
		[Enum.UserInputState.End] = function(inputObject :InputObject, button :ImageButton)
			CharacterController:EarthBending(false)
		end,
	},

	-----* Boomerang
	[CustomControls.Boomerang.actionName] = {
		[Enum.UserInputState.Begin] = function(inputObject :InputObject, button :ImageButton)
			--CharacterController:Boomerang(true)
		end,
		[Enum.UserInputState.End] = function(inputObject :InputObject, button :ImageButton)
			CharacterController:Boomerang(false)
		end,
	},

	-----* MeteoriteSword
	[CustomControls.MeteoriteSword.actionName] = {
		[Enum.UserInputState.Begin] = function(inputObject :InputObject, button :ImageButton)
			--CharacterController:MeteoriteSword(true)
		end,
		[Enum.UserInputState.End] = function(inputObject :InputObject, button :ImageButton)
			CharacterController:MeteoriteSword(false)
		end,
	}

}

function BindControls()
	UnBindControls()
	for id, keyData : ControlsType in pairs(CustomControls) do

		local inputData : CT.InputDataType = {}

		inputData.KeyCodes = {}
		inputData.KeyCodes = keyData.keys

		if keyData.touchButton then
			inputData.UiData = {}
			inputData.UiData.Text = keyData.touch.Text
			inputData.UiData.Image = keyData.touch.Image
		end

		InputController:BindMultipleInputs(inputData, keyData.actionName, function(actionName:string, inputState, inputObject :InputObject)
			if Container[actionName] and Container[actionName][inputState] then
				Container[actionName][inputState](inputObject) -- Calling Specific action
			else
				--warn("function not found! ",inputState, actionName)
			end
		end)
	end
end

function UnBindControls(except: {string : ControlsType})
	local Controls = table.clone(CustomControls)

	if except then
		for _, keyData :ControlsType in pairs(except) do
			if Controls[keyData.actionName] then
				Controls[keyData.actionName] = nil
			end
		end
	end

	for _, keyData :ControlsType in pairs(Controls) do
		for index, key in pairs(keyData.keys) do
			InputController:UnBindInput(key, keyData.actionName)
		end
	end

end

-------------------------->>>>>>>>>>>....... CONTROLS ........<<<<<<<<<<<<------------------------


------------------------>>>>>>>>>>>>>............. PUBLIC METHODS ................>>>>>>>>>>>>------------------
function CharacterController:AirBending()

	if not _G.SelectedCombat then
		if CF.PlayerData.DoesPlayerHaveAbility(_G.PlayerData, Constants.GameInventory.Abilities.AirBending.Id) then
			--if player.Progression.LEVEL.Value < Costs.AirKickLvl then return end
			_G.SelectedCombat = AirBending
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Abilities.AirBending.Id)
		end
	elseif _G.SelectedCombat == AirBending then

		if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		if _G.SelectedCombat == AirBending then
			PlayerMenuGui:ToggleSelection(false)
			_G.SelectedCombat = nil
		end

		----unEquip boomerang
		--ToggleBoomerang(false)
		----UnEquip
		--ToggleSword(false)
	else
		if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		--unEquip boomerang
		ToggleBoomerang(false)
		--UnEquip
		ToggleSword(false)

		--if player.Progression.LEVEL.Value < Costs.AirKickLvl then return end
		if CF.PlayerData.DoesPlayerHaveAbility(_G.PlayerData, Constants.GameInventory.Abilities.AirBending.Id) then
			_G.SelectedCombat = AirBending
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Abilities.AirBending.Id)
		end
		
	end
end

function CharacterController:EarthBending()
	if not _G.SelectedCombat  then
		if CF.PlayerData.DoesPlayerHaveAbility(_G.PlayerData, Constants.GameInventory.Abilities.EarthBending.Id) then
			_G.SelectedCombat = EarthBending
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Abilities.EarthBending.Id)
		end
	elseif _G.SelectedCombat == EarthBending then

		if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		if _G.SelectedCombat == EarthBending then
			PlayerMenuGui:ToggleSelection(false)
			_G.SelectedCombat = nil
		end
	else
		if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		--unEquip boomerang
		ToggleBoomerang(false)
		--UnEquip
		ToggleSword(false)

		if CF.PlayerData.DoesPlayerHaveAbility(_G.PlayerData, Constants.GameInventory.Abilities.EarthBending.Id) then
			_G.SelectedCombat = EarthBending
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Abilities.EarthBending.Id)
		end
	end
end

function CharacterController:FireBending()
	if not _G.SelectedCombat  then
		if CF.PlayerData.DoesPlayerHaveAbility(_G.PlayerData, Constants.GameInventory.Abilities.FireBending.Id) then
			_G.SelectedCombat = FireBending
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Abilities.FireBending.Id)
		end
	elseif _G.SelectedCombat == FireBending then
			if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		if _G.SelectedCombat == FireBending then
			PlayerMenuGui:ToggleSelection(false)
			_G.SelectedCombat = nil
		end
	else
		if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		--unEquip boomerang
		ToggleBoomerang(false)
		--UnEquip
		ToggleSword(false)
		
		if CF.PlayerData.DoesPlayerHaveAbility(_G.PlayerData, Constants.GameInventory.Abilities.FireBending.Id) then
			_G.SelectedCombat = FireBending
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Abilities.FireBending.Id)
		end
	end
end

function CharacterController:WaterBending()
	if not _G.SelectedCombat then
		
		if CF.PlayerData.DoesPlayerHaveAbility(_G.PlayerData, Constants.GameInventory.Abilities.WaterBending.Id) then
			_G.SelectedCombat = WaterBending
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Abilities.WaterBending.Id)
		end

	elseif _G.SelectedCombat == WaterBending then

		if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		if _G.SelectedCombat == WaterBending then
			PlayerMenuGui:ToggleSelection(false)
			_G.SelectedCombat = nil
		end
	else
		if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		--unEquip boomerang
		ToggleBoomerang(false)
		--UnEquip
		ToggleSword(false)

		if CF.PlayerData.DoesPlayerHaveAbility(_G.PlayerData, Constants.GameInventory.Abilities.WaterBending.Id) then
			_G.SelectedCombat = WaterBending
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Abilities.WaterBending.Id)
		end
	end
end

function CharacterController:Boomerang()
	if not _G.SelectedCombat then
		local passesData = _G.PlayerData.GamePurchases.Passes
		if passesData[Constants.IAPItems.Boomerang.Id] then
			_G.SelectedCombat = Boomerang
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Weapons.Boomerang)

			-- Equip boomerang
			ToggleBoomerang(true)
		else
			local data :CustomTypes.NotificationDataType = NotificationData.LockedAbility_Alert
			NotificationGui:ShowMessage(data)
		end
	elseif _G.SelectedCombat == Boomerang then

		if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		if _G.SelectedCombat == Boomerang then
			PlayerMenuGui:ToggleSelection(false)
			_G.SelectedCombat = nil
			ToggleBoomerang(false)
		end
	else
		if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		--unEquip boomerang
		ToggleBoomerang(false)
		--UnEquip
		ToggleSword(false)

		local passesData = _G.PlayerData.GamePurchases.Passes
		if passesData[Constants.IAPItems.Boomerang.Id] then
			_G.SelectedCombat = Boomerang
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Weapons.Boomerang)

			-- Equip boomerang
			ToggleBoomerang(true)
		else
			local data :CustomTypes.NotificationDataType = NotificationData.LockedAbility_Alert
			NotificationGui:ShowMessage(data)
		end
	end
end

function CharacterController:MeteoriteSword()
	if not _G.SelectedCombat then
		local passesData = _G.PlayerData.GamePurchases.Passes
		if passesData[Constants.IAPItems.MeteoriteSword.Id] then
			_G.SelectedCombat = MeteoriteSword
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Weapons.MeteoriteSword)

			--Equip
			ToggleSword(true)
		else
			local data :CustomTypes.NotificationDataType = NotificationData.LockedAbility_Alert
			NotificationGui:ShowMessage(data)
		end
	elseif _G.SelectedCombat == MeteoriteSword then

		if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		if _G.SelectedCombat == MeteoriteSword then
			PlayerMenuGui:ToggleSelection(false)
			_G.SelectedCombat = nil
			ToggleSword(false)
		end
	else
		if _G.ActiveBending ~= "None" then
			_G.SelectedCombat(false)
		end

		--unEquip boomerang
		ToggleBoomerang(false)
		--UnEquip
		ToggleSword(false)

		local passesData = _G.PlayerData.GamePurchases.Passes
		if passesData[Constants.IAPItems.MeteoriteSword.Id] then
			_G.SelectedCombat = MeteoriteSword
			PlayerMenuGui:ToggleSelection(true, Constants.GameInventory.Weapons.MeteoriteSword)

			--Equip
			ToggleSword(true)
		else
			local data :CustomTypes.NotificationDataType = NotificationData.LockedAbility_Alert
			NotificationGui:ShowMessage(data)
		end
	end
end

function CharacterController:ToggleControls(enable:boolean)
	if(enable) then
		BindControls()
	else
		Running(false)
		UnBindControls()
	end
end
------------------------>>>>>>>>>>>>>............. PUBLIC METHODS ................>>>>>>>>>>>>------------------

function CharacterController:KnitInit()

end

function CharacterController:KnitStart()
	player.CharacterAdded:Connect(OnCharacterAdded)

	UiController = Knit.GetController('UIController')
	InputController = Knit.GetController("InputController")
	CameraController = Knit.GetController("CameraController")
	AnimationController = Knit.GetController("AnimationController")
	PlayerController = Knit.GetController("PlayerController")

	CharacterService = Knit.GetService("CharacterService")
	TransportService = Knit.GetService("TransportService")

	CoolDownGui = UiController:GetGui(Constants.UiScreenTags.CoolDownGui, 2)
	PlayerMenuGui = UiController:GetGui(Constants.UiScreenTags.PlayerMenuGui, 2)
	NotificationGui = UiController:GetGui(Constants.UiScreenTags.NotificationGui, 2)

	task.delay(1, InitStates)
	task.delay(2, InitStats)

	task.spawn(InitAttributes)

	task.delay(1, function()
		self:ToggleControls(false)
	end)
end

return CharacterController
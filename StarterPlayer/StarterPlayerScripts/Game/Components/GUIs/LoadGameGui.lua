-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local RunS = game:GetService("RunService")

local Packages = RS.Packages
local Knit = require(Packages.Knit)
local Component = require(Packages.Component)

local CustomModules = RS.Modules.Custom
local CT = require(CustomModules.CustomTypes)
local CF = require(CustomModules.CommonFunctions)
local Constants = require(CustomModules.Constants)
local NotificationData = require(CustomModules.NotificationData)

local player = game.Players.LocalPlayer
local LoadGameGui = Component.new({Tag = "LoadGameGui", Ancestors = {player}})

-- Replicated Assets
local Models = RS.Assets.Models
-- Workspace
local Positions = workspace.Scripted_Items.Positions

local DraggerModel = Models.Other.Dragger
local CharModel = nil

local DurationOfErrorMessage = 5

-- UI
type SLOT = {
	DataF :{
		Level :TextLabel,
		Create :TextLabel,
		LastMap :TextLabel,
		SlotName :TextLabel,
	},
	Icon :ImageLabel & {Label :TextLabel}
}

type UI = {
	Base :TextButton & {
		CreateF :Frame,
		Slots :ImageLabel,
		Customization :Frame,
	},

	CreateF :{
		Play :ImageButton,
		Save :ImageButton,
		Container :{TextBox :TextBox, Note :TextLabel},
	},

	Slots :{
		Container :{[string] :SLOT},
		Templates :{SelectBox :UIStroke, Slot : SLOT},	
		Delete :ImageButton,
	},

	SelectBox :UIStroke,
}
local ui :UI = {}

------ Other scripts
local UIController
local TWController
local PlayerController
local CharacterService

local LoadingGui
local DialogueGui

------ Variables
_G.SelectedSlotData = CF.Value({})

------------- Helper ------------

local function textBoxFocusLost()
	local profileSlotData :CT.ProfileSlotDataType = _G.SelectedSlotData:Get()
	profileSlotData.SlotName = ui.CreateF.Container.TextBox.Text
	_G.SelectedSlotData:Set(profileSlotData, true)
end

local shake_Conn = nil
local function shakeLabel(label, duration, magnitude)
	if not label or not label:IsA("GuiObject") then return end
	local freq = 40
	duration = duration or 0.35
	magnitude = magnitude or 8
	-- capture current text if user wants to clear later
	local originalText = label.Text

	-- cancel any existing shake for this label
	if shake_Conn and typeof(shake_Conn) == "RBXScriptConnection" then
		shake_Conn:Disconnect()
		shake_Conn = nil
	end

	local targetPos = label.Position
	local elapsed = 0

	shake_Conn = RunS.Heartbeat:Connect(function(dt)
		elapsed = elapsed + dt
		local progress = math.clamp(elapsed / duration, 0, 1)
		local damping = 1 - progress
		local angle = elapsed * freq * 2 * math.pi
		local offset = math.sin(angle) * magnitude * damping

		-- apply horizontal offset
		label.Position = UDim2.new(
			targetPos.X.Scale, targetPos.X.Offset + offset,
			targetPos.Y.Scale, targetPos.Y.Offset
		)

		if progress >= 1 then
			-- restore and cleanup
			if shake_Conn then
				shake_Conn:Disconnect()
				shake_Conn = nil
			end
			label.Position = targetPos
		end
	end)
end

local thread = nil
function check()
	
	local label = ui.Base.CreateF.Play.Note
	label.Text = " "
	
	if thread then
		task.cancel(thread)
	end
	
	if _G.UnPurchasedItem then
		local err = `Buy or unequip {_G.UnPurchasedItem} to proceed.`
		label.Text = err
		thread = task.delay(DurationOfErrorMessage, function()
			if label.Text == err then
				label.Text = ""
			end
		end)
		return false
	end
	
	local newName = ui.CreateF.Container.TextBox.Text

	-- Refrence Issue: Need to clone orginal table
	local plrData :CT.PlayerDataModel = CF.Tables.CloneTable(_G.PlayerData)

	local slot_Data :CT.ProfileSlotDataType = _G.SelectedSlotData:Get()
	local slot_id = slot_Data.SlotId

	local valid, err = CF.PlayerData.ValidateSlotName(plrData.AllProfiles, newName, slot_id)

	local Label =  ui.CreateF.Container.Note
	Label.Text = " "
	if(not valid) then
		Label.Text = err
		shakeLabel(Label, 0.5, 8)
		task.delay(5, function()
			if Label.Text == err then
				Label.Text = ""
			end
		end)
	else
		--Fire or callback to update the slot details.
		if(slot_id) then
			plrData.AllProfiles[slot_id].SlotName = newName
			plrData.AllProfiles[slot_id].LastUpdatedOn = workspace.ServerTime.Value
			plrData.AllProfiles[slot_id].Data.EquippedInventory.Styling = slot_Data.Data.EquippedInventory.Styling

		else
			CF.PlayerData.CreateNewSlot(plrData, newName)
			plrData.AllProfiles[plrData.ActiveProfile].Data.EquippedInventory.Styling = slot_Data.Data.EquippedInventory.Styling
			_G.SelectedSlotData:Set(plrData.AllProfiles[plrData.ActiveProfile])
		end

		_G.PlayerDataStore:UpdateData(plrData)

		return true
	end
	
	return false
end

function play()
	if check() then
		--print("[MyData] 1 : ", _G.PlayerData)
		local plrData :CT.PlayerDataModel = _G.PlayerData
		plrData.AllProfiles[_G.SelectedSlotData:Get().SlotId].LastUpdatedOn = workspace.ServerTime.Value
		plrData.ActiveProfile = _G.SelectedSlotData:Get().SlotId --switch to seleted profile
		_G.PlayerDataStore:UpdateData(plrData)

		task.spawn(function()	
			CF.UI.Blink(player)
		end)
		
		--print("[MyData] 2 : ", _G.PlayerData)
		
		workspace:SetAttribute("GameStarted", true)
		
		CharacterService.Setup:Fire()
		wait(.1)
		CharacterService.RedirectToMap:Fire()

		CharacterController:ToggleControls(true)
		PlayerController:ToggleControls(true)

		LoadGameGui:Toggle(false)
		DialogueGui:Welcome()
	else
		warn("Create not success:", _G.PlayerData)
	end
end

local function delete()
	
	local data :CT.NotificationDataType = NotificationData.DeleteProfile_Confirmation

	NotificationGui:ShowMessage(data, function()
		local plrData :CT.PlayerDataModel = CF.Tables.CloneTable(_G.PlayerData)
		if CF.Tables.TableLength(plrData.AllProfiles) <= 1 then
			warn("[[LoadGame]] [Error] Can't delete")
			return
		end

		local id = _G.SelectedSlotData:Get().SlotId
		if(id) then
			local SlotId = id
			if plrData.ActiveProfile == SlotId then
				--Karna: Can't delete the active slot.
				warn("Can't delete the active slot")

				local nextAssumedProfile = nil
				for profileId, slotData in pairs(plrData.AllProfiles) do
					if profileId == Constants.Default_Slot or profileId == SlotId then
						continue
					else
						nextAssumedProfile = profileId
						break
					end
				end

				if nextAssumedProfile then
					plrData.ActiveProfile = nextAssumedProfile
					plrData.AllProfiles[SlotId] = nil
				else
					plrData.ActiveProfile = Constants.DefaultSlotId
					plrData.AllProfiles[SlotId] = nil
				end
			else
				plrData.AllProfiles[id] = nil
			end
		end

		--Karna: Show warning popup for confirmation
		_G.PlayerDataStore:UpdateData(plrData)

		refreshSlots()
	end)
end

local lastSlotId = nil
local function updateSelectedSlot(_data :CT.ProfileSlotDataType)
	local id = _data and _data.SlotId
	
	if id then
		-- Show Selection Box to selected slot
		ui.SelectBox.Parent = ui.Slots.Container:FindFirstChild(id)

		-- Show Delete Button
		ui.Slots.Delete.Visible = true
		ui.CreateF.Container.TextBox.Text = _data.SlotName
	else
		-- Show Selection Box to create new slot
		ui.SelectBox.Parent = ui.Slots.Container.Slot

		-- Hide Delete Button
		ui.Slots.Delete.Visible = false

		-- Show Customization
		ui.Base.Customization.Visible = true
		
		if lastSlotId then
			ui.CreateF.Container.TextBox.Text = "" 
		end
	end
	
	lastSlotId = id
	
	ui.CreateF.Play.Visible = true
	ui.CreateF.Container.Visible = true
	ui.Base.Customization.Visible = true
	-- Wearing full inventory
	
	if _data then
		CF.Inventory.ApplyFullInventory(CharModel, _data)
	else
		CF.Inventory.ApplyFullInventory(CharModel, _G.SelectedSlotData:Get())
	end
end

function refreshSlots()
	local d :CT.PlayerDataModel = _G.PlayerData

	local activeSlotId = d.ActiveProfile
	ui.SelectBox.Parent = ui.Slots.Templates

	--Clean Up all previous entries
	for i, v in pairs(ui.Slots.Container:GetChildren()) do
		if(v:IsA("ImageButton")) then
			v:Destroy()
		end
	end

	local profiles = CF.Tables.SortTable(d.AllProfiles, "LastUpdatedOn")

	local order = 1
	for i, data :CT.ProfileSlotDataType in pairs(profiles) do
		local entry :SLOT = ui.Slots.Templates.Slot:Clone()
		
		if data.SlotId ~= "Default_Slot" then
			entry.Visible = true
		end
		
		entry.DataF.Level.Visible = true
		entry.DataF.LastMap.Visible = true
		entry.DataF.SlotName.Visible = true

		entry.Icon.Label.Visible = false
		entry.DataF.Create.Visible = false

		entry.Name = data.SlotId
		entry.DataF.SlotName.Text = data.SlotName
		entry.DataF.LastMap.Text = Constants.GameInventory.Maps[data.LastVisitedMap].Name
	
		local lvl = data.PlayerLevel or 0
		entry.DataF.Level.Text = "Lvl : "..lvl

		entry.LayoutOrder = order
		entry.Parent = ui.Slots.Container

		entry.Activated:Connect(function()
			_G.SelectedSlotData:Set(data, true)
		end)

		order += 1

		TWController:SubsHover(entry)
		TWController:SubsClick(entry)
	end

	do
		if order - 1 <= RS.GameElements.Configs.MaxSlots.Value then
			local create_Entry :SLOT = ui.Slots.Templates.Slot:Clone()
			create_Entry.Visible = true
			create_Entry.LayoutOrder = order
			create_Entry.Parent = ui.Slots.Container

			TWController:SubsHover(create_Entry)
			TWController:SubsClick(create_Entry)

			create_Entry.Activated:Connect(function()
				local slotDataModel = CF.PlayerData.GetSlotDataModel()
				_G.SelectedSlotData:Set(slotDataModel, true)
			end)
		end
	end

	local NextEntry = ui.Slots.Container:FindFirstChild(activeSlotId)
	if NextEntry then
		if NextEntry.Visible then
			_G.SelectedSlotData:Set(d.AllProfiles[activeSlotId], true)		
		else
			local slotDataModel = CF.PlayerData.GetSlotDataModel()
			_G.SelectedSlotData:Set(slotDataModel, true)		
		end
	else
		--CF.Inventor.Table.Tables...ApplyFullInventory(CharModel, activeSlot)
		warn("Slot entry not found", activeSlotId)
	end

end

local customFunc = {
	ToggleCharacter = function(enable)
		
		if CharModel then
			CharModel:Destroy()
			CharModel = nil
		end
		
		if enable then
			CharModel = Models.Characters.Default:Clone()
			CharModel.Parent = workspace.Scripted_Items.LoadGame
			CharModel:PivotTo(Positions.Character[1].CFrame)

			--Karna: Play Idle animation 

			local animator : Animator = CharModel:WaitForChild('Humanoid').Animator
			local animation = Instance.new('Animation')
			animation.AnimationId = "rbxassetid://12093514687"
			animator:LoadAnimation(animation):Play()

			-- Parent and Attach Dragger to the Model
			DraggerModel.Parent = workspace.Scripted_Items.LoadGame
			DraggerModel.Rotatables.Plate.WeldConstraint.Part1 = CharModel.PrimaryPart
		else
			DraggerModel.Parent = Models.Other
		end
	end,

	ToggleCamera = function(enable)
		if enable then
			RunS:BindToRenderStep("Customization", Enum.RenderPriority.Camera.Value, function()
				workspace.Camera.CameraType = Enum.CameraType.Scriptable
				workspace.Camera.CFrame = Positions.Camera.LoadGame[1].CFrame
			end)
		else
			RunS:UnbindFromRenderStep("Customization")
			
			workspace.Camera.CameraType = Enum.CameraType.Custom
			workspace.Camera.CameraSubject = player.Character or player.CharacterAdded:Wait()
		end
		
	end,
}
----------------------***************** Private Methods **********************----------------------
_G.SelectedSlotData.OnChange:Connect(function(data:CT.ProfileSlotDataType)
	if(data and data.SlotId) then
		updateSelectedSlot(data)
	else
		updateSelectedSlot()
	end
end)

----------------------***************** Public Methods **********************----------------------
function LoadGameGui:Toggle(enable:boolean)
	if(enable ~= nil) then
		enable = (enable)
	else
		enable = (not ui.Base.Visible)
	end

	-- Setup and refresh the Profile UI
	customFunc.ToggleCharacter(enable)
	customFunc.ToggleCamera(enable)

	ui.Slots.Visible = enable
	ui.CreateF.Visible = enable

	if enable then
		
		workspace:SetAttribute("GameStarted", false)
		
		ui.Base.Visible = enable
		refreshSlots()
		
		local p, o = pcall(function()
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, false)
		end)
	
	else
		task.wait(.25)
		ui.Base.Visible = false
		
		pcall(function()
			game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
		end)
	end
end

function LoadGameGui:InitReferences()
	ui.Base = self.Instance

	ui.Slots = ui.Base.Slots
	ui.CreateF = ui.Base.CreateF
	ui.SelectBox = ui.Slots.Templates.SelectBox
end

function LoadGameGui:InitButtons()
	-- Bind to Open automatically on Game got Loaded
	workspace:GetAttributeChangedSignal("GameLoaded"):Connect(function()
		local loaded = workspace:GetAttribute("GameLoaded")

		if not _G.IsHub then
			CharacterService.Setup:Fire()
			wait(.1)
			CharacterService.RedirectToMap:Fire()
			wait(.1)
			CharacterController:ToggleControls(true)
			PlayerController:ToggleControls(true)
			
			workspace:SetAttribute("GameStarted", true)
			
			LoadGameGui:Toggle(false)
			DialogueGui:Welcome()
		else
			self:Toggle(loaded)
		end
	end)
	
	if _G.IsHub then
		task.spawn(function()
			local startTime = tick()
			repeat 
				wait(0.1)
			until workspace:GetAttribute("GameLoaded") or tick() - startTime >= 20

			if not workspace:GetAttribute("GameLoaded") then
				warn("GameLoaded not set in 20 seconds. Forcing it to true.")
				workspace:SetAttribute("GameLoaded", true)
			end

			print("Loaded Properly : ")

			if not ui.Base.Visible then
				self:Toggle(true)
			end
		end)

	end
	
	-- CreateF buttons
	ui.CreateF.Play.Activated:Connect(play)

	-- SlotF
	ui.Slots.Delete.Activated:Connect(delete)
	
	-- focus changed
	ui.CreateF.Container.TextBox.FocusLost:Connect(textBoxFocusLost)
end

function LoadGameGui:Construct()
	
	CharacterService = Knit.GetService("CharacterService")

	UIController = Knit.GetController("UIController")
	TWController = Knit.GetController("TweenController")
	PlayerController = Knit.GetController("PlayerController")
	CharacterController = Knit.GetController("CharacterController")

	self.active = UIController:SubsUI(Constants.UiScreenTags.LoadGameGui, self)
end

function LoadGameGui:Start()
	warn(self," Starting...")

	LoadingGui = UIController:GetGui(Constants.UiScreenTags.LoadingGui, 2)
	DialogueGui = UIController:GetGui(Constants.UiScreenTags.DialogueGui, 2)
	NotificationGui = UIController:GetGui(Constants.UiScreenTags.NotificationGui, 2)

	if(self.active) then
		self:InitReferences()
		self:InitButtons()
	end

	TWController:SubsTween(ui.Slots, Constants.TweenDir.Right, Constants.EasingStyle.Quad, ui.Slots.Size)

	TWController:SubsHover(ui.CreateF.Save)
	TWController:SubsHover(ui.CreateF.Play)
	TWController:SubsHover(ui.Slots.Delete)
	TWController:SubsHover(ui.CreateF.Container)

	TWController:SubsClick(ui.CreateF.Save)
	TWController:SubsClick(ui.CreateF.Play)
	TWController:SubsClick(ui.Slots.Delete)

end

return LoadGameGui
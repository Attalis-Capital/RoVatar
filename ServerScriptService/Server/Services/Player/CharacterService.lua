-- @ScriptType: ModuleScript
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")

local Signal = require(RS.Packages.Signal)
local Knit = require(RS.Packages.Knit)

local Modules = RS.Modules
local misc = require(Modules.Packages.Misc)
local Constants = require(RS.Modules.Custom.Constants)
local VFXHandler = require(RS.Modules.Custom.VFXHandler)
local CT = require(RS.Modules.Custom.CustomTypes)
local CF = require(RS.Modules.Custom.CommonFunctions)
local SFXHandler = require(RS.Modules.Custom.SFXHandler)

local CharacterService = Knit.CreateService {
	Name = "CharacterService",
	Client = {
		Setup = Knit.CreateSignal(),
		RedirectToMap = Knit.CreateSignal(),
		
		UpdateState = Knit.CreateSignal(),
		UpdateStats = Knit.CreateSignal(),
		ToggleWeapon = Knit.CreateSignal(),
		RefillHealth = Knit.CreateSignal(),
	}
}

local WeaponSets = RS.Assets.Models.Combat.WeaponSets
local Pets = RS.Assets.Models.Pets

local Weapons = RS.Assets.Models.Combat.Weapons

-- Workspace Assets
local SC_Maps = workspace.Scripted_Items.Maps

------ Other Scripts Reference
local PlayerDataService

--------------->>>>>>>>>>>>>>>>>>>>>>>>>>> Private Methods <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<---------------------------

local Container = {}
local RefillHealthCooldowns = {}
local function HeartBeat(dt) -- Calling in .heartBeat
	for _, Value in pairs(Container) do
		for StateType, Data : CT.StatsDataType in pairs(Value) do
			local Factor = Data.Factor
			local Stat = Data.Stat
			if Stat then
				Stat.Value = math.clamp(Stat.Value + Factor, Data.Min, Data.Max)	
			end
		end
	end
end

local function OnStateChanged(Player, State, Data : CT.StatsDataType)
	local StateType = State.Name
	local NewState = State.Value
	local Key = tostring(Player.UserId.."Key")
	
	----- Stamina Regenerate
	if StateType == Constants.StateTypes.Move then
		Player.CombatStats.Stamina.Value = Data.Current or Player.CombatStats.Stamina.Value

		if NewState == Constants.MoveStates.Running then
			local _data = {}
			_data.Stat = Player.CombatStats.Stamina
			_data.Factor = Data.Factor or -0.025
			_data.Max = Data.Max or 100
			_data.Min = Data.Min or 0
			
			if not Container[Key] then
				Container[Key] = {}
			end
			Container[Key][StateType] = _data
		else
			local _data = {}
			_data.Stat = Player.CombatStats.Stamina
			_data.Factor = Data.Factor or .05
			_data.Max = Data.Max or 100
			_data.Min = Data.Min or 0

			if not Container[Key] then
				Container[Key] = {}
			end
			Container[Key][StateType] = _data
		end
	end
	
	------ MEDITATE, IDLE
	if StateType == Constants.StateTypes.Meditate then
		
		Player.CombatStats.Strength.Value = Data.Current or Player.CombatStats.Strength.Value
		
		if NewState == Constants.MeditateStates.Meditate then
			local _data = {}
			_data.Stat = Player.CombatStats.Strength
			_data.Factor = Data.Factor or 0.025
			_data.Max = Data.Max or 100
			_data.Min = Data.Min or 0

			if not Container[Key] then
				Container[Key] = {}
			end
			Container[Key][StateType] = _data
		else
			local _data = {}
			_data.Stat = Player.CombatStats.Strength
			_data.Factor = Data.Factor or 0.015
			_data.Max = Data.Max or 100
			_data.Min = Data.Min or 0

			if not Container[Key] then
				Container[Key] = {}
			end
			Container[Key][StateType] = _data
		end
		
	end
end

----* Stats Updation 
function UpdateState(player, Data: CT.StatsDataType)
	player.States[Data.StateType].Value = Data.State
	OnStateChanged(player, player.States[Data.StateType], Data)
end

function UpdateStats(...)
	CF.Combats.RefreshCombatControls(...)
end

function RefillHealth(plr :Player)
	local now = tick()
	local lastHeal = RefillHealthCooldowns[plr.UserId]
	if lastHeal and (now - lastHeal) < 30 then
		return -- Cooldown not expired
	end
	RefillHealthCooldowns[plr.UserId] = now

	local char = plr.Character or plr.CharacterAdded:Wait()
	local hum :Humanoid = char:WaitForChild("Humanoid")
	hum.Health = hum.MaxHealth
end

-----------------------##########** Contraints
local function SetupConstraints(char)
	local hum = char.Humanoid
	
	local spawnSFX = RS.Assets.SFXs.Sounds.Spawn:Clone()
	spawnSFX.Parent = char:WaitForChild("HumanoidRootPart")
	spawnSFX:Play()
	game.Debris:AddItem(spawnSFX, 1)
	
	char.ChildAdded:Connect(function(Object)
		if Object.Name == "Disabled" then
			--hum.WalkSpeed = 4
			--hum.JumpPower = 6 --:Karna: (TASK_ID) : 1047
			--canDash.Value = false
			--canRun.Value = false
		elseif Object.Name == "Ragdoll" then	
			if not CS:HasTag(char, "Ragdoll") then
				CS:AddTag(char, "Ragdoll")
			end
		elseif Object.Name == "OnFire" then	
			if not CS:HasTag(char, "OnFire") then
				CS:AddTag(char, "OnFire")
			end
		end
	end)

	char.ChildRemoved:Connect(function(Object)
		if Object.Name == "Disabled" then
			if not char:FindFirstChild("Disabled") then
				hum.WalkSpeed = 16
				hum.JumpPower = 50
				--canDash.Value = true
				--canRun.Value = true
			end
		elseif Object.Name == "Ragdoll" then
			if not char:FindFirstChild("Ragdoll") then
				if CS:HasTag(char, "Ragdoll") then
					CS:RemoveTag(char, "Ragdoll")
				end
			end
		elseif Object.Name == "OnFire" then
			if not char:FindFirstChild("OnFire") then
				if CS:HasTag(char, "OnFire") then
					CS:RemoveTag(char, "OnFire")
				end
			end
		end
	end)
end

---- * Spawning and updating characters
function SetupCharacter(player :Player, Respawn:boolean)

	local playerData: CT.PlayerDataModel = {}
	_G.PlayerDataStore:GetData(player, function(Data : CT.PlayerDataModel)
		if Data and Data.PersonalProfile then
			playerData = Data
		end
		
		if playerData.ActiveProfile then
			
			local activeProfile :CT.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(playerData)
			local LastMap = activeProfile.LastVisitedMap
			local LastPos = activeProfile.LastVisitedCF
			local CharId = activeProfile.CharacterId

			local OrigChar = player.Character
			local RSAssets = RS.Assets

			local Char = nil
			local Model = RSAssets.Models.Characters:FindFirstChild("Default")
			if Model then

				Char = Model:Clone()
				--Check if already same character is mounted
				
				CF.Inventory.ApplyFullInventory(player.Character, activeProfile)
				
				player.Character.Humanoid.DisplayName = activeProfile.SlotName
				
				if(player.Character:HasTag(Char.Name)) then
					Char:Destroy()
					Char = nil
					return
				end

				Char.Name = OrigChar.Name
				
				player.Character = Char
				Char.Parent = workspace

				local Animate = RSAssets.Scripts.Animate:Clone()
				local Constraint = RSAssets.Scripts.Constraint:Clone()

				Animate.Parent = Char
				Constraint.Parent = Char

				local Health = OrigChar:FindFirstChild("Health")
				if Health then
					Health:Clone().Parent = Char
				end
				
				local cf = OrigChar.PrimaryPart.CFrame
				OrigChar:Destroy()
				OrigChar = nil
				
				player.Character:PivotTo(cf)
				--CF.Transform.PivotTo(, cf, true)
			else
				local Constraint = RSAssets.Scripts.Constraint:Clone()
				Constraint.Parent = player.Character
			end
			
			
			CF.Inventory.ApplyFullInventory(Char, activeProfile)
			
			local Bool1 = Instance.new("BoolValue", player.Character)
			Bool1.Name = "IsAttacking"

			local Bool2 = Instance.new("BoolValue", player.Character)
			Bool2.Name = "Running"

			local SpawnP = SC_Maps[LastMap].Spawn:WaitForChild("Spawn")
			
			CF.Transform.PivotTo(player.Character, SpawnP, true)
			
			SetupConstraints(player.Character)
			CharacterService:OnGamePassStatusChange(player, playerData.GamePurchases.Passes) -- Bind Passes Rewards/Items with character to use. 
		else
			warn('[Error] No Active Profile Data found for character setup!')
		end

	end)

end

function RedirectToMap(player:Player)
	local playerData = {}
	_G.PlayerDataStore:GetData(player, function(Data : CT.PlayerDataModel)
		if Data and Data.Profile then
			playerData = Data
		end

		if playerData.ActiveProfile then
			local activeProfile :CT.ProfileSlotDataType = CF.PlayerQuestData.GetPlayerActiveProfile(playerData)
			local MapName = activeProfile.LastVisitedMap
			local SpawnP = SC_Maps[MapName].Spawn:WaitForChild("Spawn")
			local char = player.Character or player.CharacterAdded:Wait()
			CF.Transform.PivotTo(char, SpawnP, true)
			
			CF.Inventory.ApplyFullInventory(char, activeProfile)
			
			CharacterService:OnGamePassStatusChange(player, playerData.GamePurchases.Passes)
		else
			local MapName = Constants.GameInventory.Maps.KioshiIsland.Id
			local SpawnP = SC_Maps[MapName].Spawn:WaitForChild("Spawn")
			local char = player.Character or player.CharacterAdded:Wait()
			CF.Transform.PivotTo(char, SpawnP, true)
		end
	end)
end

--* updating Kills and Deaths on Died
local function __updateKills(Character)
	local DamageBy = Character:FindFirstChild('DamageBy')
	if DamageBy then
		local Attacker = DamageBy.Value
		if Attacker then
			local player = Players:GetPlayerFromCharacter(Attacker)
			if player then
				PlayerDataService:UpdateKills(player)
			end
		else
			warn("[Last Attacker] not found!")
		end
	else
		warn("[Damage By] not found!")
	end
end

local function __updateDeaths(Player :Player)
	PlayerDataService:UpdateDeath(Player)
end

local function _onDied(character)
	
	
	__updateKills(character)
	__updateDeaths(Players:GetPlayerFromCharacter(character))
	
	misc.Ragdoll(character, game.Players.RespawnTime+2)
end

---------------------------############** Combats
local function ToggleWeapon(player, equip, Weapon)
	if Weapon == Constants.GameInventory.Weapons.Boomerang then
		------*** Equip/UnEquip Boomerang
		if equip then
			local _weapon = Weapons.Boomerang:Clone()
			local Char = player.Character
			_weapon.Parent = Char
			
			local Boome = Char.UpperTorso:FindFirstChild("Boomerang")
			if Boome then
				Boome.Weapon.H.Transparency = 1
				Boome.Weapon.J.Transparency = 1
			end
			
		else
			local Char = player.Character
			local Boomerang = Char:FindFirstChild("Boomerang")
			if Boomerang then
				Boomerang:Destroy()
			end
			
			local Boome = Char.UpperTorso:FindFirstChild("Boomerang")
			if Boome then
				Boome.Weapon.H.Transparency = 0
				Boome.Weapon.J.Transparency = 0
			end
		end
		
		------*** Equip/UnEquip Sword
	elseif Weapon == Constants.GameInventory.Weapons.MeteoriteSword then
		if equip then
			local _weapon = Weapons.MeteoriteSword:Clone()

			local Char = player.Character
			_weapon.Parent = Char
			SFXHandler:Play(Constants.SFXs.Sheathe, true)
			
			task.delay(.25, function()
					
				local MeteoriteSword = Char.UpperTorso:FindFirstChild("MeteoriteSword")
				if MeteoriteSword then
					MeteoriteSword.Weapon.A.Transparency = 1
					MeteoriteSword.Weapon.D.Transparency = 1
					MeteoriteSword.Weapon.F.Transparency = 1
					MeteoriteSword.Weapon.G.Transparency = 1
					MeteoriteSword.Weapon.H.Transparency = 1
					MeteoriteSword.Weapon.J.Transparency = 1
					MeteoriteSword.Weapon.S.Transparency = 1
				end
			end)

		else
			local Char = player.Character
			local _weapon = Char:FindFirstChild("MeteoriteSword")
			if _weapon then
				_weapon:Destroy()
			end
			SFXHandler:Play(Constants.SFXs.UnSheathe, true)
			local MeteoriteSword = Char.UpperTorso:FindFirstChild("MeteoriteSword")
			if MeteoriteSword then
				MeteoriteSword.Weapon.A.Transparency = 0
				MeteoriteSword.Weapon.D.Transparency = 0
				MeteoriteSword.Weapon.F.Transparency = 0
				MeteoriteSword.Weapon.G.Transparency = 0
				MeteoriteSword.Weapon.H.Transparency = 0
				MeteoriteSword.Weapon.J.Transparency = 0
				MeteoriteSword.Weapon.S.Transparency = 0
			end
		end
	end
end

-------------------------------------------------------------------------
function _onCharacterAdded(character, player, firstTime)
	CS:AddTag(character, Constants.Tags.PlayerAvatar)
	character.Humanoid.Died:Once(function()
		_onDied(character)
	end)
	
	local player = Players:GetPlayerFromCharacter(character)
	SetupCharacter(player, true)
	if player:WaitForChild("CombatStats") then
		
		player.CombatStats.Stamina.Value = 100
	end
	
	if not firstTime then
		CF.UI.Blink(player, 1.5)
	end
end

function onPlayerAdded(player:Player)
	
	player.CameraMinZoomDistance = RS.GameElements.Configs.CameraMinDist.Value
	player.CameraMaxZoomDistance = RS.GameElements.Configs.CameraMaxDist.Value
	
	
	local firstTime = true
	player.CharacterAdded:Connect(function(char)
		_onCharacterAdded(char, player, firstTime)
		firstTime = false
	end)
end

function onPlayerRemoved(player:Player)


	local Key = tostring(player.UserId.."Key")
	Container[Key] = nil
	RefillHealthCooldowns[player.UserId] = nil

end
--------------->>>>>>>>>>>>>>>>>>>>>>>>>>> Public Methods <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<---------------------------

function CharacterService:OnGamePassStatusChange(player, passesData)
	
	if not passesData then
		_G.PlayerDataStore:GetData(player, function(playerData :CT.PlayerDataModel)
			if playerData.GamePurchases then
				passesData = playerData.GamePurchases.Passes
			end
		end)
	end
	
	-------------- Check activated game passes
	local IsMomoActive = passesData[Constants.IAPItems.Momo.Id]
	local IsBoomerangActive = passesData[Constants.IAPItems.Boomerang.Id]
	local IsSwordActive = passesData[Constants.IAPItems.MeteoriteSword.Id]
	local IsBlueGliderActive = passesData[Constants.IAPItems.BlueGlider.Id]
	
	----->>> Activating/Deactivating passes items
	--** Pet
	local Momo :Model = workspace.Scripted_Items.Pets:FindFirstChild(player.UserId.."'s Momo")
	if IsMomoActive then
		-- Attach pet Momo Class to the player character and set Pet as character's child
		if not Momo then
			Momo = Pets.Momo:Clone()
			Momo.Name = player.UserId.."'s Momo"
			Momo.Parent = workspace.Scripted_Items.Pets
			Momo:AddTag(player.UserId.."Momo")
			Momo.PrimaryPart:SetNetworkOwner(player)
		end
	else
		if Momo then
			Momo:Destroy()
		end
	end
	
	--** Boomerang
	if IsBoomerangActive then
		-- Check if not exist
		local parent = player.Character:WaitForChild("UpperTorso")
		
		if not parent:FindFirstChild("Boomerang") then
			-- Attach boomerang to characters back
			local Boomerang = WeaponSets.Boomerang:Clone()
			Boomerang.Parent = parent
			Boomerang.CFrame = parent.CFrame

			local weld = Instance.new("WeldConstraint", Boomerang)
			weld.Part0 = Boomerang
			weld.Part1 = parent
		end
	else
		local parent = player.Character:WaitForChild("UpperTorso")
		local _boomeRange = parent:FindFirstChild("Boomerang")
		if _boomeRange then
			_boomeRange:Destroy()
		end
	end
	
	--** MeteoriteSword
	if IsSwordActive then
		-- Check if not exist
		local parent = player.Character:WaitForChild("UpperTorso")

		if not parent:FindFirstChild("MeteoriteSword") then
			-- Attach Sword to characters back
			local MeteoriteSword = WeaponSets.MeteoriteSword:Clone()
			MeteoriteSword.Parent = parent
			MeteoriteSword.CFrame = parent.CFrame

			local weld = Instance.new("WeldConstraint", MeteoriteSword)
			weld.Part0 = MeteoriteSword
			weld.Part1 = parent
		end
	else
		local parent = player.Character:WaitForChild("UpperTorso")
		local _sword = parent:FindFirstChild("MeteoriteSword")
		if _sword then
			_sword:Destroy()
		end
	end
	
	--** Blue Glider
	if IsBlueGliderActive then
		
	else
		
	end
end

function CharacterService:KnitInit()
	
	PlayerDataService = Knit.GetService("PlayerDataService")
	
	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoved)
	
	CharacterService.Client.Setup:Connect(SetupCharacter)
	CharacterService.Client.UpdateState:Connect(UpdateState)
	CharacterService.Client.UpdateStats:Connect(UpdateStats)
	CharacterService.Client.RefillHealth:Connect(RefillHealth)
	CharacterService.Client.RedirectToMap:Connect(RedirectToMap)
	
	CharacterService.Client.ToggleWeapon:Connect(ToggleWeapon)
	
	game:GetService("RunService").Heartbeat:Connect(HeartBeat)
	
end

function CharacterService:KnitStart()
end

return CharacterService
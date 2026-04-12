-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")

local Knit = require(RS.Packages.Knit)

local Constants = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)
local SFXHandler = require(RS.Modules.Custom.SFXHandler)
local NotificationData = require(RS.Modules.Custom.NotificationData)

local rocksModule = require(RS.Modules.Packages.RocksModule)

--[[

]]
local TransportService = Knit.CreateService {
	Name = "TransportService",
	
	Client = {
		SpawnVehicle = Knit.CreateSignal(),
		DeSpawnVehicle = Knit.CreateSignal(),
	}
}

----Other services
local NotificationService

----Variables
local ScriptedItems = workspace.Scripted_Items

---- Models
local VehicleModels = RS.Assets.Models.Vehicles



--------------------------------------------->>>>>>>>>>>> Private Methods <<<<<<<<<<<<----------------------------------------------

local Vehicles = {
	[Constants.VehiclesType.AangGlider] = function(plr:Player, vehicle, ...)
		local char = plr.Character

		vehicle:AddTag(plr.UserId.."Glider")
		vehicle.Parent = char
		--vehicle.Handle.Wind:Play()
		SFXHandler:PlayAlong(Constants.SFXs.Glider_Wind, vehicle.Handle)
	end,
	
	[Constants.VehiclesType.KorraGlider] = function(plr:Player, vehicle, ...)
		local char = plr.Character

		vehicle:AddTag(plr.UserId.."Glider")
		vehicle.Parent = char
		--vehicle.Handle.Wind:Play()
		SFXHandler:PlayAlong(Constants.SFXs.Glider_Wind, vehicle.Handle)
	end,
	
	[Constants.VehiclesType.Appa] = function(plr:Player, vehicle, ...)
		local char = plr.Character

		vehicle:AddTag(plr.UserId.."Appa")
		vehicle.PrimaryPart.Massless = true
		--vehicle.Seat.Wind:Play()
		
		local finalCF = char.PrimaryPart.CFrame
		local finalCFPos = finalCF.Position + finalCF.LookVector * 20

		finalCF = CFrame.lookAt(finalCFPos, finalCF.Position)
		
		do --Check deploy feasibility
			local overlap = OverlapParams.new()
			overlap.FilterDescendantsInstances = {vehicle, plr.Character}
			overlap.FilterType = Enum.RaycastFilterType.Exclude
			
			local obj = workspace:GetPartBoundsInBox(finalCF, vehicle.PrimaryPart.Size, overlap)
			
			if(#obj > 0) then
				for i, v in pairs(obj) do
					if(v.Parent:FindFirstChild("Humanoid")) then
						--Can also show this info in notification to the user/player.
						warn(`Error: {v.Parent} Character is below the appa spawn pos`)
						vehicle:Destroy()
						
						local data :CT.NotificationDataType = NotificationData.AppaSpawnBlocked
						NotificationService:ShowMessageToPlayer(plr, data, "1")
						
						return
					end
				end
			end
		end

		--- Do Raycast
		local Params = RaycastParams.new()
		Params.FilterType = Enum.RaycastFilterType.Exclude
		Params.FilterDescendantsInstances = {char, vehicle}

		local raycastOrigin = finalCF.Position
		local raycastDirection = (finalCF * CFrame.Angles(0, 0, 45)).UpVector * -100
		local ray = workspace:Raycast(raycastOrigin, raycastDirection, Params)
		
		--- Place vehicle
		vehicle.PrimaryPart:PivotTo(finalCF)
		vehicle.Parent = char.Vehicles
		
		---Check ray and spawn deploy effect
		if ray.Instance then
			if (ray.Position - raycastOrigin).Magnitude < 40 then

				local EnemyBP = Instance.new("BodyPosition")
				EnemyBP.Name = "AirDown"
				EnemyBP.MaxForce = Vector3.new(4e4,4e4,4e4)
				EnemyBP.Position = ray.Position
				EnemyBP.P = 4e4
				EnemyBP.Parent = vehicle.Handle
				game.Debris:AddItem(EnemyBP, 1)

				rocksModule.Ground(ray.Position, 20, Vector3.new(3, 2, 3), {vehicle, workspace.Debris}, 5, false, 2.5)
				rocksModule.BlockExplosion(CFrame.new(ray.Position) * CFrame.new(0, 1, 0), 0.3, 0.7, 1, 1, false)

			end
		end
	end,
	
}

local function SpawnVehicle(player :Player, vType, ...)
	warn("SpawnVehicle request for plr:", player, "VehicleType:", vType)
	
	if(Vehicles[vType]) then

		local vehicle = VehicleModels:FindFirstChild(vType)
		if(not vehicle) then
			warn("VehicleType not found in models. type:", vType)
			return
		end
		vehicle = vehicle:Clone()
		
		--Clear previous vehicles first
		player.Character.Vehicles:ClearAllChildren()
		Vehicles[vType](player, vehicle, ...)
	else
		warn("Error in vehicles type...", vType)
	end
	
end

local function DeSpawnVehicle(player, ElementName)
	local Element :Folder = player.Character:FindFirstChild(ElementName)
	if Element then
		Element:Destroy()
		print("[Transport] Destroying...", player.Name, "'s ", Element)
	else
		player.Character.Vehicles:ClearAllChildren()
	end
end

--------------------------------------------->>>>>>>>>>>> Public Methods <<<<<<<<<<<<----------------------------------------------

function TransportService:KnitInit()
	game.Players.PlayerAdded:Connect(function(plr:Player)
		Instance.new("Folder", workspace.Scripted_Items.Transports).Name = plr.Name
		plr.CharacterAdded:Connect(function(char:Model)
			Instance.new("Folder", char).Name = "Vehicles"
		end)
	end)
	game.Players.PlayerRemoving:Connect(function(plr:Player)
		workspace.Scripted_Items.Transports[plr.Name]:Destroy()
	end)
	
	self.Client.SpawnVehicle:Connect(SpawnVehicle)
	self.Client.DeSpawnVehicle:Connect(DeSpawnVehicle)
end

function TransportService:KnitStart()
	NotificationService = Knit.GetService("NotificationService")
end

return TransportService
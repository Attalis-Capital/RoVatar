-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local Knit = require(RS.Packages.Knit)

local ADMIN_IDS = {[20408842]=true, [7907420796]=true, [8601516755]=true, [7543437207]=true, [3719953502]=true}

---------> Other scripts references
local DevService = Knit.CreateService {
	Name = "DevService",
	Client = {
		UpdateLiveDevMode = Knit.CreateSignal(),
	}
}

----------------------------------------------------------->  Private Methods And Fields  <------------------------------------------------------


function UpdatePlayerLiveDevMode(plr:Player, devMode:boolean)
	if(devMode ~= nil) then
		plr:SetAttribute("LiveDevMode", devMode)
	end
end

---------------------------------------------------------------->  Public Methods  <------------------------------------------------------

local logsOn = false
function DevService.Client:ToggleServerLogs()
	logsOn = not logsOn

	return logsOn
end

function DevService.Client:ResetPlayerInfoClick(player, playerId)
	if not ADMIN_IDS[player.UserId] then return end
	print("DevScript--> ResetPlayerInfo clicked:", playerId)
	_G.PlayerDataStore:RemovePlrData(player, playerId)
	if(not playerId) then
		_G.PlayerDataStore:Save(player)
	end
end



function DevService:KnitInit()
	self.Client.UpdateLiveDevMode:Connect(UpdatePlayerLiveDevMode)
end

function DevService:KnitStart()
	print("DevScript Knit Started......")
end

return DevService

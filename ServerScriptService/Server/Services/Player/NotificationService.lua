-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(RS.Packages.Knit)

local CT = require(RS.Modules.Custom.CustomTypes)

local NotificationService = Knit.CreateService {
	Name = "NotificationService",
	playersFunctionHolder = {},
	Client = {
		ShowMessageEvent = Knit.CreateSignal(),
		OkYesEvent = Knit.CreateSignal(),
		NoEvent = Knit.CreateSignal(),
	}
}

---------------------------------------------------------->  Private Methods  <------------------------------------------------------

---------------->>>>>>>>>>>> Bindings Callbacks <<<<<<<<<<<<--------------------

function OkYesCallback(player:Player, caller)
	local plrFunction = NotificationService.playersFunctionHolder[player.UserId]
	if (plrFunction and plrFunction[caller]) then
		if(plrFunction[caller]["OkYesFunc"] ~= nil) then
			local func = NotificationService.playersFunctionHolder[player.UserId][caller]["OkYesFunc"]
			func(player, caller)
			NotificationService.playersFunctionHolder[player.UserId][caller] = nil
		end
	end
end

function NoCallback(player:Player, caller)
	local plrFunction = NotificationService.playersFunctionHolder[player.UserId]
	if(plrFunction and plrFunction[caller]) then
		if(plrFunction[caller]["NoFunc"] ~= nil) then
			local func = plrFunction[caller]["NoFunc"]
			func(player, caller)
			NotificationService.playersFunctionHolder[player.UserId][caller] = nil
		end
	end
end

---------------------------------------------------------->  Public Methods  <-------------------------------------------------------

function NotificationService:ShowMessageToPlayer(player:Player | number, popupData:CT.PopupDataType, callerId,  OkYesFunc :() -> (), NoFunc :() -> ())
	if(popupData == nil) then
		--warn("MessageData cannot be empty. What to send lol:(")
		return
	end
	
	player = typeof(player) == "number" and game.Players:GetPlayerByUserId(player) or player
	if not player or not game.Players:FindFirstChild(player.Name) then
		print("Player is not available: will use MessageService to send cross server notification : ")
		return
	end
	
	if player then
		--print("Got call to showMessage from caller:", caller)
		self.Client.ShowMessageEvent:Fire(player, popupData, callerId)

		if OkYesFunc or NoFunc then
			if(self.playersFunctionHolder[player.UserId] == nil) then
				self.playersFunctionHolder[player.UserId] = {}
			end
			self.playersFunctionHolder[player.UserId][callerId] = {}
			if(OkYesFunc) then
				self.playersFunctionHolder[player.UserId][callerId]["OkYesFunc"] = OkYesFunc
			end
			if(NoFunc) then
				self.playersFunctionHolder[player.UserId][callerId]["NoFunc"] = NoFunc
				task.delay(10, function() NoCallback(player, callerId) end)
			end
		end
	end
end

local function CleanUp(player: Player)
	if not player or not player.UserId then return end

	local uid = player.UserId
	local stored = NotificationService.playersFunctionHolder[uid]
	if not stored then return end

	-- Call NoFunc for each caller (pcall to avoid crashing)
	for callerId, funcs in pairs(stored) do
		if funcs and type(funcs) == "table" and funcs.NoFunc then
			local ok, err = pcall(funcs.NoFunc, player, callerId)
			if not ok then
				warn("[NotificationService] Error calling NoFunc for", player.Name, "callerId", tostring(callerId), err)
			end
		end
	end

	-- remove the player's entry
	NotificationService.playersFunctionHolder[uid] = nil
end

function NotificationService:KnitInit()
	self.Client.OkYesEvent:Connect(OkYesCallback)
	self.Client.NoEvent:Connect(NoCallback)
	Players.PlayerRemoving:Connect(CleanUp)
end

function NotificationService:KnitStart()

end

return NotificationService
-- @ScriptType: ModuleScript
-- Stateless helper for awarding element XP on ability hits (server-side only)
local RS = game:GetService("ReplicatedStorage")

local ElementXp = {}

function ElementXp.Award(plr: Player, element: string, xpAmount: number)
	_G.PlayerDataStore:GetData(plr, function(playerData)
		local CF = require(RS.Modules.Custom.CommonFunctions)
		CF.PlayerData.UpdateElementXpInPlayerData(playerData, element, xpAmount)

		-- Sync attribute so DamageCalc can read it without GetData
		local activeProfile = CF.PlayerQuestData.GetPlayerActiveProfile(playerData)
		local elData = activeProfile.Data.ElementLevels[element]
		if elData then
			plr:SetAttribute("ElementLevel_" .. element, elData.Level)
		end

		_G.PlayerDataStore:UpdateData(plr, playerData)
	end)
end

return ElementXp

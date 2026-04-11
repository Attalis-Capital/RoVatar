-- @ScriptType: ModuleScript
local CommonFunctions = {}

local CT = require(script.Parent.CustomTypes)
local CD = require(script.Parent.Constants)

local utils = script.Utils
----------------------***************** General Methods **********************----------------------
CommonFunctions.Number = require(utils.Number)

-- Inlined from: Modules/Custom/CommonFunctions/Utils/String.lua (cleanup sprint)
CommonFunctions.String = {
	--Returns string after 1st number is detected in given string. Like "Classic3v3" -> "3v3"
	FirstNumToLast = function(inputString)
		-- Find the position of the first digit in the string
		local startIndex = string.find(inputString, "%d")
		if startIndex then
			-- Return the substring starting from the first number
			return string.sub(inputString, startIndex)
		end
		-- Return empty if no number is found
		return ""
	end,
}

CommonFunctions.Time = require(utils.Time)

CommonFunctions.UI = require(utils.UI)

CommonFunctions.Tables = require(utils.Tables)

CommonFunctions.Transform = require(utils.Transform)

-- Inlined from: Modules/Custom/CommonFunctions/Utils/MPS.lua (cleanup sprint)
CommonFunctions.MPS = {
	GetProductInfo = function(productId:number, infoTyp:Enum.InfoType?)

		local s, r = pcall(function()
			return game:GetService('MarketplaceService'):GetProductInfo(tonumber(productId), infoTyp)
		end)

		if(s) then
			return r
		end

		return nil
	end,
}
----------------------***************** General Methods **********************----------------------

CommonFunctions.Value = require(utils.Value)

---------------->>>>>>>>>>>********* Models **********>>>>>>>>>>>>>>>>>>-----------------

CommonFunctions.Inventory = require(utils.Inventory)
---------------->>>>>>>>>>>********* Models **********>>>>>>>>>>>>>>>>>>-----------------

---------------->>>>>>>>>>>********* Combats *********>>>>>>>>>>>>>>>>>>-----------------
CommonFunctions.Combats = require(utils.Combats)
---------------->>>>>>>>>>>********* Combats **********>>>>>>>>>>>>>>>>>>-----------------

---------------->>>>>>>>>>>********* Calculations and Formulas **********>>>>>>>>>>>>>>>>>>-----------------
CommonFunctions.Calculations = require(utils.Calculations)

---------------->>>>>>>>>>>********* Calculations and Formulas **********>>>>>>>>>>>>>>>>>>-----------------

----------------*** Validations

CommonFunctions.Validations = require(utils.Validations)

----------------*** Validations
---------- Data Store Base Functions

--------**** Player Data
CommonFunctions.PlayerData = require(utils.Player.PlayerData)

--------**** Player Quest Data
CommonFunctions.PlayerQuestData = require(utils.Player.PlayerQuestData)

--------**** Element XP & Damage Scaling
CommonFunctions.ElementXp = require(utils.ElementXp)
CommonFunctions.DamageCalc = require(utils.DamageCalc)

return CommonFunctions
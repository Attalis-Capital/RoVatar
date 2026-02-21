-- @ScriptType: ModuleScript
local CommonFunctions = {}

local CT = require(script.Parent.CustomTypes)
local CD = require(script.Parent.Constants)

local utils = script.Utils
----------------------***************** General Methods **********************----------------------
CommonFunctions.Number = require(utils.Number)

CommonFunctions.String = require(utils.String)

CommonFunctions.Time = require(utils.Time)

CommonFunctions.UI = require(utils.UI)

CommonFunctions.Tables = require(utils.Tables)

CommonFunctions.Transform = require(utils.Transform)

CommonFunctions.MPS = require(utils.MPS)
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
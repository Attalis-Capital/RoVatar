-- @ScriptType: ModuleScript
------------------------------->>>>>>>******
-- warn/print overrides REMOVED (sprint 5a) — silenced save failures and security rejections.
-- Original no-ops disabled all diagnostics; now uses Roblox's built-in warn/print.
------------------------------->>>>>>>******

--[[--------------------------------------------------------------------------------------------------
-------------------/ Structure \-------------------------
# Top Level - array of DataStores :: {"PlayerData", "QuestData", "DailyChallenges", "MVP", etc}
# 
# Possible Methods:- GetData, SaveData, OnUpdate, OrderedData
# 
# Event System :- Remote Events (GetData, SaveData) // BindableEvents (OnUpdate)
# 
# 

Setup Store using the following structure:-

{Name = "_PlayerData_", KeySuffix = "_Data", Config = {AutoSave = 60},CurrVersion = 0.1},


--------------------------------------------------------------------------------------------------]]--

---------- CONFIGURATIONS
local configs = {
	AutoSave = 30, -- in sec

}

---------- CONFIGURATIONS

type logEntries = {
	LoginStartTime :DateTime, --When user's logged-in for the first time
	LoginEndTime : DateTime, --When user logged-out
	LastLoginTime : DateTime, --When user's last logged-in
	LastLogoutTime : DateTime, --When user's last logged-out
	TotalTimeSpent : number, --Total time spent in game in seconds
	NumberOfLogins : number, --Total number of logins
	NumberOfLogouts : number, --Total number of logins
	NumberOfSaves : number, --Total number of saves
	NumberOfUpdates : number, --Total number of updates
	NumberOfGetData : number, --Total number of GetData calls
	NumberOfOrderedData : number, --Total number of OrderedData calls


	LastUpdateTime : DateTime, --Last updated time of data
	LastUpdatedElement : string, --Last property/element of data updated
}

--Like custom RemoteEvents, RemoteFunctions, DataReplicator's instance on Store basis, etc.
type element = {
	obj : Instance,
	class : {},
}

type moduleReturnType = {
	GetData : (plr, fn)->(),
	GetStore : (plr)->(CT.StoreDataType),
	UpdateStoreSettings : (autoSaveTime)->(),
	Save : (plr)->(boolean),
	GetOtherStoreData : (storeName, plr)->(plrData),
	ListenChange : (plr, fn)->(RBXScriptConnection),
	ListenSpecChange : (plr, path, fn)->(RBXScriptConnection),
	UpdateData : (plr, data)->(),
	UpdateSpecData : (plr, path, data)->(),
	RemovePlr : (plr, saveData)->(),
	RemovePlrData : (plr)->(),
}

type storeSetupDetails = {
	Name : string, KeySuffix :string, Config : {AutoSave :number}, CurrVersion : number,
}

--Karna: Can also add some other helping methods like Get player's friends, etc basic info.


local RS = game:GetService("ReplicatedStorage")
local DSS = game:GetService("DataStoreService")
local HS = game:GetService('HttpService')
local RunS = game:GetService("RunService")

---# Helpers
local Helpers = script.Parent.Helpers
local Constants = require(Helpers.Consts)
local CT = require(Helpers.Types)
local CF = require(Helpers.CF)

---# Communication
local Comm = script.Parent.Comm
local Server = require(Comm.Server)

local RuntimeF = script.Parent.Runtime

type Players_Info = {
	[string] :CT.PlayerData, --key = "Player.User + store._keySuffix" , Value = CT.PlayerData
}


---^^^^^^^^^^^^^^^^^^ COMMON AMONG STORES INSTANCES ^^^^^^^^^^^^^^^^^^^---
local Stores :CT.StoresData = {} --Key = "StoreName" Value = "{Name :string = storeName, KeySuffix :string = keySuffix, StoreObj :DataStore = nil, Instance = "Class-Instance"}"
local StoreNames = {} -- Array of total store names
---__________________ COMMON AMONG STORES INSTANCES ___________________---

local infoTemp :Players_Info = {}



---^^^^^^^^^^^^^^^^^^ COMMON AMONG STORES INSTANCES ^^^^^^^^^^^^^^^^^^^---

function OnPlayerAdded(self, plr: Player)
	self:GetData(plr, function(d)
	end)
end

function OnPlayerLeaving(self, plr: Player)
	local key = plr.UserId..self._keySuffix
	if(self._plrsInfo[key]) then
		self:Save(plr)
		-- Always clean up player state, even if save failed (prevents memory leak)
		self._plrsInfo[key].Listeners.WholeData:Destroy()
		self._plrsInfo[key] = nil

		local i = table.find(self._setupPlrs, plr.UserId)
		if(i) then
			table.remove(self._setupPlrs, i)
		end
	end
end


---^^^^^^^^^^^^^^^^^^ COMMON AMONG STORES INSTANCES ^^^^^^^^^^^^^^^^^^^---

--[[

]]
local DataServer = {}
DataServer.__index = DataServer
--DataServer.ClientSide = {}


-------------------------- Setup  ---------------------------------

-----------------------------------------------^^^^^ Setup & Init Stores ^^z^^^----------------------------------------------
--[[
details : {} = Full details setup the DataStore.
details.Name :string = The name of your DataStore. Like "PlayerData", "DailyChallenges", "Leaderboard", etc
details.KeySuffix :string = the suffix you want to use for player's key to make it more unique.
handlePlayers :boolean (Optional) = Means whether player's adding/removed controlled by DataReplicator for data purpose. 
						If true, then DataReplicator will handle all player's data by itself. whenever new player joins or leaves.
						Else, dev has to manage player's joining/leaving and saving data on Roblox-Server.
defaultDataTemp :any = The default template of data for the players. Default data preset when very new player joins the game. 
						Note: This would only work if "handlePlayers" property is set to true.
]]

--Setup the DataReplicator class for server
function DataServer.SetupStore(details:storeSetupDetails, handlePlayers :boolean?, defaultDataTemp: any) : moduleReturnType
	if(Stores[details.Name]) then
		warn("Store already setup!")
		return Stores[details.Name].Instance
	end
	warn("[DataReplicator] Received call to SetupStore:", details.Name)
	if(handlePlayers) then
		assert((defaultDataTemp), "If handlePlayers is true, then must provide the defaultTemplate of data.")
	end
	
	local self = setmetatable({}, DataServer)
	self.__index = self
	self.__tostring = function()
		return "Component<" .. self .. "> DataServer :)"
	end

	self.ClientSide = {}
	--Setup parameters
	self._StoreObj = nil
	self._storeName = details.Name
	self._keySuffix = details.KeySuffix
	self._currVersion = details.CurrVersion
	self._handlePlayers = handlePlayers
	self._defaultData = defaultDataTemp
	self._plrsInfo = table.clone(infoTemp) --key = : "Player.UserId..self.keySuffix", Value :Players_Info
	self._lastSavedData = {} -- key = "Player.UserId..self.keySuffix", Value = CT.PlayerData
	self._setupPlrs = {} --Array of "Player.UserId". only those whose data is being tracking by this store. --Note: can use UserId to get any player's data even if he's not in this server. 
	self._nonPlayingPlrsData = {} --Data of plrs not playing at this server. Like any friend's data. 

	--Setup variables
	self._autoSaveTimer = 0
	self._initialised = false
	self._config = details.Config or table.clone(configs)
	self._internalConn = {}

	if(not self:InitStore()) then
		warn("Something went worng with Store Setup. :((")
		return
	end
	
	self:Establish()
	self:AutoSave()
	
	if(typeof(self.HearbeatUpdate) == "function") then
		self._internalConn["HearbeatUpdate"] = RunS.Heartbeat:Connect(function(dt)
			self:HearbeatUpdate(dt)
		end)
	end

	table.insert(StoreNames, 1, details.Name)
	return self
end

--# Init the store and on self class and setup for run
function DataServer:InitStore()
	--print("Fetching DataStore:", self._storeName)
	local s, r = pcall(function()
		return DSS:GetDataStore(self._storeName)
	end)

	--print("After initStore:", s, r)
	if(s) then
		Stores[self._storeName] = {Name = self._storeName, KeySuffix = self._keySuffix,
			StoreObj = r, Instance = self}
		
		self._StoreObj = r
		self._initialised = true
		--print("Init DataStore successfully :",self._storeName)
	else

		--print("Something went wrong while fetching DataStore :",self._storeName, r)
		self._initialised = false
	end
	
	return self._initialised
end

--# Establish the Store publically and expose client-side elements
function DataServer:Establish()
	if(RuntimeF.Server:FindFirstChild(self._storeName)) then
		warn(self, "- Already established!")
		return
	end


	-------------------------------------------^^^^^ Client-Side Functions ^^^^^--------------------------------------------
	function self.ClientSide:GetData(plr:Player, storeName:string)
		assert(storeName, "Invalid or nil StoreName received from client:",plr)

		local store :CT.StoreDataType = Stores[storeName]
		if(store) then
			local key = plr.UserId..self._keySuffix
			if(store.Instance._plrsInfo[key]) then
				return store.Instance._plrsInfo[key].Data:Get()
			end

			return nil 
		end
	end

	function self.ClientSide:GetPlrData(plr:Player, plrUserId:number)
		--print("Received calll here:", plr, plrUserId)
		assert(plrUserId, "Invalid or nil plrUserId. Invalid request from plr:",plr)
		
		--print("self here:", DataServer, self, self._keySuffix, self._plrsInfo)
		
		local key = plrUserId..self._keySuffix
		
		if(self._plrsInfo[key]) then
			--Playing plr data requested
			return self._plrsInfo[key].Data:Get()
		else
			--Non playing plr's data requested
			if(self._nonPlayingPlrsData[key]) then
				return self._nonPlayingPlrsData[key]
			else
				--Try to fetch anonomus plr's data if found on DataStore
				warn(self._storeName, "Fetching NPP data from R_Server for userId:", plrUserId)
				local s, result = pcall(function()
					return self._StoreObj:GetAsync(key)
				end)

				print(self._storeName, "Getdata:",s, result)
				local data = nil

				if(s and result) then
					warn(self._storeName, "PlayerData FOUND result:", result)
					data = result
				end

				--Fill player's info if data is found
				if(data) then
					self._nonPlayingPlrsData[key] = data
				end

				return data
			end
		end
	end
	
	function self.ClientSide:PingTest(plr:Player)
		--print(" - player testing ping check: ", plr)

		return true
	end

	--Setup Communication Mediums
	do
		
		--AutoSaveAlert before 1 second auto save
		self.AutoSaveAlert = Server.CreateSignal()
		
		--Setup Store's Folder
		self._InstanceF = Instance.new("Folder", RuntimeF.Server)
		self._InstanceF.Name = self._storeName

		--Setup Child folders
		self._RE = Instance.new("Folder", self._InstanceF)
		self._RE.Name = "RE"
		self._RF = Instance.new("Folder", self._InstanceF)
		self._RF.Name = "RF"

		--Remote Events
		self.ClientSide.Server = self
		--Client listens, Server fires
		self.ClientSide.InitData = Server.CreateEvent(self._RE, "InitData") --For very first time data initialization on client side.
		self.ClientSide.ListenChange = Server.CreateEvent(self._RE, "ListenChange") --Client listens, Server fires (whole data)

		--Client fires, Server listens
		self.ClientSide.UpdateDataRqst = Server.CreateEvent(self._RE, "UpdateDataRqst") --Client fires, Server listens (whole data)

		--Client fires, Server listens
		self.ClientSide.ClientConnected = Server.CreateEvent(self._RE, "ClientConnected") --Client fires, Server listens (specific key)

		--Setup Remote Function calls
		for name, v in pairs(self.ClientSide) do
			if(typeof(v) == "function") then
				Server.BindFunction(self._RF, name, self)
			end
		end


		--Listen for client events (with rate limiting)
		local lastUpdate = {}
		self.ClientSide.UpdateDataRqst:Connect(function(player: Player, data: any)
			local now = tick()
			if lastUpdate[player.UserId] and (now - lastUpdate[player.UserId]) < 1 then return end
			lastUpdate[player.UserId] = now
			self:DataReceivedFromClient(player, data)
		end)

		-- Clean up rate limit tracking on player leave
		game.Players.PlayerRemoving:Connect(function(player)
			lastUpdate[player.UserId] = nil
		end)

		self.ClientSide.ClientConnected:Connect(function(player: Player)
			warn(player, "[ClientConnected] with store:", self._storeName)
			self:GetData(player, function(...)
				self.ClientSide.InitData:Fire(player, ...)
			end)
		end)
	end
	
	--Setup Auto Handle Players process
	if(self._handlePlayers and self._defaultData) then
		self:AutoSetupPlayers()
	end
end

function DataServer:AutoSetupPlayers()
	warn(self._storeName, "[DataReplicator] AutoSetupPlayers started!!")
	for i, plr in pairs(game.Players:GetPlayers()) do
		OnPlayerAdded(self, plr)
	end
	
	game.Players.PlayerAdded:Connect(function(plr)
		OnPlayerAdded(self,plr)
	end)
	game.Players.PlayerRemoving:Connect(function(plr)
		OnPlayerLeaving(self,plr)
	end)
end

function DataServer.GetStore(storeName:string) :CT.StoreDataType
	--print("GetStore :", storeName, Stores)
	assert(Stores[storeName]," Given store name not found:", Stores)
	return Stores[storeName].Instance
end
----------------------------------------------^^^^^ Settings Functions ^^^^^----------------------------------------------
--# Update this store's settings. Like autoSaveTime, etc
function DataServer:UpdateStoreSettings(autoSaveTime:number)
	self._config.AutoSave = autoSaveTime
end

--# Saves all player's OR soecific player's data stored in self DataStore To Roblox
function DataServer:Save(plr:Player?, dataToSave:any?)
	local function sav(key, dataToSave)
		--print("Data to save:", dataToSave)
		if(CF:MatchTables(self._lastSavedData[key], dataToSave)) then
			warn(key," Data has no change/difference from last saved data. Should not make this call! currData:", dataToSave,"::lastSaved::", self._lastSavedData[key])
			return
		end
		
		local MAX_RETRIES = 3
		local s, r
		for attempt = 1, MAX_RETRIES do
			s, r = pcall(function()
				return self._StoreObj:SetAsync(key, dataToSave)
			end)
			if s then break end
			if attempt < MAX_RETRIES then
				warn("[DataSave] Attempt", attempt, "failed for", key, ":", r, "— retrying...")
				task.wait(2 ^ attempt)
			end
		end

		if not s then
			warn("[DataSave] FAILED after", MAX_RETRIES, "attempts for", key, ":", r)
		else
			warn("[DataSave] Successfully for plrKey:", key, r)
			self._lastSavedData[key] = dataToSave
		end

		return s
	end 
	
	if(plr) then
		if(typeof(plr) == "number") then
			local key = plr..self._keySuffix

			print(self._storeName," Saving data for singlePlayer:",plr)
			return sav(key, dataToSave)
			
		else
			local key = plr.UserId..self._keySuffix
			if(not self._plrsInfo[key]) then
				return false
			end

			print(self._storeName," Saving data for singlePlayer:",plr)
			return sav(key, self._plrsInfo[key].Data:Get())
		end
		
	else
		warn("[DataReplicator] saving all entries on Server:", self._storeName, self._plrsInfo)
		for key, plrInfo :CT.PlayerData in pairs(self._plrsInfo) do
			sav(key, plrInfo.Data:Get())
		end
	end
end


-------------------------------------------------^^^^^ Get Functions ^^^^^----------------------------------------------
--[[
This will also setup the given player if his data was not setup in this store.

player: (Player OR number) = Can pass player as "Player" or "Plater.UserId" to get his data from this store.
]]
function DataServer:GetData(player: Player | number, callback:(any, boolean)->())
	--# GetData of specified player corresponding to the self DataStore
	local userId = typeof(player) == "number" and player or player.UserId
	local key = userId..self._keySuffix
	--print("GetData called:", player, self._plrsInfo[key])
	if(not self._plrsInfo[key]) then
		--Fetch player's Data from STORE
		warn(self._storeName, "Fetching data from R_Server for plr:", player)
		local MAX_RETRIES = 3
		local s, result
		for attempt = 1, MAX_RETRIES do
			s, result = pcall(function()
				return self._StoreObj:GetAsync(key)
			end)
			if s then break end
			if attempt < MAX_RETRIES then
				warn(self._storeName, "GetAsync attempt", attempt, "failed:", result, "— retrying...")
				task.wait(2 ^ attempt)
			end
		end

		if not s then
			warn("[DataServer] GetAsync FAILED after", MAX_RETRIES, "attempts for", key, ":", result)
			if callback then callback(nil, false) end
			return
		end

		print(self._storeName, "Getdata:", s, result)
		local isFirstTime = false
		local data = nil

		if(s and result) then
			warn(self._storeName, "PlayerData FOUND result:", result)
			data = result
		elseif(s and not result) then
			isFirstTime = true
			warn(self._storeName, "PlayerData NOT found on Store. Response:", result)
			if(self._defaultData) then
				print(data, "Setting Default data::", self._defaultData)
				if(typeof(self._defaultData) == "table") then
					data = table.clone(self._defaultData)
				else
					data = self._defaultData
				end
			end
		end
		
		--print("Data::", data)
		--Fill player's info if data is found
		if(data) then
			if(not self._plrsInfo[key]) then
				local pData :CT.PlayerData = {} do
					pData.Key = key
					--pData.PlayerObj = player
					pData.Data = CF.Value(data)
					pData.Listeners = {}

					pData.Listeners.WholeData = Server.CreateSignal()
					pData.Listeners.PathsSpecific = {} --Key "Data Path", value = CT.PathSpecificType
					self._plrsInfo[key] = pData

					table.insert(self._setupPlrs, userId)
				end
				
				warn("[DataReplicator] Created new playerInfo in store:", self._storeName, pData)
			end
		end
		
		if(callback) then
			callback(CF:CloneTable(data), isFirstTime)
		end
	else
		if(callback) then
			local data = self._plrsInfo[key].Data:Get()
			callback(CF:CloneTable(data), false)
		end
	end
end

--# Get Data of other Stores using self store's Class-Instance
function DataServer:GetOtherStoreData(storeName, player:Player, callback:() ->())
	print(self._storeName," Fetching other store:", storeName, "For player:",player)
	assert(Stores[storeName], "Specified storeName is not valid or not setup yet.")
	assert(callback, "callback is required.")

	if(Stores[storeName]) then
		Stores[storeName].Instance:GetData(player, callback)
	end
end

--# Get any player data with userId
function DataServer:ReadData(UserId, callback:(any, boolean)->())
	--# GetData of specified player corresponding to the self DataStore
	local key = UserId..self._keySuffix

	if(not self._plrsInfo[key]) then
		--Fetch player's Data from STORE
		local s, result = pcall(function()
			return self._StoreObj:GetAsync(key)
		end)

		--print(self._storeName, "Getdata:",s, result)
		local isFirstTime = false
		local data = nil

		if(s and result) then
			data = result
		elseif(s and not result) then
			isFirstTime = true
		
			if(self._defaultData) then
				if(typeof(self._defaultData) == "table") then
					data = table.clone(self._defaultData)
				else
					data = self._defaultData
				end
			end
		end

		----print("Data::", data)
		if(callback) then
			callback(CF:CloneTable(data), isFirstTime)
		end
	else
		if(callback) then
			local data = self._plrsInfo[key].Data:Get()
			callback(CF:CloneTable(data), false)
		end
	end
end

----------------------------------------------^^^^^ Listen Functions ^^^^^----------------------------------------------
--[[
This is fire the event whenever given plr's data changes.
return RBXScriptConnection

]]
--# Listen whole player's data change event. ->One Way Communication<-
function DataServer:ListenChange(plr:Player, fn:()->()) :RBXScriptConnection
	local key = plr.UserId..self._keySuffix
	assert(table.find(self._setupPlrs, plr.UserId), "Player is not setup yet. Cannot listen for change.")
	
	if(not self._plrsInfo[key]) then
		warn("Player not setup in ListenChange()")
		return nil
	end

	if(not self._plrsInfo[key].Listeners.WholeData) then
		self._plrsInfo[key].Listeners.WholeData = Server.CreateSignal()
	end
	
	local conn = self._plrsInfo[key].Listeners.WholeData:Connect(fn)
	return conn
end

--[[
plr: Player = Player whose data change to specific path to listen
path : string = A valid path of data.
fn : function (NewVal, OldVal) = callback function when specified path's value is changed/updated.

return : RBXScriptConnection = Connection to specific path change is returned
]]
--# Listen for specific key change in player's data. *->One Way Communication<-
function DataServer:ListenSpecChange(plr:Player, path:string, fn :(any, any, any) -> ()) :RBXScriptConnection
	assert(fn, "Require function if you want to listen for data change.")
	assert(table.find(self._setupPlrs, plr.UserId), "Player is not setup yet. Cannot listen for specific change.")

	local key = plr.UserId..self._keySuffix
	if(not self._plrsInfo[key].Listeners.PathsSpecific[path]) then
		self._plrsInfo[key].Listeners.PathsSpecific[path] = 
			setmetatable({}, CF.GetLength)
	end
	
	local conn = self:ListenChange(plr, function(data)
		if(data) then
			local newVal = CF:ValidatePath(data, path)

			if(newVal) then
				local oldData = self._plrsInfo[key].Data:GetPreVal()
				local oldValue = CF:ValidatePath(oldData, path)
				
				if oldValue and (not CF:MatchTables(oldValue, newVal)) then
					for i, d:CT.PathsSpecificType in pairs(self._plrsInfo[key].Listeners.PathsSpecific[path]) do
						if(d.Conn) then
							task.spawn(function()
								d.Func(newVal, oldValue, data)
							end)
						else
							warn("[PathSpecific] Connection was disconnected!!")
						end
					end
				end
			end
		end
	end)

	table.insert(self._plrsInfo[key].Listeners.PathsSpecific[path], {Conn = conn, Func = fn})
	
	return conn
end

----------------------------------------------^^^^^ Update Functions ^^^^^----------------------------------------------
--# Validate that protected fields did not increase from client data
-- Returns false if a numeric field increased (client should never raise these)
local function fieldIncreased(cur, inc)
	return typeof(cur) == "number" and typeof(inc) == "number" and inc > cur
end

local function validateClientData(currentData, incomingData, plrName)
	if typeof(currentData) ~= "table" or typeof(incomingData) ~= "table" then return true end

	-- Top-level protected fields
	for _, field in ipairs({"Gold", "Gems", "TotalXP"}) do
		if fieldIncreased(currentData[field], incomingData[field]) then
			warn("[SECURITY] Rejected: " .. field .. " increased for " .. tostring(plrName))
			return false
		end
	end

	-- Protect GamePass purchases — passes can never be added by client
	local curPasses = currentData.GamePurchases and currentData.GamePurchases.Passes
	local incPasses = incomingData.GamePurchases and incomingData.GamePurchases.Passes
	if typeof(curPasses) == "table" and typeof(incPasses) == "table" then
		for passId, owned in pairs(incPasses) do
			if owned and not curPasses[passId] then
				warn("[SECURITY] Rejected: GamePass", passId, "spoofed for", tostring(plrName))
				return false
			end
		end
	end

	-- Per-profile protected fields
	if typeof(currentData.AllProfiles) ~= "table" or typeof(incomingData.AllProfiles) ~= "table" then return true end
	for profileKey, curProfile in pairs(currentData.AllProfiles) do
		local incProfile = incomingData.AllProfiles[profileKey]
		if typeof(curProfile) ~= "table" or typeof(incProfile) ~= "table" then continue end

		if fieldIncreased(curProfile.PlayerLevel, incProfile.PlayerLevel)
			or fieldIncreased(curProfile.XP, incProfile.XP) then
			warn("[SECURITY] Rejected: profile field increased for " .. tostring(plrName))
			return false
		end

		local curStats = curProfile.Data and curProfile.Data.PlayerStats
		local incStats = incProfile.Data and incProfile.Data.PlayerStats
		if typeof(curStats) == "table" and typeof(incStats) == "table"
			and fieldIncreased(curStats.Kills, incStats.Kills) then
			warn("[SECURITY] Rejected: Kills increased for " .. tostring(plrName))
			return false
		end
	end

	return true
end

--# Update data on the server. ->Two Way Communication<
function DataServer:DataReceivedFromClient(plr:Player, data:any)
	assert(data, "Nil or invalid data in store:", self)
	assert(table.find(self._setupPlrs, plr.UserId), "Player is not setup yet. Cannot update data.")

	local key = plr.UserId..self._keySuffix
	local currentData = self._plrsInfo[key].Data:Get()

	-- Validate protected fields before accepting client data
	if not validateClientData(currentData, data, plr.Name) then
		return
	end

	if(not CF:MatchTables(currentData, data)) then
		self._plrsInfo[key].Data:Set(data)
		self._plrsInfo[key].Listeners.WholeData:Fire(data)
	end
end

--# Update data on the server. ->Two Way Communication<
function DataServer:UpdateData(plr:Player, data:any)
	assert(data, "Nil or invalid data in store:", self)
	assert(table.find(self._setupPlrs, plr.UserId), "Player is not setup yet. Cannot update data.")
	
	local key = plr.UserId..self._keySuffix
	--print("Old data:", self._plrsInfo[key].Data:Get(), data)
	if(not CF:MatchTables(self._plrsInfo[key].Data:Get(), data)) then
		self._plrsInfo[key].Data:Set(data)
		
		self.ClientSide.ListenChange:Fire(plr, data)
		self._plrsInfo[key].Listeners.WholeData:Fire(data)
	else
		--print("No change detected in data.", self)
	end
end

function DataServer:UpdateSpecData(plr: Player, path:string, newVal:any)
	assert(newVal, "Nil or invalid data:",self)
	assert(table.find(self._setupPlrs, plr.UserId), "Player is not setup yet. Cannot update spec data.")

	local key = plr.UserId..self._keySuffix
	
	local orgData = self._plrsInfo[key].Data:Get()
	local orgVal = CF:ValidatePath(orgData, path)
	
	local same = true
	if(orgVal) then
		if(typeof(newVal) == "table") then
			if(not CF:MatchTables(orgVal, newVal)) then
				same = false
			end
		elseif(orgVal ~= newVal) then
			same = false
		end
	else
		warn("Invalid path")
		return
	end
	
	if(same) then
		--print("SpecData are same", orgVal, newVal)
		return
	end
	
	--print("FUll daa:", orgData, path, newVal)
	CF:UpdatePathData(orgData, path, newVal)
	--print("UpdateSpecData up:",orgData)
	self:UpdateData(plr, orgData)
end


----------------------------------------------^^^^^ Remove Functions ^^^^^----------------------------------------------
function DataServer:RemovePlr(plr:Player, saveData:boolean)
	--Clear connections. and other binds
	--Call on Roblox server to delete key & values
	assert(table.find(self._setupPlrs, plr.UserId), "Player not setup yet. Cannot remove plr.")
	
	local key = plr.UserId..self._keySuffix
	if(self._plrsInfo[key]) then
		if(saveData) then
			if(self:Save(plr)) then
				--Player's data saved
			end
		end
		
		self._plrsInfo[key].Listeners.WholeData:Destroy()
		self._plrsInfo[key] = nil

		local i = table.find(self._setupPlrs, plr.UserId)
		if(i) then
			table.remove(self._setupPlrs, i)
		end
	end
end

function DataServer:RemovePlrData(plr:Player, targetId:string)
	--Only clear the data element of player.
	assert(table.find(self._setupPlrs, plr.UserId), "Player not setup yet. Cannot remove data.")
	
	
	if(targetId) then
		self:Save(tonumber(targetId), table.clone(self._defaultData))
	else
		local key = plr.UserId..self._keySuffix
		if(self._plrsInfo[key]) then
			self._plrsInfo[key].Data:Set(table.clone(self._defaultData), true)
		end
	end
	
end


----------# For Internal Use only #----------
function DataServer:AutoSave()
	--print("[AutoSaving] for store:", self._storeName)
	
	task.delay(self._config.AutoSave, function()
		self.AutoSaveAlert:Fire()
		task.delay(1, function()
			self:Save()
		end)
		self:AutoSave()
	end)
end
function DataServer:HearbeatUpdate(dt)

	--Auto Save
	self._autoSaveTimer += dt
	
	if (self._autoSaveTimer == self._config.AutoSave - 1) then
		self.AutoSaveAlert:Fire()
	end
	
	if(self._autoSaveTimer > self._config.AutoSave) then
		----print("[AutoSaving] for store:", self._storeName)
	
		self._autoSaveTimer = 0
		--task.spawn(function()
		--	self:Save()
		--end)
	end
end


function DataServer:Destroy()

end

return DataServer
-- @ScriptType: ModuleScript
------------------------------->>>>>>>******
-- warn/print overrides REMOVED (sprint 5c) — silenced all client-side data errors.
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
--------------------------------------------------------------------------------------------------]]--


---------- CONFIGURATIONS
local configs = {
	MaxPingFailedLimit = 5, 
	PingCheckoutTime = 60, --In sec, the module will try to communicate with related server store to check connectivity.
}

---------- CONFIGURATIONS

type moduleReturnType = {
	GetData : (fn)->(),
	GetPlrData : (plrUserId)->(),
	GetStore : ()->(CT.StoreDataType),
	GetOtherStoreData : (storeName)->(plrData),
	ListenChange : (fn)->(RBXScriptConnection),
	ListenSpecChange : (path, fn)->(RBXScriptConnection),
	UpdateData : (data)->(),
	UpdateSpecData : (path, data)->(),
	RemovePlrData : ()->(),
}


local RS = game:GetService("ReplicatedStorage")
local HS = game:GetService('HttpService')
local RunS = game:GetService("RunService")

---# Helpers
local Helpers = script.Parent.Helpers
local Constants = require(Helpers.Consts)
local CT = require(Helpers.Types)
local CF = require(Helpers.CF)

---# Communication
local Comm = script.Parent.Comm
local Client = require(Comm.Client)

local RuntimeF = script.Parent.Runtime
local ClientF = RuntimeF.Client
local ServerF = RuntimeF.Server


------------- Client Members
local myPlr = game.Players.LocalPlayer

------------- Client Members



---^^^^^^^^^^^^^^^^^^ COMMON AMONG STORES INSTANCES ^^^^^^^^^^^^^^^^^^^---
local Stores :CT.StoresData = {} --Key = "StoreName" Value = "{Name = storeName, KeySuffix = keySuffix, Type = typ, StoreObj = nil, PlrsInfo = {}, Instance = "Class-Instance"}"
local StoreNames = {} -- Array of total store names
---__________________ COMMON AMONG STORES INSTANCES ___________________---

local infoTemp :CT.PlayerData = {}


--[[

]]
local DataClient = {}
DataClient.__index = DataClient


-------------------------- Setup  ---------------------------------

-----------------------------------------------^^^^^ Setup & Init Stores ^^z^^^----------------------------------------------
function DataClient.SetupAll()
	for i, v in pairs(ServerF:GetChildren()) do
		if(v:IsA("Folder")) then
			--print("Got Server store module:", v.Name)
			
			local store = DataClient.SetupStore(v)
			
			if(store) then
				
				warn("Store Setup at client side:", store)
				
			else
				warn("Something went wrong while setting-up store!")
			end
		end
	end
end

--[[
storeName :string = The name of your DataStore. Like "PlayerData", "DailyChallenges", "Leaderboard", etc
keySuffix :string = the suffix you want to use for player's key to make it more unique.
handlePlayers :boolean (Optional) = Means whether player's adding/removed controlled by DataReplicator for data purpose. 
						If true, then DataReplicator will handle all player's data by itself. whenever new player joins or leaves.
						Else, dev has to manage player's joining/leaving and saving data on Roblox-Server.
defaultDataTemp :any = The default template of data for the players. Default data preset when very new player joins the game. 
						Note: This would only work if "handlePlayers" property is set to true.
]]
--Setup the DataReplicator class for Client
function DataClient.SetupStore(newStore:string | Instance)
	if(typeof(newStore) == "string") then
		newStore = ServerF:FindFirstChild(newStore)
		assert(newStore, "Requested storeName does not exists.")
	elseif(typeof(newStore) == "Instance") then
		newStore  = ServerF:FindFirstChild(newStore.Name)
		assert(newStore, "Given Instance is not a child of Server Stores.")
	else
		return nil
	end
	
	if(Stores[newStore.Name]) then
		warn("Store already setup!")
		return Stores[newStore.Name].Instance
	end
	
	warn("[DataReplicator] Received call to SetupStore:", newStore)
	
	local self = setmetatable({}, DataClient)
	self.__index = self
	self.__tostring = function()
		return "Component<" .. self .. "> DataClient :)"
	end

	--Setup parameters
	self._InstanceF = newStore
	self._MyStore = nil -- server-side store module (generate at client-side at startup)
	self._storeName = newStore.Name
	self._plrInfo = table.clone(infoTemp) -- "table" -> CT.PlayerData
	
	--Setup variables
	self._quotes = {}
	self._pingFailed = 0
	self._pingCheckTimer = 0
	self._connected = false
	self._initialised = false
	self._config = table.clone(configs)
	self._internalConn = {}

	if(not self:InitStore()) then
		warn("Something went wrong while Connecting with the server. :((")
		self._connected = false
		return nil
	end

	self:Establish()
	
	--print("Establihsed the storeL", self._storeName, self._InstanceF)
	--Inform Server that player has connected with store.
	self._MyStore.ClientConnected:Fire()
	
	if(typeof(self.HearbeatUpdate) == "function") then
		self._internalConn["HearbeatUpdate"] = RunS.Heartbeat:Connect(function(dt)
			self:HearbeatUpdate(dt)
		end)
	end

	table.insert(StoreNames, 1, newStore.Name)
	return self
end

function DataClient.GetStore(storeName:string) :CT.StoreDataType
	--print("GetStore :", storeName, Stores)
	assert(Stores[storeName]," Given store name not found:", Stores)
	return Stores[storeName].Instance
end

---------------- Module Instance ---------------

--# Init the store and on self class and setup for run
function DataClient:InitStore()
	--print("Fetching DataStore:", self._storeName)
	
	self._MyStore = Client.BuildServerModule(self._InstanceF)

	if(self._MyStore) then
		Stores[self._storeName] = {Name = self._storeName,
			ServerStore = self._MyStore, Instance = self}

		self._quotes.StoreInitialised = workspace:GetServerTimeNow()
		self._initialised = true
		--print("Init DataStore successfully :",self._storeName)
		
	else
		--print("Something went wrong while fetching ServerStore :",self._storeName, self._MyStore)
		self._initialised = false
	end

	return self._initialised
end

--# Establish the Client-Store and connect with server-side attributes
function DataClient:Establish()
	if(not self._initialised) then
		return
	end
	
	--Setup Communication Mediums
	do
		self._plrInfo.Data = CF.Value({})
		self._plrInfo.Listeners = {}
		self._plrInfo.Listeners.WholeData = {}
		self._plrInfo.Listeners.PathsSpecific = {}
		
		--Client listens, Server fires
		self._MyStore.InitData:Connect(function(data:any)
			warn(self._storeName, "InitData received from server-store:", data)
			if(self._initData) then
				warn(self._storeName, "InitData was already received!!")
				return
			end
			
			self._initData = data
			self._plrInfo.Data:Set(data, true)
			self._quotes.InitDataReceivedTime = workspace:GetServerTimeNow()
		end)
		
		self._MyStore.ListenChange:Connect(function(newData:any)
			print(self._storeName, "Client listened the Data Change!!", newData)
			self._quotes.LastChangeTime = workspace:GetServerTimeNow()
			self._plrInfo.Data:Set(newData, true)
		end)
		
		--Client fires, Server listens
		--self._MyStore.UpdateDataRqst
		--self._MyStore.UpdateSpecDataRqst
	end
	
	self._quotes.StoreEstablishedAt = workspace:GetServerTimeNow()
	self._connected = true
end

----------------------------------------------^^^^^ Settings Functions ^^^^^----------------------------------------------
--# Update this store's settings. Like autoSaveTime, etc
function DataClient:UpdateStoreSettings()
	
end


----------------------------------------------^^^^^ Get Functions ^^^^^----------------------------------------------
--[[
This will also setup the given player if his data was not setup in this store.

player: (Player OR number) = Can pass player as "Player" or "Plater.UserId" to get his data from this store.
]]
function DataClient:GetData()
	if(not self._initialised) then
		return
	end
	
	if(self._plrInfo.Data:Get()) then
		return (self._plrInfo.Data:Get())
	else
		local data = self._MyStore:GetData()
		if(data) then
			self._plrInfo.Data:Set(data)
			--print("Found the data from server!! :))")
			return (self._plrInfo.Data:Get())
		else
			warn("Data not received from server! :((")
			return (nil)
		end
	end
	
end

--[[
To get any other player's data from server on client side
]]
function DataClient:GetPlrData(plrUserId:number)
	assert(plrUserId, "Plr UserId is required to fetch the data.")
	if(not self._initialised) then
		return
	end

	local data = self._MyStore:GetPlrData(plrUserId)
	if(data) then
		--print("Found other plr data on server!! :))", data)
		return data
	else
		warn("Data not received from server! :((")
		return nil
	end
end

--# Get Data of other Stores using self store's Class-Instance
function DataClient:GetOtherStoreData(storeName, callback:() ->())
	print(self._storeName," Fetching other store:", storeName)
	assert(Stores[storeName], "Specified storeName is not valid or not setup yet.")
	assert(callback, "callback func is required.")

	if(Stores[storeName]) then
		Stores[storeName].Instance:GetData(callback)
	end
end


----------------------------------------------^^^^^ Listen Functions ^^^^^----------------------------------------------
--[[
This is fire the event whenever plr's data changes.
return RBXScriptConnection

]]
--# Listen whole player's data change event. ->One Way Communication<-
function DataClient:ListenChange(fn:()->()) :RBXScriptConnection
	if(not self._initialised) then
		warn("Player not setup in ListenChange()")
		return nil
	end
	
	local conn = self._plrInfo.Data.OnChange:Connect(fn)
	table.insert(self._plrInfo.Listeners.WholeData, conn)
	return conn
end

--[[
path : string = A valid path of data.
fn : function (NewVal, OldVal) = callback function when specified path's value is changed/updated.

return : RBXScriptConnection = Connection to specific path change is returned
]]
--# Listen for specific key change in player's data. *->One Way Communication<-
function DataClient:ListenSpecChange(path:string, fn :(any, any, any) -> ()) :RBXScriptConnection
	assert(fn, "Require func if you want to listen for data change.")
	
	if(not self._plrInfo.Listeners.PathsSpecific[path]) then
		self._plrInfo.Listeners.PathsSpecific[path] = {} --setmetatable({}, CF.GetLength)
	end
	
	--print("[SpecChange] Subscribed : ", path, self._plrInfo.Listeners.PathsSpecific)
	
	--Don't subs again to ListenChange. can also just add the callback fn in the table and can remove when not required.
	--Can only use single connection to listen all specific changes.
	local conn = self:ListenChange(function(data, oldData)
		if(data) then
			local orgVal = CF:ValidatePath(data, path)
			if(orgVal) then
				local oldVal = CF:ValidatePath(oldData, path)
				
				--Karna: MOST IMPORTANT!!! [ >B|U|G< ]
				
				local IsSame = CF:MatchTables(orgVal, oldVal) -- Same -> TRUE
				
				----print("[TEST] PP ",path, IsSame, oldVal == orgVal, orgVal, oldVal, type(oldVal), type(orgVal))
				if IsSame == false then
					
					----print("[Profile Updated][DATA CHANGED ]",path, orgVal, oldVal, IsSame)
					for i, d:CT.PathsSpecificType in pairs(self._plrInfo.Listeners.PathsSpecific[path]) do
						if(d.Conn) then
							
							local f = d.Func
							task.spawn(function()
								----print("[Profile Updated] ", path)
								f(orgVal, oldVal, data)
							end)
							
						else
							warn("[PathSpecific] Connection was disconnected!!")
						end
					end
				end

			end
		end
	end)

	table.insert(self._plrInfo.Listeners.PathsSpecific[path], {Conn = conn, Func = fn})

	return conn
end

----------------------------------------------^^^^^ Update Functions ^^^^^----------------------------------------------

--# Update data on the server. 
function DataClient:UpdateData(data)
	assert(data, "Nil or invalid data in store:", self)
	local IsSame = CF:MatchTables(self._plrInfo.Data:Get(), data)
	--print("[Debug New Slot] Matching ", self._plrInfo.Data:Get(), data, IsSame)
	
	if(not IsSame) then
		--print("[Debug New Slot] Matching TRUE", self._plrInfo.Data:Get(), data)
		self._plrInfo.Data:Set(data)
		self._MyStore.UpdateDataRqst:Fire(data)
	else
		print("No change detected in data.", self)
	end
end

--# Update data on the server. 
function DataClient:UpdateDataOnServer(data)
	assert(data, "Nil or invalid data in store:", self)
	
	self._MyStore.UpdateDataRqst:Fire(data)
end

function DataClient:UpdateSpecData(path:string, newVal:any)
	assert(newVal, "Nil or invalid newVal:",self)
	--print("UpdateSpecData:", path, newVal, self._plrInfo.Data:Get())
	local orgVal = CF:ValidatePath(self._plrInfo.Data:Get(), path)
	
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
		warn("datas are identical....", orgVal, newVal)
		return
	end
	
	local d = self._plrInfo.Data:Get()
	CF:UpdatePathData(d, path, newVal)
	self._plrInfo.Data:Set(d)
	--Fire to server
	self._MyStore.UpdateSpecDataRqst:Fire(path, newVal)
end

----------------------------------------------^^^^^ Delete/Remove Functions ^^^^^----------------------------------------------
function DataClient:DeleteData()
	self._MyStore.RemovePlrData:Fire()
end


function DataClient:CheckPing()
	--print("Check ping with server-store module:", self._storeName)
	local succ = self._MyStore:PingTest()
	--print("Ping succ:", succ)
	if(succ) then
		self._connected = true
	else
		self._pingFailed += 1
	end
	
	
	if(self._pingFailed >= self._config.MaxPingFailedLimit) then
		warn("Reached to MaxPingFailedLimit. Shutting the Client-Side Store :",self._storeName)
		self._connected = false
		--Karna: Shut the client-store
	end
end


----------# For Internal Use only #----------
function DataClient:HearbeatUpdate(dt)
	if(not self._connected) then
		return
	end

	
	if(not self._MyStore) then
		self._connected = false
	end
	
	
	
	--Check Ping
	self._pingCheckTimer += dt

	if(self._pingCheckTimer > self._config.PingCheckoutTime) then
		self._pingCheckTimer = 0
		self:CheckPing()
	end
	
end


function DataClient:Destroy()

end

return DataClient
-- @ScriptType: ModuleScript

function CompareTables(t1, t2)
	if t1 == t2 then return true end 
	if type(t1) ~= "table" or type(t2) ~= "table" then return false end

	for key in pairs(t2) do
		if t1[key] == nil then
			return false
		end
	end

	for key, value in pairs(t1) do
		if type(value) == "table" then

			if not CompareTables(value, t2[key]) then
				return false
			end

		elseif t2[key] ~= value then
			return false
		end
	end

	return true
end


------------------------- Event/Connection -----------------------
local EvConnect = {} do
	EvConnect.__index = EvConnect
	function EvConnect.new(name:string)
		local self = setmetatable({}, EvConnect)
		self.__index = self
		self.Name = name or "EvConnect"

		self.Func = {}
		self.Connections = {} --key = function, value = connection
		self.Bevent = Instance.new("BindableEvent")
		self.Bevent.Name = self.Name
		self.Bevent.Event:Connect(function()
			--print("checking connect fire - total func", #self.Func)
		end)

		return self
	end

	function EvConnect:Fire(...)
		self.Bevent:Fire(...)
	end

	function EvConnect:Connect(fn)
		assert(fn or typeof(fn) == "function", "Require a valid function to Connect")
		--task.spawn(fn)
		self.Connections[fn] = self.Bevent.Event:Connect(fn)
		return self.Connections[fn]
	end

	function EvConnect:Once(fn)
		assert(fn or typeof(fn) == "function", "Require a valid function to Connect")

		self.Connections[fn] = self.Bevent.Event:Once(function()
			task.spawn(fn)
			self.Connections[fn] = nil
		end)

		return self.Connections[fn]
	end

	function EvConnect:Wait()
		self.Bevent.Event:Wait()
	end

	--Disconnects the connect to the given fn (if found)
	function EvConnect:Disconnect(fn)
		assert(fn or typeof(fn) == "function", "Require a valid function to Disconnect")

		if(self.Connections[fn]) then
			self.Connections[fn]:Disconnect()
		end
	end

	--Completely destory the connections and class
	function EvConnect:DisconnectAll()
		for i, con in pairs(self.Connections) do
			con:Disconnect()
		end
		self.Bevent:Destroy()
		self = nil
	end

end

------------------------- Event/Connection -----------------------

local Val = {} do
	Val.__index = Val
	function Val.new(initialVal:any)
		if(initialVal == nil) then initialVal = "0" end

		local self = setmetatable({}, Val)
		self.__index = self
		self.__tostring = function()
			--print("[Value] :>" .. self._val)
			return self._val
		end

		self._typ = typeof(initialVal)

		--Init
		self._initVal = initialVal
		self._preVal = self:GetInitialVal()
		self._val = self:GetInitialVal()

		self.OnChange = EvConnect.new()

		return self
	end

	function Val:Set(newVal:any, force:boolean)
		if(typeof(newVal) ~= self._typ and not force) then
			warn("Type mismatch error. typeof of newVal doesn't match with Value.")
			return (self._typ == "table") and table.clone(self._val) or self._val
		end

		if(not force) then
			local same = false
			if(typeof(self._typ) == "table") then
				same = (CompareTables(self._val, newVal))
			else
				same = (self._val == newVal)
			end

			if(same) then
				return
			end
		end

		self._preVal = self._val
		self._val = newVal
		self._typ = typeof(newVal)

		local preVal = self._preVal
		self.OnChange:Fire(newVal, preVal)

		return (self._typ == "table") and table.clone(self._val) or self._val
	end

	function Val:Get()
		return (self._typ == "table") and table.clone(self._val) or self._val
	end

	function Val:GetInitialVal()
		return (self._typ == "table") and table.clone(self._initVal) or self._initVal
	end

	function Val:GetPreVal()
		return (self._typ == "table") and table.clone(self._preVal) or self._preVal
	end

	function Val:Reset()
		return self:Set(self:GetInitialVal(), true)
	end

	function Val:Clear()
		self.OnChange:DisconnectAll()
		self._val = self:GetInitialVal()
		self._preVal = self:GetInitialVal()
	end

	function Val:Destroy()
		self:Clear()
		self = nil
	end
end

return function(initialVal:any)
	return Val.new(initialVal)
end

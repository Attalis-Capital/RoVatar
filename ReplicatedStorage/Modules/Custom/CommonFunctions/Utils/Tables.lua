-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local Tables

Tables = {
	--Returns count of all elements of table (nested tables not included)
	GetLengthFunction = function(Table)
		local counter = 0 
		for _,v in pairs(Table) do
			counter = counter + 1
		end
		return counter
	end,

	--Returns count of all descendent elements of table (nested tables included)
	TableLengthDeep = function(Table) :number
		local counter = 0 
		for _, v in pairs(Table) do
			if(typeof(v) == "table") then
				counter += Tables.TableLengthDeep(v)
			else
				counter += 1
			end
		end

		return counter
	end,

	--Compares the tables deeply
	CompareTables = function(t1, t2)
		if t1 == t2 then return true end 
		if type(t1) ~= "table" or type(t2) ~= "table" then return false end

		for key in pairs(t2) do
			if t1[key] == nil then
				return false
			end
		end

		for key, value in pairs(t1) do
			if type(value) == "table" then

				if not Tables.CompareTables(value, t2[key]) then
					return false
				end

			elseif t2[key] ~= value then
				return false
			end
		end

		return true
	end,

	--Only matches whether tables are similar in structure and values
	MatchTables = function(sorTab:table, doubTab:table) :boolean
		if sorTab and doubTab and typeof(sorTab) == "table" and typeof(doubTab) == "table" then
			return Tables.CompareTables(sorTab, doubTab)
		else
			local HS = game:GetService("HttpService")
			return (HS:JSONEncode(sorTab) == HS:JSONEncode(doubTab))
		end
	end,

	--Updates the mainTable according to templateTable (Adds/Removes/Updates the fields/elements)
	SyncTables = function(mainTable, templateTable, removeMissing:boolean)

		local function CopyTable(t)
			assert(type(t) == "table", "First argument must be a table")
			local tCopy = table.create(#t)
			for k,v in pairs(t) do
				if (type(v) == "table") then
					tCopy[k] = CopyTable(v)
				else
					tCopy[k] = v
				end
			end
			return tCopy
		end

		local function Sync(tbl, templateTbl)
			assert(type(tbl) == "table", "First argument must be a table")
			assert(type(templateTbl) == "table", "Second argument must be a table")

			for k,v in pairs(tbl) do
				local vTemplate = templateTbl[k]

				if (type(v) ~= type(vTemplate)) then
					if (type(vTemplate) == "table") then
						tbl[k] = CopyTable(vTemplate)
					end

					-- Synchronize sub-tables:
				elseif (type(v) == "table") then
					Sync(v, vTemplate)
				end
			end


			-- Add any missing keys:
			for k,vTemplate in pairs(templateTbl) do

				local v = tbl[k]

				if (v == nil) then
					if (type(vTemplate) == "table") then
						tbl[k] = CopyTable(vTemplate)
					else
						tbl[k] = vTemplate
					end
				end

				if(typeof(vTemplate) ~= typeof(v)) then
					print("Type not same. Key:",k)
					tbl[k] = vTemplate
				end
			end

		end

		local function remove(mainTbl, tmpTbl)
			for k, v in pairs(mainTbl) do
				local keyFound = false
				for kk, vv in pairs(tmpTbl) do
					if(kk == k) then
						keyFound = true
					end
				end

				--Remove the key if NOT found
				if(keyFound == false) then
					print("Key not found in new tmp table.")
					print("[Key]",k)
					mainTbl[k] = nil
				else
					if(typeof(v) == "table" and typeof(tmpTbl[k] == "table")) then
						remove(v, tmpTbl[k])
					end
				end
			end
		end

		Sync(mainTable, templateTable)
		if(removeMissing) then
			remove(mainTable, templateTable)
		end
	end,

	--Clone the mainTable and return new table[TOBEINT]
	CloneTable = function(Table)
		if not Table then
			return Table
		end
		local function Clone(original)
			local copy = {}

			for key, value in pairs(original) do
				if type(value) == "table" then
					copy[key] = Clone(value)
				else
					copy[key] = value
				end
			end
			return copy
		end

		local newTable = Clone(Table)
		return newTable
	end,

	-- 
	NextValue = function(Table, exceptId):table
		local TableC = table.clone(Table)
		if exceptId and TableC[exceptId] then
			TableC[exceptId] = nil
		end

		for _, data in pairs(TableC) do
			return data 
		end

		return nil
	end,

	--
	ConvertDicToArray = function(tbl)
		local newTbl = {}
		for key, Value in pairs(tbl) do
			table.insert(newTbl, Value)
		end
		return newTbl
	end,

	--[TOBEINT]
	SortTable = function(tbl, property:string)
		if not tbl[1] then
			tbl = Tables.ConvertDicToArray(tbl)
		end

		local t = table.clone(tbl)
		table.sort(t, function(v1, v2)
			return v1[property] > v2[property]
		end)

		tbl = t
		return t
	end,

	--[TOBEINT]
	TableLength = function(Table) :number
		local counter = 0
		for i, v in pairs(Table) do
			counter += 1
		end
		return counter
	end,

	--[TOBEINT]
	RandomValue = function(Table)
		local RNG = Random.new()
		local array = {}
		for key, _ in pairs(Table) do
			table.insert(array, key)
		end

		local Index = math.floor(RNG:NextNumber(1, #array))
		local id = array[Index]

		return Table[id]
	end,

}


return Tables
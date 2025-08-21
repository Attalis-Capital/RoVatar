-- @ScriptType: ModuleScript
return {
	DateToDays = function(Day :number, Month :number, Year :number)
		-- Month days for a regular year (not considering leap years)
		local monthShortTable = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}
		if type(Month) == "string" then
			Month = table.find(monthShortTable, Month)
		end

		local givenTime = os.time({year = Year, month = Month, day = Day, hour = 0, min = 0, sec = 0})
		local epochTime = os.time({year = 1970, month = 1, day = 1, hour = 0, min = 0, sec = 0})

		return math.floor(os.difftime(givenTime, epochTime) / 86400) -- 86400 seconds in a day
	end,

	DaysDiff = function(newDate:{}, oldDate:{})
		local givenTime = os.time(newDate)
		local epochTime = os.time(oldDate)

		return math.floor(os.difftime(givenTime, epochTime) / 86400) -- 86400 seconds in a day
	end,

	ConvertUnixTimeStampToTimeFormat = function(timeStamp, timeWithDate:BoolValue)
		if(timeStamp == nil) then
			print("Unable to convert to timestring, utcSeconds is nil.")
			return
		end

		local monthShortTable = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};

		--print("[Unix timeStamp]:", timeStamp)
		local pTime = "AM"
		local dd = DateTime.fromUnixTimestamp(timeStamp)
		local Time = dd:ToLocalTime()
		local year = Time.Year
		local month = monthShortTable[Time.Month]
		local day = string.format("%02d",Time.Day)
		local hours = Time.Hour
		local min = string.format("%02d",Time.Minute)
		local sec = string.format("%02d",Time.Second)

		if(hours >= 12) then
			hours = hours > 12 and hours - 12 or hours
			pTime = "PM"
		end
		hours = string.format("%02d",hours)
		local timeString
		if(timeWithDate) then
			timeString = day.."-"..month.."-"..year.." "..hours..":"..min..":"..sec.." "..pTime
		else
			timeString = hours..":"..min..":"..sec
		end

		return timeString, day, month, year, hours, min, sec, pTime
	end,

	ConvertToTimeFormat = function(timeInSec:number , onlyMinSec:BoolValue)
		local hrs = math.floor(timeInSec / 3600)
		local minutes = (timeInSec / 60) % 60
		local seconds = timeInSec % 60
		if(onlyMinSec) then
			return string.format("%02d:%02d", minutes, seconds)
		else
			return string.format("%02d:%02d:%02d",hrs, minutes, seconds)
		end
	end,
}

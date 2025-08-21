-- @ScriptType: ModuleScript
return {
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

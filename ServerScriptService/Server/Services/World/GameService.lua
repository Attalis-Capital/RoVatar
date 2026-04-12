-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local CS = game:GetService("CollectionService")

local Knit = require(RS.Packages.Knit)
local Timer = require(RS.Packages.Timer)

local GameService = Knit.CreateService {
	Name = "GameService",
	
	Client = {
	}
}

----Other services

----Variables
--------------------------------------------->>>>>>>>>>>> Private Methods <<<<<<<<<<<<----------------------------------------------

------------------->>>>>>>.. Timer 
local function StartTimer()
	local Folder = Instance.new("Folder", workspace)
	Folder.Name = "Timers"
	
	local Remaining = Instance.new("NumberValue", Folder)
	local Current = Instance.new("NumberValue", Folder)
	local Datetime = Instance.new("NumberValue", Folder)
	
	Remaining.Name = "Remaining"
	Current.Name = "Current"
	Datetime.Name = "Datetime"
	
	local CountDown = Timer.new(1)
	CountDown:Start()
	
	CountDown.Tick:Connect(function()
		
		local Time = workspace.ServerTime.Value -- workspace:GetServerTimeNow()
		local date = os.date("*t", workspace.ServerTime.Value) -- workspace:GetServerTimeNow())
		
		local TodaySeconds = (date.hour * 3600 + date.min * 60 + date.sec)
		local RemainingSeconds = (24 * 3600) - TodaySeconds
		
		Datetime.Value = Time
		Current.Value = TodaySeconds
		Remaining.Value = RemainingSeconds
		
		-- Current Time
		local hours = math.floor(TodaySeconds / 3600)
		TodaySeconds = TodaySeconds % 3600
		local minutes = math.floor(TodaySeconds / 60)
		local seconds = TodaySeconds % 60
		
	end)
end
-------------------<<<<<<<.. Timer 

function GameService:KnitInit()
end

function GameService:KnitStart()
	StartTimer()
end

return GameService
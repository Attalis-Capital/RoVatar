-- @ScriptType: ModuleScript

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

--// Modules
local Maid = require(script.Maid)

--// Assets
local uiTemplate = script.DamageTemplate

--// Objects
local random = Random.new()

local DamageIndication = {}
DamageIndication.__index = DamageIndication

function DamageIndication.new(instance)
	local self = setmetatable({}, DamageIndication)
	
	self._humanoid = instance:FindFirstChild("Humanoid")
	self._head = instance:FindFirstChild("Head")
	self._instance = instance
	
	self._maid = Maid.new()
	
	self:Bind()
	
	return self
end

--// Bind damage indicator UI to instance, called automaticlaly in constructor
function DamageIndication:Bind()
	assert(self._humanoid, "Instance does not contain a humanoid")
	assert(self._head, "Instance does not contain a humanoid root part")
	
	self.currentHealth = self._humanoid.Health
	
	self._maid:GiveTask(self._humanoid.HealthChanged:Connect(function(newHealth)
		local damage = self.currentHealth - newHealth
		self.currentHealth = newHealth
		
		self:SpawnUI(damage)
	end))
	
	self._maid:GiveTask(self._instance.AncestryChanged:Connect(function()
		if self._instance.Parent ~= game then
			self:Destroy()
		end
	end))
	
	self._maid:GiveTask(self._humanoid.Died:Connect(function()
		self:Destroy()
	end))
end

function DamageIndication:SpawnUI(amount)
	local indicator = uiTemplate:Clone()
	local label = indicator.Label
	local maxHealth = self._humanoid.maxHealth
	
	label.Text = math.floor(math.abs(amount))
	label.TextColor3 = self:GetIndicatorColor(amount, maxHealth)
	
	local xy = math.clamp(math.abs(amount/maxHealth), 0.6, 1.3)
	label.Size = UDim2.fromScale(xy, xy) 
	
	--// Randomly disperse to prevent clutter
	local x = random:NextNumber(.2, .8)
	label.Position = UDim2.fromScale(x, 0.5)
	
	local indicatorTween = TweenService:Create(label, TweenInfo.new(2, Enum.EasingStyle.Quint), {
		Position = UDim2.fromScale(x, -0.5),
		TextTransparency = 1
	})
	
	indicator.Parent = self._head
	indicatorTween:Play()
	
	indicatorTween.Completed:Wait()
	indicator:Destroy()
end

function DamageIndication:GetIndicatorColor(amount)
	return amount >= 0 and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
end

function DamageIndication:Destroy()
	self._maid:Destroy()
end

--// BONUS: Automatic method that binds to all existing NPC's in your game
function DamageIndication.BindToAllNPCs()
	for _, instance in ipairs(game.Workspace:GetDescendants()) do
		if not instance:IsA("Model") then continue end
		if not instance:FindFirstChild("Humanoid") then continue end
		if not instance:FindFirstChild("Head") then continue end

		DamageIndication.new(instance)
	end
end

--// Binds damage indicators to NPCs that spawn after initial load (respawns, new spawns)
function DamageIndication.BindToNewNPCs()
	local Players = game:GetService("Players")
	workspace.DescendantAdded:Connect(function(instance)
		if not instance:IsA("Humanoid") then return end
		local model = instance.Parent
		if not model or not model:IsA("Model") then return end
		-- Skip player characters — only bind to NPCs
		if Players:GetPlayerFromCharacter(model) then return end
		if not model:FindFirstChild("Head") then
			-- Head may not be parented yet, wait briefly
			task.delay(0.1, function()
				if model.Parent and model:FindFirstChild("Head") and model:FindFirstChild("Humanoid") then
					DamageIndication.new(model)
				end
			end)
			return
		end
		DamageIndication.new(model)
	end)
end

return DamageIndication
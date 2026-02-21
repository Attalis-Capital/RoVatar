-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local CD = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)

return {
	GetPivotLocation = function(obj, spawnner:Part)
		local groundClearence = 1
		local sizeMultiplier = 1
		local minItemsGap = 3 -- Sets distance between item boxes

		local function CalculatePos(spawner)
			local Position, Size = spawner.Position, spawner.Size

			--Get random position inside the spawner (respect to targetModel)
			local randomPos = Vector3.new(
				math.random(Position.X - Size.X/2, Position.X + Size.X/2),
				Position.Y - Size.Y/2 + obj.PrimaryPart.Size.Y/2 + groundClearence,
				math.random(Position.Z - Size.Z/2, Position.Z + Size.Z/2)
			)
			return randomPos
		end

		local function GetRandomPos(spawner :Instance, obj:Instance)
			--Get random position inside the spawner (respect to targetModel)
			local randomPos = CalculatePos(spawner)

			--Check the min distance between new pos and each previous items
			for i, itm:Instance in pairs(game:GetService("CollectionService"):GetTagged(CD.Tags.PlayerAvatar)) do

				local dist = (randomPos - itm.PrimaryPart.Position).Magnitude
				if(dist < minItemsGap) then
					randomPos = GetRandomPos(spawner, obj)
				end
			end

			local parms = OverlapParams.new()
			parms.FilterDescendantsInstances = {spawner.Parent.Parent}
			parms.FilterType = Enum.RaycastFilterType.Exclude
			--Check the collision with environment
			local p = workspace:GetPartBoundsInBox(CFrame.new(randomPos), (obj.PrimaryPart.Size * sizeMultiplier), parms)

			if(#p > 0) then
				randomPos = GetRandomPos(spawner, obj)
			end

			return randomPos
		end

		local location = GetRandomPos(spawnner, obj) do
			if not location then
				warn("[Need To Calculate Position Again -->>>>]")
				location = CalculatePos(spawnner)
			end

			location = CFrame.lookAlong(Vector3.new(location.X, spawnner.Position.Y, location.Z), spawnner.CFrame.LookVector)

		end

		return location
	end,
}

-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")

local CD = require(RS.Modules.Custom.Constants)
local CT = require(RS.Modules.Custom.CustomTypes)

local Calculations = require(script.Parent.Calculations)
return {
	--[TOBEINT]
	WrapObject = function(obj:Instance)
		if(typeof(obj) == "CFrame") then
			return {Pos = {X = obj.Position.X,Y = obj.Position.Y,Z = obj.Position.Z,}, Rot = {X = obj.Rotation.X,Y = obj.Rotation.Y,Z = obj.Rotation.Z}}
		elseif(typeof(obj) == "Vector3") then
			return {X = obj.X,Y = obj.Y,Z = obj.Z,}
		elseif(typeof(obj) == "Vector2") then
			return {X = obj.X,Y = obj.Y}
		elseif(typeof(obj) == "UDim2") then
			return {Scale = {X = obj.X.Scale,Y = obj.Y.Scale}, Offset = {X = obj.X.Offset,Y = obj.Y.Offset}}
		else
			warn(obj, "Not supported type:", typeof(obj))
		end
	end,

	CreateObject = function(obj:{}, typ)
		if(obj.Pos and obj.Rot) then
			--local s = {Pos = {X = obj.Position.X,Y = obj.Position.Y,Z = obj.Position.Z,}, Rot = {X = obj.Rotation.X,Y = obj.Rotation.Y,Z = obj.Rotation.Z}}

			return CFrame.lookAt(Vector3.new(obj.Pos.X, obj.Pos.Y, obj.Pos.Z), Vector3.new(obj.Rot.X, obj.Rot.Y, obj.Rot.Z))
		elseif(typeof(obj) == "Vector3") then
			return Vector3.new(obj.X, obj.Y, obj.Z)
		elseif(typeof(obj) == "Vector2") then
			return Vector2.new(obj.X, obj.Y)
		elseif(typeof(obj) == "UDim2") then
			return UDim2.new(obj.Scale.X, obj.Offset.X, obj.Scale.Y, obj.Offset.Y)
		else
			warn(obj, "Not supported type:", typeof(obj))
		end
	end,

	--[TOBEINT]
	PivotTo = function(char :Model, part:Part, playEffect:boolean, caller)
		if(playEffect) then
			--VFXHandler:PlayEffect(char, CD.VFXs.SpawnEffect)
		end

		local cf :CFrame = part
		if(typeof(part) ~= "CFrame") then
			--print("Finding  dynamic position, ", char, part)
			cf = Calculations.GetPivotLocation(char, part)
		end

		task.wait(.1)
		char:PivotTo(cf)
	end
}

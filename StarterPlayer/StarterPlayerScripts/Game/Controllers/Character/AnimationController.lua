-- @ScriptType: ModuleScript
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")

local Knit = require(RS.Packages.Knit)

local AnimatorS = require(RS.Modules.Custom.Animator)

local player = game.Players.LocalPlayer
local Char :Model = nil
local humanoid :Humanoid = nil

local AnimationController = Knit.CreateController {
	Name = "AnimationController",
	AnimTable = {},
}

-----Other scripts
local MatchService
local AnimationService
local myAnimator = nil --Runtime class reference



------------------------------------------------------- >>>>>> Helper Private Methods <<<<<< -----------------------------------------------------

function OnCharacterUpdated(newChar:Model)
	newChar = newChar or player.CharacterAdded:Wait()
	humanoid = newChar:WaitForChild("Humanoid")
	
	if(Char ~= newChar) then
		myAnimator = AnimatorS.new(newChar)
	end
	
	Char = newChar
end

function ControlAnim(Type, ...) --To Handle animation events from server

	if Type == "Play" then
		myAnimator:Play(...)
	elseif Type == "StopAll" then
		myAnimator:StopAll()
	elseif Type == "Stop" then
		myAnimator:Stop(...)
	elseif Type == "PlayDirect" then
		AnimationController:PlayDirectAnimation(...)
	elseif Type == "StopAllDirect" then
		AnimationController:StopAllDirectAnimations(...)
	end

end



------------------------------------------------------- >>>>>> Public Methods <<<<<< -----------------------------------------------------

function AnimationController:PlayAnimation(...)
	return myAnimator:Play(...)
end

function AnimationController:Stop(...)
	myAnimator:Stop(...)
end

function AnimationController:StopAll()
	myAnimator:StopAll()
end

function AnimationController:PlayDirectAnimation(...)
	if(not myAnimator) then
		warn(player.Name,"'s Animator is not assigned",...)
		return
	end

	return myAnimator:PlayDirect(...)
end

function AnimationController:StopAllDirectAnimations(...)
	if(not myAnimator) then
		warn(player.Name,"'s Animator is not assigned",...)
		return
	end

	myAnimator:StopAllDirectAnimations(...)
end

function AnimationController:ToggleAnim(...)
	return myAnimator:ToggleAnim(...)
end

function AnimationController:ToggleAnimation(...)
	return myAnimator:ToggleAnimation(...)
end

function AnimationController:GetTrack(...) :AnimationTrack
	return myAnimator:GetTrack(...)
end

------------------------------------------------------- >>>>>> Public Methods <<<<<< -----------------------------------------------------




function AnimationController:KnitInit()
	player.CharacterAdded:Connect(OnCharacterUpdated)
end

function AnimationController:KnitStart()
	OnCharacterUpdated(player.Character)
end

return AnimationController
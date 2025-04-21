-- Script de Imortalidade Total para Roblox
local player = game:GetService("Players").LocalPlayer

local function tornarImortal()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Mantém a vida sempre cheia
	humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if humanoid.Health < humanoid.MaxHealth then
			humanoid.Health = humanoid.MaxHealth
		end
	end)

	humanoid.Health = humanoid.MaxHealth
end

player.CharacterAdded:Connect(function()
	task.wait(0.5)
	tornarImortal()
end)

if player.Character then
	task.wait(0.5)
	tornarImortal()
end

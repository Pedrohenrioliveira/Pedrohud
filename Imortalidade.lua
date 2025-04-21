-- Script de Imortalidade + Dano Infinito para Roblox
local player = game:GetService("Players").LocalPlayer

-- Função: torna o jogador imortal
local function tornarImortal()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")

	-- Garante vida cheia sempre
	humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if humanoid.Health < humanoid.MaxHealth then
			humanoid.Health = humanoid.MaxHealth
		end
	end)

	humanoid.Health = humanoid.MaxHealth
end

-- Função: aplica dano infinito em inimigos tocados
local function danoInfinito()
	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	
	for _, part in pairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Touched:Connect(function(hit)
				local enemy = hit.Parent
				if enemy and enemy:FindFirstChild("Humanoid") and enemy ~= character then
					enemy.Humanoid.Health = 0
				end
			end)
		end
	end
end

-- Ativar sempre que o personagem aparecer
player.CharacterAdded:Connect(function()
	task.wait(0.5)
	tornarImortal()
	danoInfinito()
end)

-- Se já estiver com o personagem carregado
if player.Character then
	task.wait(0.5)
	tornarImortal()
	danoInfinito()
end

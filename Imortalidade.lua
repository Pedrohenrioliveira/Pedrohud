-- Script com Imortalidade, Dano Infinito (não afeta jogadores) e Botão Preto no Topo
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local running = false
local connections = {}

-- Cria a GUI do botão
local screenGui = Instance.new("ScreenGui", coreGui)
screenGui.Name = "ToggleImortal"
screenGui.ResetOnSpawn = false

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 60, 0, 25)
button.Position = UDim2.new(1, -70, 0, 10) -- canto superior direito
button.Text = "LIGAR"
button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BorderSizePixel = 0
button.Font = Enum.Font.SourceSans
button.TextSize = 16
button.Parent = screenGui

-- Ativa imortalidade + dano infinito
local function ativar()
	running = true
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")

	-- Imortalidade
	table.insert(connections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if humanoid.Health < humanoid.MaxHealth then
			humanoid.Health = humanoid.MaxHealth
		end
	end))

	table.insert(connections, char.ChildRemoved:Connect(function(c)
		if c.Name == "Humanoid" then
			wait(0.1)
			local novo = Instance.new("Humanoid")
			novo.Name = "Humanoid"
			novo.Parent = char
		end
	end))

	spawn(function()
		while running and humanoid and humanoid.Parent do
			humanoid.Health = humanoid.MaxHealth
			wait(0.1)
		end
	end)

	-- Dano infinito em NPCs (ignora jogadores)
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			local conn = part.Touched:Connect(function(hit)
				local enemyChar = hit.Parent
				if not enemyChar or enemyChar == char then return end

				local enemyHum = enemyChar:FindFirstChild("Humanoid")
				if not enemyHum then return end

				-- Verifica se é um jogador; se for, ignora
				if Players:GetPlayerFromCharacter(enemyChar) then
					return
				end

				-- Mata o NPC
				pcall(function()
					enemyHum.Health = 0
				end)
			end)
			table.insert(connections, conn)
		end
	end
end

-- Desativa tudo
local function desativar()
	running = false
	for _, conn in pairs(connections) do
		pcall(function() conn:Disconnect() end)
	end
	connections = {}
end

-- Alterna ao clicar
button.MouseButton1Click:Connect(function()
	if running then
		desativar()
		button.Text = "LIGAR"
		button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	else
		ativar()
		button.Text = "DESLIGAR"
		button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	end
end)

-- Reativa após respawn, se estiver ligado
player.CharacterAdded:Connect(function()
	if running then
		wait(0.5)
		ativar()
	end
end)

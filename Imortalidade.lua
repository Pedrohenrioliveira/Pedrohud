local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local running = false
local connections = {}

-- Interface: botão no topo preto
local screenGui = Instance.new("ScreenGui", coreGui)
screenGui.Name = "ToggleImortal"
screenGui.ResetOnSpawn = false

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 60, 0, 25)
button.Position = UDim2.new(1, -70, 0, 10)
button.Text = "LIGAR"
button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.BorderSizePixel = 0
button.Font = Enum.Font.SourceSans
button.TextSize = 16
button.Parent = screenGui

-- Dinheiro infinito
local function darDinheiroInfinito()
	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local money = leaderstats:FindFirstChild("Money") -- Troque "Money" se o nome for outro, tipo "Bonds"
		if money then
			spawn(function()
				while running and money.Parent do
					money.Value = 999999999
					wait(0.5)
				end
			end)
		end
	end
end

-- Imortalidade e dano infinito (NPCs apenas)
local function ativar()
	running = true
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")

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

	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			local conn = part.Touched:Connect(function(hit)
				local enemyChar = hit.Parent
				if not enemyChar or enemyChar == char then return end

				local enemyHum = enemyChar:FindFirstChild("Humanoid")
				if not enemyHum then return end

				if Players:GetPlayerFromCharacter(enemyChar) then
					return
				end

				pcall(function()
					enemyHum.Health = 0
				end)
			end)
			table.insert(connections, conn)
		end
	end

	darDinheiroInfinito()
end

-- Desativar tudo
local function desativar()
	running = false
	for _, conn in pairs(connections) do
		pcall(function() conn:Disconnect() end)
	end
	connections = {}
end

-- Alternância do botão
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

-- Reativa após respawn
player.CharacterAdded:Connect(function()
	if running then
		wait(0.5)
		ativar()
	end
end)


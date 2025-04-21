-- Script com Imortalidade, Dano Infinito e Botão Liga/Desliga
local player = game:GetService("Players").LocalPlayer
local coreGui = game:GetService("CoreGui")
local running = false
local connections = {}

-- Interface do botão
local screenGui = Instance.new("ScreenGui", coreGui)
screenGui.Name = "ToggleImortal"
screenGui.ResetOnSpawn = false

local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 60, 0, 30)
button.Position = UDim2.new(1, -70, 1, -40) -- canto inferior direito
button.Text = "LIGAR"
button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
button.TextColor3 = Color3.fromRGB(255, 255, 255)
button.Parent = screenGui

-- Ativa imortalidade
local function ativar()
	running = true
	local char = player.Character or player.CharacterAdded:Wait()
	local humanoid = char:WaitForChild("Humanoid")

	-- Imortalidade reforçada
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

	-- Dano infinito
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			local conn = part.Touched:Connect(function(hit)
				local enemy = hit.Parent
				if enemy and enemy ~= char and enemy:FindFirstChild("Humanoid") then
					pcall(function()
						enemy.Humanoid.Health = 0
					end)
				end
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

-- Alterna ao clicar no botão
button.MouseButton1Click:Connect(function()
	if running then
		desativar()
		button.Text = "LIGAR"
		button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		ativar()
		button.Text = "DESLIGAR"
		button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
end)

-- Recarrega ao morrer
player.CharacterAdded:Connect(function()
	if running then
		wait(0.5)
		ativar()
	end
end)

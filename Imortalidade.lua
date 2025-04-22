local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local running = false
local connections = {}

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToggleImortal"
screenGui.ResetOnSpawn = false
screenGui.Parent = coreGui

-- Botão LIGAR/DESLIGAR Imortalidade & Dano Infinito
local buttonAtivar = Instance.new("TextButton")
buttonAtivar.Size = UDim2.new(0, 100, 0, 30)
buttonAtivar.Position = UDim2.new(1, -110, 0, 10)
buttonAtivar.Text = "LIGAR"
buttonAtivar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
buttonAtivar.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonAtivar.BorderSizePixel = 0
buttonAtivar.Font = Enum.Font.SourceSans
buttonAtivar.TextSize = 16
buttonAtivar.Parent = screenGui

-- Ativar imortalidade e dano infinito
local function ativarImortal()
    running = true
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    -- Saúde no máximo sempre
    table.insert(connections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end))

    -- Bloqueia dano (também de projéteis e múltiplos mobs)
    table.insert(connections, RunService.Heartbeat:Connect(function()
        if humanoid and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
        humanoid.PlatformStand = false
        humanoid.Sit = false
    end))

    -- Recriar humanoid caso seja removido
    table.insert(connections, char.ChildRemoved:Connect(function(c)
        if c.Name == "Humanoid" then
            task.wait(0.1)
            if not char:FindFirstChild("Humanoid") then
                local novo = Instance.new("Humanoid")
                novo.Name = "Humanoid"
                novo.Parent = char
            end
        end
    end))

    -- Dano infinito a NPCs (ao tocar)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local conn = part.Touched:Connect(function(hit)
                local enemyChar = hit:FindFirstAncestorOfClass("Model")
                if not enemyChar or enemyChar == char then return end
                local enemyHum = enemyChar:FindFirstChildWhichIsA("Humanoid")
                if enemyHum and not Players:GetPlayerFromCharacter(enemyChar) then
                    pcall(function()
                        enemyHum.Health = 0
                    end)
                end
            end)
            table.insert(connections, conn)
        end
    end
end

-- Desativar tudo
local function desativar()
    running = false
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

-- Clique do botão
buttonAtivar.MouseButton1Click:Connect(function()
    if running then
        desativar()
        buttonAtivar.Text = "LIGAR"
        buttonAtivar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    else
        ativarImortal()
        buttonAtivar.Text = "DESLIGAR"
        buttonAtivar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    end
end)

-- Reaplicar após respawn
player.CharacterAdded:Connect(function()
    if running then
        task.wait(0.5)
        ativarImortal()
    end
end)

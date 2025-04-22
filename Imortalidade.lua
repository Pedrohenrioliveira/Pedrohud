local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local running = false
local connections = {}

-- GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImortalUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = coreGui

-- Botão Imortalidade / Dano
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

-- Botão REVIVER
local buttonReviver = Instance.new("TextButton")
buttonReviver.Size = UDim2.new(0, 100, 0, 30)
buttonReviver.Position = UDim2.new(1, -110, 0, 50)
buttonReviver.Text = "REVIVER"
buttonReviver.BackgroundColor3 = Color3.fromRGB(40, 120, 40)
buttonReviver.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonReviver.BorderSizePixel = 0
buttonReviver.Font = Enum.Font.SourceSans
buttonReviver.TextSize = 16
buttonReviver.Parent = screenGui

-- Ativar imortalidade e dano infinito
local function ativarImortal()
    running = true
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    table.insert(connections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end))

    table.insert(connections, RunService.Heartbeat:Connect(function()
        humanoid.PlatformStand = false
        humanoid.Sit = false
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end))

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

local function desativar()
    running = false
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

-- Botão de ativar/desativar
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

-- Botão de Reviver
buttonReviver.MouseButton1Click:Connect(function()
    local char = player.Character
    if not char then return end

    local humanoid = char:FindFirstChildWhichIsA("Humanoid")
    if humanoid then
        humanoid.Health = humanoid.MaxHealth
        humanoid.PlatformStand = false
        humanoid.Sit = false
    end

    for _, obj in pairs(char:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            pcall(function() obj.Disabled = true obj.Disabled = false end)
        end
    end
end)

-- Reaplicar após respawn
player.CharacterAdded:Connect(function()
    if running then
        task.wait(0.5)
        ativarImortal()
    end
end)

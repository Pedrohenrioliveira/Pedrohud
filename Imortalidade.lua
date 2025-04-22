local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local running = false
local connections = {}

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImortalUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = coreGui

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

-- Ativar modo deus
local function ativarImortal()
    running = true
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

    humanoid.BreakJointsOnDeath = false
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge

    -- Regeneração infinita
    table.insert(connections, RunService.Stepped:Connect(function()
        if running and humanoid then
            humanoid.Health = math.huge
            humanoid.PlatformStand = false
            humanoid.Sit = false
        end
    end))

    -- Recriar Humanoid se for removido
    table.insert(connections, char.ChildRemoved:Connect(function(c)
        if c.Name == "Humanoid" then
            task.wait(0.1)
            if not char:FindFirstChild("Humanoid") then
                local novo = Instance.new("Humanoid")
                novo.Name = "Humanoid"
                novo.BreakJointsOnDeath = false
                novo.MaxHealth = math.huge
                novo.Health = math.huge
                novo.Parent = char
            end
        end
    end))

    -- Dano infinito ao tocar partes do corpo (NPCs apenas)
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local conn = part.Touched:Connect(function(hit)
                local enemyChar = hit:FindFirstAncestorOfClass("Model")
                if not enemyChar or enemyChar == char then return end
                if Players:GetPlayerFromCharacter(enemyChar) then return end
                local enemyHum = enemyChar:FindFirstChildWhichIsA("Humanoid")
                if enemyHum then
                    pcall(function()
                        enemyHum.Health = 0
                    end)
                end
            end)
            table.insert(connections, conn)
        end
    end

    -- Ferramentas com dano infinito (sem afetar players)
    local function aplicarDanoInfinito(tool)
        for _, desc in pairs(tool:GetDescendants()) do
            if desc:IsA("BasePart") then
                local conn = desc.Touched:Connect(function(hit)
                    local enemyChar = hit:FindFirstAncestorOfClass("Model")
                    if not enemyChar or enemyChar == char then return end
                    if Players:GetPlayerFromCharacter(enemyChar) then return end
                    local enemyHum = enemyChar:FindFirstChildWhichIsA("Humanoid")
                    if enemyHum then
                        pcall(function()
                            enemyHum.Health = 0
                        end)
                    end
                end)
                table.insert(connections, conn)
            end
        end
    end

    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            aplicarDanoInfinito(tool)
        end
    end

    table.insert(connections, char.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") then
            aplicarDanoInfinito(obj)
        end
    end))
end

-- Desativar modo deus
local function desativar()
    running = false
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.MaxHealth = 100
            humanoid.Health = 100
            humanoid.BreakJointsOnDeath = true
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        end
    end
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

-- Botão ativar/desativar
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
        local char = player.Character or player.CharacterAdded:Wait()
        char:WaitForChild("Humanoid")
        task.wait(0.5)
        ativarImortal()
    end
end)

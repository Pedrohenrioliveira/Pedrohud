-- SERVIÇOS E VARIÁVEIS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local running = false
local connections = {}

-- CONFIGURAR GRUPO DE COLISÃO
pcall(function()
    PhysicsService:CreateCollisionGroup("Ghost")
    PhysicsService:CollisionGroupSetCollidable("Ghost", "Default", false)
end)

-- GUI PRINCIPAL E BARRA DE CARREGAMENTO
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImortalUI"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false
screenGui.Parent = coreGui

local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingUI"
loadingGui.ResetOnSpawn = false
loadingGui.Parent = coreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BorderSizePixel = 0
frame.Parent = loadingGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.5, 0)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundTransparency = 1
title.Text = "Dead Rails"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.Font = Enum.Font.SourceSansBold
title.TextWrapped = true
title.Parent = frame

local barBg = Instance.new("Frame")
barBg.Size = UDim2.new(0.9, 0, 0.25, 0)
barBg.Position = UDim2.new(0.05, 0, 0.6, 0)
barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
barBg.BorderSizePixel = 0
barBg.Parent = frame

local barFill = Instance.new("Frame")
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
barFill.BorderSizePixel = 0
barFill.Parent = barBg

-- ANIMA A BARRA POR 10 SEGUNDOS
task.spawn(function()
    local tweenInfo = TweenInfo.new(10, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local tween = TweenService:Create(barFill, tweenInfo, { Size = UDim2.new(1, 0, 1, 0) })
    tween:Play()
    tween.Completed:Wait()
    loadingGui:Destroy()
    screenGui.Enabled = true
end)

-- BOTÃO
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

-- FUNÇÃO DE ATIVAR PODERES
local function ativarImortal()
    running = true
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    humanoid.BreakJointsOnDeath = false
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge

    -- Colisão e invisibilidade para mobs
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            PhysicsService:SetPartCollisionGroup(part, "Ghost")
        end
    end
    char.Name = "GhostPlayer_" .. math.random(1000,9999)

    -- Regeneração constante
    table.insert(connections, RunService.Heartbeat:Connect(function()
        if humanoid then
            humanoid.Health = math.huge
            humanoid.PlatformStand = false
            humanoid.Sit = false
        end
    end))

    -- Substitui Humanoid se for deletado
    table.insert(connections, char.ChildRemoved:Connect(function(c)
        if c.Name == "Humanoid" then
            task.wait(0.1)
            if not char:FindFirstChild("Humanoid") then
                local novo = Instance.new("Humanoid")
                novo.BreakJointsOnDeath = false
                novo.MaxHealth = math.huge
                novo.Health = math.huge
                novo.Parent = char
            end
        end
    end))

    -- Dano infinito em NPCs
    local function aplicarDanoInfinito(obj)
        for _, part in pairs(obj:GetDescendants()) do
            if part:IsA("BasePart") then
                local conn = part.Touched:Connect(function(hit)
                    local enemyChar = hit:FindFirstAncestorOfClass("Model")
                    if not enemyChar or enemyChar == char then return end
                    if Players:GetPlayerFromCharacter(enemyChar) then return end
                    local enemyHum = enemyChar:FindFirstChildWhichIsA("Humanoid")
                    if enemyHum then
                        pcall(function() enemyHum.Health = 0 end)
                    end
                end)
                table.insert(connections, conn)
            end
        end
    end

    aplicarDanoInfinito(char)
    for _, tool in pairs(char:GetChildren()) do
        if tool:IsA("Tool") then aplicarDanoInfinito(tool) end
    end
    table.insert(connections, char.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") then aplicarDanoInfinito(obj) end
    end))
end

-- DESATIVAR
local function desativar()
    running = false
    local char = player.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(part, "Default")
                part.CanCollide = true
            end
        end
        local humanoid = char:FindFirstChildWhichIsA("Humanoid")
        if humanoid then
            humanoid.MaxHealth = 100
            humanoid.Health = 100
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            humanoid.BreakJointsOnDeath = true
        end
    end
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

-- CLIQUE DO BOTÃO
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

-- REAPLICA APÓS MORRER
player.CharacterAdded:Connect(function()
    if running then
        task.wait(0.5)
        ativarImortal()
    end
end)

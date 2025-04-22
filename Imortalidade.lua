local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local player = Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local running = false
local connections = {}

-- GUI Principal e Carregamento
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ImortalUI"
screenGui.ResetOnSpawn = false
screenGui.Enabled = false -- só ativa após carregamento
screenGui.Parent = coreGui

-- Tela de carregamento (Dead Rails)
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
title.Size = UDim2.new(1, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "Carregando...\nDead Rails"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 24
title.Font = Enum.Font.SourceSansBold
title.TextWrapped = true
title.Parent = frame

-- Mostrar interface depois de 10 segundos
task.delay(10, function()
    loadingGui:Destroy()
    screenGui.Enabled = true
end)

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

-- Criar grupo de colisão para passar por mobs
pcall(function()
    PhysicsService:CreateCollisionGroup("Ghost")
    PhysicsService:CollisionGroupSetCollidable("Ghost", "Default", false)
end)

-- Ativar poderes
local function ativarImortal()
    running = true
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
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

    -- Repor Humanoid se removido
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

    -- Dano infinito contra NPCs
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
        if tool:IsA("Tool") then
            aplicarDanoInfinito(tool)
        end
    end
    table.insert(connections, char.ChildAdded:Connect(function(obj)
        if obj:IsA("Tool") then
            aplicarDanoInfinito(obj)
        end
    end))

    -- Invisível para mobs
    local function tornarIndetectavel()
        char.Name = "FakeNPC_" .. math.random(1000, 9999)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                PhysicsService:SetPartCollisionGroup(part, "Ghost")
            end
        end
        for _, tag in pairs(char:GetDescendants()) do
            if tag:IsA("ObjectValue") or tag:IsA("StringValue") then
                if tostring(tag.Name):lower():find("creator") or tostring(tag.Value):lower():find("player") then
                    tag:Destroy()
                end
            end
        end
    end

    tornarIndetectavel()
end

-- Desativar tudo
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
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                PhysicsService:SetPartCollisionGroup(part, "Default")
                part.CanCollide = true
            end
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

-- Reaplicar poderes após respawn
player.CharacterAdded:Connect(function()
    if running then
        task.wait(0.5)
        ativarImortal()
    end
end)

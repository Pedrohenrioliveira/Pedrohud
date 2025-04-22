-- SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local PhysicsService = game:GetService("PhysicsService")
local player = Players.LocalPlayer
local coreGui = game:GetService("CoreGui")

local running = false
local connections = {}

-- SETUP COLISÃO
pcall(function()
    PhysicsService:CreateCollisionGroup("Ghost")
    PhysicsService:CollisionGroupSetCollidable("Ghost", "Default", false)
end)

-- GUI DE CARREGAMENTO
local loadingGui = Instance.new("ScreenGui", coreGui)
loadingGui.Name = "LoadingUI"
loadingGui.ResetOnSpawn = false

local frame = Instance.new("Frame", loadingGui)
frame.Size = UDim2.new(0, 300, 0, 100)
frame.Position = UDim2.new(0.5, -150, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0.5, 0)
title.Text = "Dead Rails"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 24

local barBg = Instance.new("Frame", frame)
barBg.Size = UDim2.new(0.9, 0, 0.25, 0)
barBg.Position = UDim2.new(0.05, 0, 0.6, 0)
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local bar = Instance.new("Frame", barBg)
bar.Size = UDim2.new(0, 0, 1, 0)
bar.BackgroundColor3 = Color3.fromRGB(0, 170, 255)

local tween = TweenService:Create(bar, TweenInfo.new(10), { Size = UDim2.new(1, 0, 1, 0) })
tween:Play()
tween.Completed:Wait()
loadingGui:Destroy()

-- GUI PRINCIPAL
local screenGui = Instance.new("ScreenGui", coreGui)
screenGui.Name = "ImortalUI"
screenGui.ResetOnSpawn = false

local button = Instance.new("TextButton", screenGui)
button.Size = UDim2.new(0, 100, 0, 30)
button.Position = UDim2.new(1, -110, 0, 10)
button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
button.Text = "LIGAR"
button.TextColor3 = Color3.new(1, 1, 1)
button.Font = Enum.Font.SourceSans
button.TextSize = 16

-- FUNÇÃO PODER TOTAL
local function ativarImortal()
    running = true
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    -- Segurança máxima
    humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
    humanoid.BreakJointsOnDeath = false
    humanoid.MaxHealth = math.huge
    humanoid.Health = math.huge
    humanoid.Name = "GodHumanoid"

    -- Invisível e intocável pra mobs
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
            PhysicsService:SetPartCollisionGroup(part, "Ghost")
        end
    end

    -- Regeneração infinita e reset de estados
    table.insert(connections, RunService.Heartbeat:Connect(function()
        if humanoid then
            humanoid.Health = math.huge
            humanoid.PlatformStand = false
            humanoid.Sit = false
        end
    end))

    -- Substituir Humanoid se sumir
    table.insert(connections, char.ChildRemoved:Connect(function(child)
        if child:IsA("Humanoid") then
            task.wait(0.1)
            if not char:FindFirstChildWhichIsA("Humanoid") then
                local newHum = Instance.new("Humanoid")
                newHum.Name = "GodHumanoid"
                newHum.Health = math.huge
                newHum.MaxHealth = math.huge
                newHum.BreakJointsOnDeath = false
                newHum.Parent = char
            end
        end
    end))

    -- Dano infinito em NPCs
    local function danoInfinito(container)
        for _, obj in pairs(container:GetDescendants()) do
            if obj:IsA("BasePart") then
                local conn = obj.Touched:Connect(function(hit)
                    local model = hit:FindFirstAncestorOfClass("Model")
                    if model and model ~= char and not Players:GetPlayerFromCharacter(model) then
                        local enemyHum = model:FindFirstChildWhichIsA("Humanoid")
                        if enemyHum then
                            pcall(function()
                                enemyHum.Health = 0
                            end)
                        end
                    end
                end)
                table.insert(connections, conn)
            end
        end
    end

    danoInfinito(char)

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            danoInfinito(tool)
        end
    end

    table.insert(connections, char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            danoInfinito(child)
        end
    end))
end

-- DESATIVAR
local function desativar()
    running = false
    local char = player.Character
    local humanoid = char and char:FindFirstChildWhichIsA("Humanoid")

    if humanoid then
        humanoid.MaxHealth = 100
        humanoid.Health = 100
        humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
        humanoid.BreakJointsOnDeath = true
    end

    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(part, "Default")
            part.CanCollide = true
        end
    end

    for _, c in pairs(connections) do
        pcall(function() c:Disconnect() end)
    end
    connections = {}
end

-- BOTÃO
button.MouseButton1Click:Connect(function()
    if running then
        desativar()
        button.Text = "LIGAR"
        button.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    else
        ativarImortal()
        button.Text = "DESLIGAR"
        button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    end
end)

-- REAPLICAR NO RESPAWN
player.CharacterAdded:Connect(function()
    if running then
        task.wait(0.5)
        ativarImortal()
    end
end)

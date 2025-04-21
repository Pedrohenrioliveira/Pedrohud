local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local player     = Players.LocalPlayer
local coreGui    = game:GetService("CoreGui")
local running    = false
local connections = {}

-- GUI Setup
local screenGui = Instance.new("ScreenGui", coreGui)
screenGui.Name = "ToggleImortal"
screenGui.ResetOnSpawn = false

-- Botão LIGAR/DESLIGAR Imortalidade & Dano Infinito
local buttonAtivar = Instance.new("TextButton")
buttonAtivar.Size = UDim2.new(0, 60, 0, 25)
buttonAtivar.Position = UDim2.new(1, -140, 0, 10)
buttonAtivar.Text = "LIGAR"
buttonAtivar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
buttonAtivar.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonAtivar.BorderSizePixel = 0
buttonAtivar.Font = Enum.Font.SourceSans
buttonAtivar.TextSize = 16
buttonAtivar.Parent = screenGui

-- Botão CLONAR Barra de Ouro
local buttonClonar = Instance.new("TextButton")
buttonClonar.Size = UDim2.new(0, 60, 0, 25)
buttonClonar.Position = UDim2.new(1, -70, 0, 10)
buttonClonar.Text = "CLONAR"
buttonClonar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
buttonClonar.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonClonar.BorderSizePixel = 0
buttonClonar.Font = Enum.Font.SourceSans
buttonClonar.TextSize = 16
buttonClonar.Parent = screenGui

-- Função: clonar uma barra de ouro se estiver na mão
local function clonarBarraDeOuro()
    local char = player.Character
    if not char then return end
    local gold = char:FindFirstChild("GoldBar")
    if gold then
        local clone = gold:Clone()
        clone.Parent = player.Backpack
    end
end

-- Função: ativar imortalidade e dano infinito
local function ativarImortal()
    running = true
    local char = player.Character or player.CharacterAdded:Wait()
    local humanoid = char:WaitForChild("Humanoid")

    -- Manter saúde sempre no máximo
    table.insert(connections, humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end))

    -- Recriar Humanoid se for removido
    table.insert(connections, char.ChildRemoved:Connect(function(c)
        if c.Name == "Humanoid" then
            wait(0.1)
            local novo = Instance.new("Humanoid")
            novo.Name = "Humanoid"
            novo.Parent = char
        end
    end))

    -- Loop para garantir saúde máxima
    spawn(function()
        while running and humanoid and humanoid.Parent do
            humanoid.Health = humanoid.MaxHealth
            wait(0.1)
        end
    end)

    -- Dano infinito aos NPCs ao tocar em qualquer parte
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local conn = part.Touched:Connect(function(hit)
                local enemyChar = hit.Parent
                if not enemyChar or enemyChar == char then return end
                local enemyHum = enemyChar:FindFirstChild("Humanoid")
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

-- Função: desativar tudo
local function desativar()
    running = false
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

-- Conexões de clique nos botões
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

buttonClonar.MouseButton1Click:Connect(function()
    clonarBarraDeOuro()
end)

-- Reaplicar imortalidade após respawn
player.CharacterAdded:Connect(function()
    if running then
        wait(0.5)
        ativarImortal()
    end
end)

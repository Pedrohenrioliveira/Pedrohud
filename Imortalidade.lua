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

local buttonAtivar = Instance.new("TextButton")
buttonAtivar.Size = UDim2.new(0, 60, 0, 25)
buttonAtivar.Position = UDim2.new(1, -140, 0, 10)  -- Ajuste a posição para ficar ao lado
buttonAtivar.Text = "LIGAR"
buttonAtivar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
buttonAtivar.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonAtivar.BorderSizePixel = 0
buttonAtivar.Font = Enum.Font.SourceSans
buttonAtivar.TextSize = 16
buttonAtivar.Parent = screenGui

local buttonClonar = Instance.new("TextButton")
buttonClonar.Size = UDim2.new(0, 60, 0, 25)
buttonClonar.Position = UDim2.new(1, -70, 0, 10)  -- Ajuste a posição para ficar ao lado
buttonClonar.Text = "CLONAR"
buttonClonar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
buttonClonar.TextColor3 = Color3.fromRGB(255, 255, 255)
buttonClonar.BorderSizePixel = 0
buttonClonar.Font = Enum.Font.SourceSans
buttonClonar.TextSize = 16
buttonClonar.Parent = screenGui

-- Clonar barras de ouro infinitamente
local function clonarBarrasDeOuro()
    local backpack = player.Backpack
    local gold = backpack:FindFirstChild("GoldBar")
    
    if gold then
        spawn(function()
            while running and gold.Parent do
                for i = 1, 100 do  -- Ajuste o número de clones conforme necessário
                    local clone = gold:Clone()
                    clone.Parent = backpack
                end
                wait(0.5)  -- Atraso para evitar sobrecarga
            end
        end)
    end
end

-- Função para clonar uma barra de ouro ao clicar no botão "CLONAR"
local function clonarUmaBarraDeOuro()
    local backpack = player.Backpack
    local gold = backpack:FindFirstChild("GoldBar")
    
    if gold then
        local clone = gold:Clone()
        clone.Parent = backpack
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

    clonarBarrasDeOuro()  -- Adiciona a clonagem de barras de ouro
end

-- Desativar tudo
local function desativar()
    running = false
    for _, conn in pairs(connections) do
        pcall(function() conn:Disconnect() end)
    end
    connections = {}
end

-- Alternância do botão "Ativar"
buttonAtivar.MouseButton1Click:Connect(function()
    if running then
        desativar()
        buttonAtivar.Text = "LIGAR"
        buttonAtivar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    else
        ativar()
        buttonAtivar.Text = "DESLIGAR"
        buttonAtivar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    end
end)

-- Botão "Clonar" para clonar uma barra de ouro ao clicar
buttonClonar.MouseButton1Click:Connect(function()
    clonarUmaBarraDeOuro()
end)

-- Reativa após respawn
player.CharacterAdded:Connect(function()
    if running then
        wait(0.5)
        ativar()
    end
end)

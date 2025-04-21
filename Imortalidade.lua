local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local coreGui = game:GetService("CoreGui")
local running = false
local cloningActive = false  -- Variável para controlar a clonagem
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

-- Função para clonar a barra de ouro enquanto estiver segurando
local function clonarBarrasDeOuro()
    local backpack = player.Backpack
    local gold = backpack:FindFirstChild("GoldBar")
    
    if gold then
        spawn(function()
            while cloningActive and gold.Parent do
                if backpack:FindFirstChild("GoldBar") then
                    -- Clonando a barra de ouro enquanto o jogador está segurando
                    local clone = gold:Clone()
                    clone.Parent = backpack
                    wait(0.1)  -- Atraso para não sobrecarregar o servidor
                end
            end
        end)
    end
end

-- Função para ativar a clonagem
local function ativarClonagem()
    cloningActive = true
    clonarBarrasDeOuro()
    buttonClonar.Text = "DESCLONAR"
    buttonClonar.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
end

-- Função para desativar a clonagem
local function desativarClonagem()
    cloningActive = false
    buttonClonar.Text = "CLONAR"
    buttonClonar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
end

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

-- Alternância do botão "Clonar"
buttonClonar.MouseButton1Click:Connect(function()
    if cloningActive then
        desativarClonagem()  -- Desativa a clonagem
    else
        ativarClonagem()  -- Ativa a clonagem
    end
end)

-- Reativa após respawn
player.CharacterAdded:Connect(function()
    if running then
        wait(0.5)
        ativar()
    end
end)

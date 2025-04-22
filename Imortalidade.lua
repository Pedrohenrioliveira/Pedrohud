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

-- Lista de possíveis nomes
local nomesPossiveis = {
    "barra de ouro",
    "gold bar",
    "goldbar",
    "ouro",
    "gold"
}

-- Verifica se o nome do objeto é compatível
local function nomeValido(nome)
    nome = nome:lower()
    for _, n in pairs(nomesPossiveis) do
        if nome:find(n) then
            return true
        end
    end
    return false
end

-- Função: clonar objeto flutuante
local function clonarItemFlutuando()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
            if nomeValido(obj.Name) then
                local mag = (obj.Position - char.HumanoidRootPart.Position).Magnitude
                if mag < 10 then -- está perto do jogador
                    local clone = obj:Clone()
                    clone.Anchored = false
                    clone.Parent = workspace
                    clone.CFrame = obj.CFrame + Vector3.new(2, 0, 0)
                    print("Item flutuando clonado!")
                    return
                end
            end
        end
    end

    warn("Nenhum item flutuando encontrado.")
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
            task.wait(0.1)
            if not char:FindFirstChild("Humanoid") then
                local novo = Instance.new("Humanoid")
                novo.Name = "Humanoid"
                novo.Parent = char
            end
        end
    end))

    -- Loop para garantir saúde máxima
    task.spawn(function()
        while running and humanoid and humanoid.Parent do
            humanoid.Health = humanoid.MaxHealth
            task.wait(0.1)
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
    clonarItemFlutuando()
end)

-- Reaplicar imortalidade após respawn
player.CharacterAdded:Connect(function()
    if running then
        task.wait(0.5)
        ativarImortal()
    end
end)

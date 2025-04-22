local Players = game:GetService("Players")
local player = Players.LocalPlayer
local coreGui = game:GetService("CoreGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CloneUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = coreGui

-- Botão CLONAR
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

-- Variável para o ouro
local ouroClonado = nil

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

-- Função para clonar o ouro flutuante
local function clonarItemFlutuando()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
            if nomeValido(obj.Name) then
                local mag = (obj.Position - char.HumanoidRootPart.Position).Magnitude
                if mag < 10 then -- Está perto do jogador
                    local clone = obj:Clone()
                    clone.Anchored = false
                    clone.Parent = workspace
                    clone.CFrame = obj.CFrame + Vector3.new(2, 0, 0)

                    -- Guardar a referência ao ouro clonado
                    ouroClonado = clone

                    -- Conectar o evento de venda
                    clone.Touched:Connect(function(hit)
                        if hit.Parent == player.Character then
                            venderOuro(clone)
                        end
                    end)

                    print("Item flutuando clonado!")
                    return
                end
            end
        end
    end

    warn("Nenhum item flutuando encontrado.")
end

-- Função para vender o ouro
local function venderOuro(ouro)
    local valorVenda = 100  -- Defina o valor de venda do ouro
    local playerMoeda = player:FindFirstChild("Moeda") -- O player precisa ter um objeto Moeda

    -- Se o player não tiver a moeda, cria a moeda
    if not playerMoeda then
        playerMoeda = Instance.new("IntValue")
        playerMoeda.Name = "Moeda"
        playerMoeda.Value = 0
        playerMoeda.Parent = player
    end

    -- Adiciona o valor da venda à moeda do jogador
    playerMoeda.Value = playerMoeda.Value + valorVenda

    -- Destruir o ouro clonado após a venda
    if ouro then
        ouro:Destroy()
    end

    print("Ouro vendido! Moeda do jogador: " .. playerMoeda.Value)
end

-- Clique no botão para clonar o ouro
buttonClonar.MouseButton1Click:Connect(function()
    clonarItemFlutuando()
end)

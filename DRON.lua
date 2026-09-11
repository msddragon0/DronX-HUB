-- ============================================================
-- DRONX v4.1 – Auto Farm + Auto Maestria (CORRIGIDO)
-- ============================================================

print("[DRONX] Carregando...")

-- ====== CONFIGURAÇÕES ======
getgenv().DRONX = {
    AutoFarm = false,
    AutoMaestria = false,
    AutoHeal = false,
    AutoCollect = false,
    TipoArma = "Sword",
    MaxDistance = 1000,
    HealThreshold = 0.5,
    posX = 0,
    posY = 30,
    posZ = 0,
}

local armaEquipada = nil
local npcAtual = nil

-- ====== JOGADOR ======
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

player.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
    armaEquipada = nil
    print("[DRONX] Respawnou.")
end)

-- ====== HOOK DO COMBAT FRAMEWORK ======
local plr = game.Players.LocalPlayer
local CbFw2 = nil

pcall(function()
    local CF = plr.PlayerScripts:FindFirstChild("CombatFramework")
    if CF then CbFw2 = debug.getupvalues(require(CF))[2] end
end)

if not CbFw2 then
    pcall(function()
        local CF = game.ReplicatedStorage:FindFirstChild("CombatFramework")
        if CF then CbFw2 = debug.getupvalues(require(CF))[2] end
    end)
end

if not CbFw2 then
    pcall(function()
        local CF = game.ReplicatedStorage.Controllers:FindFirstChild("CombatController")
        if CF then CbFw2 = debug.getupvalues(require(CF))[2] end
    end)
end

if CbFw2 then
    print("[DRONX] ✅ Hook carregado!")
else
    warn("[DRONX] ❌ Hook falhou. Vai usar keypress.")
end

local function GetCurrentBlade() 
    if not CbFw2 or not CbFw2.activeController then return end
    local p13 = CbFw2.activeController
    local ret = p13.blades[1]
    if not ret then return end
    while ret.Parent ~= game.Players.LocalPlayer.Character do 
        ret = ret.Parent 
    end
    return ret
end

-- ====== ATAQUE (olha pro NPC e clica) ======
local function atacarRapido(npc)
    pcall(function()
        if npc and npc.Parent and npc:FindFirstChild("HumanoidRootPart") then
            local hrp = npc.HumanoidRootPart
            local direcao = (hrp.Position - rootPart.Position).Unit
            rootPart.CFrame = CFrame.new(rootPart.Position, rootPart.Position + direcao)
        end
        mouse1click()
    end)
end

-- ====== EQUIPAR ARMA ======
local function equiparArma(tipoForcado)
    local tipo = tipoForcado or getgenv().DRONX.TipoArma or "Melee"
    
    local armaAtual = player.Character:FindFirstChildOfClass("Tool")
    if armaAtual and armaAtual.ToolTip == tipo then
        return
    end
    
    for _, tool in pairs(player.Backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.ToolTip == tipo then
            pcall(function()
                player.Character.Humanoid:EquipTool(tool)
                armaEquipada = tool.Name
            end)
            return
        end
    end
end

-- ====== HAKI ======
local function autoHaki()
    if not player.Character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end

-- ====== ACHAR NPC ======
local function getClosestNPC()
    local closest, minDist = nil, math.huge
    local enemiesFolder = workspace:FindFirstChild("Enemies")
    if not enemiesFolder then return nil end

    for _, npc in pairs(enemiesFolder:GetChildren()) do
        if npc:IsA("Model") and not npc.Name:lower():find("brigade") and not npc.Name:lower():find("boat") then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if hum and hum:IsA("Humanoid") and hum.Health > 0 and hrp then
                local dist = (rootPart.Position - hrp.Position).Magnitude
                if dist < minDist and dist <= getgenv().DRONX.MaxDistance then
                    minDist = dist
                    closest = npc
                end
            end
        end
    end
    return closest
end

-- ====== ATACAR NPC ======
local function attackNPC(npc)
    if not npc or not npc.Parent then return end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return end

    local posX = getgenv().DRONX.posX or 0
    local posY = getgenv().DRONX.posY or 15  -- 🔥 15 studs (mais perto)
    local posZ = getgenv().DRONX.posZ or 0
    
    rootPart.CFrame = hrp.CFrame * CFrame.new(posX, posY, posZ)

    pcall(function()
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hrp.CanCollide = false
        hrp.Size = Vector3.new(60, 60, 60)
        hrp.CFrame = rootPart.CFrame * CFrame.new(-posX, -posY, -posZ)
    end)

    if getgenv().DRONX.AutoFarm then
        equiparArma("Melee")
    elseif getgenv().DRONX.AutoMaestria then
        equiparArma()
    end
    
    task.wait(0.3)
    autoHaki()

    for i = 1, 20 do
        atacarRapido(npc)
        task.wait(0.1)
    end
end

-- ====== BODYCLIP ======
local function atualizarBodyClip()
    pcall(function()
        if getgenv().DRONX.AutoFarm or getgenv().DRONX.AutoMaestria then
            if not player.Character.HumanoidRootPart:FindFirstChild("BodyClip") then
                local Noclip = Instance.new("BodyVelocity")
                Noclip.Name = "BodyClip"
                Noclip.Parent = player.Character.HumanoidRootPart
                Noclip.MaxForce = Vector3.new(100000, 100000, 100000)
                Noclip.Velocity = Vector3.new(0, 0, 0)
            end
        else
            local bc = player.Character.HumanoidRootPart:FindFirstChild("BodyClip")
            if bc then bc:Destroy() end
        end
    end)
end

-- ====== CURA ======
local function autoHeal()
    if not humanoid or humanoid.Health <= 0 then return end
    if humanoid.Health / humanoid.MaxHealth < getgenv().DRONX.HealThreshold then
        local pociones = {"Potion", "Devil Fruit", "Mochi", "Dough", "Ice Cream", "Cake", "Candy", "Chocolate", "Bomb"}
        for _, nome in ipairs(pociones) do
            local item = player.Backpack:FindFirstChild(nome) or character:FindFirstChild(nome)
            if item and item:IsA("Tool") then
                pcall(function()
                    if item.Parent == player.Backpack then
                        player.Character.Humanoid:EquipTool(item)
                        task.wait(0.1)
                    end
                    item:Activate()
                    task.wait(0.3)
                end)
                return
            end
        end
    end
end

-- ====== COLETAR ======
local function autoCollect()
    if npcAtual and npcAtual.Parent then
        local h = npcAtual:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 then return end
    end

    for _, item in pairs(workspace:GetChildren()) do
        if item:IsA("Model") or item:IsA("Tool") then
            local handle = item:FindFirstChild("Handle")
            local clickDetector = item:FindFirstChildOfClass("ClickDetector") 
                or (handle and handle:FindFirstChildOfClass("ClickDetector"))
            
            if handle then
                local dist = (rootPart.Position - handle.Position).Magnitude
                if dist < 30 then
                    if clickDetector then
                        local posAnterior = rootPart.CFrame
                        rootPart.CFrame = CFrame.new(handle.Position + Vector3.new(0, 3, 0))
                        task.wait(0.1)
                        fireclickdetector(clickDetector)
                        task.wait(0.2)
                        rootPart.CFrame = posAnterior
                        break
                    end
                end
            end
        end
    end
end

-- ====== LOOP PRINCIPAL ======
coroutine.wrap(function()
    while true do
        task.wait(0.3)
        atualizarBodyClip()

        if getgenv().DRONX.AutoFarm or getgenv().DRONX.AutoMaestria then
            if character and character.Parent and humanoid and humanoid.Health > 0 then
                if getgenv().DRONX.AutoHeal then autoHeal() end
                if getgenv().DRONX.AutoCollect then autoCollect() end

                local npcValido = false
                if npcAtual and npcAtual.Parent then
                    local h = npcAtual:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then npcValido = true end
                end

                if npcValido then
                    attackNPC(npcAtual)
                else
                    npcAtual = nil
                    local novo = getClosestNPC()
                    if novo then
                        npcAtual = novo
                        attackNPC(novo)
                    end
                end
            else
                task.wait(2)
            end
        end
    end
end)()

-- ====== GUI (FLUENT) ======
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "DRONX HUB",
    SubTitle = "v4.1",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 320),
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Config = Window:AddTab({ Title = "Config", Icon = "settings" })
}

Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm (Soco)",
    Default = false,
    Callback = function(v)
        getgenv().DRONX.AutoFarm = v
        if v then getgenv().DRONX.AutoMaestria = false end
        Fluent:Notify({Title = "DRONX", Content = v and "Auto Farm ATIVADO!" or "Auto Farm DESATIVADO", Duration = 3})
    end
})

Tabs.Main:AddToggle("AutoMaestria", {
    Title = "Auto Maestria",
    Default = false,
    Callback = function(v)
        getgenv().DRONX.AutoMaestria = v
        if v then getgenv().DRONX.AutoFarm = false end
        Fluent:Notify({Title = "DRONX", Content = v and "Auto Maestria ATIVADA!" or "Auto Maestria DESATIVADA", Duration = 3})
    end
})

Tabs.Main:AddDropdown("TipoArma", {
    Title = "Tipo de Arma (Maestria)",
    Values = {"Sword", "Melee", "Blox Fruit", "Gun"},
    Default = "Sword",
    Callback = function(v)
        getgenv().DRONX.TipoArma = v
        armaEquipada = nil
    end
})

Tabs.Main:AddToggle("AutoCollect", {
    Title = "Auto Coletar",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoCollect = v end
})

Tabs.Main:AddToggle("AutoHeal", {
    Title = "Auto Cura",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoHeal = v end
})

Tabs.Config:AddParagraph({Title = "Posição em relação ao NPC", Content = "Ajuste onde seu boneco fica"})

Tabs.Config:AddSlider("SliderX", {
    Title = "Posição X (Lado)",
    Default = 0, Min = -30, Max = 30, Rounding = 1,
    Callback = function(v) getgenv().DRONX.posX = v end
})

Tabs.Config:AddSlider("SliderY", {
    Title = "Posição Y (Altura)",
    Default = 30, Min = 0, Max = 60, Rounding = 1,
    Callback = function(v) getgenv().DRONX.posY = v end
})

Tabs.Config:AddSlider("SliderZ", {
    Title = "Posição Z (Frente/Trás)",
    Default = 0, Min = -30, Max = 30, Rounding = 1,
    Callback = function(v) getgenv().DRONX.posZ = v end
})

local StatusLabel = Tabs.Config:AddParagraph({
    Title = "Status",
    Content = "Carregando..."
})

coroutine.wrap(function()
    while task.wait(1) do
        pcall(function()
            local p = game.Players.LocalPlayer
            StatusLabel:SetDesc(
                "Nivel: " .. p.Data.Level.Value ..
                " | $: " .. p.Data.Beli.Value ..
                " | Vida: " .. math.floor(p.Character.Humanoid.Health)
            )
        end)
    end
end)()

-- ====== BOTÃO FLUTUANTE + MINIMIZAR (estilo Kavo) ======
local screenGuiBtn = Instance.new("ScreenGui")
screenGuiBtn.Name = "DRONX_BotaoFlutuante"
screenGuiBtn.ResetOnSpawn = false
screenGuiBtn.Parent = game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- 🔥 Ícone de 3 pontinhos (estilo Kavo)
local floatingToggle = Instance.new("Frame")
floatingToggle.Size = UDim2.new(0, 45, 0, 45)
floatingToggle.Position = UDim2.new(0, 20, 0.5, -22)
floatingToggle.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
floatingToggle.Visible = false
floatingToggle.ZIndex = 999
floatingToggle.Active = true
floatingToggle.Draggable = true
floatingToggle.Parent = screenGuiBtn

local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(1, 0)
cornerBtn.Parent = floatingToggle

local strokeBtn = Instance.new("UIStroke")
strokeBtn.Color = Color3.fromRGB(255, 215, 0)
strokeBtn.Thickness = 2
strokeBtn.Parent = floatingToggle

-- Layout dos 3 pontinhos
local dotLayout = Instance.new("UIListLayout")
dotLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
dotLayout.VerticalAlignment = Enum.VerticalAlignment.Center
dotLayout.Padding = UDim.new(0, 4)
dotLayout.Parent = floatingToggle

-- Cria 3 pontinhos
for i = 1, 3 do
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 5, 0, 5)
    dot.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    dot.BorderSizePixel = 0
    dot.Parent = floatingToggle
    
    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = dot
end

-- Declara fluentGui PRIMEIRO
local function encontrarFluent()
    local function procurar(pai)
        for _, gui in pairs(pai:GetChildren()) do
            if gui:IsA("ScreenGui") and gui ~= screenGuiBtn then
                if gui.Name:lower():find("fluent") or gui.Name:lower():find("dawid") then
                    return gui
                end
            end
        end
        return nil
    end
    return procurar(game:GetService("CoreGui")) or procurar(game.Players.LocalPlayer.PlayerGui)
end

local fluentGui = encontrarFluent()
if not fluentGui then
    task.wait(2)
    fluentGui = encontrarFluent()
end

-- 🔥 Botão pra restaurar (clicar no ícone)
local function restaurarJanela()
    if fluentGui and fluentGui.Parent then
        fluentGui.Enabled = true
    end
    pcall(function()
        Window:Show()
    end)
    floatingToggle.Visible = false
end

local startPos
floatingToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        startPos = input.Position
    end
end)

floatingToggle.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if startPos then
            local endPos = input.Position
            -- Só restaura se foi um clique (não arrasto)
            if (startPos - endPos).Magnitude < 10 then
                restaurarJanela()
            end
            startPos = nil
        end
    end
end)

-- 🔥 Botão de minimizar DENTRO do Fluent (adicionado via código)
local function adicionarBotaoMinimizar()
    -- Procura a janela do Fluent
    local fluentFrame = nil
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and gui ~= screenGuiBtn then
            for _, v in pairs(gui:GetDescendants()) do
                -- Procura o frame principal (aquele com botão de fechar)
                if v:IsA("TextButton") and (v.Text == "X" or v.Name == "Close") then
                    fluentFrame = v.Parent
                    break
                end
            end
            if fluentFrame then break end
        end
    end
    
    if not fluentFrame then
        warn("[DRONX] Não achei o botão de fechar do Fluent")
        return
    end
    
    print("[DRONX] ✅ Achei a janela do Fluent!")
    
    -- Cria o botão de minimizar ao lado do fechar
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "DRONX_Minimize"
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(1, -65, 0.5, -12)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 18
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.ZIndex = 999
    minimizeBtn.Parent = fluentFrame
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeBtn
    
    minimizeBtn.MouseButton1Click:Connect(function()
        print("[DRONX] Minimizando...")
        pcall(function()
            Window:Hide()
        end)
        if fluentGui and fluentGui.Parent then
            fluentGui.Enabled = false
        end
        task.wait(0.1)
        floatingToggle.Visible = true
    end)
end

-- Tenta adicionar o botão minimizar (com delay)
task.wait(1)
pcall(adicionarBotaoMinimizar)

-- Se falhar, tenta de novo depois
if not getgenv().DRONX_MinimizeOK then
    task.wait(2)
    pcall(adicionarBotaoMinimizar)
end

-- ====== BOTÃO DO CANTO ESQUERDO (mantém pra abrir/fechar tbm) ======
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 80, 0.5, -22)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleBtn.Text = "◀"
toggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
toggleBtn.TextSize = 22
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Draggable = true
toggleBtn.Parent = screenGuiBtn

local cornerBtn2 = Instance.new("UICorner")
cornerBtn2.CornerRadius = UDim.new(1, 0)
cornerBtn2.Parent = toggleBtn

local strokeBtn2 = Instance.new("UIStroke")
strokeBtn2.Color = Color3.fromRGB(255, 215, 0)
strokeBtn2.Thickness = 2
strokeBtn2.Parent = toggleBtn

local guiAberta = true

toggleBtn.MouseButton1Click:Connect(function()
    guiAberta = not guiAberta
    local sucesso = pcall(function()
        if guiAberta then Window:Show() else Window:Hide() end
    end)
    if not sucesso then
        if not fluentGui or not fluentGui.Parent then
            fluentGui = encontrarFluent()
        end
        if fluentGui then fluentGui.Enabled = guiAberta end
    end
    toggleBtn.Text = guiAberta and "◀" or "▶"
    toggleBtn.BackgroundColor3 = guiAberta and Color3.fromRGB(25, 25, 35) or Color3.fromRGB(50, 0, 0)
end)

print("[DRONX] Carregado com sucesso!")
print("[DRONX] Se aparecer 3 pontinhos = minimize. Clique neles pra restaurar.")

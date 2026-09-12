-- ============================================================
-- DRONX v4.2 – Auto Farm + Auto Maestria (RegisterAttack)
-- ============================================================

print("[DRONX] Carregando...")

-- ====== CAPTURA DO REGISTER ATTACK ======
getgenv().DRONX_REMOTES = getgenv().DRONX_REMOTES or {}

pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            local nome = ""
            pcall(function() nome = self.Name end)
            if nome and nome:lower():find("registerattack") then
                getgenv().DRONX_REMOTES.RegisterAttack = self
            end
        end
        return oldNamecall(self, ...)
    end)
end)

print("[DRONX] Capturador de RegisterAttack instalado.")

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

-- 🔥 Tenta aumentar hitbox (se CombatController existir)
pcall(function()
    local CombatController = require(game.ReplicatedStorage.Controllers.CombatController)
    task.spawn(function()
        while task.wait(0.1) do
            pcall(function()
                if CombatController and CombatController.activeController then
                    CombatController.activeController.hitboxMagnitude = 200
                end
            end)
        end
    end)
end)

-- ====== ATAQUE (com Lerp - olhar suave) ======
local RunService = game:GetService("RunService")

local function atacarRapido(npc)
    pcall(function()
        -- 🔥 Lerp: olha pro NPC suavemente (não teleporta)
        if npc and npc.Parent and npc:FindFirstChild("HumanoidRootPart") then
            local hrp = npc.HumanoidRootPart
            local alvo = CFrame.lookAt(rootPart.Position, hrp.Position)
            rootPart.CFrame = rootPart.CFrame:Lerp(alvo, 0.3)
        end
        
        if getgenv().DRONX_REMOTES and getgenv().DRONX_REMOTES.RegisterAttack then
            getgenv().DRONX_REMOTES.RegisterAttack:FireServer(0.4, 1, nil)
        end
        
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
        task.wait(0.05)
        game:GetService("VirtualUser"):Button1Up(Vector2.new(1280, 672))
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
    local posY = getgenv().DRONX.posY or 3
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
    
    -- 🔥 Força um ataque extra depois
    task.wait(0.1)
    atacarRapido(npc)
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
    SubTitle = "v4.2",
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
        Fluent:Notify({Title = "DRONX", Content = v and "Farm ON!" or "Farm OFF", Duration = 2})
        
        -- 🔥 Esconde a GUI automaticamente ao ligar o farm
        if v then
            task.wait(1)
            for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name:lower():find("fluent") then
                    gui.Enabled = false
                end
            end
        end
    end
})

Tabs.Main:AddToggle("AutoMaestria", {
    Title = "Auto Maestria",
    Default = false,
    Callback = function(v)
        getgenv().DRONX.AutoMaestria = v
        if v then getgenv().DRONX.AutoFarm = false end
        Fluent:Notify({Title = "DRONX", Content = v and "Maestria ON!" or "Maestria OFF", Duration = 2})
        
        if v then
            task.wait(1)
            for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name:lower():find("fluent") then
                    gui.Enabled = false
                end
            end
        end
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

-- ====== BOTÃO FLUTUANTE (funcional) ======
local screenGuiBtn = Instance.new("ScreenGui")
screenGuiBtn.Name = "DRONX_Botao"
screenGuiBtn.ResetOnSpawn = false
screenGuiBtn.Parent = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")

-- 🔥 Função pra achar a GUI do Fluent
local function getFluentGui()
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and gui ~= screenGuiBtn then
            if gui.Name:lower():find("fluent") or gui.Name:lower():find("dawid") or gui.Name:lower():find("main") then
                return gui
            end
        end
    end
    return nil
end

-- 🔥 Botão ◀/▶ do canto
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleBtn.Text = "▶"
toggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
toggleBtn.TextSize = 24
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Draggable = true
toggleBtn.Parent = screenGuiBtn

local c = Instance.new("UICorner")
c.CornerRadius = UDim.new(1, 0)
c.Parent = toggleBtn

local s = Instance.new("UIStroke")
s.Color = Color3.fromRGB(255, 215, 0)
s.Thickness = 2
s.Parent = toggleBtn

-- 🔥 Toggle
local aberta = true
toggleBtn.MouseButton1Click:Connect(function()
    aberta = not aberta
    local gui = getFluentGui()
    if gui then
        gui.Enabled = aberta
        print("[DRONX] GUI " .. (aberta and "ABERTA" or "FECHADA"))
    else
        warn("[DRONX] GUI do Fluent não encontrada")
    end
    toggleBtn.Text = aberta and "◀" or "▶"
end)

print("[DRONX] Carregado com sucesso!")
print("[DRONX] Clique no ◀ pra esconder. Clique no ▶ pra mostrar.")

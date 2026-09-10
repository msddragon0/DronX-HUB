-- ============================================================
-- DRONX v3.3 – Auto Farm + Maestria + Fluent UI
-- ============================================================

print("[DRONX] Carregando...")

-- ====== CONFIGURAÇÕES ======
getgenv().DRONX = {
    AutoFarm = false,
    AutoHeal = false,
    AutoCollect = false,
    Maestria = false,
    TipoArma = "Sword",
    AttackSpeed = 0.3,
    MaxDistance = 1000,
    HealThreshold = 0.5,
}

local armaEquipada = nil

-- ====== ILHAS ======
local ilhas = {
    {nome = "Port Town",         nivel = 1900, coords = CFrame.new(-290, 6, 5343)},
    {nome = "Haunted Castle",    nivel = 2000, coords = CFrame.new(-9515, 164, 5786)},
    {nome = "Great Tree",        nivel = 2200, coords = CFrame.new(2681, 1682, -7190)},
    {nome = "Floating Turtle",   nivel = 2400, coords = CFrame.new(-13274, 531, -7579)},
    {nome = "Castle on the Sea", nivel = 2600, coords = CFrame.new(-5075, 314, -3150)},
}

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

local npcAtual = nil

-- ====== HOOK DE ATAQUE ======
local AC = nil

local sucesso = pcall(function()
    local CombatFramework = require(game:GetService("Players").LocalPlayer.PlayerScripts:WaitForChild("CombatFramework", 5))
    local CameraShaker = require(game.ReplicatedStorage.Util.CameraShaker)
    CameraShaker:Stop()
    AC = debug.getupvalues(CombatFramework)[2]
end)

if not sucesso or not AC then
    warn("[DRONX] Hook falhou, usando fallback.")
end

-- ====== ATAQUE (baseado no Byte Hub) ======
local plr = game.Players.LocalPlayer
local CbFw = debug.getupvalues(require(plr.PlayerScripts.CombatFramework))
local CbFw2 = CbFw[2]

local function GetCurrentBlade()
    local p13 = CbFw2.activeController
    local ret = p13.blades[1]
    if not ret then return end
    while ret.Parent ~= game.Players.LocalPlayer.Character do ret = ret.Parent end
    return ret
end

local function atacarRapido()
    local funcionou = pcall(function()
        if not CbFw2 or not CbFw2.activeController then error("sem hook") end
        local AC = CbFw2.activeController
        local bladehit = require(game.ReplicatedStorage.CombatFramework.RigLib).getBladeHits(
            player.Character,
            {player.Character.HumanoidRootPart},
            60
        )
        local cac, hash = {}, {}
        for k, v in pairs(bladehit) do
            if v.Parent:FindFirstChild("HumanoidRootPart") and not hash[v.Parent] then
                table.insert(cac, v.Parent.HumanoidRootPart)
                hash[v.Parent] = true
            end
        end
        bladehit = cac
        if #bladehit > 0 then
            AC.attacking = false
            AC.timeToNextAttack = 0
            local u8 = debug.getupvalue(AC.attack, 5)
            local u9 = debug.getupvalue(AC.attack, 6)
            local u7 = debug.getupvalue(AC.attack, 4)
            local u10 = debug.getupvalue(AC.attack, 7)
            local u12 = (u8 * 798405 + u7 * 727595) % u9
            local u13 = u7 * 798405
            u12 = (u12 * u9 + u13) % 1099511627776
            u8 = math.floor(u12 / u9)
            u7 = u12 - u8 * u9
            u10 = u10 + 1
            debug.setupvalue(AC.attack, 5, u8)
            debug.setupvalue(AC.attack, 6, u9)
            debug.setupvalue(AC.attack, 4, u7)
            debug.setupvalue(AC.attack, 7, u10)
            pcall(function()
                for k, v in pairs(AC.animator.anims.basic) do v:Play() end
            end)
            if player.Character:FindFirstChildOfClass("Tool") and AC.blades and AC.blades[1] then
                game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("weaponChange", tostring(GetCurrentBlade()))
                game.ReplicatedStorage.Remotes.Validator:FireServer(math.floor(u12 / 1099511627776 * 16777215), u10)
                game:GetService("ReplicatedStorage").RigControllerEvent:FireServer("hit", bladehit, 1, "")
            end
        end
    end)
    
    -- Fallback: se o hook falhar, clica
    if not funcionou then
        pcall(function()
            game:GetService("VirtualUser"):CaptureController()
            game:GetService("VirtualUser"):Button1Down(Vector2.new(1280, 672))
            game:GetService("VirtualUser"):Button1Up(Vector2.new(1280, 672))
        end)
    end
end
            
-- ====== EQUIPAR ARMA ======
local function equiparArma()
    pcall(function()
        local tipo = getgenv().DRONX.TipoArma or "Sword"
        
        -- 🔥 Verifica se o jogador tem PONTOS DE STAT naquele tipo
        local stats = player.Data:FindFirstChild("Stats")
        local temStats = true
        if stats then
            local pontos = {
                ["Sword"] = stats:FindFirstChild("Sword") and stats.Sword.Value or 0,
                ["Melee"] = stats:FindFirstChild("Melee") and stats.Melee.Value or 0,
                ["Blox Fruit"] = stats:FindFirstChild("Devil Fruit") and stats["Devil Fruit"].Value or 0,
                ["Gun"] = stats:FindFirstChild("Gun") and stats.Gun.Value or 0,
            }
            if pontos[tipo] and pontos[tipo] <= 0 then
                temStats = false
                warn("[DRONX] Sem stats em " .. tipo .. "! Usando Melee (soco).")
            end
        end
        
        -- Se não tem stats, usa soco (Melee)
        if not temStats then tipo = "Melee" end
        
        -- Se já está equipado, não troca
        local armaAtual = player.Character:FindFirstChildOfClass("Tool")
        if armaAtual and armaAtual.ToolTip == tipo then
            armaEquipada = armaAtual.Name
            return
        end
        
        -- Procura e equipa
        for _, tool in pairs(player.Backpack:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == tipo then
                player.Character.Humanoid:EquipTool(tool)
                armaEquipada = tool.Name
                return
            end
        end
    end)
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
        if npc:IsA("Model") then
            local hum = npc:FindFirstChildOfClass("Humanoid")
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and hrp then
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

    -- 🔥 Teleporta PRA CIMA (3 studs de altura pra não bugar)
    rootPart.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)

    -- 🔥 Prende o NPC embaixo de você
    pcall(function()
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hrp.CanCollide = false
        hrp.Size = Vector3.new(60, 60, 60)
        hrp.CFrame = rootPart.CFrame * CFrame.new(0, -3, 0)
    end)

    -- 🔥 Equipa arma escolhida
    equiparArma()
    autoHaki()

    -- 🔥 Ataca 5 vezes por ciclo (mais dano)
    for i = 1, 5 do
        atacarRapido()
        task.wait(0.05)
    end
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

-- ====== TROCAR ILHA ======
local function trocarIlha()
    local nivel = player.Data.Level.Value
    local melhorIlha = nil
    for _, ilha in ipairs(ilhas) do
        if nivel >= ilha.nivel then melhorIlha = ilha end
    end
    if melhorIlha then
        rootPart.CFrame = melhorIlha.coords
        print("[DRONX] Indo para " .. melhorIlha.nome)
        task.wait(2)
    end
end

-- ====== LOOP PRINCIPAL ======
coroutine.wrap(function()
    local semNPC = 0
    while true do
        task.wait(0.3)

        if getgenv().DRONX.AutoFarm or getgenv().DRONX.Maestria then
            if character and character.Parent and humanoid and humanoid.Health > 0 then
                if getgenv().DRONX.AutoHeal then autoHeal() end
                if getgenv().DRONX.AutoCollect then autoCollect() end

                local npcValido = false
                if npcAtual and npcAtual.Parent then
                    local h = npcAtual:FindFirstChildOfClass("Humanoid")
                    if h and h.Health > 0 then npcValido = true end
                end

                if npcValido then
                    semNPC = 0
                    attackNPC(npcAtual)
                else
                    npcAtual = nil
                    local novo = getClosestNPC()
                    if novo then
                        semNPC = 0
                        npcAtual = novo
                        attackNPC(novo)
                    else
                        semNPC = semNPC + 1
                        if semNPC >= 30 then
                            trocarIlha()
                            semNPC = 0
                        end
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
    SubTitle = "v3.3",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 320),
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "home" }),
    Config = Window:AddTab({ Title = "Config", Icon = "settings" })
}

Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false,
    Callback = function(v)
        getgenv().DRONX.AutoFarm = v
        Fluent:Notify({
            Title = "DRONX",
            Content = v and "Farm ATIVADO!" or "Farm DESATIVADO",
            Duration = 3
        })
    end
})

Tabs.Main:AddToggle("Maestria", {
    Title = "Farm Maestria",
    Default = false,
    Callback = function(v)
        getgenv().DRONX.Maestria = v
        Fluent:Notify({
            Title = "DRONX",
            Content = v and "Maestria ATIVADA!" or "Maestria DESATIVADA",
            Duration = 3
        })
    end
})

Tabs.Main:AddDropdown("TipoArma", {
    Title = "Tipo de Arma (Maestria)",
    Values = {"Sword", "Melee", "Blox Fruit", "Gun"},
    Default = "Sword",
    Callback = function(v)
        getgenv().DRONX.TipoArma = v
        armaEquipada = nil
        Fluent:Notify({
            Title = "DRONX",
            Content = "Arma: " .. v,
            Duration = 2
        })
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

print("[DRONX] Carregado com sucesso!")

-- ====== BOTÃO FLUTUANTE ======
local screenGuiBtn = Instance.new("ScreenGui")
screenGuiBtn.Name = "DRONX_BotaoFlutuante"
screenGuiBtn.ResetOnSpawn = false
screenGuiBtn.Parent = game:GetService("CoreGui") or game.Players.LocalPlayer:WaitForChild("PlayerGui")

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 45, 0, 45)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -22)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleBtn.Text = "◀"
toggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
toggleBtn.TextSize = 22
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Draggable = true
toggleBtn.Parent = screenGuiBtn

local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(1, 0)
cornerBtn.Parent = toggleBtn

local strokeBtn = Instance.new("UIStroke")
strokeBtn.Color = Color3.fromRGB(255, 215, 0)
strokeBtn.Thickness = 2
strokeBtn.Parent = toggleBtn

local guiAberta = true

local function encontrarFluent()
    local function procurar(pai)
        for _, gui in pairs(pai:GetChildren()) do
            if gui:IsA("ScreenGui") and gui ~= screenGuiBtn then
                if gui.Name:lower():find("fluent") 
                or gui.Name:lower():find("dawid") 
                or gui:FindFirstChild("Main") 
                or gui:FindFirstChild("Fluent") then
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

print("[DRONX] Botão flutuante criado!")

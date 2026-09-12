-- ============================================================
-- DRONX v6.0 – Auto Farm + Boss + Chest + Haki + TP + ESP     
-- ============================================================

print("[DRONX] Carregando...")


-- ====== CAPTURA DO REGISTER ATTACK ======
getgenv().DRONX_REMOTES = getgenv().DRONX_REMOTES or {}

task.spawn(function()
    -- Procura o RegisterAttack em vários caminhos
    local caminhos = {
        function()
            local net = game.ReplicatedStorage.Modules:FindFirstChild("Net")
            if net then
                local re = net:FindFirstChild("RE")
                if re then return re:FindFirstChild("RegisterAttack") end
            end
        end,
        function()
            local net = game.ReplicatedStorage.Modules:FindFirstChild("Net")
            if net then return net:FindFirstChild("RegisterAttack") end
        end,
        function()
            return game.ReplicatedStorage:FindFirstChild("RegisterAttack", true)
        end,
        function()
            return game.ReplicatedStorage.Modules.Net:FindFirstChild("RE/RegisterAttack")
        end,
    }
    
    for i, caminho in ipairs(caminhos) do
        local sucesso, remote = pcall(caminho)
        if sucesso and remote then
            getgenv().DRONX_REMOTES.RegisterAttack = remote
            print("[DRONX] ✅ RegisterAttack capturado! (caminho " .. i .. ")")
            return
        end
    end
    
    -- Se falhar, tenta via getgc (pega todos os objetos do jogo)
    pcall(function()
        for _, v in pairs(getgc()) do
            if type(v) == "table" or typeof(v) == "Instance" then
                pcall(function()
                    if v.Name == "RegisterAttack" then
                        getgenv().DRONX_REMOTES.RegisterAttack = v
                        print("[DRONX] ✅ RegisterAttack capturado via getgc!")
                    end
                end)
            end
        end
    end)
    
    if not getgenv().DRONX_REMOTES.RegisterAttack then
        warn("[DRONX] ❌ RegisterAttack não encontrado. Ataque pode falhar.")
    end
end)

-- Hook de backup (captura se o jogo disparar de qualquer jeito)
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

print("[DRONX] Captura automática de RegisterAttack ativada.")

-- ====== CONFIGURAÇÕES ======
getgenv().DRONX = {
    AutoFarm = false,
    AutoMaestria = false,
    AutoHeal = false,
    AutoCollect = false,
    AutoQuest = false,
    BringMob = false,
    AntiAFK = false,
    AutoBoss = false,
    BossName = "",
    AutoChest = false,
    AutoHaki = false,
    ESP = false,
    FPS = false,
    TipoArma = "Sword",
    MaxDistance = 1000,
    HealThreshold = 0.5,
    posX = 0, posY = 3, posZ = 0,
}

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local npcAtual = nil
local aberta = false
local toggleBtn = nil
local espFolder = nil

player.CharacterAdded:Connect(function(char)
    character = char
    rootPart = char:WaitForChild("HumanoidRootPart")
    humanoid = char:WaitForChild("Humanoid")
end)

-- ====== LISTA DE QUESTS (THIRD SEA) ======
local quests = {
    {lvl = 1500, mon = "Pirate Millionaire", quest = "PiratePortQuest", qlvl = 1, questPos = CFrame.new(-289, 43, 5580), monPos = CFrame.new(-435, 189, 5551)},
    {lvl = 1575, mon = "Dragon Crew Warrior", quest = "AmazonQuest", qlvl = 1, questPos = CFrame.new(5833, 51, -1103), monPos = CFrame.new(6301, 104, -1082)},
    {lvl = 1625, mon = "Female Islander", quest = "AmazonQuest2", qlvl = 1, questPos = CFrame.new(5446, 601, 749), monPos = CFrame.new(5792, 848, 1084)},
    {lvl = 1700, mon = "Marine Commodore", quest = "MarineTreeIsland", qlvl = 1, questPos = CFrame.new(2179, 28, -6740), monPos = CFrame.new(2198, 128, -7109)},
    {lvl = 1775, mon = "Fishman Raider", quest = "DeepForestIsland3", qlvl = 1, questPos = CFrame.new(-10582, 331, -8757), monPos = CFrame.new(-10553, 521, -8176)},
    {lvl = 1825, mon = "Forest Pirate", quest = "DeepForestIsland", qlvl = 1, questPos = CFrame.new(-13232, 332, -7626), monPos = CFrame.new(-13489, 400, -7770)},
    {lvl = 1900, mon = "Jungle Pirate", quest = "DeepForestIsland2", qlvl = 1, questPos = CFrame.new(-12682, 390, -9902), monPos = CFrame.new(-12267, 459, -10277)},
    {lvl = 1975, mon = "Reborn Skeleton", quest = "HauntedQuest1", qlvl = 1, questPos = CFrame.new(-9480, 142, 5566), monPos = CFrame.new(-8761, 183, 6168)},
    {lvl = 2025, mon = "Demonic Soul", quest = "HauntedQuest2", qlvl = 1, questPos = CFrame.new(-9516, 178, 6078), monPos = CFrame.new(-9712, 204, 6193)},
    {lvl = 2075, mon = "Peanut Scout", quest = "NutsIslandQuest", qlvl = 1, questPos = CFrame.new(-2105, 37, -10195), monPos = CFrame.new(-2150, 122, -10358)},
    {lvl = 2125, mon = "Ice Cream Chef", quest = "IceCreamIslandQuest", qlvl = 1, questPos = CFrame.new(-819, 64, -10967), monPos = CFrame.new(-789, 209, -11009)},
    {lvl = 2200, mon = "Cookie Crafter", quest = "CakeQuest1", qlvl = 1, questPos = CFrame.new(-2022, 36, -12030), monPos = CFrame.new(-2321, 36, -12216)},
    {lvl = 2300, mon = "Cocoa Warrior", quest = "ChocQuest1", qlvl = 1, questPos = CFrame.new(231, 23, -12200), monPos = CFrame.new(167, 26, -12238)},
    {lvl = 2400, mon = "Candy Pirate", quest = "CandyQuest1", qlvl = 1, questPos = CFrame.new(-1149, 13, -14445), monPos = CFrame.new(-1437, 17, -14385)},
    {lvl = 2450, mon = "Isle Outlaw", quest = "TikiQuest1", qlvl = 1, questPos = CFrame.new(-16549, 55, -179), monPos = CFrame.new(-16162, 11, -96)},
}

-- ====== BOSSES (THIRD SEA) ======
local bosses = {
    {nome = "Stone", pos = CFrame.new(-1027, 92, 6578)},
    {nome = "Island Empress", pos = CFrame.new(5543, 668, 199)},
    {nome = "Kilo Admiral", pos = CFrame.new(2764, 432, -7144)},
    {nome = "Captain Elephant", pos = CFrame.new(-13376, 433, -8071)},
    {nome = "Beautiful Pirate", pos = CFrame.new(5283, 22, -110)},
    {nome = "Cake Queen", pos = CFrame.new(-678, 381, -11114)},
    {nome = "Longma", pos = CFrame.new(-10238, 389, -9549)},
    {nome = "Soul Reaper", pos = CFrame.new(-9524, 315, 6655)},
    {nome = "rip_indra True Form", pos = CFrame.new(-5415, 505, -2814)},
}

-- ====== ILHAS (TELEPORT) ======
local ilhas = {
    {nome = "Port Town", pos = CFrame.new(-290, 6, 5343)},
    {nome = "Haunted Castle", pos = CFrame.new(-9515, 164, 5786)},
    {nome = "Great Tree", pos = CFrame.new(2681, 1682, -7190)},
    {nome = "Floating Turtle", pos = CFrame.new(-13274, 531, -7579)},
    {nome = "Castle on the Sea", pos = CFrame.new(-5075, 314, -3150)},
    {nome = "Hydra Island", pos = CFrame.new(5753, 610, -282)},
    {nome = "Cake Island", pos = CFrame.new(-1884, 19, -11666)},
    {nome = "Tiki Outpost", pos = CFrame.new(-16542, 55, 1044)},
}

-- ====== FUNÇÕES AUXILIARES ======
local function getClosestNPC()
    local closest, minDist = nil, math.huge
    local folder = workspace:FindFirstChild("Enemies")
    if not folder then return nil end
    for _, npc in pairs(folder:GetChildren()) do
        if npc:IsA("Model") and not npc.Name:lower():find("brigade") and not npc.Name:lower():find("boat") then
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

local function atacarRapido(npc)
    pcall(function()
        if npc and npc.Parent and npc:FindFirstChild("HumanoidRootPart") then
            local alvo = CFrame.lookAt(rootPart.Position, npc.HumanoidRootPart.Position)
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

local function equiparArma(tipo)
    tipo = tipo or getgenv().DRONX.TipoArma or "Melee"
    local atk = character:FindFirstChildOfClass("Tool")
    if atk and atk.ToolTip == tipo then return end
    for _, t in pairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.ToolTip == tipo then
            pcall(function() humanoid:EquipTool(t) end)
            return
        end
    end
end

local function autoHaki()
    if not character:FindFirstChild("HasBuso") then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("Buso")
    end
end

local function attackNPC(npc)
    if not npc or not npc.Parent then return end
    local hum = npc:FindFirstChildOfClass("Humanoid")
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hum or hum.Health <= 0 or not hrp then return end

    rootPart.CFrame = hrp.CFrame * CFrame.new(0, 3, 0)
    pcall(function()
        hum.WalkSpeed = 0
        hum.JumpPower = 0
        hrp.CanCollide = false
        hrp.Size = Vector3.new(60, 60, 60)
        hrp.CFrame = rootPart.CFrame * CFrame.new(0, -3, 0)
    end)

    if getgenv().DRONX.AutoFarm then equiparArma("Melee") else equiparArma() end
    task.wait(0.3)
    autoHaki()

    for i = 1, 15 do
        atacarRapido(npc)
        task.wait(0.1)
    end
end

-- ====== BRING MOB (PUXAR NPC) ======
local function bringMob()
    pcall(function()
        local folder = workspace:FindFirstChild("Enemies")
        if not folder then return end
        for _, npc in pairs(folder:GetChildren()) do
            if npc:IsA("Model") then
                local hum = npc:FindFirstChildOfClass("Humanoid")
                local hrp = npc:FindFirstChild("HumanoidRootPart")
                if hum and hum.Health > 0 and hrp then
                    local dist = (rootPart.Position - hrp.Position).Magnitude
                    if dist <= 300 then
                        hum.WalkSpeed = 0
                        hum.JumpPower = 0
                        hrp.CanCollide = false
                        hrp.Size = Vector3.new(60, 60, 60)
                        hrp.CFrame = rootPart.CFrame * CFrame.new(math.random(-10,10), 0, math.random(-10,10))
                    end
                end
            end
        end
    end)
end

-- ====== AUTO CHEST ======
local function autoChest()
    pcall(function()
        for _, item in pairs(workspace:GetChildren()) do
            if item.Name:lower():find("chest") and item:FindFirstChild("Handle") then
                local cd = item.Handle:FindFirstChildOfClass("ClickDetector") or item:FindFirstChildOfClass("ClickDetector")
                if cd then
                    local dist = (rootPart.Position - item.Handle.Position).Magnitude
                    if dist < 500 then
                        local pos = rootPart.CFrame
                        rootPart.CFrame = CFrame.new(item.Handle.Position)
                        task.wait(0.2)
                        fireclickdetector(cd)
                        task.wait(0.3)
                    end
                end
            end
        end
    end)
end

-- ====== AUTO HAKI (Comprar) ======
local function buyHaki()
    pcall(function()
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyHaki", "Buso")
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyHaki", "Geppo")
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("BuyHaki", "Soru")
    end)
end

-- ====== AUTO QUEST ======
local function getQuestForLevel()
    local lvl = player.Data.Level.Value
    local melhor = nil
    for _, q in ipairs(quests) do
        if lvl >= q.lvl then melhor = q end
    end
    return melhor
end

local function autoQuest()
    local q = getQuestForLevel()
    if not q then return end
    
    local questGui = player.PlayerGui:FindFirstChild("Main")
    local titulo = ""
    if questGui and questGui:FindFirstChild("Quest") then
        local cont = questGui.Quest:FindFirstChild("Container")
        if cont and cont:FindFirstChild("QuestTitle") then
            titulo = cont.QuestTitle.Title.Text
        end
    end
    
    if not titulo:find(q.mon) then
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("AbandonQuest")
        if (q.questPos.Position - rootPart.Position).Magnitude > 5 then
            rootPart.CFrame = q.questPos
            task.wait(0.5)
        end
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("StartQuest", q.quest, q.qlvl)
    end
end

-- ====== ANTI-AFK ======
task.spawn(function()
    while task.wait(60) do
        if getgenv().DRONX.AntiAFK then
            pcall(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 0))
                task.wait(0.1)
                game:GetService("VirtualUser"):Button1Up(Vector2.new(0, 0))
            end)
        end
    end
end)

-- ====== LOOP PRINCIPAL ======
task.spawn(function()
    while task.wait(0.3) do
        if getgenv().DRONX.AntiAFK then
            pcall(function()
                game:GetService("Players").LocalPlayer.Idled:Connect(function()
                    game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    task.wait(1)
                    game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                end)
            end)
        end

        -- Auto Quest
        if getgenv().DRONX.AutoQuest then
            pcall(autoQuest)
        end

        -- Bring Mob
        if getgenv().DRONX.BringMob and (getgenv().DRONX.AutoFarm or getgenv().DRONX.AutoMaestria) then
            bringMob()
        end

        -- Auto Chest
        if getgenv().DRONX.AutoChest then
            autoChest()
        end

        -- Farm
        if getgenv().DRONX.AutoFarm or getgenv().DRONX.AutoMaestria then
            if character and character.Parent and humanoid.Health > 0 then
                -- Cura
                if getgenv().DRONX.AutoHeal then
                    if humanoid.Health / humanoid.MaxHealth < getgenv().DRONX.HealThreshold then
                        local p = player.Backpack:FindFirstChild("Potion") or character:FindFirstChild("Potion")
                        if p then pcall(function() p:Activate() end) end
                    end
                end

                -- Coleta
                if getgenv().DRONX.AutoCollect and not npcAtual then
                    for _, item in pairs(workspace:GetChildren()) do
                        if item:IsA("Model") or item:IsA("Tool") then
                            local h = item:FindFirstChild("Handle")
                            local cd = item:FindFirstChildOfClass("ClickDetector") or (h and h:FindFirstChildOfClass("ClickDetector"))
                            if h and cd and (rootPart.Position - h.Position).Magnitude < 30 then
                                fireclickdetector(cd)
                            end
                        end
                    end
                end

                -- Farm NPC
                local valido = npcAtual and npcAtual.Parent and npcAtual:FindFirstChildOfClass("Humanoid") and npcAtual.Humanoid.Health > 0
                if not valido then npcAtual = getClosestNPC() end
                if npcAtual then attackNPC(npcAtual) end
            end
        end

        -- Boss
        if getgenv().DRONX.AutoBoss and getgenv().DRONX.BossName ~= "" then
            for _, b in ipairs(bosses) do
                if b.nome:lower():find(getgenv().DRONX.BossName:lower()) then
                    rootPart.CFrame = b.pos
                    task.wait(0.5)
                    for _, npc in pairs(workspace.Enemies:GetChildren()) do
                        if npc.Name:lower():find(getgenv().DRONX.BossName:lower()) and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                            attackNPC(npc)
                        end
                    end
                end
            end
        end

        -- Anti-AFK (loop)
        if getgenv().DRONX.AntiAFK then
            pcall(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):Button1Down(Vector2.new(0, 0))
                task.wait(0.05)
                game:GetService("VirtualUser"):Button1Up(Vector2.new(0, 0))
            end)
        end
    end
end)

-- ====== ESP ======
task.spawn(function()
    while task.wait(2) do
        if getgenv().DRONX.ESP then
            local folder = workspace:FindFirstChild("Enemies")
            if folder then
                for _, npc in pairs(folder:GetChildren()) do
                    if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and npc:FindFirstChild("Humanoid") and npc.Humanoid.Health > 0 then
                        if not npc.HumanoidRootPart:FindFirstChild("ESP_Nome") then
                            local bill = Instance.new("BillboardGui", npc.HumanoidRootPart)
                            bill.Name = "ESP_Nome"
                            bill.Size = UDim2.new(0, 200, 0, 30)
                            bill.AlwaysOnTop = true
                            bill.StudsOffset = Vector3.new(0, 3, 0)
                            local lbl = Instance.new("TextLabel", bill)
                            lbl.Size = UDim2.new(1, 0, 1, 0)
                            lbl.BackgroundTransparency = 1
                            lbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                            lbl.TextStrokeTransparency = 0.5
                            lbl.TextScaled = true
                            lbl.Font = Enum.Font.GothamBold
                            lbl.Name = "Texto"
                        end
                        local dist = math.floor((rootPart.Position - npc.HumanoidRootPart.Position).Magnitude)
                        npc.HumanoidRootPart.ESP_Nome.Texto.Text = npc.Name .. " [" .. dist .. "m]"
                    end
                end
            end
        else
            local folder = workspace:FindFirstChild("Enemies")
            if folder then
                for _, npc in pairs(folder:GetChildren()) do
                    if npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart:FindFirstChild("ESP_Nome") then
                        npc.HumanoidRootPart.ESP_Nome:Destroy()
                    end
                end
            end
        end
    end
end)

-- ====== FPS BOOSTER ======
local function fpsBooster()
    pcall(function()
        local g = game
        local w = g.Workspace
        local l = g.Lighting
        local t = w.Terrain
        sethiddenproperty(l, "Technology", 2)
        sethiddenproperty(t, "Decoration", false)
        t.WaterWaveSize = 0
        t.WaterWaveSpeed = 0
        t.WaterReflectance = 0
        t.WaterTransparency = 0
        l.GlobalShadows = false
        l.FogEnd = 9e9
        l.Brightness = 0
        settings().Rendering.QualityLevel = "Level01"
        for _, v in pairs(g:GetDescendants()) do
            if v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1
            elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Lifetime = NumberRange.new(0)
            elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") then v.Enabled = false
            end
        end
    end)
end

-- ====== GUI ======
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "DRONX HUB",
    SubTitle = "v6.0",
    TabWidth = 150,
    Size = UDim2.fromOffset(520, 350),
    Theme = "Dark"
})

local Tabs = {
    Main = Window:AddTab({ Title = "Farm", Icon = "home" }),
    Boss = Window:AddTab({ Title = "Boss", Icon = "skull" }),
    Chest = Window:AddTab({ Title = "Chest", Icon = "box" }),
    Haki = Window:AddTab({ Title = "Haki", Icon = "zap" }),
    TP = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    ESP = Window:AddTab({ Title = "ESP", Icon = "eye" }),
    Config = Window:AddTab({ Title = "Config", Icon = "settings" }),
}

-- ABA FARM
Tabs.Main:AddToggle("AutoFarm", {
    Title = "Auto Farm (Soco)",
    Default = false,
    Callback = function(v)
        getgenv().DRONX.AutoFarm = v
        if v then getgenv().DRONX.AutoMaestria = false end
        
        -- 🔥 ESCONDE A GUI AUTOMATICAMENTE
        if v then
            task.wait(0.5)
            for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
                if gui:IsA("ScreenGui") and gui ~= screenGuiBtn then
                    if gui.Name:lower():find("fluent") or gui.Name:lower():find("dawid") then
                        gui.Enabled = false
                    end
                end
            end
            if toggleBtn then
                aberta = false
                toggleBtn.Text = "▶"
            end
            Fluent:Notify({Title = "DRONX", Content = "Farm ON - GUI escondida!", Duration = 3})
        end
    end
})

Tabs.Main:AddToggle("AutoMaestria", {
    Title = "Auto Maestria",
    Default = false,
    Callback = function(v)
        getgenv().DRONX.AutoMaestria = v
        if v then getgenv().DRONX.AutoFarm = false end
        
        if v then
            task.wait(0.5)
            for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
                if gui:IsA("ScreenGui") and gui ~= screenGuiBtn then
                    if gui.Name:lower():find("fluent") or gui.Name:lower():find("dawid") then
                        gui.Enabled = false
                    end
                end
            end
            if toggleBtn then
                aberta = false
                toggleBtn.Text = "▶"
            end
            Fluent:Notify({Title = "DRONX", Content = "Maestria ON - GUI escondida!", Duration = 3})
        end
    end
})

Tabs.Main:AddDropdown("TipoArma", {
    Title = "Tipo de Arma",
    Values = {"Sword", "Melee", "Blox Fruit", "Gun"},
    Default = "Sword",
    Callback = function(v) getgenv().DRONX.TipoArma = v end
})

Tabs.Main:AddToggle("AutoQuest", {
    Title = "Auto Quest (Missões)",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoQuest = v end
})

Tabs.Main:AddToggle("BringMob", {
    Title = "Bring Mob (Puxar NPC)",
    Default = false,
    Callback = function(v) getgenv().DRONX.BringMob = v end
})

Tabs.Main:AddToggle("AutoHeal", {
    Title = "Auto Cura",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoHeal = v end
})

Tabs.Main:AddToggle("AutoCollect", {
    Title = "Auto Coletar",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoCollect = v end
})

Tabs.Main:AddToggle("AntiAFK", {
    Title = "Anti-AFK",
    Default = true,
    Callback = function(v) getgenv().DRONX.AntiAFK = v end
})

Tabs.Main:AddButton({
    Title = "🔄 Server Hop (Trocar Servidor)",
    Callback = function()
        local TS = game:GetService("TeleportService")
        local servers = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"))
        if servers and #servers.data > 0 then
            for _, s in ipairs(servers.data) do
                if s.playing < s.maxPlayers - 1 then
                    TS:TeleportToPlaceInstance(game.PlaceId, s.id, player)
                    break
                end
            end
        end
    end
})

-- ABA BOSS
Tabs.Boss:AddDropdown("BossDrop", {
    Title = "Escolher Boss",
    Values = (function()
        local t = {}
        for _, b in ipairs(bosses) do table.insert(t, b.nome) end
        return t
    end)(),
    Default = "Stone",
    Callback = function(v)
        getgenv().DRONX.BossName = v
    end
})

Tabs.Boss:AddToggle("AutoBoss", {
    Title = "Auto Boss",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoBoss = v end
})

-- ABA CHEST
Tabs.Chest:AddToggle("AutoChest", {
    Title = "Auto Abrir Baús",
    Default = false,
    Callback = function(v) getgenv().DRONX.AutoChest = v end
})

-- ABA HAKI
Tabs.Haki:AddToggle("AutoHaki", {
    Title = "Auto Comprar Haki",
    Default = false,
    Callback = function(v)
        getgenv().DRONX.AutoHaki = v
        if v then buyHaki() end
    end
})

-- ABA TELEPORT
for _, ilha in ipairs(ilhas) do
    Tabs.TP:AddButton({
        Title = ilha.nome,
        Callback = function()
            rootPart.CFrame = ilha.pos
        end
    })
end

-- ABA ESP
Tabs.ESP:AddToggle("ESP", {
    Title = "ESP NPC (Ver através de parede)",
    Default = false,
    Callback = function(v) getgenv().DRONX.ESP = v end
})

-- ABA CONFIG
Tabs.Config:AddToggle("FPS", {
    Title = "FPS Booster",
    Default = false,
    Callback = function(v)
        getgenv().DRONX.FPS = v
        if v then fpsBooster() end
    end
})

Tabs.Config:AddSlider("SliderY", {
    Title = "Altura do Farm",
    Default = 3, Min = 0, Max = 30, Rounding = 1,
    Callback = function(v) getgenv().DRONX.posY = v end
})

-- ====== BOTÃO FLUTUANTE ======
local screenGuiBtn = Instance.new("ScreenGui")
screenGuiBtn.Name = "DRONX_Botao"
screenGuiBtn.ResetOnSpawn = false
screenGuiBtn.Parent = game:GetService("CoreGui") or player:WaitForChild("PlayerGui")

local function getFluentGui()
    for _, gui in pairs(game:GetService("CoreGui"):GetChildren()) do
        if gui:IsA("ScreenGui") and gui ~= screenGuiBtn then
            if gui.Name:lower():find("fluent") or gui.Name:lower():find("dawid") then
                return gui
            end
        end
    end
    return nil
end

toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
toggleBtn.Position = UDim2.new(0, 20, 0.5, -25)
toggleBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
toggleBtn.Text = "◀"
toggleBtn.TextColor3 = Color3.fromRGB(255, 215, 0)
toggleBtn.TextSize = 24
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.BorderSizePixel = 0
toggleBtn.Draggable = true
toggleBtn.Parent = screenGuiBtn

local cc = Instance.new("UICorner")
cc.CornerRadius = UDim.new(1, 0)
cc.Parent = toggleBtn

local ss = Instance.new("UIStroke")
ss.Color = Color3.fromRGB(255, 215, 0)
ss.Thickness = 2
ss.Parent = toggleBtn

toggleBtn.MouseButton1Click:Connect(function()
    aberta = not aberta
    local gui = getFluentGui()
    if gui then
        gui.Enabled = aberta
    end
    toggleBtn.Text = aberta and "◀" or "▶"
end)

print("[DRONX] v6.0 carregado com sucesso!")
print("[DRONX] Abas: Farm | Boss | Chest | Haki | Teleport | ESP | Config")

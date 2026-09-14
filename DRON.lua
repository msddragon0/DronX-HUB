-- ============================================================
-- DRONX v7.0 – AUTO FARM CORRIGIDO
-- substitui o arquivo inteiro
-- ============================================================

getgenv().DRONX = {
    Enabled       = true,
    AutoFarm      = false,
    AutoMaestria  = false,
    AutoHeal      = false,
    AntiAFK       = true,
    TipoArma      = "Superhuman",
    MaxDistance   = 2000,
    HealThreshold = 0.5,
    Kills         = 0,
    TweenSpeed    = 300,
}

local Players      = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser  = game:GetService("VirtualUser")
local RunService   = game:GetService("RunService")

local player = Players.LocalPlayer
local char, root, hum

local function fetchChar()
    char = player.Character or player.CharacterAdded:Wait()
    root = char:WaitForChild("HumanoidRootPart")
    hum  = char:WaitForChild("Humanoid")
end
fetchChar()
player.CharacterAdded:Connect(function()
    task.wait(1)
    fetchChar()
end)

-- ── NPC MAIS PRÓXIMO ─────────────────────────────────────────
local function getClosestNPC()
    local maxDist = getgenv().DRONX.MaxDistance
    local closest, closestDist = nil, maxDist
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0 then
            local model = obj.Parent
            if model == char then continue end
            if Players:GetPlayerFromCharacter(model) then continue end
            -- ignora quest givers e NPCs não combatíveis
            if model.Name:lower():find("quest") then continue end
            local hrp = model:FindFirstChild("HumanoidRootPart")
            if hrp then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = model
                end
            end
        end
    end
    return closest
end

-- ── TELEPORTE INSTANTÂNEO (sem tween — combat precisa de proximidade) ──
local function snapToNPC(npc)
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    -- fica a 5 studs na frente do NPC
    root.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
end

-- ── ATAQUE — usa o RemoteEvent da tool equipada ──────────────
local function atacar(npc)
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then
        -- tenta equipar a tool pelo nome
        for _, t in ipairs(player.Backpack:GetChildren()) do
            if t:IsA("Tool") and t.Name == getgenv().DRONX.TipoArma then
                hum:EquipTool(t)
                task.wait(0.1)
                tool = char:FindFirstChildOfClass("Tool")
                break
            end
        end
    end
    if not tool then return end

    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- vira pro NPC
    root.CFrame = CFrame.new(root.Position, hrp.Position)

    -- dispara o RemoteEvent principal da tool (ataque)
    local remEv = tool:FindFirstChild("RemoteEvent")
    if remEv then
        -- Blox Fruits fighting styles: FireServer com a posição do alvo
        pcall(function()
            remEv:FireServer(hrp.Position)
        end)
    end

    -- fallback: tenta todos os RemoteEvents da tool
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name ~= "EquipEvent" then
            pcall(function()
                v:FireServer(hrp.Position)
            end)
        end
    end
end

-- ── TRAVAR NPC (impede de fugir) ─────────────────────────────
local function travarNPC(npc)
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    local nhum = npc:FindFirstChildOfClass("Humanoid")
    if not (hrp and nhum) then return end
    pcall(function()
        nhum.WalkSpeed  = 0
        nhum.JumpPower  = 0
        hrp.CanCollide  = false
    end)
end

-- ── SEGURANÇA ────────────────────────────────────────────────
local function checkGround()
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char}
    local result = workspace:Raycast(root.Position, Vector3.new(0, -20, 0), params)
    if not result then
        root.CFrame = root.CFrame + Vector3.new(0, 10, 0)
    end
end

-- ── POÇÃO ────────────────────────────────────────────────────
local function usarPocao()
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name:lower():find("potion") then
            hum:EquipTool(t)
            task.wait(0.1)
            local ev = t:FindFirstChild("RemoteEvent")
            if ev then pcall(function() ev:FireServer() end) end
            return
        end
    end
end

-- ── ENGINE ───────────────────────────────────────────────────
local currentNPC = nil
local attackConn = nil

task.spawn(function()
    while task.wait(0.1) do
        if not getgenv().DRONX.Enabled then continue end
        if not (char and root and hum) then continue end
        if hum.Health <= 0 then continue end

        checkGround()

        if getgenv().DRONX.AutoFarm or getgenv().DRONX.AutoMaestria then
            -- pega novo NPC se o atual morreu ou não existe
            if not currentNPC then
                currentNPC = getClosestNPC()
            else
                local nhum = currentNPC:FindFirstChildOfClass("Humanoid")
                if not nhum or nhum.Health <= 0 then
                    getgenv().DRONX.Kills += 1
                    currentNPC = nil
                    continue
                end
            end

            if currentNPC then
                local nhrp = currentNPC:FindFirstChild("HumanoidRootPart")
                if nhrp then
                    local dist = (nhrp.Position - root.Position).Magnitude
                    -- se longe, teleporta
                    if dist > 8 then
                        snapToNPC(currentNPC)
                    end
                    travarNPC(currentNPC)
                    atacar(currentNPC)
                end
            end
        end

        -- auto heal
        if getgenv().DRONX.AutoHeal then
            if hum.Health / hum.MaxHealth < getgenv().DRONX.HealThreshold then
                usarPocao()
            end
        end

        -- anti afk
        if getgenv().DRONX.AntiAFK then
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:Button1Down(Vector2.new(0,0))
                task.wait(0.05)
                VirtualUser:Button1Up(Vector2.new(0,0))
            end)
        end
    end
end)

-- ── GUI ──────────────────────────────────────────────────────
local Fluent           = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager      = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title       = "DRONX v7.0",
    SubTitle    = "nullsec philippines",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = false,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

local Tabs   = {
    Main     = Window:AddTab({ Title = "Main",     Icon = "sword"    }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}
local Options = Fluent.Options

do
    Tabs.Main:AddParagraph({
        Title   = "DRONX Engine",
        Content = "v30 Sea3 detectada. Fighting style: Superhuman.",
    })

    Tabs.Main:AddToggle("AutoFarm", {
        Title       = "Auto Farm",
        Description = "Teleporta e ataca NPCs em loop.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoFarm = Options.AutoFarm.Value
        if not Options.AutoFarm.Value then currentNPC = nil end
    end)

    Tabs.Main:AddToggle("AutoMaestria", {
        Title       = "Auto Maestria",
        Description = "Farm de XP de maestria.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoMaestria = Options.AutoMaestria.Value
        if not Options.AutoMaestria.Value then currentNPC = nil end
    end)

    Tabs.Main:AddToggle("AutoHeal", {
        Title       = "Auto Heal",
        Description = "Usa poção quando HP cai abaixo do limiar.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoHeal = Options.AutoHeal.Value
    end)

    Tabs.Main:AddSlider("HealThreshold", {
        Title    = "Limiar de Cura (%)",
        Default  = 50,
        Min      = 10,
        Max      = 90,
        Rounding = 0,
        Callback = function(v)
            getgenv().DRONX.HealThreshold = v / 100
        end,
    })

    Tabs.Main:AddToggle("AntiAFK", {
        Title   = "Anti-AFK",
        Default = true,
    }):OnChanged(function()
        getgenv().DRONX.AntiAFK = Options.AntiAFK.Value
    end)

    Tabs.Main:AddSlider("MaxDistance", {
        Title    = "Distância Máxima (studs)",
        Default  = 2000,
        Min      = 100,
        Max      = 5000,
        Rounding = 0,
        Callback = function(v)
            getgenv().DRONX.MaxDistance = v
        end,
    })

    Tabs.Main:AddInput("TipoArma", {
        Title       = "Nome da Tool/Arma",
        Default     = "Superhuman",
        Placeholder = "ex: Superhuman, Saber, Dark Blade",
        Finished    = true,
        Callback    = function(v)
            getgenv().DRONX.TipoArma = v
        end,
    })

    Tabs.Main:AddButton({
        Title       = "TP Manual para NPC mais Próximo",
        Description = "Teleporta uma vez para testar.",
        Callback    = function()
            local npc = getClosestNPC()
            if npc then
                snapToNPC(npc)
                Fluent:Notify({ Title = "DRONX", Content = "TP → " .. npc.Name, Duration = 2 })
            else
                Fluent:Notify({ Title = "DRONX", Content = "Nenhum NPC no raio.", Duration = 3 })
            end
        end,
    })

    local kp = Tabs.Main:AddParagraph({ Title = "Kills nesta sessão", Content = "0" })
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                kp:Set({ Title = "Kills nesta sessão", Content = tostring(getgenv().DRONX.Kills) })
            end)
        end
    end)
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("DRONX")
SaveManager:SetFolder("DRONX/BloxFruits")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)
Fluent:Notify({ Title = "DRONX v7.0", Content = "Pronto. Liga o Auto Farm.", Duration = 4 })
SaveManager:LoadAutoloadConfig()

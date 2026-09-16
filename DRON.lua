-- ============================================================
-- PATCH 1: substitui getgenv().DRONX
-- remove TweenSpeed (não usado), adiciona flags novas
-- ============================================================
getgenv().DRONX = {
    Enabled       = true,
    AutoFarm      = false,
    AutoMaestria  = false,
    AutoHeal      = false,
    AutoQuest     = false,
    AutoChest     = false,
    AntiAFK       = true,
    TipoArma      = "Auto",
    MaxDistance   = 2000,
    HealThreshold = 0.5,
    Kills         = 0,
}

-- ============================================================
-- PATCH 2: substitui getClosestNPC — filtro melhorado
-- ============================================================
local NPC_BLACKLIST = {
    quest = true, banker = true, civilian = true,
    shop = true, dealer = true, master = true,
    teacher = true, courier = true,
}

local function getClosestNPC()
    local maxDist = getgenv().DRONX.MaxDistance
    local closest, closestDist = nil, maxDist
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") and obj.Health > 0 then
            local model = obj.Parent
            if model == char then continue end
            if Players:GetPlayerFromCharacter(model) then continue end
            local nameLower = model.Name:lower()
            local blocked = false
            for word in pairs(NPC_BLACKLIST) do
                if nameLower:find(word) then blocked = true break end
            end
            if blocked then continue end
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

-- ============================================================
-- PATCH 3: substitui atacar — modo Auto detecta tool equipada
-- ============================================================
local function getTool()
    if getgenv().DRONX.TipoArma == "Auto" then
        local eq = char:FindFirstChildOfClass("Tool")
        if eq then return eq end
        local first = player.Backpack:FindFirstChildOfClass("Tool")
        if first then
            hum:EquipTool(first)
            task.wait(0.15)
            return char:FindFirstChildOfClass("Tool")
        end
        return nil
    end
    local eq = char:FindFirstChildOfClass("Tool")
    if eq and eq.Name == getgenv().DRONX.TipoArma then return eq end
    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name == getgenv().DRONX.TipoArma then
            hum:EquipTool(t)
            task.wait(0.15)
            return char:FindFirstChildOfClass("Tool")
        end
    end
    return char:FindFirstChildOfClass("Tool")
end

local function atacar(npc)
    local tool = getTool()
    if not tool then return end
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    root.CFrame = CFrame.new(root.Position, hrp.Position)
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name ~= "EquipEvent" then
            pcall(function() v:FireServer(hrp.Position) end)
        end
    end
end

-- ============================================================
-- PATCH 4: Auto Quest — cola no engine após o bloco AutoFarm
-- ============================================================
local function autoQuest()
    if not getgenv().DRONX.AutoQuest then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") then
            local model = obj.Parent
            local nameLower = model.Name:lower()
            if nameLower:find("quest") then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    -- teleporta até o quest giver
                    root.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                    task.wait(0.3)
                    -- tenta disparar remote de quest
                    for _, v in ipairs(model:GetDescendants()) do
                        if v:IsA("RemoteEvent") then
                            pcall(function() v:FireServer() end)
                        end
                    end
                    return
                end
            end
        end
    end
end

-- ============================================================
-- PATCH 5: Auto Chest — cola no engine após autoQuest
-- ============================================================
local function autoChest()
    if not getgenv().DRONX.AutoChest then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        local nameLower = obj.Name:lower()
        if nameLower:find("chest") and obj:IsA("Model") then
            local hrp = obj:FindFirstChild("HumanoidRootPart")
                or obj:FindFirstChildOfClass("BasePart")
            if hrp then
                local dist = (hrp.Position - root.Position).Magnitude
                if dist < getgenv().DRONX.MaxDistance then
                    root.CFrame = CFrame.new(hrp.Position)
                    task.wait(0.2)
                    for _, v in ipairs(obj:GetDescendants()) do
                        if v:IsA("RemoteEvent") then
                            pcall(function() v:FireServer() end)
                        end
                    end
                end
            end
        end
    end
end

-- ============================================================
-- PATCH 6: engine atualizado — substitui o task.spawn completo
-- ============================================================
local currentNPC = nil

task.spawn(function()
    while task.wait(0.1) do
        if not getgenv().DRONX.Enabled then continue end
        if not (char and root and hum) then continue end
        if hum.Health <= 0 then continue end

        checkGround()

        if getgenv().DRONX.AutoFarm or getgenv().DRONX.AutoMaestria then
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
                    if (nhrp.Position - root.Position).Magnitude > 8 then
                        snapToNPC(currentNPC)
                    end
                    travarNPC(currentNPC)
                    atacar(currentNPC)
                end
            end
        end

        autoQuest()
        autoChest()

        if getgenv().DRONX.AutoHeal then
            if hum.Health / hum.MaxHealth < getgenv().DRONX.HealThreshold then
                usarPocao()
            end
        end

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

-- ============================================================
-- PATCH 7: GUI — substitui o bloco do "do...end" inteiro
-- ============================================================
do
    Tabs.Main:AddParagraph({
        Title   = "DRONX v7.1",
        Content = "Place v" .. tostring(game.PlaceVersion) .. " | Sea3",
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
        Default  = 50, Min = 10, Max = 90, Rounding = 0,
        Callback = function(v)
            getgenv().DRONX.HealThreshold = v / 100
        end,
    })

    Tabs.Main:AddToggle("AutoQuest", {
        Title       = "Auto Quest",
        Description = "Vai até o quest giver e aceita/entrega.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoQuest = Options.AutoQuest.Value
    end)

    Tabs.Main:AddToggle("AutoChest", {
        Title       = "Auto Chest",
        Description = "Coleta baús no mapa.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoChest = Options.AutoChest.Value
    end)

    Tabs.Main:AddToggle("AntiAFK", {
        Title   = "Anti-AFK",
        Default = true,
    }):OnChanged(function()
        getgenv().DRONX.AntiAFK = Options.AntiAFK.Value
    end)

    Tabs.Main:AddSlider("MaxDistance", {
        Title    = "Distância Máxima (studs)",
        Default  = 2000, Min = 100, Max = 5000, Rounding = 0,
        Callback = function(v)
            getgenv().DRONX.MaxDistance = v
        end,
    })

    Tabs.Main:AddDropdown("TipoArma", {
        Title  = "Fighting Style / Arma",
        Values = {
            "Auto",
            "Superhuman", "Electric", "Electric Claw",
            "Sharkman Karate", "Death Step", "Rubber",
            "Dark Step", "Water Kung Fu", "Dragon Talon",
            "Godhuman", "Sanguine Art", "Thundergod",
        },
        Multi   = false,
        Default = 1,
    }):OnChanged(function(v)
        getgenv().DRONX.TipoArma = v
    end)

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

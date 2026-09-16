local Players = game:GetService("Players")

local NPC_BLACKLIST = {
    banker = true, civilian = true,
    shop = true, dealer = true,
    master = true, teacher = true, courier = true,
}

local function getClosestNPC()
    local maxDist = getgenv().DRONX.MaxDistance
    local closest, closestDist = nil, maxDist
    local char = getgenv().char
    local root = getgenv().root

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

local function autoQuest()
    if not getgenv().DRONX.AutoQuest then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Humanoid") then
            local model = obj.Parent
            if model.Name:lower():find("quest") then
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if hrp then
                    getgenv().root.CFrame = hrp.CFrame * CFrame.new(0, 0, -5)
                    task.wait(0.3)
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

local function autoChest()
    if not getgenv().DRONX.AutoChest then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("chest") and obj:IsA("Model") then
            local part = obj:FindFirstChildOfClass("BasePart")
            if part then
                local dist = (part.Position - getgenv().root.Position).Magnitude
                if dist < getgenv().DRONX.MaxDistance then
                    getgenv().root.CFrame = CFrame.new(part.Position)
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

local currentNPC = nil

task.spawn(function()
    while task.wait(0.1) do
        if not getgenv().DRONX.Enabled then continue end
        local char = getgenv().char
        local root = getgenv().root
        local hum  = getgenv().hum
        if not (char and root and hum) then continue end
        if hum.Health <= 0 then continue end

        getgenv().checkGround()

        -- farm / maestria
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
                        getgenv().snapToNPC(currentNPC)
                    end
                    getgenv().travarNPC(currentNPC)
                    getgenv().atacar(currentNPC)
                end
            end
        end

        autoQuest()
        autoChest()

        -- heal
        if getgenv().DRONX.AutoHeal then
            if hum.Health / hum.MaxHealth < getgenv().DRONX.HealThreshold then
                getgenv().usarPocao()
            end
        end

        -- anti afk
        if getgenv().DRONX.AntiAFK then
            getgenv().antiAfk()
        end
    end
end)

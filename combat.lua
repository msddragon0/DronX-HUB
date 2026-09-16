local Players = game:GetService("Players")

getgenv().getTool = function()
    local char   = getgenv().char
    local hum    = getgenv().hum
    local player = getgenv().player
    local nome   = getgenv().DRONX.TipoArma

    if nome == "Auto" then
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
    if eq and eq.Name == nome then return eq end

    for _, t in ipairs(player.Backpack:GetChildren()) do
        if t:IsA("Tool") and t.Name == nome then
            hum:EquipTool(t)
            task.wait(0.15)
            return char:FindFirstChildOfClass("Tool")
        end
    end

    return char:FindFirstChildOfClass("Tool")
end

getgenv().atacar = function(npc)
    local tool = getgenv().getTool()
    if not tool then return end
    local hrp = npc:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    getgenv().root.CFrame = CFrame.new(getgenv().root.Position, hrp.Position)
    for _, v in ipairs(tool:GetDescendants()) do
        if v:IsA("RemoteEvent") and v.Name ~= "EquipEvent" then
            pcall(function() v:FireServer(hrp.Position) end)
        end
    end
end

getgenv().travarNPC = function(npc)
    local hrp  = npc:FindFirstChild("HumanoidRootPart")
    local nhum = npc:FindFirstChildOfClass("Humanoid")
    if not (hrp and nhum) then return end
    pcall(function()
        nhum.WalkSpeed  = 0
        nhum.JumpPower  = 0
        hrp.CanCollide  = false
    end)
end

getgenv().usarPocao = function()
    local player = getgenv().player
    local hum    = getgenv().hum
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

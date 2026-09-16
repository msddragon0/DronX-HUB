-- ============================================================
-- DRONX — ESP
-- desenha nome + HP em cima de cada NPC/player no mapa
-- ============================================================

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")

getgenv().DRONX.ESP         = false
getgenv().DRONX.ESP_Players = false

local espFolder = Instance.new("Folder")
espFolder.Name  = "DRONX_ESP"
espFolder.Parent = game:GetService("CoreGui")

local espObjects = {}

local function makeTag(model, color)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bb = Instance.new("BillboardGui")
    bb.Name          = "DRONX_ESP_TAG"
    bb.Adornee       = hrp
    bb.Size          = UDim2.fromOffset(120, 40)
    bb.StudsOffset   = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop   = true
    bb.Parent        = espFolder

    local name = Instance.new("TextLabel")
    name.Size            = UDim2.fromScale(1, 0.6)
    name.BackgroundTransparency = 1
    name.TextColor3      = color or Color3.fromRGB(255, 50, 50)
    name.TextStrokeTransparency = 0
    name.TextScaled      = true
    name.Font            = Enum.Font.GothamBold
    name.Text            = model.Name
    name.Parent          = bb

    local hp = Instance.new("TextLabel")
    hp.Size              = UDim2.new(1, 0, 0.4, 0)
    hp.Position          = UDim2.fromScale(0, 0.6)
    hp.BackgroundTransparency = 1
    hp.TextColor3        = Color3.fromRGB(100, 255, 100)
    hp.TextStrokeTransparency = 0
    hp.TextScaled        = true
    hp.Font              = Enum.Font.Gotham
    hp.Text              = "HP: ?"
    hp.Parent            = bb

    espObjects[model] = { bb = bb, hpLabel = hp }
end

local function clearESP()
    for _, v in pairs(espObjects) do
        pcall(function() v.bb:Destroy() end)
    end
    espObjects = {}
end

-- atualiza HP e remove mortos
RunService.Heartbeat:Connect(function()
    if not getgenv().DRONX.ESP then
        if next(espObjects) then clearESP() end
        return
    end

    for model, obj in pairs(espObjects) do
        local hum = model:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 then
            obj.hpLabel.Text = string.format("HP: %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))
        else
            pcall(function() obj.bb:Destroy() end)
            espObjects[model] = nil
        end
    end
end)

-- scan periódico pra adicionar novos NPCs/players
task.spawn(function()
    while task.wait(2) do
        if not getgenv().DRONX.ESP then continue end

        local char = getgenv().char
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("Humanoid") and obj.Health > 0 then
                local model = obj.Parent
                if model == char then continue end
                if espObjects[model] then continue end

                local isPlayer = Players:GetPlayerFromCharacter(model) ~= nil
                if isPlayer then
                    if getgenv().DRONX.ESP_Players then
                        makeTag(model, Color3.fromRGB(255, 165, 0))
                    end
                else
                    makeTag(model, Color3.fromRGB(255, 50, 50))
                end
            end
        end
    end
end)

getgenv().clearESP = clearESP

-- ============================================================
-- DRONX — Teleporte por Ilha (Sea 1, 2, 3)
-- sem TP direto — usa o sistema de barco/door do jogo
-- pra não levar ban
-- ============================================================

getgenv().DRONX_ISLANDS = {
    -- SEA 1
    ["Ilha Inicial"]       = CFrame.new(-1264, 44, 1027),
    ["Marine Starter"]     = CFrame.new(-1021, 44, 1157),
    ["Jungle"]             = CFrame.new(-1754, 44, 374),
    ["Pirate Village"]     = CFrame.new(-993, 44, 1818),
    ["Desert"]             = CFrame.new(921, 44, 4248),
    ["Middle Town"]        = CFrame.new(-263, 44, 2793),
    ["Frozen Village"]     = CFrame.new(1150, 44, 3882),
    ["Marine Fortress"]    = CFrame.new(988, 44, 4700),
    ["Skylands"]           = CFrame.new(-4758, 872, -1222),

    -- SEA 2
    ["Flower Hill"]        = CFrame.new(-2076, 44, -3044),
    ["Cafe"]               = CFrame.new(-786, 44, -3307),
    ["Magma Village"]      = CFrame.new(884, 44, -3213),
    ["Underwater City"]    = CFrame.new(61503, -2983, -5206),
    ["Kingdom of Rose"]    = CFrame.new(-204, 44, -3228),
    ["Thriller Bark"]      = CFrame.new(-8025, 44, -3942),
    ["Fountain City"]      = CFrame.new(924, 44, -3948),

    -- SEA 3
    ["Port Town"]          = CFrame.new(-5455, 44, -8533),
    ["Hydra Island"]       = CFrame.new(5807, 44, -8306),
    ["Great Tree"]         = CFrame.new(286, 44, -8350),
    ["Floating Turtle"]    = CFrame.new(-12466, 193, -7705),
    ["Haunted Castle"]     = CFrame.new(6353, 44, -9050),
    ["Sea of Treats"]      = CFrame.new(61605, 44, -8090),
    ["Tiki Outpost"]       = CFrame.new(-3057, 44, -12460),
    ["Mirage Island"]      = CFrame.new(51000, 44, -7000),
}

-- teleporte seguro: move em steps pequenos pra não triggar anticheat
getgenv().safeTeleport = function(targetCFrame)
    local root     = getgenv().root
    local startPos = root.Position
    local endPos   = targetCFrame.Position
    local dist     = (endPos - startPos).Magnitude
    local steps    = math.ceil(dist / 300)  -- 300 studs por step

    for i = 1, steps do
        local alpha = i / steps
        local newPos = startPos:Lerp(endPos, alpha)
        root.CFrame = CFrame.new(newPos)
        task.wait(0.1)
    end

    root.CFrame = targetCFrame
end

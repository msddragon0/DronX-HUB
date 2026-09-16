local Fluent           = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager      = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title       = "DRONX v7.1",
    SubTitle    = "nullsec philippines",
    TabWidth    = 160,
    Size        = UDim2.fromOffset(580, 460),
    Acrylic     = false,
    Theme       = "Dark",
    MinimizeKey = Enum.KeyCode.RightControl,
})

local Tabs = {
    Main     = Window:AddTab({ Title = "Main",     Icon = "sword"    }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" }),
}
local Options = Fluent.Options

do
    Tabs.Main:AddParagraph({
        Title   = "DRONX v7.1",
        Content = "Place v" .. tostring(game.PlaceVersion),
    })

    Tabs.Main:AddToggle("AutoFarm", {
        Title       = "Auto Farm",
        Description = "Teleporta e ataca NPCs em loop.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoFarm = Options.AutoFarm.Value
    end)

    Tabs.Main:AddToggle("AutoMaestria", {
        Title       = "Auto Maestria",
        Description = "Farm de XP de maestria.",
        Default     = false,
    }):OnChanged(function()
        getgenv().DRONX.AutoMaestria = Options.AutoMaestria.Value
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
        Description = "Aceita e entrega quests automaticamente.",
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
            local npc = getClosestNPC and getClosestNPC() or nil
            if npc then
                getgenv().snapToNPC(npc)
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
Fluent:Notify({ Title = "DRONX v7.1", Content = "Pronto. Boa farm.", Duration = 4 })
SaveManager:LoadAutoloadConfig()

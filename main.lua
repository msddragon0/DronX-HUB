local function load(file)
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/msddragon0/DronX-HUB/refs/heads/main/main.lua" .. file
    ))()
end

load("config.lua")
load("utils.lua")
load("movement.lua")
load("combat.lua")
load("farm.lua")
load("quest.lua")
load("chest.lua")
load("gui.lua")

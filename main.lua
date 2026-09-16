local function load(file)
    return loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/SEU_USER/DRONX/main/" .. file
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

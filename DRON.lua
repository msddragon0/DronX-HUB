local BASE = "https://raw.githubusercontent.com/msddragon0/DronX-HUB/refs/heads/main/DRON.lua"

local function load(file)
    loadstring(game:HttpGet(BASE .. file))()
end

load("config.lua")
load("utils.lua")
load("movement.lua")
load("combat.lua")
load("farm.lua")
load("teleport.lua")
load("esp.lua")
load("gui.lua")

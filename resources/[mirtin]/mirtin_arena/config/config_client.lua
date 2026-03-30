------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

src = {}
Tunnel.bindInterface("mirtin_arena",src)
vSERVER = Tunnel.getInterface("mirtin_arena")
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config = {}
config.rangeDistance = 100 -- Distancia se o player se afastar muito voltar para a arena

config.locArenas = { -- Localizações das arenas
    vec3(-282.44,-1922.77,29.95)
}

config.keys = {
    scoreboard = 137, -- CAPS
    spawn = 38, -- SPAWNAR
}

config.drawMarker = function(coords) -- DRAWMARKER DO BLIP DA ARENA
    DrawMarker(0,coords,0,0,0,0,0,130.0, 0.5,0.5,0.5, 12,198,254,180 ,1,0,0,1)
end

config.drawTxt = function()
    drawTxt("VOCÊ ESTÁ MORTO PRESSIONE ~b~E~w~ PARA SPAWNAR",4,0.5,0.93,0.50,255,255,255,255)
end

--[[ -- COLOQUE ISSO NAS FUNCOES DE CLIENTS
    local in_arena = false

    RegisterNetEvent("mirtin_survival:updateArena")
    AddEventHandler("mirtin_survival:updateArena", function(boolean)
        in_arena = boolean
    end)
]] 
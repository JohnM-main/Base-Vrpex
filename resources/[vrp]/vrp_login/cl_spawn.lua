local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
spawnselector = Tunnel.getInterface("spawnselector")
local SpawnLocation = {}

RegisterNetEvent('vrp:ToogleLoginMenu')
AddEventHandler('vrp:ToogleLoginMenu', function()
    SetTimecycleModifier('hud_def_blur')
    SendNUIMessage({action = true})
    SetNuiFocus(true, true)
end)

local SPAWNS = {
    ["airport"] = vector3(-1034.61,-2732.09,13.76),
    ["hospital"] = vector3(-439.61,-363.33,33.34),
    ["mirror"] = vector3(1036.73,-756.16,57.77),
    ["sandy"] = vector3(340.79,2616.27,44.65),
    ["paleto"] = vector3(-767.52,5583.55,33.61)
}

RegisterNUICallback('spawn', function(data, cb)
    local SpawnName = data.location

    if SpawnName == "last" then
        local coords = spawnselector.ultimaposicao()
        SPAWNS["last"] = vector3(coords.x,coords.y,coords.z)
    end
    SpawnLocation = SPAWNS[SpawnName]
    vRP.teleport(SpawnLocation.x,SpawnLocation.y,SpawnLocation.z)

    DoScreenFadeIn(500)
    SetTimecycleModifier('default')
    SetNuiFocus(false, false)
    TriggerEvent("ToogleBackCharacter")
end)


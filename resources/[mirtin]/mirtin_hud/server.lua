----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONEXÃO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_hud",src)
vCLIENT = Tunnel.getInterface("vrp_hud")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE CLIMA
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local hora = 12
local minuto = 0
local varTime = 10*1000 -- 10 segundos Pra atualizar o tempo

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(varTime)

        if parseInt(hora) >= 22 or parseInt(hora) < 7 then
            minuto = minuto + 2--[[ 10 ]]
        else
            minuto = minuto + 2
        end

        if parseInt(minuto) >= 60 then
            hora = hora + 1
            minuto = 0

            if parseInt(hora) >= 24 then
                hora = 0
            end
        end
        
        vCLIENT.updateClima(-1, hora, parseInt(minuto)) 
    end
end)

RegisterCommand('time', function(source,args)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, "admin.permissao") then
            if args[1] and args[2] and parseInt(args[1]) >= 0 and parseInt(args[1]) <= 23 and parseInt(args[2]) >= 0 and parseInt(args[2]) <= 60 then
                hora = parseInt(args[1])
                minuto = parseInt(args[2])
                vCLIENT.updateClima(-1, hora, parseInt(minuto)) 
            else
                TriggerClientEvent("Notify",source,"negado","Digite o tempo corretamente, entre 00 00 ate 23 00", 5)
            end
        end
    end
end)

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
    vCLIENT.updateClima(source, hora, parseInt(minuto)) 
end)
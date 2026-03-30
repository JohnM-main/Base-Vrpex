
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")

RegisterServerEvent('chat:init')
RegisterServerEvent('chat:addTemplate')
RegisterServerEvent('chat:addMessage')
RegisterServerEvent('chat:clear')
RegisterServerEvent('__cfx_internal:commandFallback')

AddEventHandler('__cfx_internal:commandFallback', function(command)
    local name = GetPlayerName(source)
    TriggerEvent('chatMessage', source, name, '/' .. command)
    CancelEvent()
end)

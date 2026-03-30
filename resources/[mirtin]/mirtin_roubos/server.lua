local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("mirtin_roubos",src)
Proxy.addInterface("mirtin_roubos",src)
vPOLICE = Tunnel.getInterface("vrp_policia")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local robberyList = {}
local block_roubar = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.giveItem(item,amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        vRP.giveInventoryItem(user_id, item, amount, true)
    end
end

function src.checkRobbery(id)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if cfg.locationRoubos[id] == nil then return end

        local tipo = cfg.locationRoubos[id].type
        if tipo ~= nil then
            local infoRoubo = cfg.roubos[tostring(tipo)]
            local itensRoubo = infoRoubo.itens
            local inPtr = src.totalPtr()

            for k,v in pairs(itensRoubo) do
                local itemAmount = vRP.getInventoryItemAmount(user_id, v)
                if itemAmount < 1 then
                    block_roubar[parseInt(user_id)] = true
                end
            end
            
            if block_roubar[user_id] then
                TriggerClientEvent("Notify",source,"negado","Você não possui os itens necessarios para roubar esse local.", 5)
            else
                if robberyList[id] == nil then
                    if inPtr >= infoRoubo.pmPTR then
                        for k,v in pairs(itensRoubo) do vRP.tryGetInventoryItem(user_id, v, 1, true) end
                        robberyList[id] = infoRoubo.cooldown
                        vRP.blockCommands(user_id, infoRoubo.tempo)
                        return true
                    else
                        TriggerClientEvent("Notify",source,"negado","Sem policias em patrulhamento no momento. ", 5)
                    end
                else
                    TriggerClientEvent("Notify",source,"negado","Aguarde <b>"..robberyList[id].." segundo(s)</b> para roubar este local.", 5)
                end
            end
            

            block_roubar[user_id] = false
        end
    end
end

function src.cancelRobbery()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        vRP.blockCommands(user_id, 0)
    end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- POLICIA NOTIFY
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.totalPtr()
    local policia = vRP.getUsersByPermission("perm.policia")	
    local contadorPOLICIA = 0
    for k,v in pairs(policia) do
        local patrulhamento = vRP.checkPatrulhamento(parseInt(v))
        if patrulhamento then
            contadorPOLICIA = contadorPOLICIA + 1
        end
    end
    
    return contadorPOLICIA
end 

function src.alertPolice(x,y,z,blipText, mensagem)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        vPOLICE.sendAlertPolice(source, x, y, z, blipText, mensagem)
    end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTADOR DE ROUBOS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		
		for k,v in pairs(robberyList) do
			if v > 0 then
				robberyList[k] = v - 1
			end

			if robberyList[k] == 0 then
				robberyList[k] = nil
			end
		end

        Citizen.Wait(1000)
	end
end)
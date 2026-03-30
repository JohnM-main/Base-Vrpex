local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_farms",src)
Proxy.addInterface("vrp_farms",src)

vCLIENT = Tunnel.getInterface("vrp_farms")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local actived = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GERAL
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.requestBancada(bancada)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local itens = {}
        local items = cfg.bancadaNui[bancada].itens
        if items then
            for k,v in pairs(items) do
                if vRP.getItemName(v.id) then
                    table.insert(itens,{ id = v.id, imagem = cfg.gerais["imagens"]..v.id..cfg.gerais["formatoImagens"], nome = vRP.getItemName(v.id), minAmount = v.minAmount, maxAmount = v.maxAmount, action = k })
                end
            end
           
            return cfg.bancadaNui[bancada].bancadaName,itens
        end
    end
end

function src.fabricarItem(item, minAmout, maxAmount)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if actived[user_id] == 0 or not actived[user_id] then 
            actived[parseInt(user_id)] = 10
            vCLIENT.iniciarRota(source, item, vRP.getItemName(item), minAmout, maxAmount)
            TriggerClientEvent("Notify",source,"importante","Você iniciou as rotas de <b>"..vRP.getItemName(item).."</b>.", 3)
            vCLIENT.closeNui(source)
        else
            TriggerClientEvent("Notify",source,"negado","Aguarde <b>"..actived[parseInt(user_id)].." segundo(s)</b> para iniciar novamente..", 3) 
        end
    end
end

function src.giveItem(item,amount, tipo)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.computeInvWeight(user_id) + vRP.getItemWeight(item) * amount <= vRP.getInventoryMaxWeight(user_id) then
            vRP.giveInventoryItem(user_id,item,amount, true)
            vRP.sendLog("FARMS", "O ID: "..user_id.." farmou o item " ..vRP.getItemName(item).. " na quantidade de "..amount)
            return true
        else
            TriggerClientEvent("Notify",source,"negado","Sua mochila esta cheia.", 3) 
        end
    end
end

function src.checkPermission(perm)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if perm == nil or vRP.hasPermission(user_id, perm) then
            return true
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ACTIVEDOWNTIME
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k,v in pairs(actived) do
			if v > 0 then
				actived[k] = v - 1
				if v <= 0 then
					actived[k] = nil
				end
			end
		end
	end
end)
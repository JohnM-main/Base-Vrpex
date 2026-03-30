local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_empregos",src)
vCLIENT = Tunnel.getInterface("vrp_empregos")

vPOLICE = Tunnel.getInterface("vrp_policia")
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECAR PLACA
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.checkPlate()
    local source = source
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if identity then
        return identity.registro
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PAGAMENTOS EMPREGOS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local minerios = {
    [1] = { "bronze", math.random(2,5) },
    [2] = { "ferro", math.random(2,5) },
    [3] = { "ouro", math.random(2,4) },
    [4] = { "diamante", math.random(2,4) },
    [5] = { "rubi", math.random(1,3) },
    [6] = { "safira", math.random(1,3) }
}

local peixes = {
    [1] = { "pacu" },
    [2] = { "tilapia" },
    [3] = { "salmao" },
    [4] = { "tucunare" },
    [5] = { "dourado" }
}

function src.payment(tipo, quantidade)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if tipo == "Lixeiro" then
            local nuser_id = {}
            local valor = cfg.config[tipo].price
            local count = 1
            local nplayers = vRPclient.getNearestPlayers(source, 8)

            for k,v in pairs(nplayers) do
                if vCLIENT.checkInServico(parseInt(k)) == tipo  then
                    nuser_id[vRP.getUserId(parseInt(k))] = true
                    count = count + 1
                else
                    TriggerClientEvent("Notify",parseInt(k),"negado","Você não recebeu pois não esta em serviço.",5)
                end
            end

            if count > 1 then
                valor = valor/count

                for k,v in pairs(nuser_id) do
                    vRP.giveMoney(parseInt(k), parseInt(valor))
                end

                vRP.giveMoney(user_id, parseInt(valor))
            else
                vRP.giveMoney(user_id, parseInt(valor))
            end

        elseif tipo == "Motorista" then
            local nuser_id = {}
            local valor = cfg.config[tipo].price
            local count = 1
            local nplayers = vRPclient.getNearestPlayers(source, 8)
            for k,v in pairs(nplayers) do
                if vCLIENT.checkInServico(parseInt(k)) == tipo then
                    nuser_id[vRP.getUserId(parseInt(k))] = true
                    count = count + 1
                else
                    TriggerClientEvent("Notify",parseInt(k),"negado","Você não recebeu pois não esta em serviço.",5)
                end
            end

            if count > 1 then
                valor = valor/count

                for k,v in pairs(nuser_id) do
                    vRP.giveMoney(parseInt(k), parseInt(valor))
                end

                vRP.giveMoney(user_id, parseInt(valor))
            else
                vRP.giveMoney(user_id, parseInt(valor))
            end
        elseif tipo == "Taxista" then
            local nuser_id = {}
            local valor = cfg.config[tipo].price
            local count = 1
            local nplayers = vRPclient.getNearestPlayers(source, 8)
            for k,v in pairs(nplayers) do
                if vCLIENT.checkInServico(parseInt(k)) == tipo then
                    nuser_id[vRP.getUserId(parseInt(k))] = true
                    count = count + 1
                else
                    TriggerClientEvent("Notify",parseInt(k),"negado","Você não recebeu pois não esta em serviço.",5)
                end
            end

            if count > 1 then
                valor = valor/count

                for k,v in pairs(nuser_id) do
                    vRP.giveMoney(parseInt(k), parseInt(valor))
                end

                vRP.giveMoney(user_id, parseInt(valor))
            else
                vRP.giveMoney(user_id, parseInt(valor))
            end

        elseif tipo == "Drogas" then
            local x,y,z = vRPclient.getPosition(source)
            local policia = vRP.getUsersByPermission("perm.policia")
            local valorPolicial = cfg.config[tipo].valorPorPolicia*#policia
            local chance = math.random(100)

            if chance >= 30 then
                vPOLICE.sendAlertPolice(source, x,y,z, "Venda de Drogas", "Um novo registro de vendas de drogas nesse momento.")
            end
            
            if vRP.tryGetInventoryItem(user_id, "maconha", quantidade, true) then
                vRP.giveInventoryItem(user_id, "dirty_money", cfg.config[tipo].price*quantidade+valorPolicial, true)
                vRP.sendLog("VENDERDROGAS", "O ID: "..user_id.." vendeu o item " ..vRP.getItemName("maconha").. " na quantidade de ".." e recebeu $ "..cfg.config[tipo].price*quantidade+valorPolicial.." dinheiro sujo")
                return true
            elseif vRP.tryGetInventoryItem(user_id, "cocaina", quantidade, true) then
                vRP.giveInventoryItem(user_id, "dirty_money", cfg.config[tipo].price*quantidade+valorPolicial, true)
                vRP.sendLog("VENDERDROGAS", "O ID: "..user_id.." vendeu o item " ..vRP.getItemName("cocaina").. " na quantidade de ".." e recebeu $ "..cfg.config[tipo].price*quantidade+valorPolicial.." dinheiro sujo")
                return true
            elseif vRP.tryGetInventoryItem(user_id, "lsd", quantidade, true) then
                vRP.giveInventoryItem(user_id, "dirty_money", cfg.config[tipo].price*quantidade+valorPolicial, true)
                vRP.sendLog("VENDERDROGAS", "O ID: "..user_id.." vendeu o item " ..vRP.getItemName("lsd").. " na quantidade de ".." e recebeu $ "..cfg.config[tipo].price*quantidade+valorPolicial.." dinheiro sujo")
                return true
            elseif vRP.tryGetInventoryItem(user_id, "heroina", quantidade, true) then
                vRP.giveInventoryItem(user_id, "dirty_money", cfg.config[tipo].price*quantidade+valorPolicial, true)
                vRP.sendLog("VENDERDROGAS", "O ID: "..user_id.." vendeu o item " ..vRP.getItemName("heroina").. " na quantidade de ".." e recebeu $ "..cfg.config[tipo].price*quantidade+valorPolicial.." dinheiro sujo")
                return true
            elseif vRP.tryGetInventoryItem(user_id, "ecstasy", quantidade, true) then
                vRP.giveInventoryItem(user_id, "dirty_money", cfg.config[tipo].price*quantidade+valorPolicial, true)
                vRP.sendLog("VENDERDROGAS", "O ID: "..user_id.." vendeu o item " ..vRP.getItemName("ecstasy").. " na quantidade de ".." e recebeu $ "..cfg.config[tipo].price*quantidade+valorPolicial.." dinheiro sujo")
                return true
            elseif vRP.tryGetInventoryItem(user_id, "metanfetamina", quantidade, true) then
                vRP.giveInventoryItem(user_id, "dirty_money", cfg.config[tipo].price*quantidade+valorPolicial, true)
                vRP.sendLog("VENDERDROGAS", "O ID: "..user_id.." vendeu o item " ..vRP.getItemName("metanfetamina").. " na quantidade de "..quantidade.." e recebeu $ "..cfg.config[tipo].price*quantidade+valorPolicial.." dinheiro sujo")
                return true
            else
                TriggerClientEvent("Notify",source,"negado","Você não possui a quantia de <b>"..quantidade.." x</b> drogas.", 5)
                return false
            end

        elseif tipo == "Minerador" then
            if vRP.computeInvWeight(user_id)+vRP.getItemWeight(minerios[quantidade][1]) <= vRP.getInventoryMaxWeight(user_id) then
                vRP.giveInventoryItem(user_id, minerios[quantidade][1], minerios[quantidade][2], true)
            else
                TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
            end

        elseif tipo == "Entregador" then
            if vRP.tryGetInventoryItem(user_id, "caixa", 1, true) then
                vRP.giveMoney(user_id, parseInt(cfg.config[tipo].price))
                return true
            end

        elseif tipo == "Lenhador" then
            if vRP.computeInvWeight(user_id)+vRP.getItemWeight("madeira") <= vRP.getInventoryMaxWeight(user_id) then
                vRP.giveInventoryItem(user_id, "madeira", 1, true)
                return true
            else
                TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
            end

        elseif tipo == "Pescador" then
            if vRP.computeInvWeight(user_id)+vRP.getItemWeight(peixes[quantidade][1]) <= vRP.getInventoryMaxWeight(user_id) then
                vRP.giveInventoryItem(user_id, peixes[quantidade][1], 1, true)
            else
                TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
            end

        elseif tipo == "Tartaruga" then
            if vRP.computeInvWeight(user_id)+vRP.getItemWeight("tartaruga") <= vRP.getInventoryMaxWeight(user_id) then
                vRP.giveInventoryItem(user_id, "tartaruga", 1, true)
            else
                TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
            end
            
        end

    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ENTREGADOR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.giveCaixas(quantidade)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.computeInvWeight(user_id)+vRP.getItemWeight("caixa")*quantidade <= vRP.getInventoryMaxWeight(user_id) then
            vRP.giveInventoryItem(user_id, "caixa", quantidade, true)
        else
            TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PESCADOR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.tryIsca()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.tryGetInventoryItem(user_id, "isca", 1, true) then
            return true
        else
            TriggerClientEvent("Notify",source,"negado","Acabou suas iscas, volte a central e busque mais.", 5)
        end
    end
end

function src.giveIsca(quantidade)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.computeInvWeight(user_id)+vRP.getItemWeight("isca")*quantidade <= vRP.getInventoryMaxWeight(user_id) then
            vRP.giveInventoryItem(user_id, "isca", quantidade, true)
        else
            TriggerClientEvent("Notify",source,"negado","Mochila cheia.", 5)
        end
    end
end
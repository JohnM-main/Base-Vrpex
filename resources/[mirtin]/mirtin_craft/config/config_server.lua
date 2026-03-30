local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("mirtin_craft",src)
Proxy.addInterface("mirtin_craft",src)

vCLIENT = Tunnel.getInterface("mirtin_craft")
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config = {}
config.token = "DEFINA-SEU-TOKEN-AQUI"  -- configure aqui seu token [ DEFINA-SEU-TOKEN-AQUI ]
config.delayCraft = 5 -- Segundos ( Delay de cada mesa de craft, para evitar floods )
config.weebdump = "" -- WEEBHOOK QUANDO NEGO TENTAR DUMPAR DESLIGANDO A INTERNET. 

config.weebhook = {
    logo = "https://i.imgur.com/Ta9YOaY.png", -- LOGO do Servidor
    color =  6356736,
    footer = "© Mirt1n Store",
}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG CRAFT
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config.table = {
    ["Mafia"] = { -- NUNCA REPITIR O MESMO NOME
       armazem = false, -- Caso coloque true, configure a localização do armazem. ( false os items precisam está no inventario .)
       weebhook = "", -- WEEBHOOK DAS TRANSACOES FEITAS AQUI [ CRAFT / ARMAZEM ] [ PASSAR PARA SERVER SIDE AQUI TUDO ]

       craft = {
            ["Mochila"] = { -- IMAGEM DO ITEM
                spawnID = "mochila", -- SPAWN DO ITEM
                nameItem = "Mochila", -- NOME DO ITEM
                maxAmount = 50, -- Quantidade maxima de Craft [ VALOR DA INPUT < > ]
                customAmount = 1, -- Caso queira colocar um valor x por unidade.
                tempo = 10, -- Tempo de craft por Unidade [ em segundos ]
                anim = { "amb@prop_human_parking_meter@female@idle_a","idle_a_female" }, -- ANIMAÇÃO DURANTE O CRAFT. (SE O TEMPO ESTIVER 0 DESCONSIDERAR)

                requires = {
                    { item = "m-malha" , amount = 1 }, -- ITEM / QUANTIDADE ( POR UNIDADE )
                    { item = "m-tecido" , amount = 1 },
                }
            },
        
            ["WEAPON_ASSAULTRIFLE_MK2"] = { -- IMAGEM DO ITEM
                spawnID = "WEAPON_ASSAULTRIFLE_MK2", -- SPAWN DO ITEM
                nameItem = "AK-47", -- NOME DO ITEM
                maxAmount = 5, -- Quantidade maxima de Craft [ VALOR DA INPUT < >]
                customAmount = 1, -- Caso queira colocar um valor x por unidade.
                tempo = 10, -- Tempo de craft por Unidade [ em segundos ]
                anim = { "amb@prop_human_parking_meter@female@idle_a","idle_a_female" }, -- ANIMAÇÃO DURANTE O CRAFT. (SE O TEMPO ESTIVER 0 DESCONSIDERAR)

                requires = {
                    { item = "m-aco" , amount = 25 }, -- ITEM / QUANTIDADE ( POR UNIDADE )
                    { item = "m-gatilho" , amount = 10 },
                    { item = "m-corpo_ak47_mk2" , amount = 2 },
                    { item = "m-placametal" , amount = 200 },
                }
            },  

            ["celular"] = { -- IMAGEM DO ITEM
                spawnID = "celular", -- SPAWN DO ITEM
                nameItem = "Celular", -- NOME DO ITEM
                maxAmount = 5, -- Quantidade maxima de Craft [ VALOR DA INPUT < >]
                customAmount = 1, -- Caso queira colocar um valor x por unidade.
                tempo = 5, -- Tempo de craft por Unidade [ em segundos ]
                anim = { "amb@prop_human_parking_meter@female@idle_a","idle_a_female" }, -- ANIMAÇÃO DURANTE O CRAFT. (SE O TEMPO ESTIVER 0 DESCONSIDERAR)

                requires = {
                    { item = "m-aco" , amount = 25 }
                }
            },  

            ["money"] = { -- IMAGEM DO ITEM
                spawnID = "money", -- SPAWN DO ITEM
                nameItem = "Dinheiro", -- NOME DO ITEM
                maxAmount = 10, -- Quantidade maxima de Craft [ VALOR DA INPUT < >]
                customAmount = 100000, -- Caso queira colocar um valor x por unidade.
                tempo = 1, -- Tempo de craft por Unidade [ em segundos ]
                anim = { "amb@prop_human_parking_meter@female@idle_a","idle_a_female" }, -- ANIMAÇÃO DURANTE O CRAFT. (SE O TEMPO ESTIVER 0 DESCONSIDERAR)

                requires = {
                    { item = "dirty_money" , amount = 100000 },
                    { item = "l-alvejante" , amount = 3 },
                }
            },  

            ["radio"] = { -- IMAGEM DO ITEM
                spawnID = "radio", -- SPAWN DO ITEM
                nameItem = "Radio", -- NOME DO ITEM
                maxAmount = 5, -- Quantidade maxima de Craft [ VALOR DA INPUT < >]
                customAmount = 1, -- Caso queira colocar um valor x por unidade.
                tempo = 15, -- Tempo de craft por Unidade [ em segundos ]
                anim = { "amb@prop_human_parking_meter@female@idle_a","idle_a_female" }, -- ANIMAÇÃO DURANTE O CRAFT. (SE O TEMPO ESTIVER 0 DESCONSIDERAR)

                requires = {
                    { item = "m-aco" , amount = 25 }
                }
            },  
       }
    },
}

config.craftLocations = {
    [1] = { type = "Mafia", perm = nil, coords = vec3(582.31,-3110.7,6.07), visible = 5.0 },
}

config.armazemLocations = {
    ["Mafia"] = { perm = "perm.mafia", coords = vec3(585.68,-3118.25,6.07), visible = 5.0 },
}


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
src.checkPermission = function(permission)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if permission == nil then
            return true
        end

        if vRP.hasPermission(user_id, permission) then
            return true
        end

        return false
    end
end

src.getItemName = function(item)
    return vRP.getItemName(item)
end

src.giveInventoryItem = function(user_id, item, amount)
    vRP.giveInventoryItem(user_id, item, amount, true)
end

src.getInventoryItemAmount = function(user_id, item)
    return vRP.getInventoryItemAmount(user_id, item)
end

src.tryGetInventoryItem = function(user_id, item, amount)
    return vRP.tryGetInventoryItem(user_id, item, amount, true)
end

src.checkInventoryWeight = function(user_id, spawnID, amount)
    if vRP.computeInvWeight(user_id)+vRP.getItemWeight(tostring(spawnID))*parseInt(amount) > vRP.getInventoryMaxWeight(user_id) then -- CASO ESTIVER CHEIO
        return false
    end

    return true
end

src.playAnim = function(source, anim1, anim2) 
    vRPclient._playAnim(source, false,{{anim1, anim2}},true)
end

src.stopAnim = function(source) 
    vRPclient._stopAnim(source, false)
end

src.progressBar = function(user_id, time)
    local source = vRP.getUserSource(user_id)
    TriggerClientEvent("progress", source, time) -- Caso use em segundos
    -- TriggerClientEvent("progress", source, time*1000) -- Caso use em milissegundos
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LANGS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config.lang = {
    notArmazemItem = function(source, mensagem, tipo) if tipo == "armazem" then TriggerClientEvent("Notify",source,"negado","O Armazem possui: <br>" ..mensagem, 5) else TriggerClientEvent("Notify",source,"negado","Você possui: <br>" ..mensagem, 5) end end,
    erroFabricar = function(source) TriggerClientEvent("Notify",source,"sucesso","Ocorreu um erro ao tentar fabricar esse item, tente novamente!", 5) end,
    waitCraft = function(source, segundos) TriggerClientEvent("Notify",source,"sucesso","Aguarde, <b>"..segundos.." segundo(s)</b> para continuar.", 5) end,
    armazemItens = function(source, mensagem) TriggerClientEvent("Notify",source,"importante","Itens do Armazem:<br> ".. mensagem, 15)  end,
    notArmazemItens = function(source) TriggerClientEvent("Notify",source,"importante","Esse Armazem, não possui <b>itens</b>.", 5)  end,
    notStoreItens = function(source) TriggerClientEvent("Notify",source,"importante","Você não possui itens que possa ser guardado no armazem.", 5)  end,
    storeItens = function(source, mensagem) TriggerClientEvent("Notify",source,"importante","Você guardou:<br> "..mensagem, 5)  end,
    backpackFull = function(source) TriggerClientEvent("Notify",source,"negado","Sua Mochila está cheia", 5)  end,
    fabricandoItem = function(source) TriggerClientEvent("Notify",source,"negado","Aguarde, Você ja está fabricando um item.", 5)  end,
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE DESMANCHE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local desmanchando = {}

function src.checkVehicleStatus(mPlaca,mName)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        
        if desmanchando[mPlaca] or desmanchando[mPlaca] ~= nil then
            TriggerClientEvent("Notify",source,"negado","Este veiculo ja esta sendo desmanchado.", 5)
            return
        end

        local nuser_id = vRP.getUserByPlate(mPlaca)
        if nuser_id then
            local rows = vRP.query("vRP/get_veiculos_status", {user_id = nuser_id, veiculo = mName})
            if rows[1] then
                if rows[1].status == 0 then
                    desmanchando[mPlaca] = user_id
                    vRP.blockCommands(user_id, 60)
                    return true
                else
                    TriggerClientEvent("Notify",source,"negado","Este veiculo ja se encontra detido/retido.", 5)
                end
            end
        else
            TriggerClientEvent("Notify",source,"negado","Este veiculo nao possui nenhum proprietario.", 5)
        end
    end
end

function src.pagarDesmanche(mPlaca,mName,mPrice,mVeh)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local nuser_id = vRP.getUserByPlate(mPlaca)
        if nuser_id then
            if desmanchando[mPlaca] == user_id then
                vRP.blockCommands(user_id, 0)
                vRP.execute("vRP/set_status",{ user_id = nuser_id, veiculo = mName, status = 2})
                vRP.giveInventoryItem(user_id, "dirty_money", mPrice*0.3, true)
                
                TriggerEvent('nation:deleteVehicleSync', mVeh)
                desmanchando[mPlaca] = nil

                vRP.sendLog("DESMANCHE", "O ID: "..user_id.." desmanchou o veiculo do id "..nuser_id.." veiculo: "..mName.." placa: "..mPlaca.." e recebeu $ "..vRP.format(mPrice*0.3))
            else
                print(user_id, "Troxa dupando #DUPANDO")
            end
        else
            TriggerClientEvent("Notify",source,"negado","Este veiculo nao possui nenhum proprietario.", 5)
        end
    end
end


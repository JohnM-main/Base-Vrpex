----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CARREGAR CONTA QUANDO ENTRAR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
    if user_id then
        if first_spawn then
            vRP.carregarConta(user_id, true)
        else
            vRP.carregarConta(user_id, false)
        end
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATE ACCOUNT
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function tvRP.updateRoupas()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if not vRP.checkPatrulhamento(user_id) or not vRP.checkFarda(user_id) then
            vRP.updateRoupas(user_id, vRPclient.getCustomization(source))
        end
    end
end

function tvRP.updatePos(x,y,z)
    local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		local tmp = vRP.getUserTmpTable(user_id)
		if data and (not tmp or not tmp.home_stype) then
			data.position = { x = tonumber(x), y = tonumber(y), z = tonumber(z) }
		end
	end
end

function tvRP.updateArmor(armor)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.colete = armor
		end
	end
end

function tvRP.updateWeapons(weapons)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.weapons = weapons
		end
	end
end

function tvRP.updateHealth(health)
	local user_id = vRP.getUserId(source)
	if user_id then
		local data = vRP.getUserDataTable(user_id)
		if data then
			data.health = health
		end
	end
end

function tvRP.atualizarRosto()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        vRP.carregarRosto(user_id)
        vRP.carregarTatuagens(user_id)
    end
end

function vRP.clearAccount(user_id)
    local source = vRP.getUserSource(user_id)
    if user_id then
        local data = vRP.getUserDataTable(user_id)

        data.inventory = {}
        data.weapons = {}

        vRP.clearInventory(user_id)
		vRPclient._setHandcuffed(source,false)
        vRPclient._replaceWeapons(source,{})
        vRP.carregarConta(user_id, false)

        if not data.mochila.perder or data.mochila.perder <= 0 and not vRP.hasPermission(user_id, "perm.mochila") then
            data.mochila = { quantidade = 0, perder = 0 }
        end
    end
end

function tvRP.clearInventory()
    local source = source
    local user_id = vRP.getUserId(source)
    local data = vRP.getUserDataTable(user_id)
    if user_id then
        vRP.clearInventory(user_id)
        vRPclient._replaceWeapons(source,{})

        if data then
            data.weapons = {}
            data.inventory = {} 
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ROSTO & ROUPAS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.carregarInfo(user_id)
    local source = vRP.getUserSource(user_id)
    
    Wait(5000) 
    if user_id then
        local data = vRP.getUserDataTable(user_id)
        if data then
            if not data.position or data.position == nil then
                data.position = {}
            end
    
            if data.weapons == nil then
                data.weapons = {}
            end

            if data.colete == nil then
                data.colete = 0
            end

            if data.health == nil then
                data.health = 300
            end

            if data.hunger == nil then
                data.hunger = 0
            end

            if data.thirst == nil then
                data.thirst = 0
            end

            SetTimeout(5000, function()
                local source = vRP.getUserSource(user_id)
    
                if source then
                    local colete = data.colete
                    local weapons = data.weapons
                    local health = data.health

                    vRPclient._giveWeapons(source, weapons, true)
                    vRPclient._setHealth(source, parseInt(health))
                    vRPclient._setArmour(source, colete)
    
                    vRPclient._setJogando(source,true)
                end
            end)
    
            --vRP.setThirst(user_id, data.thirst)
            --vRP.setHunger(user_id, data.hunger) 
           
            vRPclient._teleport(source,data.position.x,data.position.y,data.position.z)
        end
    end
end

function vRP.updateRoupas(user_id, roupas)
    if user_id then
        vRP.execute("vRP/set_roupas",{ user_id = user_id, roupas = json.encode(roupas) })
    end
end

function vRP.carregarRosto(user_id)
	local source = vRP.getUserSource(user_id)
	if source then
		local rows = vRP.query("vRP/get_controller",{ user_id = user_id })
		if rows[1].controller == 1 then
			local getRosto = vRP.query("vRP/get_rosto", {user_id = user_id})
			local custom = json.decode(getRosto[1].rosto) or nil
			if custom ~= nil then
				vRPclient._updateRosto(source, custom)
			end
		end
	end
end

function vRP.carregarRoupas(user_id)
	local source = vRP.getUserSource(user_id)
    local rows = vRP.query("vRP/get_users_infos",{ user_id = user_id })
    if rows then
        vRPclient._setCustomization(source, json.decode(rows[1].roupas))
    end
end

function vRP.carregarTatuagens(user_id)
    local source = vRP.getUserSource(user_id)
    local rows = vRP.query("vRP/get_users_infos",{ user_id = user_id })
    local tattos = json.decode(rows[1].tattos)
    if rows then
        TriggerClientEvent("vRP_Tatuagem:carregarTatuagens", source, tattos)
    end
end

function vRP.carregarConta(user_id, database)
	if user_id then
		vRP.carregarRoupas(user_id)
        vRP.carregarRosto(user_id)
        vRP.carregarTatuagens(user_id)

        if database then
            vRP.carregarInfo(user_id)
        end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- BLOCK COMMANDS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local time = {}

function vRP.blockCommands(user_id, segundos)
    time[user_id] = segundos
end

function vRP.unblockCommands(user_id)
    time[user_id] = nil
end

function vRP.checkCommands(user_id)
    local source = vRP.getUserSource(user_id)
    if source then
        if not time[user_id] and time[user_id] == nil then
            if GetEntityHealth(GetPlayerPed(source)) > 101 then
                return true
            end 
        else
            TriggerClientEvent("Notify", source,"negado","Você precisa esperar <b>"..time[user_id].." segundo(s)</b> para executar essa ação.", 5)
        end
    end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MALA
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("trymala")
AddEventHandler("trymala",function(nveh)
	TriggerClientEvent("syncmala",-1,nveh)
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTADOR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k,v in pairs(time) do
			if v >= 0 then
                time[k] = v - 1
				if v == 0 then
					time[k] = nil
                end

                if v < 0 then
                    time[k] = nil
                end
			end
		end
	end
end)
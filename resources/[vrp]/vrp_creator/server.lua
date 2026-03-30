local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local userlogin = {}
AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	if first_spawn then
		local rows = vRP.query("vRP/get_controller",{ user_id = user_id }) or 0
		if rows then
			processSpawnController(source,rows[1].controller,user_id)
		end
	end
end)


function processSpawnController(source,statusSent,user_id)
	local source = source
	if statusSent >= 1 then
		if not userlogin[user_id] then
			userlogin[user_id] = true
			doSpawnPlayer(source,user_id,false)
		else
			doSpawnPlayer(source,user_id,true)
		end
	elseif statusSent == 0 then
		userlogin[user_id] = true
		TriggerClientEvent("character:characterCreate",source)
		SetPlayerRoutingBucket(source, parseInt(user_id)) 
	end
end

RegisterServerEvent("character:finishedCharacter")
AddEventHandler("character:finishedCharacter",function(currentCharacterMode)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.execute("vRP/set_controller",{ user_id = user_id, controller = 1, rosto = json.encode(currentCharacterMode) })

		vRP.giveInventoryItem(user_id, "money", 10000, false, 1)
		vRP.giveInventoryItem(user_id, "celular", 1, false, 2)
		SetPlayerRoutingBucket(source, 0) 

		SetTimeout(60*1000, function()
			exports['fivem']:dispatch('vrp', 'addTemporaryGroup', 5, user_id, 'Vipfree')
			TriggerClientEvent('__title', source, 'PARABÉNS, VOCÊ FOI PREMIADO!', 'VOCÊ ACABA DE GANHAR UM VIP GRATUITO POR 5 DIAS, /vip PARA MAIS INFORMAÇÕES')
		end)
	end
end)

RegisterServerEvent("character:updateName")
AddEventHandler("character:updateName",function(idNome,idSobrenome,idIdade)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.execute("vRP/update_user_first_spawn",{ user_id = user_id, nome = idNome, sobrenome = idSobrenome, idade = idIdade })
		vRP.updateIdentity(user_id)
	end
end)

function doSpawnPlayer(source,user_id,firstspawn)
	TriggerClientEvent("character:normalSpawn",source,firstspawn)
end
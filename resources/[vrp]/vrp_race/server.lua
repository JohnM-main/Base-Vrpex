local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

emP = {}
Tunnel.bindInterface("vrp_race",emP)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
local pay = {
	[1] = { ['min'] = 5000, ['max'] = 10000 }
}

function emP.paymentCheck(check,status)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local random = math.random(pay[check].min,pay[check].max)
		local policia = vRP.getUsersByPermission("perm.policia")
		if parseInt(#policia) == 0 then
			vRP.giveInventoryItem(user_id,"dirty_money",parseInt(random))
		else
			vRP.giveInventoryItem(user_id,"dirty_money",parseInt(random))
		end

		vRP.sendLog("CORRIDAILEGAL", "O ID: "..user_id.." finalizou a corrida ilegal e recebeu $ "..vRP.format(random).." dinheiro sujo.")
	end
end

function emP.initCorrida()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.sendLog("CORRIDAILEGAL", "O ID: "..user_id.." iniciou a corrida ilegal.")
	end
end

local racepoint = 1
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(180000)
		racepoint = math.random(#pay)
	end
end)

function emP.getRacepoint()
	return parseInt(racepoint)
end

function emP.startBombRace()
	local source = source
	local policia = vRP.getUsersByPermission("perm.policia")
	for l,w in pairs(policia) do
		local player = vRP.getUserSource(parseInt(w))
		if player then
			async(function()
				vRPclient._playSound(player,"Oneshot_Final","MP_MISSION_COUNTDOWN_SOUNDSET")
				TriggerClientEvent('chatMessage',player,"911",{65,130,255},"Encontramos um corredor ilegal na cidade, intercepte-o.")
			end)
		end
	end
end

function emP.removeBombRace()
	local source = source
	TriggerEvent('eblips:remove',source)
end

RegisterCommand('defuse',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"perm.policia") then
		local nplayer = vRPclient._getNearestPlayer(source,2)
		if nplayer then
			TriggerClientEvent('emp_race:defuse',nplayer)
		end
	end
end)

RegisterServerEvent('azRaces:blip')
AddEventHandler('azRaces:blip',function(x,y,z)
	local user_id = vRP.getUserId(source)
	if user_id then
		--if not vRP.hasPermission(user_id,"perm.policia") then
			local policiais = vRP.getUsersByPermission("perm.policia")
			for l,w in pairs(policiais) do
				local player = vRP.getUserSource(w)
				if player then
					TriggerClientEvent('AZnotificacao:corrida',player,x,y,z,user_id)
				end
			end
		--end
	end
end)
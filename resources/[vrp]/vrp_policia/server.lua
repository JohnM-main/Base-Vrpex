local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_policia",src)
Proxy.addInterface("vrp_policia",src)

vCLIENT = Tunnel.getInterface("vrp_policia")

local idgens = Tools.newIDGenerator()
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MENUS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local policia_equipamentos = {}
local segundos = {}

policia_equipamentos["1. Patrulhamento"] = {function(source,choice)
	local user_id = vRP.getUserId(source)
	local sexo = vCLIENT.checkSexo(source)
	local identity = vRP.getUserIdentity(user_id)
	local group = vRP.getUserGroupByType(user_id, "org")
	if user_id ~= nil and not segundos[user_id] and segundos[user_id] == nil then
		segundos[user_id] = 5

		if vRP.hasGroup(user_id, "Comandante") then
			vRPclient._giveWeapons(source, { ["WEAPON_CARBINERIFLE"] = {ammo= 250}, ["WEAPON_SNIPERRIFLE"] = {ammo= 30}, ["WEAPON_SMG"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250}, ["WEAPON_PUMPSHOTGUN_MK2"] = {ammo= 20}, ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "Coronel") or vRP.hasGroup(user_id, "Tenente Coronel") or vRP.hasGroup(user_id, "Major")  or vRP.hasGroup(user_id, "Tenente [STIC]") or vRP.hasGroup(user_id, "Sargento [STIC]") or vRP.hasGroup(user_id, "Cabo [STIC]") or vRP.hasGroup(user_id, "Soldado [STIC]") or vRP.hasGroup(user_id, "Recruta [STIC]")   then
			vRPclient._giveWeapons(source, { ["WEAPON_CARBINERIFLE"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250}, ["WEAPON_PUMPSHOTGUN_MK2"] = {ammo= 30}, ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "Capitao") then
			vRPclient._giveWeapons(source, { ["WEAPON_CARBINERIFLE"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250}, ["WEAPON_PUMPSHOTGUN_MK2"] = {ammo= 30},  ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "1Tenente") or vRP.hasGroup(user_id, "2Tenente") or vRP.hasGroup(user_id, "Aspirante") or vRP.hasGroup(user_id, "SubTenente") then
			vRPclient._giveWeapons(source, { ["WEAPON_CARBINERIFLE_MK2"] = {ammo= 250}, ["WEAPON_SMG"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250},  ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "1Sargento") or vRP.hasGroup(user_id, "2Sargento") or vRP.hasGroup(user_id, "3Sargento")  then
			vRPclient._giveWeapons(source, { ["WEAPON_CARBINERIFLE_MK2"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250}, ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "Recruta") then
			vRPclient._giveWeapons(source, { ["WEAPON_COMBATPISTOL"] = {ammo= 250}, ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "Soldado") then
			vRPclient._giveWeapons(source, { ["WEAPON_SMG"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250},  ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "Cabo") then
			vRPclient._giveWeapons(source, { ["WEAPON_COMBATPISTOL"] = {ammo= 250},  ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		
		end

		limparItems(user_id)
		vRP.addPeso(user_id, 15)
		vRP.giveInventoryItem(user_id, "algemas", 1, true)
		vRP.giveInventoryItem(user_id, "radio", 1, true)
		vRP.giveInventoryItem(user_id, "body_armor", 1, true) 
		vRP.setPatrulhamento(user_id)
		vRPclient._setArmour(source,100)
		TriggerClientEvent("vrp_sysblips:ToggleService",source, "Policial" , 3,"Policia")

		vRP.sendLog("BATERPONTOPOLICIA", "```css\n** BATER PONTO [PATRULHAMENTO]**\n"..os.date("[%d/%m/%Y as %X]").." O Policial ["..identity.nome ..identity.sobrenome.." ("..user_id..")] acabou de entrar em expediente. ```")
	end
end}

policia_equipamentos["2. Sair"] = {function(source,choice)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
    if user_id ~= nil and not segundos[user_id] and segundos[user_id] == nil then
		segundos[user_id] = 5
		
		limparItems(user_id)
		vRP.addPeso(user_id, 0)
		vRPclient._giveWeapons(source, {}, true)
		vRP.removerFarda(user_id) 
		vRP.removePatrulhamento(user_id)
		vRPclient._setArmour(source, 0)
		TriggerEvent("vrp_sysblips:ExitService",source)

		vRP.sendLog("BATERPONTOPOLICIA", "```css\n** BATER PONTO [SAIR] **\n"..os.date("[%d/%m/%Y as %X]").." O Policial ["..identity.nome ..identity.sobrenome.." ("..user_id..")] acabou de sair do expediente. ```")
	end
end} 

function limparItems(id)
    vRP.tryGetInventoryItem(id, "chave_algemas", vRP.getInventoryItemAmount(id, "chave_algemas"), true)
	vRP.tryGetInventoryItem(id, "algemas", vRP.getInventoryItemAmount(id, "algemas"), true)
	vRP.tryGetInventoryItem(id, "body_armor", vRP.getInventoryItemAmount(id, "colete"), true)
end

vRP._addStaticMenuChoices("policia_equipamentos", policia_equipamentos)


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MENUS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local policia_equipamentosstic = {}

policia_equipamentosstic["1. Patrulhamento"] = {function(source,choice)
	local user_id = vRP.getUserId(source)
	local sexo = vCLIENT.checkSexo(source)
	local identity = vRP.getUserIdentity(user_id)
	local group = vRP.getUserGroupByType(user_id, "org")
	if user_id ~= nil and not segundos[user_id] and segundos[user_id] == nil then
		segundos[user_id] = 5

		if vRP.hasGroup(user_id, "Comandante") then
			vRPclient._giveWeapons(source, { ["WEAPON_CARBINERIFLE"] = {ammo= 250}, ["WEAPON_SNIPERRIFLE"] = {ammo= 30}, ["WEAPON_SMG"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250}, ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "Coronel") or vRP.hasGroup(user_id, "Tenente Coronel") or vRP.hasGroup(user_id, "Major")  or vRP.hasGroup(user_id, "Tenente [STIC]") or vRP.hasGroup(user_id, "Sargento [STIC]") or vRP.hasGroup(user_id, "Cabo [STIC]") or vRP.hasGroup(user_id, "Soldado [STIC]") or vRP.hasGroup(user_id, "Recruta [STIC]")   then
			vRPclient._giveWeapons(source, { ["WEAPON_CARBINERIFLE"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250}, ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "Capitao") then
			vRPclient._giveWeapons(source, { ["WEAPON_CARBINERIFLE"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250}, ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "1Tenente") or vRP.hasGroup(user_id, "2Tenente") or vRP.hasGroup(user_id, "Aspirante") or vRP.hasGroup(user_id, "SubTenente") then
			vRPclient._giveWeapons(source, { ["WEAPON_CARBINERIFLE_MK2"] = {ammo= 250}, ["WEAPON_SMG"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250},  ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "1Sargento") or vRP.hasGroup(user_id, "2Sargento") or vRP.hasGroup(user_id, "3Sargento")  then
			vRPclient._giveWeapons(source, { ["WEAPON_CARBINERIFLE_MK2"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250}, ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "Recruta") then
			vRPclient._giveWeapons(source, { ["WEAPON_COMBATPISTOL"] = {ammo= 250}, ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "Soldado") then
			vRPclient._giveWeapons(source, { ["WEAPON_SMG"] = {ammo= 250}, ["WEAPON_COMBATPISTOL"] = {ammo= 250},  ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		elseif vRP.hasGroup(user_id, "Cabo") then
			vRPclient._giveWeapons(source, { ["WEAPON_COMBATPISTOL"] = {ammo= 250},  ["WEAPON_STUNGUN"] = {ammo=1}, ["WEAPON_FLASHLIGHT"] = {ammo=1}, ["WEAPON_NIGHTSTICK"] = {ammo=1} }, true)
		
		end

		limparItems(user_id)
		vRP.addPeso(user_id, 15)
		vRP.giveInventoryItem(user_id, "algemas", 1, true)
		vRP.giveInventoryItem(user_id, "radio", 1, true)
		vRP.setPatrulhamento(user_id)
		vRPclient._setArmour(source,100)
		TriggerClientEvent("vrp_sysblips:ToggleService",source, "Policial" , 3,"Policia")

		vRP.sendLog("BATERPONTOPOLICIA", "```css\n** BATER PONTO [PATRULHAMENTO]**\n"..os.date("[%d/%m/%Y as %X]").." O Policial ["..identity.nome ..identity.sobrenome.." ("..user_id..")] acabou de entrar em expediente. ```")
	end
end}

policia_equipamentosstic["2. Sair"] = {function(source,choice)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
    if user_id ~= nil and not segundos[user_id] and segundos[user_id] == nil then
		segundos[user_id] = 5
		
		limparItems(user_id)
		vRP.addPeso(user_id, 0)
		vRPclient._giveWeapons(source, {}, true)
		vRP.removerFarda(user_id) 
		vRP.removePatrulhamento(user_id)
		vRPclient._setArmour(source, 0)
		TriggerEvent("vrp_sysblips:ExitService",source)

		vRP.sendLog("BATERPONTOPOLICIA", "```css\n** BATER PONTO [SAIR] **\n"..os.date("[%d/%m/%Y as %X]").." O Policial ["..identity.nome ..identity.sobrenome.." ("..user_id..")] acabou de sair do expediente. ```")
	end
end} 

function limparItems(id)
    vRP.tryGetInventoryItem(id, "chave_algemas", vRP.getInventoryItemAmount(id, "chave_algemas"), true)
	vRP.tryGetInventoryItem(id, "algemas", vRP.getInventoryItemAmount(id, "algemas"), true)
end

vRP._addStaticMenuChoices("policia_equipamentosstic", policia_equipamentosstic)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RMASCARA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('rmascara',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"perm.policia") then
		local nplayer = vRPclient.getNearestPlayer(source,2)
		if nplayer then
			TriggerClientEvent('rmascara',nplayer)
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RCHAPEU
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('rchapeu',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"perm.policia") then
		local nplayer = vRPclient.getNearestPlayer(source,2)
		if nplayer then
			TriggerClientEvent('rchapeu',nplayer)
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Itens Ilegais
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local blackItens = {
	"algemas",
	"chave_algemas",
	"c4",
	"bolsadinheiro",
	"masterpick",
	"pendrive",
	"furadeira",
	"lockpick",
	"m-aco",
	"m-capa_colete",
	"m-corpo_ak47_mk2",
	"m-corpo_g3",
	"m-corpo_machinepistol",
	"m-corpo_pistol_mk2",
	"m-corpo_shotgun",
	"m-corpo_smg_mk2",
	"m-corpo_snspistol_mk2",
	"m-gatilho",
	"m-malha",
	"m-placametal",
	"m-tecido",
	"c-cobre",
	"c-ferro",
	"c-fio",
	"c-polvora",
	"l-alvejante",
	"folhamaconha",
	"maconha",
	"pococaina",
	"cocaina",
	"acidolsd",
	"body_armor",
	"capuz",
	"dirty_money",
	"scubagear",
	"relogioroubado",
	"colarroubado",
	"anelroubado",
	"brincoroubado",
	"pulseiraroubada",
	"carnedepuma",
	"carnedelobo",
	"carnedejavali",
	"lsd",
	"morfina",
	"heroina",
	"anfetamina",
	"metanfetamina",
	"tartaruga",
	"WEAPON_SNSPISTOL_MK2",
	"AMMO_SNSPISTOL_MK2",
	"WEAPON_PISTOL_MK2",
	"AMMO_PISTOL_MK2",
	"WEAPON_COMBATPISTOL",
	"AMMO_COMBATPISTOL",
	"WEAPON_MACHINEPISTOL",
	"AMMO_MACHINEPISTOL",
	"WEAPON_SMG_MK2",
	"AMMO_SMG_MK2",
	"WEAPON_SMG",
	"AMMO_SMG",
	"WEAPON_ASSAULTSMG",
	"AMMO_ASSAULTSMG",
	"WEAPON_SAWNOFFSHOTGUN",
	"AMMO_SAWNOFFSHOTGUN",
	"WEAPON_PUMPSHOTGUN_MK2",
	"AMMO_PUMPSHOTGUN_MK2",
	"WEAPON_ASSAULTRIFLE_MK2",
	"AMMO_ASSAULTRIFLE_MK2",
	"WEAPON_SPECIALCARBINE_MK2",
	"AMMO_SPECIALCARBINE_MK2",
	"WEAPON_CARBINERIFLE",
	"AMMO_CARBINERIFLE",
	"WEAPON_SPECIALCARBINE",
	"AMMO_SPECIALCARBINE",
	"WEAPON_STUNGUN",
	"WEAPON_PETROLCAN",
	"AMMO_PETROLCAN",
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PEGAR RG
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('rg',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
	local nplayer = vRPclient.getNearestPlayer(source,4)
	if vRP.hasPermission(user_id,"perm.policia") or vRP.hasPermission(user_id,"ticket.permissao") then
		if user_id then
			if nplayer then
				local nuser_id = vRP.getUserId(nplayer)
				local identity = vRP.getUserIdentity(nuser_id)
				local carteira = vRP.getMoney(nuser_id)
				local trabalho = vRP.getUserGroupByType(nuser_id, "job") if (trabalho == nil or trabalho == "") or (trabalho == "Vendedor de Drogas" or trabalho == "Traficante de Tartartuga" or trabalho == "Hacker" or trabalho == "Cacador" or trabalho == "Clandestino") then trabalho = "Desempregado" end

				if vCLIENT.enviarIdentidade(source, true, identity.user_id, identity.nome,identity.sobrenome,identity.idade,identity.registro,identity.telefone,vRP.format(carteira),trabalho) then
					TriggerClientEvent("Notify",nplayer,"importante","O Policial esta checando seu documento.", 5)
					if vRP.request(source, "Deseja fechar a identidade do individuo?", 120) then
						vCLIENT.enviarIdentidade(source, false) else vCLIENT.enviarIdentidade(source, false)
					end
				end
			else
				TriggerClientEvent("Notify",source,"negado","Nenhum jogador proximo.", 5)
			end
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE PRISAO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local tempoPrisao = {}

RegisterCommand('prender',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"perm.policia") then
		if user_id then
			if vCLIENT.checkPrisonArea(source) then
				local nplayer = vRPclient.getNearestPlayer(source, 2)
				if nplayer then
					local nuser_id = vRP.getUserId(nplayer)
					local tempo = vRP.prompt(source, "Digite o tempo da prisao: ", "")
					if tempo ~= nil and tempo ~= "" and tonumber(tempo) then
						if tonumber(tempo) > 180 then tempo = 180 end
						if tonumber(tempo) < 1 then tempo = 1 end
						local motivo = vRP.prompt(source, "Digite o motivo:", "")
						if motivo ~= nil and motivo ~= "" then
							local multas = vRP.prompt(source, "Digite o valor em multas: ", "")
							if multas ~= nil and multas ~= "" and tonumber(multas) then
								if tonumber(multas) >= 200000 then multas = 200000 end
								if tonumber(multas) >= 0 then multas = 0 end

								tempoPrisao[nuser_id] = tempo

								TriggerClientEvent("Notify",nplayer, "importante","Você esta sendo levado para prisao, caso deslogar/crashar sera adicionado +10min em sua pena.", 5)

								TriggerClientEvent("Notify",nplayer,"importante","Você foi preso/multado no valor de <b>$ "..vRP.format(multas).."</b> pelo motivo <b>"..motivo.."</b>", 5)
								vRP.execute("vRP/add_multa",{ user_id = nuser_id, multas = tonumber(multas) })

								src.adicionarCriminal(nuser_id, "PRISAO", motivo)
								src.setarPrisioneiro(nuser_id)
								vCLIENT.levarPrisioneiro(nplayer, tempo)
								vRP.addPrisioneiro(nplayer, true)
								vRP.blockCommands(nuser_id, 800)

								vRP.sendLog("PRENDER", "O Policial "..user_id.." prendeu o ID "..nuser_id.. " por "..tempo.." mes(s) pelo motivo de "..motivo.. " e aplico $"..vRP.format(multas).." em multas.")
							end
						end
					end
				else
					TriggerClientEvent("Notify",source,"negado","Nenhum jogador proximo.", 5)
				end

			else
				TriggerClientEvent("Notify",source,"importante","Você precisa está perto das celas para prender alguem", 5)
			end
		end
	end
end)

function src.setarPrisioneiro(user_id)
	local source = vRP.getUserSource(user_id)
	if user_id then
		vRPclient._setHealth(source, 300)
		vRPclient._setHandcuffed(source,true)
		vCLIENT.setarRoupasPrisional(source)

		for k,v in pairs(blackItens) do
			if vRP.getInventoryItemAmount(user_id, v) > 0 then
				vRP.tryGetInventoryItem(user_id, v, vRP.getInventoryItemAmount(user_id, v), true)
			end
		end

		vRPclient._giveWeapons(source, {}, true)
		vCLIENT.updateWeapons(source)
		TriggerClientEvent("Notify",source,"negado","Seus Itens ilegais foram apreendidos.", 5)
	end
end

function src.colocarPrisao(time)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		time = time - 5

		if time <= 0 then
			time = 0
		end

		TriggerClientEvent('chatMessage', -1, 'PRISÃO', { 0, 0, 0 }, '^0 O ^3'.. GetPlayerName(source) ..' ^0 foi preso(a) e condenado(a) por ^3'.. time ..' ^0mes(s).')
		vRP.setUData(user_id,"vRP:prisao",json.encode(tonumber(time)))
		vCLIENT.prisioneiro(source, true)
		src.setarPrisioneiro(user_id)
		tempoPrisao[user_id] = nil
		vRPclient._setHandcuffed(source,false)
		prison_lock(parseInt(user_id))
	end
end

function prison_lock(user_id)
	local source = vRP.getUserSource(parseInt(user_id))
	if source then
		SetTimeout(60000, function()
			local value = vRP.getUData(parseInt(user_id), "vRP:prisao")
			local tempo = json.decode(value) or 0
			if parseInt(tempo) >= 1 then
				vRP.setUData(parseInt(user_id), "vRP:prisao", json.encode(parseInt(tempo)-1))
				vRPclient._setHealth(source, 300)
				TriggerClientEvent("Notify",source,"importante","Você ainda vai passar "..parseInt(tempo).." meses na prisão.", 5)
				prison_lock(parseInt(user_id))
				vRP.addPrisioneiro(source, true)
			elseif parseInt(tempo) == 0 or parseInt(tempo) == -1 then
				vCLIENT.prisioneiro(source, false)
				vRP.setUData(parseInt(user_id), "vRP:prisao", json.encode(-1))
				TriggerClientEvent("Notify",source,"importante","Sua detenção acabou, esperamos não ve-lo novamente.", 5)
				vRPclient._teleport(source, 1847.94,2586.04,45.68)
				vRP.carregarConta(user_id, false)
				vRP.addPrisioneiro(source, false)
			end
		end)
	end
end


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ALGEMAR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.algemar()
	local source = source
    local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		if vRP.getInventoryItemAmount(user_id, "algemas") >= 1 or vRP.hasPermission(user_id, "perm.policia") or vRP.hasPermission(user_id, "admin.permissao") or vRP.hasPermission(user_id, "moderador.permissao") or vRP.hasPermission(user_id," suporte.permissao") then
			local nplayer = vRPclient.getNearestPlayer(source,3)
			if nplayer then
				if not vRPclient.isInVehicle(nplayer) then
					if vRPclient.isHandcuffed(nplayer) then
						TriggerClientEvent("vrp_sound:source",source,'uncuff',0.4)
						TriggerClientEvent("vrp_sound:source",nplayer,'uncuff',0.4)
						vRPclient._setHandcuffed(nplayer, false)
					else
						vCLIENT.arrastar(nplayer,source)
						vRPclient._playAnim(source,false,{{"mp_arrest_paired","cop_p2_back_left"}},false)
						vRPclient._playAnim(nplayer,false,{{"mp_arrest_paired","crook_p2_back_left"}},false)
						SetTimeout(3500,function()
							vRPclient._stopAnim(source,false)
							vRPclient._toggleHandcuff(nplayer)
							vCLIENT._arrastar(nplayer,source)
							TriggerClientEvent("vrp_sound:source",source,'cuff',0.1)
							TriggerClientEvent("vrp_sound:source",nplayer,'cuff',0.1)
							vRPclient._setHandcuffed(nplayer, true)
						end)
					end
				end
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RETIRAR MASCARA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('rmascara',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"perm.policia") then
		if user_id ~= nil then
			local nplayer = vRPclient.getNearestPlayer(source,3)
			if nplayer then
				vCLIENT.retirarMascara(nplayer)
			else
				TriggerClientEvent("Notify",source,"negado","Nenhum jogador proximo.", 5)
			end
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ARRASTAR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.arrastar()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		if vRP.getInventoryItemAmount(user_id, "algemas") >= 1 or vRP.hasPermission(user_id, "perm.policia") or vRP.hasPermission(user_id, "admin.permissao") or vRP.hasPermission(user_id, "moderador.permissao") or vRP.hasPermission(user_id," suporte.permissao") then
			local nplayer = vRPclient.getNearestPlayer(source,3)
			if nplayer then
				vCLIENT.arrastar(nplayer,source)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COLOCAR NO VEICULO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('cv',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local nplayer = vRPclient.getNearestPlayer(source,4)
	if vRP.hasPermission(user_id,"perm.policia") or vRP.hasPermission(user_id,"perm.unizk") then 
		if user_id then
			if nplayer then
				if vRPclient.isHandcuffed(nplayer) then
					vRPclient._putInNearestVehicleAsPassenger(nplayer, 5)
					TriggerClientEvent("Notify",source,"sucesso","Voce colocou o cidadao no veiculo.", 5)
				else
					TriggerClientEvent("Notify",source,"negado","O Jogador não está algemado.", 5)
				end
			else
				TriggerClientEvent("Notify",source,"negado","Nenhum jogador proximo.", 5)
			end
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RETIRAR DO VEICULO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('rv',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local nplayer = vRPclient.getNearestPlayer(source,4)
	if vRP.hasPermission(user_id,"perm.policia") or vRP.hasPermission(user_id,"perm.unizk")  or vRP.hasPermission(user_id,"admin.permissao") then 
		if user_id then
			if nplayer then
				if vRPclient.isHandcuffed(nplayer) then
					vRPclient._ejectVehicle(nplayer, {})
					TriggerClientEvent("Notify",source,"negado","Voce retirou o cidadao no veiculo.", 5)
				else
					TriggerClientEvent("Notify",source,"negado","O Jogador não está algemado.", 5)
				end
			else
				TriggerClientEvent("Notify",source,"negado","Nenhum jogador proximo.", 5)
			end
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- APREENDER ITENS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('apreender',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local nplayer = vRPclient.getNearestPlayer(source,4)
	local nuser_id = vRP.getUserId(nplayer)
	if vRP.hasPermission(user_id,"perm.policia") then
		if user_id then
			if nplayer then
				for k,v in pairs(blackItens) do
					if vRP.getInventoryItemAmount(nuser_id, v) > 0 then
						vRP.tryGetInventoryItem(nuser_id, v, vRP.getInventoryItemAmount(nuser_id, v), true)
					end
				end

				vRPclient._giveWeapons(nplayer, {}, true)
				vCLIENT._updateWeapons(nplayer)

				TriggerClientEvent("Notify",nplayer,"negado","Seus Itens ilegais foram apreendidos.", 5)
				TriggerClientEvent("Notify",source,"sucesso","Você aprendeu os itens ilegais.", 5)
			else
				TriggerClientEvent("Notify",source,"negado","Nenhum jogador proximo.", 5)
			end
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONSULTAR VEICULO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('placa',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"perm.policia") then
		if user_id then
			local mPlaca,mName = vRPclient.ModelName(source, 5)
			local mNome = vRPclient.getCar(source, mName)
			local nuser_id = vRP.getUserByPlate(mPlaca)
			if nuser_id then
				local identity = vRP.getUserIdentity(nuser_id)
				if identity then
					TriggerClientEvent("Notify",source,"importante","• Veiculo: <b>"..mNome.."</b><br>• Placa: <b>"..mPlaca.."</b><br>• Proprietario: <b>"..identity.nome.. " "..identity.sobrenome.. "</b> (<b>"..identity.idade.."</b>)<br>• Telefone: <b>"..identity.telefone.."</b> <br>• Passaporte: <b>"..identity.user_id.."</b> ", 50)
				end
			else
				TriggerClientEvent("Notify",source,"negado","Não foi possivel consultar esse veiculo.", 5)
			end
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- APREENDER VEICULO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('detido',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"perm.policia") then
		if user_id then
			local mPlaca,mName,mNetVeh = vRPclient.ModelName(source, 5)
			local mNome = vRPclient.getCar(source, mName)

			
			local nuser_id = vRP.getUserByPlate(mPlaca)
			local rows = vRP.query("vRP/get_veiculos_status", {user_id = nuser_id, veiculo = mName})
			if nuser_id then
				local identity = vRP.getUserIdentity(nuser_id)
				
				if identity then
					if rows[1].status == 0 then
						vRP.execute("vRP/set_status",{ user_id = nuser_id, veiculo = mName, status = 1})
						TriggerClientEvent('deletarveiculo',source, vRPclient.getNearestVehicle(source, 5))
						TriggerClientEvent("Notify",source,"importante","<b> VEICULO APREENDIDO: </b> <br>• Veiculo: <b>"..mNome.."</b><br>• Placa: <b>"..mPlaca.."</b><br>• Proprietario: <b>"..identity.nome.. " "..identity.sobrenome.. "</b> (<b>"..identity.idade.."</b>)<br>• Telefone: <b>"..identity.telefone.."</b> ", 15)
					else
						TriggerClientEvent("Notify",source,"importante","Este veiculo ja se encontra apreendido ", 5)
					end
				end

			end
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LIMPAR FICHA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('limparficha',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if user_id then
			local nuser_id = tonumber(args[1])
			if nuser_id ~= nil then
				local gCriminal = {}
				vRP.execute("vRP/add_criminal",{ user_id = nuser_id, criminal = json.encode(gCriminal) })
				TriggerClientEvent("Notify",source,"sucesso","Você limpo a ficha do (ID: "..nuser_id..") .", 5)
			end
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MULTAR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.addMulta(id, motivoMulta, officer, valorMulta)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.hasPermission(user_id,"perm.policia") then
			local nplayer = vRP.getUserSource(parseInt(id))
			if nplayer then
				if tonumber(valorMulta) >= 1 and tonumber(valorMulta) <= 500000 then
					TriggerClientEvent("Notify",source,"importante","Você multou o cidadao em <b>$ "..vRP.format(valorMulta).."</b>", 5)
					TriggerClientEvent("Notify",nplayer,"importante","Você foi multado no valor de <b>$ "..vRP.format(valorMulta).."</b> pelo motivo <b>"..motivoMulta.."</b>", 5)
					vRP.updateMultas(parseInt(id), vRP.getMultas(parseInt(id)) + tonumber(valorMulta))
					src.adicionarCriminal(parseInt(id), "MULTA", valorMulta, officer, motivoMulta)
				else
					TriggerClientEvent("Notify",source,"negado","Digite um valor correto entre 1-500000 ", 5)
				end
			else
				TriggerClientEvent("Notify",source,"negado","O Jogador não se encontra na cidade no momento.", 5)
			end
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FICHA CRIMINAL
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.adicionarCriminal(user_id, tipo, tempo, officer, criminal)
	local source = vRP.getUserSource(user_id)
	local cCriminal = vRP.query("vRP/get_user_identity",{ user_id = user_id })
	local gCriminal = json.decode(cCriminal[1].criminal) or nil
	if user_id then
	  gCriminal[os.time()] = {tipo = tipo, tempo = tempo, officer = officer, motivo = criminal}
	  vRP.execute("vRP/add_criminal",{ user_id = user_id, criminal = json.encode(gCriminal) })
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE CHAMAR A POLICIA
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.alertPolice(x,y,z, blipText, text)
	local policia = vRP.getUsersByPermission("perm.policia") 
	if #policia > 0 then
		for k,v in pairs(policia) do
			local nsource = vRP.getUserSource(parseInt(v))
			if nsource and vRP.checkPatrulhamento(parseInt(v)) then
				async(function()
					TriggerClientEvent("NotifyPush", nsource, { code = 31, title = blipText, x = x, y = y, z = z, badge = text })
				end)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- P
-----------------------------------------------------------------------------------------------------------------------------------------
local idgens = Tools.newIDGenerator()
local policia = {}
RegisterCommand('p',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local uplayer = vRP.getUserSource(user_id)
    local identity = vRP.getUserIdentity(user_id)
    local x,y,z = vRPclient.getPosition(source)
    if vRPclient.getHealth(source) > 100 then
        if vRP.hasPermission(user_id,"perm.policia") then
            local soldado = vRP.getUsersByPermission("perm.policia")
            for l,w in pairs(soldado) do
                local player = vRP.getUserSource(parseInt(w))
                if player and player ~= uplayer then
                    async(function()
                        local id = idgens:gen()
                        policia[id] = vRPclient.addBlip(player,x,y,z,153,84,"Localização de "..identity.nome.." "..identity.sobrenome,0.5,false)
                        TriggerClientEvent("Notify",player,"importante","Localização recebida de <b>"..identity.nome.." "..identity.sobrenome.."</b>.")
                        vRPclient._playSound(player,"Out_Of_Bounds_Timer","DLC_HEISTS_GENERAL_FRONTEND_SOUNDS")
                        SetTimeout(60000,function() vRPclient._removeBlip(player,policia[id]) idgens:free(id) end)
                    end)
                end
            end
            TriggerClientEvent("Notify",source,"sucesso","Localização enviada com sucesso.", 5)
            vRPclient._playSound(source,"Event_Message_Purple","GTAO_FM_Events_Soundset")
        end
    end
end)

function src.qthP()
	local user_id = vRP.getUserId(source)
    local uplayer = vRP.getUserSource(user_id)
    local identity = vRP.getUserIdentity(user_id)
    local x,y,z = vRPclient.getPosition(source)
    if vRPclient.getHealth(source) > 100 then
        if vRP.hasPermission(user_id,"perm.policia") then
            local soldado = vRP.getUsersByPermission("perm.policia")
            for l,w in pairs(soldado) do
                local player = vRP.getUserSource(parseInt(w))
                if player and player ~= uplayer then
                    async(function()
                        local id = idgens:gen()
                        policia[id] = vRPclient.addBlip(player,x,y,z,153,84,"Localização de "..identity.nome.." "..identity.sobrenome,0.5,false)
                        TriggerClientEvent("Notify",player,"importante","Localização recebida de <b>"..identity.nome.." "..identity.sobrenome.."</b>.")
                        vRPclient._playSound(player,"Out_Of_Bounds_Timer","DLC_HEISTS_GENERAL_FRONTEND_SOUNDS")
                        SetTimeout(60000,function() vRPclient.removeBlip(player,policia[id]) idgens:free(id) end)
                    end)
                end
            end
            TriggerClientEvent("Notify",source,"sucesso","Localização enviada com sucesso.", 5)
            vRPclient._playSound(source,"Event_Message_Purple","GTAO_FM_Events_Soundset")
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFICAO DE DISPARO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.sendLocationFire(x,y,z)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if not vRP.hasPermission(user_id, "perm.policia") then
			vCLIENT.sendAlertPolice(source, x,y,z, "Disparos", "Um novo registro de disparos foi registrado.")
		end
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE REDUZIR PENA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.reduzirPrisao(reduzir)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local value = vRP.getUData(parseInt(user_id), "vRP:prisao")
        local tempo = json.decode(value) or 0
        if tempo > 0 then
            vRP.setUData(user_id,"vRP:prisao", json.encode(tonumber(tempo-reduzir)))
            TriggerClientEvent("Notify",source,"sucesso","Parabens! Você acabou de reduzir <b>"..reduzir.." mes(es)</b> de sua prisão, agora restam <b>"..tempo-reduzir.."</b> meses.", 5)
        end
    end
end

function src.checkTempoPrisao()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local value = vRP.getUData(parseInt(user_id), "vRP:prisao")
        local tempo = json.decode(value) or 0
        return tonumber(tempo)
    end
end

function src.blockCommands(tempo)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        vRP.blockCommands(user_id, tempo)
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Sistema de ficha criminal
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.infoUser(user)
	local source = source 
	if user then
		local identity = vRP.getUserIdentity(parseInt(user))
		local infos = vRP.query("vRP/get_user_identity",{ user_id = user })
		local criminal = json.decode(infos[1].criminal)
		local prisoes = 0
		local avisos = 0

		for k,v in pairs(criminal) do 
			if v.tipo == "PRISAO" then
				prisoes = prisoes + 1
			end

			if v.tipo == "MULTA" then
				avisos = avisos + 1
			end
		end

		if identity then
			return infos[1].multas or 0,identity.nome,identity.sobrenome,identity.registro,parseInt(identity.idade),prisoes,avisos
		end
	end
end

function src.arrestsUser(user)
	local source = source
	if user then
		local infos = vRP.query("vRP/get_user_identity",{ user_id = user })
		local criminal = json.decode(infos[1].criminal)
		local arrest = {}
		if infos then
			for k,v in pairs(criminal) do
				if v.tipo == "PRISAO" then
					table.insert(arrest,{ data = os.date("%d/%m/%Y", k), value = v.tempo, info = v.motivo, officer = v.officer })
				end
			end
			return arrest
		end
	end 
end

function src.ticketsUser(user)
	local source = source
	if user then
		local infos = vRP.query("vRP/get_user_identity",{ user_id = user })
		local criminal = json.decode(infos[1].criminal)
		local ticket = {}
		if infos then
			for k,v in pairs(criminal) do
				if v.tipo == "MULTA" then
					table.insert(ticket,{ data = os.date("%d/%m/%Y", k), value = v.tempo, info = v.motivo, officer = v.officer })
				end
			end
			return ticket
		end
	end
end

function src.checkPermission()
	local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"perm.policia") or vRP.hasPermission(user_id,"perm.advogado") then
		return true
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTROS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerSpawn",function(user_id, source, first_spawn)
	local user_id = vRP.getUserId(source)
	if user_id then
		SetTimeout(15*1000, function()
			local value = vRP.getUData(parseInt(user_id), "vRP:prisao")
			local tempo = json.decode(value) or 0
			if tonumber(tempo) > 0 then
				vRPclient._teport(source, 1679.09,2514.52,45.57)
				prison_lock(parseInt(user_id))
				vCLIENT.prisioneiro(source, true)
				vCLIENT.setarRoupasPrisional(source)
			end
		end)
	end
end)

AddEventHandler("vRP:playerLeave",function(user_id, player)
	if user_id then
		if tempoPrisao[user_id] ~= nil then
			TriggerClientEvent('chatMessage', -1, 'PRISÃO', { 0, 0, 0 }, '^0 O ^3'.. GetPlayerName(player) ..' ^0 tentou escapar do transporte para a prisao e foi pego.')
			vRP.setUData(user_id,"vRP:prisao",json.encode(tonumber(tempoPrisao[user_id]+10)))
			tempoPrisao[user_id] = nil
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k,v in pairs(segundos) do
			if v > 0 then
				segundos[k] = v - 1
			end

			if segundos[k] == 0 then
				segundos[k] = nil
			end
		end
	end
end)

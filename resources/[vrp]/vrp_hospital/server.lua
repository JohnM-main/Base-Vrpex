local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_hospital",src)
Proxy.addInterface("vrp_hospital",src)

vCLIENT = Tunnel.getInterface("vrp_hospital")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UNIZK EQUIPAMENTOS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local unizk_equipamentos = {}
local segundos = {}

unizk_equipamentos["1. Paramédico"] = {function(source,choice)
	local user_id = vRP.getUserId(source)
	local sexo = vCLIENT.checkSexo(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id ~= nil and not segundos[user_id] and segundos[user_id] == nil then
        segundos[user_id] = 5

		vRP.colocarFarda(user_id, "Paramedico [".. sexo .."]")

		limparItems(user_id)
		vRPclient._giveWeapons(source, { ["WEAPON_STUNGUN"] = {ammo=1} }, true)
		vRP.giveInventoryItem(user_id, "radio", 1, true)

		vRP.setPatrulhamento(user_id)
		TriggerClientEvent("vrp_blipsystem:serviceEnter",source,"Unizk",26)
		
		vRP.sendLog("BATERPONTOHOSPITAL", "```css\n** BATER PONTO **\n"..os.date("[%d/%m/%Y as %X]").." O Medico(a) ["..identity.nome ..identity.sobrenome.." ("..user_id..")] acabou de entrar em expediente. ```")
	end
end}

unizk_equipamentos["2. Sair"] = {function(source,choice)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
    if user_id ~= nil and not segundos[user_id] and segundos[user_id] == nil then
        segundos[user_id] = 5

		vRPclient._giveWeapons(source, {}, true)
		vRP.removerFarda(user_id)
        vRP.removePatrulhamento(user_id)
		limparItems(user_id)
		TriggerClientEvent("vrp_blipsystem:serviceExit",source)
		
		vRP.sendLog("BATERPONTOHOSPITAL", "```css\n** BATER PONTO **\n"..os.date("[%d/%m/%Y as %X]").." O Medico(a) ["..identity.nome ..identity.sobrenome.." ("..user_id..")] acabou de sair em expediente.```")
	end
end}


function limparItems(id)
	vRP.tryGetInventoryItem(id, "radio", vRP.getInventoryItemAmount(id, "radio"), true)
end

vRP._addStaticMenuChoices("unizk_equipamentos", unizk_equipamentos)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local tentativas = {}
RegisterCommand('re',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"perm.unizk") then 
	if user_id ~= nil then
		local nplayer = vRPclient.getNearestPlayer(source,5)
		if nplayer then
			local nuser_id = vRP.getUserId(nplayer)
			if vRPclient.isInComa(nplayer) then
				if tentativas[tonumber(nuser_id)] == nil then tentativas[tonumber(nuser_id)] = 0 end
				local chance = math.random(100)

				if tentativas[tonumber(nuser_id)] >= 0 then
					if chance >= 50 then
						tentativas[tonumber(nuser_id)] = 0
						TriggerClientEvent("Notify",nplayer,"sucesso","Você está com <b>pulsação</b>, aguarde o medicamento fazer efeito.", 5)
						TriggerClientEvent("Notify",source,"sucesso","O Cidadão está com <b>pulsação</b>, realizando tratamento.", 5)
						vRP.blockCommands(source, 13)

						SetTimeout(3*1000, function()  
							vRPclient._playAnim(source, false,{{"mini@cpr@char_a@cpr_def","cpr_intro"}},true)
							SetTimeout(10*1000, function()  
								vRPclient._stopAnim(source, false)
								vRPclient._setHealth(nplayer, 110)
							end)
						end)
					else
						tentativas[tonumber(nuser_id)] = 1 + tentativas[tonumber(nuser_id)]
						if tentativas[tonumber(nuser_id)] >= 2 then
							TriggerClientEvent("Notify",source,"negado","O Cidadão acabou <b>morrendo</b> pois não aguentou os ferimentos.", 5)
							TriggerClientEvent("Notify",nplayer,"negado","Você não resistiu aos <b>ferimentos</b>", 5)
							vRPclient._setComa(nplayer, 15)
							tentativas[tonumber(nuser_id)] = -1
							
							SetTimeout(15*1000, function()  
								vRPclient._killPlayer(nplayer)
								tentativas[tonumber(nuser_id)] = 0
							end)
						else
							TriggerClientEvent("Notify",source,"negado","O Cidadão está sem <b>pulsação</b>, tente novamente.", 5)
							TriggerClientEvent("Notify",nplayer,"negado","Você está sem <b>pulsação</b>, o medico ira tentar novamente pela ultima vez", 5)
						end
					end
				else
					TriggerClientEvent("Notify",source,"negado","O Cidadão está <b>morto</b>.", 5)
				end
			else
			  TriggerClientEvent("Notify",source,"negado","Este jogador não esta em coma.", 3)
			end
		else
			TriggerClientEvent("Notify",source,"negado","Nenhum jogador proximo.", 5)
		end
	end
end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MENUS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--[[vRP._registerMenuBuilder("unizk_menu", function(add, data)
	local user_id = vRP.getUserId(data.player)
	if user_id then
		local choices = {}
		choices["1. Primeiro Socorros"] = choice_primeiroSocorros
		choices["2. Carregar Paciente"] = choice_carregarPaciente
		choices["3. Soltar Paciente"] = choice_soltarPaciente
		choices["4. Colocar no Veiculo"] = choice_colocarPaciente
		choices["5. Tirar do Veiculo"] = choice_tirarPaciente
		add(choices)
	end
end)]]

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  CONTADOR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  SISTEMA DE MACA HOSPITAL
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.checkUNZIK()
	local unizk = vRP.getUsersByPermission("perm.unizk")
	local count = 0
	
	for k,v in pairs(unizk) do
		if vRP.checkPatrulhamento(parseInt(v)) then
			count = count + 1
		end
 	end
	 
	if count > 0 then
		return true
	else
		return false
	end
end

function src.checkTratamento()
	local source = source
	local user_id = vRP.getUserId(source)
	local nplayer = vRPclient.getNearestPlayer(source, 5)
	local nuser_id = vRP.getUserId(nplayer)
	if nplayer then
		local deitado,tratamento = vCLIENT.checkPaciente(nplayer)
		if deitado then
			if not tratamento then
				if vRP.hasPermission(user_id, "perm.unizk") then
					if vRP.tryFullPayment(nuser_id, 3000) then
						vRP.giveMoney(user_id, 3000)
						vCLIENT.iniciarTratamento(nplayer)
						vRP.blockCommands(nuser_id, 59)
						return true
					else
						TriggerClientEvent("Notify",source,"negado","Este paciente não possui dinheiro.", 5)
					end
				else
					TriggerClientEvent("Notify",source,"negado","Você não está em expediente para realizar o tratamento.", 5)
				end
			else
				TriggerClientEvent("Notify",source,"negado","Este paciente ja esta em tratamento.", 5)
			end
		else
			TriggerClientEvent("Notify",source,"negado","Nenhum paciente deitado na maca.", 5)
		end
	else
		TriggerClientEvent("Notify",source,"negado","Nenhum jogador proximo.", 5)
	end
end

function src.blockCommands(segundos)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.blockCommands(user_id, segundos)
	end
end
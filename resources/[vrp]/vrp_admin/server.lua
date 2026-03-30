local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_admin",src)
Proxy.addInterface("vrp_admin",src)

vCLIENT = Tunnel.getInterface("vrp_admin")

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local cfgGroups = module("cfg/groups")
local groups = cfgGroups.groups

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE EXPEDIENTE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local aExpediente = {
	{ ['grupo1'] = "admin", ['grupo2'] = "adminoff"},
	{ ['grupo1'] = "moderador", ['grupo2'] = "moderadoroff"},
	{ ['grupo1'] = "suporte", ['grupo2'] = "suporteoff"}
}

RegisterCommand('exp',function(source,args,rawCommand)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		for k,v in pairs(aExpediente) do
			if args[1] == "entrar" then 
				if vRP.hasGroup(user_id, v.grupo2) then
					vRP.addUserGroup(user_id, v.grupo1)
					TriggerClientEvent("Notify",source,"sucesso","[STAFF] Você entrou em Expediente.", 5)
					vRP.sendLog("BATERPONTOADMIN", "```css\n** BATER PONTO **\n"..os.date("[%d/%m/%Y as %X]").." ["..string.upper(v.grupo1).."] O(a) ["..identity.nome.." " ..identity.sobrenome.." ("..user_id..")] acabou de entrar em expediente.```")
				end
			elseif args[1] == "sair" then
				if vRP.hasGroup(user_id, v.grupo1) then
					vRP.addUserGroup(user_id, v.grupo2)
					TriggerClientEvent("Notify",source,"negado","[STAFF] Você saiu do Expediente.", 5)
					vRP.sendLog("BATERPONTOADMIN", "```css\n** BATER PONTO **\n"..os.date("[%d/%m/%Y as %X]").." ["..string.upper(v.grupo1).."] O(a) ["..identity.nome.. " " ..identity.sobrenome.." ("..user_id..")] acabou de sair em expediente.```")
				end
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ADD CAR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare("vrp/add_vehicle","INSERT IGNORE INTO vrp_user_veiculos(user_id,veiculo,placa,ipva) VALUES(@user_id,@veiculo,@placa,@ipva)")
RegisterCommand('addcar',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local nplayer = vRP.getUserId(parseInt(args[2]))
    if vRP.hasPermission(user_id,"admin.permissao") then
        if args[1] and args[2] then
            local nuser_id = vRP.getUserId(nplayer)
            local identity = vRP.getUserIdentity(user_id)
            local identitynu = vRP.getUserIdentity(nuser_id)
			local placa = vRP.gerarPlaca()
            vRP.execute("vrp/add_vehicle",{ user_id = parseInt(args[2]), veiculo = args[1], placa = placa, ipva = parseInt(os.time()) }) 
            TriggerClientEvent("Notify",source,"sucesso","Voce adicionou o veículo <b>"..args[1].."</b> para o Passaporte: <b>"..parseInt(args[2]).."</b>.") 
        end
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- REM CAR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare("vrp/rem_vehicle","DELETE FROM vrp_user_veiculos WHERE user_id = @user_id AND veiculo = @veiculo")
RegisterCommand('remcar',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local nplayer = vRP.getUserId(parseInt(args[2]))
    if vRP.hasPermission(user_id,"admin.permissao") then
        if args[1] and args[2] then
            local nuser_id = vRP.getUserId(nplayer)
            local identity = vRP.getUserIdentity(user_id)
            local identitynu = vRP.getUserIdentity(nuser_id)
			local placa = vRP.gerarPlaca()
            vRP.execute("vrp/rem_vehicle",{ user_id = parseInt(args[2]), veiculo = args[1], placa = placa, ipva = parseInt(os.time())  }) 
            TriggerClientEvent("Notify",source,"sucesso","Voce removeu o veículo <b>"..args[1].."</b> do Passaporte: <b>"..parseInt(args[2]).."</b>.") 
        end
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RG2
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('rg2',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") then
        local nuser_id = parseInt(args[1])
        local identity = vRP.getUserIdentity(nuser_id)
        local bankMoney = vRP.getBankMoney(nuser_id)
        local walletMoney = vRP.getMoney(nuser_id)
		local nsource = vRP.getUserSource(nuser_id)

		if source then
			TriggerClientEvent("Notify",source,"importante","ID: <b>"..parseInt(nuser_id).." (ONLINE)</b><br>Nome: <b>"..identity.nome.." "..identity.sobrenome.."</b><br>Idade: <b>"..identity.idade.."</b><br>Telefone: <b>"..identity.telefone.."</b><br>Banco: <b>"..vRP.format(parseInt(identity.banco)).."</b><br>Sets: <b>"..json.encode(vRP.getUserDataTable(nuser_id).groups).."</b>", 5)    
		else
			TriggerClientEvent("Notify",source,"importante","ID: <b>"..parseInt(nuser_id).." (OFFLINE)</b><br>Nome: <b>"..identity.nome.." "..identity.sobrenome.."</b><br>Idade: <b>"..identity.idade.."</b><br>Telefone: <b>"..identity.telefone.."</b><br>Banco: <b>"..vRP.format(parseInt(identity.banco)).."</b><br>Sets: <b>"..json.encode(vRP.getUData(nuser_id,"vRP:datatable").groups).."</b>", 5)    
		end
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRYDELETEPED
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("trydeleteped")
AddEventHandler("trydeleteped",function(index)
	TriggerClientEvent("syncdeleteped",-1,index)
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ARMA ADM
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('w',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
    if user_id then
		if args[1] == "armas" and vRP.hasPermission(user_id,"admin.permissao") then
			vRPclient._giveWeapons(source,{["WEAPON_HEAVYSNIPER_MK2"] = { ammo = 250 }})
			vRPclient._giveWeapons(source,{["WEAPON_PISTOL_MK2"] = { ammo = 250 }})
			vRPclient._giveWeapons(source,{["WEAPON_ASSAULTRIFLE_MK2"] = { ammo = 250 }})
			vRPclient._giveWeapons(source,{["WEAPON_SPECIALCARBINE_MK2"] = { ammo = 250 }})
		elseif args[1] == "limpar" and vRP.hasPermission(user_id,"admin.permissao") then
			vRPclient._giveWeapons(source,{},true)
		elseif vRP.hasPermission(user_id,"admin.permissao") then
			TriggerClientEvent("Notify",source,"negado","Armamento não encontrado.")
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRYDELETEOBJ
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("trydeleteobj")
AddEventHandler("trydeleteobj",function(index)
	TriggerClientEvent("syncdeleteobj",-1,index)
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE PRISAO ADMIN
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('prenderadm',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
	local idPlayer = vRP.prompt(source, "Digite o ID:", "")
		if tonumber(idPlayer) then
			local nplayer = vRP.getUserSource(tonumber(idPlayer))
			local tempoPrisao = vRP.prompt(source, "Digite o tempo da prisão", "")
			if tonumber(tempoPrisao) then
				local motivoPrisao = vRP.prompt(source, "Digite o motivo da prisão", "")
				if motivoPrisao ~= nil and motivoPrisao ~= "" then
					local nidentity = vRP.getUserIdentity(tonumber(idPlayer))
					if nidentity then
					--	TriggerClientEvent('chatMessage', -1, 'PRISÃO ADM', { 0, 0, 0 }, '^0 O ^3'.. nidentity.nome ..' '.. nidentity.sobrenome..' ^0 foi preso(a) por ^3'.. tonumber(tempoPrisao) ..' ^0minutos ^0 pelo motivo: ^3 '.. motivoPrisao)
						TriggerClientEvent('chatMessage', nplayer, 'PRISÃO ADM', { 0, 0, 0 }, '^0Você foi preso pelo admin: ^4['..user_id..']^0.')
						vRPclient._teleport(nplayer, 1641.54,2570.48,45.56)
						prison_lock_adm(tonumber(idPlayer))
						TriggerClientEvent('prisaoADM',nplayer,true)
						vRP.setUData(tonumber(idPlayer),"vRP:prisao:ADM", json.encode(tonumber(tempoPrisao)))
						vRP.sendLog("PRENDERADM", "O ADMIN "..user_id.." PRENDEU O ID: "..idPlayer.."PELO MOTIVO: "..motivoPrisao)
					end
				else
					TriggerClientEvent("Notify",source,"negado","Digite o Motivo corretamente.",5)
				end
			else
				TriggerClientEvent("Notify",source,"negado","Digite o Tempo de Prisão corretamente.",5)
			end
		else
			TriggerClientEvent("Notify",source,"negado","Digite o ID corretamente.",5)
		end
	end
end)

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PRISÃO ADM
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	local player = vRP.getUserSource(parseInt(user_id))
	if player then
		SetTimeout(30000,function()
			local value = vRP.getUData(parseInt(user_id),"vRP:prisao:ADM")
			local tempo = json.decode(value) or 0
				if tonumber(tempo) > 0 then
					TriggerClientEvent('prisaoADM',player,true)
					vRPclient._teleport(player, 1641.54,2570.48,45.56)
					prison_lock_adm(parseInt(user_id))
				end
		end)
	end
end)

function prison_lock_adm(target_id)
	local player = vRP.getUserSource(parseInt(target_id))
	if player then
		SetTimeout(60000,function()
			local value = vRP.getUData(parseInt(target_id),"vRP:prisao:ADM")
			local tempo = json.decode(value) or 0
			if parseInt(tempo) >= 1 then
				TriggerClientEvent('chatMessage', player, 'PRISAO ADM', { 0, 0, 0 }, '^0Você Ainda vai passar ^5'..parseInt(tempo)..'M^0 preso.')
				vRP.setUData(parseInt(target_id),"vRP:prisao:ADM",json.encode(parseInt(tempo)-1))
				prison_lock_adm(parseInt(target_id))
				vRPclient._setHealth(player,300)
--[[ 				vRP.setHunger(parseInt(target_id), 0)
				vRP.setThirst(parseInt(target_id), 0) ]]
			elseif parseInt(tempo) == 0  or parseInt(tempo) == -1 then
				TriggerClientEvent('prisaoADM',player,false)
				vRPclient._teleport(player, -1038.07,-2738.83,13.81)
				vRP.setUData(parseInt(target_id),"vRP:prisao:ADM",json.encode(-1))
			end
		end)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FIX
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('fix',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") then
		local vehicle = vRPclient.getNearestVehicle(source,7)
		if vehicle then
			TriggerClientEvent('reparar',source,vehicle)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FIX
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('fixvip',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id, "perm.fix") then
		local vehicle = vRPclient.getNearestVehicle(source,7)
		if vehicle then
			TriggerClientEvent('reparar',source,vehicle)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- STATUS 2
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('status2',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local mensagem = ""
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"perm.policia") or vRP.hasPermission(user_id,"suporte.permissao") then
		if user_id then

			--[[ ADMINISTRADOR ]]
			local admin = vRP.getUsersByPermission("admin.permissao")
			local adminTotal = ""
			for k,v in pairs(admin) do
				adminTotal = adminTotal.. parseInt(v)..","
			end
			if adminTotal == "" then adminTotal = "Nenhum(a)" end
			mensagem = mensagem.."<br><br> <b>👑 IDS de Admin em Serviço: </b>"..adminTotal

			--[[ MODERADOR ]]
			local moderador = vRP.getUsersByPermission("moderador.permissao")
			local moderadorTotal = ""
			for k,v in pairs(moderador) do
				moderadorTotal = moderadorTotal.. parseInt(v)..","
			end
			if moderadorTotal == "" then moderadorTotal = "Nenhum(a)" end
			mensagem = mensagem.."<br><b>🛡️ IDS de Moderador em Serviço: </b>"..moderadorTotal

			--[[ SUPORTE ]]
			local suporte = vRP.getUsersByPermission("suporte.permissao")
			local suporteTotal = ""
			for k,v in pairs(suporte) do
				suporteTotal = suporteTotal.. parseInt(v)..","
			end
			if suporteTotal == "" then suporteTotal = "Nenhum(a)" end
			mensagem = mensagem.."<br><b>📑 IDS de Suporte em Serviço: </b>"..suporteTotal

			--[[ STAFF FORA DE SERVICO ]]
			local adminFora = vRP.getUsersByPermission("staffoff.permissao")
			local adminForaTotal = ""
			for k,v in pairs(adminFora) do
				adminForaTotal = adminForaTotal.. parseInt(v)..","
			end
			if adminForaTotal == "" then adminForaTotal = "Nenhum(a)" end
			mensagem = mensagem.."<br><b>👑 IDS de STAFFs fora de Serviço: </b>"..adminForaTotal

			--[[ POLICIAIS ]]
			local policiais = vRP.getUsersByPermission("perm.policia")
			local totalPolicia = ""
			for k,v in pairs(policiais) do
				totalPolicia = totalPolicia.. parseInt(v)..","
			end
			if totalPolicia == "" then totalPolicia = "Nenhum(a)" end
			mensagem = mensagem.."<br><br> <b>👮 IDS de Policiais: </b>"..totalPolicia

			local totalPoliciaPtr = ""
			for k,v in pairs(policiais) do
				local patrulhamento = vRP.checkPatrulhamento(parseInt(v))
				if patrulhamento then
					totalPoliciaPtr = totalPoliciaPtr.. parseInt(v)..","
				end
			end
			if totalPoliciaPtr == "" then totalPoliciaPtr = "Nenhum(a)" end
			mensagem = mensagem.."<br> <b>👮 IDS de Policiais em PTR: </b>"..totalPoliciaPtr

			--[[ UNIZK ]]
			local unizk = vRP.getUsersByPermission("perm.unizk")
			local unizkTotal = ""
			for k,v in pairs(unizk) do
				unizkTotal = unizkTotal.. parseInt(v)..","
			end
			if unizkTotal == "" then unizkTotal = "Nenhum(a)" end
			mensagem = mensagem.."<br><br> <b>⛑️ IDS de HOSPITAL: </b>"..unizkTotal

			local totalUnizkPtr = ""
			for k,v in pairs(unizk) do
				local patrulhamento = vRP.checkPatrulhamento(parseInt(v))
				if patrulhamento then
					totalUnizkPtr = totalUnizkPtr.. parseInt(v)..","
				end
			end
			if totalUnizkPtr == "" then totalUnizkPtr = "Nenhum(a)" end
			mensagem = mensagem.."<br> <b>⛑️ IDS de HOSPITAL em PTR: </b>"..totalUnizkPtr

			--[[ MECANICO ]]
			local mec = vRP.getUsersByPermission("perm.rocket")
			local mecTotal = ""
			for k,v in pairs(mec) do
				mecTotal = mecTotal.. parseInt(v)..","
			end
			if mecTotal == "" then mecTotal = "Nenhum(a)" end
			mensagem = mensagem.."<br><br> <b>🔧 IDS de MECANICO: </b>"..mecTotal

			local totalMecPtr = ""
			for k,v in pairs(mec) do
				local patrulhamento = vRP.checkPatrulhamento(parseInt(v))
				if patrulhamento then
					totalMecPtr = totalMecPtr.. parseInt(v)..","
				end
			end
			if totalMecPtr == "" then totalMecPtr = "Nenhum(a)" end
			mensagem = mensagem.."<br> <b>🔧 IDS de MECANICO em PTR: </b>"..totalMecPtr

			local onlinePlayers = GetNumPlayerIndices()
			mensagem = mensagem.."<br><br> <b>🏘️ Total de jogadores Online: </b>"..onlinePlayers

			TriggerClientEvent("Notify",source,"importante","<b>Mirtin Base:</b>"..mensagem, 20)
		end
	end
end)


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PFARDA
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('pfarda',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") then
		local custom = vRPclient.getCustomization(source,{})
		local content = ""
		for k,v in pairs(custom) do
			if tonumber(k) == 1 or tonumber(k) == 3 or tonumber(k) == 4 or tonumber(k) == 6 or tonumber(k) == 7 or tonumber(k) == 8 or tonumber(k) == 9 or tonumber(k) == 11 or k == "p0" or k == "p6" then
				content = content.."\n["..k.."] = { "..json.encode(v).." }"
			end
		end
		
		vRP.prompt(source, "Farda: ", "[FARDA TAL] = { "..content.." \n} ")
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PLAYERSON
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('pon',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
        local users = vRP.getUsers()
        local players = ""
		local quantidade = 0
		
        for k,v in pairs(users) do
			players = players..k..","
            quantidade = quantidade + 1 
		end
		
        TriggerClientEvent('chatMessage',source,"TOTAL ONLINE",{255,160,0}, quantidade)
        TriggerClientEvent('chatMessage',source,"ID's ONLINE",{255,160,0}, players)
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PARTICULAR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('pm',function(source,args,rawCommand)
    local source = source
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"ticket.permissao") then
		if args[1] then
			local mensagem = vRP.prompt(source,"Mensagem:","")
			if mensagem == "" then
				return
			end
			local tplayer = vRP.getUserSource(parseInt(args[1]))

			TriggerClientEvent('chatMessage',tplayer,"(Administração)",{5, 230, 255},mensagem)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRYAREA
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('limpararea',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local x,y,z = vRPclient.getPosition(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		TriggerClientEvent("syncarea",-1,x,y,z)
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Limpar Inventario
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('clearinv',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if args[1] then
			local nplayer = vRP.getUserSource(parseInt(args[1]))
			if nplayer then
				vRP.clearInventory(parseInt(args[1]))
			end
		else
			vRP.clearInventory(user_id)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GOD
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('god',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		if args[1] then
			local nplayer = vRP.getUserSource(parseInt(args[1]))
			if nplayer then
				vRPclient._killGod(nplayer)
				vRPclient._setHealth(nplayer,300)
				vRP.sendLog("GOID", "O ID "..user_id.." usou o /god no ID "..parseInt(args[1]).."")
			end
		else
			vRPclient._killGod(source)
			vRPclient._setHealth(source,300)
			vRP.sendLog("GOD", "O ID "..user_id.." usou o /god ")
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CUFF
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('cuff',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") then
		if args[1] then
			local nplayer = vRP.getUserSource(parseInt(args[1]))
			if nplayer then
				vRPclient._toggleHandcuff(nplayer)
			end
		else
			vRPclient._toggleHandcuff(source)
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- KILL
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('kill',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if args[1] then
			local nplayer = vRP.getUserSource(parseInt(args[1]))
			if nplayer then
				vRPclient._setHealth(nplayer, 0)
				SetTimeout(1000, function()
					vRPclient._killComa(nplayer)
				end)

				vRP.sendLog("KILL", "O ID "..user_id.." usou o /kill no ID "..parseInt(args[1]).."")
			end
		else
			vRPclient._setHealth(source, 0)
			SetTimeout(1000, function()
				vRPclient._killComa(source)
			end)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Zerar fome e sede
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 RegisterCommand('zerarnec',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		if args[1] then
			local nplayer = vRP.getUserSource(parseInt(args[1]))
			if nplayer then
				vRP.setHunger(parseInt(args[1]), 0)
				vRP.setThirst(parseInt(args[1]), 0)
			end
		else
			vRP.setHunger(user_id, 0)
			vRP.setThirst(user_id, 0)
		end
	end
end) 

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PARAALL
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('parall', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		local player = vRP.getUserSource(user_id)
		if vRP.hasPermission(user_id,"admin.permissao") then
			TriggerClientEvent("nzk:giveParachute", -1)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PD
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('pd',function(source,args,rawCommand)
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local permission = "perm.policia"
		if vRP.hasPermission(user_id,permission) then
			local mec = vRP.getUsersByPermission(permission)
			for l,w in pairs(mec) do
				local player = vRP.getUserSource(parseInt(w))
				if player then
					async(function()
						TriggerClientEvent('chatMessage',player,identity.nome.." "..identity.sobrenome,{0,0,255},rawCommand:sub(3))
					end)
				end
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- HR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('hr',function(source,args,rawCommand)
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local permission = "perm.unizk"
		if vRP.hasPermission(user_id,permission) then
			local mec = vRP.getUsersByPermission(permission)
			for l,w in pairs(mec) do
				local player = vRP.getUserSource(parseInt(w))
				if player then
					async(function()
						TriggerClientEvent('chatMessage',player,identity.nome.." "..identity.sobrenome,{237,100,100},rawCommand:sub(3))
					end)
				end
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- AA
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('aa',function(source,args,rawCommand)
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
		local permission = "ticket.permissao"
		if vRP.hasPermission(user_id,permission) then
			local mec = vRP.getUsersByPermission(permission)
			for l,w in pairs(mec) do
				local player = vRP.getUserSource(parseInt(w))
				if player then
					async(function()
						TriggerClientEvent('chatMessage',player,identity.nome.." "..identity.sobrenome,{255,0,0},rawCommand:sub(3))
					end)
				end
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TPALL
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('tpall', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		local player = vRP.getUserSource(user_id)
		if vRP.hasPermission(user_id,"admin.permissao") then
			local x,y,z = vRPclient.getPosition(player,{})
			TriggerClientEvent("nzk:tpall", -1, x, y, z)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ReviveALL
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('reviveall', function(source, args, rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao") then
        local rusers = vRP.getUsers()
        for k,v in pairs(rusers) do
            local rsource = vRP.getUserSource(k)
			vRPclient._setHealth(rsource,300)
        end
    end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- REMOVER DETENCAO VEICULO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('rdet', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		local player = vRP.getUserSource(user_id)
		if vRP.hasPermission(user_id,"admin.permissao") then
			if tonumber(args[1]) and args[2] then
				vRP.execute("vRP/set_detido",{ user_id = tonumber(args[1]), vehicle = args[2], detido = 0})
				TriggerClientEvent('chatMessage', source, '^2Você removeu o veiculo '..args[2]..' do [ID: '..tonumber(args[1])..'] da detencao/retencao.')
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SPECTADE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('spec', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") then
			if tonumber(args[1]) == 0 or tonumber(args[1]) == user_id then
				vRPclient._stopSpec(source)
			else
				local nplayer = vRP.getUserSource(tonumber(args[1]))
				if nplayer then
					vRPclient._toggleSpec(source, nplayer)
				end
			end
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Deleta todos Carros
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('clearallveh', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		if vRP.hasPermission(user_id,"admin.permissao") then
			TriggerClientEvent('chatMessage', -1, "^1Administração: ^0Contagem Iniciada ^260s^0 para limpeza de veiculos. (Entre em seu veiculo para não ser removido)")
			Wait(60000)
			TriggerClientEvent("wld:delallveh", -1)
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- HASH
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('hash',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		local vehicle = vRPclient.getNearestVehicle(source,7)
		if vehicle then
			TriggerClientEvent('vehash',source,vehicle)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- HASH2
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('hash2',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		local vehicle = vRPclient.getNearestVehicle(source,7)
		if vehicle then
			vRP.prompt(source, "Hash Veiculo: ", vCLIENT.returnHashVeh(source,vehicle))
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PEGAR FUNG VEICULOS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('hveh',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") then
		local hash = vCLIENT.getStatusVehicle(source)
		local vehicleSpawn = vRP.prompt(source, "Digite o Spawn do veiculo: ", "")
		local vehicleName = vRP.prompt(source, "Digite o Nome do veiculo: ", "")
		local price = vRP.prompt(source, "Digite o valor do veiculo: ", "")
		local portamalas = vRP.prompt(source, "Digite o limite do portamalas: ", "")
		local tipo = vRP.prompt(source, "Digite a classe do veiculo: ", "sedans,suvs,imports,vip,trucks,motos,outros")

		if tonumber(price) and tonumber(portamalas) and tipo then
			vRP.prompt(source, "Informacoes do veiculo: ", '{ hash = '..hash..', name = "'..vehicleSpawn..'", price = '..price..', banido = false, modelo = "'..vehicleName..'", capacidade = '..portamalas..', tipo = "'..tipo..'" },')
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Tunning
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('tuning',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao")  then
		local vehicle = vRPclient.getNearestVehicle(source,7)
		if vehicle then
			TriggerClientEvent('vehtuning',source,vehicle)
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- WL
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('wl',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		if args[1] then
			vRP.setWhitelisted(parseInt(args[1]),true)
			TriggerClientEvent("Notify",source,"sucesso","Você Liberou o Passaporte " ..parseInt(args[1]))
			vRP.sendLog("WL", "O ID "..user_id.." adicionou o id "..parseInt(args[1]))
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UNWL
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('unwl',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		if args[1] then
			TriggerClientEvent("Notify",source,"negado","Você Retirou o Passaporte " ..parseInt(args[1]))
			vRP.setWhitelisted(parseInt(args[1]),false)
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GIVE ITEM
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('item',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if args[1] and args[2] then
			if args[1] == "money" then
				local creturn = vRP.getItemInSlot(user_id, "money", false)
				if creturn then
					vRP.giveInventoryItem(user_id,""..args[1].."",parseInt(args[2]), true, creturn)
				else
					vRP.giveInventoryItem(user_id,""..args[1].."",parseInt(args[2]), true)
				end
			else
				vRP.giveInventoryItem(user_id,""..args[1].."",parseInt(args[2]), true)
			end
			
			vRP.sendLog("ITEM", "O ID "..user_id.." givou o item "..args[1].." na quantidade de "..args[2].." x")
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GIVE ALL ITENS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('itens', function(source,args)
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.hasPermission(user_id, "admin.permissao") then
			local allItems = vRP.getAllItens()
			for k,v in pairs(allItems) do
				vRP.giveInventoryItem(user_id, k, 1, true)
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- KICK
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('kick',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		if args[1] then
			local id = vRP.getUserSource(parseInt(args[1]))
			if id then
				local motivo = vRP.prompt(source, "Digite o Motivo: ", "")
				if motivo ~= nil and motivo ~= "" then
					vRP.kick(id,"EXPULSO: "..motivo)
					vRP.sendLog("KICK", "O ADMIN "..user_id.." KICKOU O ID: "..args[1].." PELO MOTIVO: "..motivo)
				end
			else
				TriggerClientEvent("Notify",source,"negado","O Cidadão não está na cidade.",5)
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GIVE ITEM PLAYER
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('itemp',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if args[1] and args[2] and args[3] then
			local nplayer = vRP.getUserSource(parseInt(args[1]))
			if nplayer then
				TriggerClientEvent('chatMessage', source, "(ID: "..parseInt(args[1])..") Você givou o Item: "..args[2].." "..parseInt(args[3]).."x", {0, 170, 255})
				vRP.giveInventoryItem(parseInt(args[1]),""..args[2].."",parseInt(args[3]), true)
			end
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GIVE ARMOR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('col',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if args[1] then
			local nplayer = vRP.getUserSource(parseInt(args[1]))
			if nplayer then
				vRPclient._setArmour(nplayer, 100)
			end
		else
			vRPclient._setArmour(source, 100)
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MONEY
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('money',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if args[1] then
			vRP.giveMoney(user_id,parseInt(args[1]))

			vRP.sendLog("MONEY", "O ID "..user_id.." usou o /money na quantidade de "..parseInt(args[1]).."")
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NC
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('nc',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		vCLIENT._effectLGBT(source)
		vRPclient._toggleNoclip(source)
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TPCDS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('tpcds',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		local fcoords = vRP.prompt(source,"Cordenadas:","")
		if fcoords == "" then
			return
		end
		local coords = {}
		for coord in string.gmatch(fcoords or "0,0,0","[^,]+") do
			table.insert(coords,parseInt(coord))
		end
		vRPclient._teleport(source,coords[1] or 0,coords[2] or 0,coords[3] or 0)
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CDS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('cds',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		local x,y,z = vRPclient.getPosition(source)
		vRP.prompt(source,"Cordenadas:",tD(x)..","..tD(y)..","..tD(z))
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CDS2
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('cds2',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"mod.permissao") or vRP.hasGroup(user_id,"suporte") then
		local x,y,z = vRPclient.getPosition(source)
		heading = GetEntityHeading(GetPlayerPed(-1))
		vRP.prompt(source,"Cordenadas:","['x'] = "..tD(x)..", ['y'] = "..tD(y)..", ['z'] = "..tD(z))
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CDSH
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('cdsh',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		local x,y,z = vRPclient.getPosition(source)
		vRP.prompt(source,"Cordenadas:",tD(x)..","..tD(y)..","..tD(z)..","..tD(vCLIENT.myHeading(source)))
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CDSH2
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('cdsh2',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		local x,y,z = vRPclient.getPosition(source)
		vRP.prompt(source,"Cordenadas:","vec3("..tD(x)..","..tD(y)..","..tD(z).."), heading = "..tD(vCLIENT.myHeading(source)))
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CDS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('debug', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		local player = vRP.getUserSource(user_id)
		if vRP.hasPermission(user_id,"admin.permissao") then
			TriggerClientEvent("NZK:ToggleDebug", player)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GROUP
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('groupadd',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if args[1] and args[2] then
			if groups[tostring(args[2])] ~= nil then
				vRP.addUserGroup(parseInt(args[1]),args[2])
				TriggerClientEvent("Notify",source,"sucesso","Você adicionou o <b>(ID: "..parseInt(args[1])..")</b> no grupo: <b>"..args[2].."</b>", 5)
				vRP.sendLog("GROUPADD", "O ID "..user_id.." usou o setou "..parseInt(args[1]).." no grupo "..args[2].."")
			else
				TriggerClientEvent("Notify",source,"negado","Esse grupo não existe", 5)
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GROUPREM
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('grouprem',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if args[1] and args[2] then
			if groups[tostring(args[2])] ~= nil then
				vRP.removeUserGroup(parseInt(args[1]),args[2])

				TriggerClientEvent("Notify",source,"negado","Você removeu o <b>(ID: "..parseInt(args[1])..")</b> no grupo: <b>"..args[2].."</b>", 5)
				vRP.sendLog("GROUPREM", "O ID "..user_id.." removeu o grupo "..args[2].." do id "..args[1].."")
			else
				TriggerClientEvent("Notify",source,"negado","Esse grupo não existe", 5)
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DISPLAY
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local player_customs = {}
RegisterCommand('display',function(source,args,rawCommand)
	local custom = vRPclient.getCustomization(source,{})
	if custom then
		if player_customs[source] then
			player_customs[source] = nil
			vRPclient._removeDiv(source,"customization")
		else
			local content = ""
			for k,v in pairs(custom) do
				content = content..k.." => "..json.encode(v).."<br />"
			end

			player_customs[source] = true
			vRPclient._setDiv(source,"customization",".div_customization{ margin: auto; padding: 8px; width: 500px; margin-top: 80px; background: black; color: white; font-weight: bold; ", content)
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TPTOME
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('tptome',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao")  then
		if args[1] then
			local tplayer = vRP.getUserSource(parseInt(args[1]))
			local x,y,z = vRPclient.getPosition(source)
			if tplayer then
				vRPclient._teleport(tplayer,x,y,z)

				vRP.sendLog("TPTOME", "O ID "..user_id.." puxou o id "..parseInt(args[1]))
			end
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TPTO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('tpto',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		if args[1] then
			local tplayer = vRP.getUserSource(parseInt(args[1]))
			if tplayer then
				vRPclient._teleport(source,vRPclient.getPosition(tplayer))

				vRP.sendLog("TPTO", "O ID "..user_id.." teleportou ate o id "..parseInt(args[1]))
			end
		end
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TPWAY
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('tpway',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
		TriggerClientEvent('tptoway',source)

		vRP.sendLog("TPWAY", "O ID "..user_id.." usou o /tpway")
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DELNPCS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('car',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if args[1] then
			TriggerClientEvent('spawnarveiculo12',source,args[1])
			vRP.sendLog("SPAWNCAR", "O ID "..user_id.." spawnou o veiculo "..args[1])
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Copy Preset
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('copypreset',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if tonumber(args[1]) then
			local nsource = vRP.getUserSource(tonumber(args[1]))
			if nsource then
				local ncustom = vRPclient.getCustomization(nsource, {})
				vRPclient._setCustomization(source, ncustom)
				vRP.sendLog("COPYPRESET", "O Admin "..user_id.. " copiou as customização do id "..tonumber(args[1]))
			else
				TriggerClientEvent("Notify",source,"negado","Este ID não se encontra online no momento.", 5)
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Set Preset
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('setpreset',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		if tonumber(args[1]) then
			local nsource = vRP.getUserSource(tonumber(args[1]))
			if nsource then
				local custom = vRPclient.getCustomization(source, {})
				vRPclient._setCustomization(nsource, custom)
				vRP.sendLog("SETPRESET", "O Admin "..user_id.. " setou as customização dele no id "..tonumber(args[1]))
			else
				TriggerClientEvent("Notify",source,"negado","Este ID não se encontra online no momento.", 5)
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DELNPCS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('delnpcs',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id,"admin.permissao") then
		TriggerClientEvent('delnpcs',source)
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ADM
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('aadm',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao") then
        local mensagem = vRP.prompt(source,"Mensagem:","")
        if mensagem == "" then
            return
        end

		TriggerClientEvent("Notify",-1,"sucesso",mensagem.."<br><b>Mensagem enviada por:</b> Governador", 60)
		SendWebhookMessage(webhooknotify,"```ini\n[ID]: "..user_id.."\n[MSG]: "..mensagem.." "..os.date("\n[DATA]: %d/%m/%Y [HORA]: %H:%M:%S").." \r```")
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- /ff
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('ff',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"perm.policia") then
        local mensagem = vRP.prompt(source,"Mensagem:","")
        if mensagem == "" then
            return
        end

		TriggerClientEvent("Notify",-1,"sucesso",mensagem.."<br><b>Mensagem enviada por:</b> Policial", 10)
		SendWebhookMessage(webhooknotify,"```ini\n[ID]: "..user_id.."\n[MSG]: "..mensagem.." "..os.date("\n[DATA]: %d/%m/%Y [HORA]: %H:%M:%S").." \r```")
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONSULTAR ID
----------------------------------------------------------------------------------------------------------------------------------------
local permitido = {}

RegisterCommand('consultar', function(source,args)    
    if source == 0 then
        permitido[source] = true
    else
        if vRP.hasPermission(vRP.getUserId(source), "admin.permissao") then
            permitido[source] = true
        end
    end

    if permitido[source] then
        local mensagem = ""
        if tonumber(args[1]) then
            local idPlayer = tonumber(args[1])
            local identity = vRP.getUserIdentity(idPlayer)
            
            if identity then
				
				mensagem = mensagem.. "\n**Conta: **\n```cs\nID: "..identity.user_id.."\nNome: "..identity.nome.." "..identity.sobrenome.." "..identity.idade.."\nRegistro: "..identity.registro.."\nTelefone: "..identity.telefone.."```"

                local infoUser = vRP.query("vRP/get_all_users",{ id = idPlayer })
                if infoUser[1] then
                    local ultimologin = infoUser[1].ultimo_login
                    local ip = infoUser[1].ip
                    local whitelist = infoUser[1].whitelist
                    local banido = infoUser[1].banido
                    local motivobanido = infoUser[1].Motivo_BAN

                    if banido then
                        banido = "Sim ["..motivobanido.."]"
                    else
                        banido = "Não"
                    end

                    if whitelist then
                        whitelist = "Sim"
                    else
                        whitelist = "Não"
                    end

					mensagem = mensagem.. "\n**Info-Conta**```cs\nUltimo Login: "..ultimologin.."\nIP: "..ip.."\nWhitelist: "..whitelist.."\nBanido: "..banido.." ```"
                end

			
               
                local licenses = vRP.query("vRP/get_all_licenses",{ user_id = idPlayer }) or nil
                if #licenses > 0 then
					local msgLicences = ""
					mensagem = mensagem.."\n**Licenças:**\n"
                    for k,v in pairs(licenses) do
						msgLicences = msgLicences..""..v.identifier.."\n"
                    end

					mensagem = mensagem.."```cs\n"..msgLicences.."```"
                end

				if identity then
					local banco = identity.banco
					local total = identity.banco
					mensagem = mensagem.. "\n **Dinheiro** ```cs\nCarteira: EM BREVE\nBanco: "..vRP.format(banco).."\nTotal: "..vRP.format(total).."   ```"
				end
   

                local table = vRP.getUData(idPlayer, "vRP:datatable") 
                local userTable = json.decode(table) or nil
                if userTable then
					mensagem = mensagem.. "\n**Pessoais**```cs\nVida: "..userTable.health.."\nColete: "..userTable.colete.."\nFome: "..parseInt(userTable.hunger).." %\nSede: "..parseInt(userTable.thirst).." % \nArmas Equipadas: "..json.encode(userTable.weapons).."\nInventario: "..json.encode(userTable.inventory).."\nGrupos: "..json.encode(userTable.groups).."\nPosição: "..tD(userTable.position.x)..","..tD(userTable.position.y)..","..tD(userTable.position.z).."  ```"
                end

				mensagem = mensagem.."\n**Veiculos**"
                local veh = vRP.query("vRP/get_Veiculos", {user_id = idPlayer}) or nil
                if #veh > 0 then
                    for k,v in pairs(veh) do
						mensagem = mensagem.."```cs\nNome: "..string.upper(v.veiculo).." • Porta Malas: "..v.portamalas.." ```"
                    end
                else
					mensagem = mensagem.."```cs\nNão possui veiculos```"
                end

				--[[ mensagem = mensagem.."\n**Propriedades**"
                local propriedades = vRP.query("mirtin/selectProprietario",{ proprietario = idPlayer })
                if #propriedades > 0 then
                    for k,v in pairs(propriedades) do
						mensagem = mensagem.. "```cs\nID: "..v.houseID.." • Bau: "..v.bau.."```"
                    end
                else
					mensagem = mensagem.. "```cs\nNão possui propriedades```"
                end ]]
				
				sendToDiscord("https://discord.com/api/webhooks/920802107324522527/Ej78pYh2oMMqRsYRBSB-SZ1kkOeRa4-LnZBGo_QCJ57BGetFHhYKpipoKRw7dXNmocHq", 6356736, "Sistema de Consultas", mensagem, "© Paris Roleplay")
            end
        end

        permitido[source] = nil
    end
end)


function sendToDiscord(weebhook, color, name, message, footer)
	local embed = { { ["color"] = color, ["title"] = "**".. name .."**", ["description"] = message, ["footer"] = { ["text"] = footer, }, } }
	PerformHttpRequest(weebhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

function tD(n)
    n = math.ceil(n * 100) / 100
    return n
end

-- TYPES
-- license: • license2: • xbl: • live: • ip: • steam: • discord:
----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
-- KICKAR QUEM ENTRA SEM ID
----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('kickbugados',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao")then
        TriggerClientEvent('MQCU:bugado',-1)
    end
end)

RegisterServerEvent("MQCU:bugado")
AddEventHandler("MQCU:bugado",function()
    local user_id = vRP.getUserId(source)
    if user_id == nil then
        local identifiers = GetPlayerIdentifiers(source)
        DropPlayer(source,"Hoje não.")
        identifiers = json.encode(identifiers)
        print("Player bugado encontrado: "..identifiers)
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------
-- DERRUBAR JOGADOR NO CHAO
----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('ney',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if user_id then
        if vRP.hasPermission(user_id,"admin.permissao") then
            if args[1] then
                local nplayer = vRP.getUserSource(parseInt(args[1]))
                if nplayer then
                    TriggerClientEvent('derrubarwebjogador',nplayer,args[1])
                end
            end
        end
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------
-- CAR SEAT
----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('carseat',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao") then
        TriggerClientEvent('SetarDentroDocarro',source)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE CHAMADOS ADMIN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local weebhook = "https://discord.com/api/webhooks/898794545234456626/KpjY5KzB1UhyE2x6UbGCEeWdq6dw2rCEh_pCa43qLduy3ByJBx1jMmhDsUpGSM-Hed29"

vRP.prepare("mirtin_chamados/getUser", "SELECT * FROM mirtin_chamados WHERE user_id = @user_id")
vRP.prepare("mirtin_chamados/inserirChamado", "INSERT INTO mirtin_chamados(user_id, total, historico) VALUES(@user_id,@total,@historico)")
vRP.prepare("mirtin_chamados/updateChamado", "UPDATE mirtin_chamados SET total = @total, historico = @historico WHERE user_id = @user_id")
vRP.prepare("mirtin_chamados/allChamados", "SELECT * FROM mirtin_chamados ORDER BY total DESC")
vRP.prepare("mirtin_chamados/delAllChamados", "DELETE from mirtin_chamados")
vRP.prepare("mirtin_chamados/createTable", [[ CREATE TABLE IF NOT EXISTS `mirtin_chamados` ( `user_id` int(11) NOT NULL, `total` int(11) NOT NULL, `historico` text NOT NULL DEFAULT '{}', PRIMARY KEY (`user_id`) ) ENGINE=InnoDB DEFAULT CHARSET=latin1; ]])

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMANDOS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('mchamados', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, "admin.permissao") then
            local chamados = vRP.query("mirtin_chamados/allChamados", {})
            local mensagem = ""

            if #chamados > 0 then
                for k,v in pairs(chamados) do
                    mensagem = mensagem .. "```cs\nID: "..v.user_id.." • Total: "..v.total.."``` "
                end
            end

            if mensagem == "" then
                mensagem = "```cs\n Ainda não existe chamados registrados```"
            end

            sendToDiscord(mensagem.. "\n Para ver o historico /mhistorico [ID]")
        end
    end
end)

RegisterCommand('mhistorico', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, "admin.permissao") then
            if args[1] ~= nil and args[1] ~= "" and tonumber(args[1]) then
                local rows = vRP.query("mirtin_chamados/getUser", { user_id = tonumber(args[1]) })
                local mensagem = ""
                if #rows > 0 then
                    local desc = json.decode(rows[1].historico)
                    for k,v in pairs(desc) do
                        mensagem = mensagem.. "```cs\n[ID DO JOGADOR]: "..v.idAceito.."\n[DESCRICAO]: "..v.descricao.." \n[DATA]: "..os.date("[%d/%m/%Y] as [%X]", k).." ```"
                    end

                    sendToDiscord(mensagem)
                else
                    TriggerClientEvent("Notify",source,"negado","ID não encontrado na lista.", 5)
                end
            end
        end
    end
end)

RegisterCommand('mwipe', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, "admin.permissao") then
            vRP.execute("mirtin_chamados/delAllChamados", {})
            sendToDiscord("```cs\n Os Chamados Foram Wipados```")
            TriggerClientEvent("Notify",source,"sucesso","Você limpou a lista de chamados.", 5)
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent('mirtin_chamados:registerChamado')
AddEventHandler('mirtin_chamados:registerChamado', function(user_id, nuser_id, info)
    local rows = vRP.query("mirtin_chamados/getUser", { user_id = user_id })
    local historico = {}

    if #rows > 0 then
        historico = json.decode(rows[1].historico)

        historico[os.time()] = { idAceito = nuser_id, descricao = info }

        vRP.execute("mirtin_chamados/updateChamado", { user_id = user_id, total = rows[1].total + 1, historico = json.encode(historico) })
        return
    end

    historico[os.time()] = { idAceito = nuser_id, descricao = info } 
    vRP.execute("mirtin_chamados/inserirChamado", { user_id = user_id, total = 1, historico = json.encode(historico) })
end)

function sendToDiscord(message)
	local embed = { { ["color"] = 6356736, ["title"] = "** Sistema de Chamados **", ["description"] = message, ["footer"] = { ["text"] = "© Mirt1n Store", }, } }
	PerformHttpRequest(weebhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
end

async(function()
	vRP.execute("mirtin_chamados/createTable", {})
end)
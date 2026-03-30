local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_player",src)
Proxy.addInterface("vrp_player",src)

vCLIENT = Tunnel.getInterface("vrp_player")

local arena = Tunnel.getInterface("mirtin_arena")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local actived = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DISCORD API
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.CheckPlayers()
	return GetNumPlayerIndices()
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- TRYTOW
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("trytow")
AddEventHandler("trytow",function(nveh,rveh)
	TriggerClientEvent("synctow",-1,nveh,rveh)
end)

--------------------------------------------------------------------------------------------------------------------------------
--- COR NA ARMA COM PERMISSAO --------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('cor', function(source, args)
    local source = source
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"perm.vips") or vRP.hasPermission(user_id,"ticket.permissao") or vRP.hasPermission(user_id,"perm.booster") then
		TriggerClientEvent('changeWeaponColor', source, args[1])
	else
		TriggerClientEvent("Notify",source,"negado","Negado","Apenas <b>VIP's</b> e <b>BOOST</b> podem utilizar este comando")
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('bvida',function(source,args)
    local user_id = vRP.getUserId(source)
    if vRP.checkCommands(user_id) then
        if not vRP.checkPrisioneiro(source) then
            if actived[parseInt(user_id)] == 0 or not actived[parseInt(user_id)] then
				if vRP.checkCommands(user_id) then
					if not vRP.checkFarda(user_id) then
					--	actived[parseInt(user_id)] = 5
						vRP.carregarConta(user_id, false)
					else
						TriggerClientEvent("Notify",source,"negado","Você não pode utilizar esse comando fardado.",5)
					end
				end
            else
                TriggerClientEvent("Notify",source,"negado","Você so pode utilizar esse comando em <b>"..actived[parseInt(user_id)].." segundo(s)</b>",5)
            end
        else
            TriggerClientEvent("Notify",source,"negado","Você não pode utilizar esse comando preso.",5)
        end
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------
-- STATUS
----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('status',function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        local onlinePlayers = GetNumPlayerIndices()
		
        local policia = vRP.getUsersByPermission("perm.policia")
		local policiaPtr = 0
		for k,v in pairs(policia) do
			local patrulhamento = vRP.checkPatrulhamento(parseInt(v))
			if patrulhamento then
				policiaPtr = policiaPtr + 1
			end
		end

        local paramedico = vRP.getUsersByPermission("perm.unizk")	
		local paramedicoPtr = 0
		for k,v in pairs(paramedico) do
			local patrulhamento = vRP.checkPatrulhamento(parseInt(v))
			if patrulhamento then
				paramedicoPtr = paramedicoPtr + 1
			end
		end

        local mec = vRP.getUsersByPermission("perm.bennys")
		local mecPTR = 0
		for k,v in pairs(mec) do
			local patrulhamento = vRP.checkPatrulhamento(parseInt(v))
			if patrulhamento then
				mecPTR = mecPTR + 1
			end 
		end

		local mec = vRP.getUsersByPermission("perm.sportrace")
		local mecPTR = 0
		for k,v in pairs(mec) do
			local patrulhamento = vRP.checkPatrulhamento(parseInt(v))
			if patrulhamento then
				mecPTR = mecPTR + 1
			end 
		end
 
        local staff = vRP.getUsersByPermission("admin.permissao")
		local moderador = vRP.getUsersByPermission("moderador.permissao")
		local suporte = vRP.getUsersByPermission("suporte.permissao")
        local staffPtr = vRP.getUsersByPermission("staffoff.permissao")
		TriggerClientEvent("Notify",source,"importante","<b>Mirtin Base:</b> <br> <br> <b>Policiais em Serviço: </b>  "..policiaPtr.."/"..#policia.."<br><b>Médicos em Serviço: </b>"..paramedicoPtr.."/"..#paramedico.."<br><b>Mecânicos em Serviço: </b> "..mecPTR.."/"..#mec.. ".", 15)
    end
    
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VEHS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local actived = {}
RegisterCommand('vehs',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
	if user_id then
		local veh = vRP.query("vRP/get_Veiculos", {user_id = user_id})
		local mensagem = ""
		for k,v in pairs(veh) do
			mensagem = mensagem..v.veiculo..","
		end

		local veiculos = vRP.prompt(source, "Digite o nome do veiculo: ", "Seus Veiculos: ".. mensagem)
		if veiculos and veiculos ~= nil and veiculos ~= "" then
			local myveh = vRP.query("vRP/get_veiculos_status", {user_id = user_id, veiculo = veiculos })
			if myveh[1] ~= nil then
				local nuser_id = vRP.prompt(source, "Digite o ID do jogador: ", "")
				if nuser_id and tonumber(nuser_id) and tonumber(nuser_id) > 0 and nuser_id ~= nil and nuser_id ~= "" then
					if parseInt(nuser_id) ~= parseInt(user_id) then
						local nplayer = vRP.getUserSource(parseInt(nuser_id))
						if nplayer then
							local valor = vRP.prompt(source, "Digite o valor que você deseja no veiculo: ", "")
							if tonumber(valor) > 0 and tonumber(valor) < 99999999 and valor ~= nil and valor ~= "" then
								if vRP.request(nplayer, "Você deseja comprar o veiculo <b>"..veiculos.."</b> por <b>$ "..vRP.format(valor).."</b> do id <b>"..user_id.."</b>", 30) then
									if actived[parseInt(nuser_id)] == 0 or not actived[parseInt(nuser_id)] then
										actived[parseInt(nuser_id)] = 5
										local myveh2 = vRP.query("vRP/get_veiculos_status", {user_id = user_id, veiculo = veiculos })

										if myveh2[1] ~= nil then
											if vRP.tryFullPayment(parseInt(nuser_id), parseInt(valor)) then
												vRP.giveMoney(user_id, parseInt(valor))
												vRP.execute("vRP/update_owner_vehicle", { nuser_id = tonumber(nuser_id), user_id = tonumber(user_id), veiculo = veiculos })
												vRP.updateAllPlates()

												TriggerClientEvent("Notify",source,"sucesso","Parabens, Você acaba de vender seu veiculo.", 5)
												TriggerClientEvent("Notify",nplayer,"sucesso","Parabens, Você acaba de comprar este veiculo.", 5)
											else
												TriggerClientEvent("Notify",source,"negado","O Jogador não possui dinheiro.", 5)
												TriggerClientEvent("Notify",nplayer,"negado","Você não possui dinheiro.", 5)
											end
										else
											TriggerClientEvent("Notify",source,"negado","O Jogador recusou a proposta.", 5)
											TriggerClientEvent("Notify",nplayer,"negado","Você recusou a proposta.", 5)
										end
									end
								end
							end
						else
							TriggerClientEvent("Notify",source,"negado","Este jogador não se encontra na cidade no momento.", 5)
						end
					else
						TriggerClientEvent("Notify",source,"negado","Você não pode vender para si mesmo.", 5)
					end
				end
			else
				TriggerClientEvent("Notify",source,"negado","Você não possui ou não digitou corretamente o nome do veiculo.", 5)
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SEQUESTRAR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('sequestrar', function(source,args)
	local user_id = vRP.getUserId(source)
	if user_id then
		local nplayer = vRPclient.getNearestPlayer(source,5)
		if nplayer then
			if vRPclient.isMalas(nplayer) then
				vRPclient._setMalas(nplayer, false)
				TriggerClientEvent("Notify",source,"sucesso","Você retirou o jogador do porta malas.", 5)
			else
				if vRPclient.isCapuz(nplayer) then
					vRPclient._setMalas(nplayer, true)
					TriggerClientEvent("Notify",source,"sucesso","Você colocou o jogador no porta malas.", 5)
				else
					TriggerClientEvent("Notify",source,"negado","O Jogador precisa está com capuz.", 5)
				end
			end
		end
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ACTIVEDOWNTIME
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GARMAS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('garmas', function(source,args)
	local user_id = vRP.getUserId(source)
    if user_id then
        local ok = vRP.request(source, "Você deseja guardar suas armas?", 30)
        if ok and not vRPclient.isInComa(source) and not actived[user_id] and actived[user_id] == nil then
            actived[parseInt(user_id)] = 5

			if arena.inArena(source) then
				return
			end

            if not vRP.checkPatrulhamento(user_id) then
                local weapons = vRPclient.replaceWeapons(source,{})
				local mensagem = ""

                for k,v in pairs(weapons) do
					if k == "WEAPON_STUNGUN" or k == "WEAPON_PETROLCAN" then 
						TriggerClientEvent("Notify",source,"negado","Não é possivel guardar <b>"..vRP.getItemName(k).."</b> na mochila..", 5)
					else
						vRP.giveInventoryItem(user_id, k, 1, true)

						if v.ammo > 0 then
							local ammo = string.gsub(k, "WEAPON_","AMMO_")
							vRP.giveInventoryItem(user_id, ammo, v.ammo, true)
						end
						

						if v.ammo > 0 then
							mensagem = mensagem.. "(Arma: "..k.." Municao: "..v.ammo.."x) - "
						else
							mensagem = mensagem.. "(Arma: "..k.." Municao: 0x) - "
						end

						vCLIENT.updateWeapons(source)
					end
                end
                
                TriggerClientEvent("Notify",source,"sucesso","Você guardou seu armamento na mochila.", 5)
				vRP.sendLog("GARMAS", "O ID "..user_id.." guardou  [ "..mensagem.." ] ")
            else
                TriggerClientEvent("Notify",source,"negado","Você não pode guardar armas em patrulhamento.", 5)
            end
        end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GCOLETE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('gcolete', function(source,args)
	local user_id = vRP.getUserId(source)
	local armour = vRPclient.getArmour(source)
	if user_id then
		local ok = vRP.request(source, "Você deseja guardar seu colete?", 30)
		if ok and not vRPclient.isInComa(source) and not actived[user_id] and actived[user_id] == nil and not vRP.checkPatrulhamento(user_id) then
            actived[parseInt(user_id)] = 5

			if armour and armour >= 95 then
				vRPclient._setArmour(source, 0)
				vRP.giveInventoryItem(user_id, "body_armor", 1, true)
				vCLIENT.updateWeapons(source)
				TriggerClientEvent("Notify",source,"sucesso","Você guardou seu colete na mochila.", 5)
			else
				TriggerClientEvent("Notify",source,"negado","Você não pode guardar um colete danificado.", 5)
			end
			
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GMOCHILA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('gmochila', function(source,args)
	local user_id = vRP.getUserId(source)
	if user_id then
		local ok = vRP.request(source, "Você deseja guardar sua(s) <b>"..vRP.getMochilaAmount(user_id).."</b> mochila(s)?", 30)
		if ok and not vRPclient.isInComa(source) and not actived[user_id] and actived[user_id] == nil then
            actived[parseInt(user_id)] = 5
			
			vRP.giveInventoryItem(user_id, "mochila", vRP.getMochilaAmount(user_id), true)
			vRP.remMochila(user_id)
			TriggerClientEvent("Notify",source,"sucesso","Você guardou suas mochilas.", 5)
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ENVIAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('enviar',function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	local nplayer = vRPclient.getNearestPlayer(source,2)
	local nuser_id = vRP.getUserId(nplayer)
    if nuser_id and parseInt(args[1]) > 0 and parseInt(args[1]) < 9999999 and not actived[user_id] and actived[user_id] == nil then
        actived[parseInt(user_id)] = 5
		if nplayer then
            if vRP.tryPayment(user_id,parseInt(args[1])) then
                vRP.giveMoney(nuser_id,parseInt(args[1]))
                vRPclient._playAnim(source,true,{{"mp_common","givetake1_a"}},false)
                TriggerClientEvent("Notify",source,"sucesso","Você enviou $"..vRP.format(parseInt(args[1])), 5)
				TriggerClientEvent("Notify",nplayer,"sucesso","Você recebeu $"..vRP.format(parseInt(args[1])), 5)
            else
                TriggerClientEvent("Notify",source,"negado","Você não possui essa quantia.", 5)
            end
        end
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- VER O ID PROXIMO
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('id', function(source,args)
    local source = source
    local user_id = vRP.getUserId(source)

	if user_id then
		local nplayer = vRPclient.getNearestPlayer(source,10)
		local nuser_id = vRP.getUserId(nplayer)
		if nplayer then
			TriggerClientEvent("Notify",source,"importante","ID Próximo: "..nuser_id, 5)
			TriggerClientEvent("Notify",nplayer,"importante","O [ID:"..user_id.."] acabou de ver seu id.", 5)
		else
			TriggerClientEvent("Notify",source,"negado","Nenhum jogador proximo.", 5)
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CHAMAR ADMIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('chamar', function(source, args, rawCommand)
local user_id = vRP.getUserId(source)
    if user_id ~= nil then
		if args[1] == "adm" then
			local aceito = false
			local x,y,z = vRPclient.getPosition(source,{})
			local desc = vRP.prompt(source,"Descreva seu problema:","")
			if desc and not actived[user_id] and actived[user_id] == nil then
				local admin = vRP.getUsersByPermission("ticket.permissao")
				for l,w in pairs(admin) do
				local player = vRP.getUserSource(parseInt(w))
					if player then
						async(function()
							vRPclient._playSound(player,"Event_Message_Purple","GTAO_FM_Events_Soundset")
							TriggerClientEvent("chatMessage",player,"^6CHAMADO^0: ^2(ID: "..user_id..") ^0"..desc.."")
							if vRP.request(player, "Você deseja aceitar o chamado do ID:"..user_id.. "?", 30) then
								if not aceito then
									local nuser_id = vRP.getUserId(player)
									if player then
										local nidentity = vRP.getUserIdentity(nuser_id)
										
										aceito = true
										vRPclient._teleport(player, x,y,z)
										TriggerClientEvent("Notify",source,"sucesso","O Membro da staff <b> "..nidentity.nome.." "..nidentity.sobrenome.." ("..nuser_id..") </b> aceitou o seu chamado..", 5)
										TriggerEvent('mirtin_chamados:registerChamado', nuser_id, user_id, desc.." \n[COORDENADAS]: "..tD(x)..","..tD(y)..","..tD(z))
									end

									vRP.sendLog("ACEITARCHAMADOADMIN", "O ADMIN ID "..nuser_id.." aceitou o chamado do id "..user_id.."  [ "..desc.." ] ")
								else
									TriggerClientEvent("Notify",source,"negado","Este chamado ja foi aceito por outro staff.", 5)
								end
							end
						end)
						actived[parseInt(user_id)] = 15
					end
				end
	
				TriggerClientEvent("Notify",source,"sucesso","Você chamou um administrador, aguarde.", 5)
			end
		end
    end
end)

RegisterCommand('call', function(source, args, rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id ~= nil then
		if args[1] == "adm" then
			local aceito = false
			local x,y,z = vRPclient.getPosition(source,{})
			local desc = vRP.prompt(source,"Descreva seu problema:","")
			if desc and not actived[user_id] and actived[user_id] == nil then
				local admin = vRP.getUsersByPermission("ticket.permissao")
				for l,w in pairs(admin) do
				local player = vRP.getUserSource(parseInt(w))
					if player then
						async(function()
							vRPclient._playSound(player,"Event_Message_Purple","GTAO_FM_Events_Soundset")
							TriggerClientEvent("chatMessage",player,"^6CHAMADO^0: ^2(ID: "..user_id..") ^0"..desc.."")
							if vRP.request(player, "Você deseja aceitar o chamado admin do id "..user_id.."?", 30) then
								if not aceito then
									local nuser_id = vRP.getUserId(player)
									if player then
										local nidentity = vRP.getUserIdentity(nuser_id)
										
										aceito = true
										vRPclient._teleport(player, x,y,z)
										TriggerClientEvent("Notify",source,"sucesso","O Membro da staff <b> "..nidentity.nome.." "..nidentity.sobrenome.." </b> aceitou o seu chamado..", 5)
										TriggerEvent('mirtin_chamados:registerChamado', nuser_id, user_id, desc.." \n[COORDENADAS]: "..tD(x)..","..tD(y)..","..tD(z))
									end
								else
									TriggerClientEvent("Notify",source,"negado","Este chamado ja foi aceito por outro staff.", 5)
								end
							end
						end)
						actived[parseInt(user_id)] = 15
					end
				end
	
				TriggerClientEvent("Notify",source,"sucesso","Você chamou um administrador, aguarde.", 5)
			end
		end
	end
end)

function tD(n)
    n = math.ceil(n * 100) / 100
    return n
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- ME
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("me",function(source,args,rawCommand)
	local user_id = vRP.getUserId(source)
	if user_id then
		if args[1] then
			TriggerClientEvent("vrp_player:pressMe",-1,source,rawCommand:sub(4),{ 10,250,0,255,100 })
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- /SKIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('skin',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao") then
        if parseInt(args[1]) and args[2] then
            local nplayer = vRP.getUserSource(parseInt(args[1]))
            if nplayer then
                TriggerClientEvent("skinmenu",nplayer,args[2])
                TriggerClientEvent("Notify",source,"sucesso","Você setou a skin <b>"..args[2].."</b> no passaporte <b>"..parseInt(args[1]).."</b>.", 5)
            end
        end
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE HORAS JOGADAS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local hour = {}

vRP.prepare("vRP/update_hour","UPDATE vrp_users_infos SET tempo_jogado = @tempo_jogado WHERE user_id = @user_id")

function src.giveWeaponToInventory()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		
		local weapons = vRPclient.replaceWeapons(source,{})
		for k,v in pairs(weapons) do
				vRP.giveInventoryItem(user_id, k, 1, true)
			if v.ammo > 0 then
				if not k == "WEAPON_STUNGUN" then
					local weapon = string.gsub(k, "WEAPON_","AMMO_")
					vRP.giveInventoryItem(user_id, weapon, v.ammo, true)
				end
			end
		end

		vCLIENT.updateWeapons(source)
	end
end

function src.getHour()
	local source = source
	local user_id = vRP.getUserId(source)
	
	if user_id then
		return hour[user_id] or 0
	end
end 

Citizen.CreateThread(function()
	while true do
		if hour then
			for k,v in pairs(hour) do
				hour[k] = hour[k] + 1
			end
		end
		Citizen.Wait(60*1000)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE IDENTIDADE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.getIdentity()
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	local carteira = vRP.getMoney(user_id)
	local banco = vRP.getBankMoney(user_id)
	local job = vRP.getUserGroupByType(user_id,"job") if (job == nil or job == "") then job = "Nenhum" end
	local org = vRP.getUserGroupByType(user_id,"org") if (org == nil or org == "") then org = "Nenhuma" end
	local vip = vRP.getUserGroupByType(user_id,"vip") if (vip == nil or vip == "") then vip = "Nenhum" end
	if user_id then
		return user_id,identity.nome,identity.sobrenome,identity.idade,identity.registro,identity.telefone,job,org,vip,vRP.format(carteira),vRP.format(banco)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE CHECAR COMANDO BLOQUEADO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.checkCommandsC()
	local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.checkCommands(user_id) then
            return true
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DELETAR VEICULO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.deleteVeh(vehicle)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        TriggerClientEvent('deletarveiculo',-1,vehicle)
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE PULAR E DERRUBAR PLAYER
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.TackleServerPlayer(Tackled,ForwardVectorX,ForwardVectorY,ForwardVectorZ,Tackler)
	if Tackled then
		vCLIENT.TackleClientPlayer(Tackled,ForwardVectorX,ForwardVectorY,ForwardVectorZ,Tackler)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TROCAR DE BANCO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("seat",function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRPclient.getHealth(source) > 105 then
			if tonumber(args[1]) then
				vCLIENT.seatPlayer(source, tonumber(args[1]))
			end
        end
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ATTACHS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.checkAttachs()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id,"compattachs") >= 1 or vRP.hasPermission(user_id,"perm.vips") or vRP.hasPermission(user_id,"ticket.permissao") or vRP.hasPermission(user_id,"perm.booster") or vRP.hasPermission(user_id,"perm.policia") then
			return true
		end
	end
end

--------------------------------------------------------------------------------------------
--------------------  COLOCAR FOGO EM ALGUÉM  ---------------------
--------------------------------------------------------------------------------------------

RegisterCommand('fogo', function(source)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao") then
        TriggerClientEvent('FOGO', source)
    end
end)



-----------------------------------------------------------------------------------------------------------------------------------------
--Cor carro
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('carcolor',function(source,args,rawCommand)
    local user_id = vRP.getUserId(source)
    if vRP.hasPermission(user_id,"admin.permissao") then
        local vehicle = vRPclient.getNearestVehicle(source,7)
        if vehicle then
            local rgb = vRP.prompt(source,"RGB Color(255 255 255):","")
            rgb = sanitizeString(rgb,"\"[]{}+=?!_()#@%/\\|,.",false)
            local r,g,b = table.unpack(splitString(rgb," "))
            TriggerClientEvent('vcolorv',source,vehicle,tonumber(r),tonumber(g),tonumber(b))
            TriggerClientEvent('Notify',source,"sucesso","Cor Alterada")
        end
    end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE SALARIOS 
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local cfg = module("cfg/groups")
local grupos = cfg.groups
local salarios = {}
local sound = {}

function src.rCountSalario()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then

		if salarios[user_id] == nil then 
			salarios[user_id] = 0 
		else
			salarios[user_id] = salarios[user_id] + 1
		end

		if salarios[user_id] == 30 then
			pagarSalario(user_id)
			salarios[user_id] = 0
		end
	end
end

function pagarSalario(user_id)
	local source = vRP.getUserSource(user_id)
	if user_id then
		local groups = vRP.getUserGroups(user_id)
		for k,v in pairs(groups) do
			if grupos[k] and grupos[k]._config ~= nil and grupos[k]._config.salario ~= nil then
				if grupos[k]._config.salario > 0 then
					if grupos[k]._config.ptr then
						if vRP.checkPatrulhamento(user_id) then
							vRP.giveBankMoney(user_id, grupos[k]._config.salario)
                            TriggerClientEvent('chatMessage',source,"SALARIO:",{255,160,0}, "Você acaba de receber o salario de ^2"..k.."^0 no valor de ^2 $ "..vRP.format(grupos[k]._config.salario))
						end
					else
						vRP.giveBankMoney(user_id, grupos[k]._config.salario)
						TriggerClientEvent('chatMessage',source,"SALARIO:",{255,160,0}, "Você acaba de receber o salario de ^2"..k.."^0 no valor de ^2 $ "..vRP.format(grupos[k]._config.salario))
					end

					if sound[user_id] == nil then
						sound[user_id] = true
						vRPclient._playSound(source,"Event_Message_Purple","GTAO_FM_Events_Soundset")
						SetTimeout(2000, function() sound[user_id] = nil end)
					end

				end
			end
		end
	end
end

RegisterCommand('salario', function(source,args)
	local user_id = vRP.getUserId(source)
	if user_id then
		if salarios[user_id] ~= nil then
			TriggerClientEvent('chatMessage',source,"SALARIO: ",{255,160,0}, " Ainda faltam ^2 ".. 40 - salarios[user_id].." minuto(s)^0 para você receber o seu salario.")
		end
	end
end)

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ANUNCIO DE CHAMADOS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servicesAn = {
	["perm.policia"] = { prefix = "^5[POLICIA]" },
}

RegisterCommand('911',function(source,args,rawCommand)
	if args[1] then
		local user_id = vRP.getUserId(source)
		local identity = vRP.getUserIdentity(user_id)
	
		if user_id then
			for k,v in pairs(servicesAn) do
				if vRP.hasPermission(user_id, k) then
					TriggerClientEvent('chatMessage',-1,v.prefix.. "^ " ..identity.nome.." "..identity.sobrenome.. ": ",{64,64,255},rawCommand:sub(3))
					break;
				end
			end
		end
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		for k,v in pairs(actived) do
			if v > 0 then
				actived[k] = v - 1
			end

			if actived[k] == 0 then
				actived[k] = nil
			end
		end
	end
end)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("trytow")
AddEventHandler("trytow",function(nveh,rveh)
	TriggerClientEvent("synctow",-1,nveh,rveh)
end)

RegisterServerEvent("trytrunk")
AddEventHandler("trytrunk",function(nveh)
	TriggerClientEvent("synctrunk",-1,nveh)
end)

RegisterServerEvent("trywins")
AddEventHandler("trywins",function(nveh)
	TriggerClientEvent("syncwins",-1,nveh)
end)

RegisterServerEvent("tryhood")
AddEventHandler("tryhood",function(nveh)
	TriggerClientEvent("synchood",-1,nveh)
end)

RegisterServerEvent("trydoors")
AddEventHandler("trydoors",function(nveh,door)
	TriggerClientEvent("syncdoors",-1,nveh,door)
end)
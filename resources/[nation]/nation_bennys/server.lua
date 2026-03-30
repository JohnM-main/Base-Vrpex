local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("nation_bennys",src)
Proxy.addInterface("nation_bennys",src)

vCLIENT = Tunnel.getInterface("nation_bennys")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local using_bennys = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EQUIPAMENTOS BENNYS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local bennys_equipamentos = {}
local segundos = {}

bennys_equipamentos["1. Equipar"] = {function(source,choice)
	local user_id = vRP.getUserId(source)
    local sexo = vCLIENT.checkSexo(source)
    local identity = vRP.getUserIdentity(user_id)
	if user_id ~= nil and not segundos[user_id] and segundos[user_id] == nil then
		segundos[user_id] = 5
        vRP.giveInventoryItem(user_id, "repairkit", 10, true)
        vRP.colocarFarda(user_id, "[BENNYS] Mecanico ["..sexo.."]")
		vRP.addPeso(user_id, 15)
		vRP.setPatrulhamento(user_id)
        vRP.sendLog("BATERPONTOBENNYS", "```css\n** BATER PONTO **\n"..os.date("[%d/%m/%Y as %X]").." O Mecanico(a) ["..identity.nome ..identity.sobrenome.." ("..user_id..")] acabou de entrar em expediente. ```")
	end
end}

bennys_equipamentos["2. Sair"] = {function(source,choice)
	local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if user_id ~= nil and not segundos[user_id] and segundos[user_id] == nil then
		segundos[user_id] = 5
		
        vRP.removerFarda(user_id) 
        vRP.removePatrulhamento(user_id)
		vRP.addPeso(user_id, 0)
        vRP.sendLog("BATERPONTOBENNYS", "```css\n** BATER PONTO **\n"..os.date("[%d/%m/%Y as %X]").." O Mecanico(a) ["..identity.nome ..identity.sobrenome.." ("..user_id..")] acabou de sair em expediente.```")
	end
end}

vRP._addStaticMenuChoices("bennys_equipamentos", bennys_equipamentos)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EQUIPAMENTOS SPORTRACE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local sportrace_equipamentos = {}

sportrace_equipamentos["1. Equipar"] = {function(source,choice)
	local user_id = vRP.getUserId(source)
    local sexo = vCLIENT.checkSexo(source)
    local identity = vRP.getUserIdentity(user_id)
	if user_id ~= nil and not segundos[user_id] and segundos[user_id] == nil then
		segundos[user_id] = 5
        vRP.giveInventoryItem(user_id, "repairkit", 10, true)
        vRP.colocarFarda(user_id, "[SPORT] Mecanico ["..sexo.."]")
		vRP.addPeso(user_id, 15)
		vRP.setPatrulhamento(user_id)
        --vRP.sendLog("BATERPONTOBENNYS", "```css\n** BATER PONTO **\n"..os.date("[%d/%m/%Y as %X]").." O Mecanico(a) ["..identity.nome ..identity.sobrenome.." ("..user_id..")] acabou de entrar em expediente. ```")
	end
end}

sportrace_equipamentos["2. Sair"] = {function(source,choice)
	local user_id = vRP.getUserId(source)
    local identity = vRP.getUserIdentity(user_id)
    if user_id ~= nil and not segundos[user_id] and segundos[user_id] == nil then
		segundos[user_id] = 5
		
        vRP.removerFarda(user_id) 
        vRP.removePatrulhamento(user_id)
		vRP.addPeso(user_id, 0)
        --vRP.sendLog("BATERPONTOBENNYS", "```css\n** BATER PONTO **\n"..os.date("[%d/%m/%Y as %X]").." O Mecanico(a) ["..identity.nome ..identity.sobrenome.." ("..user_id..")] acabou de sair em expediente.```")
	end
end}

vRP._addStaticMenuChoices("sportrace_equipamentos", sportrace_equipamentos)


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTROS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        for k,v in pairs(segundos) do
            if v >= 0 then
                segundos[k] = v - 1
                if v <= 0 then
                    segundos[k] = nil
                end
            end
        end

        Citizen.Wait(1000)
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTROS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.checkPermission()
    local source = source
    local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id, "perm.sportrace") or vRP.hasPermission(user_id, "perm.bennys") then
        return true
    end
end

function src.getSavedMods(vehicle_name, vehicle_plate)
    local puser_id = vRP.getUserByPlate(vehicle_plate)
    if puser_id then
        local rows = vRP.query("vRP/get_tunagem", {user_id = puser_id, veiculo = vehicle_name})
        return json.decode(rows[1].tunagem or {}) or {}
    end
end

function src.checkPayment(amount)
    local source = source
    local user_id = vRP.getUserId(source)
	
	if amount == nil or parseInt(amount) <= 0 then
	   amount = 5000
	end

    if vRP.tryFullPayment(user_id, parseInt(amount)) then
        TriggerClientEvent("Notify",source,"sucesso","Modificações aplicadas com <b>sucesso</b><br >Você pagou <b>$ "..vRP.format(tonumber(amount)).."<b>.", 5)
        return true
    else
        TriggerClientEvent("Notify",source,"negado","Você não possui dinheiro suficiente.", 5)
        return false
    end 
	
end

function src.repairVehicle(vehicle, damage)
    TriggerEvent("tryreparar", vehicle)
    return true
end

function src.removeVehicle(vehicle)
    using_bennys[vehicle] = nil
    return true
end

function src.checkVehicle(vehicle)
    if using_bennys[vehicle] then
        return false
    end
    using_bennys[vehicle] = true
    return true
end

function src.checkTuningVehicle()
    local source = source
	local  mPlaca,mName,mNet,mPortaMalas,mPrice,mLock = vRPclient.ModelName(source,7)
	local puser_id = vRP.getUserByPlate(mPlaca)
	if mPlaca then
		local rows = vRP.query("vRP/get_portaMalas",{ user_id = puser_id, veiculo = mName })
		if #rows > 0 then
			return true
		end
	end
end

function src.saveVehicle(vehicle_name, vehicle_plate, vehicle_mods)
    local puser_id = vRP.getUserByPlate(vehicle_plate)
    if puser_id then
        vRP.execute("vRP/update_tuning",{ user_id = parseInt(puser_id), veiculo = vehicle_name, tunagem = json.encode(vehicle_mods) })
        return true
    end
end

RegisterServerEvent("nation:syncApplyMods")
AddEventHandler("nation:syncApplyMods",function(vehicle_tuning,vehicle)
    TriggerClientEvent("nation:applymods_sync",-1,vehicle_tuning,vehicle)
end)

vRP.prepare("vRP/get_tunagem2","SELECT * FROM vrp_user_veiculos WHERE placa = @placa AND veiculo = @veiculo")
function src.requestTuning(veiculo, placa)
    local rows = vRP.query("vRP/get_tunagem2", { veiculo = veiculo, placa = placa  })
    if #rows > 0 then
        return json.decode(rows[1].tunagem)
    end

    return {}
end

function src.syncModsAplly(vehicle_tuning,vehicle)
    vCLIENT.syncTunagem(-1, vehicle_tuning,vehicle)
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('reparar', function(source,args)
    local source = source
    local user_id = vRP.getUserId(source)
	if vRP.hasPermission(user_id, "admin.permissao") or vRP.hasPermission(user_id, "perm.bennys") then
        if not vRPclient.isInVehicle(source) then
            local vehicle = vRPclient.getNearestVehicle(source, 7)
            vRPclient._playAnim( source, false, {{"mini@repair", "fixing_a_player"}}, true )
            TriggerClientEvent("progress", source, 15)
            vRP.blockCommands(user_id, 15)
            SetTimeout(15000,function()
                TriggerClientEvent("reparar", source, vehicle)
                vRPclient._stopAnim(source, false)
                TriggerClientEvent( "Notify", source, "sucesso", "Você reparou o veiculo.", 5 )
            end)
        else
            TriggerClientEvent( "Notify", source, "negado", "Precisa estar próximo ou fora do veículo para efetuar os reparos.", 5 )
        end
    end
end)


-----------------------------------------------------------------------------------------------------------------------------------------
-- TOW
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("trytow")
AddEventHandler("trytow",function(nveh,rveh)
	TriggerClientEvent("synctow",-1,nveh,rveh)
end)
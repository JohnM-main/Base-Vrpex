local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP","vrp_policia")

src = {}
Tunnel.bindInterface("vrp_policia",src)
vSERVER = Tunnel.getInterface("vrp_policia")


local segundos = 0

----------------------------------------------------------------------------------------------------------------------------------------
-- PEDIR RG
----------------------------------------------------------------------------------------------------------------------------------------
local css = [[ #simplehud { bottom: 13%; right: 0%; background: rgba(0, 0, 0, 0.4); -webkit-box-shadow: 0 6px 15px 0 rgba(0,0,0,.6); box-shadow: 10px rgba(0,0,0,.4); -webkit-box-sizing: border-box; width: 15%; padding: 0 15px 12px 15px; border-radius: 15px 0 0 15px; position: fixed; } @keyframes animateright { from { right: -300px; opacity: 0 } to { right: 3%; opacity: 1 } } .label_carteira { font-family: 'Lobster', cursive; font-size: 25px; font-weight: bold; letter-spacing: 1px; color: #fff; letter-spacing: 0.25rem; text-align: center; } .label_carteira p { background: linear-gradient(270deg, rgba(74, 255, 213,1), rgba(74, 255, 213,0.3)); background-size: 400% 400%; margin: 10px; padding: 0; -webkit-background-clip: text; -webkit-text-fill-color: transparent; animation: changebackground 5s ease infinite; } @keyframes changebackground { 0%{background-position:0% 50%} 50%{background-position:100% 50%} 100%{background-position:0% 50%} } .info_carteira { font-family: 'Blinker', sans-serif; font-size: 15px; color: #333; } .info_carteira .info_section{ background: transparent; padding: 8px; /*border-radius: 8px; margin: 10px 0;*/ text-align: left; letter-spacing: 1px; border-bottom:1px solid transparent; color: white; } .info_carteira .info_section:first-child{ border-top-left-radius: 8px; border-top-right-radius: 8px; } .info_carteira .info_section:last-child{ border-bottom-left-radius: 8px; border-bottom-right-radius: 8px; box-shadow: 0 2px 1px transparent; border: 0; } .info_carteira .info_section .icon { width: 30px; height: 30px; background-repeat: no-repeat; background-size: 20px; background-position: center; float: left; position: relative; top: -5px; left: -2px; } .info_carteira .info_section .info { float: right; color: rgb(255, 255, 255); padding-right: 5px; } @keyframes animateright { from { right: -300px; opacity: 0 } to { right: 2.2%; opacity: 1 } } ]]

function src.enviarIdentidade(status, id, nome,sobrenome,idade,registro,telefone,carteira,trabalho)
    if status then
        local html = string.format("<div id='simplehud'> <div class='label_carteira'><img src='https://i.imgur.com/Ta9YOaY.png' style='width: 120px;'></div> <div class='info_carteira'> <div class='info_section'> PASSAPORTE: <span class='info'>"..id.."</span> </div> </div> <div class='info_carteira'> <div class='info_section'> NOME: <span class='info'> "..nome.. " "..sobrenome.. " ("..idade..")</span> </div> </div> <div class='info_carteira'> <div class='info_section'> RG: <span class='info'> "..registro.. "</span> </div> </div> <div class='info_carteira'> <div class='info_section'> Telefone: <span class='info'> "..telefone.. "</span> </div> </div> <div class='info_carteira'> <div class='info_section'> Trabalho: <span class='info'> "..trabalho.. "</span> </div> </div> <div class='info_carteira'> <div class='info_section'> Carteira: <span class='info'> "..carteira.. "</span> </div> </div> </div>")
        vRP._setDiv("registro", css, html)
    else
        vRP._removeDiv("registro")
    end
    return true
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- /RCHAPEU
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("rchapeu")
AddEventHandler("rchapeu",function()
	ClearPedProp(PlayerPedId(),0)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- /RMASCARA
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("rmascara")
AddEventHandler("rmascara",function()
	SetPedComponentVariation(PlayerPedId(),1,0,0,2)
end)


----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE PRISAO
----------------------------------------------------------------------------------------------------------------------------------------
local nveh = nil
local pveh01 = nil
local pveh02 = nil
local Transporte = false 
local chegou = false
local prisioneiro = false

local coords = {
	[1] = { 482.99,-1010.38,26.28 },
	[2] = { -2063.01,-457.47,16.44 },
    [3] = { 606.84,-7.72,82.78 }
}

function src.checkPrisonArea()
    local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))

	for k,v in pairs(coords) do
		local _,i = GetGroundZFor_3dCoord(v[1],v[2],v[3])
		local distance = Vdist(x,y,z,v[1],v[2],v[3],i)
		if distance <= 20.0 then
			return true
		end
	end

	return false
end

function src.levarPrisioneiro(prisionTime)
    local ped = PlayerPedId()

	local vhash = GetHashKey("riot")
	while not HasModelLoaded(vhash) do
		RequestModel(vhash)
		Citizen.Wait(10)
	end

	local phash = GetHashKey("mp_m_securoguard_01")
	while not HasModelLoaded(phash) do
		RequestModel(phash)
		Citizen.Wait(10)
    end

	if HasModelLoaded(vhash) then
		nveh = CreateVehicle(vhash, 497.27,-1015.44,27.96,250.12,true,false)
		SetVehicleNumberPlateText(nveh,vRP.getRegistrationNumber())
        pveh01 = CreatePedInsideVehicle(nveh,27,GetHashKey("mp_m_securoguard_01"),-1,true,false)
        pveh02 = CreatePedInsideVehicle(nveh,27,GetHashKey("mp_m_securoguard_01"),1,true,false)


        TaskWarpPedIntoVehicle(PlayerPedId(),nveh,2)
        SetVehicleSiren(nveh, true)


		SetEntityAsMissionEntity(nveh,  true, false)
        SetEntityAsMissionEntity(pveh01,  true, false)
        SetEntityAsMissionEntity(pveh02,  true, false)

        SetVehicleOnGroundProperly(nveh)
		TaskVehicleDriveToCoordLongrange(pveh01,nveh, 1685.38,2607.15,45.1, 18.0 ,2883621, 1.0)
        SetModelAsNoLongerNeeded(vhash)
        Transporte = true
        local contador = 0

        async(function()
            while Transporte do
                Citizen.Wait(1000)

                local x,y,z = table.unpack(GetEntityCoords(ped))
                local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
                if street == "Route 68" then
                    SetEntityMaxSpeed(nveh,0.32*80-0.45)
                end

                local distancia = GetDistanceBetweenCoords(GetEntityCoords(nveh),1685.38,2607.15,45.1,true)
                local vehspeed = GetEntitySpeed(nveh)*3.6

                if not IsPedSittingInAnyVehicle(pveh01) or not IsPedSittingInAnyVehicle(ped) and not chegou then
                    SetEntityAsNoLongerNeeded(pveh01)
                    SetEntityAsNoLongerNeeded(pveh02)

                    vSERVER.colocarPrisao(prisionTime)
                    Transporte = false
                    chegou = false
                    clearPeds()
                end

                if math.ceil(vehspeed) <= 5 then 
                    contador = contador + 1
                    
                    if contador >= 10 then
                        SetEntityAsNoLongerNeeded(pveh01)
                        SetEntityAsNoLongerNeeded(pveh02)

                        vSERVER.colocarPrisao(prisionTime)
                        Transporte = false
                        chegou = false
                        clearPeds()
                        contador = 0
                    end
                end

                if distancia < 30.0 and math.ceil(vehspeed) <= 2 then
                    if IsPedSittingInAnyVehicle(ped) then
                        local veh = GetVehiclePedIsIn(ped, false)
                        TaskLeaveVehicle(ped,veh, 4160)

                        SetTimeout(3000, function()
                            TaskGoToCoordAnyMeans(ped, 1678.29,2593.77,45.57 , 0.4, 0, 0, 786603, 0xbf800000)

                            TaskLeaveVehicle(pveh02,veh, 4160)
                            TaskGoToCoordAnyMeans(pveh02,  1678.29,2593.77,45.57, 0.4, 0, 0, 786603, 0xbf800000)

                            SetEntityAsNoLongerNeeded(pveh01)
                            SetEntityAsNoLongerNeeded(pveh02)
                        end)

                        chegou = true
                    end
                end

                local distanciaPrison = GetDistanceBetweenCoords(GetEntityCoords(ped),1678.29,2593.77,45.57,true)
                if distanciaPrison < 3.0 then
                    vSERVER.colocarPrisao(prisionTime)
                    Transporte = false
                    chegou = false
                end
            end
        end)
    end
end

function src.prisioneiro(status)
    prisioneiro = status
    DoScreenFadeOut(1000)

    Wait(1000)
    local ped = PlayerPedId()
	if prisioneiro then
		SetEntityInvincible(ped,false) --mqcu
		FreezeEntityPosition(ped,true)
		SetEntityVisible(ped,false,false)
		SetTimeout(3000,function()
			SetEntityInvincible(ped,false)
			FreezeEntityPosition(ped,false)
			SetEntityVisible(ped,true,false)
        end)
        clearPeds()
    end
    vRP.teleport(1679.1,2514.55,45.55)

	Wait(3500)
    DoScreenFadeIn(1000)
end

function src.setarRoupasPrisional()
    if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
        SetPedComponentVariation(PlayerPedId(),1,120,0,2)
        SetPedComponentVariation(PlayerPedId(),3,0,0,2)
        SetPedComponentVariation(PlayerPedId(),4,27,2,2)
        SetPedComponentVariation(PlayerPedId(),6,5,2,2)
        SetPedComponentVariation(PlayerPedId(),8,15,0,2)
        SetPedComponentVariation(PlayerPedId(),9,0,1,2)
        SetPedComponentVariation(PlayerPedId(),11,1,11,2)
        SetPedPropIndex(PlayerPedId(),0,-1,0,0)
        SetPedPropIndex(PlayerPedId(),6,-1,0,0)
    elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
        SetPedComponentVariation(PlayerPedId(),1,0,0,2)
        SetPedComponentVariation(PlayerPedId(),3,14,0,2)
        SetPedComponentVariation(PlayerPedId(),4,3,15,2)
        SetPedComponentVariation(PlayerPedId(),6,5,0,2)
        SetPedComponentVariation(PlayerPedId(),8,9,0,2)
        SetPedComponentVariation(PlayerPedId(),9,0,1,2)
        SetPedComponentVariation(PlayerPedId(),11,141,2,2)
        SetPedPropIndex(PlayerPedId(),0,-1,0,0)
        SetPedPropIndex(PlayerPedId(),6,-1,0,0)
    end
end

function clearPeds()
    TriggerServerEvent("Garagem:deletarVeiculo",VehToNet(nveh))
    TriggerServerEvent("trydeleteped",PedToNet(pveh01))
    TriggerServerEvent("trydeleteped",PedToNet(pveh02))
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		if prisioneiro then
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),1678.6,2513.39,45.57,true)
			if distance >= 150 then
                SetEntityCoords(PlayerPedId(),1678.6,2513.39,45.57)
                TriggerEvent("Notify","negado","O agente penitenciário encontrou você tentando escapar.", 5)
			end
		end
	end
end)




-----------------------------------------------------------------------------------------------------------------------------------------
-- ANDAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("homem",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@confident")
	end
end)

RegisterCommand("mulher",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_f@heels@c")
	end
end)

RegisterCommand("depressivo",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@depressed@a")
	end
end)

RegisterCommand("depressiva",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_f@depressed@a")
	end
end)

RegisterCommand("empresario",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@business@a")
	end
end)

RegisterCommand("determinado",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@brave@a")
	end	
end)

RegisterCommand("descontraido",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@casual@a")
	end
end)

RegisterCommand("farto",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@fat@a")
	end
end)

RegisterCommand("estiloso",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@hipster@a")
	end
end)

RegisterCommand("ferido",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@injured")
	end
end)

RegisterCommand("nervoso",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@hurry@a")
	end
end)

RegisterCommand("desleixado",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@hobo@a")
	end
end)

RegisterCommand("infeliz",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@sad@a")
	end
end)

RegisterCommand("musculoso",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@muscle@a")
	end
end)

RegisterCommand("desligado",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@shadyped@a")
	end
end)

RegisterCommand("fadiga",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@buzzed")
	end
end)

RegisterCommand("apressado",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@hurry_butch@a")
	end
end)

RegisterCommand("descolado",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@money")
	end
end)

RegisterCommand("corridinha",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@quick")
	end
end)

RegisterCommand("piriguete",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_f@maneater")
	end
end)

RegisterCommand("petulante",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_f@sassy")
	end
end)

RegisterCommand("arrogante",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_f@arrogant@a")
	end
end)

RegisterCommand("bebado",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@drunk@slightlydrunk")
	end
end)

RegisterCommand("bebado2",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@drunk@verydrunk")
	end
end)

RegisterCommand("bebado3",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@drunk@moderatedrunk")
	end
end)

RegisterCommand("irritado",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@fire")
	end
end)

RegisterCommand("intimidado",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_m@intimidation@cop@unarmed")
	end
end)

RegisterCommand("poderosa",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_f@handbag")
	end
end)

RegisterCommand("chateado",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_f@injured")
	end
end)

RegisterCommand("estilosa",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_f@posh@")
	end
end)

RegisterCommand("sensual",function(source,args)
	if not prisioneiro then
	vRP.loadAnimSet("move_f@sexy@a")
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ALGEMAR
----------------------------------------------------------------------------------------------------------------------------------------
local other = nil
local drag = false
local carregado = false

function src.arrastar(p1)
    other = p1
    drag = not drag
end

Citizen.CreateThread(function()
    while true do
        local time = 1000
		if drag and other then
            time = 5
			local ped = GetPlayerPed(GetPlayerFromServerId(other))
			Citizen.InvokeNative(0x6B9BBD38AB0796DF,PlayerPedId(),ped,4103,11816,0.48,0.0,0.0,0.0,0.0,0.0,false,false,false,false,2,true)
			carregado = true
        else
        	if carregado then
				DetachEntity(PlayerPedId(),true,false)
				carregado = false
			end
        end

        Citizen.Wait(time)
	end
end)


Citizen.CreateThread(function()
	while true do
		Citizen.Wait(5000)
		if prisioneiro then
			local distance = GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()),1678.6,2513.39,45.57,true)
			if distance >= 150 then
                SetEntityCoords(PlayerPedId(),1678.6,2513.39,45.57)
                TriggerEvent("Notify","negado","O agente penitenciário encontrou você tentando escapar.", 5)
			end
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ALGEMAR / DESALGEMAR 
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("algemar",function(source,args)
    if not IsPedInAnyVehicle(PlayerPedId()) then
	    vSERVER.algemar()
    end
end)


RegisterCommand("arrastar",function(source,args)
    if not IsPedInAnyVehicle(PlayerPedId()) then
	    vSERVER.arrastar()
    end
end)

RegisterCommand("qth",function(source,args)
    if not IsPedInAnyVehicle(PlayerPedId()) then
	    vSERVER.qthP()
    end
end)

RegisterKeyMapping("algemar","Algemar o Cidadao","keyboard","g")
RegisterKeyMapping("arrastar","Carregar o Cidadao","keyboard","h")
RegisterKeyMapping("qth","QTH","keyboard","PAGEDOWN")

-----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFICAR POLICIA
-----------------------------------------------------------------------------------------------------------------------------------------
function src.sendAlertPolice(x,y,z, blipText, text)
    vSERVER.alertPolice(x,y,z, blipText, text)
end

--------------------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFICAO DE DISPARO
--------------------------------------------------------------------------------------------------------------------------------------------------
local in_arena = false
local blacklistedWeapons = {
	"WEAPON_DAGGER",
	"WEAPON_BAT",
	"WEAPON_BALL",
	"WEAPON_SNOWBALL",
	"WEAPON_BOTTLE",
	"WEAPON_CROWBAR",
	"WEAPON_FLASHLIGHT",
	"WEAPON_GOLFCLUB",
	"WEAPON_HAMMER",
	"WEAPON_HATCHET",
	"WEAPON_KNUCKLE",
	"WEAPON_KNIFE",
	"WEAPON_MACHETE",
	"WEAPON_SWITCHBLADE",
	"WEAPON_NIGHTSTICK",
	"WEAPON_WRENCH",
	"WEAPON_BATTLEAXE",
	"WEAPON_POOLCUE",
	"WEAPON_STUNGUN",
	"WEAPON_STONE_HATCHET"
}

local blacklistedLocations = {
    [1] = { coords = vec3(1571.94,-1685.43,88.22), dist = 100.0 },
    [2] = { coords = vec3(-91.33,-2642.74,6.04), dist = 100.0 },
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()

        if GetSelectedPedWeapon(ped) ~= -1569615261 and not in_arena then
            time = 30

            local vehicle = GetVehiclePedIsUsing(ped)
            local blacklistweapon = false
            local x,y,z = table.unpack(GetEntityCoords(ped))
            
            for k,v in ipairs(blacklistedWeapons) do
                if GetSelectedPedWeapon(ped) == GetHashKey(v) or not vehicle then
                    blacklistweapon = true
                end
            end
           
            for k,v in pairs(blacklistedLocations) do
                local distance = #(GetEntityCoords(ped) - v.coords)
                if distance <= v.dist then
                    blacklistweapon = true
                end
            end

            if IsPedShooting(ped) and not blacklistweapon and not IsPedCurrentWeaponSilenced(PlayerPedId()) then
                vSERVER.sendLocationFire(x,y,z)
                Wait(3000)
            end

            blacklistweapon = false
        end

        Citizen.Wait(time)
	end
end)

RegisterNetEvent("mirtin_survival:updateArena")
AddEventHandler("mirtin_survival:updateArena", function(boolean)
    in_arena = boolean
end)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE REDUCAO DE PENA
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local agindo = false
local delayServico = {}

Citizen.CreateThread(function()
    while true do
        local time = 1000
		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)
        if prisioneiro then
            if not agindo then
                for k,v in pairs(cfg.locations) do
                    local distance = #(pedCoords - v.coords)
                    if distance <= 15.0 then
                        time = 5
                        DrawMarker(21, v.coords[1],v.coords[2],v.coords[3], 0, 0,0,0,180.0,130.0,0.3,0.1,0.3, 255,0,0,255 ,1,0,0,1) 
                        if distance <= 3.0 then
                            if IsControlJustReleased(1, 51) and segundos <= 0 then
                                segundos = 5
                                if delayServico[k] == nil or not delayServico[k] then
                                    if vSERVER.checkTempoPrisao() > cfg.geral.tempoMin then
                                        iniciarServico(k, v.type, v.coords, v.heading)
                                    else
                                        TriggerEvent("Notify","negado","Não precisamos mais de seus serviços.", 5)
                                    end
                                else
                                    TriggerEvent("Notify","negado","Você já passou por esse local aguarde <b>"..delayServico[k].." segundo(s)</b>.", 5)
                                end
                            end
                        end
                    end
                end
            end  
        end
        
        Citizen.Wait(time)
    end
end)

function iniciarServico(id, servico, coords, heading)
    local ped = PlayerPedId()
    if ped then
        if servico == "Consertar" then
            agindo = true
            SetEntityCoords(ped, coords[1],coords[2],coords[3]-0.8)
            SetEntityHeading(ped , heading)
            vRP._playAnim(false,{task=cfg.types[servico].anim},false)

            local finished = vRP.taskBar(15000, math.random(10,15))
            if finished then
                local finished = vRP.taskBar(15000, math.random(10,15))
                if finished then
                    local finished = vRP.taskBar(15000, math.random(10,15))
                    if finished then
                        delayServico[id] = 90

                        vRP._DeletarObjeto()
                        ClearPedTasks(GetPlayerPed(-1))
                        reduzirTempo(cfg.types[servico].reduzir)
                    end
                end
            end
            agindo = false
        elseif servico == "Varrer" then
            agindo = true
            vSERVER.blockCommands(30)
            vRP.CarregarObjeto(cfg.types[servico].anim,cfg.types[servico].dict,cfg.types[servico].prop[1],cfg.types[servico].prop[2],cfg.types[servico].prop[3])
            TriggerEvent("progress", 30)

            SetTimeout(30*1000,function()
                delayServico[id] = 90
                agindo = false

                vRP._DeletarObjeto()
                ClearPedTasks(GetPlayerPed(-1))
                reduzirTempo(cfg.types[servico].reduzir)
            end)
        end
    end
    
end

function reduzirTempo(tempo)
    vSERVER.reduzirPrisao(tempo)
end
--------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE RADAR
--------------------------------------------------------------------------------------------------------------------------------------------------
local radar = {
	shown = false,
	freeze = false,
	info = "INICIANDO O SISTEMA DO RADAR",
	info2 = "INICIANDO O SISTEMA DO RADAR"
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
        if IsPedInAnyVehicle(PlayerPedId()) then
            time = 5
            if IsControlJustPressed(1,306) and IsPedInAnyPoliceVehicle(PlayerPedId()) then
                if radar.shown then
                    radar.shown = false
                else
                    radar.shown = true
                end
            end

            if IsControlJustPressed(1,301) and IsPedInAnyPoliceVehicle(PlayerPedId()) then
                if radar.freeze then
                    radar.freeze = false
                else
                    radar.freeze = true
                end
            end

            if radar.shown then
                if radar.freeze == false then
                    local veh = GetVehiclePedIsIn(PlayerPedId(),false)
                    local coordA = GetOffsetFromEntityInWorldCoords(veh,0.0,1.0,1.0)
                    local coordB = GetOffsetFromEntityInWorldCoords(veh,0.0,105.0,0.0)
                    local frontcar = StartShapeTestCapsule(coordA,coordB,3.0,10,veh,7)
                    local a,b,c,d,e = GetShapeTestResult(frontcar)

                    if IsEntityAVehicle(e) then
                        local fmodel = GetDisplayNameFromVehicleModel(GetEntityModel(e))
                        local fvspeed = GetEntitySpeed(e)*2.236936
                        local fplate = GetVehicleNumberPlateText(e)
                        radar.info = string.format("~y~PLACA: ~w~%s   ~y~MODELO: ~w~%s   ~y~VELOCIDADE: ~w~%s MPH",fplate,fmodel,math.ceil(fvspeed))
                    end

                    local bcoordB = GetOffsetFromEntityInWorldCoords(veh,0.0,-105.0,0.0)
                    local rearcar = StartShapeTestCapsule(coordA,bcoordB,3.0,10,veh,7)
                    local f,g,h,i,j = GetShapeTestResult(rearcar)

                    if IsEntityAVehicle(j) then
                        local bmodel = GetDisplayNameFromVehicleModel(GetEntityModel(j))
                        local bvspeed = GetEntitySpeed(j)*2.236936
                        local bplate = GetVehicleNumberPlateText(j)
                        radar.info2 = string.format("~y~PLACA: ~w~%s   ~y~MODELO: ~w~%s   ~y~VELOCIDADE: ~w~%s MPH",bplate,bmodel,math.ceil(bvspeed))
                    end
                end
                drawTxt(radar.info,4,0.5,0.905,0.50,255,255,255,180)
                drawTxt(radar.info2,4,0.5,0.93,0.50,255,255,255,180)
            end

            if not IsPedInAnyVehicle(PlayerPedId()) and radar.shown then
                radar.shown = false
            end
        end
        Citizen.Wait(time)
	end
end)
----------------------------------------------------------------------------------------------------------------------------------------
-- NOTIFY MENU
----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('npush', function(source,args)
    if vSERVER.checkPermission() then
        TriggerEvent('OpenNotifyPush')
    end
end)

RegisterKeyMapping("npush","Abrir notificações policia","keyboard","1")

----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE FICHA CRIMINAL
----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("tablet",function(source,args)
	if vSERVER.checkPermission() then
		SetNuiFocus(true,true)
		SendNUIMessage({ action = "showMenu" })
	end
end)


RegisterNUICallback("fichaClose",function(data,cb)
	SetNuiFocus(false,false)
	SendNUIMessage({ action = "hideMenu" })
end)

RegisterNUICallback("infoUser",function(data,cb)
	local tickets,name,lastname,identity,age,arrests,warnings = vSERVER.infoUser(data.user)
	cb({ tickets = tickets, name = name, lastname = lastname, identity = identity, age = age, arrests = arrests, warnings = warnings })
end)

RegisterNUICallback("arrestsUser",function(data,cb)
	local arrests = vSERVER.arrestsUser(data.user)
	if arrests then
		cb({ arrests = arrests })
	end
end)

RegisterNUICallback("arrestUser",function(data,cb)
	if data.user then
		vSERVER.addPrisao(data.user, data.info, data.officer, data.value)
	end
end)

RegisterNUICallback("ticketsUser",function(data,cb)
	local tickets = vSERVER.ticketsUser(data.user)
	if tickets then
		cb({ tickets = tickets })
	end
end)

RegisterNUICallback("ticketUser",function(data,cb)
	if data.user then
		vSERVER.addMulta(data.user, data.info, data.officer, data.value)
	end
end)

RegisterNUICallback("warningsUser",function(data,cb)
	local warnings = vSERVER.warningsUser(data.user)
	if warnings then
		cb({ warnings = warnings })
	end
end)




----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------
function src.checkSexo()
    if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
        return "H" 
    elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
        return "M"
    end
end

function src.retirarMascara()
    SetPedComponentVariation(PlayerPedId(), 1, 0,0,2)
end

function src.updateWeapons()
    vRPserver.updateWeapons(vRP.getWeapons())
    vRPserver.updateArmor(vRP.getArmour())
end

function DrawText3Ds(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,150)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text))/370
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,80)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTROS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	SetNuiFocus(false,false)
end)

Citizen.CreateThread(function()
    while true do
        local time = 1000
        for k,v in pairs(delayServico) do
            if v >= 0 then
                delayServico[k] = v - 1

                if v <= 0 then
                    delayServico[k] = nil
                end
            end
        end

        Citizen.Wait(time)
    end
end)

Citizen.CreateThread(function()
    while true do
        local time = 1000

        if segundos > 0 then
            segundos = segundos - 1
        end

        Citizen.Wait(time)
    end
end)

function drawTxt(text,font,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end
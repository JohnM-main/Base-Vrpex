local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP","vrp_player")

src = {}
Tunnel.bindInterface("vrp_player",src)
vSERVER = Tunnel.getInterface("vrp_player")

function src.updateWeapons()
    vRPserver.updateWeapons(vRP.getWeapons())
    vRPserver.updateArmor(vRP.getArmour())
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- cor carro
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vcolorv")
AddEventHandler("vcolorv",function(veh,r,g,b)
    if IsEntityAVehicle(veh) then
        SetVehicleCustomPrimaryColour(veh,r,g,b)
    end
end)
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COLOCAR FOGO EM ALGUÉM 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('FOGO')
AddEventHandler('FOGO',function(source)
    local ped = PlayerPedId(-1)
    if not kravinho then
        kravinho = true
        Citizen.Wait(100)
        StartEntityFire(ped);
    else
        kravinho = false
        StopEntityFire(ped);
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DISCORD API
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local players = vSERVER.CheckPlayers()
        SetDiscordAppId("SEU ID, RETIRAR ASPAS DUPLAS")
        SetDiscordRichPresenceAssetText('discord.gg/XXX')
        SetDiscordRichPresenceAsset("logo")
        SetRichPresence("Jogando Mirtin Base")
        SetDiscordRichPresenceAction(1, "Discord", "https://discord.gg/XXX")
        Citizen.Wait(60*1000)
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTADOR DE SALARIO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		vSERVER.rCountSalario()
		Citizen.Wait(60*1000)
	end
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LIMITADOR DE VELOCIDADE VEICULOS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread( function()
	while true do 
		local time = 1000
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		local speed = GetEntitySpeed(vehicle) * 3.6

		if speed >= 300 then
			local maxSpeed = 400.0 / 3.6
			SetEntityMaxSpeed(GetVehiclePedIsIn(GetPlayerPed(-1), false), maxSpeed)
		end

		Citizen.Wait(time) 
	end
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EMPURRAR E CAIR
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
        local time = 500
        
        if IsPedJumping(PlayerPedId()) then
            time = 5
            if IsControlJustReleased(0,51) then
                if not IsPedInAnyVehicle(PlayerPedId()) then
                    local ForwardVector = GetEntityForwardVector(PlayerPedId())
                    local Tackled = {}

                    SetEntityHealth(PlayerPedId(),GetEntityHealth(PlayerPedId())-10)
                    SetPedToRagdollWithFall(PlayerPedId(),1500,2000,0,ForwardVector,1.0,0.0,0.0,0.0,0.0,0.0,0.0)

                    while IsPedRagdoll(PlayerPedId()) do
                        Citizen.Wait(1)
                        for Key,Value in ipairs(GetTouchedPlayers()) do
                            if not Tackled[Value] then
                                Tackled[Value] = true
                                vSERVER.TackleServerPlayer(GetPlayerServerId(Value),ForwardVector.x,ForwardVector.y,ForwardVector.z,GetPlayerName(PlayerId()))
                            end
                        end
                    end
                end
            end
        end

        Citizen.Wait(time)
	end
end)

function src.TackleClientPlayer(ForwardVectorX,ForwardVectorY,ForwardVectorZ,Tackler)
    SetPedToRagdollWithFall(PlayerPedId(),1500,1500,0,ForwardVectorX,ForwardVectorY,ForwardVectorZ,10.0,0.0,0.0,0.0,0.0,0.0,0.0)
end

function GetPlayers()
    local Players = {}
    for i = 0,256 do
        if NetworkIsPlayerActive(i) then
            table.insert(Players,i)
        end
    end
    return Players
end

function GetTouchedPlayers()
    local TouchedPlayer = {}
    for Key,Value in ipairs(GetPlayers()) do
		if IsEntityTouchingEntity(PlayerPedId(),GetPlayerPed(Value)) then
			table.insert(TouchedPlayer,Value)
		end
    end
    return TouchedPlayer
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TROCAR DE BANCO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.seatPlayer(index)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsUsing(ped)

    if IsEntityAVehicle(vehicle) and IsPedInAnyVehicle(ped) then
        if parseInt(index) <= 1 or index == nil then
            seat = -1
        elseif parseInt(index) == 2 then
            seat = 0
        elseif parseInt(index) == 3 then
            seat = 1
        elseif parseInt(index) == 4 then
            seat = 2
        elseif parseInt(index) == 5 then
            seat = 3
        elseif parseInt(index) == 6 then
            seat = 4
        elseif parseInt(index) == 7 then
            seat = 5
        elseif parseInt(index) >= 8 then
            seat = 6
        end

        if IsVehicleSeatFree(vehicle,seat) then
            SetPedIntoVehicle(ped,vehicle,seat)
        end
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- /TOW
-----------------------------------------------------------------------------------------------------------------------------------------
local reboque = nil
local rebocado = nil
RegisterCommand("tow",function(source,args)
    local vehicle = GetPlayersLastVehicle()
    local vehicletow = IsVehicleModel(vehicle,GetHashKey("flatbed"))

    if vehicletow and not IsPedInAnyVehicle(PlayerPedId()) then
        rebocado = getVehicleInDirection(GetEntityCoords(PlayerPedId()),GetOffsetFromEntityInWorldCoords(PlayerPedId(),0.0,5.0,0.0))
        if IsEntityAVehicle(vehicle) and IsEntityAVehicle(rebocado) then
            TriggerServerEvent("trytow",VehToNet(vehicle),VehToNet(rebocado))
        end
    end
end)

RegisterNetEvent('synctow')
AddEventHandler('synctow',function(vehid,rebid)
    if NetworkDoesNetworkIdExist(vehid) and NetworkDoesNetworkIdExist(rebid) then
        local vehicle = NetToVeh(vehid)
        local rebocado = NetToVeh(rebid)
        if DoesEntityExist(vehicle) and DoesEntityExist(rebocado) then
            if reboque == nil then
                if vehicle ~= rebocado then
                    local min,max = GetModelDimensions(GetEntityModel(rebocado))
                    AttachEntityToEntity(rebocado,vehicle,GetEntityBoneIndexByName(vehicle,"bodyshell"),0,-2.2,0.4-min.z,0,0,0,1,1,0,1,0,1)
                    reboque = rebocado
                end
            else
                AttachEntityToEntity(reboque,vehicle,20,-0.5,-15.0,-0.3,0.0,0.0,0.0,false,false,true,false,20,true)
                DetachEntity(reboque,false,false)
                PlaceObjectOnGroundProperly(reboque)
                reboque = nil
                rebocado = nil
            end
        end
    end
end)

function getVehicleInDirection(coordsfrom,coordsto)
	local handle = CastRayPointToPoint(coordsfrom.x,coordsfrom.y,coordsfrom.z,coordsto.x,coordsto.y,coordsto.z,10,PlayerPedId(),false)
	local a,b,c,d,vehicle = GetRaycastResult(handle)
	return vehicle
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- GARAGEM
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local garagens = {
    { 213.90,-809.08,31.01},
    { 596.69,91.42,93.12},
    { 275.41,-345.24,45.17},
    { 56.08,-876.53,30.65},
    { -348.95,-874.39,31.31},
    { -340.64,266.31,85.67},
    { -773.59,5597.57,33.60},
    { 317.17,2622.99,44.45},
    { 459.6,-986.55,25.7},
    { -1184.93,-1509.98,4.64},
	{ 55.43, -876.19, 30.66},
	{ 213.9, -809.08, 31.01},
	{ 100.78, -1073.53, 29.38},
	{ -101.66, 6344.92, 31.58},
	{ -823.51, -1171.97, 7.18},
	{ -1526.09, 889.49, 181.84},
	{ 1628.26,4602.22,52.69},
	{ 984.75,-206.59,71.07},
	{ -1288.73,620.83,139.17},
	{ 2034.44,3411.22,44.69},
	{ 1708.27,1103.8,124.17},
	{ -23.93,2780.23,57.8},
	{ 484.34,-3111.83,6.34},
	{ -73.53,2158.11,132.95},
	{ 1377.04,-114.04,125.44},
    { -73.32,-2004.20,18.27}
}

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local x,y,z = table.unpack(GetEntityCoords(ped))
    
        if z < -110 then
            if IsPedInAnyVehicle(ped) then
                teleportPlayerProxmityCoords(x,y,z)
                TriggerEvent('Notify', 'negado', 'Você caiu no limbo com seu veiculo e foi teleportado para a garagem mais proxima.', 5)
            end
        end

        Citizen.Wait(1000)
    end
end)

function teleportPlayerProxmityCoords(x,y,z)
    local array = {}
    local coordenadas = {}

    for k,v in pairs(garagens) do
        local distanceAtual = parseInt(Vdist2(v[1],v[2],v[3], td(x),td(y),td(z)))
        table.insert(array, distanceAtual)
        coordenadas[distanceAtual] = { x = v[1], y = v[2], z = v[3] }
    end

    if coordenadas[math.min(table.unpack(array))] then
        SetEntityCoords(PlayerPedId(),coordenadas[math.min(table.unpack(array))].x,coordenadas[math.min(table.unpack(array))].y,coordenadas[math.min(table.unpack(array))].z)
    end

end

function td(n)
    n = math.ceil(n * 100) / 100
    return n
end 

-----------------------------------------------------------------------------------------------------------------------------------------
-- [ ATTACHS ]---------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("attachs",function(source,args)
	local ped = PlayerPedId()
    if vSERVER.checkAttachs() then
        if GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_COMBATPISTOL") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_COMBATPISTOL"),GetHashKey("COMPONENT_AT_PI_FLSH"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_SMG") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SMG"),GetHashKey("COMPONENT_AT_AR_FLSH"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SMG"),GetHashKey("COMPONENT_AT_SCOPE_MACRO_02"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_COMBATPDW") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_COMBATPDW"),GetHashKey("COMPONENT_AT_AR_FLSH"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_COMBATPDW"),GetHashKey("COMPONENT_AT_SCOPE_SMALL"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_COMBATPDW"),GetHashKey("COMPONENT_AT_AR_AFGRIP"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_PUMPSHOTGUN_MK2") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_PUMPSHOTGUN_MK2"),GetHashKey("COMPONENT_AT_SIGHTS"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_PUMPSHOTGUN_MK2"),GetHashKey("COMPONENT_AT_SCOPE_SMALL_MK2"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_PUMPSHOTGUN_MK2"),GetHashKey("COMPONENT_AT_AR_FLSH"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_CARBINERIFLE") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE"),GetHashKey("COMPONENT_AT_AR_FLSH"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE"),GetHashKey("COMPONENT_AT_AR_AFGRIP"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE"),GetHashKey("COMPONENT_AT_SCOPE_MEDIUM"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_MICROSMG") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_MICROSMG"),GetHashKey("COMPONENT_AT_PI_FLSH"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_MICROSMG"),GetHashKey("COMPONENT_AT_SCOPE_MACRO"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_ASSAULTRIFLE") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_ASSAULTRIFLE"),GetHashKey("COMPONENT_AT_AR_FLSH"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_ASSAULTRIFLE"),GetHashKey("COMPONENT_AT_SCOPE_MACRO"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_ASSAULTRIFLE"),GetHashKey("COMPONENT_AT_AR_AFGRIP"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_ASSAULTRIFLE"),GetHashKey("COMPONENT_ASSAULTRIFLE_VARMOD_LUXE"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_PISTOL_MK2") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_PISTOL_MK2"),GetHashKey("COMPONENT_AT_PI_RAIL"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_PISTOL_MK2"),GetHashKey("COMPONENT_AT_PI_FLSH_02"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_PISTOL_MK2"),GetHashKey("COMPONENT_AT_PI_COMP"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_REVOLVER_MK2") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_REVOLVER_MK2"),GetHashKey("COMPONENT_AT_PI_FLSH"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_REVOLVER_MK2"),GetHashKey("COMPONENT_AT_SIGHTS"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_REVOLVER_MK2"),GetHashKey("COMPONENT_REVOLVER_MK2_CAMO_IND_01"))	
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_ASSAULTSMG") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_ASSAULTSMG"),GetHashKey("COMPONENT_AT_AR_FLSH"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_ASSAULTSMG"),GetHashKey("COMPONENT_AT_SCOPE_MACRO"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_ASSAULTSMG"),GetHashKey("COMPONENT_ASSAULTSMG_VARMOD_LOWRIDER"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_PISTOL") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_PISTOL"),GetHashKey("COMPONENT_AT_PI_FLSH"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_CARBINERIFLE_MK2") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE_MK2"),GetHashKey("COMPONENT_SPECIALCARBINE_MK2_CLIP_02"))	
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE_MK2"),GetHashKey("COMPONENT_AT_MUZZLE_06"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE_MK2"),GetHashKey("COMPONENT_AT_SIGHTS"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE_MK2"),GetHashKey("COMPONENT_AT_SCOPE_MEDIUM_MK2"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE_MK2"),GetHashKey("COMPONENT_AT_AR_FLSH"))
            
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_SPECIALCARBINE") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE"),GetHashKey("COMPONENT_AT_AR_FLSH"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE"),GetHashKey("COMPONENT_AT_SCOPE_MEDIUM"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE"),GetHashKey("COMPONENT_AT_AR_AFGRIP"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE"),GetHashKey("COMPONENT_SPECIALCARBINE_CLIP_01"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_CARBINERIFLE_MK2") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE_MK2"),GetHashKey("COMPONENT_AT_SIGHTS"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE_MK2"),GetHashKey("COMPONENT_AT_MUZZLE_04"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE_MK2"),GetHashKey("COMPONENT_AT_AR_AFGRIP_02"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_CARBINERIFLE_MK2"),GetHashKey("COMPONENT_AT_AR_FLSH"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_ASSAULTRIFLE_MK2") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_ASSAULTRIFLE_MK2"),GetHashKey("COMPONENT_AT_AR_FLSH"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_ASSAULTRIFLE_MK2"),GetHashKey("COMPONENT_AT_SCOPE_MEDIUM_MK2"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_ASSAULTRIFLE_MK2"),GetHashKey("COMPONENT_AT_AR_AFGRIP_02"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_ASSAULTRIFLE_MK2"),GetHashKey("COMPONENT_AT_MUZZLE_01"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_BULLPUPRIFLE_MK2") then
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_BULLPUPRIFLE_MK2"),GetHashKey("COMPONENT_BULLPUPRIFLE_MK2_CLIP_01"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_BULLPUPRIFLE_MK2"),GetHashKey("COMPONENT_AT_AR_FLSH"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_BULLPUPRIFLE_MK2"),GetHashKey("COMPONENT_AT_SIGHTS"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_BULLPUPRIFLE_MK2"),GetHashKey("COMPONENT_AT_MUZZLE_04"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_BULLPUPRIFLE_MK2"),GetHashKey("COMPONENT_AT_BP_BARREL_01"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_BULLPUPRIFLE_MK2"),GetHashKey("COMPONENT_AT_AR_AFGRIP_02"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_BULLPUPRIFLE_MK2"),GetHashKey("COMPONENT_BULLPUPRIFLE_MK2_CAMO_09"))
		elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_HEAVYSNIPER_MK2") then	
			GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_HEAVYSNIPER_MK2"),GetHashKey("COMPONENT_AT_SR_SUPP_03"))
			GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_HEAVYSNIPER_MK2"),GetHashKey("COMPONENT_HEAVYSNIPER_MK2_CAMO_04"))
			GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_HEAVYSNIPER_MK2"),GetHashKey("COMPONENT_HEAVYSNIPER_MK2_CLIP_02"))
			GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_HEAVYSNIPER_MK2"),GetHashKey("COMPONENT_AT_SCOPE_THERMAL"))
        elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_SPECIALCARBINE_MK2") then	
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE_MK2"),GetHashKey("COMPONENT_AT_AR_FLSH"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE_MK2"),GetHashKey("COMPONENT_AT_AR_AFGRIP_02"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE_MK2"),GetHashKey("COMPONENT_AT_SCOPE_MEDIUM_MK2"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE_MK2"),GetHashKey("COMPONENT_SPECIALCARBINE_MK2_CLIP_01"))
            GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE_MK2"),GetHashKey("COMPONENT_AT_MUZZLE_04"))
        end
    end
end)

--------------------------------------------------------------------------------------------------------------------------------
--- COR NA ARMA COM PERMISSAO ------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('changeWeaponColor')
AddEventHandler('changeWeaponColor', function(cor) 
    local tinta = tonumber(cor)
    local ped = PlayerPedId()
    local arma = GetSelectedPedWeapon(ped)
    if tinta >= 0 then
        SetPedWeaponTintIndex(ped,arma,tinta)
    end
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- /FPS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("fps",function(source,args)
    if args[1] == nil then
        TriggerEvent("Notify","sucesso","Escolha qual o nivel de Boost voce deseja: </br>1 - /fps ultra</br>  2 - /fps medio</br> 3 - /fps baixo</br> 4- /fps off", "") 
    elseif args[1] == "on" then
        TriggerEvent("Notify","sucesso","Escolha qual o nivel de Boost voce deseja: </br>1 - /fps ultra</br>  2 - /fps medio</br> 3 - /fps baixo</br> 4- /fps off", "") 

   elseif args[1] == "ultra" then
        SetTimecycleModifier("cinema")
        RopeDrawShadowEnabled(false)
        CascadeShadowsClearShadowSampleType()
        CascadeShadowsSetAircraftMode(false)
        CascadeShadowsEnableEntityTracker(true)
        CascadeShadowsSetDynamicDepthMode(false)
        CascadeShadowsSetEntityTrackerScale(0.0)
        CascadeShadowsSetDynamicDepthValue(0.0)
        CascadeShadowsSetCascadeBoundsScale(0.0)
        SetFlashLightFadeDistance(0.0)
        SetLightsCutoffDistanceTweak(0.0)
        DistantCopCarSirens(false)
        TriggerEvent("Notify","sucesso","Boost de fps ultra ligado!", "")

    elseif args[1] == "medio" then
        SetTimecycleModifier("cinema")
        RopeDrawShadowEnabled(false)
        CascadeShadowsClearShadowSampleType()
        CascadeShadowsSetAircraftMode(false)
        CascadeShadowsEnableEntityTracker(true)
        CascadeShadowsSetDynamicDepthMode(false)
        CascadeShadowsSetEntityTrackerScale(0.0)
        CascadeShadowsSetDynamicDepthValue(0.0)
        CascadeShadowsSetCascadeBoundsScale(0.0)
        SetFlashLightFadeDistance(0.0)
        SetLightsCutoffDistanceTweak(0.0)
        DistantCopCarSirens(false)
        TriggerEvent("Notify","sucesso","Boost de fps mediano ligado!", "")

    elseif args[1] == "baixo" then
        RopeDrawShadowEnabled(true)
        CascadeShadowsClearShadowSampleType()
        CascadeShadowsSetAircraftMode(false)
        CascadeShadowsEnableEntityTracker(true)
        CascadeShadowsSetDynamicDepthMode(false)
        CascadeShadowsSetEntityTrackerScale(5.0)
        CascadeShadowsSetDynamicDepthValue(3.0)
        CascadeShadowsSetCascadeBoundsScale(3.0)
        SetFlashLightFadeDistance(3.0)
        SetLightsCutoffDistanceTweak(3.0)
        DistantCopCarSirens(false)
        SetArtificialLightsState(false)
        TriggerEvent("Notify","sucesso","Boost de fps baixo ligado!", "")

    elseif args[1] == "off" then
        SetTimecycleModifier("default")
        RopeDrawShadowEnabled(true)
        CascadeShadowsSetAircraftMode(true)
        CascadeShadowsEnableEntityTracker(false)
        CascadeShadowsSetDynamicDepthMode(true)
        CascadeShadowsSetEntityTrackerScale(5.0)
        CascadeShadowsSetDynamicDepthValue(5.0)
        CascadeShadowsSetCascadeBoundsScale(5.0)
        SetFlashLightFadeDistance(10.0)
        SetLightsCutoffDistanceTweak(10.0)
        DistantCopCarSirens(true)
        SetArtificialLightsState(false)
        TriggerEvent("Notify","sucesso","Boost de fps desligado!")
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- /VTUNING
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("vtuning",function(source,args)
	local vehicle = vRP.getNearestVehicle(3)
	if IsEntityAVehicle(vehicle) then
		local motor = GetVehicleMod(vehicle,11)
		local freio = GetVehicleMod(vehicle,12)
		local transmissao = GetVehicleMod(vehicle,13)
		local suspensao = GetVehicleMod(vehicle,15)
		local blindagem = GetVehicleMod(vehicle,16)
		local body = GetVehicleBodyHealth(vehicle)
		local engine = GetVehicleEngineHealth(vehicle)
		local fuel = GetVehicleFuelLevel(vehicle)

		if motor == -1 then
			motor = "Desativado"
		elseif motor == 0 then
			motor = "Nível 1 / "..GetNumVehicleMods(vehicle,11)
		elseif motor == 1 then
			motor = "Nível 2 / "..GetNumVehicleMods(vehicle,11)
		elseif motor == 2 then
			motor = "Nível 3 / "..GetNumVehicleMods(vehicle,11)
		elseif motor == 3 then
			motor = "Nível 4 / "..GetNumVehicleMods(vehicle,11)
		elseif motor == 4 then
			motor = "Nível 5 / "..GetNumVehicleMods(vehicle,11)
		end

		if freio == -1 then
			freio = "Desativado"
		elseif freio == 0 then
			freio = "Nível 1 / "..GetNumVehicleMods(vehicle,12)
		elseif freio == 1 then
			freio = "Nível 2 / "..GetNumVehicleMods(vehicle,12)
		elseif freio == 2 then
			freio = "Nível 3 / "..GetNumVehicleMods(vehicle,12)
		end

		if transmissao == -1 then
			transmissao = "Desativado"
		elseif transmissao == 0 then
			transmissao = "Nível 1 / "..GetNumVehicleMods(vehicle,13)
		elseif transmissao == 1 then
			transmissao = "Nível 2 / "..GetNumVehicleMods(vehicle,13)
		elseif transmissao == 2 then
			transmissao = "Nível 3 / "..GetNumVehicleMods(vehicle,13)
		elseif transmissao == 3 then
			transmissao = "Nível 4 / "..GetNumVehicleMods(vehicle,13)
		end

		if suspensao == -1 then
			suspensao = "Desativado"
		elseif suspensao == 0 then
			suspensao = "Nível 1 / "..GetNumVehicleMods(vehicle,15)
		elseif suspensao == 1 then
			suspensao = "Nível 2 / "..GetNumVehicleMods(vehicle,15)
		elseif suspensao == 2 then
			suspensao = "Nível 3 / "..GetNumVehicleMods(vehicle,15)
		elseif suspensao == 3 then
			suspensao = "Nível 4 / "..GetNumVehicleMods(vehicle,15)
		end

		if blindagem == -1 then
			blindagem = "Desativado"
		elseif blindagem == 0 then
			blindagem = "Nível 1 / "..GetNumVehicleMods(vehicle,16)
		elseif blindagem == 1 then
			blindagem = "Nível 2 / "..GetNumVehicleMods(vehicle,16)
		elseif blindagem == 2 then
			blindagem = "Nível 3 / "..GetNumVehicleMods(vehicle,16)
		elseif blindagem == 3 then
			blindagem = "Nível 4 / "..GetNumVehicleMods(vehicle,16)
		elseif blindagem == 4 then
			blindagem = "Nível 5 / "..GetNumVehicleMods(vehicle,16)
		end

		TriggerEvent("Notify","importante","<b>Motor:</b> "..motor.."<br><b>Freio:</b> "..freio.."<br><b>Transmissão:</b> "..transmissao.."<br><b>Suspensão:</b> "..suspensao.."<br><b>Blindagem:</b> "..blindagem.."<br><b>Chassi:</b> "..parseInt(body/10).."%<br><b>Engine:</b> "..parseInt(engine/10).."%<br><b>Gasolina:</b> "..parseInt(fuel).."%", 15)
	end
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE PUXAR A ARMA
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local data = {		
	["peds"] = {
	  ["mp_m_freemode_01"] = { ["components"] = { [7] = { [1] = 3, [6] = 5, [8] = 2, [42] = 43, [110] = 111, [119] = 120 }, [8] = { [16] = 18 } } },
	  ["mp_f_freemode_01"] = { ["components"] = { [7] = { [1] = 3, [6] = 5, [8] = 2, [29] = 30, [81] = 82 }, [8] = { [9] = 10 } } },
	}
}

local default_weapon = GetHashKey(data.weapon)
local active = false
local ped = nil
local currentPedData = nil
local holstered = true

local skins = {
	"mp_m_freemode_01",
	"mp_f_freemode_01",
}

local weapons = { 
	"WEAPON_SNSPISTOL_MK2",
	"WEAPON_PISTOL_MK2",
	"WEAPON_MACHINEPISTOL",
	"WEAPON_SMG_MK2",
	"WEAPON_SMG",
	"WEAPON_COMBATPDW",
	"WEAPON_ASSAULTSMG",
	"WEAPON_SAWNOFFSHOTGUN",
	"AMMO_PUMPSHOTGUN_MK2",
	"WEAPON_ASSAULTRIFLE_MK2",
	"WEAPON_SPECIALCARBINE_MK2",
	"WEAPON_CARBINERIFLE",
	"WEAPON_SPECIALCARBINE",
	"WEAPON_STUNGUN"
}

Citizen.CreateThread(function()
	while true do
		local time = 650
		local ped = PlayerPedId()
		if DoesEntityExist( ped ) and not IsEntityDead( ped ) and not IsPedInAnyVehicle(PlayerPedId(), true) and CheckSkin(ped) then
			loadAnimDict( "rcmjosh4" )
			loadAnimDict( "weapons@pistol@" )
			if CheckWeapon(ped) then
				time = 200
				if holstered then
                    if vSERVER.checkCommandsC() then
					    TaskPlayAnim(ped, "rcmjosh4", "josh_leadout_cop2", 8.0, 2.0, -1, 48, 10, 0, 0, 0 )
                        Citizen.Wait(600)
                        ClearPedTasks(ped)
                    end
					holstered = false
				end
			elseif not CheckWeapon(ped) then
				time = 200
				if not holstered then
                    if vSERVER.checkCommandsC() then
                        TaskPlayAnim(ped, "weapons@pistol@", "aim_2_holster", 8.0, 2.0, -1, 48, 10, 0, 0, 0 )
                        Citizen.Wait(500)
                        ClearPedTasks(ped)
                    end

					holstered = true
				end
			end
		end

		Citizen.Wait(time)
	end
end)

function table_invert(t)
  local s={}
  for k,v in pairs(t) do
    s[v]=k
  end
  return s
end

function CheckSkin(ped)
	for i = 1, #skins do
		if GetHashKey(skins[i]) == GetEntityModel(ped) then
			return true
		end
	end
	return false
end

function CheckWeapon(ped)
	for i = 1, #weapons do
		if GetHashKey(weapons[i]) == GetSelectedPedWeapon(ped) then
			return true
		end
	end
	return false
end

function DisableActions(ped)
	DisableControlAction(1, 37, true)
	DisablePlayerFiring(ped, true)
end

function loadAnimDict( dict )
	while ( not HasAnimDictLoaded( dict ) ) do
		RequestAnimDict( dict )
		Citizen.Wait( 0 )
	end
end

Citizen.CreateThread(function()
  while true do
    ped = GetPlayerPed(-1)
    local ped_hash = GetEntityModel(ped)
    local enable = false 
    for ped, data in pairs(data.peds) do
      if GetHashKey(ped) == ped_hash then 
        enable = true
        if data.enabled ~= nil then
          enable = data.enabled
        end
        currentPedData = data
        break
      end
    end
    active = enable
    Citizen.Wait(5000)
  end
end)

local last_weapon = nil
Citizen.CreateThread(function()
  while true do
    if active then
      current_weapon = GetSelectedPedWeapon(ped)
      if current_weapon ~= last_weapon then
        
        for component, holsters in pairs(currentPedData.components) do
          local holsterDrawable = GetPedDrawableVariation(ped, component)
          local holsterTexture = GetPedTextureVariation(ped, component)

          local emptyHolster = holsters[holsterDrawable]
          if emptyHolster and current_weapon == default_weapon then
            SetPedComponentVariation(ped, component, emptyHolster, holsterTexture, 0)
            break
          end

          local filledHolster = table_invert(holsters)[holsterDrawable]
          if filledHolster and current_weapon ~= default_weapon and last_weapon == default_weapon then
            SetPedComponentVariation(ped, component, filledHolster, holsterTexture, 0)
            break
          end
        end
      end
      last_weapon = current_weapon
    end
    Citizen.Wait(500)
  end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- PRESSME
-----------------------------------------------------------------------------------------------------------------------------------------
local showMe = {}
RegisterNetEvent("vrp_player:pressMe")
AddEventHandler("vrp_player:pressMe",function(source,text,v)
	local pedSource = GetPlayerFromServerId(source)
	if pedSource ~= -1 then
		showMe[GetPlayerPed(pedSource)] = { text,v[1],v[2],v[3],v[4],v[5] }
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- THREADSHOWMEDISPLAY
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local timeDistance = 1000
		local ped = PlayerPedId()
		local coords = GetEntityCoords(ped)
		for k,v in pairs(showMe) do
			local coordsMe = GetEntityCoords(k)
			local distance = #(coords - coordsMe)
			if distance <= 5 then
				timeDistance = 5
				if HasEntityClearLosToEntity(ped,k,17) then
					showMe3D(coordsMe.x,coordsMe.y,coordsMe.z+0.3,string.upper(v[1]),v[3],v[4],v[5],v[6])
				end
			end
		end

		Citizen.Wait(timeDistance)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- TRHEADSHOWMETIMER
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		for k,v in pairs(showMe) do
			if v[2] > 0 then
				v[2] = v[2] - 1
				if v[2] <= 0 then
					showMe[k] = nil
				end
			end
		end
		Citizen.Wait(1000)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SHOWME3D
-----------------------------------------------------------------------------------------------------------------------------------------
function showMe3D(x,y,z,text,h,back,color,opacity)
	SetTextFont(4)
	SetTextCentre(1)
	SetTextEntry("STRING")
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,150)
	AddTextComponentString(text)
	SetDrawOrigin(x,y,z,0)
	DrawText(0.0,0.0)
	local factor = (string.len(text) / 375) + 0.01
	DrawRect(0.0,0.0125,factor,0.03,38,42,56,200)
	ClearDrawOrigin()
end
-----------------------------------------------------------------------------------------------------------------------------------------
--[ ABRIR PORTAS DO VEICULO ]------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("portas",function(source,args)
	local vehicle = vRP.getNearestVehicle(7)
	if IsEntityAVehicle(vehicle) then
		if parseInt(args[1]) == 5 then
			TriggerServerEvent("trytrunk",VehToNet(vehicle))
		else
			TriggerServerEvent("trydoors",VehToNet(vehicle),args[1])
		end
	end
end)

RegisterNetEvent("syncdoors")
AddEventHandler("syncdoors",function(index,door)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		local isopen = GetVehicleDoorAngleRatio(v,0) and GetVehicleDoorAngleRatio(v,1)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
				if door == "1" then
					if GetVehicleDoorAngleRatio(v,0) == 0 then
						SetVehicleDoorOpen(v,0,0,0)
					else
						SetVehicleDoorShut(v,0,0)
					end
				elseif door == "2" then
					if GetVehicleDoorAngleRatio(v,1) == 0 then
						SetVehicleDoorOpen(v,1,0,0)
					else
						SetVehicleDoorShut(v,1,0)
					end
				elseif door == "3" then
					if GetVehicleDoorAngleRatio(v,2) == 0 then
						SetVehicleDoorOpen(v,2,0,0)
					else
						SetVehicleDoorShut(v,2,0)
					end
				elseif door == "4" then
					if GetVehicleDoorAngleRatio(v,3) == 0 then
						SetVehicleDoorOpen(v,3,0,0)
					else
						SetVehicleDoorShut(v,3,0)
					end
				elseif door == nil then
					if isopen == 0 then
						SetVehicleDoorOpen(v,0,0,0)
						SetVehicleDoorOpen(v,1,0,0)
						SetVehicleDoorOpen(v,2,0,0)
						SetVehicleDoorOpen(v,3,0,0)
					else
						SetVehicleDoorShut(v,0,0)
						SetVehicleDoorShut(v,1,0)
						SetVehicleDoorShut(v,2,0)
						SetVehicleDoorShut(v,3,0)
					end
				end
			end
		end
	end
end)

RegisterNetEvent("synctrunk")
AddEventHandler("synctrunk",function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		local isopen = GetVehicleDoorAngleRatio(v,5)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
				if isopen == 0 then
					SetVehicleDoorOpen(v,5,0,0)
				else
					SetVehicleDoorShut(v,5,0)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ ABRE E FECHA OS VIDROS ]-------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
local vidros = false
RegisterCommand("vidros",function(source,args)
	local vehicle = vRP.getNearestVehicle(7)
	if IsEntityAVehicle(vehicle) then
		TriggerServerEvent("trywins",VehToNet(vehicle))
	end
end)

RegisterNetEvent("syncwins")
AddEventHandler("syncwins",function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
				if vidros then
					vidros = false
					RollUpWindow(v,0)
					RollUpWindow(v,1)
					RollUpWindow(v,2)
					RollUpWindow(v,3)
				else
					vidros = true
					RollDownWindow(v,0)
					RollDownWindow(v,1)
					RollDownWindow(v,2)
					RollDownWindow(v,3)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
--[ ABRIR CAPO DO VEICULO ]--------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("capo",function(source,args)
	local vehicle = vRP.getNearestVehicle(7)
	if IsEntityAVehicle(vehicle) then
		TriggerServerEvent("tryhood",VehToNet(vehicle))
	end
end)

RegisterNetEvent("synchood")
AddEventHandler("synchood",function(index)
	if NetworkDoesNetworkIdExist(index) then
		local v = NetToVeh(index)
		local isopen = GetVehicleDoorAngleRatio(v,4)
		if DoesEntityExist(v) then
			if IsEntityAVehicle(v) then
				if isopen == 0 then
					SetVehicleDoorOpen(v,4,0,0)
				else
					SetVehicleDoorShut(v,4,0)
				end
			end
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- /SKIN
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("skinmenu")
AddEventHandler("skinmenu",function(mhash)
    while not HasModelLoaded(mhash) do
        RequestModel(mhash)
        Citizen.Wait(10)
    end

    if HasModelLoaded(mhash) then
        SetPlayerModel(PlayerId(),mhash)
        SetModelAsNoLongerNeeded(mhash)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- /FPS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("fps",function(source, args)
	if args[1] == "on" then
		FPS_COMMAND = true
		SetTimecycleModifier("cinema")
		TIME_INDEX = GetTimecycleModifierIndex()
		TimecycleThread()
		TriggerEvent("Notify", "sucesso", "Modo FPS ativado.")
	elseif args[1] == "off" then
		FPS_COMMAND = false
		SetTimecycleModifier("default")
		TriggerEvent("Notify", "negado", "Modo FPS desativado.")
	end
	SetResourceKvp("fpscommand", tostring(FPS_COMMAND))
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- EMPURRAR
-----------------------------------------------------------------------------------------------------------------------------------------
local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end
		enum.destructor = nil
		enum.handle = nil
	end
}

local function EnumerateEntities(initFunc,moveFunc,disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = { handle = iter, destructor = disposeFunc }
		setmetatable(enum, entityEnumerator)

		local next = true
		repeat
		coroutine.yield(id)
		next,id = moveFunc(iter)
		until not next

		enum.destructor,enum.handle = nil,nil
		disposeFunc(iter)
	end)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle,FindNextVehicle,EndFindVehicle)
end

function GetVeh()
    local vehicles = {}
    for vehicle in EnumerateVehicles() do
        table.insert(vehicles,vehicle)
    end
    return vehicles
end

function GetClosestVeh(coords)
	local vehicles = GetVeh()
	local closestDistance = -1
	local closestVehicle = -1
	local coords = coords

	if coords == nil then
		local ped = PlayerPedId()
		coords = GetEntityCoords(ped)
	end

	for i=1,#vehicles,1 do
		local vehicleCoords = GetEntityCoords(vehicles[i])
		local distance = GetDistanceBetweenCoords(vehicleCoords,coords.x,coords.y,coords.z,true)
		if closestDistance == -1 or closestDistance > distance then
			closestVehicle  = vehicles[i]
			closestDistance = distance
		end
	end
	return closestVehicle,closestDistance
end

local First = vector3(0.0,0.0,0.0)
local Second = vector3(5.0,5.0,5.0)
local Vehicle = { Coords = nil, Vehicle = nil, Dimension = nil, IsInFront = false, Distance = nil }

Citizen.CreateThread(function()
	while true do
		local timeDistance = 1000
		local ped = PlayerPedId()
		local closestVehicle,Distance = GetClosestVeh()
		if Distance < 3.9 and not IsPedInAnyVehicle(ped) then
			Vehicle.Coords = GetEntityCoords(closestVehicle)
			Vehicle.Dimensions = GetModelDimensions(GetEntityModel(closestVehicle),First,Second)
			Vehicle.Vehicle = closestVehicle
			Vehicle.Distance = Distance
			if GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle), GetEntityCoords(ped), true) > GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle) * -1, GetEntityCoords(ped), true) then
				Vehicle.IsInFront = false
			else
				Vehicle.IsInFront = true
			end
		else
			Vehicle = { Coords = nil, Vehicle = nil, Dimensions = nil, IsInFront = false, Distance = nil }
		end
		Citizen.Wait(timeDistance)
	end
end)

Citizen.CreateThread(function()
	while true do 
		Citizen.Wait(500)
		if Vehicle.Vehicle ~= nil and GetVehicleDoorLockStatus(Vehicle.Vehicle) == 1 then
			local ped = PlayerPedId()
			
			if GetEntityHealth(ped) > 101 and IsVehicleSeatFree(Vehicle.Vehicle,-1) and not IsEntityInWater(ped) and not IsEntityInAir(ped) and not IsPedBeingStunned(ped) and not IsEntityAttachedToEntity(ped,Vehicle.Vehicle) and not (GetEntityRoll(Vehicle.Vehicle) > 75.0 or GetEntityRoll(Vehicle.Vehicle) < -75.0) then
				Citizen.Wait(1000)
				if IsControlPressed(0,244) and IsInputDisabled(0) then
					RequestAnimDict('missfinale_c2ig_11')
					TaskPlayAnim(ped,'missfinale_c2ig_11','pushcar_offcliff_m',2.0,-8.0,-1,35,0,0,0,0)
					NetworkRequestControlOfEntity(Vehicle.Vehicle)

					if Vehicle.IsInFront then
						AttachEntityToEntity(ped,Vehicle.Vehicle,GetPedBoneIndex(6286),0.0,Vehicle.Dimensions.y*-1+0.1,Vehicle.Dimensions.z+1.0,0.0,0.0,180.0,0.0,false,false,true,false,true)
					else
						AttachEntityToEntity(ped,Vehicle.Vehicle,GetPedBoneIndex(6286),0.0,Vehicle.Dimensions.y-0.3,Vehicle.Dimensions.z+1.0,0.0,0.0,0.0,0.0,false,false,true,false,true)
					end

					while true do
						Citizen.Wait(5)
						if IsDisabledControlPressed(0,34) then
							TaskVehicleTempAction(ped,Vehicle.Vehicle,11,100)
						end

						if IsDisabledControlPressed(0,9) then
							TaskVehicleTempAction(ped,Vehicle.Vehicle,10,100)
						end

						if Vehicle.IsInFront then
							SetVehicleForwardSpeed(Vehicle.Vehicle,-1.0)
						else
							SetVehicleForwardSpeed(Vehicle.Vehicle,1.0)
						end

						if not IsDisabledControlPressed(0,244) then
							DetachEntity(ped,false,false)
							StopAnimTask(ped,'missfinale_c2ig_11','pushcar_offcliff_m',2.0)
							break
						end
					end
				end
			end
		end
	end
end)
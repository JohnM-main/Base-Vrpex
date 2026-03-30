
local in_arena = 0
local time_arena = 0
local openedCoords
local arenaCoords

local reasonDeath
local pedKiller
local Killer
local cooldown = 0
local cooldownBoard = 0
local GiveWeapons
local morto = false
local Tunnel = module("vrp","lib/Tunnel")
local src = {}
Tunnel.bindInterface("mirtin_arena",src)


local attachs = false
local setCurretWeapon = ""
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ARENA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local time = 1000

        if in_arena == 0 then
            local ped = PlayerPedId()
            local playercoords = GetEntityCoords(ped)
            local vida = GetEntityHealth(ped)

            for k,v in pairs(config.locArenas) do
                local distance = #(playercoords - v)
                if distance <= 15.0 then
                    time = 5
                    config.drawMarker(v)
                    if distance <= 2.0 then
                        if IsControlJustPressed(0,38) and vida > 101 and not LocalPlayer.state.NovatMode then
                            openedCoords = v
                            openNui()
                        end
                    end
                end
            end
        end

        Citizen.Wait(time)
    end
end)

local GiveWeapons = function(weapon)
    if in_arena <= 0 then
        return
    end
    if time_arena <= 0 then
        return
    end
    local player = PlayerPedId()

    local hash = GetHashKey(weapon)
    local ammo = 250
    
    GiveWeaponToPed(player, hash, ammo, true)
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
src.setArena = function(id, coords, weapon)
    if GetInvokingResource() then return end
    if #(GetEntityCoords(PlayerPedId()) - vec3(-1632.11,-1015.49,13.13)) > 60.0 then return end
    print('ENTRANDO NA ARENA!')
    DoScreenFadeOut(1000)
    in_arena = parseInt(id)
    setCurretWeapon = weapon

    Citizen.Wait(1000)
    SetEntityCoords(PlayerPedId(), coords[1],coords[2],coords[3])
    arenaCoords = { coords[1],coords[2],coords[3] }

    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
    time_arena = vSERVER.getTimeArena(in_arena)
    GiveWeapons(setCurretWeapon)

    async(function()
        while in_arena > 0 do
            time_arena = time_arena - 1

            if time_arena >= 0 then
                SendNUIMessage({ contadorArena = true, tempo = time_arena })
            end

            Citizen.Wait(1000)
        end
    end)

    CreateThread(function()
        while in_arena > 0 do
            local ped = PlayerPedId()
            SetCurrentPedWeapon(ped, GetHashKey(setCurretWeapon), true)

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
            elseif GetSelectedPedWeapon(ped) == GetHashKey("WEAPON_SPECIALCARBINE_MK2") then	
                GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE_MK2"),GetHashKey("COMPONENT_AT_AR_FLSH"))
                GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE_MK2"),GetHashKey("COMPONENT_AT_AR_AFGRIP_02"))
                GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE_MK2"),GetHashKey("COMPONENT_AT_SCOPE_MEDIUM_MK2"))
                GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE_MK2"),GetHashKey("COMPONENT_SPECIALCARBINE_MK2_CLIP_01"))
                GiveWeaponComponentToPed(ped,GetHashKey("WEAPON_SPECIALCARBINE_MK2"),GetHashKey("COMPONENT_AT_MUZZLE_04"))
            end

            Wait(1000)
        end
    end)
end

src.removePlayerArena = function()
    DoScreenFadeOut(1000)
    RemoveAllPedWeapons(PlayerPedId(),true)

    Wait(1000)
    in_arena = tonumber(0)
    closeAllNuis()

    Citizen.Wait(1000)
    SetEntityCoords(PlayerPedId(), openedCoords[1],openedCoords[2],openedCoords[3])

    Citizen.Wait(1000)
    DoScreenFadeIn(1000)
end

Citizen.CreateThread(function()
    while true do
        if in_arena > 0 then
            time_arena = vSERVER.getTimeArena(in_arena)
        end
        
        Citizen.Wait(60*1000)
    end
end)




------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NUIS CALL BACKS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("closeNui", function(data, cb)
	closeNui()
end)

RegisterNUICallback("entrarArena", function(data, cb)
    vSERVER.apostarArena(data.arena)
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS NUIS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function openNui()
    local arenas = vSERVER.showNuiArena()
    if arenas then
        SetNuiFocus(true,true)
		TransitionToBlurred(1000)
		SendNUIMessage({ showArena = true, arenas = arenas })
    end
end

function closeNui()
    SetNuiFocus(false, false)
    TransitionFromBlurred(1000)
    SendNUIMessage({ closeArena = true })
end

function closeAllNuis()
    SetNuiFocus(false, false)
    TransitionFromBlurred(1000)
    SendNUIMessage({ closeArena = true })
    SendNUIMessage({ closeContadorArena = true })
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTROLADOR DE KILLS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local time = 1000

        if in_arena > 0  then
            local ped = PlayerPedId()
            local vida = GetEntityHealth(ped)
            local x,y,z = table.unpack(GetEntityCoords(ped,true))
            time = 150

            if IsEntityDead(ped) then
                time = 0
                if GetPedCauseOfDeath(ped) ~= 0 and cooldown == 0 then
                    cooldown = 2
                    if not morto then
                        reasonDeath = GetPedCauseOfDeath(ped)
                        pedKiller = GetPedSourceOfDeath(ped)
        
                        if IsEntityAPed(pedKiller) and IsPedAPlayer(pedKiller) then
                            Killer = NetworkGetPlayerIndexFromPed(pedKiller)
                        elseif IsEntityAVehicle(pedKiller) and IsEntityAPed(GetPedInVehicleSeat(pedKiller, -1)) and IsPedAPlayer(GetPedInVehicleSeat(pedKiller, -1)) then
                            Killer = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(pedKiller, -1))
                        end
                        
                        sendToLog(PlayerId(), reasonDeath, Killer)
                    end
                end

                SetEntityHealth(ped, 101)
            end
			
			 if vida < 101 then
				time = 0
		
				SetEntityHealth(ped, 101)
             end

            if vida <= 101 and not morto then
                morto = true
                TriggerEvent("ragdoll:ChangeStatus", morto)
                SetEntityHealth(ped, 101)
            end

            if morto then
                time = 0

                if vida <= 101 then
                    SetPedToRagdoll(ped, 1500, 1500,0, 0, 0, 0)
                end
                
                config.drawTxt()
                if IsControlJustPressed(0, config.keys['spawn']) and morto then
                    morto = false
                    TriggerEvent("ragdoll:ChangeStatus", morto)
                    local coords,health = vSERVER.randomSpawn()
                    if coords then
                        GiveWeapons(setCurretWeapon)
                        NetworkResurrectLocalPlayer(x,y,z,true,true, false)
                        SetEntityCoords(PlayerPedId(), coords[1],coords[2],coords[3])
                        SetEntityHealth(ped, health)
                    end
                end
            end

            if arenaCoords ~= nil then
                local distance = #(GetEntityCoords(PlayerPedId()) - vec3(arenaCoords[1],arenaCoords[2],arenaCoords[3]))
                if distance >= config.rangeDistance then
                    SetEntityCoords(PlayerPedId(), arenaCoords[1],arenaCoords[2],arenaCoords[3])
                end
            end
        end
        
        Citizen.Wait(time)
    end
end)

sendToLog = function(idMorto, arma, quemMatou)
    local source = 0
    local ksource = 0

    if idMorto ~= 0 then
        source = GetPlayerServerId(idMorto)
    end

    if quemMatou ~= 0 then
        ksource = GetPlayerServerId(quemMatou)
    end
    
    if source then
        vSERVER.receberMorte(source, arma, ksource)
    end
end

function src.sendChatKill(kName, nName, arma, delay)
    SendNUIMessage({ chatKill = true, killer = kName, vitima = nName, arma = arma, delay = delay })
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SCOREBOARD
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local pressionado = false

Citizen.CreateThread(function()
    while true do
        local time = 1000
        if in_arena > 0  then
            time = 5

            if IsControlPressed(0, config.keys['scoreboard']) then
                if not pressionado and cooldownBoard <= 0 then
                    cooldownBoard = 1
                    pressionado = true
                    
                    local dados,user_list = vSERVER.scoreBoard(in_arena)
                    if dados and user_list then
                        SendNUIMessage({ scoreboard = true, dados = dados, user_list = user_list })
                    end
                end
            else
                if pressionado then
                    pressionado = false
                    SendNUIMessage({ closeScoreboard = true })
                end
            end
        end

        Citizen.Wait(time)
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTADOR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local time = 1000
        
        if cooldown > 0 then
            cooldown = cooldown - 1

            if cooldown <= 0 then
                cooldown = 0
            end
        end

        if cooldownBoard > 0 then
            cooldownBoard = cooldownBoard - 1

            if cooldownBoard <= 0 then
                cooldownBoard = 0
            end
        end

        Citizen.Wait(time)
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

function src.inArena()
    return in_arena > 0
end
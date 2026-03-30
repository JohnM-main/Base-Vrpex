local reasonDeath
local pedKiller
local Killer

local cooldown = 0
local morto = false
local deathtimer = LocalPlayer.state.NovatMode and 25 or cfg.deathtimer

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- THREAD
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
        local time = 300
		local ped = PlayerPedId()
		local vida = GetEntityHealth(ped)
		local x,y,z = table.unpack(GetEntityCoords(ped,true))

        if cfg.dependencys() then
            if IsEntityDead(ped) then
                time = 0
                if GetPedCauseOfDeath(ped) ~= 0 and cooldown == 0 then
                    cooldown = cfg.cooldown

                    reasonDeath = GetPedCauseOfDeath(ped)
                    pedKiller = GetPedSourceOfDeath(ped)

                    if IsEntityAPed(pedKiller) and IsPedAPlayer(pedKiller) then
                        Killer = NetworkGetPlayerIndexFromPed(pedKiller)
                    elseif IsEntityAVehicle(pedKiller) and IsEntityAPed(GetPedInVehicleSeat(pedKiller, -1)) and IsPedAPlayer(GetPedInVehicleSeat(pedKiller, -1)) then
                        Killer = NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(pedKiller, -1))
                    end
                    
                    sendToLog(PlayerId(), reasonDeath, Killer)
                end 

                if not morto then
                    deathtimer = LocalPlayer.state.NovatMode and 25 or cfg.deathtimer

                    local newSeconds = vSERVER.secoundsDeath()
                    if newSeconds then
                        deathtimer = newSeconds
                    end
                end


                NetworkResurrectLocalPlayer(x,y,z,true,true, false)
                SetEntityInvincible(ped,true)
                SetPedDiesInWater(ped, false)
                SetEntityHealth(ped, cfg.minHealth)
            end

            if vida <= cfg.minHealth and not morto then
                morto = true
                TriggerEvent('dynamic:closeSystem2',source)
                TriggerEvent("ragdoll:ChangeStatus", morto)

                SetEntityHealth(ped, cfg.minHealth)
                vRPserver.updateHealth(cfg.minHealth)
                TriggerEvent('mirtin_survival:updateComa', morto)
                TriggerServerEvent('pma-voice:toggleMutePlayer', true)
                SetCurrentPedWeapon(ped,GetHashKey("WEAPON_UNARMED"),true)
                TriggerEvent("pma-voice:MutePlayer")

                exports["pma-voice"]:removePlayerFromRadio()
                exports["pma-voice"]:setVoiceProperty('radioEnabled',false)
                TriggerEvent("lotus-hud:leaveFrequency", 0)
                TriggerEvent('lotus-hud:toggle', false)
            end

            if morto then
                if vida <= cfg.minHealth then
                    time = 5
                    cfg.animDeath()

                    DisableControlAction(0,199,true)
                    DisableControlAction(0,200,true)

                    if cfg.versionNUI then
                        openNui()

                        if deathtimer <= 0 then
                            if not cfg.timedown then
                                if IsControlJustPressed(0,38) then
                                    if exports['vrp_policia']:getArrest() or exports['vrp_carry']:getCarry() then 
                                        TriggerEvent("Notify",'negado','Você não pode reviver sendo arrestado/carregado.')
                                    else
                                        morrer()
                                        StopScreenEffect("DeathFailMPIn")
                                    end
                                end
                            end
                        end
                    else
                        cfg.drawtext(deathtimer)
                    end

                end

                if vida > cfg.minHealth then
                    morto = false
                    TriggerEvent("ragdoll:ChangeStatus", morto)
                    deathtimer =  cfg.deathtimer
                    SetEntityInvincible(ped,false)
                    SetPedDiesInWater(ped, true)
                    TriggerEvent('mirtin_survival:updateComa', morto)
                    StopScreenEffect("DeathFailMPIn")
                    vRPserver.updateHealth(GetEntityHealth(ped))
                    TriggerServerEvent('pma-voice:toggleMutePlayer', false)
                    TriggerEvent("pma-voice:DesmutePlayer")

                    if cfg.versionNUI then
                        closeNui()
                        TriggerEvent('lotus-hud:toggle', true)
                    end
                end

                if deathtimer <= 0 then
                    if cfg.timedown then
                        morrer()
                    end
                end
            end
        end

        Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
sendToLog = function(idMorto, motivoMorto, quemMatou)
    local source = 0
    local ksource = 0
    local motivo = ""

    if idMorto ~= 0 then
        source = GetPlayerServerId(idMorto)
    end

    if quemMatou ~= 0 then
        ksource = GetPlayerServerId(quemMatou)
    end
    
    if cfg.reasons[motivoMorto] then
        motivo = cfg.reasons[motivoMorto]
    else
        motivo= cfg.reasons[0]
    end

    vSERVER.receberMorte(source, motivo, ksource)
end

src.getPosition = function()
    return GetEntityCoords(PlayerPedId(),true)
end

src.setFinalizado = function()
    deathtimer = 0
end

morrer = function()

    Citizen.Wait(500)
    morto = false
    TriggerEvent("ragdoll:ChangeStatus", morto)

    deathtimer =  cfg.deathtimer

    StopScreenEffect("DeathFailMPIn")
    if cfg.versionNUI then
        closeNui()
    end

    TriggerEvent('mirtin_survival:updateComa', morto)
    TriggerServerEvent('pma-voice:toggleMutePlayer', false)
    DoScreenFadeOut(500)

    Citizen.Wait(2000)
    SetEntityInvincible(PlayerPedId(),false)
    SetPedDiesInWater(PlayerPedId(), true)
    ClearPedBloodDamage(PlayerPedId())

    Citizen.Wait(3000)
    SetEntityHealth(PlayerPedId(), cfg.maxHealth)
    Citizen.Wait(200)
    SetEntityCoords(PlayerPedId(), cfg.respawn)
    cfg.clearAccount()
    
    Citizen.Wait(4000)
    DoScreenFadeIn(1000)
    TriggerEvent('lotus-hud:toggle', true)
end

src.morrer2 = function()
    Citizen.Wait(500)
    SetEntityHealth(PlayerPedId(), cfg.maxHealth)
    morto = false
    TriggerEvent("ragdoll:ChangeStatus", morto)

    deathtimer =  cfg.deathtimer

    StopScreenEffect("DeathFailMPIn")
    if cfg.versionNUI then
        closeNui()
    end

    TriggerEvent('mirtin_survival:updateComa', morto)
    TriggerServerEvent('pma-voice:toggleMutePlayer', false)
    DoScreenFadeOut(500)

    Citizen.Wait(2000)
    SetPedDiesInWater(PlayerPedId(), true)
    ClearPedBloodDamage(PlayerPedId())

    Citizen.Wait(3000)
    SetEntityCoords(PlayerPedId(), cfg.respawn)
    cfg.clearAccount()
    TriggerServerEvent('pma-voice:toggleMutePlayer', false)
    
    Citizen.Wait(4000)
    DoScreenFadeIn(1000)
end

RegisterNetEvent("mirtin_survival:updateComa")

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NUI
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
openNui = function()
    SendNUIMessage({ setDisplay = true, setDisplayDead = false, deathtimer = deathtimer })
end

closeNui = function()
    SendNUIMessage({ setDisplay = false, setDisplayDead = false, deathtimer = deathtimer })
end

RegisterNUICallback('ButtonRevive', function()
    if deathtimer <= cfg.deathNUItimer then
        cfg.clearAccount()

        Wait(1000)
        morrer()
    else
        TriggerEvent("Notify","negado","Você não pode desistir de sua vida agora.", 5000)
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

        if morto then
            deathtimer = deathtimer - 1

            if deathtimer <= 0 then
                deathtimer = 0
            end
        end

        Citizen.Wait(time)
    end
end)
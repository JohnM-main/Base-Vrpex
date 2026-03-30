-----------------------------------------------------------------------------------------------------------------------------------------
-- DISPATCH
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	for i = 1,120 do
		EnableDispatchService(i,false)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- BLACKOUT
-----------------------------------------------------------------------------------------------------------------------------------------
local isBlackout = false
local oldSpeed = 0
Citizen.CreateThread(function()
	while true do
		local idle = 100
		local vehicle = GetVehiclePedIsIn(PlayerPedId())
		if IsEntityAVehicle(vehicle) and GetPedInVehicleSeat(vehicle,-1) == PlayerPedId() then
			idle = 1
			local currentSpeed = GetEntitySpeed(vehicle)*2.236936
			if currentSpeed ~= oldSpeed then
				if not isBlackout and (currentSpeed < oldSpeed) and ((oldSpeed - currentSpeed) >= 50) then
					blackout()
				end
				oldSpeed = currentSpeed
			end
		else
			if oldSpeed ~= 0 then
				oldSpeed = 0
			end
		end

		if isBlackout then
			idle = 1
			DisableControlAction(0,71,true)
			DisableControlAction(0,72,true)
			DisableControlAction(0,63,true)
			DisableControlAction(0,64,true)
			DisableControlAction(0,75,true)
		end
		Citizen.Wait(idle)
	end
end)

function blackout()
	TriggerEvent("vrp_sound:source",'heartbeat',0.5)
	if not isBlackout then
		isBlackout = true
		SetEntityHealth(PlayerPedId(),GetEntityHealth(PlayerPedId())-100)
		Citizen.CreateThread(function()
			DoScreenFadeOut(500)
			while not IsScreenFadedOut() do
				Citizen.Wait(10)
			end
			Citizen.Wait(5000)
			DoScreenFadeIn(5000)
			isBlackout = false
		end)
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- DESABILITAR A CORONHADA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
		local ped = PlayerPedId()
		local idle = 1000
		if IsPedArmed(ped,6) then
			idle = 5
            DisableControlAction(0,140,true)
            DisableControlAction(0,141,true)
            DisableControlAction(0,142,true)
		end
		Citizen.Wait(idle)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- NAO RECUPERAR VIDA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
		SetPlayerHealthRechargeMultiplier(PlayerId(),0)
		Citizen.Wait(500)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- STAMINA INFINITA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		RestorePlayerStamina(PlayerId(),1.0)
        Citizen.Wait(500)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- DESATIVAR WEAPONS NPCS E DROP
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		if GetPlayerWantedLevel(PlayerId()) ~= 0 then
            SetPlayerWantedLevel(PlayerId(), 0, false)
            SetPlayerWantedLevelNow(PlayerId(), false)
        end
        Citizen.Wait(3000)
    end
end)

Citizen.CreateThread(function()
	while true do
		local handle, ped = FindFirstPed()
		local finished = false
		repeat
			if IsPedDeadOrDying(ped) and not IsPedAPlayer(ped) then
				SetEntityAsMissionEntity(ped,true,true)
				SetEntityAsNoLongerNeeded(ped)
				local model = GetEntityModel(ped)
				SetModelAsNoLongerNeeded(model)
				SetEntityAsMissionEntity(ped,true,true)
				DeleteEntity(ped)
			end
			finished, ped = FindNextPed(handle)
			if IsPedDeadOrDying(ped) and not IsPedAPlayer(ped) then
				SetEntityAsMissionEntity(ped,true,true)
				SetEntityAsNoLongerNeeded(ped)
				local model = GetEntityModel(ped)
				SetModelAsNoLongerNeeded(model)
				SetEntityAsMissionEntity(ped,true,true)
				DeleteEntity(ped)
			end
			if not IsPedDeadOrDying(ped) and not IsPedAPlayer(ped) then
				RemoveAllPedWeapons(ped, true)
			end

		until not finished
		EndFindPed(handle)
		Citizen.Wait(60000)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FICAR NO BANCO ESCOLHIDO
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local time = 500
        if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
            time = 5
            if GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), 0) == GetPlayerPed(-1) then
                if GetIsTaskActive(GetPlayerPed(-1), 165) then
                    SetPedIntoVehicle(GetPlayerPed(-1), GetVehiclePedIsIn(GetPlayerPed(-1), false), 0)
                end
            end
        end

        Citizen.Wait(time)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ESTOURAR OS PNEUS QUANDO CAPOTA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local time = 300
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped) then
            local vehicle = GetVehiclePedIsIn(ped)
            if GetPedInVehicleSeat(vehicle,-1) == ped then
				time = 100
                local roll = GetEntityRoll(vehicle)
                if (roll > 75.0 or roll < -75.0) and GetEntitySpeed(vehicle) < 2 then
                    if IsVehicleTyreBurst(vehicle, wheel_rm1, 0) == false then
						SetVehicleTyreBurst(vehicle, 0, 1)
						Citizen.Wait(100)
						SetVehicleTyreBurst(vehicle, 1, 1)
						Citizen.Wait(100)
						SetVehicleTyreBurst(vehicle, 2, 1)
						Citizen.Wait(100)
						SetVehicleTyreBurst(vehicle, 3, 1)
						Citizen.Wait(100)
						SetVehicleTyreBurst(vehicle, 4, 1)
						Citizen.Wait(100)
						SetVehicleTyreBurst(vehicle, 5, 1)
						Citizen.Wait(100)
						SetVehicleTyreBurst(vehicle, 45, 1)
						Citizen.Wait(100)
						SetVehicleTyreBurst(vehicle, 47, 1)
                    end
                end
            end
        end

		Citizen.Wait(time)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REMOVER HUD
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
		AddTextEntry("FE_THDR_GTAO","Mirtin Base")
		AddTextEntry('PM_PANE_LEAVE', 'Sair')
		StartAudioScene("CHARACTER_CHANGE_IN_SKY_SCENE");
		SetAudioFlag("PoliceScannerDisabled",true);
		while true do
			DisableControlAction(0,44,true)
			DisableControlAction(0,36,true)
			DisableControlAction(0,157,false)
			
			N_0xf4f2c0d4ee209e20()
			N_0x4757f00bc6323cfe(GetHashKey("WEAPON_UNARMED"), 0.0) 
			N_0x4757f00bc6323cfe(-1553120962, 0.0) 
			
			HideHudComponentThisFrame(1)
			HideHudComponentThisFrame(2)
			HideHudComponentThisFrame(3)
			HideHudComponentThisFrame(4)
			HideHudComponentThisFrame(5)
			HideHudComponentThisFrame(6)
			HideHudComponentThisFrame(7)
			HideHudComponentThisFrame(8)
			HideHudComponentThisFrame(9)
			HideHudComponentThisFrame(10)
			HideHudComponentThisFrame(11)
			HideHudComponentThisFrame(12)
			HideHudComponentThisFrame(13)
			HideHudComponentThisFrame(20)
			DisableVehicleDistantlights(true)
			DisablePlayerVehicleRewards(PlayerId())
			SetPedSuffersCriticalHits(PlayerPedId(), true)
			 
			Citizen.Wait(5)
		end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- [ AUTO CAPACETE ]---------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread( function()
    while true do
		local time = 1000
        
        local veh = GetVehiclePedIsUsing(PlayerPedId())
        if veh ~= 0 then 
			time = 5
            SetPedConfigFlag(PlayerPedId(),35,false) 
        end

		Citizen.Wait(time)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- DRIFT
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		if IsPedInAnyVehicle(ped) then
			time = 5
			local vehicle = GetVehiclePedIsIn(PlayerPedId())
			local speed = GetEntitySpeed(vehicle) * 2.236936
			if GetPedInVehicleSeat(vehicle,-1) == ped then
				if speed <= 80.0 then
					if IsControlPressed(1,21) then
						SetVehicleReduceGrip(vehicle,true)
					else
						SetVehicleReduceGrip(vehicle,false)
					end
				end
			end
		end
		Citizen.Wait(time)
	end
end)

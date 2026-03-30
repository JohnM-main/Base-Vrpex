-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VRP
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP","mirtin_snippets")

src = {}
Tunnel.bindInterface("mirtin_snippets",src)
vSERVER = Tunnel.getInterface("mirtin_snippets")


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local segundos = 0
local trancas = config.doors

-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE TRANCAS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local pedCoords = GetEntityCoords(PlayerPedId())
		
		for k,v in pairs(trancas) do
			local distance = #(pedCoords - v.coords)
			if distance <= v.distance then
				time = 5
				if trancas[k].trancado[1] and trancas[k].text[1] then
					DrawText3Ds(v.coords[1],v.coords[2],v.coords[3], "[PORTA]: ~r~TRANCADA")
				else
					DrawText3Ds(v.coords[1],v.coords[2],v.coords[3], "[PORTA]: ~g~DESTRANCADA")
				end

				if distance <= 1.5 then
					if IsControlJustPressed(0,38) and segundos <= 0 then
						segundos = 5
						if trancas[k].trancado[1] then
							vRP._playAnim(true,{{"veh@mower@base","start_engine"}},false)
							Citizen.Wait(2200)
							if vSERVER.syncLock(k, false, trancas[k].perm[1]) then
								TriggerEvent("Notify","negado","Porta destrancada.", 5)
							end
						else
							vRP._playAnim(true,{{"veh@mower@base","start_engine"}},false)
							Citizen.Wait(2200)
							if vSERVER.syncLock(k, true, trancas[k].perm[1]) then
								TriggerEvent("Notify","sucesso","Porta trancada.", 5)
							end
						end
					end
				end

			end
		end
	
		Citizen.Wait(time)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SYNCRONIZAR PORTAS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 500
		local pedCoords = GetEntityCoords(PlayerPedId())
		for k,v in pairs(trancas) do
			local distance = #(pedCoords - v.coords)
			if distance <= 20.0 then
				local door = GetClosestObjectOfType(v.coords[1],v.coords[2],v.coords[3],1.0,trancas[k].hash[1],false,false,false)
				SetEntityCanBeDamaged(door,false)
				if v.trancado[1] == false then
					NetworkRequestControlOfEntity(door)
					FreezeEntityPosition(door,false)
				else
					local lock,heading = GetStateOfClosestDoorOfType(v.hash[1],v.coords[1],v.coords[2],v.coords[3],lock,heading)
					if heading > -0.02 and heading < 0.02 then
						NetworkRequestControlOfEntity(door)
						FreezeEntityPosition(door,true)
					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)


function src.setLock(id, status)
	if id then
		trancas[id].trancado[1] = status
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ELEVADOR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)
		
		for k,v in pairs(config.locationElevador) do
			local distance = #(playercoords - v.coords)
			if distance <= 2.0 then
				time = 5
				DrawMarker(20,v.coords[1],v.coords[2],v.coords[3]-0.7,0,0,0,0,0,130.0,0.4,0.1,0.5, 12,198,254,180 ,1,0,0,1)

				if IsControlJustReleased(1, 51) then
					if config.elevador[v.type] ~= nil then
						openElevador(v.type, v.andar, config.elevador[v.type].andares)
					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

function openElevador(tipo, andar, elevador)
	SetNuiFocus(true,true)
	SendNUIMessage({ showmenu = true, tipo = tipo, andar = andar, elevador = elevador })
end

function updateElevador(tipo, andar)
	local ped = PlayerPedId()
	DoScreenFadeOut(1000)

	Wait(1000)
	SetEntityCoordsNoOffset(ped,config.elevador[tipo].andares[andar][1],config.elevador[tipo].andares[andar][2],config.elevador[tipo].andares[andar][3], true,true,true)

	Wait(1000)
	SetNuiFocus(false)
	SendNUIMessage({ hidemenu = true })

	Wait(1000)
	DoScreenFadeIn(1000)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CALL BACKS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("closeNui",function(data,cb)
	SetNuiFocus(false)
	SendNUIMessage({ hidemenu = true })
end)

RegisterNUICallback("elevadorInit",function(data,cb)
	if segundos <= 0 then
		segundos = 5
		updateElevador(data.elevador, data.andar)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SOUNDS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent('vrp_sound:source')
AddEventHandler('vrp_sound:source',function(sound,volume)
	SendNUIMessage({ transactionType = 'playSound', transactionFile = sound, transactionVolume = volume })
end)

RegisterNetEvent('vrp_sound:distance')
AddEventHandler('vrp_sound:distance', function(playerNetId, maxDistance, soundFile, soundVolume)
    local lCoords = GetEntityCoords(GetPlayerPed(-1))
    local eCoords = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerNetId)))
    local distIs = Vdist(lCoords.x, lCoords.y, lCoords.z, eCoords.x, eCoords.y, eCoords.z)
    if (distIs <= maxDistance) then
        SendNUIMessage({ transactionType = 'playSound', transactionFile = soundFile, transactionVolume = soundVolume })
    end
end)  

RegisterNetEvent('vrp_sound:fixed')
AddEventHandler('vrp_sound:fixed',function(playerid,x2,y2,z2,maxdistance,sound,volume)
	local ped = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(ped))
	local distance = GetDistanceBetweenCoords(x2,y2,z2,x,y,z,true)
	if distance <= maxdistance then
		SendNUIMessage({ transactionType = 'playSound', transactionFile = sound, transactionVolume = volume })
	end
end) 

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- BLIPS NO MAPA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	for k,v in pairs(config.blips) do
		local blip = AddBlipForCoord(v[1]+0.001,v[2]+0.001,v[3]+0.001)
		SetBlipSprite(blip,v[4])
		SetBlipAsShortRange(blip,true)
		SetBlipColour(blip,v[5])
		SetBlipScale(blip,v[7])
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(v[6])
		EndTextCommandSetBlipName(blip)
	end
end)

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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONTADOR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		if segundos > 0 then
			segundos = segundos - 1
			
			if segundos <= 0 then
				segundos = 0
			end

		end
		Citizen.Wait(time)
	end
end)
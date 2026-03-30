----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONEXAO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
src = {}
Tunnel.bindInterface("vrp_hud",src)
vSERVER = Tunnel.getInterface("vrp_hud")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local fome = 0
local sede = 0
local hour = 00
local minute = 05

local voice = 1
local talking = false
local radio = 0

local sBuffer = {}
local vBuffer = {}
local cinto_seguranca = false
local ExNoCarro = false
local showHud = true

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MAIN
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000

		local ped = PlayerPedId()
		local vida = math.ceil((100 * ((GetEntityHealth(ped) - 100) / (GetEntityMaxHealth(ped) - 100))))
		local armour = GetPedArmour(ped)
		local inVehicle = IsPedInAnyVehicle(ped, false)
		CalculateTimeToDisplay()

		local x,y,z = table.unpack(GetEntityCoords(ped))
		local city = GetLabelText(GetNameOfZone(x,y,z))
		local streetName = GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z))

		if inVehicle then
			time = 150
			local vehicle = GetVehiclePedIsIn(ped, false)
			local speed = math.ceil(GetEntitySpeed(vehicle) * 3.605936)
			local fuel = GetVehicleFuelLevel(vehicle)

			SendNUIMessage({ hud = showHud, vehicle = true, health = vida, armour = armour, fome = (100 - fome), sede = (100 - sede), time = hour .. ':' .. minute, street = streetName..', '..city, voice = voice, talking = talking, radiofreq = radio, speed = speed, fuel = fuel, seatbelt = cinto_seguranca })
		else
			SendNUIMessage({ hud = showHud, vehicle = false, health = vida, armour = armour, fome = (100 - fome), sede = (100 - sede), time = hour .. ':' .. minute, street = streetName..', '..city, voice = voice, talking = talking, radiofreq = radio })
		end

		DisplayRadar(inVehicle)

		Citizen.Wait(time)
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CINTO DE SEGURANCA
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
IsCar = function(veh)
	local vc = GetVehicleClass(veh)
	return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end

Citizen.CreateThread(function()
	while true do
		local timeDistance = 1000

		local ped = PlayerPedId()
		local car = GetVehiclePedIsIn(ped)
		if car ~= 0 and (ExNoCarro or IsCar(car)) then
			timeDistance = 5

			ExNoCarro = true
			if cinto_seguranca then
				DisableControlAction(0,75)
			end

			
			sBuffer[2] = sBuffer[1]
			sBuffer[1] = GetEntitySpeed(car)

			if sBuffer[2] ~= nil and not cinto_seguranca and GetEntitySpeedVector(car,true).y > 1.0 and sBuffer[1] > 10.25 and (sBuffer[2] - sBuffer[1]) > (sBuffer[1] * 0.255) then
		---		SetEntityHealth(ped, GetEntityHealth(ped) - 10)
				TaskLeaveVehicle(ped,GetVehiclePedIsIn(ped),4160)
			end

			if IsControlJustReleased(1,47) then
				if cinto_seguranca then
					TriggerEvent("vrp_sound:source","unbelt",0.5)
					cinto_seguranca = false
				else
					TriggerEvent("vrp_sound:source","belt",0.5)
					cinto_seguranca = true
				end
			end
		elseif ExNoCarro then
			ExNoCarro = false
			cinto_seguranca = false
			sBuffer[1],sBuffer[2] = 0.0,0.0
		end
		Citizen.Wait(timeDistance)
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function CalculateTimeToDisplay()
	hour = GetClockHours()
	minute = GetClockMinutes()
	if hour <= 9 then
		hour = '0' .. hour
	end
	if minute <= 9 then
		minute = '0' .. minute
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VOIP
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("vrp_hud:TokovoipRadio")
AddEventHandler("vrp_hud:TokovoipRadio",function(freq)
	radio = freq
end)

RegisterNetEvent("vrp_hud:Tokovoip")
AddEventHandler("vrp_hud:Tokovoip",function(status)
	voice = status
end)

RegisterNetEvent("vrp_hud:TokovoipTalking")
AddEventHandler("vrp_hud:TokovoipTalking",function(status)
	talking = status
end)

RegisterNetEvent("vrp_hud:updateHunger")
AddEventHandler("vrp_hud:updateHunger",function(status)
	fome = status
end)

RegisterNetEvent("vrp_hud:updateThrist")
AddEventHandler("vrp_hud:updateThrist",function(status)
	sede = status
end)

RegisterNetEvent("vrp_hud:hide")
AddEventHandler("vrp_hud:hide",function(status)
	showHud = status
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- REMOVER HUD
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('rhud', function(source,args)
	showHud = not showHud
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE PROGRESSBAR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNetEvent("progress")
AddEventHandler("progress",function(time)
	if time > 0 then
		SendNUIMessage({ status = true, display = true, time = time*1000 })
	else
		SendNUIMessage({ status = true, display = false, time = 0 })
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA CLIMATICO
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local hora = 12
local minuto = 0

function src.updateClima(h, m)
	hora = h
	minuto = m
end

Citizen.CreateThread(function()
	while true do
		NetworkOverrideClockTime(tonumber(hora), tonumber(minuto), 0)
		SetWeatherTypeNowPersist("CLEAR")

		Citizen.Wait(1000)
	end
end)

local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
emP = Tunnel.getInterface("vrp_race")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local blips = false
local inrace = false
local timerace = 0
local racepoint = 1
local racepos = 0 

local CoordenadaX = -932.57
local CoordenadaY = -2644.34
local CoordenadaZ = 39.11
local PlateIndex = nil
local bomba = nil
local explosive = 0
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local races = {
	[1] = {
		['time'] = 140,
		[1] = { ['x'] = -941.26, ['y'] = -2659.92, ['z'] = 32.62 },
		[2] = { ['x'] = -941.93, ['y'] = -2660.57, ['z'] = 22.48 },
		[3] = { ['x'] = -901.01, ['y'] = -2663.47, ['z'] = 12.98 },
		[4] = { ['x'] = -795.19, ['y'] = -2521.67, ['z'] = 13.1 },
		[5] = { ['x'] = -602.89, ['y'] = -2256.5, ['z'] = 5.44 },
		[6] = { ['x'] = -350.36, ['y'] = -2150.54, ['z'] = 9.67 },
		[7] = { ['x'] = -59.7, ['y'] = -2143.54, ['z'] = 9.67 },
		[8] = { ['x'] = -169.32, ['y'] = -1908.11, ['z'] = 24.62 },
		[9] = { ['x'] = -223.81, ['y'] = -1813.26, ['z'] = 29.22 },
		[10] = { ['x'] = -89.17, ['y'] = -1777.52, ['z'] = 28.28 },
		[11] = { ['x'] = 77.7, ['y'] = -1883.42, ['z'] = 22.09 },
		[12] = { ['x'] = 186.08, ['y'] = -1798.3, ['z'] = 28.26 },
		[13] = { ['x'] = 342.56, ['y'] = -1902.5, ['z'] = 24.49 },
		[14] = { ['x'] = 438.84, ['y'] = -1855.77, ['z'] = 27.05 },
		[15] = { ['x'] = 501.61, ['y'] = -1735.56, ['z'] = 28.43 },
		[16] = { ['x'] = 607.04, ['y'] = -1621.82, ['z'] = 24.53 },
		[17] = { ['x'] = 534.99, ['y'] = -1464.03, ['z'] = 28.65 },
		[18] = { ['x'] = 502.47, ['y'] = -1235.85, ['z'] = 28.65 },
		[19] = { ['x'] = 489.5, ['y'] = -1131.69, ['z'] = 28.78 },
		[20] = { ['x'] = 469.87, ['y'] = -1092.21, ['z'] = 28.52 }
	},

	[2] = {
		['time'] = 140,
		[1] = { ['x'] = 32.38, ['y'] = -1177.03, ['z'] = 28.86 },
		[2] = { ['x'] = 9.9, ['y'] = -1041.22, ['z'] = 37.68 },
		[3] = { ['x'] = -81.31, ['y'] = -1021.87, ['z'] = 27.95 },
		[4] = { ['x'] = -130.91, ['y'] = -1095.36, ['z'] = 21.24 },
		[5] = { ['x'] = -194.33, ['y'] = -1068.22, ['z'] = 21.89 },
		[6] = { ['x'] = -109.22, ['y'] = -939.72, ['z'] = 28.79 },
		[7] = { ['x'] = -11.27, ['y'] = -894.69, ['z'] = 29.43 },
		[8] = { ['x'] = 77.4, ['y'] = -694.8, ['z'] = 31.15 },
		[9] = { ['x'] = 240.54, ['y'] = -638.98, ['z'] = 39.59 },
		[10] = { ['x'] = 532.93, ['y'] = -181.44, ['z'] = 53.84  },		
	},

	[3] = {
		['time'] = 140,
		[1] = { ['x'] = 511.64, ['y'] = -660.64, ['z'] = 24.33 },
		[2] = { ['x'] = 497.9, ['y'] = -1057.27, ['z'] = 28.1 },
		[3] = { ['x'] = 379.3, ['y'] = -1154.76, ['z'] = 28.85 },
		[4] = { ['x'] = 215.44, ['y'] = -1168.61, ['z'] = 37.65 },
		[5] = { ['x'] = 44.76, ['y'] = -1302.67, ['z'] = 28.81 },
		[6] = { ['x'] = -84.75, ['y'] = -1317.18, ['z'] = 28.8 },
		[7] = { ['x'] = -133.99, ['y'] = -1146.07, ['z'] = 24.73 },
		[8] = { ['x'] = -606.74, ['y'] = -1078.28, ['z'] = 21.94 },
		[9] = { ['x'] = -690.41, ['y'] = -1064.32, ['z'] = 14.41 },
		[10] = { ['x'] = -854.53, ['y'] = -843.84, ['z'] = 18.85 }
	},

	[4] = {
		['time'] = 140,
		[1] = { ['x'] = -288.88, ['y'] = -913.08, ['z'] = 30.64 },
		[2] = { ['x'] = -354.29, ['y'] = -794.94, ['z'] = 52.64 },
		[3] = { ['x'] = -189.79, ['y'] = -908.61, ['z'] = 28.91 },
		[4] = { ['x'] = -268.67, ['y'] = -1416.28, ['z'] = 30.75 },
		[5] = { ['x'] = -186.92, ['y'] = -1348.58, ['z'] = 30.66 },
		[6] = { ['x'] = -114.65, ['y'] = -1421.11, ['z'] = 29.56 },
		[7] = { ['x'] = -12.61, ['y'] = -1416.15, ['z'] = 28.87 },
		[8] = { ['x'] = 164.95, ['y'] = -1517.12, ['z'] = 28.7 },
		[9] = { ['x'] = 269.23, ['y'] = -1667.09, ['z'] = 28.9 },
		[10] = { ['x'] = 511.05, ['y'] = -1847.71, ['z'] = 26.74 },
		[11] = { ['x'] = 799.76, ['y'] = -1750.92, ['z'] = 28.89 }
	},

	[5] = {
		['time'] = 140,
		[1] = { ['x'] = 748.41, ['y'] = -968.89, ['z'] = 24.3 },
		[2] = { ['x'] = 746.2, ['y'] = -1030.18, ['z'] = 20.96 },
		[3] = { ['x'] = 822.95, ['y'] = -1126.0, ['z'] = 24.01 },
		[4] = { ['x'] = -241.1, ['y'] = -1188.0, ['z'] = 36.81 },
		[5] = { ['x'] = -308.73, ['y'] = -1239.17, ['z'] = 27.95 },
		[6] = { ['x'] = -154.94, ['y'] = -1251.94, ['z'] = 30.85 },
		[7] = { ['x'] = 17.85, ['y'] = -1137.07, ['z'] = 28.6 },
		[8] = { ['x'] = 131.04, ['y'] = -1241.65, ['z'] = 29.06 },
		[9] = { ['x'] = 339.41, ['y'] = -1333.98, ['z'] = 31.88 },
		[10] = { ['x'] = 490.7, ['y'] = -1514.3, ['z'] = 28.85 },
		[11] = { ['x'] = 97.84, ['y'] = -1405.14, ['z'] = 28.73  }
	},

	[6] = {
		['time'] = 140,
		[1] = { ['x'] = 66.36, ['y'] = -585.63, ['z'] = 31.19 },
		[2] = { ['x'] = -47.14, ['y'] = -686.26, ['z'] = 31.9 },
		[3] = {  ['x'] = -221.71, ['y'] = -623.81, ['z'] = 33.04 },
		[4] = { ['x'] = -138.34, ['y'] = -341.4, ['z'] = 35.99 },
		[5] = { ['x'] = -233.76, ['y'] = -212.72, ['z'] = 48.68 },
		[6] = { ['x'] = -248.6, ['y'] = -75.4, ['z'] = 48.78 },
		[7] = { ['x'] = -168.38, ['y'] = -177.44, ['z'] = 43.18 },
		[8] = { ['x'] = 146.04, ['y'] = -330.0, ['z'] = 44.23 },
		[9] = { ['x'] = 9.12, ['y'] = -395.73, ['z'] = 39.0 },
		[10] = { ['x'] = -226.87, ['y'] = -446.16, ['z'] = 31.9 },
		[11] = { ['x'] = -1157.87, ['y'] = -635.62, ['z'] = 22.18 }
	},
}

-----------------------------------------------------------------------------------------------------------------------------------------
-- STARTRACES
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local skips = 1000
		if not inrace then
			local ped = PlayerPedId()
			local vehicle = GetVehiclePedIsUsing(ped)
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(CoordenadaX,CoordenadaY,CoordenadaZ)
			local distance = GetDistanceBetweenCoords(CoordenadaX,CoordenadaY,cdz,x,y,z,true)

			if distance <= 30.0 then
				if IsEntityAVehicle(vehicle) and GetVehicleClass(vehicle) ~= 8 and GetPedInVehicleSeat(vehicle,-1) == ped then
					skips = 1
					DrawMarker(23,CoordenadaX,CoordenadaY,CoordenadaZ-0.96,0,0,0,0,0,0,10.0,10.0,1.0,0,95,140,50,0,0,0,0)
					if distance <= 5.9 then
						skips = 1
						drawTxt("PRESSIONE  ~b~E~w~  PARA INICIAR A CORRIDA",4,0.5,0.93,0.50,255,255,255,180)
						if IsControlJustPressed(0,38) then
							inrace = true
							racepos = 1
							racepoint = emP.getRacepoint()
							timerace = races[racepoint].time
							PlateIndex = GetVehicleNumberPlateText(vehicle)
							SetVehicleNumberPlateText(vehicle,"CORREDOR")
							CriandoBlip(races,racepoint,racepos)
							emP.initCorrida()
							explosive = math.random(100)
							if explosive >= 70 then
								emP.startBombRace()
								bomba = CreateObject(GetHashKey("prop_c4_final_green"),x,y,z,true,false,false)
								AttachEntityToEntity(bomba,vehicle,GetEntityBoneIndexByName(vehicle,"exhaust"),0.0,0.0,0.0,180.0,-90.0,180.0,false,false,false,true,2,true)
								TriggerEvent("Notify","importante","Você começou uma corrida <b>Explosiva</b>, não saia do veículo e termine<br>no tempo estimado, ou então sei veículo vai explodir com você dentro.", 5)
							end
						end
					end
				end
			end
		end
		Citizen.Wait(skips)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECKPOINTS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local skips = 1000
		if inrace then
			local ped = PlayerPedId()
			local vehicle = GetVehiclePedIsUsing(ped)
			local x,y,z = table.unpack(GetEntityCoords(ped))
			local bowz,cdz = GetGroundZFor_3dCoord(races[racepoint][racepos].x,races[racepoint][racepos].y,races[racepoint][racepos].z)
			local distance = GetDistanceBetweenCoords(races[racepoint][racepos].x,races[racepoint][racepos].y,cdz,x,y,z,true)

			if distance <= 100.0 then
				if IsEntityAVehicle(vehicle) and GetVehicleClass(vehicle) ~= 8 then
					skips = 1
					DrawMarker(1,races[racepoint][racepos].x,races[racepoint][racepos].y,races[racepoint][racepos].z-3,0,0,0,0,0,0,12.0,12.0,8.0,255,255,255,25,0,0,0,0)
					skips = 1
					DrawMarker(21,races[racepoint][racepos].x,races[racepoint][racepos].y,races[racepoint][racepos].z+1,0,0,0,0,180.0,130.0,3.0,3.0,2.0,255,0,0,50,1,0,0,1)
					if distance <= 15.1 then
						RemoveBlip(blips)
						if racepos == #races[racepoint] then
							inrace = false
							SetVehicleNumberPlateText(GetPlayersLastVehicle(),PlateIndex)
							PlateIndex = nil
							PlaySoundFrontend(-1,"RACE_PLACED","HUD_AWARDS",false)
							if explosive >= 70 then
								explosive = 0
								DetachEntity(bomba,false,false)
								TriggerServerEvent("trydeleteobj",ObjToNet(bomba))
								emP.removeBombRace()
								emP.paymentCheck(racepoint,1)
							else
								emP.paymentCheck(racepoint,1)
							end
						else
							racepos = racepos + 1
							TriggerServerEvent('azRaces:blip',x,y,z)
							CriandoBlip(races,racepoint,racepos)
						end
					end
				end
			end
		end
		Citizen.Wait(skips)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMEDRAWN
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local skips = 1000
		if inrace and timerace > 0 and GetVehiclePedIsUsing(PlayerPedId()) then
			skips = 1
			drawTxt("RESTAM ~b~"..timerace.." SEGUNDOS ~w~PARA CHEGAR AO DESTINO FINAL DA CORRIDA",4,0.5,0.905,0.45,255,255,255,100)
			skips = 1
			drawTxt("VENÇA A CORRIDA E SUPERE SEUS PROPRIOS RECORDES ANTES DO TEMPO ACABAR",4,0.5,0.93,0.38,255,255,255,50)
		end
		Citizen.Wait(skips)
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- TIMERACE
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if inrace and timerace > 0 then
			timerace = timerace - 1
			if timerace <= 0 or not IsPedInAnyVehicle(PlayerPedId()) then
				inrace = false
				RemoveBlip(blips)
				SetVehicleNumberPlateText(GetPlayersLastVehicle(),PlateIndex)
				PlateIndex = nil
				if explosive >= 70 then
					SetTimeout(3000,function()
						explosive = 0
						DetachEntity(bomba,false,false)
						TriggerServerEvent("trydeleteobj",ObjToNet(bomba))
						emP.removeBombRace()
						AddExplosion(GetEntityCoords(GetPlayersLastVehicle()),1,1.0,true,true,true)
					end)
				end
			end
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
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

function CriandoBlip(races,racepoint,racepos)
	blips = AddBlipForCoord(races[racepoint][racepos].x,races[racepoint][racepos].y,races[racepoint][racepos].z)
	SetBlipSprite(blips,1)
	SetBlipColour(blips,1)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Corrida Clandestina")
	EndTextCommandSetBlipName(blips)
end

RegisterNetEvent("emp_race:defuse")
AddEventHandler("emp_race:defuse",function()
	inrace = false
	SetVehicleNumberPlateText(GetPlayersLastVehicle(),PlateIndex)
	PlateIndex = nil
	RemoveBlip(blips)
	if explosive >= 70 then
		explosive = 0
		DetachEntity(bomba,false,false)
		TriggerServerEvent("trydeleteobj",ObjToNet(bomba))
		emP.removeBombRace()
	end
end)

local blips = {}
RegisterNetEvent('AZnotificacao:corrida')
AddEventHandler('AZnotificacao:corrida',function(x,y,z,user_id)
		if not DoesBlipExist(blips[user_id]) then
			blips[user_id] = AddBlipForCoord(x,y,z)
			SetBlipScale(blips[user_id],0.3)
			SetBlipSprite(blips[user_id],10)
			SetBlipColour(blips[user_id],3)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString("Corrida Ilegal")
			EndTextCommandSetBlipName(blips[user_id])
			SetBlipAsShortRange(blips[user_id],false)
			SetTimeout(5000,function()
				if DoesBlipExist(blips[user_id]) then
					RemoveBlip(blips[user_id])
				end
			end)
		end
end)
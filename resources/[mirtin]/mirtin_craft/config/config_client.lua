
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP","mirtin_craft")

src = {}
Tunnel.bindInterface("mirtin_craft",src)
vSERVER = Tunnel.getInterface("mirtin_craft")

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config = {}
config_server = {}

config.imgDir = "http://177.54.148.31:4020/inventario/" -- DIRETORIO DE SUAS IMAGENS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRADUÇOES
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config.lang = {
    notPermiss = function() TriggerEvent("Notify","negado","Você não possui permissão para isso.", 5) end,
}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTRAS CONFIG
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config.marker = function(tipo, coords) -- CONFIG DA MARCAÇÃO DO BLIP
    if tipo == "craft" then
        DrawText3D(coords[1],coords[2],coords[3], "Pressione ~g~ E ~w~ para abrir a bancada.")
	elseif tipo == "armazem" then
		DrawText3D(coords[1],coords[2],coords[3], "[~b~ARMAZEM~w~] ~g~ E ~w~ para ver ~g~ G ~w~ para guardar.")
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
src.playAnim = function(anim)
	vRP.playAnim(false,{{anim[1], anim[2]}},true)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DrawText3D(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,100)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
	local factor = (string.len(text)) / 400
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,140)
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DESMANCHE
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DESMANCHE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local desmanchando = false
local tempoDesmanche = 0
local segundos = 0

local locations = {
	[1] = { coords = vec3(1534.4,3533.72,35.37), range = 5.0, permission = "perm.elements" },
	[2] = { coords = vec3(1175.32,2638.25,37.76), range = 5.0, permission = "perm.brancos" },
}

Citizen.CreateThread(function()
    while true do
    local time = 1000 
    local ped = PlayerPedId()
	local pedCoords = GetEntityCoords(ped)
		for k,v in pairs(locations) do
			local distance = #(pedCoords - v.coords)
			if distance <= v.range then
				if not IsPedInAnyVehicle(ped) then
					time = 5

					local veh = getVehicleRadius(5)
					local coordsVehicle = GetOffsetFromEntityInWorldCoords(veh, 0.0, 0.0, 1.0)
					local distanceVeh = GetDistanceBetweenCoords(pedCoords, coordsVehicle.x,coordsVehicle.y,coordsVehicle.z,true)
					if distanceVeh <= 5.0 then
						time = 5
						if desmanchando then
							DrawText3Ds(coordsVehicle.x,coordsVehicle.y,coordsVehicle.z,"Aguarde ~g~"..tempoDesmanche.." segundo(s)~w~ para desmanchar esse veiculo.")
						else
							DrawText3Ds(coordsVehicle.x,coordsVehicle.y,coordsVehicle.z,"Pressione ~g~E~w~ para desmanchar esse veiculo.")
							if IsControlJustReleased(1, 51) and segundos <= 0 and vSERVER.checkPermission(v.permission) and distance <= 1.5 then
								segundos = 5
								local mPlaca,mName,mNet,mPortaMalas,mPrice,mLock,mModel = vRP.ModelName(5)
								desmancharVeiculo(veh,mPlaca,mName,mNet,mPortaMalas,mPrice,mLock,mModel)
							end
						end
					end

				end
			end
		end
        Citizen.Wait(time)
    end
end)

function desmancharVeiculo(veh,mPlaca,mName,mVeh,mPortaMalas,mPrice,mLock,mModel)
    if vSERVER.checkVehicleStatus(mPlaca,mName) then
		if veh then
			SetVehicleUndriveable(veh, true)
			SetVehicleDoorsLocked(veh,2)

			desmanchando = true
			tempoDesmanche = 60
			vRP._playAnim(false,{{"mini@repair","fixing_a_player"}},true)
		end

        async(function()
            while desmanchando do
                tempoDesmanche = tempoDesmanche-1

				if tempoDesmanche <= 0 then
					tempoDesmanche = 0
					desmanchando = false
					vSERVER.pagarDesmanche(mPlaca,mName,mPrice,mVeh)
                    vRP._stopAnim(false)
				end

				Citizen.Wait(1000)
            end
        end)
    end
end

function getVehicleRadius(radius)
	local veh
	local vehs = getVehiclesRadius(radius)
	local min = radius+0.0001
	for _veh,dist in pairs(vehs) do
		if dist < min then
			min = dist
			veh = _veh
		end
	end
	return veh
end

function getVehiclesRadius(radius)
	local r = {}
	local px,py,pz = table.unpack(GetEntityCoords(PlayerPedId()))

	local vehs = {}
	local it,veh = FindFirstVehicle()
	if veh then
		table.insert(vehs,veh)
	end
	local ok
	repeat
		ok,veh = FindNextVehicle(it)
		if ok and veh then
			table.insert(vehs,veh)
		end
	until not ok
	EndFindVehicle(it)

	for _,veh in pairs(vehs) do
		local x,y,z = table.unpack(GetEntityCoords(veh,true))
		local distance = GetDistanceBetweenCoords(x,y,z,px,py,pz,true)
		if distance <= radius then
			r[veh] = distance
		end
	end
	return r
end


----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,150)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if segundos > 0 then
            segundos = segundos - 1
        end
    end
end)
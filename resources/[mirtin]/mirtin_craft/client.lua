------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
open = false
segundos = 0
nearestCraft = {}
nearestArmazem = {}
cauth = true
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MAIN THREAD
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local time = 1000
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        if cauth then
            if not open then
                if length(nearestCraft) > 0 then
                    for k,v in pairs(nearestCraft) do
                        local distance = #(pedCoords - vec3(v.coords[1],v.coords[2],v.coords[3]))
                        if distance <= v.visible then
                            time = 5
                            config.marker("craft", v.coords)
    
                            if IsControlJustPressed(0, 38) and segundos <= 0 and GetEntityHealth(ped) > 105 and not IsPedInAnyVehicle(ped) then
                                segundos = 5
                                if v.isDominas ~= nil then
                                    if vSERVER.checkDominacao(v.isDominas) then
                                        print(v.type)
                                        openNui(v.type)
                                    else
                                        config.lang['notPermiss']()
                                    end
                                else
                                    if vSERVER.checkPermission(v.perm) then
                                        openNui(v.type)
                                    else
                                        config.lang['notPermiss']()
                                    end
                                end
                            end
    
                        end
                    end
                end
    
                if length(nearestArmazem) > 0 then
                    for k,v in pairs(nearestArmazem) do
                        local distance = #(pedCoords - vec3(v.coords[1],v.coords[2],v.coords[3]))
                        if distance <= v.visible then
                            time = 5
                            config.marker("armazem", v.coords)
    
                            if IsControlJustPressed(0, 38) and segundos <= 0 then
                                segundos = 5
    
                                if vSERVER.checkPermission(v.perm) then
                                    vSERVER.getItensArmazem(k)
                                else
                                    config.lang['notPermiss']()
                                end
                            end
    
                            if IsControlJustPressed(0, 47) and segundos <= 0 then
                                segundos = 5
    
                                if vSERVER.checkPermission(v.perm) then
                                    vSERVER.guardarItensArmazem(k)
                                else
                                    config.lang['notPermiss']()
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
openNui = function(tipo)
    if config_server.table[tipo] ~= nil then
        SendNUIMessage({ show = true, items = config_server.table[tipo].craft, orgID = tipo, imgDir = config.imgDir })
        SetNuiFocus(true,true)
        open = true
    end
end

src.blockAnimation = function(anim, time, status)
    in_status = status
    anim1 = anim[1]
    anim2 = anim[2]
    getCoords = GetEntityCoords(PlayerPedId())
    getHeading = GetEntityHeading(PlayerPedId())

    Wait(5000)
    CreateThread(function()
        while in_status do
            local time = 1000
            
            if in_status then
                if not IsEntityPlayingAnim(PlayerPedId(), anim1, anim2,3) then
                    SetEntityHeading(PlayerPedId(), getHeading)
                    SetEntityCoords(PlayerPedId(), getCoords.x, getCoords.y, getCoords.z - 0.7)
                    src.playAnim(anim)
                end
            end

            Citizen.Wait(time)
        end
    end)
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CALLBACKS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RegisterNUICallback("craftItem", function(data)
--     if data and not IsPedInAnyVehicle(ped) then
--         vSERVER.craftItem(data.craftID, data.item, data.spawnID, data.amount)
--     end
-- end)

RegisterNUICallback("craftItem", function(data)
    if data and not IsPedInAnyVehicle(ped) then
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        if length(nearestCraft) > 0 then
            for k,v in pairs(nearestCraft) do
                local distance = #(pedCoords - vec3(v.coords[1],v.coords[2],v.coords[3]))
                print(pedCoords, v.coords[1],v.coords[2],v.coords[3])
                print(distance)
                if distance <= 5 then
                    vSERVER.craftItem(data.craftID, data.item, data.spawnID, data.amount)
                else
                    TriggerEvent("Notify","negado","Você está longe do ponto de craft, safadinho!")
                end
            end
        else
            TriggerEvent("Notify","negado","Você está longe do ponto de craft, safadinho!")
        end
    end
end)

local delay = false
RegisterNUICallback("closeNUI", function(data)
    if data.antiDump then
        if not delay then
            delay = true
            vSERVER.sendLogDump()

            SetTimeout(5000, function() delay = false end)
        end
    else
        SetNuiFocus(false,false)
        open = false
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- THREADS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local time = 1500
        local ped = PlayerPedId()
        local pedCoords = GetEntityCoords(ped)
        if config_server ~= nil then
            if config_server.craftLocations then
                for k in pairs(config_server.craftLocations) do
                    local distance = #(pedCoords - vec3(config_server.craftLocations[k].coords[1],config_server.craftLocations[k].coords[2],config_server.craftLocations[k].coords[3]))
                    if distance < 10 then
                        nearestCraft[k] = config_server.craftLocations[k]
                    elseif nearestCraft[k] then
                        nearestCraft[k] = nil
                    end 
                end
            end

            if config_server.armazemLocations then
                for k in pairs(config_server.armazemLocations) do
                    local distance = #(pedCoords - vec3(config_server.armazemLocations[k].coords[1],config_server.armazemLocations[k].coords[2],config_server.armazemLocations[k].coords[3]))
                    if distance < 10 then
                        nearestArmazem[k] = config_server.armazemLocations[k]
                    elseif nearestArmazem[k] then
                        nearestArmazem[k] = nil
                    end 
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

        if segundos <= 0 then
            segundos = 0
        end

        Citizen.Wait(time)
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Functions
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function length(array)
    local len = 0
    for i in pairs(array) do 
        if array[i] then
            len = len + 1
        end
    end
    return len
end    
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- THREAD
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    config_server = vSERVER.ServerConfig() -- Não mexa aqui
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE DESMANCHE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local segundos = 0
local desmanchando = false
local locations = {
	[1] = { coords = vec3(987.51,-139.39,73.1), range = 10.0, permission = "perm.desmanche" },
	[2] = { coords = vec3(998.54,-1533.11,30.08), range = 10.0, permission = "perm.desmanche" },
	[3] = { coords = vec3(-204.74,-1635.31,33.58), range = 10.0, permission = "perm.desmanche"},
	[4] = { coords = vec3(1313.46,-740.27,66.29), range = 10.0, permission = "perm.desmanche"},

    [5] = { coords = vec3(478.32,-1308.57,29.24), range = 10.0, permission = "perm.desmanche"},
    [6] = { coords = vec3(-1158.86,-2006.33,13.19), range = 10.0, permission = "perm.desmanche"},
    [7] = { coords = vec3(998.33,-1533.21,30.11), range = 10.0, permission = "perm.desmanche"},
    [8] = { coords = vec3(85.01,-1972.0,20.79), range = 10.0, permission = "perm.desmanche"},

    [9] = { coords = vec3(-336.63,-1572.29,25.23), range = 10.0, permission = "perm.desmanche"},

    [10] = { coords = vec3(-241.19,-1334.99,30.89), range = 10.0, permission = "perm.desmanche"},
    [11] = { coords = vec3(-232.06,-1334.98,30.89), range = 10.0, permission = "perm.desmanche"},
    [12] = { coords = vec3(-182.43,-1285.16,31.29), range = 10.0, permission = "perm.desmanche"},
    [13] = { coords = vec3(-223.97,-1329.05,30.89), range = 10.0, permission = "perm.desmanche"},


    


}

Citizen.CreateThread(function()
    while true do
    local time = 1000
    local ped = PlayerPedId()
	local pedCoords = GetEntityCoords(ped)
		for k,v in pairs(locations) do
			local distance = #(pedCoords - v.coords)
			if distance <= v.range then
				if not desmanchando and not IsPedInAnyVehicle(ped) then
					time = 5

					local veh = getVehicleRadius(5)
					local coordsVehicle = GetOffsetFromEntityInWorldCoords(veh, 0.0, 0.0, 1.0)
					local distanceVeh = GetDistanceBetweenCoords(pedCoords, coordsVehicle.x,coordsVehicle.y,coordsVehicle.z,true)
					if distanceVeh <= 2.0 then
						time = 5
						DrawText3Ds2(coordsVehicle.x,coordsVehicle.y,coordsVehicle.z,"Pressione [~b~E~w~] para desmanchar esse veiculo.")
						if IsControlJustReleased(1, 51) and segundos <= 0 and vSERVER.checkPermission(v.permission) then
							segundos = 0
							local mPlaca,mName,mNet,mPortaMalas,mPrice,mLock,mModel = vRP.ModelName(5) 
							desmancharVeiculo(veh,mPlaca,mName,mNet,mPortaMalas,mPrice,mLock,mModel)
                            exports.bm_module:setInDesmanche(true)

						end
					end

				end
			end
		end
        Citizen.Wait(time)
    end
end)

function desmancharVeiculo(veh,mPlaca,mName,mVeh,mPortaMalas,mPrice,mLock,mModel)
    local ped = PlayerPedId()
    local time = 0
    if vSERVER.checkItensD() and vSERVER.checkVehicleStatus(mPlaca,mName) then
        desmanchando = true
        vRP._playAnim(false,{{"mini@repair","fixing_a_player"}},true)
        async(function()
            while desmanchando do
                Citizen.Wait(1000)
                time = time+1

                if time == 1 then
                    TriggerEvent("progress",40,"desmanchando")
                elseif time == 5 then
                    SetVehicleUndriveable(veh, true)
                    SetVehicleDoorsLocked(veh,2)
                    SetVehicleAlarmTimeLeft(veh,30*1000)
                elseif time == 10 then
                    SetVehicleColours(veh, 101 , 101)
                elseif time == 15 then
                    SetVehicleTyreBurst(veh, 0, true, 1000)
                elseif time == 20 then
                    SetVehicleTyreBurst(veh, 1, true, 1000)
                elseif time == 25 then
                    SetVehicleTyreBurst(veh, 4, true, 1000)
                elseif time == 28 then
                    SetVehicleTyreBurst(veh, 5, true, 1000)
					vRP._playAnim(false,{task="WORLD_HUMAN_WELDING"},false)
                elseif time == 33 then

                    SetVehicleDoorBroken(veh, 0, true)
                    SetVehicleDoorBroken(veh, 2, true)
                elseif time == 35 then
                    SetVehicleDoorBroken(veh, 1, true)
                    SetVehicleDoorBroken(veh, 3, true)

                elseif time == 38 then
                    SetVehicleDoorBroken(veh, 4, true)
                elseif time == 39 then
                    SetVehicleDoorBroken(veh, 5, true)
                elseif time == 40 then
					
                    desmanchando = false
                    time = 0
                    vSERVER.pagarDesmanche(mPlaca,mName,mPrice,VehToNet(veh))
                    exports.bm_module:setInDesmanche(false)

                   --- vSERVER.checkItensD2()
                    vRP._stopAnim(false)
                end
		
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
function DrawText3D(x, y, z, text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,150)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
end

function DrawText3Ds2(x,y,z,text)
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
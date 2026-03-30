local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_hospital",src)
vSERVER = Tunnel.getInterface("vrp_hospital")

local segundos = 0

----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE TRATAMENTO
----------------------------------------------------------------------------------------------------------------------------------------
local in_area = 0
local deitado = false
local tratamento = false
local segundosT = 0
local vida = 0

local macas = {
    [1] = { -455.56,-285.04,34.92 , deitado = { -455.08,-286.15,35.84 } },
    [2] = { -460.91,-287.21,34.92 , deitado = { -460.32,-288.51,35.84 } },
    [3] = { -458.47,-281.13,34.92 , deitado = { -459.02,-279.71,35.84 } },
    [4] = { -452.14,-283.73,34.92 , deitado = { -451.63,-284.86,35.84  }   },
    [5] = { -464.37,-288.66,34.92, deitado = { -463.85,-290.04,35.84  }   },
    [6] = { -454.55,-279.51,34.92 , deitado = { -455.08,-278.29,35.84 } },
    [7] = { -462.25,-282.69,34.92 , deitado = { -466.42,-283.16,35.84} },
    [8] = { -448.92,-282.38,34.92 , deitado = { -448.36,-283.57,35.84 } },
    [9] = { -467.57,-290.02,34.92 , deitado = { -467.1,-291.07,35.84 } },
    [10] = { -469.25,-285.61,34.92 , deitado = { -469.87,-284.26,35.84 } },
    [11] = { -465.86,-284.18,34.92 , deitado = { -466.44,-282.87,35.84 } },
    [12] = { -449.28,-312.15,34.92 , deitado = { -450.19,-311.01,35.84 } },
    [13] = { -449.94,-303.95,34.92 , deitado = { -449.0,-303.34,35.83 } } 
 
    --Macas das salas
  --  [14] = { -451.96,-323.07,34.92 , deitado = { -450.46,-323.09,35.59 } } ,
   -- [15] = { -461.32,-307.31,34.92 , deitado = { -459.97,-306.83,35.58 } } ,
   -- [16] = { -463.54,-301.99,34.92 , deitado = {-462.41,-301.72,35.69 } },

   -- [17] = { -463.58,-302.11,34.92 , deitado = {-462.17,-301.57,35.59 } },
  --  [18] = { -466.18,-295.99,34.92 , deitado = {-464.89,-295.6,35.68 } },
 --   [19] = { -463.54,-301.99,34.92 , deitado = {-462.41,-301.72,35.69 } },


  --  [20] = { -448.46,-291.84,34.92, deitado = {-446.84,-291.07,35.82} },

   -- [21] = { -442.75,-303.97,34.92 , deitado = {-441.18,-303.25,35.78 } }

  




}

-----------------------------------------------------------------------------------------------------------------------------------------
-- CHECAR AREA
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))

		for k,v in pairs(macas) do
            local entrada = (GetDistanceBetweenCoords(v[1],v[2],v[3],x,y,z,true) <= 3)

			if entrada then
				in_area = tonumber(k)
			end 
		end

		Citizen.Wait(time)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE MACAS
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))

		if tonumber(in_area) > 0 and not deitado then
			if GetDistanceBetweenCoords(macas[tonumber(in_area)][1],macas[tonumber(in_area)][2],macas[tonumber(in_area)][3],x,y,z,true) <= 2.5 then
				time = 5
				DrawText3Ds(macas[tonumber(in_area)][1],macas[tonumber(in_area)][2],macas[tonumber(in_area)][3], "~w~[~g~E~w~] DEITAR\n~w~[~b~F~w~] TRATAMENTO")


                if IsControlJustReleased(1, 51) and segundos <= 0 then
                    segundos = 5
                    DoScreenFadeOut(1000)

                    Citizen.Wait(2000)
                    SetEntityHeading(ped, macas[tonumber(in_area)].deitado[4])
                    SetEntityCoords(ped, macas[tonumber(in_area)].deitado[1],macas[tonumber(in_area)].deitado[2],macas[tonumber(in_area)].deitado[3]-0.9)
                    vRP.playAnim(false,{{"amb@world_human_sunbathe@female@back@idle_a","idle_a",1}},true)

                    Citizen.Wait(2000)
                    DoScreenFadeIn(1000)

                    if vSERVER.checkUNZIK() then
                        deitado = true
                        tratamento = false
                        segundosT = 0
                        TriggerEvent("blockCell", true)
                    else
                        deitado = true
                        tratamento = true
                        segundosT = 60
                        vida = 110
                        SetEntityHealth(ped, vida)
                        vSERVER.blockCommands(59)
                        TriggerEvent("Notify","importante","Nenhum medico em expediente, você esta sendo tratado pelos medicos da prefeitura", 5)
                        TriggerEvent("blockCell", true)
                    end

                    
                end

                if IsControlJustReleased(1, 49) and segundos <= 0 then
                    segundos = 5
                    if vSERVER.checkTratamento() then
                        TriggerEvent("Notify","importante","Você iniciou tratamento.", 5)
                    end
                end
            end

			if GetDistanceBetweenCoords(macas[tonumber(in_area)][1],macas[tonumber(in_area)][2],macas[tonumber(in_area)][3],x,y,z,true) >= 3 then
				in_area = 0
			end
		end
	
		Citizen.Wait(time)
	end
end) 

-----------------------------------------------------------------------------------------------------------------------------------------
-- DEITADO
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local time = 1000

        if deitado and not tratamento and segundosT == 0 then
            time = 5
            drawTxt("VOCÊ ESTÁ ~r~DEITADO~w~, ~b~[F6]~w~ PARA LEVANTAR OU AGUARDE UM MÉDICO VIR TE ATENDER.",4,0.5,0.96,0.50,255,255,255,180)

            if IsControlJustPressed(0, 167) then
                deitado = false
                segundosT = 0
                tratamento = false
                TriggerEvent("blockCell", false)
            end
            
            DisableControlAction(2, 37, true)
            if IsDisabledControlJustPressed(2, 37) then
				SetCurrentPedWeapon(GetPlayerPed(-1),GetHashKey("WEAPON_UNARMED"),true)
            end
        elseif deitado and tratamento and segundosT > 0 then
            time = 5
            drawTxt("VOCÊ ESTÁ EM ~b~TRATAMENTO~w~, AGUARDE ~b~"..segundosT.."~w~ SEGUNDOS PARA SE LEVANTAR.",4,0.5,0.96,0.50,255,255,255,180)

            DisableControlAction(2, 37, true)
            if IsDisabledControlJustPressed(2, 37) then
				SetCurrentPedWeapon(GetPlayerPed(-1),GetHashKey("WEAPON_UNARMED"),true)
            end
        elseif deitado and segundosT == -1 and not tratamento then
            time = 5
            drawTxt("SEU ~b~TRATAMENTO~w~ ACABOU, ~b~[F6]~w~ PARA LEVANTAR.",4,0.5,0.96,0.50,255,255,255,180)
   
            if IsControlJustPressed(0, 167) then
                deitado = false
                segundosT = 0
                tratamento = false
                TriggerEvent("blockCell", false)
            end

            DisableControlAction(2, 37, true)
            if IsDisabledControlJustPressed(2, 37) then
				SetCurrentPedWeapon(GetPlayerPed(-1),GetHashKey("WEAPON_UNARMED"),true)
            end
        end

        Citizen.Wait(time)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA TRATAMENTO
-----------------------------------------------------------------------------------------------------------------------------------------
function src.iniciarTratamento()
    deitado = true
    tratamento = true
    segundosT = 60

    vida = 110
    SetEntityHealth(ped, vida)
end

function src.checkPaciente()
    return deitado,tratamento
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTADOR TRATAMENTO
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        local time = 1000
        local ped = PlayerPedId()

        if deitado and tratamento and segundosT > 0 then
            segundosT = segundosT - 1

            if vida >= 300 then
                SetEntityHealth(ped, 300)
            else
                vida = vida + 4
                SetEntityHealth(ped, vida)
            end

            if segundosT == 0 then
                tratamento = false
                segundosT = -1
            end
        end

        Citizen.Wait(time)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- OUTROS
-----------------------------------------------------------------------------------------------------------------------------------------
function src.checkSexo()
    if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
        return "H"
    elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
        return "M"
    end
end

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

function DrawText3Ds(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,150)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
end

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

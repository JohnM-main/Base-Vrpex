------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local pescador = {
	["Pescador"] = {
		iniciar = vec3(-1593.1,5203.03,4.32),
		pegarbarco = vec3(-1605.12,5257.84,2.09),
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		for k,v in pairs(pescador) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 2.0 then
					time = 5
					DrawText3Ds(v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.1,"[~b~E~w~] PARA ENTRAR EM SERVIÇO.") 

					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 10
						servico = true
						vSERVER.giveIsca(25)
						zonas = carregarZonas("Pescador", true)
					end
				end
			else
				local distance2 = #(playercoords - v.pegarbarco)
				if distance2 <= 2.0 then
					time = 5
					DrawText3Ds(v.pegarbarco[1],v.pegarbarco[2],v.pegarbarco[3]-0.1,"[~b~E~w~] PARA PEGAR O BARCO.")
					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 10
						criarVehicle(-1598.53,5251.9,0.12,347.04,"dinghy", false)
					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS DE PESCA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		if servico then
			for k,v in pairs(zonas) do
				local distance = #(playercoords - v.coords)
				if distance <= 50.0 then
					time = 5
					drawTxt("[~b~E~w~] PARA PESCAR.",0.5,0.96)
					if IsControlJustReleased(1, 51) and segundos <= 0 and not IsPedInAnyVehicle(PlayerPedId()) then
						segundos = 5
						if vSERVER.tryIsca() then
							vRP._CarregarObjeto("amb@world_human_stand_fishing@idle_a","idle_c","prop_fishing_rod_01",15,60309)

							local finished = vRP.taskBar(3500, math.random(10,20))
							if finished then
								local finished = vRP.taskBar(3500, math.random(10,20))
								if finished then
									local finished = vRP.taskBar(2500, math.random(10,20))
									if finished then
										payment("Pescador", math.random(5))
									end
								end
							end

							vRP._stopAnim(false)
                            vRP._DeletarObjeto()
						end

					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

function src.carregarZonas()
	zonas = {
		[1] = { coords = vec3( -2663.07,3763.49,3.06 ) },
		[2] = { coords = vec3( -991.21,5882.25,2.16 ) },
		[3] = { coords = vec3( -396.36,6609.8,2.51 ) },
		[4] = { coords = vec3( 3429.17,5290.05,3.84 ) },
		[5] = { coords = vec3( 3945.36,3842.28,6.13 ) },
		[6] = { coords = vec3( 2953.09,-689.13,1.77 ) },
		[7] = { coords = vec3( 900.23,-2742.16,3.43 ) },
		[8] = { coords = vec3( -2072.75,-3358.66,3.83 ) },
		[9] = { coords = vec3( -1817.21,-2251.71,8.82 ) },
		[10] = { coords = vec3( -1891.52,-1324.93,2.52 ) },
		[11] = { coords = vec3( -3296.88,-26.11,2.66 ) },
		[12] = { coords = vec3( 1127.18,6854.84,8.67 ) },
		[13] = { coords = vec3( 3239.3,6523.48,6.2 ) },
		[14] = { coords = vec3( 3750.02,2729.3,5.72 ) },
		[15] = { coords = vec3( 3338.35,1358.5,4.65 ) },
		[16] = { coords = vec3( 2912.96,-2381.48,6.07 ) },
		[17] = { coords = vec3( -3336.23,1980.17,7.54 ) },
		[18] = { coords = vec3( -348.11,-3103.98,5.33 ) }
	}
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EM SERVIÇO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		if servico then
			time = 5
			drawTxt("~w~APERTE ~r~F7~w~ PARA FINALIZAR O EXPEDIENTE.\nCOLETO OS ~y~PEIXES~w~ PELOS PONTOS DO MAR.", 0.215,0.94)

			if IsControlJustPressed(0, 168) and not IsPedInAnyVehicle(PlayerPedId()) then
				servico = false
				sairServico()
				deletarVehicle()
				removeBlips()
			end
		end
		
		Citizen.Wait(time)
	end
end)

Citizen.CreateThread(function()
	while true do
		local time = 1000
		if segundos >= 0 then
			segundos = segundos - 1

			if segundos <= 0 then
				segundos = 0
			end
		end
		Citizen.Wait(time)
	end
end)
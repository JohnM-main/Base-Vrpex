------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local entregador = {
	["Entregador"] = {
		iniciar = vec3(53.62,114.67,79.2),
		pegarcaminhao = vec3(69.23,127.72,79.22),
		pegarcaixas = vec3(79.09,112.44,81.17)
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		for k,v in pairs(entregador) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 2.0 then
					time = 5
					DrawText3Ds(v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.1,"[~b~E~w~] PARA ENTRAR EM SERVIÇO.")

					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 5
						servico = true
						zonas = carregarZonas("Entregador", true)
					end
				end
			else
				local distance2 = #(playercoords - v.pegarcaminhao)
				if distance2 <= 2.0 then
					time = 5
					DrawText3Ds(v.pegarcaminhao[1],v.pegarcaminhao[2],v.pegarcaminhao[3]-0.1,"[~b~E~w~] PARA PEGAR O CAMINHÃO.")
					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 5
						criarVehicle(61.0,124.57,79.13,161.27,"boxville2", false)
					end
				end

				local distance3 = #(playercoords - v.pegarcaixas)
				if distance3 <= 2.0 then
					time = 5
					DrawText3Ds(v.pegarcaixas[1],v.pegarcaixas[2],v.pegarcaixas[3]-0.1,"[~b~E~w~] PARA COLETAS AS CAIXAS.")
					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 5
						
						local finished = vRP.taskBar(3500, math.random(10,20))
						if finished then
							local finished = vRP.taskBar(3500, math.random(10,20))
							if finished then
								local finished = vRP.taskBar(2500, math.random(10,20))
								if finished then
									vSERVER.giveCaixas(math.random(1,3))
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS DE ENTREGA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		if servico then
			for k,v in pairs(zonas) do
				local distance = #(playercoords - v.coords)
				if distance <= 30.0 and v.visivel then
					time = 5
					DrawMarker(21,v.coords[1],v.coords[2],v.coords[3],0,0,0,0,180.0,130.0,1.0,1.0,0.5, 25,140,255,180 ,1,0,0,1)

					if distance <= 2.5 then
						if IsControlJustReleased(1, 51) and segundos <= 0 and not IsPedInAnyVehicle(PlayerPedId()) then
							segundos = 5
							local vehicle = GetPlayersLastVehicle()
							if IsVehicleModel(vehicle,GetHashKey("boxville2")) then
								
								vRP.playAnim(true,{{"mp_common","givetake1_a"}},false)
								SetTimeout(3*1000, function()
									if payment("Entregador", 0)then
										zonas[k] = { coords = zonas[k].coords, visivel = false }
										removeToBlip(k)
									end
								end)

							else
								TriggerEvent("Notify","importante","Você não pode fazer entrega utilizando outro veiculo", 5)
							end
						end
					end

				end
			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EM SERVIÇO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		if servico then
			time = 5
			drawTxt("~w~APERTE ~r~F7~w~ PARA FINALIZAR O EXPEDIENTE.\nENTREGUE AS ~y~CAIXAS~w~ PELOS PONTOS NO MAPA.", 0.215,0.94)

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
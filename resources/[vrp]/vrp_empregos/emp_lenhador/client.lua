------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local lenhador = {
	["Lenhador"] = {
		iniciar = vec3(-841.65,5401.1,34.62),
		pegarcaminhao = vec3(-794.1,5410.68,34.22),
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		for k,v in pairs(lenhador) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 2.0 then
					time = 5
					DrawText3Ds(v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.1,"[~b~E~w~] PARA ENTRAR EM SERVIÇO.")

					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 10
						servico = true
						zonas = carregarZonas("Lenhador", true)
					end
				end
			else
				local distance2 = #(playercoords - v.pegarcaminhao)
				if distance2 <= 2.0 then
					time = 5
					DrawText3Ds(v.pegarcaminhao[1],v.pegarcaminhao[2],v.pegarcaminhao[3]-0.1,"[~b~E~w~] PARA PEGAR O CAMINHÃO.")
					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 10

						criarVehicle(-806.59,5411.33,33.99,59.27,"ratloader", false)
					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS DE COLETAR MADEIRA
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
							vRP._playAnim(false,{{"melee@hatchet@streamed_core","plyr_front_takedown_b"}},true)

							local finished = vRP.taskBar(3500, math.random(10,20))
							if finished then
								local finished = vRP.taskBar(3500, math.random(10,20))
								if finished then
									local finished = vRP.taskBar(2500, math.random(10,20))
									if finished then
										removeToBlip(k)
										zonas[k] = { coords = zonas[k].coords, visivel = false }
										payment("Lenhador", 0)
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EM SERVIÇO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		if servico then
			time = 5
			drawTxt("~w~APERTE ~r~F7~w~ PARA FINALIZAR O EXPEDIENTE.\nCOLETE AS ~y~MADEIRAS~w~ PELOS PONTOS NO MAPA.", 0.215,0.94)

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
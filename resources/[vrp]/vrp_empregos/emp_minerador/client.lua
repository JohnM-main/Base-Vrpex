------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local minerador = {
	["Minerador"] = {
		iniciar = vec3(1054.05,-1952.6,32.1),
		pegarcaminhao = vec3(1082.93,-1949.51,31.02),
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		for k,v in pairs(minerador) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 2.0 then
					time = 5
					DrawText3Ds(v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.1,"[~b~E~w~] PARA ENTRAR EM SERVIÇO.")

					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 10
						servico = true
						zonas = carregarZonas("Minerador", true)
					end
				end
			else
				local distance2 = #(playercoords - v.pegarcaminhao)
				if distance2 <= 2.0 then
					time = 5
					DrawText3Ds(v.pegarcaminhao[1],v.pegarcaminhao[2],v.pegarcaminhao[3]-0.1,"[~b~E~w~] PARA PEGAR O CAMINHÃO.")
					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 10
						criarVehicle(1074.19,-1949.35,30.65,146.81,"TipTruck", false)
					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS DE MINERAR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		if servico and segundos <= 0 then
			for k,v in pairs(zonas) do
				local distance = #(playercoords - v.coords)
				if distance <= 30.0 and v.visivel then
					time = 5
					DrawMarker(21,v.coords[1],v.coords[2],v.coords[3],0,0,0,0,180.0,130.0,1.0,1.0,0.5, 25,140,255,180 ,1,0,0,1)

					if distance <= 2.5 then
						if IsControlJustReleased(1, 51) and segundos <= 0 and not IsPedInAnyVehicle(PlayerPedId()) then
							segundos = 5
							vRP.CarregarObjeto("amb@world_human_const_drill@male@drill@base","base","prop_tool_jackham",15,28422)

							local finished = vRP.taskBar(3500, math.random(10,20))
							if finished then
								local finished = vRP.taskBar(3500, math.random(10,20))
								if finished then
									local finished = vRP.taskBar(2500, math.random(10,20))
									if finished then
										removeToBlip(k)
										zonas[k] = { coords = zonas[k].coords, visivel = false }
										payment("Minerador", math.random(6))
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
			drawTxt("~w~APERTE ~r~F7~w~ PARA FINALIZAR O EXPEDIENTE.\nCOLETE AS ~y~ROCHAS~w~ PELOS PONTOS NO MAPA.", 0.215,0.94)

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
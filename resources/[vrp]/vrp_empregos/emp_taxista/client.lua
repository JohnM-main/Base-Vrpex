------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local taxista = {
	["Taxista"] = {
		iniciar = vec3(895.21,-178.85,74.71),
		pegartaxi = vec3(900.12,-170.89,74.08)
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		for k,v in pairs(taxista) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 2.0 then
					time = 5
					DrawText3Ds(v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.1,"[~b~E~w~] PARA ENTRAR EM SERVIÇO.")

					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 5
						servico = true
						zonas = carregarZonas("Taxista", true)
						vSERVER.setTaxista(true)
					end
				end
			else
				local distance2 = #(playercoords - v.pegartaxi)
				if distance2 <= 2.0 then
					time = 5
					DrawText3Ds(v.pegartaxi[1],v.pegartaxi[2],v.pegartaxi[3]-0.1,"[~b~E~w~] PARA PEGAR O TAXI.")
					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 5
						criarVehicle(897.53,-183.54,73.38,237.22,"taxi", false)
					end
				end

			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS
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

					if distance <= 5.0 then
						if IsControlJustReleased(1, 51) and segundos <= 0 and IsPedInAnyVehicle(PlayerPedId()) then
							segundos = 15

							local vehicle = GetPlayersLastVehicle()
							if GetPedInVehicleSeat(vehicle, -1) then
								if IsVehicleModel(vehicle,GetHashKey("taxi")) then
									TriggerEvent("progress", 10)
									SetVehicleUndriveable(vehicle, true)

									SetTimeout(10*1000, function()
										removeToBlip(k)
										zonas[k] = { coords = zonas[k].coords, visivel = false }
										SetVehicleUndriveable(vehicle, false)
										payment("Taxista", 0)
									end)
								else
									TriggerEvent("Notify","importante","VOCÊ PRECISA DO VEICULO DO SERVIÇO.", 5)
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
-- EM SERVIÇO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		if servico then
			time = 5
			drawTxt("~w~APERTE ~r~F7~w~ PARA FINALIZAR O EXPEDIENTE.\nENTREGUE OS ~y~PASSAGEIROS~w~ PELA CIDADE.", 0.215,0.94)

			if IsControlJustPressed(0, 168) and not IsPedInAnyVehicle(PlayerPedId()) then
				servico = false
				sairServico()
				deletarVehicle()
				removeBlips()
				vSERVER.setTaxista(false)
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
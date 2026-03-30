------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local servico = false
local zonas = {}
local segundos = 0

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INICIAR EMPREGO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local tartarua = {
	["Tartaruga"] = {
		iniciar = vec3(3807.78,4478.64,6.37),
		pegarbarco = vec3(3856.64,4459.23,1.85),
	}
}

Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		for k,v in pairs(tartarua) do
			if not servico then
				local distance = #(playercoords - v.iniciar)
				if distance <= 2.0 then
					time = 5
					DrawText3Ds(v.iniciar[1],v.iniciar[2],v.iniciar[3]-0.1,"Aperte ~b~E~w~ para entrar em serviço.")

					if IsControlJustReleased(1, 51) and segundos <= 0 and checkInService() then
						segundos = 10
						servico = true
						zonas = carregarZonas("Tartaruga", true)
					end
				end
			else
				local distance2 = #(playercoords - v.pegarbarco)
				if distance2 <= 2.0 then
					time = 5
					DrawText3Ds(v.pegarbarco[1],v.pegarbarco[2],v.pegarbarco[3]-0.1,"Aperte ~b~E~w~ para pegar o barco.")
					if IsControlJustReleased(1, 51) and segundos <= 0 then
						segundos = 10
						criarVehicle(3854.16,4453.84,0.12,268.27,"dinghy", false)
					end
				end
			end
		end

		Citizen.Wait(time)
	end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ZONAS DE TARTARUGA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local playercoords = GetEntityCoords(ped)

		if servico then
			for k,v in pairs(zonas) do
				local distance = #(playercoords - v.coords)
				if distance <= 60.0 and v.visivel then
					time = 5
					DrawMarker(21,v.coords[1],v.coords[2],v.coords[3],0,0,0,0,180.0,130.0,1.0,1.0,0.5, 25,140,255,180 ,1,0,0,1)

					if distance <= 5.0 then
						drawTxt("Aperte ~b~E~w~ para pegar a tartaruga",0.5,0.96)
						if IsControlJustReleased(1, 51) and segundos <= 0 and not IsPedInAnyVehicle(PlayerPedId()) then
							segundos = 5
							payment("Tartaruga", 0)
							
							removeToBlip(k)
							zonas[k] = { coords = zonas[k].coords, visivel = false }
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
			drawTxt("~w~Aperte ~r~F7~w~ se deseja finalizar o expediente.\nColete as ~y~tartarugas~w~ pelos pontos do mar.", 0.215,0.94)

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

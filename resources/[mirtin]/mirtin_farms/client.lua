local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_farms",src)
vSERVER = Tunnel.getInterface("vrp_farms")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local isOpenned = false
local blips = {}
local in_rota = false
local itemRoute = ""
local itemName = ""
local itemAmountRoute = 0
local itemMinAmountRoute = 0
local itemMaxAmountRoute = 0
local itemNumRoute = 0
local segundos = 0
local typeRoute

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MENUS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function openNui(bancada, itens, org)
	if not isOpenned then
		SetNuiFocus(true,true)
		TransitionToBlurred(1000)
		SendNUIMessage({ showmenu = true, bancada = bancada, itens = itens, opennedOrg = org })
		isOpenned = true
	end
end

RegisterNUICallback("closeNui", function(data, cb)
	if isOpenned then
		SetNuiFocus(false, false)
		TransitionFromBlurred(1000)
		SendNUIMessage({ hidemenu = true })
		isOpenned = false
	end
end)

RegisterNUICallback("fabricarItem", function(data, cb)
	vSERVER.fabricarItem(data.item, data.minAmount, data.maxAmount)
end)

function src.closeNui()
	SetNuiFocus(false, false)
	TransitionFromBlurred(1000)
	SendNUIMessage({ hidemenu = true })
	isOpenned = false
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ABRIR MENU
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
		local pedCoords = GetEntityCoords(ped)

		if not isOpenned and not in_rota then 
			for k,v in pairs(cfg.initRoutesPositions)  do
				local distance = #(pedCoords - vec3(v.coords[1],v.coords[2],v.coords[3]))

				if distance <= 5.0 then
					DrawText3D(v.coords[1],v.coords[2],v.coords[3], v.text)

					if distance <= 1.5 then
						time = 5

						if IsControlJustPressed(0,38) and vSERVER.checkPermission(v.perm) then
							local bName,bItens = vSERVER.requestBancada(v.type)
							if bName and bItens then
								openNui(bName,bItens)
								typeRoute = v.type
							end
						end
					end
				end
				
			end
		end

		Citizen.Wait(time)
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ROTAS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.iniciarRota(item, itemName2, minAmount, maxAmount)
	if not in_rota then
		in_rota = true
		itemNumRoute = 1
		itemRoute = item
		itemName = itemName2
		itemMinAmountRoute = minAmount
		itemMaxAmountRoute = maxAmount
		itemAmountRoute = math.random(itemMinAmountRoute,itemMaxAmountRoute)

		CriandoBlip(itemNumRoute)

		async(function()
			while in_rota do
				local time = 1000
				local ped = PlayerPedId()
				local pedCoords = GetEntityCoords(ped)
				local distance = #(pedCoords - cfg.allRoutes[parseInt(itemNumRoute)].coords)
				if distance <= 15.0 then
					time = 5
					DrawMarker(20,cfg.allRoutes[parseInt(itemNumRoute)].coords[1],cfg.allRoutes[parseInt(itemNumRoute)].coords[2],cfg.allRoutes[parseInt(itemNumRoute)].coords[3],0,0,0,0,180.0,130.0,0.3,0.1,0.3, 255,0,0,180 ,1,0,0,1)

					if distance <= 2.0 then
						if IsControlJustReleased(1, 51) and segundos <= 0 and not IsPedInAnyVehicle(PlayerPedId()) then 
							segundos = 5

							if vSERVER.giveItem(itemRoute, parseInt(itemAmountRoute), typeRoute) then
								itemNumRoute = itemNumRoute + 1

								if itemNumRoute > #cfg.allRoutes then
									itemNumRoute = 1
								end

								itemAmountRoute = math.random(itemMinAmountRoute,itemMaxAmountRoute)
								RemoveBlip(blips)
								CriandoBlip(itemNumRoute)
							end
						end
					end
				end

				Citizen.Wait(time)
			end
		end)
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EM SERVIÇO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local time = 1000
		
		if in_rota then
			time = 5
			drawTxt("~w~APERTE ~r~F7~w~ PARA FINALIZAR A ENTREGA.\nCOLETE ~y~"..itemAmountRoute.."x "..itemName.."~w~.", 0.215,0.94)

			if IsControlJustPressed(0, 168) and not IsPedInAnyVehicle(PlayerPedId()) then
				in_rota = false
				itemRoute = ""
				itemName = ""
				itemAmountRoute = 0
				itemNumRoute = 0
				RemoveBlip(blips)
			end
		end

		if segundos >= 0 then
			segundos = segundos - 1

			if segundos <= 0 then
				segundos = 0
			end
		end
		
		Citizen.Wait(time)
	end
end)


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FARMS DE DROGAS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local coletando = false
local processando = false
local in_process = false
local selecionado = 1

Citizen.CreateThread(function()
    while true do
        local time = 1000
        if not coletando and not processando and not in_process then
            for k,v in pairs(cfg.farmDrogas) do
                local ped = PlayerPedId()
                local x,y,z = table.unpack(GetEntityCoords(ped))

                local bowz,cdz = GetGroundZFor_3dCoord(cfg.farmDrogas[k].Coletar[selecionado][1],cfg.farmDrogas[k].Coletar[selecionado][2],cfg.farmDrogas[k].Coletar[selecionado][3])
                local distance = GetDistanceBetweenCoords(cfg.farmDrogas[k].Coletar[selecionado][1],cfg.farmDrogas[k].Coletar[selecionado][2],cdz,x,y,z,true)

                if distance <= 8.0 and not coletando then
                    time = 5
                    DrawMarker(20,cfg.farmDrogas[k].Coletar[selecionado][1],cfg.farmDrogas[k].Coletar[selecionado][2],cfg.farmDrogas[k].Coletar[selecionado][3],0,0,0,0, 180.0,130.0,0.3,0.1,0.3, 12,231,254,180 ,1,0,0,1)
                    if distance <= 2.0 then
                        if IsControlJustReleased(1, 51) and segundos <= 0 and vSERVER.checkPermission("perm.drogas") then
                            segundos = 3
                            coletando = true
                            vRP._playAnim(false,{{cfg.farmDrogas[k].AnimacaoC[1],cfg.farmDrogas[k].AnimacaoC[2]}},false)
							TriggerEvent("progress", cfg.farmDrogas[k].AnimacaoC[3])
                            local random = math.random(#cfg.farmDrogas[k].Coletar)

                            async(function()
                                while coletando do
                                    Citizen.Wait(cfg.farmDrogas[k].AnimacaoC[3]*1000)
                                    vRP._stopAnim(false)
                                    vSERVER.giveItem(cfg.farmDrogas[k].itemQntdC[1], math.random(cfg.farmDrogas[k].itemQntdC[2]))
                                    selecionado = random
                                    coletando = false
                                end
                            end)

                            vSERVER.blockCommands(10)
                        end
                    end
                end
            end
        end

        Citizen.Wait(time)
    end
end)


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

function drawTxt(text,x,y)
	local res_x, res_y = GetActiveScreenResolution()

	SetTextFont(4)
	SetTextScale(0.3,0.3)
	SetTextColour(255,255,255,255)
	SetTextOutline()
	SetTextCentre(1)
	SetTextEntry("STRING")
	AddTextComponentString(text)

	if res_x >= 2000 then
		DrawText(x+0.076,y)
	else
		DrawText(x,y)
	end
end

function CriandoBlip(selecionado)
	blips = AddBlipForCoord(cfg.allRoutes[parseInt(selecionado)].coords[1],cfg.allRoutes[parseInt(selecionado)].coords[2],cfg.allRoutes[parseInt(selecionado)].coords[3])
	SetBlipSprite(blips,8)
	SetBlipColour(blips,1)
	SetBlipScale(blips,0.4)
	SetBlipAsShortRange(blips,false)
	SetBlipRoute(blips,true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Coleta")
	EndTextCommandSetBlipName(blips)
end
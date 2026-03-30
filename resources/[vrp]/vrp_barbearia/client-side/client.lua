local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_barbearia",src)
vSERVER = Tunnel.getInterface("vrp_barbearia")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local cam = -1
local myClothes = {}
local old_custom = {}
local currentCharacterMode = { fathersID = 0, mothersID = 0, skinColor = 0, shapeMix = 0.0, eyesColor = 0, eyebrowsHeight = 0, eyebrowsWidth = 0, noseWidth = 0, noseHeight = 0, noseLength = 0, noseBridge = 0, noseTip = 0, noseShift = 0, cheekboneHeight = 0, cheekboneWidth = 0, cheeksWidth = 0, lips = 0, jawWidth = 0, jawHeight = 0, chinLength = 0, chinPosition = 0, chinWidth = 0, chinShape = 0, neckWidth = 0, hairModel = 4, firstHairColor = 0, secondHairColor = 0, eyebrowsModel = 0, eyebrowsColor = 0, beardModel = -1, beardColor = 0, chestModel = -1, chestColor = 0, blushModel = -1, blushColor = 0, lipstickModel = -1, lipstickColor = 0, blemishesModel = -1, ageingModel = -1, complexionModel = -1, sundamageModel = -1, frecklesModel = -1, makeupModel = -1 }
local custom = currentCharacterMode

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LOCATIONS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local locations = {
	{ -813.37,-183.85,37.57 },
	{ 138.13,-1706.46,29.3 },
	{ -1280.92,-1117.07,7.0 },
	{ 1930.54,3732.06,32.85 },
	{ 1214.2,-473.18,66.21 },
	{ -33.61,-154.52,57.08 },
	{ -276.65,6226.76,31.7 }
}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- THREADOPEN
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		local timeDistance = 1000
		local ped = PlayerPedId()
		if not IsPedInAnyVehicle(ped) then
			local coords = GetEntityCoords(ped)
			for k,v in pairs(locations) do
				local distance = #(coords - vector3(v[1],v[2],v[3]))
				if distance <= 5.0 then
					timeDistance = 5
					DrawText3D(v[1],v[2],v[3],"[~g~E~w~] LOJA")
					if IsControlJustPressed(1,38) and distance <= 2.0 then
						local getCustom = vSERVER.getCustom()

						if getCustom then
							custom = getCustom
							old_custom = vRP.getCustomization()
							vSERVER.setInstance(true)

							displayBarbershop(true)
							SetEntityHeading(ped,332.21)
						end
					end
				end
			end
		end
		Citizen.Wait(timeDistance)
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATESKIN
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("updateSkin",function(data)
	myClothes = {}
	myClothes = { tonumber(data.hairModel), tonumber(data.firstHairColor), tonumber(data.secondHairColor), tonumber(data.makeupModel), tonumber(data.makeupintensity), tonumber(data.makeupcolor), tonumber(data.lipstickModel), tonumber(data.lipstickintensity), tonumber(data.lipstickColor), tonumber(data.eyebrowsModel), tonumber(data.eyebrowintensity), tonumber(data.eyebrowsColor), tonumber(data.beardModel), tonumber(data.beardintentisy), tonumber(data.beardColor), tonumber(data.blushModel), tonumber(data.blushintentisy), tonumber(data.blushColor) }

	custom.lipstickModel = tonumber(data.lipstickModel)
	custom.lipstickColor = tonumber(data.lipstickColor)
	custom.hairModel = tonumber(data.hairModel)
	custom.firstHairColor = tonumber(data.firstHairColor)
	custom.secondHairColor = tonumber(data.secondHairColor)
	custom.blushModel = tonumber(data.blushModel)
	custom.blushColor = tonumber(data.blushColor)
	custom.makeupModel = tonumber(data.makeupModel)
	custom.makeupcolor = tonumber(data.makeupcolor)
	custom.eyebrowsModel = tonumber(data.eyebrowsModel)
	custom.eyebrowsColor = tonumber(data.eyebrowsColor)
	custom.beardModel = tonumber(data.beardModel)
	custom.beardColor = tonumber(data.beardColor)

	if data.value then
		SetNuiFocus(false)
		displayBarbershop(false)
		vSERVER.setInstance(false)

		vSERVER.updateSkin(custom)
		SendNUIMessage({ openBarbershop = false })
	end

	changeApparence(myClothes)
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ROTATELEFT
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("rotate",function(data,cb)
	local ped = PlayerPedId()
	local heading = GetEntityHeading(ped)
	if data == "left" then
		SetEntityHeading(ped,heading+10)
	elseif data == "right" then
		SetEntityHeading(ped,heading-10)
	end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CLOSENUI
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("closeNui",function()
	SetNuiFocus(false)
	displayBarbershop(false)
	vSERVER.setInstance(false)

	SendNUIMessage({ openBarbershop = false })
	vRP.setCustomization(old_custom)
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DISPLAYBARBERSHOP
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function displayBarbershop(enable)
	local ped = PlayerPedId()
	if enable then
		SetNuiFocus(true,true)
		SendNUIMessage({ openBarbershop = true, hairModel =  tonumber(custom.hairModel), firstHairColor =  tonumber(custom.firstHairColor), secondHairColor =  tonumber(custom.secondHairColor), makeupModel =  tonumber(custom.makeupModel), makeupintensity = 10, makeupcolor = tonumber(custom.makeupcolor), lipstickModel =  tonumber(custom.lipstickModel), lipstickintensity = 10, lipstickColor =  tonumber(custom.lipstickColor), eyebrowsModel =  tonumber(custom.eyebrowsModel), eyebrowintensity = 10, eyebrowsColor =  tonumber(custom.eyebrowsColor), beardModel =  tonumber(custom.beardModel), beardintentisy = 10, beardColor =  tonumber(custom.beardColor), blushModel =  tonumber(custom.blushModel), blushintentisy = 10, blushColor = tonumber(custom.blushColor) })

		FreezeEntityPosition(ped,true)
		if IsDisabledControlJustReleased(0,24) or IsDisabledControlJustReleased(0,142) then
			SendNUIMessage({ type = "click" })
		end

		SetPlayerInvincible(ped,false) -- mqcu

		if not DoesCamExist(cam) then
			cam = CreateCam("DEFAULT_SCRIPTED_CAMERA",true)
			SetCamCoord(cam,GetEntityCoords(ped))
			SetCamRot(cam,0.0,0.0,0.0)
			SetCamActive(cam,true)
			RenderScriptCams(true,false,0,true,true)
			SetCamCoord(cam,GetEntityCoords(ped))
		end

		local x,y,z = table.unpack(GetEntityCoords(ped))
		SetCamCoord(cam,x+0.2,y+0.5,z+0.7)
		SetCamRot(cam,0.0,0.0,150.0)
		TriggerEvent("vrp_hud:hide", false)
	else
		FreezeEntityPosition(ped,false)
		SetPlayerInvincible(ped,false)
		RenderScriptCams(false,false,0,1,0)
		DestroyCam(cam,false)
		TriggerEvent("vrp_hud:hide", true)
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- UPDATECUSTOM
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
changeApparence = function(status)
	local ped = PlayerPedId()

	myClothes = {}
	myClothes = { status[1], status[2], status[3], status[4], status[5], status[6], status[7], status[8], status[9], status[10], status[11], status[12], status[13], status[14], status[15], status[16], status[17], status[18] }

	SetPedComponentVariation(ped,2,status[1],0,2)
	SetPedHairColor(ped,status[2],status[3])

	SetPedHeadOverlay(ped,4,status[4],0.99)
	SetPedHeadOverlayColor(ped,4,0,status[6],status[6])

	SetPedHeadOverlay(ped,8,status[7],0.99)
	SetPedHeadOverlayColor(ped,8,2,status[9],status[9])

	SetPedHeadOverlay(ped,2,status[10],0.99)
	SetPedHeadOverlayColor(ped,2,1,status[12],status[12])

	SetPedHeadOverlay(ped,1,status[13],0.99)
	SetPedHeadOverlayColor(ped,1,1,status[15],status[15])

	SetPedHeadOverlay(ped,5,status[16],0.99)
	SetPedHeadOverlayColor(ped,5,2,status[18],status[18])
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTROS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function f(n)
	n = n + 0.00000
	return n
end

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
	DrawRect(_x,_y+0.0125,0.01+factor,0.03,0,0,0,100)
end

function criarBlip()
    for _, item in pairs(locations) do
        item.blip = AddBlipForCoord(item[1], item[2], item[3])
        SetBlipSprite(item.blip, 71)
        SetBlipColour(item.blip, 13)
        SetBlipScale(item.blip, 0.4)
        SetBlipAsShortRange(item.blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Barbearia")
        EndTextCommandSetBlipName(item.blip)
    end
end

Citizen.CreateThread(function()
	SetNuiFocus(false,false)
	SendNUIMessage({ openBarbershop = false })
	displayBarbershop(false)
	criarBlip()
end)

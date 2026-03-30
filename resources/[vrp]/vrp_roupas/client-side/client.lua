local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_roupas",src)
vSERVER = Tunnel.getInterface("vrp_roupas")

-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIABLES
-----------------------------------------------------------------------------------------------------------------------------------------
local old_custom = {}
local nCustom = {}
local ultLoja = 0
local in_loja = false
local chegou = false
local noProvador = false
local pos = nil
local camPos = nil
local cam = -1
local dataPart = 1
local handsup = false
local cooldown = 0

local lojaderoupa = {
    {["id"] = 73, ["color"] = 13, x = 70.87, ["y"] = -1399.49, ["z"] = 29.39, ["provador"] = {["x"] = 70.87, ["y"] = -1399.49, ["z"] = 29.39, ["heading"] = 359.29}},
    {["x"] = 72.41, ["y"] = -1399.49, ["z"] = 29.39, ["provador"] = {["x"] = 72.41, ["y"] = -1399.49, ["z"] = 29.39, ["heading"] = 356.65}},
    {["x"] = 73.85, ["y"] = -1399.49, ["z"] = 29.39, ["provador"] = {["x"] = 73.85, ["y"] = -1399.49, ["z"] = 29.39, ["heading"] = 3.41}},
    {["x"] = 75.37, ["y"] = -1399.49, ["z"] = 29.39, ["provador"] = {["x"] = 75.37, ["y"] = -1399.49, ["z"] = 29.39, ["heading"] = 0.1}},

    { ["id"] = 73, ["color"] = 13, ["x"] = 430.1, ["y"] = -799.67, ["z"] = 29.52, ["provador"] = {["x"] = 430.1, ["y"] = -799.67, ["z"] = 29.52, ["heading"] = 177.1}},
    { ["x"] = 428.62, ["y"] = -799.67, ["z"] = 29.52, ["provador"] = {["x"] = 428.62, ["y"] = -799.67, ["z"] = 29.52, ["heading"] = 173.11}},
    { ["x"] = 427.06, ["y"] = -799.67, ["z"] = 29.52, ["provador"] = {["x"] = 427.06, ["y"] = -799.67, ["z"] = 29.52, ["heading"] = 192.52}},
    { ["x"] = 425.62, ["y"] = -799.67, ["z"] = 29.52, ["provador"] = {["x"] = 425.62, ["y"] = -799.67, ["z"] = 29.52, ["heading"] = 181.76}},

    { ["id"] = 73, ["color"] = 13, ["x"] = 128.63, ["y"] = -220.14, ["z"] = 54.56, ["provador"] = {["x"] = 128.63, ["y"] = -220.14, ["z"] = 54.56, ["heading"] = 115.46}},
    { ["x"] = 129.23, ["y"] = -218.53, ["z"] = 54.56, ["provador"] = {["x"] = 129.23, ["y"] = -218.53, ["z"] = 54.56, ["heading"] = 107.44}},
    { ["x"] = 129.94, ["y"] = -216.27, ["z"] = 54.56, ["provador"] = {["x"] = 129.94, ["y"] = -216.27, ["z"] = 54.56, ["heading"] = 128.95}},
    { ["x"] = 130.7, ["y"] = -214.05, ["z"] = 54.56, ["provador"] = {["x"] = 130.7, ["y"] = -214.05, ["z"] = 54.56, ["heading"] = 95.77}},

    { ["id"] = 73, ["color"] = 13, ["x"] = -165.9, ["y"] = -310.94, ["z"] = 39.74, ["provador"] = {["x"] = -165.9, ["y"] = -310.94, ["z"] = 39.74, ["heading"] = 248.85}},
    { ["x"] = -165.6, ["y"] = -309.52, ["z"] = 39.74, ["provador"] = {["x"] = -165.6, ["y"] = -309.52, ["z"] = 39.74, ["heading"] = 251.32}},
    { ["x"] = -165.09, ["y"] = -308.15, ["z"] = 39.74, ["provador"] = {["x"] = -165.09, ["y"] = -308.15, ["z"] = 39.74, ["heading"] = 213.57}},
    { ["x"] = -164.74, ["y"] = -306.74, ["z"] = 39.74, ["provador"] = {["x"] = -164.74, ["y"] = -306.74, ["z"] = 39.74, ["heading"] = 286.29}},

    { ["id"] = 73, ["color"] = 13, ["x"] = -830.4, ["y"] = -1072.88, ["z"] = 11.33, ["provador"] = {["x"] = -830.4, ["y"] = -1072.88, ["z"] = 11.33, ["heading"] = 292.33}},
    { ["x"] = -829.63, ["y"] = -1074.25, ["z"] = 11.33, ["provador"] = {["x"] = -829.63, ["y"] = -1074.25, ["z"] = 11.33, ["heading"] = 311.26}},
    { ["x"] = -828.85, ["y"] = -1075.51, ["z"] = 11.33, ["provador"] = {["x"] = -828.85, ["y"] = -1075.51, ["z"] = 11.33, ["heading"] = 304.74}},
    { ["x"] = -828.07, ["y"] = -1076.79, ["z"] = 11.33, ["provador"] = {["x"] = -828.07, ["y"] = -1076.79, ["z"] = 11.33, ["heading"] = 312.29}},

    { ["id"] = 73, ["color"] = 13, ["x"] = -714.24, ["y"] = -145.74, ["z"] = 37.42, ["provador"] = {["x"] = -714.24, ["y"] = -145.74, ["z"] = 37.42, ["heading"] = 141.83}},
    { ["x"] = -713.1, ["y"] = -147.37, ["z"] = 37.42, ["provador"] = {["x"] = -713.1, ["y"] = -147.37, ["z"] = 37.42, ["heading"] = 130.49}},
    { ["x"] = -712.46, ["y"] = -148.6, ["z"] = 37.42, ["provador"] = {["x"] = -712.46, ["y"] = -148.6, ["z"] = 37.42, ["heading"] = 80.07}},
    { ["x"] = -711.74, ["y"] = -149.56, ["z"] = 37.42, ["provador"] = {["x"] = -711.74, ["y"] = -149.56, ["z"] = 37.42, ["heading"] = 178.12}},

    { ["id"] = 73, ["color"] = 13, ["x"] = -1198.0, ["y"] = -769.28, ["z"] = 17.32, ["provador"] = {["x"] = -1198.0, ["y"] = -769.28, ["z"] = 17.32, ["heading"] = 222.52}}, 
    { ["x"] = -1199.6, ["y"] = -770.57, ["z"] = 17.32, ["provador"] = {["x"] = -1199.6, ["y"] = -770.57, ["z"] = 17.32, ["heading"] = 217.49}}, 
    { ["x"] = -1201.26, ["y"] = -771.96, ["z"] = 17.32, ["provador"] = {["x"] = -1201.26, ["y"] = -771.96, ["z"] = 17.32, ["heading"] = 179.08}}, 
    { ["x"] = -1202.65, ["y"] = -773.12, ["z"] = 17.32, ["provador"] = {["x"] = -1202.65, ["y"] = -773.12, ["z"] = 17.32, ["heading"] = 214.11}}, 

    { ["id"] = 73, ["color"] = 13, ["x"] = -1448.24, ["y"] = -235.21, ["z"] = 49.82, ["provador"] = {["x"] = -1448.24, ["y"] = -235.21, ["z"] = 49.82, ["heading"] = 95.97}},
    { ["x"] = -1446.95, ["y"] = -233.58, ["z"] = 49.82, ["provador"] = {["x"] = -1446.95, ["y"] = -233.58, ["z"] = 49.82, ["heading"] = 10.74}},
    { ["x"] = -1445.87, ["y"] = -232.37, ["z"] = 49.82, ["provador"] = {["x"] = -1445.87, ["y"] = -232.37, ["z"] = 49.82, ["heading"] = 56.05}},
    { ["x"] = -1444.85, ["y"] = -231.29, ["z"] = 49.82, ["provador"] = {["x"] = -1444.85, ["y"] = -231.29, ["z"] = 49.82, ["heading"] = 50.59}},

    { ["id"] = 73, ["color"] = 13, ["x"] = -3167.29, ["y"] = 1047.19, ["z"] = 20.87, ["provador"] = {["x"] = -3167.29, ["y"] = 1047.19, ["z"] = 20.87, ["heading"] = 84.66}},
    { ["x"] = -3166.22, ["y"] = 1049.4, ["z"] = 20.87, ["provador"] = {["x"] = -3166.22, ["y"] = 1049.4, ["z"] = 20.87, ["heading"] = 95.4}},
    { ["x"] = -3165.14, ["y"] = 1051.79, ["z"] = 20.87, ["provador"] = {["x"] = -3165.14, ["y"] = 1051.79, ["z"] = 20.87, ["heading"] = 74.04}},
    { ["x"] = -3164.5, ["y"] = 1053.44, ["z"] = 20.87, ["provador"] = {["x"] = -3164.5, ["y"] = 1053.44, ["z"] = 20.87, ["heading"] = 66.15}},

    { ["id"] = 73, ["color"] = 13, ["x"] = -1109.44, ["y"] = 2709.55, ["z"] = 19.11, ["provador"] = {["x"] = -1109.44, ["y"] = 2709.55, ["z"] = 19.11, ["heading"] = 311.52}},
    { ["x"] = -1108.37, ["y"] = 2708.43, ["z"] = 19.11, ["provador"] = {["x"] = -1108.37, ["y"] = 2708.43, ["z"] = 19.11, ["heading"] = 314.75}},
    { ["x"] = -1107.43, ["y"] = 2707.32, ["z"] = 19.11, ["provador"] = {["x"] = -1107.43, ["y"] = 2707.32, ["z"] = 19.11, ["heading"] = 307.39}},
    { ["x"] = -1106.33, ["y"] = 2706.17, ["z"] = 19.11, ["provador"] = {["x"] = -1106.33, ["y"] = 2706.17, ["z"] = 19.11, ["heading"] = 325.3}},

    { ["id"] = 73, ["color"] = 13, ["x"] = 612.87, ["y"] = 2758.49, ["z"] = 42.09, ["provador"] = {["x"] = 612.87, ["y"] = 2758.49, ["z"] = 42.09, ["heading"] = 292.48}},
    { ["x"] = 613.12, ["y"] = 2756.56, ["z"] = 42.09, ["provador"] = {["x"] = 613.12, ["y"] = 2756.56, ["z"] = 42.09, ["heading"] = 283.19}},
    { ["x"] = 613.13, ["y"] = 2753.29, ["z"] = 42.09, ["provador"] = {["x"] = 613.13, ["y"] = 2753.29, ["z"] = 42.09, ["heading"] = 264.95}},
    { ["x"] = 613.26, ["y"] = 2751.39, ["z"] = 42.09, ["provador"] = {["x"] = 613.26, ["y"] = 2751.39, ["z"] = 42.09, ["heading"] = 280.25}},
    
    { ["id"] = 73, ["color"] = 13, ["x"] = 1190.08, ["y"] = 2714.76, ["z"] = 38.23, ["provador"] = {["x"] = 1190.08, ["y"] = 2714.76, ["z"] = 38.23, ["heading"] = 267.87}},
    { ["x"] = 1190.18, ["y"] = 2713.24, ["z"] = 38.23, ["provador"] = {["x"] = 1190.18, ["y"] = 2713.24, ["z"] = 38.23, ["heading"] = 276.04}},
    { ["x"] = 1190.09, ["y"] =  2711.73, ["z"] = 38.23, ["provador"] = {["x"] = 1190.09, ["y"] =  2711.73, ["z"] = 38.23, ["heading"] = 280.45}},
    { ["x"] = 1190.07, ["y"] = 2710.23, ["z"] = 38.23, ["provador"] = {["x"] = 1190.07, ["y"] = 2710.23, ["z"] = 38.23, ["heading"] = 283.45}},

    { ["id"] = 73, ["color"] = 13, ["x"] = 1697.49, ["y"] = 4829.94, ["z"] = 42.07, ["provador"] = {["x"] = 1697.49, ["y"] = 4829.94, ["z"] = 42.07, ["heading"] = 179.54}},
    { ["x"] = 1695.95, ["y"] = 4829.75, ["z"] = 42.07, ["provador"] = {["x"] = 1695.95, ["y"] = 4829.75, ["z"] = 42.07, ["heading"] = 201.35}},
    { ["x"] = 1694.54, ["y"] = 4829.57, ["z"] = 42.07, ["provador"] = {["x"] = 1694.54, ["y"] = 4829.57, ["z"] = 42.07, ["heading"] = 186.38}},
    { ["x"] = 1693.04, ["y"] = 4829.35, ["z"] = 42.07, ["provador"] = {["x"] = 1693.04, ["y"] = 4829.35, ["z"] = 42.07, ["heading"] = 190.91}},

    { ["id"] = 73, ["color"] = 13, ["x"] = 12.7, ["y"] = 6513.6, ["z"] = 31.878, ["provador"] = {["x"] = 12.7, ["y"] = 6513.6, ["z"] = 31.878, ["heading"] = 134.57}},    
    { ["x"] = 11.7, ["y"] = 6514.76, ["z"] = 31.878, ["provador"] = {["x"] = 11.7, ["y"] = 6514.76, ["z"] = 31.878, ["heading"] = 134.28}},    
    { ["x"] = 10.74, ["y"] = 6515.8, ["z"] = 31.878, ["provador"] = {["x"] = 10.74, ["y"] = 6515.8, ["z"] = 31.878, ["heading"] = 138.6}},    
    { ["x"] = 9.66, ["y"] = 6516.88, ["z"] = 31.878, ["provador"] = {["x"] = 9.66, ["y"] = 6516.88, ["z"] = 31.878, ["heading"] = 150.98}},  
    { ["x"] = -634.97, ["y"] = 227.64, ["z"] = 81.89, ["provador"] = {["x"] = -634.97, ["y"] = 227.64, ["z"] = 81.89, ["heading"] =  182.62}},  

    --Hp
    { ["x"] = -438.12, ["y"] = -307.57, ["z"] = 34.92, ["provador"] = {["x"] = -438.12, ["y"] = -307.57, ["z"] = 34.92, ["heading"] =  197.14}},  

    --Dp
    { ["x"] = 463.27, ["y"] = -996.37, ["z"] = 30.69, ["provador"] = {["x"] = 463.27, ["y"] = -996.37, ["z"] = 30.69, ["heading"] =  89.77}},  
    --Vanilla
  
    { ["x"] = 99.73, ["y"] = -1311.91, ["z"] = 29.27, ["provador"] = {["x"] = 99.73, ["y"] = -1311.91, ["z"] = 29.27, ["heading"] = 210.64}},  
    --Bahamas
    
    { ["x"] = -1372.39, ["y"] = -618.71, ["z"] = 30.32, ["provador"] = {["x"] = -1372.39, ["y"] = -618.71, ["z"] = 30.32, ["heading"] = 213.93}},  
}



local parts = {
    mascara = 1,
    mao = 3,
    calca = 4,
    mochila = 5,
    sapato = 6,
    gravata = 7,
    camisa = 8,
    colete = 9,
    jaqueta = 11,
    bone = "p0",
    oculos = "p1",
    brinco = "p2",
    relogio = "p6",
    bracelete = "p7"
}

function SetCameraCoords()
    local ped = PlayerPedId()
	RenderScriptCams(false, false, 0, 1, 0)
    DestroyCam(cam, false)
    
	if not DoesCamExist(cam) then
        cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
		SetCamActive(cam, true)
        RenderScriptCams(true, true, 500, true, true)

        pos = GetEntityCoords(PlayerPedId())
        camPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 2.0, 0.0)
        SetCamCoord(cam, camPos.x, camPos.y, camPos.z+0.75)
        PointCamAtCoord(cam, pos.x, pos.y, pos.z+0.15)
    end

end

function DeleteCam()
	SetCamActive(cam, false)
	RenderScriptCams(false, true, 0, true, true)
	cam = nil
end

RegisterNUICallback("changePart", function(data, cb)
    dataPart = parts[data.part]
    local ped = PlayerPedId()
    if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
        SendNUIMessage({ 
            changeCategory = true, 
            sexo = "Male", prefix = "M", 
            drawa = vRP.getDrawables(dataPart), category = dataPart,
        })
    elseif GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then 
        SendNUIMessage({ 
            changeCategory = true, 
            sexo = "Female", prefix = "F", 
            drawa = vRP.getDrawables(dataPart), category = dataPart,
        })
    end
end)

RegisterNUICallback("updateColor", function(data, cb)
    local dataPart = parts[data.part]
    local ped = PlayerPedId()
    if type(dados) == "number" then
        max = GetNumberOfPedTextureVariations(PlayerPedId(), dados, tipo)
    elseif type(dados) == "string" then
        max = GetNumberOfPedPropTextureVariations(PlayerPedId(), parse_part(dados), tipo)
    end

    if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
        SendNUIMessage({ 
            changeCategoryColor = true, 
            sexo = "Male", prefix = "M", 
            max = max, category = dataPart,
        })
    elseif GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then 
        SendNUIMessage({ 
            changeCategoryColor = true, 
            sexo = "Female", prefix = "F", 
            max = max, category = dataPart,
        })
    end
end)

CreateThread(function()
    while true do
        local timeDistance = 1000
        local ped = PlayerPedId()
        if not IsPedInAnyVehicle(ped) then
            local plyCds = GetEntityCoords(ped, true)
            for k, v in pairs(lojaderoupa) do
                local provador = v.provador
                local coords = #(plyCds - vector3(v["x"],v["y"],v["z"]))
                if coords <= 5 and not in_loja and (cooldown == 0) then 
                    DrawText3D(v["x"],v["y"],v["z"],"[~g~E~w~] LOJA")
                    timeDistance = 5
                    if GetDistanceBetweenCoords(GetEntityCoords(ped), v["x"],v["y"],v["z"], true ) < 1 then
                        local abrirLojaDeRoupa = false
                        if IsControlJustPressed(0, 38) then
                            abrirLojaDeRoupa = true 
            
                            if abrirLojaDeRoupa then 
                                TriggerEvent("vrp_hud:hide", false)
                                ultLoja = k
                                noProvador = true
                                old_custom = vRP.getCustomization()

                                Citizen.Wait(40)
                                nCustom = old_custom
                                old = {}
                
                                lojaProvador()
                
                                cor = 0
                                dados, tipo = nil
                
                                TaskGoToCoordAnyMeans(ped, provador.x, provador.y, provador.z, 1.0, 0, 0, 786603, 0xbf800000)
                            end
                        end
                    end
                end
                
        
                if noProvador then
                    if GetDistanceBetweenCoords(GetEntityCoords(ped), provador.x, provador.y, provador.z, true ) < 0.5 and not chegou then
                        chegou = true
                        SetEntityHeading(PlayerPedId(), provador.heading)
                        FreezeEntityPosition(ped, true)
                        SetEntityInvincible(ped, false)
                        openGuiLojaRoupa()
                    end
                end
            end
        end
        Citizen.Wait(timeDistance)
    end
end)

function openGuiLojaRoupa()
    local ped = PlayerPedId()
    SetNuiFocus(true, true)
    SetCameraCoords()
    if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then
        SendNUIMessage({ 
            openLojaRoupa = true, 
            sexo = "Male", prefix = "M", 
            drawa = vRP.getDrawables(dataPart), category = dataPart,
            oldCustom = nCustom,
            ultLoja = ultLoja
        })
    elseif GetEntityModel(ped) == GetHashKey("mp_f_freemode_01") then 
        SendNUIMessage({ 
            openLojaRoupa = true, 
            sexo = "Female", prefix = "F", 
            drawa = vRP.getDrawables(dataPart), category = dataPart,
            oldCustom = nCustom,
            ultLoja = ultLoja
        })
    end
    in_loja = true
end

RegisterNUICallback("leftHeading", function(data, cb)
    local currentHeading = GetEntityHeading(PlayerPedId())
    heading = currentHeading-tonumber(data.value)
    SetEntityHeading(PlayerPedId(), heading)
end)


RegisterNUICallback("rightHeading", function(data, cb)
    local currentHeading = GetEntityHeading(PlayerPedId())
    heading = currentHeading+tonumber(data.value)
    SetEntityHeading(PlayerPedId(), heading)
end)

RegisterNUICallback("changeColor", function(data, cb)
    if type(dados) == "number" then
        max = GetNumberOfPedTextureVariations(PlayerPedId(), dados, tipo)
    elseif type(dados) == "string" then
        max = GetNumberOfPedPropTextureVariations(PlayerPedId(), parse_part(dados), tipo)
    end

    if data.action == "menos" then
        if cor > 0 then cor = cor - 1 else cor = max end
    elseif data.action == "mais" then
        if cor < max then cor = cor + 1 else cor = 0 end
    end
    if dados and tipo then 
        setRoupa(dados, tipo, cor) 
        SendNUIMessage({ 
            atualizaRoupa = true, 
            type = tipo,
            color = cor
        })
    end
end)

function changeClothe(type, id, color)
    dados = type
    tipo = tonumber(parseInt(id))
	cor = color
 
    setRoupa(dados, tipo, cor)
end

function setRoupa(dados, tipo, cor)
    local ped = PlayerPedId()

    if type(dados) == "number" then
		SetPedComponentVariation(ped, dados, tipo, cor, 1)
    elseif type(dados) == "string" then
        if(tipo == -1) then 
            ClearPedProp(ped, parse_part(dados))
        else      
            SetPedPropIndex(ped, parse_part(dados), tipo, cor, 1)
        end        
        dados = "p" .. (parse_part(dados))
	end
	  
  	custom = vRP.getCustomization()
  	custom.modelhash = nil

	aux = old_custom[dados]
	v = custom[dados]

    if v[1] ~= aux[1] and old[dados] ~= "custom" then
    	old[dados] = "custom"
    end
    if v[1] == aux[1] and old[dados] == "custom" then
    	old[dados] = "0"
	end
end

RegisterNUICallback("changeCustom", function(data, cb)
    changeClothe(data.type, data.id, data.color)
end)

RegisterNUICallback("payament", function(data, cb)
    vSERVER.updateClothes(data.parts)
    old_custom = {}
    closeGuiLojaRoupa()
    ClearPedTasks(PlayerPedId())
end)

RegisterNUICallback("reset", function(data, cb)
    vRP.setCustomization(old_custom)
    old_custom = {}
    closeGuiLojaRoupa()
    ClearPedTasks(PlayerPedId())
end)

function closeGuiLojaRoupa()
    local ped = PlayerPedId()
    DeleteCam()
    SetNuiFocus(false, false)
    SendNUIMessage({ openLojaRoupa = false })
    FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false)    
    in_loja = false
    noProvador = false
    chegou = false
    old_custom = {}
    old = nil
    TriggerEvent("vrp_hud:hide", true)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GET CUSTOMIZATION
-----------------------------------------------------------------------------------------------------------------------------------------
function getCustomization()
	local ped = PlayerPedId()
	local custom = {}

	for i = 0,20 do
		if i ~= 2 then 
			custom[i] = { GetPedDrawableVariation(ped,i),GetPedTextureVariation(ped,i),GetPedPaletteVariation(ped,i) }
		end
	end

	for i = 0,10 do
		custom["p"..i] = { GetPedPropIndex(ped,i),math.max(GetPedPropTextureIndex(ped,i),0) }
	end

	return custom
end

function parse_part(key)
    if type(key) == "string" and string.sub(key, 1, 1) == "p" then
        return tonumber(string.sub(key, 2))
    else
        return false, tonumber(key)
    end
end

function lojaProvador() 
    Citizen.CreateThread(function()
        while true do
            local time = 1000

            if noProvador then
                time = 5
                DisableControlAction(1, 1, true)
                DisableControlAction(1, 2, true)
                DisableControlAction(1, 24, true)
                DisablePlayerFiring(PlayerPedId(), true)
                DisableControlAction(1, 142, true)
                DisableControlAction(1, 106, true)
                DisableControlAction(1, 37, true)
            end

            Citizen.Wait(time)
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        N_0xf4f2c0d4ee209e20()
        Citizen.Wait(1000)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- ROTATE
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("rotate",function(data,cb)
	local ped = PlayerPedId()
	local heading = GetEntityHeading(ped)
	if data == "left" then
		SetEntityHeading(ped,heading + 10)
	elseif data == "right" then
		SetEntityHeading(ped,heading - 10)
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- HANDSUP
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback("handsup",function(data,cb)
    local ped = PlayerPedId()
    if IsEntityPlayingAnim(ped,"random@mugging3","handsup_standing_base",3) then
        vRP.stopAnim()
    else
		vRP._playAnim(true,{{"random@mugging3","handsup_standing_base"}},false)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ROUPAS
-----------------------------------------------------------------------------------------------------------------------------------------
function src.updateClothes(tipo,item,textura)
	local ped = PlayerPedId()

	if tipo == "oculos" then
		SetPedPropIndex(ped, 1, item,textura,2)

		if item == nil then
			if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
				SetPedPropIndex(ped, 1, 14,0,2)

			elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
				SetPedPropIndex(ped, 1, 12,0,2)
			end
		end
	elseif tipo == "chapeu" then
		SetPedPropIndex(ped, 0, item,textura,2)

		if item == nil then
			if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
				SetPedPropIndex(ped, 0, 8,0,2)

			elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
				SetPedPropIndex(ped, 0, 57,0,2)
			end
		end
	elseif tipo == "colete" then
		SetPedComponentVariation(ped, 9,item,textura,2)

		if item == nil then
			SetPedComponentVariation(ped, 9, 0,0,2)
		end
	elseif tipo == "acessorio" then
		SetPedComponentVariation(ped, 7,item,textura,2)
		
		if item == nil then
			SetPedComponentVariation(ped, 9, 0,0,2)
		end

	elseif tipo == "sapato" then
		SetPedComponentVariation(ped, 6,item,textura,2)

		if item == nil then
			if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
				SetPedComponentVariation(ped, 6, 34,0,2)

			elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
				SetPedComponentVariation(ped, 6, 35,0,2)
			end
		end
	elseif tipo == "mochila" then
		SetPedComponentVariation(ped, 5,item,textura,2)

		if item == nil then
			SetPedComponentVariation(ped, 5, 0,0,2)
		end
	elseif tipo == "mascara" then
		SetPedComponentVariation(ped, 1, item,textura,2)

		if item == nil then
			SetPedComponentVariation(ped,1,0,0,2)
		end
	elseif tipo == "jaqueta" then
		SetPedComponentVariation(ped, 11,item,textura,2)

		if item == nil then
			if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
				SetPedComponentVariation(ped, 11, 15,0,2)

			elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
				SetPedComponentVariation(ped, 11, 18,0,2)
			end
		end
	elseif tipo == "mao" then
		SetPedComponentVariation(ped, 3,item,textura,2)

		if item == nil then
			SetPedComponentVariation(ped, 3, 15,0,2)
		end
	elseif tipo == "calca" then
		SetPedComponentVariation(ped, 4,item,textura,2)

		if item == nil then
			if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
				SetPedComponentVariation(ped, 4, 21,0,2)

			elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
				SetPedComponentVariation(ped, 4, 17,0,2)
			end
		end
	elseif tipo == "blusa" then
		SetPedComponentVariation(ped, 8,item,textura,2)

		if item == nil then
			if GetEntityModel(PlayerPedId()) == GetHashKey("mp_m_freemode_01") then
				SetPedComponentVariation(ped, 8, 15,0,2)

			elseif GetEntityModel(PlayerPedId()) == GetHashKey("mp_f_freemode_01") then
				SetPedComponentVariation(ped, 8, 7,0,2)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- STOP RSRC
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        closeGuiLojaRoupa()
    end
end)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTROS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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

CreateThread(function()
    while true do 
        if cooldown > 0 then             
            cooldown = cooldown - 1
        end
        Citizen.Wait(1000)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- CRIAR BLIP
-----------------------------------------------------------------------------------------------------------------------------------------
local blips = {}

Citizen.CreateThread(function()
	SetNuiFocus(false,false)
	criarblips()
end)

function criarblips()
	for k,v in pairs(lojaderoupa) do
		if v.id ~= nil then
            blips[k] = AddBlipForCoord(v.x,v.y,v.z)
            SetBlipSprite(blips[k], 73)
            SetBlipColour(blips[k], 13)
            SetBlipScale(blips[k], 0.4)
            SetBlipAsShortRange(blips[k], true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Loja de Roupas")
            EndTextCommandSetBlipName(blips[k])
        end
	end
end

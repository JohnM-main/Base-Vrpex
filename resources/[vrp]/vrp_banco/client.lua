local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP","vrp_banco")

src = {}
Tunnel.bindInterface("vrp_banco",src)
vSERVER = Tunnel.getInterface("vrp_banco")
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local segundos = 0
local oppened = nil

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- BANCO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local locations = {
  [1] = { tipo = "banco", coords = vec3(150.12,-1040.8,29.38), text = "~b~[E]~w~ BANCO" },
  [2] = { tipo = "banco", coords = vec3(237.35,217.86,106.29), text = "~b~[E]~w~ BANCO" },
  [3] = { tipo = "banco", coords = vec3(314.09,-279.04,54.18), text = "~b~[E]~w~ BANCO" },
  [4] = { tipo = "banco", coords = vec3(-2962.58,482.54,15.71), text = "~b~[E]~w~ BANCO" },
  [5] = { tipo = "banco", coords = vec3(-112.29,6469.39,31.63), text = "~b~[E]~w~ BANCO" },
  [6] = { tipo = "banco", coords = vec3(1175.04,2706.82,38.1), text = "~b~[E]~w~ BANCO" },
  [7] = { tipo = "banco", coords = vec3(-351.68,-49.64,49.05), text = "~b~[E]~w~ BANCO" },
  [8] = { tipo = "banco", coords = vec3(817.15,-929.23,32.4), text = "~b~[E]~w~ BANCO" },
  [9] = { tipo = "banco", coords = vec3(-1211.07,-329.89,37.79), text = "~b~[E]~w~ BANCO" },
  
  [10] = { tipo = "caixaeletronico", coords = vec3(89.57,2.16,68.32), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [11] = { tipo = "caixaeletronico", coords = vec3(-526.53,-1222.80,18.45), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [12] = { tipo = "caixaeletronico", coords = vec3(-2072.61,-317.18,13.31), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [13] = { tipo = "caixaeletronico", coords = vec3(-821.61,-1082.05,11.13), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [14] = { tipo = "caixaeletronico", coords = vec3(1686.60,4815.74,42.00), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [15] = { tipo = "caixaeletronico", coords = vec3(-386.82,6045.96,31.50), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [16] = { tipo = "caixaeletronico", coords = vec3(1172.47,2702.48,38.17), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [17] = { tipo = "caixaeletronico", coords = vec3(1968.07,3743.59,32.34), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [18] = { tipo = "caixaeletronico", coords = vec3(2558.94,350.94,108.62), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [19] = { tipo = "caixaeletronico", coords = vec3(1153.74,-326.77,69.20), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [20] = { tipo = "caixaeletronico", coords = vec3(-56.98,-1752.12,29.42), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [21] = { tipo = "caixaeletronico", coords = vec3(-3241.09,997.48,12.55), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [22] = { tipo = "caixaeletronico", coords = vec3(-1827.16,784.97,138.30), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [23] = { tipo = "caixaeletronico", coords = vec3(-1091.33,2708.48,18.95), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [24] = { tipo = "caixaeletronico", coords = vec3(112.63,-819.19,31.33), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [25] = { tipo = "caixaeletronico", coords = vec3(-256.15,-716.03,33.51), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [26] = { tipo = "caixaeletronico", coords = vec3(-258.62,-723.49,33.43), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [27] = { tipo = "caixaeletronico", coords = vec3(174.32,6637.82,31.57), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [28] = { tipo = "caixaeletronico", coords = vec3(-660.69,-853.86,24.48), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [29] = { tipo = "caixaeletronico", coords = vec3(147.64,-1035.50,29.34), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR" },
  [30] = { tipo = "caixaeletronico", coords = vec3(146.09,-1034.96,29.34), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR" },
  [31] = { tipo = "caixaeletronico", coords = vec3(-866.53,-187.66,37.83), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [32] = { tipo = "caixaeletronico", coords = vec3(-867.49,-186.01,37.83), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [33] = { tipo = "caixaeletronico", coords = vec3(472.41,-1001.43,30.7), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [34] = { tipo = "caixaeletronico", coords = vec3(296.18,-591.49,43.27), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" }, --HP ANTIGO
  [35] = { tipo = "caixaeletronico", coords = vec3(296.23,-894.11,29.22), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [36] = { tipo = "caixaeletronico", coords = vec3(295.67,-896.07,29.21), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [37] = { tipo = "caixaeletronico", coords = vec3(-717.56,-915.68,19.21), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [38] = { tipo = "caixaeletronico", coords = vec3(33.16,-1348.11,29.49), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [39] = { tipo = "caixaeletronico", coords = vec3(119.08,-883.86,31.13), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [40] = { tipo = "caixaeletronico", coords = vec3(129.63,-12,29.26), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" }, --Limbo
  [41] = { tipo = "caixaeletronico", coords = vec3(122.27,-1293.51,29.26), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [42] = { tipo = "caixaeletronico", coords = vec3(288.95,-1256.81,29.44), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [43] = { tipo = "caixaeletronico", coords = vec3(-31.49,-1121.46,26.55), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [44] = { tipo = "caixaeletronico", coords = vec3(-203.75,-861.52,30.26), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [45] = { tipo = "caixaeletronico", coords = vec3(-1109.71,-1690.73,4.37), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [46] = { tipo = "caixaeletronico", coords = vec3(-1430.10,-211.08,46.50), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [47] = { tipo = "caixaeletronico", coords = vec3(540.28,2671.14,42.15), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [48] = { tipo = "caixaeletronico", coords = vec3(2683.08,3286.57,55.24), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [49] = { tipo = "caixaeletronico", coords = vec3(2564.62,2584.77,38.08), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [50] = { tipo = "caixaeletronico", coords = vec3(1077.71,-776.35,58.23), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [51] = { tipo = "caixaeletronico", coords = vec3(1735.34,6410.66,35.04), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [52] = { tipo = "caixaeletronico", coords = vec3(-3240.82,1008.61,12.84), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [53] = { tipo = "caixaeletronico", coords = vec3(-2975.28,380.17,15.0), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [54] = { tipo = "caixaeletronico", coords = vec3(-2956.87,487.64,15.47), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [55] = { tipo = "caixaeletronico", coords = vec3(-2958.95,487.78,15.47), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [56] = { tipo = "caixaeletronico", coords = vec3(-254.34,-692.32,33.61), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [57] = { tipo = "caixaeletronico", coords = vec3(-301.72,-830.24,32.42), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [58] = { tipo = "caixaeletronico", coords = vec3(-303.28,-829.9,32.42), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" },
  [59] = { tipo = "caixaeletronico", coords = vec3(315.26,-593.74,43.29), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" }, --Hp antigo
  [60] = { tipo = "caixaeletronico", coords = vec3(-197.54,-1341.88,34.91), text = "[~b~CAIXA ELETRONICO~w~]\n ~w~~r~[E]~w~ PARA ACESSAR\n ~w~~r~[F]~w~ PARA ROUBAR" }, --Bennys

  

}

Citizen.CreateThread(function()
    while true do
      local time = 1000
      local pedCoords = GetEntityCoords(PlayerPedId())
      if oppened == nil then
        for k,v in pairs(locations) do
            local distance = #(pedCoords - v.coords)
            if distance <= 2.5 then
                time = 5
                DrawText3D(v.coords[1], v.coords[2], v.coords[3]+0.2, v.text)
                if IsControlJustPressed(0,38) and distance <= 1.5 then
                  local banco,carteira,identidade,multas,checkout = vSERVER.openBank()

                  if checkout then
                    oppened = v.tipo
                    TransitionToBlurred(1000)
                    SetNuiFocus(true, true)
                    SendNUIMessage({ openBank = true, bank = banco, cart = carteira, identidade = identidade, multas = multas })
                  end

                end
            end
        end
      end

      Citizen.Wait(time)
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NUI CALLBACKS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('balance', function(data, cb)
  SendNUIMessage({openSection = "balance"})
end)

RegisterNUICallback('withdraw', function(data, cb)
  SendNUIMessage({openSection = "withdraw"})
end)

RegisterNUICallback('deposit', function(data, cb)
  SendNUIMessage({openSection = "deposit"})
end)

RegisterNUICallback('transfer', function(data, cb)
  SendNUIMessage({openSection = "transfer"})
end)


RegisterNUICallback('withdrawSubmit', function(data, cb)
  if oppened ~= nil and segundos <= 0 and NetworkIsSessionActive() then
    segundos = 5
    if vSERVER.sacarDinheiro(data.amount) then
      vSERVER.updateBank()
    end
  end
end)

RegisterNUICallback('depositSubmit', function(data, cb)
    if oppened ~= nil and oppened == "banco" and segundos <= 0 and NetworkIsSessionActive() then
      segundos = 5
      if vSERVER.depositarDinheiro(data.amount) then
        vSERVER.updateBank()
      end
    else
      TriggerEvent("Notify","negado","Você so pode efetuar depositos em um banco.", 5)
    end
end)

RegisterNUICallback('transferSubmit', function(data, cb)
  if oppened ~= nil and segundos <= 0 and NetworkIsSessionActive() then
    segundos = 5
    if vSERVER.transferirDinheiro(data.toPlayer, data.amount) then
      vSERVER.updateBank()
    end
  end
end)

RegisterNUICallback('multasSubmit', function(data, cb)
  if oppened ~= nil and segundos <= 0 and NetworkIsSessionActive() then
    segundos = 5
    if vSERVER.pagarMultas(data.amount) then
      vSERVER.updateBank()
    end
  end
end)

RegisterNUICallback('close', function(data, cb)
  TransitionFromBlurred(1000)
  SetNuiFocus(false)
  SendNUIMessage({openBank = false})
  oppened = nil
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------------------------------------------------------------------------------------------
function src.atualizarBanco(banco,carteira,multas)
  SendNUIMessage({ updateBalance = true, bank = banco, cart = carteira, multas = multas })
end

Citizen.CreateThread(function()
    while true do
      segundos = segundos - 1
      if segundos <= 0 then
        segundos = 0
      end
      Citizen.Wait(1000)
    end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- DRAW3DS
-----------------------------------------------------------------------------------------------------------------------------------------
function DrawText3D(x,y,z,text)
	local onScreen,_x,_y = World3dToScreen2d(x,y,z)
	SetTextFont(4)
	SetTextScale(0.35,0.35)
	SetTextColour(255,255,255,180)
	SetTextEntry("STRING")
	SetTextCentre(1)
	AddTextComponentString(text)
	DrawText(_x,_y)
end
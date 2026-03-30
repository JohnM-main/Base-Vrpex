local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPserver = Tunnel.getInterface("vRP","mirtin_orgs")
src = {}
Tunnel.bindInterface("mirtin_orgs",src)
vSERVER = Tunnel.getInterface("mirtin_orgs")
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local is_openned = false

src.openNui = function(org)
    if vSERVER.checkAuth() then
        if not is_openned then
            local infos,members,ranking = vSERVER.getInfosOrg(org)
            if infos and members then
                SetNuiFocus(true,true)
                SetCursorLocation(0.5,0.5)
                SendNUIMessage({ show = true, infos = infos, members = members, ranking = ranking })
                is_openned = true
            end
        end
    end
end

src.updateNui = function(org)
    if vSERVER.checkAuth() then
        local infos,members,ranking = vSERVER.getInfosOrg(org)
        if infos and members then
            SetNuiFocus(true,true)
            SetCursorLocation(0.5,0.5)
            SendNUIMessage({ show = true, update = true, infos = infos, members = members, ranking = ranking })
        end
    end
end

src.closeNui = function()
    if vSERVER.checkAuth() then
        SetNuiFocus(false,false)
        SendNUIMessage({ show = false })
        is_openned = false
    end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CALLBACKS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterNUICallback('closeNUI', function()
    src.closeNui()
end)

RegisterNUICallback('invite', function(data)
    if data.user_id > 0 then
        vSERVER.invitePlayer(data.user_id, data.orgName, data.cargo)
    end
end)

RegisterNUICallback('promove', function(data)
    if parseInt(data.user_id) > 0 then
        vSERVER.promovePlayer(data.user_id, data.orgName, data.cargo)
    end
end)

RegisterNUICallback('demitir', function(data)
    if data.user_id > 0 then
        vSERVER._demitirPlayer(data.user_id, data.orgName)
    end
end)

RegisterNUICallback('anotar', function(data)
    vSERVER._anotar(data.orgName, data.anotacao)
end)

RegisterNUICallback('pedircontas', function(data)
    vSERVER._pedirContas(data.orgName)
end)

RegisterNUICallback('sacar', function(data)
    vSERVER._sacar(data.orgName, data.value)
end)

RegisterNUICallback('depositar', function(data)
    vSERVER._depositar(data.orgName, data.value)
end)

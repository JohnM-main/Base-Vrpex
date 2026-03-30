------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local patrulhamento = {}
local acaoPtr = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE PATRULHAMENTO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.setPatrulhamento(user_id)
	patrulhamento[user_id] = true
end

function vRP.removePatrulhamento(user_id)
    patrulhamento[user_id] = nil
end

function vRP.checkPatrulhamento(user_id)
	return patrulhamento[user_id]
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TOOGLE
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('toogle', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, "perm.policia") or vRP.hasPermission(user_id, "perm.hospital") or vRP.hasPermission(user_id, "perm.mecanico") then
            if patrulhamento[user_id] then
                patrulhamento[user_id] = false
                TriggerClientEvent("Notify",source,"negado","Voce saiu de <b>serviço</b>.", 5)
                corpoWebHook = { { ["color"] = 6356736, ["title"] = "**".. "TOOGLE | Novo Registro" .."**\n", ["thumbnail"] = { ["url"] = "https://i.imgur.com/Ta9YOaY.png" }, ["description"] = "**ID:**\n```cs\n- ID: "..user_id.."  ```\n**STATUS:**\n```cs\n- SAIU DE SERVIÇO ```\n**Horario:**\n```cs\n"..os.date("[%d/%m/%Y as %H:%M]").." ```", ["footer"] = { ["text"] = "Mirt1n Store", }, } }
                
                if vRP.hasPermission(user_id, "perm.policia") then
                    vRPclient._giveWeapons(source, {}, true)
                    TriggerEvent("vrp_sysblips:ExitService",source)
                end
            else
                patrulhamento[user_id] = true
                TriggerClientEvent("Notify",source,"sucesso","Voce entrou em <b>serviço</b>.", 5)
                corpoWebHook = { { ["color"] = 6356736, ["title"] = "**".. "TOOGLE | Novo Registro" .."**\n", ["thumbnail"] = { ["url"] = "https://i.imgur.com/Ta9YOaY.png" }, ["description"] = "**ID:**\n```cs\n- ID: "..user_id.."  ```\n**STATUS:**\n```cs\n- ENTROU EM SERVIÇO ```\n**Horario:**\n```cs\n"..os.date("[%d/%m/%Y as %H:%M]").." ```", ["footer"] = { ["text"] = "Mirt1n Store", }, } }
            
                if vRP.hasPermission(user_id, "perm.policia") then
                    TriggerClientEvent("vrp_sysblips:ToggleService",source, "Policial" , 3,"Policia")
                end
            end

            vRP.sendLog("TOOGLE", corpoWebHook, "embeds")
        end
    end
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CHECAGENS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
    patrulhamento[user_id] = nil
    acaoPtr[user_id] = nil
end)
  
AddEventHandler("vRP:playerLeave",function(user_id,source)
    local data = vRP.getUserDataTable(user_id)
    if patrulhamento[user_id] then
        if data then
            data.weapons = {}
        end

        TriggerEvent("vrp_sysblips:ExitService",source)
    end

    acaoPtr[user_id] = nil
    patrulhamento[user_id] = nil
end)
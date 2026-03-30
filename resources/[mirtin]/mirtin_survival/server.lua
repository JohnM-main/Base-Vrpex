function src.receberMorte(source, motivo, ksource)
    if source == 0 or source == nil then
        return
    end
    
    local user_id = vRP.getUserId(source)
    if user_id then
        local discord_UserID = GetPlayerIdentifiers(source)
        local coords = vCLIENT.getPosition(source)

        local kuser_id = 0
        if ksource ~= 0 or ksource == nil then
            local id = vRP.getUserId(ksource)
            if id then
                kuser_id = id
            end
        end

        if user_id == nil or kuser_id == nil then
            return
        end

        if in_arena then
            return
        end

        corpoWebHook = { 
            { 
                ["color"] = cfg.color, 
                ["title"] = "**".. ":skull_crossbones:  | Novo Registro" .."**\n", 
                ["thumbnail"] = { ["url"] = cfg.logo },
                ["description"] = "**Vitima:**\n```cs\n- ID: "..user_id.."  ```\n**Causa da Morte:**\n```cs\n- "..motivo.." ```\n**Assasino:**\n```cs\n- "..kuser_id.." ```\n**Coordenadas:**\n```cs\n"..tD(coords[1])..","..tD(coords[2])..","..tD(coords[3]).." ```\n**Horario:**\n```cs\n"..os.date("[%d/%m/%Y as %H:%M]").." ```", 
                ["footer"] = { ["text"] = "Mirt1n Store", },
            } 
        }
    
        sendToDiscord(cfg.weebhook, corpoWebHook)

        vRP._generateLog({
            category = "morte",
            room = "mortes",
            user_id = kuser_id,
            target_id = user_id,
            message = ([[O USER_ID %s MATOU O USER_ID %s MOTIVO %s COORDENADAS %s ]]):format(kuser_id, user_id, motivo, vec3(tD(coords[1]),tD(coords[2]),tD(coords[3])))
        })
    end
end

-- finalized_ids = {}
-- RegisterCommand('finalizar', function(source, args)
--     local user_id = vRP.getUserId(source)
--     if (not user_id) then
--         return
--     end
--     if GetEntityHealth(GetPlayerPed(source)) <= 101 then
--         return
--     end
--     local nplayer = vRPclient.getNearestPlayer(source, 5)
--     if (not nplayer) then
--         return TriggerClientEvent("Notify",source,"negado","Nenhum jogador proximo.")
--     end
--     local nuser_id = vRP.getUserId(nplayer)
--     if not nuser_id then
--         return
--     end
--     local orgu = vRP.getUserGroupOrg(user_id)
--     local orgn = vRP.getUserGroupOrg(nuser_id)
--     if orgu == orgn then
--         return TriggerClientEvent("Notify",source,"negado","Você não pode finalizar um membro da sua organização!")
--     end

--     local health = GetEntityHealth(GetPlayerPed(nplayer))
--     if health > 101 then
--         return TriggerClientEvent("Notify",source,"negado","Este jogador não está morto.")
--     end
--     if finalized_ids[nuser_id] then
--         return TriggerClientEvent("Notify",source,"negado","Este jogador já está finalizado.")
--     end
--     TriggerClientEvent("Notify",source,"sucesso","Você finalizou esse jogador.")
--     finalized_ids[nuser_id] = true
--     vCLIENT.setFinalizado(nplayer)
--     vRP._generateLog({
--         room = "finalizar",
--         user_id = user_id,
--         target_id = nuser_id,
--         message = ([[O USER_ID %s FINALIZOU O  USER_ID %s ]]):format(user_id, nuser_id)
--     })
--     Wait(1000)
--     finalized_ids[nuser_id] = nil
-- end)

finalized_ids = {}
RegisterCommand('finalizar', function(source, args)
    local user_id = vRP.getUserId(source)
    if (not user_id) then
        return
    end
    if GetEntityHealth(GetPlayerPed(source)) <= 101 then
        return
    end
    local nplayer = vRPclient.getNearestPlayer(source, 5)
    if (not nplayer) then
        return TriggerClientEvent("Notify",source,"negado","Nenhum jogador proximo.")
    end
    local nuser_id = vRP.getUserId(nplayer)
    if not nuser_id then
        return
    end
    local orgu = vRP.getUserGroupOrg(user_id)
    local orgn = vRP.getUserGroupOrg(nuser_id)

    -- if #(GetEntityCoords(GetPlayerPed(source)) - vec3(-312.27,-2780.8,5.0)) <= 120 or #(GetEntityCoords(GetPlayerPed(source)) - vec3(129.87,-3108.59,5.9)) <= 120 or #(GetEntityCoords(GetPlayerPed(source)) - vec3(575.52,-3111.11,6.07)) <= 120 or #(GetEntityCoords(GetPlayerPed(source)) - vec3(1011.17,-2895.78,39.16)) <= 120 or #(GetEntityCoords(GetPlayerPed(source)) - vec3(-235.64,-2002.62,24.68)) <= 120 or #(GetEntityCoords(GetPlayerPed(source)) - vec3(2341.79,2591.04,46.66)) <= 120 then
    --     if orgu == orgn then
    --         return TriggerClientEvent("Notify",source,"negado","Você não pode finalizar um membro da sua organização nesta área!")
    --     end
    -- else
        local health = GetEntityHealth(GetPlayerPed(nplayer))
        if health > 101 then
            return TriggerClientEvent("Notify",source,"negado","Este jogador não está morto.")
        end
        if finalized_ids[nuser_id] then
            return TriggerClientEvent("Notify",source,"negado","Este jogador já está finalizado.")
        end
        TriggerClientEvent("Notify",source,"sucesso","Você finalizou esse jogador.")
        finalized_ids[nuser_id] = true
        vCLIENT.setFinalizado(nplayer)
        Wait(1000)
        finalized_ids[nuser_id] = nil
    -- end
end)


function sendToDiscord(weebhook, message)
    SetTimeout(5000, function()
        local weebhook,message = weebhook,message
        PerformHttpRequest(weebhook, function(err, text, headers) end, 'POST', json.encode({embeds = message}), { ['Content-Type'] = 'application/json' })
    end)
end

function tD(n)
    n = math.ceil(n * 100) / 100
    return n
end


function src.secoundsDeath()
    local source = source
    local user_id = vRP.getUserId(source)
    if not user_id then return end
    if vRP.hasGroup(user_id,'VipPolicia') then 
        return 200
    elseif vRP.hasPermission(user_id, 'perm.ada') or vRP.hasPermission(user_id, 'perm.grecia') or vRP.hasPermission(user_id, 'perm.grota') or vRP.hasPermission(user_id, 'perm.complexodoalemao') or vRP.hasPermission(user_id, 'perm.deathtime') or vRP.hasPermission(user_id,'perm.cdd') or vRP.hasPermission(user_id,'perm.playboy') then
        return 300
    end

    return false
end
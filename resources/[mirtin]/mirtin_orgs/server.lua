local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("mirtin_orgs",src)
Proxy.addInterface("mirtin_orgs",src)

vCLIENT = Tunnel.getInterface("mirtin_orgs")

local autenticado = true
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("getTop10", "SELECT org,banco FROM mirtin_orgs ORDER BY banco DESC LIMIT 10")
src.getInfosOrg = function(org)
    if src.checkAuth() then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            if config.groups[org] then
                local rows = vRP.query("mirtin_orgs/getOrg", { org = org })
                if #rows > 0 then
                    local members = json.decode(rows[1].membros)
                    if rows[1] then
                        local anotacao = rows[1].anotacao
                        local orgName = rows[1].org
                        local orgMaxMembers = rows[1].maxMembros
                        local banco = rows[1].banco
                        local bancoHistorico = json.decode(rows[1].bancoHistorico) or {}
                        local orgTotalMembers = 0
                        local totalOnline = 0
                        local orgMembers = {}
                        local ranking = vRP.query("getTop10", {})
                        
                        for k,v in pairs(members) do
                            local nsource = vRP.getUserSource(parseInt(k))

                            if nsource then
                                v.status = 1
                                totalOnline = totalOnline + 1
                            else
                                v.status = 2 
                            end

                            if config.groups[org].groups[parseInt(v.nivel)] then
                                v.cargo = config.groups[org].groups[parseInt(v.nivel)].prefix
                            else
                                v.cargo = "Indefinido"
                            end

                            if v.last_login ~= nil then
                                v.last_login = os.date("%d/%m/%Y as %H:%M", v.last_login)
                            else
                                v.last_login = "Indefinido"
                            end
                            
                            orgTotalMembers = orgTotalMembers + 1
                            orgMembers[k] = v
                        end

                        

                        return { orgName,orgTotalMembers,orgMaxMembers,anotacao, totalOnline, config.groups[org].groups, "$ "..vRP.format(banco), bancoHistorico}, orgMembers, ranking
                    end
                else
                    print("^1[mirtin_orgs] (ERROR) Organização ("..org..") não encontrada no banco de dados. (1a)^0")
                    return
                end
            else
                config.langs['notMember'](source)
            end
        end
    end
end

src.invitePlayer = function(playerID, orgName, cargo)
    if src.checkAuth() then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            if not src.checkLiderPermission(user_id, orgName) then
                config.langs['notPermission'](source)
                return
            end

            if parseInt(playerID) == parseInt(user_id) and not vRP.hasPermission(user_id, config.adminPermission) then
                config.langs['notThis'](source)
                return
            end

            if src.getMyOrg(playerID) then
                config.langs['haveGroup'](source)
                return
            end

            local isBlackList,tempoBlackList = src.checkBlackList(playerID)
            if isBlackList and not vRP.hasPermission(user_id, config.adminPermission) then
                config.langs['haveBlackList'](source, os.date("%d/%m/%Y", tempoBlackList))
                return
            end

            if config.groups[orgName] and config.groups[orgName].groups ~= nil then
                local rows = vRP.query("mirtin_orgs/getOrg", { org = orgName })
                if #rows > 0 then
                    local members = json.decode(rows[1].membros)
                    local name,lastname = src.identity(tostring(playerID))

                    local totalMembers = 0
                    for k,v in pairs(members) do
                        if parseInt(v.nivel) == parseInt(cargo) then
                            totalMembers = totalMembers + 1
                        end
                    end

                    if config.groups[orgName].groups[parseInt(cargo)].maxMembers ~= nil then
                        if totalMembers >= config.groups[orgName].groups[parseInt(cargo)].maxMembers then
                            config.langs['fullLoads'](source, config.groups[orgName].groups[parseInt(cargo)].maxMembers)
                            return
                        end
                    end

                    local nsource = vRP.getUserSource(playerID) 
                    if nsource then
                        config.langs['invitePlayer'](source, playerID)
                        local request = config.langs['requestInvite'](nsource, orgName)
                        if request then
                            corpoHook = { 
                                { 
                                    ["color"] = config.weebhook['color'], 
                                    ["title"] = "**".. ":globe_with_meridians: | Sistema de Controle de Membros " .."**\n", 
                                    ["thumbnail"] = { ["url"] = config.weebhook['logo'] },
                                    ["description"] = "**Organização:** `` "..orgName.." ``\n**Ação:** `` CONTRATAR ``\n\n**Quem contratou:** ```css\n- "..user_id.." ```\n**Foi contratado:** ```css\n- "..playerID.." ```\n**Cargo:** ```css\n- ".. config.groups[orgName].groups[1].prefix .." ```\n**Data da Contratação:** ```css\n- ".. os.date("%d/%m/%Y") .." ```", 
                                    ["footer"] = { ["text"] = config.weebhook['footer'], }, } 
                            }
                            sendToDiscord(config.groups[orgName].weebhook, corpoHook)


                            config.langs['acceptInvite'](source)
                            config.langs['acceptNInvite'](nsource, orgName)

                            vRP.addUserGroup(parseInt(playerID), config.groups[orgName].groups[parseInt(cargo)].grupo)

                            members[tostring(playerID)] = { nome = name.." "..lastname , nivel = cargo, last_login = os.time() }
                            vRP.execute("mirtin_orgs/updateMembers", { org = orgName, membros = json.encode(members) })

                            vCLIENT.updateNui(source, orgName)
                        end
                    else
                        config.langs['jogadorOffline'](source)
                    end
                else
                    print("^1[mirtin_orgs] (ERROR) Organização ("..orgName..") não encontrada no banco de dados. (2a)^0")
                    return
                end
            end
        end
    end
end

src.promovePlayer = function(playerID, orgName, cargo)
    playerID = parseInt(playerID)
    if src.checkAuth() then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            if not src.checkLiderPermission(user_id, orgName) then
                config.langs['notPermission'](source)
                return
            end

            if parseInt(playerID) == parseInt(user_id) and not vRP.hasPermission(user_id, config.adminPermission) then
                config.langs['notThis'](source)
                return
            end

            if config.groups[orgName] then
                if config.groups[orgName] and config.groups[orgName].groups ~= nil then
                    local rows = vRP.query("mirtin_orgs/getOrg", { org = orgName })
                    if #rows > 0 then
                        local members = json.decode(rows[1].membros)
                        if members[tostring(playerID)] then

                            local newLevel = tonumber(cargo)

                            local totalMembers = 0
                            for k,v in pairs(members) do
                                if parseInt(v.nivel) == parseInt(cargo) then
                                    totalMembers = totalMembers + 1
                                end
                            end

                            if config.groups[orgName].groups[parseInt(newLevel)].maxMembers ~= nil then
                                if totalMembers >= config.groups[orgName].groups[parseInt(newLevel)].maxMembers then
                                    config.langs['fullLoads'](source, config.groups[orgName].groups[parseInt(newLevel)].maxMembers)
                                    return
                                end
                            end

                            local nsource = vRP.getUserSource(playerID)
                            if nsource then
                                config.langs['youPromoted'](nsource, config.groups[orgName].groups[parseInt(newLevel)].prefix)
                                vRP.addUserGroup(parseInt(playerID), config.groups[orgName].groups[parseInt(newLevel)].grupo)
                            end

                            corpoHook = { 
                                { 
                                    ["color"] = config.weebhook['color'], 
                                    ["title"] = "**".. ":globe_with_meridians: | Sistema de Controle de Membros " .."**\n", 
                                    ["thumbnail"] = { ["url"] = config.weebhook['logo'] },
                                    ["description"] = "**Organização:** `` "..orgName.." ``\n**Ação:** `` PROMOÇÃO ``\n\n**Quem Promoveu:** ```css\n- "..user_id.." ```\n**Foi Promovido:** ```css\n- "..playerID.." ```\n**Cargo Antigo:** ```css\n- ".. config.groups[orgName].groups[parseInt(newLevel)].prefix .." ```\n**Cargo Novo:** ```css\n- ".. config.groups[orgName].groups[parseInt(newLevel)].prefix .." ```\n**Data da Promoção:** ```css\n- ".. os.date("%d/%m/%Y") .." ```", 
                                    ["footer"] = { ["text"] = config.weebhook['footer'], }, } 
                            }
                            sendToDiscord(config.groups[orgName].weebhook, corpoHook)

                            config.langs['promoted'](source, playerID, config.groups[orgName].groups[parseInt(newLevel)].prefix)
                            members[tostring(playerID)] = { nome = members[tostring(playerID)].nome, nivel = newLevel, last_login = os.time() }
                            vRP.execute("mirtin_orgs/updateMembers", { org = orgName, membros = json.encode(members) })
                            vCLIENT.updateNui(source, orgName)
                        end
                    end
                end
            end

        end
    end
end

src.demitirPlayer = function(playerID, orgName)
    if src.checkAuth() then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            if not src.checkLiderPermission(user_id, orgName) then
                config.langs['notPermission'](source)
                return
            end

            if parseInt(playerID) == parseInt(user_id) and not vRP.hasPermission(user_id, config.adminPermission) then
                config.langs['notThis'](source)
                return
            end

            if config.groups[orgName] then
                if config.groups[orgName] and config.groups[orgName].groups ~= nil then
                    local rows = vRP.query("mirtin_orgs/getOrg", { org = orgName })
                    if #rows > 0 then
                        local members = json.decode(rows[1].membros)
                        if members[tostring(playerID)] then
                            local group = config.groups[orgName].groups[parseInt(members[tostring(playerID)].nivel)].grupo

                            local nsource = vRP.getUserSource(playerID)
                            if nsource then
                                vRP.removeUserGroup(parseInt(playerID), group)
                                config.langs['demitirN'](nsource, orgName)
                            end

                            corpoHook = { 
                                { 
                                    ["color"] = config.weebhook['color'], 
                                    ["title"] = "**".. ":globe_with_meridians: | Sistema de Controle de Membros " .."**\n", 
                                    ["thumbnail"] = { ["url"] = config.weebhook['logo'] },
                                    ["description"] = "**Organização:** `` "..orgName.." ``\n**Ação:** `` DEMISSÃO ``\n\n**Quem demitiu:** ```css\n- "..user_id.." ```\n**Foi demitido:** ```css\n- "..playerID.." ```\n**Cargo Antigo:** ```css\n- ".. config.groups[orgName].groups[parseInt(members[tostring(playerID)].nivel)].prefix .." ```\n**Data da Demissão:** ```css\n- ".. os.date("%d/%m/%Y") .." ```", 
                                    ["footer"] = { ["text"] = config.weebhook['footer'], }, } 
                            }
                            sendToDiscord(config.groups[orgName].weebhook, corpoHook)

                            config.langs['demitir'](source, playerID)
                            src.addBlackList(playerID)

                            members[tostring(playerID)] = nil
                            vRP.execute("mirtin_orgs/updateMembers", { org = orgName, membros = json.encode(members) })

                            vCLIENT.updateNui(source, orgName)
                        end
                    end
                end
            end
        end
    end
end

src.anotar = function(orgName, anotacao)
    if src.checkAuth() then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            if not src.checkLiderPermission(user_id, orgName) then
                config.langs['notPermission'](source)
                return
            end

            if config.groups[orgName] then
                corpoHook = { 
                    { 
                        ["color"] = config.weebhook['color'], 
                        ["title"] = "**".. ":globe_with_meridians: | Sistema de Controle de Membros " .."**\n", 
                        ["thumbnail"] = { ["url"] = config.weebhook['logo'] },
                        ["description"] = "**Organização:** `` "..orgName.." ``\n**Ação:** `` ANOTAÇÃO ``\n\n**Quem atualizou:** ```css\n- "..user_id.." ```\n**MENSAGEM:** ```css\n- "..anotacao.." ```\n**Data da Anotação:** ```css\n- ".. os.date("%d/%m/%Y") .." ```", 
                        ["footer"] = { ["text"] = config.weebhook['footer'], }, } 
                }
                sendToDiscord(config.groups[orgName].weebhook, corpoHook)

                config.langs['attInfo'](source)
                vRP.execute("mirtin_orgs/updateText", { org = orgName, anotacao = anotacao })
                vCLIENT.updateNui(source, orgName)
            end

        end
    end
end

src.pedirContas = function(orgName)
    if src.checkAuth() then
        local source = source
        local user_id = vRP.getUserId(source)
        if user_id then
            local rows = vRP.query("mirtin_orgs/getOrg", { org = orgName })
            if #rows > 0 then
                local members = json.decode(rows[1].membros)

                local grupos = config.groups[orgName].groups
                for k,v in pairs(grupos) do
                    if vRP.hasGroup(user_id, v.grupo) then
                        vRP.removeUserGroup(user_id, v.grupo)
                    end
                end

                corpoHook = { 
                    { 
                        ["color"] = config.weebhook['color'], 
                        ["title"] = "**".. ":globe_with_meridians: | Sistema de Controle de Membros " .."**\n", 
                        ["thumbnail"] = { ["url"] = config.weebhook['logo'] },
                        ["description"] = "**Organização:** `` "..orgName.." ``\n**Ação:** `` PEDIR DEMISSÃO ``\n\n**Quem pediu:** ```css\n- "..user_id.." ```\n**Data da Demissão:** ```css\n- ".. os.date("%d/%m/%Y") .." ```", 
                        ["footer"] = { ["text"] = config.weebhook['footer'], }, } 
                }
                sendToDiscord(config.groups[orgName].weebhook, corpoHook)
                
                config.langs['pedirContas'](source, orgName)
                src.addBlackList(user_id)

                members[tostring(user_id)] = nil
                vRP.execute("mirtin_orgs/updateMembers", { org = orgName, membros = json.encode(members) })

                vCLIENT.closeNui(source)
            end
        end
    end
end

src.getMyOrg = function(user_id)
    if src.checkAuth() then
        local groups = vRP.getUserGroups(user_id)
        for k,v in pairs(groups) do
            local kgroup = allGroups.groups[tostring(k)]
            
            if kgroup then
                if kgroup._config ~= nil and kgroup._config.orgName ~= nil then
                    return kgroup._config.orgName,k
                end
            end
        end

        return false
    end
end

src.checkLiderPermission = function(user_id, orgName) 
    if src.checkAuth() then
        local grupos = config.groups[orgName].groups
        for k,v in pairs(grupos) do
            if v.permLider then
                if vRP.hasGroup(user_id, v.grupo) or vRP.hasPermission(user_id, config.adminPermission) then
                    return true
                end
            end
        end
        return false
    end
end

src.checkBancoPermission = function(user_id, orgName) 
    if src.checkAuth() then
        local grupos = config.groups[orgName].groups
        for k,v in pairs(grupos) do
            if v.permBanco then
                if vRP.hasGroup(user_id, v.grupo) --[[ or vRP.hasPermission(user_id, config.adminPermission) ]] then
                    return true
                end
            end
        end
        return false
    end
end

src.addBlackList = function(id)
    local source = vRP.getUserSource(id)
    if source then
        local blackListed = os.time()+config.blackList*24*60*60
        config.langs['isBlackList'](source, os.date("%d/%m/%Y", blackListed))

        vRP.setUData(id, "Mirt1n:BlackList", blackListed)
    end
end

src.checkBlackList = function(id)
    local source = vRP.getUserSource(id)
    if source then
        local blacklisted = parseInt(vRP.getUData(id, "Mirt1n:BlackList")) or 0
        if blacklisted > 0 then
            if os.time() > blacklisted then
                vRP.setUData(id, "Mirt1n:BlackList", 0)
                return false
            end

            return true,blacklisted
        end

        return false
    end
end

src.sacar = function(orgName, value)
    value = parseInt(value)
    if value < 0 then
        value = 1
    end
    
    if src.checkAuth() then
        local source = source
        local user_id = vRP.getUserId(source)
        local identity = vRP.getUserIdentity(user_id)
        if user_id then
            if GetPlayerPing(source) <= 0 then
                return
            end

            if not src.checkBancoPermission(user_id, orgName) then
                config.langs['notPermission'](source)
                return
            end

            local rows = vRP.query("mirtin_orgs/getOrg", { org = orgName })
            if #rows > 0 then
                local bancoAmount = rows[1].banco
                local history = rows[1].bancoHistorico
                local historyValue = json.decode(history)

                if bancoAmount < value then
                    config.langs['notWithdraw'](source)
                    return
                end

                bancoAmount = bancoAmount - value

                if bancoAmount <= 0 then
                    bancoAmount = 0
                end

                vRP.giveMoney(user_id, value)

                historyValue[os.time()] = { tipo = "saque", valor = format(value), nome = "["..user_id.."] ".. identity.nome.. " "..identity.sobrenome }
                
                config.langs['withdraw'](source, value)

                vRP._execute("mirtin_orgs/updateBanco", { org = orgName, banco = bancoAmount, bancoHistorico = json.encode(historyValue) } )
                vCLIENT._updateNui(source, orgName)

                corpoHook = { 
                    { 
                        ["color"] = config.weebhook['color'], 
                        ["title"] = "**".. ":globe_with_meridians: | Sistema de banco " .."**\n", 
                        ["thumbnail"] = { ["url"] = config.weebhook['logo'] },
                        ["description"] = "**Organização:** `` "..orgName.." ``\n**Ação:** `` SAQUE ``\n\n**Quem sacou:** ```css\n- "..user_id.." ```\n**Valor Sacado:** ```css\n- "..value.." ```\n**Valor Antes:** ```css\n- ".. bancoAmount + value .." ```\n**Data da Transação:** ```css\n- ".. os.date("%d/%m/%Y") .." ```", 
                        ["footer"] = { ["text"] = config.weebhook['footer'], }, } 
                }
                sendToDiscord("https://discord.com/api/webhooks/1016233137208033290/_ynP3IctFipuByX0TJP3fPRvGZ9khqD_8j1NCVXM-y_FZ0NkIKFmLuSXWr9qsK_3CW8i", corpoHook)
            end
        end
    end
end

src.depositar = function(orgName, value)
    value = parseInt(value)

    if src.checkAuth() then
        local source = source
        local user_id = vRP.getUserId(source)
        local identity = vRP.getUserIdentity(user_id)
        if user_id then
            if GetPlayerPing(source) <= 0 then
                return
            end

            if not src.checkBancoPermission(user_id, orgName) then
                config.langs['notPermission'](source)
                return
            end

            local rows = vRP.query("mirtin_orgs/getOrg", { org = orgName })
            if #rows > 0 then
                if vRP.tryPayment(user_id, parseInt(value)) then
                    local bancoAmount = rows[1].banco
                    local history = rows[1].bancoHistorico
                    local historyValue = json.decode(history) or {}

                    if bancoAmount <= 0 then
                        bancoAmount = 0
                    end

                    bancoAmount = bancoAmount + value

                    historyValue[os.time()] = { tipo = "deposito", valor = format(value), nome = "["..user_id.."] ".. identity.nome.. " "..identity.sobrenome }
                    
                    config.langs['deposit'](source, value)

                    vRP._execute("mirtin_orgs/updateBanco", { org = orgName, banco = bancoAmount, bancoHistorico = json.encode(historyValue) } )
                    vCLIENT._updateNui(source, orgName)

                    corpoHook = { 
                        { 
                            ["color"] = config.weebhook['color'], 
                            ["title"] = "**".. ":globe_with_meridians: | Sistema de banco " .."**\n", 
                            ["thumbnail"] = { ["url"] = config.weebhook['logo'] },
                            ["description"] = "**Organização:** `` "..orgName.." ``\n**Ação:** `` DEPOSITO ``\n\n**Quem depositou:** ```css\n- "..user_id.." ```\n**Valor Depositado:** ```css\n- "..value.." ```\n**Valor Antes:** ```css\n- ".. bancoAmount - value .."\n```**Valor Depois:** ```css\n- ".. bancoAmount .." ```\n**Data da Transação:** ```css\n- ".. os.date("%d/%m/%Y") .." ```", 
                            ["footer"] = { ["text"] = config.weebhook['footer'], }, } 
                    }
                    sendToDiscord("https://discord.com/api/webhooks/1016233253683863613/u6x0L3gLzPio9B3WKEDR1PqGW9o-V-OA4KDWVS_uEfxrW8tDQKpmhyVGOtPq5FxLXNg_", corpoHook)
                else
                    config.langs['notMoney'](source, value)
                end
            end
        end
    end
end

function format(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1 '):reverse())..right
end

src.checkAuth = function()
    return autenticado
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VALIDAÇÃO DA CHECAGENS DOS GRUPOS
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
    if src.checkAuth() then
        if user_id then
            local myOrg,myGroup = src.getMyOrg(user_id)
            if myOrg then
                local rows = vRP.query("mirtin_orgs/getOrg", { org = myOrg })
                if #rows > 0 then
                    local members = json.decode(rows[1].membros)
                    
                    if members[tostring(user_id)] == nil then
                        config.langs['notThisMember'](source, myOrg)
                        vRP.removeUserGroup(parseInt(user_id), myGroup)
                        return
                    end
					
                    local nivel = members[tostring(user_id)].nivel
                    vRP.addUserGroup(user_id, config.groups[myOrg].groups[parseInt(nivel)].grupo)

                    members[tostring(user_id)]['last_login'] = os.time()
                    vRP.execute("mirtin_orgs/updateMembers", { org = myOrg, membros = json.encode(members) })
                else
                    print("^1[mirtin_orgs] (ERROR) Organização ("..myOrg..") não encontrada no banco de dados. (1b)^0")
                    return
                end
            end
        end
    end
end)

function sendToDiscord(weebhook, message)
    PerformHttpRequest(weebhook, function(err, text, headers) end, 'POST', json.encode({embeds = message}), { ['Content-Type'] = 'application/json' })
end




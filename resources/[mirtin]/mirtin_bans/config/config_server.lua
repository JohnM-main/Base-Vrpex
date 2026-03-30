-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MAIN
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config = {} -- Não mexer

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config.timeUnbans = 5 -- (minutos) Configura o tempo para o refresh de desbanimentos automaticos
config.createTable = true -- Depois de ligar o script pela 1x coloque false
config.permissionBan = "admin.permissao" -- Permissao para o comando /ban & /unban
config.timeConnect = 3000 -- Caso não estja aparecendo a mensagem de banimento ou trave na tela checando banimento aumente esse valor

config.geral = {
    logo = "https://i.imgur.com/Ta9YOaY.png", -- LOGO do Servidor
    background = "https://cdn.discordapp.com/attachments/403296672748142595/875522538510368858/download_1.jpg", -- Fundo da Tela de banimento
    discord = "https://discord.gg/eQjSdTQYM8", -- Discord do Servidor (Colocar https://)

    color = 6356736, -- Cor da Lateral do WeebHook
    footer = "© Mirtin Base", -- RODAPE do WeebHook

    whookBan = "https://discord.com/api/webhooks/937578904435187713/i5tFfvzQtML7ljqEOurpu7BICdCrcQUFcvv7iqX2kp4T5KOvwWSNU9v1DUXTrCYnLt7E", -- WEEBHOOK para quando o jogador for banido
    whookUnban = "https://discord.com/api/webhooks/937579013101203496/U6pzGndKBEn6wGcq1CMyhIqVBQIqJk8yoMQu7y_JXtFUo5ycFVoKsDfmjrt0aIl5JSSI", -- WEEBHOOK para quando o jogador for desbanido
    whookUnbanTime = "https://discord.com/api/webhooks/937579090922332270/8KzWdlp1kf00oxxxpE3CtM0zDWbGKdF_4wqdRkUIbZ0IjLbd0U_zjffE5JB8O_31Huzr", -- WEEBHOOK para quando o jogador for desbanido automaticamente ( BAN TEMPORARIO )
    whookHWIDlogin = "https://discord.com/api/webhooks/940244724999147531/bj-wEXsD1DnvzziQtoj5rGYAy7Ba365QkNOOneatf3Uk0sjs2SZgG_Ybaallnl2jUmlw", -- WEEBHOOK para quando o estiver banido HWID e logar com outra conta.
}

config.serverLang = {
    isBanned = function(source) 
        return TriggerClientEvent("Notify", source, "negado", "Este jogador ja está banido.", 5)
    end,

    isNotBanned = function(source) 
        return TriggerClientEvent("Notify", source, "negado", "Este jogador não está banido.", 5)
    end,

    banned = function(source, id, motivo, tempo) 
        return TriggerClientEvent("Notify", source, "importante", "Você baniu o <b>ID: "..id.."</b> pelo motivo: <b> "..motivo.."</b>", 5)
    end,

    unbanned = function(source, id) 
        return TriggerClientEvent("Notify", source, "importante", "Você desbaniu o <b>ID: "..id.."</b>.", 5)
    end,

    kickBan = function(nsource, motivo, dataBan, dataUnban) 
        vRP.kick(nsource, "\nVocê foi banido do servidor.\nMotivo: "..motivo.."\nData do Banimento: "..dataBan.."\nData do Desbanimento: "..dataUnban.." ")
    end,
}

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- COMANDOS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('ban', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, config.permissionBan) then
            local idBan = tonumber(args[1])
            if idBan == nil then
                TriggerClientEvent("Notify",source,"negado","Este ID não foi encotrado.", 5)
                return
            end

            local motivoBan = ""
            local tempoBan = 0
            for i=2,#args do
            local allargs = args[i]
                if allargs:match('%d+[mhdMHD]') then
                    tempoBan = allargs
                    break
                else
                    motivoBan = motivoBan..' '..allargs
                end
            end

            if motivoBan == "" then
                motivoBan = "Sem Motivo"
            end

            src.setBanned(source, idBan, motivoBan, convertTime(tempoBan), 0)
        end
    end
end)

RegisterCommand('bansrc', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, config.permissionBan) then
            local idSource = tonumber(args[1])

            local ids = GetPlayerIdentifiers(idSource)
            if #ids > 0 then

                local idBan
                for k,v in pairs(ids) do
                    local rows = vRP.query("getUserId", { identifier = v })
                    if #rows > 0 then
                        idBan = rows[1].user_id
                        break;
                    end
                end
               
                if idBan then
                    local motivoBan = ""
                    local tempoBan = 0
                    for i=2,#args do
                    local allargs = args[i]
                        if allargs:match('%d+[mhdMHD]') then
                            tempoBan = allargs
                            break
                        else
                            motivoBan = motivoBan..' '..allargs
                        end
                    end
        
                    if motivoBan == "" then
                        motivoBan = "Sem Motivo"
                    end
                   
                    src.setBanned(source, idBan, motivoBan, convertTime(tempoBan), 0)
                else
                    TriggerClientEvent("Notify",source,"negado","Não conseguimos capturar um id com esse source.", 5000)
                end
            else
                TriggerClientEvent("Notify",source,"negado","Este source não foi encontrado.", 5000)
            end
        end
    end
end)

RegisterCommand('hban', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, config.permissionBan) then
            local idBan = tonumber(args[1])
            if idBan == nil then
                TriggerClientEvent("Notify",source,"negado","Este ID não foi encotrado.", 5)
                return
            end

            local motivoBan = ""
            local tempoBan = 0
            for i=2,#args do
            local allargs = args[i]
                if allargs:match('%d+[mhdMHD]') then
                    tempoBan = allargs
                    break
                else
                    motivoBan = motivoBan..' '..allargs
                end
            end

            if motivoBan == "" then
                motivoBan = "Sem Motivo"
            end

            src.setBanned(source, idBan, motivoBan, convertTime(tempoBan), 1)
        end
    end
end)

RegisterCommand('unban', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, config.permissionBan) then
            local idBan = tonumber(args[1])
            if idBan == nil then
                TriggerClientEvent("Notify",source,"negado","Este ID não foi encotrado.", 5)
                return
            end

            local motivoUnBan = ""
            for i=2, #args do
                motivoUnBan = motivoUnBan.. " " ..args[i]
            end

            if motivoUnBan == "" then
                motivoUnBan = "Sem Motivo"
            end

            src.setUnBanned(source, idBan, motivoUnBan)
        end
    end
end)

RegisterCommand('check', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, config.permissionBan) then
            local idBan = tonumber(args[1])
            if idBan == nil then
                TriggerClientEvent('chatMessage', source, "^9Digite o ID corretamente. ")
                return
            end

            src.getHcheck(source, idBan)
        end
    end
end)

RegisterCommand('kick', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, config.permissionBan) or vRP.hasPermission(user_id,"moderador.permissao") or vRP.hasPermission(user_id,"suporte.permissao") then
            local idKick = tonumber(args[1])
            if idKick == nil then
                TriggerClientEvent("Notify",source,"negado","Este ID não foi encotrado.", 5)
                return
            end

            local nsource = vRP.getUserSource(idKick)
            if nsource == nil then
                TriggerClientEvent("Notify",source,"negado","Este jogador não está online.", 5)
                return
            end

            local motivoKick = ""
            for i=2, #args do
                motivoKick = motivoKick.. " " ..args[i]
            end

            if motivoKick == "" then
                motivoKick = "Sem Motivo"
            end

            vRP.kick(nsource,"Você foi kickado da cidade: ("..motivoKick.." ) ")

            corpoWebHook = { { ["color"] = 6356736, ["title"] = "**".. "KICK | Novo Registro" .."**\n", ["thumbnail"] = { ["url"] = "https://i.imgur.com/Ta9YOaY.png" }, ["description"] = "**ADMIN:**\n```cs\n- ID: "..user_id.."  ```\n**ID:**\n```cs\n- ID: "..idKick.."  ```\n**MOTIVO:**\n```cs\n- "..motivoKick.."  ```\n**Horario:**\n```cs\n"..os.date("[%d/%m/%Y as %H:%M]").." ```", ["footer"] = { ["text"] = "Mirt1n Store", }, } }
            vRP.sendLog("KICK", corpoWebHook, "embeds")
        end
    end
end)

RegisterCommand('idsrc', function(source,args)
    local user_id = vRP.getUserId(source)

    if vRP.hasPermission(user_id, config.permissionBan) then
        local ids = GetPlayerIdentifiers(args[1])

        local idBan
        for k,v in pairs(ids) do
            local rows = vRP.query("getUserId", { identifier = v })
            if #rows > 0 then
                idBan = rows[1].user_id
                break;
            end
        end

        if idBan ~= nil then
            TriggerClientEvent("Notify", source, "negado", "Source ID: "..idBan.." .", 5)
        end
    end

end)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUERYS
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vRP._prepare("mirtin/getAllBans","SELECT * FROM mirtin_bans")
vRP._prepare("mirtin/getUserBanned","SELECT * FROM mirtin_bans WHERE user_id = @user_id")
vRP._prepare("mirtin/insertBanned","INSERT INTO mirtin_bans(user_id,motivo,desbanimento,banimento,time, hwid) VALUES(@user_id,@motivo,@desbanimento,@banimento,@time, @hwid)")
vRP._prepare("mirtin/addToken","INSERT IGNORE INTO mirtin_bans_hwid(id,token) VALUES(@user_id,@token)")
vRP._prepare("mirtin/select_hwid", "SELECT * FROM mirtin_bans_hwid mhb LEFT JOIN mirtin_bans mh ON (mh.user_id = mhb.id) WHERE mhb.token = @token AND hwid = '1'")
vRP._prepare("mirtin/removeBanned", "DELETE FROM mirtin_bans WHERE user_id = @user_id")
vRP._prepare("mirtin/createBanDB",[[ CREATE TABLE IF NOT EXISTS `mirtin_bans` ( `user_id` int(11) NOT NULL, `motivo` text NOT NULL, `banimento` tinytext NOT NULL, `desbanimento` tinytext NOT NULL, `time` int(11) NOT NULL, `hwid` int(11) NOT NULL, PRIMARY KEY (`user_id`) USING BTREE ) ENGINE=InnoDB DEFAULT CHARSET=latin1; ]])
vRP._prepare("mirtin/createBanDBHWID",[[ CREATE TABLE IF NOT EXISTS `mirtin_bans_hwid` ( `token` varchar(120) NOT NULL, `id` int(11) NOT NULL, PRIMARY KEY (`token`), KEY `id` (`id`) ) ENGINE=InnoDB DEFAULT CHARSET=latin1; ]])
vRP._prepare("getUserId", "SELECT user_id FROM vrp_user_ids WHERE identifier = @identifier")

async(function()
    if config.createTable then
        vRP._execute("mirtin/createBanDB", {})
        vRP._execute("mirtin/createBanDBHWID", {})
    end
end)
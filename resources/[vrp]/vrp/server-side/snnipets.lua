local pressetHooks = {
    ["ENTRADA"] = { "" },
    ["SAIDA"] = { "" },
    ["DROPAR"] = { "" },
    ["ENVIAR"] = { "" },
    ["EQUIPAR"] = { "" },
    ["GARMAS"] = { "" },
    ["SAQUEAR"] = { "" },
    ["BAUCARRO"] = { "" },
    ["BAUCASAS"] = { "" },
    ["CRASHS"] = { "" },
    ["MORTE"] = { "" },
    ["ROUBOGERAIS"] = { "" },
    ["ROUBOAMMU"] = { "" },
    ["ROUBOCAIXA"] = { "" },
    ["ROUBOREGISTRADORA"] = { "" },
    ["BANCODEPOSITAR"] = { "" },
    ["BANCOSACAR"] = { "" },
    ["BANCOENVIAR"] = { "" },
    ["COMPRARVEICULO"] = { "" },
    ["WL"] = { "" },
    ["IDS"] = { "" },
    ["TPTO"] = { "" },
    ["TPTOME"] = { "" },
    ["GOD"] = { "" },
    ["GOID"] = { "" },
    ["KICK"] = { "" },
    ["BAN"] = { "" },
    ["PRENDERADM"] = { "" },
    ["AADM"] = { "" },
    ["KILL"] = { "" },
    ["ITEM"] = { "" },
    ["TPWAY"] = { "" },
    ["ACEITARCHAMADOADMIN"] = { "" },
    ["GROUPADD"] = { "" },
    ["GROUPREM"] = { "" },
    ["SPAWNCAR"] = { "" },
    ["MONEY"] = { "" },
    ["BATERPONTOBENNYS"] = { "" },
    ["BATERPONTOPOLICIA"] = { "" },
    ["BATERPONTOHOSPITAL"] = { "" },
    ["BATERPONTOADMIN"] = { "" },
    ["PRENDER"] = { "" },
    ["DESMANCHE"] = { "" },
    ["COPYPRESET"] = { "" },
    ["SETPRESET"] = { "" },
    ["REVISTARADM"] = { "" },
    ["VAULTADM"] = { "" },
    ["HOUSEADMCHEST"] = { "" },
    ["FUEL"] = { "" },
    ["LOCKPICK"] = { "" },
    ["FARMS"] = { "" },
    ["CRAFTS"] = { "" },
    ["VENDERDROGAS"] = { "" },
    ["CORRIDAILEGAL"] = { "" },
}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DISCORD WEEBHOOK
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.sendLog(weebhook, mensagge)
    if weebhook and mensagge then
        if pressetHooks[weebhook] ~= nil then
            SendWebhookMessage(pressetHooks[weebhook][1],mensagge)
        else
            SendWebhookMessage(weebhook,mensagge)
        end
    end
end

function SendWebhookMessage(webhook,message)
    if webhook ~= "none" then
        PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE BONUS
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.bonusTotal(user_id)
    local cOutros = vRP.query("vRP/select_bonus", {user_id = user_id} )
	local rOutros = json.decode(cOutros[1].bonus)
	local valorTotal = 0
    
	if rOutros then
		for k,v in pairs(rOutros) do
			valorTotal = valorTotal + v.bonus
		end

        if tonumber(valorTotal) > 0 then
            return tonumber(valorTotal)
        end
	end
end

function vRP.formatBonus(user_id, valor)
    local source = vRP.getUserSource(user_id)
	local bonus = vRP.bonusTotal(user_id)
	local total = valor
	if user_id then
		if bonus ~= nil then
			total = valor*(bonus/100)+valor
            TriggerClientEvent('chatMessage', source, "BONUS: ",{64,64,255},"Você possui ^2"..bonus.."%^0 de bonus e recebeu um valor adicional de ^2$"..vRP.format(valor*(bonus/100)))
            return total
        else
            return valor
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- DESLOGAR DENTRO DA PROPRIEDADE
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.atualizarPosicao(user_id,x,y,z)
    local data = vRP.getUserDataTable(user_id)
    if user_id then
        if data then
            data.position = { x = x, y = y, z = z }
        end
    end
end

function vRP.limparArmas(user_id)
    local data = vRP.getUserDataTable(user_id)
    if user_id then
        if data then
            data.weapons = {}
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTROS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler('playerDropped', function (reason)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then

        if reason == "Game crashed: gta-core-five.dll!CrashCommand (0x0)" then
            vRP.setBanned(user_id, true, "Usou comando para forjar o crash")
            vRP.sendLog("CRASHS", "O ID "..user_id.." utilizou o comando _crash.")
        end
    end
end)

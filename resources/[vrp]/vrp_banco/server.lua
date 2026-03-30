local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_banco",src)
Proxy.addInterface("vrp_banco",src)

vCLIENT = Tunnel.getInterface("vrp_banco")


local activated = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ABRIR BANCO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.openBank()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local money = vRP.getMoney(user_id)
        local identidade = vRP.getUserIdentity(user_id) 
        local infos = vRP.query("vRP/get_user_identity",{ user_id = user_id })
        if infos[1] then
            return infos[1].banco,money,identidade.nome.. " "..identidade.sobrenome,infos[1].multas,true 
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SACAR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.sacarDinheiro(amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if activated[user_id] == nil or not activated[user_id] then
            activated[user_id] = 3
            if vRP.tryWithdraw(user_id, amount) then
                TriggerClientEvent("Notify",source,"sucesso","Você sacou <b>$ "..amount.."</b>", 5)
                vRP.sendLog("BANCOSACAR", "O ID "..user_id.." sacou $ "..amount..".")
                return true
            else
                TriggerClientEvent("Notify",source,"importante","Você não possui essa quantia no banco para sacar.", 5)
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- DEPOSITAR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.depositarDinheiro(amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if activated[user_id] == nil or not activated[user_id] then
        activated[user_id] = 3
            if vRP.tryDeposit(user_id, amount) then
                TriggerClientEvent("Notify",source,"sucesso","Você depositou <b>$ "..amount.."</b>", 5)
                vRP.sendLog("BANCODEPOSITAR", "O ID "..user_id.." depositou $ "..amount..".")
                return true
            else
                TriggerClientEvent("Notify",source,"importante","Você não possui essa quantia para depositar.", 5)
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- TRANSFERIR
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.transferirDinheiro(targetid, amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        if activated[user_id] == nil or not activated[user_id] then
            activated[user_id] = 3
            if parseInt(targetid) == parseInt(user_id) then
                TriggerClientEvent("Notify",source,"negado","Você não pode transferir para si mesmo.", 5)
                return
            end

            local nsource = vRP.getUserSource(parseInt(targetid))
            if vRP.tryTransfer(user_id, targetid, amount) then
                if nsource then
                    TriggerClientEvent("Notify",nsource,"sucesso","Você acabou de receber uma transferencia de <b>$ "..amount.."</b> do ID: <b> "..user_id.."</b>.", 5)
                end

                TriggerClientEvent("Notify",source,"sucesso","Você acabou de transferir <b>$ "..amount.."</b> para o ID: <b> "..targetid.."</b>.", 5)
                vRP.sendLog("BANCOENVIAR", "O ID "..user_id.." enviou $ "..amount.." para o id "..targetid)
                return true
            else
                TriggerClientEvent("Notify",source,"importante","Você não possui essa quantia para transferir.", 5)
            end
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- PAGAR MULTAS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.pagarMultas(amount)
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local multas = vRP.getMultas(user_id)
        if multas >= parseInt(amount) then
            if vRP.tryTransfer(user_id, 1, amount) then -- TODAS MULTAS IREM PARA O ID [1]
                TriggerClientEvent("Notify",source,"sucesso","Você pagou <b>$ "..amount.."</b> de multas.", 5)
                vRP.updateMultas(user_id, multas - amount)
                return true
            end
        else
            TriggerClientEvent("Notify",source,"negado","Você possui <b>$ "..multas.."</b> de multas.", 5)
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ATUALIZAR BANCO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.updateBank()
    local source = source
    local user_id = vRP.getUserId(source)
    if user_id then
        local money = vRP.getMoney(user_id)
        local infos = vRP.query("vRP/get_user_identity",{ user_id = user_id })
        if infos[1] then
            vCLIENT.atualizarBanco(source, infos[1].banco,money,infos[1].multas)
        end
    end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTROS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
    while true do
        for k,v in pairs(activated) do
            if v >= 0 then
                activated[k] = v - 1
                if v <= 0 then
                    activated[k] = nil
                end
            end
        end

        Citizen.Wait(1000)
    end
end)
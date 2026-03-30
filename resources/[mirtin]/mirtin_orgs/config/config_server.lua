local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("mirtin_orgs",src)
Proxy.addInterface("mirtin_orgs",src)

vCLIENT = Tunnel.getInterface("mirtin_orgs")

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTROS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
allGroups = module("cfg/groups")
config = {}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUERYS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("mirtin_orgs/getOrg", "SELECT * FROM mirtin_orgs WHERE org = @org")
vRP.prepare("mirtin_orgs/updateMembers", "UPDATE mirtin_orgs SET membros = @membros WHERE org = @org")
vRP.prepare("mirtin_orgs/updateText", "UPDATE mirtin_orgs SET anotacao = @anotacao WHERE org = @org")
vRP.prepare("mirtin_orgs/initGroups", "INSERT IGNORE INTO mirtin_orgs(org,maxMembros) VALUES(@org, @maxMembros)")
vRP.prepare("mirtin_orgs/initTable", "CREATE TABLE IF NOT EXISTS `mirtin_orgs` ( `org` varchar(50) NOT NULL, `membros` text NOT NULL DEFAULT '{}', `maxMembros` int(11) NOT NULL DEFAULT 0, `anotacao` text DEFAULT NULL, PRIMARY KEY (`org`) ) ENGINE=InnoDB DEFAULT CHARSET=latin1;")

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIGS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config.license = "main" -- não mexa aqui ( isso server para updates exclusivos )
config.createTable = false -- Criar Tabela Automaticamente (Depois de startar o script pela primeira vez coloque false)
config.automaticGroups = true -- INSERIR CATEGORIA DE GRUPOS AUTOMATICAMENTE NO BANCO DE DADOS
config.adminPermission = "ticket.permissao" -- Permissao de ADM
config.blackList = 1 -- dia(s) Configura o tempo que o jogador não pode entrar em uma organização quando pedir contas/demitido

config.weebhook = {
    color = 6356736,
    logo = "https://i.imgur.com/Ta9YOaY.png",
    footer = "© Mirt1n Store"
}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONFIG GROUPS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config.groups = {
    ["Policia"] = {
        maxMembers = 99, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Recruta", grupo = "Recruta", permLider = false },
            [2] = { prefix = "Soldado", grupo = "Soldado", permLider = false },
            [3] = { prefix = "Cabo", grupo = "Cabo", permLider = false },
            [4] = { prefix = "3Sargento", grupo = "3Sargento", permLider = false },
            [5] = { prefix = "2Sargento", grupo = "2Sargento", permLider = false },
            [6] = { prefix = "1Sargento", grupo = "1Sargento", permLider = false },
            [7] = { prefix = "SubTenente", grupo = "SubTenente", permLider = false },
            [8] = { prefix = "Aspirante", grupo = "Aspirante", permLider = false },   
            [9] = { prefix = "2Tenente", grupo = "2Tenente", permLider = false },
            [10] = { prefix = "1Tenente", grupo = "1Tenente", permLider = false },
            [11] = { prefix = "Capitao", grupo = "Capitao", permLider = false },
            [12] = { prefix = "Major", grupo = "Major", permLider = false },
            [13] = { prefix = "Tenente Coronel", grupo = "Tenente Coronel", permLider = false },
            [14] = { prefix = "Coronel", grupo = "Coronel", permLider = true },
            [15] = { prefix = "Comandante", grupo = "Comandante", permLider = true },
        }
    },

    ["Stic"] = {
        maxMembers = 99, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Soldado S", grupo = "Soldado Stic", permLider = false },
            [2] = { prefix = "Tenente Coronel S", grupo = "Tenente Coronel Stic", permLider = false },
            [3] = { prefix = "Coronel S", grupo = "Coronel Stic", permLider = true },
            [4] = { prefix = "Comandante S", grupo = "Comandante Stic", permLider = true },
        }
    },

    ["Hospital"] = {
        maxMembers = 99, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Enfermeiro", grupo = "Enfermeiro [HOSPITAL]", permLider = false },
            [2] = { prefix = "Medico", grupo = "Medico [HOSPITAL]", permLider = false },
            [3] = { prefix = "Vice Diretor", grupo = "Vice Diretor [HOSPITAL]", permLider = true },
            [4] = { prefix = "Diretor", grupo = "Diretor [HOSPITAL]", permLider = true },
        }
    },

    ["Juridico"] = {
        maxMembers = 99, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Advogado", grupo = "Advogado", permLider = false },
            [2] = { prefix = "Juiz", grupo = "Juiz", permLider = true },
        }
    },

    ["Mafia"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [MAFIA]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [MAFIA]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [MAFIA]", permLider = true },
        }
    },

    ["Cartel"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [CARTEL]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [CARTEL]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [CARTEL]", permLider = true },
        }
    }, 

    ["Moto Clube"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [MOTOCLUBE]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [MOTOCLUBE]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [MOTOCLUBE]", permLider = true },
        }
    }, 

    ["Elements"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [ELEMENTS]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [ELEMENTS]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [ELEMENTS]", permLider = true },
        }
    }, 

    ["Brancos"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [BRANCOS]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [BRANCOS]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [BRANCOS]", permLider = true },
        }
    }, 

    ["Groove"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [GROOVE]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [GROOVE]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [GROOVE]", permLider = true },
        }
    }, 
    ["Vagos"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [VAGOS]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [VAGOS]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [VAGOS]", permLider = true },
        }
    }, 
    ["Cafe"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [CAFE]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [CAFE]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [CAFE]", permLider = true },
        }
    }, 

    ["MCL"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [MCL]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [MCL]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [MCL]", permLider = true },
        }
    }, 

    ["Bratva"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [BRATVA]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [BRATVA]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [BRATVA]", permLider = true },
        }
    },

    ["Vanilla"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [VANILLA]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [VANILLA]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [VANILLA]", permLider = true },
        }
    },

    ["Bahamas"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "XXX",
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [BAHAMAS]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [BAHAMAS]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [BAHAMAS]", permLider = true },
        }
    },

    ["Favela04"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [Favela04]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [Favela04]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [Favela04]", permLider = true },
        }
    },

    ["Favela05"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [Favela05]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [Favela05]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [Favela05]", permLider = true },
        }
    },

    ["Favela03"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [Favela03]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [Favela03]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [Favela03]", permLider = true },
        }
    },

    ["Verdes"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [VERDES]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [VERDES]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [VERDES]", permLider = true },
        }
    },

    ["Laranjas"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [LARANJAS]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [LARANJAS]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [LARANJAS]", permLider = true },
        }
    },

    ["Rosas"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [ROSAS]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [ROSAS]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [ROSAS]", permLider = true },
        }
    },

    ["Roxos"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [ROXOS]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [ROXOS]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [ROXOS]", permLider = true },
        }
    },

    ["Marrons"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [MARRONS]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [MARRONS]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [MARRONS]", permLider = true },
        }
    },

    ["Favela01"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [Favela01]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [Favela01]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [Favela01]", permLider = true },
        }
    },

    ["Favela02"] = {
        maxMembers = 30, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [Favela02]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [Favela02]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [Favela02]", permLider = true },
        }
    },

    ["Tropa VK"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [TROPAVK]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [TROPAVK]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [TROPAVK]", permLider = true },
        }
    },

    ["Franca"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [FRANCA]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [FRANCA]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [FRANCA]", permLider = true },
        }
    },

    ["Bennys"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [BENNYS]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [BENNYS]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [BENNYS]", permLider = true },
        }
    },

    ["Sport Race"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [SPORTRACE]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [SPORTRACE]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [SPORTRACE]", permLider = true },
        }
    },

    ["Cassino Royale"] = {
        maxMembers = 15, -- Defina Esse Valor Apenas 1x proxima vez alterar direto no banco de dados
        weebhook = "SEULINK", -- DEFINA O WEEBHOOK PARA AS TRANSACOES FEITAS NESSA ORGANIZACAO
        groups = {
            [1] = { prefix = "Membro", grupo = "Membro [CR]", permLider = false },
            [2] = { prefix = "Gerente", grupo = "Gerente [CR]", permLider = false },
            [3] = { prefix = "Lider", grupo = "Lider [CR]", permLider = true },
        }
    },
}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- LANGS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
config.langs = {
    jogadorOffline = function(source) return TriggerClientEvent("Notify",source, "negado","Este Jogador não se encontra na cidade.", 5) end,
    invitePlayer = function(source, playerID) return TriggerClientEvent("Notify",source, "sucesso","Você convidou o <b>(ID: "..playerID..")</b> para sua organização.", 5) end,
    requestInvite = function(source, orgName) return vRP.request(source, "Você está sendo convidado para a <b>"..orgName.."</b> deseja aceitar?", 30) end,
    acceptInvite = function(source) return TriggerClientEvent("Notify",source, "sucesso","O Jogador <b>aceitou</b> o convite da sua organização.", 5) end,
    acceptNInvite = function(source, orgName) return TriggerClientEvent("Notify",source, "sucesso","Parabens!!! Você acaba de entrar para a organização <b>"..orgName.."</b>", 5) end,
    notMember = function(source, orgName) return TriggerClientEvent("Notify",source, "negado","Você não faz parte de nenhuma organização.", 5) end,
    maxCargo = function(source) return TriggerClientEvent("Notify",source, "negado","Este jogador já atingiu o cargo maximo.", 5) end,
    promoted = function(source, playerID, cargo) return TriggerClientEvent("Notify",source, "sucesso","Você promoveu o <b>(ID: "..playerID..")</b> para <b>"..cargo.."</b>.", 5) end,
    youPromoted = function(source, cargo) return TriggerClientEvent("Notify",source, "sucesso","Você acaba de ser promovido para <b>"..cargo.."</b>.", 5) end,
    notThis = function(source) return TriggerClientEvent("Notify",source, "negado","Você não pode fazer isso em si mesmo.", 5) end,
    notPermission = function(source) return TriggerClientEvent("Notify",source, "negado","Você não possui permissão para isso.", 5) end,
    demitir = function(source, playerID) return TriggerClientEvent("Notify",source, "negado","Você demitiu o <b>(ID: "..playerID..")</b> da sua organização...", 5) end,
    demitirN = function(source, orgName) return TriggerClientEvent("Notify",source, "negado","Você foi demitido da organização: <b>"..orgName.."</b>", 5) end,
    attInfo = function(source, orgName) return TriggerClientEvent("Notify",source, "sucesso","Você atualizou as informaçoes de sua organização.", 5) end,
    pedirContas = function(source, orgName) vRPclient._giveWeapons(source, {}, true) return TriggerClientEvent("Notify",source, "sucesso","Você saiu da organização <b>"..orgName.."</b>.", 5) end,
    notThisMember = function(source, orgName) return TriggerClientEvent("Notify",source, "negado","Você não faz mais parte da organização: <b>"..orgName.."</b>.", 5) end,
    haveGroup = function(source) return TriggerClientEvent("Notify",source, "negado","Este Jogador já possui uma organização.", 5) end,
    isBlackList = function(source, tempo) return TriggerClientEvent("Notify",source, "negado","Atenção: Você está proibido de entrar em uma organização até <b>"..tempo.."</b>.", 5) end,
    haveBlackList = function(source, tempo) return TriggerClientEvent("Notify",source, "negado","Este jogador está proibido de entrar em qualquer organização até <b>"..tempo.."</b>", 5) end,
}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OPEN MENU
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('org', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        vCLIENT.openNui(source, src.getMyOrg(user_id))
    end
end)

RegisterCommand('orgadm', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, config.adminPermission) then
            if config.groups[args[1]] then
                vCLIENT.openNui(source, args[1])
            end
        end
    end
end)

RegisterCommand('rbl', function(source,args)
    local user_id = vRP.getUserId(source)
    if user_id then
        if vRP.hasPermission(user_id, config.adminPermission) then
            local id = tonumber(args[1])
            if id ~= nil then
                vRP.setUData(id, "Mirt1n:BlackList", 0)
                TriggerClientEvent("Notify",source, "sucesso","Você tirou a blacklist do id: "..id, 5)
            end
        end
    end
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
src.identity = function(user_id)
    local identity = vRP.getUserIdentity(user_id)
    return identity.nome,identity.sobrenome
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- INSERIR GRUPOS AUTOMATICAMENTE NO BANCO DE DADOS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
async(function()
    if config.createTable then
        vRP.execute("mirtin_orgs/initTable", {})
    end

    if config.automaticGroups then
        for k,v in pairs(config.groups) do
            vRP.execute("mirtin_orgs/initGroups", { org = k, maxMembros = v.maxMembers})
        end
    end
end)
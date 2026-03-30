local cfg = {}
-- ITEM | NOME | DESC | TYPE | PESO | FOME | SEDE

cfg.items = {
	["none"] = { "none", "none", 0.0, nil, nil},
	["roupas"] = { "Roupas", "none", 0.0, nil, nil},
	["money"] = { "Dinheiro","none", 0.0, nil, nil},
	
	-- ITENS VIP
	["alterarplaca"] = { "Alterar Placa", "usarVIP", 0.0, nil, nil},
	["alterarrg"] = { "Alterar RG", "usarVIP", 0.0, nil, nil},
	["alterartelefone"] = { "Alterar Telefone", "usarVIP", 0.0, nil, nil},
	["plastica"] = { "Plastica", "usarVIP", 0.0, nil, nil},

	-- Utilitarios
	["mochila"] = { "Mochila", "usar", 2.0, nil, nil},
	["skate"] = { "Skate", "usar", 1.0, nil, nil},
	["algemas"] = { "Algemas", "usar", 2.0, nil, nil},
	["chave_algemas"] = { "Chave de algemas", "usar", 0.3, nil, nil},
	["emptybottle"] = { "Garrafa Vazia", "usar", 0.2, nil, nil},

	-- Mecanica
	["pneus"] = { "Pneus","usar", 10.0, nil, nil},
	["repairkit"] = { "Kit de Reparos", "usar", 1.0, nil, nil},

	-- Eletronicos
	["radio"] = { "Radio", "none", 1.0, nil, nil},
    ["celular"] = { "Celular", "none", 1.0, nil, nil},
    ["apple_watch"] = { "Apple Watch", "none", 0.5, nil, nil},
	["compattachs"] = { "Attachs", "none", 2.0, nil, nil},

	-- Itens para Roubar
	["c4"] = { "C4", "none", 3.0, nil, nil},
	["bolsadinheiro"] = { "Bolsa de Dinheiro", "none", 2.0, nil, nil},
	["masterpick"] = { "MasterPick", "none", 1.0, nil, nil},
	["pendrive"] = { "Pendrive", "none", 1.0, nil, nil},
	["furadeira"] = { "Furadeira", "none", 3.0, nil, nil},
	["lockpick"] = { "Lock Pick", "usar", 1.0, nil, nil},

	-- Itens Mafia
    ["m-aco"] = { "Aço", "none", 0.3, nil, nil}, 
	["c-munirifle"] = { "Peça Munição Rifle", "none", 0.3, nil, nil},
    ["m-corpo_ak47_mk2"] = { "Corpo de AK47", "none", 0.3, nil, nil},
    ["m-corpo_g3"] = { "Corpo de G3", "none", 0.5, nil, nil},
    ["m-corpo_machinepistol"] = { "Corpo de TEC-9", "none", 0.3, nil, nil},
    ["m-corpo_pistol_mk2"] = { "Corpo de Pistol", "none", 0.3, nil, nil},
    ["m-corpo_smg_mk2"] = { "Corpo de SMG", "none", 0.3, nil, nil},
	["m-corpo_microsmg"] = { "Corpo de UZI", "none", 0.3, nil, nil},
    ["m-gatilho"] = { "Gatilho", "none", 0.3, nil, nil},
    ["m-malha"] = { "Malha", "none", 0.3, nil, nil},
    ["m-placametal"] = { "Placa de Metal", "none", 0.3, nil, nil},
    ["m-tecido"] = { "Tecido", "none", 0.3, nil, nil},


	-- Itens Caçador
	["couro"] = { "Couro", "none", 0.3, nil, nil},
	["carne"] = { "Carne", "none", 0.3, nil, nil},

	-- Itens Cartel
	["c-cobre"] = { "Cobre", "none", 0.40, nil, nil},
    ["c-ferro"] = { "Ferro", "none", 0.3, nil, nil},
    ["c-fio"] = { "Fio", "none", 0.4, nil, nil},
	["c-polvora"] = { "Polvora", "none", 0.1, nil, nil},

	-- Itens Lavagem
	["l-alvejante"] = { "Alvejante", "none", 0.1, nil, nil},

	-- Itens Drogas
	["folhamaconha"] = { "Folha de Maconha", "none", 0.3, nil, nil},
    ["pococaina"] = { "Po de cocaina", "none", 0.3, nil, nil},
	["acidolsd"] = { "Acido LSD", "none", 0.3, nil, nil},
	["morfina"] = { "Morfina", "none", 0.3, nil, nil},
	["anfetamina"] = { "Anfetamina", "none", 0.3, nil, nil},
	["acidolisergico"] = { "Ácido Lisérgico", "none", 0.3, nil, nil},

	-- Drogas
	["lsd"] = { "LSD", "usar", 1.0, nil, nil}, 
	["maconha"] = { "Maconha", "usar", 1.0, nil, nil},
	["cocaina"] = { "Cocaina", "usar", 1.0, nil, nil},
	["metanfetamina"] = { "Metanfetamina ", "usar", 1.0, nil, nil},
	["heroina"] = { "Heroina", "usar", 1.0, nil, nil},
	["ecstasy"] = { "Ecstasy", "usar", 1.0, nil, nil},

	-- Pacotes de craft
	["pacote_eletrico"] = { "Pacote Eletrico", "none", 3.0, nil, nil},
	["pacote_componentes"] = { "Pacote de Componentes", "none", 5.0, nil, nil},
	["pacote_tecido"] = { "Pacote de Tecido", "none", 3.0, nil, nil},
	["pacote_metalico"] = { "Pacote Metalico", "none", 10.0, nil, nil},
	["pacote_polvora"] = { "Pacote de Polvora", "none", 3.0, nil, nil},

    -- Ilegal
	["body_armor"] = { "Colete", "usar", 5.0, nil, nil},
    ["capuz"] = { "Capuz", "usar", 0.1, nil, nil},
    ["dirty_money"] = { "Dinheiro Sujo", "none", 0.0, nil, nil},
    ["scubagear"] = { "Kit de Mergulho", "usar",3.0, nil, nil},

	-- Itens Joalheria
	["relogioroubado"] = { "Relogio", "none", 0.5, nil, nil},
	["colarroubado"] = { "Colar", "none", 0.1, nil, nil},
	["anelroubado"] = { "Anel", "none", 0.1, nil, nil},
	["brincoroubado"] = { "Brinco", "none", 0.1, nil, nil},
	["pulseiraroubada"] = { "Pulseira", "none", 0.1, nil, nil},

	-- Itens Acougue
	["carnedepuma"] = { "Carne de Puma", "none", 3.0, nil, nil},
	["carnedelobo"] = { "Carne de Lobo", "none", 3.0, nil, nil},
	["carnedejavali"] = { "Carne de Javali", "none", 3.0, nil, nil},

    -- Tartaruga
    ["tartaruga"] = { "Tartaruga", "none", 3.0, nil, nil},

    -- Pescaria
    ["isca"] = { "Isca", "none", 0.25, nil, nil},
    ["pacu"] = { "Pacu", "none", 1.5, nil, nil},
    ["tilapia"] = { "Tilapia", "none", 0.50, nil, nil},
    ["salmao"] = { "Salmao", "none", 1.0, nil, nil},
    ["tucunare"] = { "Tucunare", "none", 2.0, nil, nil},
    ["dourado"] = { "Dourado", "none", 1.0, nil, nil},

    -- Lenhador
    ["madeira"] = { "Madeira", "none", 2.5, nil, nil},

	-- Entregador
	["caixa"] = { "Caixa de entrega", "none", 1.5, nil, nil},

	-- Mineracao
	["bronze"] = { "Bronze", "none", 1.0, nil, nil},
	["ferro"] = { "Ferro", "none", 1.0, nil, nil},
	["ouro"] = { "Ouro", "none", 1.0, nil, nil},
	["diamante"] = { "Diamante", "none", 1.0, nil, nil},
	["rubi"] = { "Rubi", "none", 1.0, nil, nil},
	["safira"] = { "Safira", "none", 1.0, nil, nil},

	-- COMIDAS
	["pao"] = { "Pao", "comer", 0.5, -10, nil},
	["sanduiche"] = { "Sanduiche", "comer", 0.5, -15, nil}, 


	["sanduichev"] = { "Sanduiche Vegano", "comer", 0.5, -15, nil},
	["paodequeijo"] = { "Pao De Queijo", "comer", 0.5, -15, nil},
	["bolodechocolate"] = { "Bolo De Chocolate", "comer", 0.5, -15, nil},
	["croissant"] = { "Croissant", "comer", 0.5, -15, nil},
	["cookie"] = { "Cookie", "comer", 0.5, -15, nil},
	["torta"] = { "Torta", "comer", 0.5, -15, nil},
	["tapioca"] = { "Tapioca", "comer", 0.5, -15, nil},

	

	
	["pizza"] = { "Pizza", "comer", 1.5, -18, nil},
	["barrac"] = { "Barra de chocolate", "comer", 0.5, -5, nil},
	["cachorroq"] = { "Cachorro Quente", "comer", 0.5, -10, nil},
	["pipoca"] = { "Pipoca", "comer", 0.3, -6, nil},
	["donut"] = { "Donut", "comer", 0.2, -5, nil},
	["paoq"] = { "Pao de Queijo", "comer", 0.3, -8, nil},
	["marmita"] = { "Marmitex", "comer", 2.0, -50, nil},
	["coxinha"] = { "Coxinha", "comer", 0.5, -10, nil},

	--Ingredientes
	["farinha"] = { "Farinha", "none", 0.1, nil, nil},
	["leite"] = { "Leite", "none", 0.1, nil, nil},
	["ovo"] = { "Ovo", "none", 0.1, nil, nil},
	["acucar"] = { "Acucar", "none", 0.1, nil, nil},
	["tapioca"] = { "Tapioca", "none", 0.1, nil, nil},
	["chocolate"] = { "Chocolate", "none", 0.1, nil, nil},
	["manteiga"] = { "Manteiga", "none", 0.1, nil, nil},
	["queijo"] = { "Queijo", "none", 0.1, nil, nil},
	["embutidos"] = { "Embutidos", "none", 0.1, nil, nil},
	



	-- BEBIDAS
	["cocacola"] = { "Coca Cola", "beber", 0.5, nil, -10},
	["sprunk"] = { "Sprunk", "beber", 0.5, nil, -12},
	["sucol"] = { "Suco de Laranja", "beber", 0.5, nil, -13},
	["sucol2"] = { "Suco de Limao", "beber", 0.5, nil, -13},
	["water"] = { "Agua", "beber", 0.5, nil, -15},
	["cha"] = { "Chá", "beber", 0.5, nil, -15},
	["suco"] = { "Suco", "beber", 0.5, nil, -15},
	["refrigerante"] = { "refrigerante", "beber", 0.5, nil, -15},
	["bubbletea"] = { "bubbletea", "beber", 0.5, nil, -15},

	["cafe"] = { "Cafe", "beber", 0.25, nil, -5},
	["energetico"] = { "Energetico", "beber", 0.25, nil, -10},

	-- ALCOLICAS FOME/SEDE
	["vodka"] = { "Vodka", "bebera", 1.0, 10, -5},
	["cerveja"] = { "Cerveja", "bebera", 0.5, 3, -5},
	["whisky"] = { "Whisky", "bebera", 1.0, 10, -5}, 
	["skolb"] = { "Skol Beats", "bebera", 0.25, 5, -5},
	["royalsalute"] = { "Royal Salute", "bebera", 2.0, 5, -25},

	-- REMEDIOS
	["bandagem"] = { "Bandagem", "remedio", 0.5, 5, nil},

	-- PISTOLAS
	["WEAPON_SNSPISTOL_MK2"] = { "Fajuta", "equipar", 3.0, nil, nil},
	["AMMO_SNSPISTOL_MK2"] = { "M-Fajuta", "recarregar", 0.05, nil, nil},

	["WEAPON_PISTOL_MK2"] = { "Five-Seven", "equipar", 3.0, nil, nil},
	["AMMO_PISTOL_MK2"] = { "M-Five-Seven", "recarregar", 0.05, nil, nil},

	["WEAPON_COMBATPISTOL"] = { "Glock", "equipar", 3.0, nil, nil},
	["AMMO_COMBATPISTOL"] = { "M-Glock", "recarregar", 0.05, nil, nil},

	-- SUBMETRALHADORA
	["WEAPON_MACHINEPISTOL"] = { "Tec-9", "equipar", 6.0, nil, nil},
	["AMMO_MACHINEPISTOL"] = { "M-Tec-9", "recarregar", 0.05, nil, nil},

	["WEAPON_SMG_MK2"] = { "Smg MK2", "equipar", 6.0, nil, nil},
	["AMMO_SMG_MK2"] = { "M-Smg MK2", "recarregar", 0.05, nil, nil},

	["WEAPON_SMG"] = { "SMG", "equipar", 6.0, nil, nil},
	["AMMO_SMG"] = { "M-SMG", "recarregar", 0.05, nil, nil},

	["WEAPON_ASSAULTSMG"] = { "MTAR", "equipar", 6.0, nil, nil},
	["AMMO_ASSAULTSMG"] = { "M-MTAR", "recarregar", 0.05, nil, nil},

	["WEAPON_MICROSMG"] = { "Uzi", "equipar", 6.0, nil, nil},
	["AMMO_MICROSMG"] = { "M-Uzi", "recarregar", 0.05, nil, nil},

	-- SHOTGUN
	["WEAPON_SAWNOFFSHOTGUN"] = { "Shotgun", "equipar", 8.0, nil, nil},
	["AMMO_SAWNOFFSHOTGUN"] = { "M-Shotgun", "recarregar", 0.05, nil, nil},

	["WEAPON_PUMPSHOTGUN_MK2"] = { "Pump Shotgun", "equipar", 8.0, nil, nil},
	["AMMO_PUMPSHOTGUN_MK2"] = { "M-Pump Shotgun", "recarregar", 0.05, nil, nil},

	-- MUSKET
	["WEAPON_MUSKET"] = { "Musket", "equipar", 8.0, nil, nil},
	["AMMO_MUSKET"] = { "M-Musket", "recarregar", 0.05, nil, nil},

	-- FUZIL
	["WEAPON_ASSAULTRIFLE_MK2"] = { "AK MK2", "equipar", 8.0, nil, nil},
	["AMMO_ASSAULTRIFLE_MK2"] = { "M-AK MK2", "recarregar", 0.05, nil, nil},

	["WEAPON_SPECIALCARBINE_MK2"] = { "G3", "equipar", 8.0, nil, nil},
	["AMMO_SPECIALCARBINE_MK2"] = { "M-G3", "recarregar", 0.05, nil, nil},

	["WEAPON_CARBINERIFLE"] = { "M4", "equipar", 8.0, nil, nil},
	["AMMO_CARBINERIFLE"] = { "M-M4", "recarregar", 0.05, nil, nil},

	["WEAPON_CARBINERIFLE_MK2"] = { "M4 MK2", "equipar", 8.0, nil, nil},
	["AMMO_CARBINERIFLE_MK2"] = { "M-M4MK2", "recarregar", 0.05, nil, nil},
	
	-- TAZER
	["WEAPON_STUNGUN"] = { "Tazer", "equipar", 1.0, nil, nil},

	-- ARMAS BRANCAS
	["WEAPON_KNIFE"] = { "Faca", "equipar", 1.0, nil, nil},
	["WEAPON_POOLCUE"] = { "Taco", "equipar", 1.0, nil, nil},
	["WEAPON_SWITCHBLADE"] = { "Canivete", "equipar", 1.0, nil, nil}, 
	["WEAPON_BATTLEAXE"] = { "Machado de Batalha", "equipar", 1.0, nil, nil}, 

	-- GALAO DE GASOLINA
	["WEAPON_PETROLCAN"] = { "Galão de gasolina", "equipar", 1.0, nil, nil},
	["AMMO_PETROLCAN"] = { "Gasolina", "equipar", 0.05, nil, nil},
}

return cfg


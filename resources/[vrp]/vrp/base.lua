local Proxy = module("lib/Proxy")
local Tunnel = module("lib/Tunnel")

vRP = {}
Proxy.addInterface("vRP",vRP)

tvRP = {}
Tunnel.bindInterface("vRP",tvRP)
vRPclient = Tunnel.getInterface("vRP")
local mirtinBan = Tunnel.getInterface("mirtin_bans")

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS TEMPORARIAS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vRP.users = {}
vRP.rusers = {}
vRP.user_tables = {}
vRP.user_tmp_tables = {}
vRP.user_sources = {}

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- BANCO DE DADOS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local db_drivers = {}
local db_driver
local cached_prepares = {}
local cached_queries = {}
local prepared_queries = {}
local db_initialized = false

function vRP.registerDBDriver(name,on_init,on_prepare,on_query)
	if not db_drivers[name] then
		db_drivers[name] = { on_init,on_prepare,on_query }
		db_driver = db_drivers[name]
		db_initialized = true

		for _,prepare in pairs(cached_prepares) do
			on_prepare(table.unpack(prepare,1,table.maxn(prepare)))
		end

		for _,query in pairs(cached_queries) do
			query[2](on_query(table.unpack(query[1],1,table.maxn(query[1]))))
		end

		cached_prepares = nil
		cached_queries = nil
	end
end

function vRP.prepare(name,query)
	prepared_queries[name] = true

	if db_initialized then
		db_driver[2](name,query)
	else
		table.insert(cached_prepares,{ name,query })
	end
end

function vRP.query(name,params,mode)
	if not mode then mode = "query" end

	if db_initialized then
		return db_driver[3](name,params or {},mode)
	else
		local r = async()
		table.insert(cached_queries,{{ name,params or {},mode },r })
		return r:wait()
	end
end

function vRP.execute(name,params)
	return vRP.query(name,params,"execute")
end

function vRP.setUData(user_id,key,value)
	exports["oxmysql"]:executeSync([[
		REPLACE INTO `vrp_user_data`(`user_id`,`dkey`,`dvalue`) VALUES(?,?,?)
	]],{ 
		user_id,key,value
	})
end

function vRP.getUData(user_id,key,cbr)
	local rows = exports["oxmysql"]:singleSync("SELECT `dvalue` FROM `vrp_user_data` WHERE `user_id` = ? AND `dkey` = ? ", { user_id,key })
	if rows then 
		return rows.dvalue
	end
	return ""
end

function vRP.remUData(user_id,key)
	vRP.execute("vRP/rem_u_data",{ user_id = parseInt(user_id), key = key })
end

function vRP.setSData(key,value)
	exports["oxmysql"]:executeSync([[
		REPLACE INTO `vrp_srv_data`(`dkey`,`dvalue`) VALUES(?,?)
	]],{ 
		key,value
	})
end

function vRP.remSrvdata(dkey)
	vRP.execute("creative/rem_srv_data",{ dkey = dkey })
end

function vRP.getSData(key, cbr)
	local rows = exports["oxmysql"]:singleSync("SELECT `dvalue` FROM `vrp_srv_data` WHERE `dkey` = ?", { key })
	if rows then 
		return rows.dvalue
	end
	return ""
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CAPTURAR IDENTIFIERS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.getUserIdByIdentifier(ids)
	local rows = vRP.query("vRP/userid_byidentifier",{ identifier = ids})
	if #rows > 0 then
		return rows[1].user_id
	else
		return -1
	end
end

function vRP.getUserIdByIdentifiers(ids)
	if ids and #ids then
		for i=1,#ids do
			if (string.find(ids[i],"ip:") == nil) then
				local rows = vRP.query("vRP/userid_byidentifier",{ identifier = ids[i] })
				if #rows > 0 then
					return rows[1].user_id
				end
			end
		end

		local rows = exports["oxmysql"]:executeSync([[INSERT IGNORE INTO vrp_users(whitelist) VALUES(false)]])
		if rows then
			local user_id = rows.insertId

			for l,w in pairs(ids) do
				if (string.find(w,"ip:") == nil) then
					vRP.execute("vRP/add_identifier",{ user_id = user_id, identifier = w })
                end

				vRP.execute("vRP/init_users_infos",{ user_id = user_id })
			end
			
			return user_id
		end
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE BANS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("mirtin/insertBanned/base","INSERT IGNORE INTO mirtin_bans(user_id,motivo,desbanimento,banimento,time, hwid) VALUES(@user_id,@motivo,@desbanimento,@banimento,@time, @hwid)")

function vRP.setBanned(user_id,status)
	if user_id then
		vRP.execute("mirtin/insertBanned/base", { user_id = user_id, motivo = "Banido pelo ANTI HACK", banimento = os.date("%d/%m/%Y as %H:%M"), desbanimento = "Nunca", time = 0, hwid = 0 })
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE WHITELIST
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.isWhitelisted(user_id)
	local rows = vRP.query("vRP/get_whitelisted",{ user_id = user_id })
	if #rows > 0 then
		return rows[1].whitelist
	else
		return false
	end
end

function vRP.setWhitelisted(user_id,whitelisted)
	vRP.execute("vRP/set_whitelisted",{ user_id = user_id, whitelist = whitelisted })
end

function vRP.kick(source,reason)
	DropPlayer(source,reason)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTION GERAIS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.getUserDataTable(user_id)
	return vRP.user_tables[user_id]
end

function vRP.getUserTmpTable(user_id)
	return vRP.user_tmp_tables[user_id]
end

function vRP.getUserId(source)
	if source ~= nil then
		local ids = GetPlayerIdentifiers(source)
		if ids ~= nil and #ids > 0 then
			return vRP.users[ids[1]]
		end
	end
	return nil
end

function vRP.getUsers()
	local users = {}
	for k,v in pairs(vRP.user_sources) do
		users[k] = v
	end
	return users
end

function vRP.getUserSource(user_id)
	return vRP.user_sources[user_id]
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Sistema do Inventario
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.getInventory(user_id)
	local data = vRP.user_tables[user_id]
	if data then
		return data.inventory
	end
	return false
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CONECTANDO NO SERVIDOR
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
	deferrals.defer()
	local source = source
	local ids       = GetPlayerIdentifiers(source)
	local playerIP = GetPlayerEndpoint(source)

	if ids ~= nil and #ids > 0 then
		deferrals.update("[MIRT1N] Checando Identificadores...")
		local user_id = vRP.getUserIdByIdentifiers(ids)
		if user_id then

			deferrals.update("[MIRT1N] Checando White-list...")
			if vRP.isWhitelisted(user_id) then
				if vRP.rusers[user_id] == nil then
					deferrals.update("[MIRT1N] Carregando Dados...")
					local sdata = vRP.getUData(user_id,"vRP:datatable")

					vRP.users[ids[1] ] = user_id
					vRP.rusers[user_id] = ids[1]
					vRP.user_tables[user_id] = {}
					vRP.user_tmp_tables[user_id] = {}
					vRP.user_sources[user_id] = source

					local data = json.decode(sdata)
					if type(data) == "table" then vRP.user_tables[user_id] = data end

					local tmpdata = vRP.getUserTmpTable(user_id)
					tmpdata.spawns = 0
					
					if playerIP == nil then playerIP = "0.0.0.0" end
					vRP.execute("vRP/set_last_login",{ user_id = user_id, ultimo_login = os.date("%d/%m/%Y"), ip = playerIP })

					TriggerEvent("vRP:playerJoin",user_id,source,name)
					
					if user_id then
						vRP.sendLog("ENTRADA", "O ID "..user_id.." entrou no servidor.")
					end

					deferrals.done()
				else
					local tmpdata = vRP.getUserTmpTable(user_id)
					tmpdata.spawns = 0

					TriggerEvent("vRP:playerRejoin",user_id,source,name)
					deferrals.done()
				end
			else
				deferrals.done("\n[MIRT1N] Bem vindo a Mirt1n Base \n Para entrar no nosso servidor basta você acessar nosso discord e fazer a White-list \n Seu ID: [ "..user_id.." ]\n Nosso Discord: seudiscord.gg")
			end
		else
			deferrals.done("[MIRT1N] Ocorreu um problema de identificação.")
		end
	else
		deferrals.done("[MIRT1N] Ocorreu um problema de identidade.")
	end
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SALVAR DADOS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function task_save_datatables()
	SetTimeout(300*1000,task_save_datatables)
	for k,v in pairs(vRP.user_tables) do
		vRP.setUData(k,"vRP:datatable",json.encode(v))
	end
end

async(function()
	task_save_datatables()
end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- OUTRAS FUNCTIONS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.format(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1.'):reverse())..right
end

function vRP.tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMAs DE DESLOGAR E SPAWNAR
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.dropPlayer(source)
	local source = source
	local user_id = vRP.getUserId(source)
	vRPclient._removePlayer(-1,source)
	if user_id then
		if user_id and source then
			vRP.sendLog("SAIDA", "O ID "..user_id.." saiu do servidor.")
			TriggerEvent("vRP:playerLeave",user_id,source)
		end

		vRP.setUData(user_id,"vRP:datatable",json.encode(vRP.getUserDataTable(user_id)))
		vRP.users[vRP.rusers[user_id]] = nil
		vRP.rusers[user_id] = nil
		vRP.user_tables[user_id] = nil
		vRP.user_tmp_tables[user_id] = nil
		vRP.user_sources[user_id] = nil
	end
end

AddEventHandler("playerDropped",function(reason)
	local source = source
	vRP.dropPlayer(source)
end)

RegisterServerEvent("vRPcli:playerSpawned")
AddEventHandler("vRPcli:playerSpawned",function()
    local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.user_sources[user_id] = source
		local tmp = vRP.getUserTmpTable(user_id)
		tmp.spawns = tmp.spawns+1
		local first_spawn = (tmp.spawns == 1)
		if first_spawn then
			for k,v in pairs(vRP.user_sources) do
				vRPclient._addPlayer(source,v)
			end
			vRPclient._addPlayer(-1,source)
			Tunnel.setDestDelay(source,0)
        end
		TriggerEvent("vRP:playerSpawn",user_id,source,first_spawn)
	end
end)

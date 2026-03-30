-----------------------------------------------------------------------------------------------------------------------------------------
-- VRP
-----------------------------------------------------------------------------------------------------------------------------------------
local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_tattos",src)
Proxy.addInterface("vrp_tattos",src)

vCLIENT = Tunnel.getInterface("vrp_tattos")

-----------------------------------------------------------------------------------------------------------------------------------------
-- QUERYS
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("vRP/set_tattos","UPDATE vrp_users_infos SET tattos = @tattos WHERE user_id = @user_id")

-----------------------------------------------------------------------------------------------------------------------------------------
-- GETPLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
function src.getTattos()
	local source = source
    local user_id = vRP.getUserId(source)
    local rows = vRP.query("vRP/get_users_infos",{ user_id = user_id })
    local tattos = json.decode(rows[1].tattos) or {}
    if rows then
        return tattos
    end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- GETPLAYERS
-----------------------------------------------------------------------------------------------------------------------------------------
function src.updateTattoo(status)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.execute("vRP/set_tattos",{ user_id = user_id, tattos = json.encode(status) })
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- SETINSTANCE
-----------------------------------------------------------------------------------------------------------------------------------------
function src.setInstance(status)
    local source = source 
    local user_id = vRP.getUserId(source)
    if user_id then 
        if status then 
	        SetPlayerRoutingBucket(source, parseInt(user_id))
        else
	        SetPlayerRoutingBucket(source,0)
        end
    end
end
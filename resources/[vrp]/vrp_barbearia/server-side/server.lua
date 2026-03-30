local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_barbearia",src)
vCLIENT = Tunnel.getInterface("vrp_barbearia")

-----------------------------------------------------------------------------------------------------------------------------------------
-- BARBER
-----------------------------------------------------------------------------------------------------------------------------------------
function src.getCustom()
	local source = source
	local user_id = vRP.getUserId(source)
	local getRosto = vRP.query("vRP/get_rosto", {user_id = user_id})
	if getRosto ~= nil then
		local custom = json.decode(getRosto[1].rosto) or {}
		return custom
	end

	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- UPDATESKIN
-----------------------------------------------------------------------------------------------------------------------------------------
function src.updateSkin(myClothes)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		vRP.execute("vRP/set_controller",{ user_id = user_id, controller = 1, rosto = json.encode(myClothes) })
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
			if GetPlayerRoutingBucket(source) ~= 0 then
		        SetPlayerRoutingBucket(source, 0)
			end
        end
    end
end

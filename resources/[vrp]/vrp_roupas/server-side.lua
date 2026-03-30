local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("vrp_roupas",src)
vCLIENT = Tunnel.getInterface("vrp_roupas")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE ROUPAS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('mascara', function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id, "roupas") >= 1 or vRP.hasPermission(user_id, "perm.vips") or vRP.hasPermission(user_id, "perm.streamer") then
			vCLIENT.updateClothes(source, "mascara", tonumber(args[1]), tonumber(args[2]))
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui o item roupas.",5)
		end
	end
end)

RegisterCommand('oculos', function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id, "roupas") >= 1 or vRP.hasPermission(user_id, "perm.vips") or vRP.hasPermission(user_id, "perm.streamer") then
			vCLIENT.updateClothes(source, "oculos", tonumber(args[1]), tonumber(args[2]))
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui o item roupas.",5)
		end
	end
end)

RegisterCommand('chapeu', function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id, "roupas") >= 1 or vRP.hasPermission(user_id, "perm.vips") or vRP.hasPermission(user_id, "perm.streamer") then
			vCLIENT.updateClothes(source, "chapeu", tonumber(args[1]), tonumber(args[2]))
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui o item roupas.",5)
		end
	end
end)

RegisterCommand('colete', function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id, "roupas") >= 1 or vRP.hasPermission(user_id, "perm.vips") or vRP.hasPermission(user_id, "perm.streamer") then
			vCLIENT.updateClothes(source, "colete", tonumber(args[1]), tonumber(args[2]))
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui o item roupas.",5)
		end
	end
end)

RegisterCommand('acessorio', function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id, "roupas") >= 1 or vRP.hasPermission(user_id, "perm.vips") or vRP.hasPermission(user_id, "perm.streamer") then
			vCLIENT.updateClothes(source, "acessorio", tonumber(args[1]), tonumber(args[2]))
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui o item roupas.",5)
		end
	end
end)

RegisterCommand('sapatos', function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id, "roupas") >= 1 or vRP.hasPermission(user_id, "perm.vips") or vRP.hasPermission(user_id, "perm.streamer") then
			vCLIENT.updateClothes(source, "sapato", tonumber(args[1]), tonumber(args[2]))
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui o item roupas.",5)
		end
	end
end)

RegisterCommand('mochila', function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id, "roupas") >= 1 or vRP.hasPermission(user_id, "perm.vips") or vRP.hasPermission(user_id, "perm.streamer") then
			vCLIENT.updateClothes(source, "mochila", tonumber(args[1]), tonumber(args[2]))
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui o item roupas.",5)
		end
	end
end)

RegisterCommand('jaqueta', function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id, "roupas") >= 1 or vRP.hasPermission(user_id, "perm.vips") or vRP.hasPermission(user_id, "perm.streamer") then
			vCLIENT.updateClothes(source, "jaqueta", tonumber(args[1]), tonumber(args[2]))
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui o item roupas.",5)
		end
	end
end)

RegisterCommand('maos', function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id, "roupas") >= 1 or vRP.hasPermission(user_id, "perm.vips") or vRP.hasPermission(user_id, "perm.streamer") then
			vCLIENT.updateClothes(source, "mao", tonumber(args[1]), tonumber(args[2]))
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui o item roupas.",5)
		end
	end
end)

RegisterCommand('calca', function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id, "roupas") >= 1 or vRP.hasPermission(user_id, "perm.vips") or vRP.hasPermission(user_id, "perm.streamer") then
			vCLIENT.updateClothes(source, "calca", tonumber(args[1]), tonumber(args[2]))
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui o item roupas.",5)
		end
	end
end)

RegisterCommand('blusa', function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.getInventoryItemAmount(user_id, "roupas") >= 1 or vRP.hasPermission(user_id, "perm.vips") or vRP.hasPermission(user_id, "perm.streamer") then
			vCLIENT.updateClothes(source, "blusa", tonumber(args[1]), tonumber(args[2]))
		else
			TriggerClientEvent("Notify",source,"negado","Você não possui o item roupas.",5)
		end
	end
end)
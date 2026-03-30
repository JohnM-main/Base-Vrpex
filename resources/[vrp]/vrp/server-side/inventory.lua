------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CRIAR ITENS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local cfg = module("cfg/items")

vRP.items = {}

function vRP.defInventoryItem(idname, name, tipo, weight, fome, sede)
	if weight == nil then
		weight = 0
	end
	
	local item = { name = name, tipo = tipo, weight = weight, fome = fome, sede = sede }
	vRP.items[idname] = item
end


for k,v in pairs(cfg.items) do
    vRP.defInventoryItem(k,v[1],v[2],v[3],v[4],v[5])
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS PADROES
-----------------------------------------------------------------------------------------------------------------------------------------
local addPeso = {}

function vRP.getAllItens()
	return vRP.items
end

function vRP.getItemName(idname)
	local args = vRP.parseItem(idname)
	local item = vRP.items[args[1]]
	if item then
		return vRP.computeItemName(item,args)
	end
	return args[1]
end

function vRP.getItemWeight(idname)
	local args = vRP.parseItem(idname)
	local item = vRP.items[args[1]]
	if item then
		return vRP.computeItemWeight(item,args)
	end
	return 0
end

function vRP.itemFood(args)
    local item = vRP.items[args]
    if item then
        return item.fome,item.sede
    end
end

function vRP.computeItemName(item,args)
	if type(item.name) == "string" then
		return item.name
	else
		return item.name(args)
	end
end

function vRP.computeItemWeight(item,args)
	if type(item.weight) == "number" then
		return item.weight
	else
		return item.weight(args)
	end
end

function vRP.getItemType(args)
	local item = vRP.items[args]
	if item then
		return item.tipo
	end
end

function vRP.getItemImagem(args)
	local item = vRP.items[args]
	if item then
		return "http://177.54.148.31:4020/inventario/"..args..".png"
	end
end

function vRP.computeInvWeight(user_id)
	local weight = 0
	local inventory = vRP.getInventory(user_id)
	if inventory then
		for k,v in pairs(inventory) do
			if vRP.items[v.item] then
				weight = weight + vRP.getItemWeight(v.item) * parseInt(v.amount)
			end
		end
		return weight
	end
	return 0
end 

function vRP.computeItemsWeight(items)
	local weight = 0
	if items then
		for k,v in pairs(items) do
			if vRP.items[v.item] then
				weight = weight + vRP.getItemWeight(v.item) * parseInt(v.amount)
			end
		end
		return weight
	end
	return 0
end 

function vRP.getInventoryItemAmount(user_id,idname)
	local data = vRP.getInventory(user_id)
	if data then
		for k,v in pairs(data) do
			if v.item == idname then
				return parseInt(v.amount)
			end
		end
	end
	return 0
end

function vRP.getItemInSlot(user_id, idname, target)
	local data = vRP.getInventory(user_id)
	if data then
		for k,v in pairs(data) do
			if v.item == idname then
				return k
			end
		end
	end
	return target
end

function vRP.addPeso(user_id, peso)
	addPeso[user_id] = tonumber(peso)
end

function vRP.getInventoryMaxWeight(user_id)
	local data = vRP.getUserDataTable(user_id)
	local mochila = data.mochila
	if data then
		if user_id then
			if addPeso[user_id] == nil then
				addPeso[user_id] = 0
			end

			return 10+tonumber(addPeso[user_id])+30*tonumber(mochila.quantidade)
		end
	end
end

function vRP.clearInventory(user_id)
	local data = vRP.getUserDataTable(user_id)
	if data then
		data.inventory = {}
	end
end

function vRP.parseItem(idname)
	return splitString(idname,"|")
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES DO INVENTARIO
-----------------------------------------------------------------------------------------------------------------------------------------
function vRP.giveInventoryItem(user_id,idname,amount,notify, slot)
	local source = vRP.getUserSource(user_id)
	local data = vRP.getInventory(user_id)
	if user_id then
		if data and parseInt(amount) > 0 then
			if not slot then
				local initial = 0
				repeat
					initial = initial + 1
				until data[tostring(initial)] == nil or (data[tostring(initial)] and data[tostring(initial)].item == idname)
				initial = tostring(initial)
				
				if data[initial] == nil then
					data[initial] = { item = idname, amount = parseInt(amount) }
				elseif data[initial] and data[initial].item == idname then
					data[initial].amount = parseInt(data[initial].amount) + parseInt(amount)
				end

				if notify then
					TriggerClientEvent("NotifyItem",source,"sucesso", amount , vRP.getItemName(idname), idname, vRP.getItemWeight(idname)*amount)
				end
			else
				slot = tostring(slot)

				if data[slot] then
					if data[slot].item == idname then
						local oldAmount = parseInt(data[slot].amount)
						data[slot] = { item = idname, amount = parseInt(oldAmount) + parseInt(amount) }
					end
				else
					data[slot] = { item = idname, amount = parseInt(amount) }
				end

				if notify then
					TriggerClientEvent("NotifyItem",source,"sucesso", amount , vRP.getItemName(idname), idname, vRP.getItemWeight(idname)*amount)
				end
			end
		end
	end
end

function vRP.tryGetInventoryItem(user_id,idname,amount,notify,slot)
	local source = vRP.getUserSource(user_id)
	local data = vRP.getInventory(user_id)
	if user_id then
		if data then
			if not slot then
				for k,v in pairs(data) do
					if v.item == idname and parseInt(v.amount) >= parseInt(amount) then
						v.amount = parseInt(v.amount) - parseInt(amount)

						if parseInt(v.amount) <= 0 then
							data[k] = nil
						end

						if notify then
							TriggerClientEvent("NotifyItem",source,"negado", amount , vRP.getItemName(idname), idname, vRP.getItemWeight(idname)*amount)
						end

						return true
					end
				end
			else
				local slot  = tostring(slot)

				if data[slot] and data[slot].item == idname and parseInt(data[slot].amount) >= parseInt(amount) then
					data[slot].amount = parseInt(data[slot].amount) - parseInt(amount)

					if parseInt(data[slot].amount) <= 0 then
						data[slot] = nil
					end

					if notify then
						TriggerClientEvent("NotifyItem",source,"negado", amount , vRP.getItemName(idname), idname, vRP.getItemWeight(idname)*amount)
					end
					
					return true
				end
			end
		end
	end
	return false
end

function vRP.removeInventoryItem(user_id,idname,amount)
	local source = vRP.getUserSource(user_id)
	local data = vRP.getInventory(user_id)
	if user_id then
		if data then
			for k,v in pairs(data) do
				if v.item == idname and parseInt(v.amount) >= parseInt(amount) then
					v.amount = parseInt(v.amount) - parseInt(amount)

					if parseInt(v.amount) <= 0 then
						data[k] = nil
					end
					break
				end
			end
			
			TriggerClientEvent("NotifyItem",source,"negado", amount , vRP.getItemName(idname), idname, vRP.getItemWeight(idname)*amount)
		end
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- ADICIONAR ITEM OFFLINE
-----------------------------------------------------------------------------------------------------------------------------------------
vRP.prepare("selectDataTable", "SELECT dvalue from vrp_user_data WHERE dkey = 'vRP:datatable' and user_id = @user_id")
vRP.prepare("updateDataTable", "UPDATE vrp_user_data SET dvalue = @dvalue WHERE user_id = @user_id")

lock = {}
RegisterServerEvent("fstore:send_item")
AddEventHandler("fstore:send_item",function(user_id, item, amount)

	while lock[user_id] do Wait(50) end
	lock[user_id] = true

	local source = vRP.getUserSource(user_id)
	if source then
		print("FIVEM-STORE: Adicionado item: "..item.." "..amount.."x user_id: "..user_id.. " jogador: online")
		vRP.giveInventoryItem(user_id, item, amount, true)
	else
		local rows = vRP.query("selectDataTable", { user_id = user_id })
		if #rows > 0 then
			local decode = json.decode(rows[1].dvalue)
			local inventory = decode.inventory

			local count = 0
			repeat 
				count = count + 1
			until inventory[tostring(count)] == nil

			print("FIVEM-STORE: Adicionado item: "..item.." "..amount.."x user_id: "..user_id.. " slot: "..count.. " jogador: offline")

			inventory[tostring(count)] = { item = item, amount = amount }
			vRP.execute("updateDataTable", { user_id = user_id, dvalue = json.encode(decode) })
		
		else
			print("Ocorreu um problema ao entregar o item para o user_id: "..user_id)
		end
	end

	lock[user_id] = nil
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE MOCHILA
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.addMochila(user_id)
	local data = vRP.getUserDataTable(user_id)
	local mochila = data.mochila

	if data then
		data.mochila = { quantidade = mochila.quantidade+1, perder = mochila.perder }
	end
end

function vRP.remMochila(user_id)
	local data = vRP.getUserDataTable(user_id)
	local mochila = data.mochila

	if data then
		data.mochila = { quantidade = 0, perder = mochila.perder }
	end
end

function vRP.getMochilaAmount(user_id)
	local data = vRP.getUserDataTable(user_id)
	local mochila = data.mochila
	if data then
		return mochila.quantidade
	end
end

function vRP.atualizarMochila(user_id, time)
	local data = vRP.getUserDataTable(user_id)
	local mochila = data.mochila

	if data then
		data.mochila = { quantidade = mochila.quantidade, perder = time }
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EVENTOS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("vRP:playerJoin", function(user_id,source,name)
	local data = vRP.getUserDataTable(user_id)

	if not data.inventory then
		data.inventory = {}
	end

	if not data.mochila then
		data.mochila = { quantidade = 0, perder = 0 }
	end
end)

AddEventHandler("vRP:playerSpawn",function(user_id,source,first_spawn)
	addPeso[user_id] = 0
end)
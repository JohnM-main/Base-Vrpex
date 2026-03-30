--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CACHE
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local cache = {}
cache['getBankMoney'] = {}
cache['getMultas'] = {}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- CARTEIRA
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.getMoney(user_id)
	if user_id then
		return parseInt(vRP.getInventoryItemAmount(user_id, "money")) or 0
	end
end

function vRP.giveMoney(user_id,amount)
	if user_id then
		if amount > 0 then
			vRP.giveInventoryItem(user_id, "money", amount, false)
		end
	end
end

function vRP.tryPayment(user_id, amount)
	if user_id then
		if amount > 0 then
			if vRP.getInventoryItemAmount(user_id, "money") >= amount then
				vRP.tryGetInventoryItem(user_id, "money", amount)
				return true
			end
		end
		return false
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- BANCO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.giveBankMoney(user_id, amount)
	if user_id then
		if parseInt(amount) > 0 then
			cache['getBankMoney'][user_id] = parseInt(vRP.getBankMoney(user_id))+parseInt(amount)
			vRP.setBankMoney(user_id, cache['getBankMoney'][user_id])
		end
	end
end

function vRP.getBankMoney(user_id)
	if user_id then
		if cache['getBankMoney'][user_id] == nil then
			local rows = vRP.query("vRP/get_user_identity",{ user_id = user_id })
			if rows[1] then
				cache['getBankMoney'][user_id] = parseInt(rows[1].banco)
			end
		end

		return cache['getBankMoney'][user_id] or 0
	end
end

function vRP.setBankMoney(user_id, amount)
    if user_id then
        if parseInt(amount) >= 0 then
			cache['getBankMoney'][user_id] = amount
            vRP.execute("vRP/update_banco",{ user_id = user_id, banco = cache['getBankMoney'][user_id] })
        end
    end
end

function vRP.tryWithdraw(user_id, amount)
	if user_id then
		if parseInt(amount) > 0 then
			local banco = vRP.getBankMoney(user_id)
			if parseInt(banco) >= parseInt(amount) then
				vRP.giveMoney(user_id, parseInt(amount))
				vRP.setBankMoney(user_id, parseInt(banco)-parseInt(amount))
				return true
			end
		end
		return false
	end
end

function vRP.tryDeposit(user_id, amount)
	if user_id then
		if parseInt(amount) > 0 then
			local money = vRP.getMoney(user_id)
			if money >= parseInt(amount) then
				vRP.tryGetInventoryItem(user_id, "money", parseInt(amount))
				vRP.setBankMoney(user_id, parseInt(vRP.getBankMoney(user_id))+parseInt(amount))
				return true
			end
		end
		return false
	end
end

function vRP.tryTransfer(user_id, target_id, amount)
	if user_id then
		if parseInt(amount) > 0 then
			local banco = vRP.getBankMoney(user_id)
			local nbanco = vRP.getBankMoney(parseInt(target_id))
			if nbanco then
				if parseInt(banco) >= parseInt(amount) then
					vRP.setBankMoney(user_id, parseInt(banco)-parseInt(amount))
					vRP.setBankMoney(target_id, parseInt(nbanco)+parseInt(amount))
					return true
				end
			end

		end
		return false
	end
end

function vRP.tryFullPayment(user_id, amount)
	if user_id then
		if amount > 0 then
			local money = vRP.getMoney(user_id)
			if money >= parseInt(amount) then
				return vRP.tryPayment(user_id, parseInt(amount))
			else
				if vRP.tryWithdraw(user_id, parseInt(amount)-money) then
					return vRP.tryPayment(user_id,parseInt(amount))
				end
			end
		end
		return false
	end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- MULTAS
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function vRP.getMultas(user_id)
	if user_id then
		if cache['getMultas'][user_id] == nil then
			local rows = vRP.query("vRP/get_user_identity",{ user_id = user_id })
			if rows[1] then
				cache['getMultas'][user_id] = parseInt(rows[1].multas)
			end
		end

		return cache['getMultas'][user_id] or 0
	end
end

function vRP.updateMultas(user_id, amount)
	if user_id then
		cache['getMultas'][user_id] = amount
		vRP.execute("vRP/update_multas",{ user_id = user_id, multas = cache['getMultas'][user_id] })
	end
end
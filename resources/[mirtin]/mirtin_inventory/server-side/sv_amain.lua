local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
local Tools = module("vrp","lib/Tools")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

src = {}
Tunnel.bindInterface("mirtin_inventory",src)
Proxy.addInterface("mirtin_inventory",src)

vCLIENT = Tunnel.getInterface("mirtin_inventory")
vPOLICE = Tunnel.getInterface("vrp_policia")
local arena = Tunnel.getInterface("mirtin_arena")
-------------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local idgens = Tools.newIDGenerator()
local allItems = {}
local actived = {}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE INVENTARIO PERSONAL
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local droplist = {}

function src.Mochila()
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)

	if user_id then
		local inv = vRP.getInventory(user_id)
		if inv then 
			local inventory = {}

			for k,v in pairs(inv) do
				if (parseInt(v["amount"]) <= 0 or allItems[v.item] == nil) then
					vRP.removeInventoryItem(user_id,v.item,parseInt(v["amount"]))
				else
					v["amount"] = parseInt(v["amount"])
					v["name"] = allItems[v["item"]].name
					v["peso"] = allItems[v["item"]].weight
					v["index"] = allItems[v["item"]].tipo
					v["key"] = v["item"]
					v["slot"] = k
					inventory[k] = v
				end
			end
			
			local org = vRP.getUserGroupByType(user_id,"org")
			if org == nil or org == "" then org = "Nenhum(a)" end

			return inventory,vRP.computeInvWeight(user_id),vRP.getInventoryMaxWeight(user_id), { identity["nome"].." "..identity["sobrenome"],user_id,identity["telefone"],identity["registro"], org }
		end
	end
end

function src.useItem(slot, amount)
    local source = source
    local user_id = vRP.getUserId(source)

    if user_id then
        local inv = vRP.getInventory(user_id)
        if inv then
            if not inv[tostring(slot)] or inv[tostring(slot)].item == nil then
                return
            end

            local item = inv[tostring(slot)].item
            local itemType = vRP.getItemType(item)
            if itemType then
                if actived[user_id] == nil then
                        if itemType == "usar" then
                            actived[user_id] = 2

                            if item == "mochila" then
                                local maxMochila = {}
                                if vRP.hasPermission(user_id, "perm.prata") then
                                    maxMochila[user_id] = 3
                                elseif vRP.hasPermission(user_id, "perm.ouro") then
                                    maxMochila[user_id] = 3
                                elseif vRP.hasPermission(user_id, "perm.platina") then
                                    maxMochila[user_id] = 4
                                elseif vRP.hasPermission(user_id, "perm.diamante") then
                                    maxMochila[user_id] = 4
								elseif vRP.hasPermission(user_id, "perm.esmeralda") then
                                    maxMochila[user_id] = 4
                                else
                                    maxMochila[user_id] = 3
                                end
                                if tonumber(maxMochila[user_id]) > tonumber(vRP.getMochilaAmount(user_id)) then
                                    if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                        vRP.addMochila(user_id)
                                        TriggerClientEvent( "Notify", source, "importante", "Você equipou a mochila, limite maximo de <b>(" .. vRP.getMochilaAmount(user_id) .. "/" .. maxMochila[user_id] .. ")</b> mochilas.", 5 )
                                    end
                                else
                                    TriggerClientEvent( "Notify", source, "negado", "Você ja antigiu o limite maximo de <b>(" .. maxMochila[user_id] .. ")</b> mochilas.", 5 )
                                end
                            elseif item == "scubagear" then
                                if not vCLIENT.checkScuba(source) then
                                    if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                        vCLIENT.setScuba(source, true)
                                    end
                                else
                                    TriggerClientEvent( "Notify", source, "negado", "Você ja possui uma scuba equipada, para retira-la /rscuba", 5 )
                                end
                            elseif item == "emptybottle" then
                                local status, style = vCLIENT.checkFountain(source)
                                if status then
                                    if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                        if style == "fountain" then
                                            vCLIENT.closeInventory(source)
                                            vRPclient._playAnim( source, false, {{"amb@prop_human_parking_meter@female@idle_a", "idle_a_female"}}, true )
                                        elseif style == "floor" then
                                            vCLIENT.closeInventory(source)
                                            vRPclient._playAnim( source, false, {{"amb@world_human_bum_wash@male@high@base", "base"}}, true )
                                        end

                                        TriggerClientEvent("progress", source, 10)
                                        vRP.blockCommands(user_id, 10)
                                        SetTimeout( 10000, function() vRP.giveInventoryItem(user_id, "water", 1, true) vRPclient._stopAnim(source, false) vCLIENT.updateInventory(source, "updateMochila") end )
                                    end
                                end
                            elseif item == "maconha" or item == "cocaina" or item == "lsd" or item == "heroina" or item == "metanfetamina" or item == "ecstasy" then
                                if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
                                    vRPclient._playAnim( source, true, {{"mp_player_int_uppersmoke", "mp_player_int_smoke"}}, true )
                                    SetTimeout( 10000, function() vRPclient._stopAnim(source, false) vRPclient._playScreenEffect(source, "RaceTurbo", 180) vRPclient._playScreenEffect(source, "DrugsTrevorClownsFight", 180) end )
                                end
                            elseif item == "body_armor" then
                                if vRP.tryGetInventoryItem(user_id, "body_armor", 1, true, slot) then
                                    vRPclient._setArmour(source, 100)
                                end
                            elseif item == "lockpick" then
								
                                local mPlaca,mName,mNet,mPortaMalas,mPrice,mLock,mModel = vRPclient.ModelName(source, 7)
                                local mPlacaUser = vRP.getUserByPlate(mPlaca)
                                local x, y, z = vRPclient.getPosition(source)

                                if mPlacaUser then
                                    if mLock then
                                        vCLIENT.closeInventory(source)

                                        Wait(1000)
                                        vCLIENT.startAnimHotwired(source)
                                        if vRP.tryGetInventoryItem(user_id, "lockpick", 1, true, slot) then
                                            local finished = vRPclient.taskBar(source, 2500, math.random(7, 15))
                                            if finished then
                                                local finished = vRPclient.taskBar(source, 1500, math.random(7, 15))
                                                if finished then
                                                    local finished = vRPclient.taskBar(source, 1000, math.random(7, 15))
                                                    if finished then 
                                                        TriggerEvent("nation:tryLockVehicle",mNet)
                                                        TriggerClientEvent("vrp_sound:source", source, "lock", 0.1)
                                                        TriggerClientEvent( "Notify", source, "negado", "Você destrancou o veiculo, cuidado a policia foi acionada.", 5 )
														vRP.sendLog("LOCKPICK", "**SUCESSO** O [ID: " .. user_id .. "] Roubou o veiculo " .. mModel .. "(ID:" .. mPlacaUser .. ") nas nas cordenadas: " .. x .. "," .. y .. "," .. z )
                                                    end
                                                end
                                            end
											 
											vPOLICE.sendAlertPolice(source, x, y, z, "Veiculo Roubado (" .. mModel .. " : " .. mPlaca .. ")", "Um novo registro de tentativa de roubo de veiculo, Modelo: ^2" .. mModel .. "^0 Placa: ^2" .. mPlaca)
                                            vRPclient._stopAnim(source, false)
                                            vCLIENT.updateInventory(source, "updateMochila")
                                        end
                                    else
                                        TriggerClientEvent( "Notify", source, "negado", "Este veiculo ja esta destracando.", 5 )
                                    end
                                else
                                    TriggerClientEvent( "Notify", source, "negado", "Este veiculo não pode ser roubado.", 5 )
                                end
                            elseif item == "repairkit" then
                                if not vRPclient.isInVehicle(source) then
                                    local vehicle = vRPclient.getNearestVehicle(source, 7)
									if vRP.tryGetInventoryItem(user_id, "repairkit", 1, true, slot) or vRP.hasPermission(user_id, "perm.bennys") then
										vRPclient._playAnim( source, false, {{"mini@repair", "fixing_a_player"}}, true )
										TriggerClientEvent("progress", source, 30)
										vRP.blockCommands(user_id, 35)
										SetTimeout(30000,function()
											TriggerClientEvent("reparar", source, vehicle)
											vRPclient._stopAnim(source, false)
											TriggerClientEvent( "Notify", source, "sucesso", "Você reparou o veiculo.", 5 )
										end)
									end
                                else
                                    TriggerClientEvent( "Notify", source, "negado", "Precisa estar próximo ou fora do veículo para efetuar os reparos.", 5 )
                                end

							elseif item == "capuz" then
								local nplayer = vRPclient.getNearestPlayer(source, 5)
								if nplayer then
									if vRPclient.isCapuz(nplayer) then
										vRPclient._setCapuz(nplayer, false)
										TriggerClientEvent( "Notify", source, "sucesso", "Você retirou o capuz desse jogador.", 5 )
									else
										vRPclient._setCapuz(nplayer, true)
										TriggerClientEvent( "Notify", source, "sucesso", "Você colocou o capuz nesse jogador, para retirar use o item novamente.", 5 )
									end
								else
									TriggerClientEvent( "Notify", source, "negado", "Nenhum jogador proximo.", 5 )
								end

							elseif item == "pneus" then
                                if not vRPclient.isInVehicle(source) then
                                    local vehicle = vRPclient.getNearestVehicle(source, 7)
									if vRP.tryGetInventoryItem(user_id, "pneus", 1, true, slot) then
										vRPclient._playAnim(source,false,{{"anim@amb@clubhouse@tutorial@bkr_tut_ig3@","machinic_loop_mechandplayer"}},true)
										TriggerClientEvent("progress", source, 30)
										vRP.blockCommands(user_id, 15)
										SetTimeout(10000,function()
												TriggerClientEvent('repararpneus',source,vehicle)
												vRPclient._stopAnim(source, false)
												TriggerClientEvent( "Notify", source, "sucesso", "Você reparou o pneu do veiculo.", 5 )
											end)
									end
                                else
                                    TriggerClientEvent( "Notify", source, "negado", "Precisa estar próximo ou fora do veículo para efetuar os reparos.", 5 )
                                end

								
                            elseif item == "algemas" then
                                local nplayer = vRPclient.getNearestPlayer(source, 3)
                                if nplayer then
                                    if not vRPclient.isHandcuffed(nplayer) then
                                        if vRP.tryGetInventoryItem(user_id, "algemas", 1, true, slot) then
                                            vRP.giveInventoryItem(user_id, "chave_algemas", 1, true)
                                            vCLIENT.arrastar(nplayer, source)
                                            vRPclient._playAnim( source, false, {{"mp_arrest_paired", "cop_p2_back_left"}}, false )
                                            vRPclient._playAnim( nplayer, false, {{"mp_arrest_paired", "crook_p2_back_left"}}, false )
                                            SetTimeout(3500,function()
                                                    vRPclient._stopAnim(source, false)
                                                    vRPclient._toggleHandcuff(nplayer)
                                                    vCLIENT._arrastar(nplayer, source)
                                                    TriggerClientEvent("vrp_sound:source", source, "cuff", 0.1)
                                                    TriggerClientEvent("vrp_sound:source", nplayer, "cuff", 0.1)
                                                    vRPclient._setHandcuffed(nplayer, true)
                                                end)
                                        else
                                            TriggerClientEvent( "Notify", source, "negado", "Você não possui algemas.", 5 )
                                        end
                                    end
                                else
                                    TriggerClientEvent("Notify", source, "negado", "Nenhum jogador proximo.", 5)
                                end
                            elseif item == "chave_algemas" then
                                local nplayer = vRPclient.getNearestPlayer(source, 3)
                                if nplayer then
                                    if vRPclient.isHandcuffed(source) then
                                        if vRP.tryGetInventoryItem(user_id, "chave_algemas", 1, true, slot) then
                                            vRP.giveInventoryItem(user_id, "algemas", 1, true)
                                            TriggerClientEvent("vrp_sound:source", source, "uncuff", 0.4)
                                            TriggerClientEvent("vrp_sound:source", nplayer, "uncuff", 0.4)
                                            vRPclient._setHandcuffed(nplayer, false)
                                        else
                                            TriggerClientEvent( "Notify", source, "negado", "Você não possui chave de algemas.", 5 )
                                        end
                                    end
                                else
                                    TriggerClientEvent("Notify", source, "negado", "Nenhum jogador proximo.", 5)
                                end
                            end
                        end

						if itemType == "usarVIP" then
							if item == "alterarplaca" then
								local vehicle = vRPclient.getNearestVehicle(source,4)
								local mPlaca,mName,mNetVeh = vRPclient.ModelName(source, 4)
								local PlacaID = vRP.getUserByPlate(mPlaca)

								if tonumber(PlacaID) == tonumber(user_id) then
									if mPlaca then
										vCLIENT.closeInventory(source)

										Wait(500)
										local placa = vRP.prompt(source, "Digite sua placa: (MAX 7) (EXEMPLO: THA0001)", "")
										if placa ~= nil and placa ~= "" and placa and string.len(placa) == 7 then
											if checkPlate(placa) then
												if vRP.request(source, "Tem certeza que deseja alterar a placa do seu veiculo para <b>"..placa.."</b> ?", 30) then
													if vRP.tryGetInventoryItem(user_id,item,1, true, slot) then
														TriggerClientEvent('deletarveiculo',source, vehicle)
														vRP.execute("vRP/update_plate",{ user_id = user_id, veiculo = mName, placa = placa })
														TriggerClientEvent("Notify",source,"sucesso","Você alterou a placa do seu veiculo para: <b> "..placa.." </b>.", 15)
													end
												end
											else
												TriggerClientEvent("Notify",source,"negado","Esta placa ja existe", 5)
											end
										else
											TriggerClientEvent("Notify",source,"negado","Digite a placa correta. (EXEMPLO: THA0001)", 5)
										end
									else
										TriggerClientEvent("Notify",source,"negado","Nenhum veiculo proximo.", 5)
									end
								else
									TriggerClientEvent("Notify",source,"negado","Este veiculo nao pertence a você", 5)
								end
							elseif item == "alterarrg" then
								vCLIENT.closeInventory(source)
								Wait(500)
								local numero = vRP.prompt(source, "Digite o numero: (MAX 6) (EXEMPLO: ABC123)", "")
								if numero ~= nil and numero ~= "" and numero and string.len(numero) == 6 then
									if checkRG(numero) then
										if vRP.request(source, "Tem certeza que deseja alterar seu rg para <b>"..numero.."</b> ?", 30) then
											if vRP.tryGetInventoryItem(user_id,item,1, true, slot) then
												vRP.updateIdentity(user_id)
												vRP.execute("vRP/update_registro",{ user_id = user_id, registro = numero })
												TriggerClientEvent("Notify",source,"sucesso","Você trocou o seu rg para <b>"..numero.."</b>, aguarde a cidade reiniciar para alteração ser feita.", 15)
											end
										end
									else
										TriggerClientEvent("Notify",source,"negado","Este rg ja existe.", 5)
									end
								else
									TriggerClientEvent("Notify",source,"negado","Digite o rg correto. (EXEMPLO: ABC123)", 5)
								end
							elseif item == "alterartelefone" then
								vCLIENT.closeInventory(source)
								Wait(500)
								local numero = vRP.prompt(source, "Digite o numero: (MAX 6) (EXEMPLO: 123456)", "")
								if tonumber(numero) ~= nil and numero ~= "" and tonumber(numero) and string.len(numero) == 6 then
									numero = formatNumber(numero)
									if checkNumber(numero) then
										if vRP.request(source, "Tem certeza que deseja alterar o numero de telefone para <b>"..numero.."</b> ?", 30) then
											if vRP.tryGetInventoryItem(user_id,item,1, true, slot) then
												vRP.execute("vRP/update_number",{ user_id = user_id, telefone = numero })
												TriggerClientEvent("Notify",source,"sucesso","Você trocou o numero de telefone para <b>"..numero.."</b>, aguarde a cidade reiniciar para alteração ser feita.", 15)
											end
										end
									else
										TriggerClientEvent("Notify",source,"negado","Este numero de telefone ja existe.", 5)
									end
								else
									TriggerClientEvent("Notify",source,"negado","Digite o numero de telefone correto. (EXEMPLO: 123456)", 5)
								end
							elseif item == "plastica" then
								if vRP.tryGetInventoryItem(user_id,item,1, true, slot) then
									vRP.execute("vRP/set_controller",{ user_id = user_id, controller = 0, rosto = "{}" })
									vRP.kick(user_id,"\n[THAY-LOJA] Você foi kickado \n entre novamente para fazer sua aparencia")
								end
							end
						end

						if itemType == "equipar" then
							actived[user_id] = 5
							if vRP.tryGetInventoryItem(user_id,item,1, true, slot) then
								local weapons = {}
								weapons[item] = { ammo = 0 }
								vRPclient._giveWeapons(source,weapons)

								vRP.sendLog("EQUIPAR", "O ID "..user_id.." equipou a arma "..vRP.getItemName(item)..".")
							end
						end

						if itemType == "recarregar" then
							actived[user_id] = 5
							local weapon = string.gsub(item, "AMMO_","WEAPON_")
							local municao = vRPclient.getAmmo(source, weapon)
							local maxMunicao = 250
							if vRPclient.checkWeapon(source, weapon) then
								if municao < 250 then
									if maxMunicao <= amount then
										maxMunicao = maxMunicao - municao
										amount = maxMunicao
									else
										maxMunicao = maxMunicao - municao
										if amount > maxMunicao then
											amount = maxMunicao
										end
									end
				
									if vRP.tryGetInventoryItem(user_id, item, amount, true, slot) then
										local weapons = {}
										weapons[weapon] = { ammo = amount }
										vRPclient._giveWeapons(source,weapons,false)

										vRP.sendLog("EQUIPAR", "O ID "..user_id.." recarregou a municao "..vRP.getItemName(item).." na quantidade de "..amount.." x.")
									end
								else
									TriggerClientEvent("Notify",source,"negado","Sua <b>"..vRP.getItemName(weapon).."</b> ja esta com seu maximo de munição", 5)
								end
							else
								TriggerClientEvent("Notify",source,"negado","Você precisa estar com a <b>"..vRP.getItemName(weapon).."</b> na mão para recarregar.", 5)
							end
						end

						if itemType == "beber" then
							actived[user_id] = 5
							local fome,sede = vRP.itemFood(item)
							if vRP.tryGetInventoryItem(user_id, item, amount, true, slot) then
								TriggerClientEvent("progress",source, 10*amount)
								play_drink(source, item, 10*amount)
								SetTimeout((10*amount)*1000, function()
									vRP.varyThirst(user_id, tonumber(sede)*amount)
									if item == "energetico" then
										TriggerClientEvent("Notify",source,"sucesso","Energetico utilizado com sucesso.", 5)
										vCLIENT.setEnergetico(source, true)
				
										SetTimeout(30*1000, function() 
											TriggerClientEvent("Notify",source,"negado","O Efeito do energetico acabou.", 5)
											vCLIENT.setEnergetico(source, false)
										end)
									elseif item == "water" then
										vRP.giveInventoryItem(user_id, "emptybottle", amount, true)
									end
								end)
							end
						end

						if itemType == "comer" then
							actived[user_id] = 5
							local fome,sede = vRP.itemFood(item)
							
							TriggerClientEvent("progress",source, 10*amount)
							play_eat(source, item, 10*amount)
				
							if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
								SetTimeout((10*amount), function() vRP.varyHunger(user_id, tonumber(fome)*amount) end)
							end
				
							vCLIENT.updateInventory(source)
							vCLIENT.updateDrop(source)
						end

						if itemType == "bebera" then
							actived[user_id] = 5
							local fome,sede = vRP.itemFood(item)
							actived[parseInt(user_id)] = 10*amount
							TriggerClientEvent("progress",source, 10*amount,"Bebendo")
							play_drink(source, item, 10*amount)
				
							if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
								SetTimeout(15*1000, function()
									vRPclient._playScreenEffect(source, "RaceTurbo", 60*amount)
									vRPclient._playScreenEffect(source, "DrugsTrevorClownsFight", 60*amount)
								end)
							end
						end

						if itemType == "remedio" then
							actived[user_id] = 5
							if item == "bandagem" then
								if vRP.tryGetInventoryItem(user_id, item, 1, true, slot) then
									vRPclient._CarregarObjeto(source,"amb@world_human_clipboard@male@idle_a","idle_c","v_ret_ta_firstaid",49,60309)

									TriggerClientEvent("progress",source, 15)
									SetTimeout(15*1000, function()
										vRPclient._DeletarObjeto(source)
										vCLIENT._useBandagem(source)
										TriggerClientEvent( "Notify", source, "importante", "Você utilizou a bandagem, não tome nenhum tipo de dano para não ser cancelada..", 5 )
									end)
									
								end
							end
						end

                        vCLIENT.updateInventory(source, "updateMochila")
                else
                    TriggerClientEvent( "Notify", source, "negado", "Aguarde <b>" .. actived[user_id] .. " segundo(s)</b> para utilizar isso novamente.", 5 )
                end
            end
        end
    end
end

function src.droparItem(slot,amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if actived[user_id] == nil then
			actived[user_id] = 2
			local inv = vRP.getInventory(user_id)
			if inv then
				if not inv[tostring(slot)] or inv[tostring(slot)].item == nil then
					return
				end

				local itemName = inv[tostring(slot)].item
				if vRP.tryGetInventoryItem(user_id,itemName, parseInt(amount), true, slot) then
					src.createDropItem(itemName,parseInt(amount),source)
					vCLIENT._updateInventory(source, "updateMochila")

					local nplayer = vRP.getNearestPlayer(source, 15)
					if nplayer then
						vCLIENT._updateInventory(nplayer, "updateMochila")
					end

					vRP.sendLog("DROPAR", "O ID "..user_id.." dropou o item "..vRP.getItemName(itemName).." na quantidade de "..amount.."x.")
				end
			end
		else
			TriggerClientEvent( "Notify", source, "negado", "Aguarde <b>" .. actived[user_id] .. " segundo(s)</b> para utilizar isso novamente.", 5 )
		end
	end
end

function src.pegarItem(id,slot,amount)
	local source = source
    local user_id = vRP.getUserId(source)
	if user_id then
		if actived[user_id] == nil then
			actived[user_id] = 2

			if droplist[id] == nil then
				return
			else
				if vRP.computeInvWeight(user_id)+vRP.getItemWeight(tostring(droplist[id].item))*parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
					if tostring(droplist[id].item) == "money" then
						vRP.giveInventoryItem(user_id,tostring(droplist[id].item),parseInt(amount), true, vRP.getItemInSlot(user_id, "money", slot))
					else
						vRP.giveInventoryItem(user_id,tostring(droplist[id].item),parseInt(amount), true, slot)
					end
					

					if droplist[id].count - amount >= 1 then 
						vCLIENT._removeDrop(-1, id)
						
						local newamount = droplist[id].count - amount
						src.createDropItem(droplist[id].item, newamount, source)

						droplist[id] = nil
						idgens:free(id)
					else
						vCLIENT._removeDrop(-1, id)
						droplist[id] = nil
						idgens:free(id)
					end
			
					vCLIENT.updateInventory(source, "updateMochila")
				else
					TriggerClientEvent( "Notify", source, "negado", "Mochila cheia.", 5 )
				end
			end
		else
			TriggerClientEvent( "Notify", source, "negado", "Aguarde <b>" .. actived[user_id] .. " segundo(s)</b> para utilizar isso novamente.", 5 )
		end
	end
end

function src.sendItem(item,slot,amount)
	local source = source
    local user_id = vRP.getUserId(source)
	if user_id then
		if actived[user_id] == nil then
			actived[user_id] = 2
			local nplayer = vRPclient.getNearestPlayer(source, 3)
			
			if nplayer then
				local nuser_id = vRP.getUserId(nplayer)
				if vRP.computeInvWeight(nuser_id)+vRP.getItemWeight(tostring(item))*parseInt(amount) <= vRP.getInventoryMaxWeight(nuser_id) then
					if vRP.tryGetInventoryItem(user_id, item, parseInt(amount), true, slot) then
						vRPclient._playAnim(source,true,{{"mp_common","givetake1_a"}},false)
						vRP.giveInventoryItem(nuser_id, item, parseInt(amount), true)
						vRPclient._playAnim(nplayer,true,{{"mp_common","givetake1_a"}},false)

						vRP.sendLog("ENVIAR", "O ID "..user_id.." enviou o item "..vRP.getItemName(item).." na quantidade de "..amount.."x para o id "..nuser_id..".")
					end
				else
					TriggerClientEvent( "Notify", source, "negado", "Mochila do jogador cheia.", 5 )
				end

				vCLIENT.updateInventory(nplayer, "updateMochila")
				vCLIENT.updateInventory(source, "updateMochila")
			else
				TriggerClientEvent( "Notify", source, "negado", "Nenhum jogador proximo.", 5 )
			end

		end
	end
end

function src.updateSlot(itemName, slot, target, targetName, targetamount, amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local firstItemAmount = vRP.getInventoryItemAmount(user_id, itemName)

		if amount == nil or amount <= 0 then 
			amount = 1 
		end

		if targetamount == nil or targetamount <= 0 then 
			targetamount = 1
		end

		local inv = vRP.getInventory(user_id)
		if inv then
			if targetName ~= nil then
				if itemName ~= targetName then
					if vRP.tryGetInventoryItem(user_id, itemName, firstItemAmount, false, slot) then
						if vRP.tryGetInventoryItem(user_id, targetName, targetamount, false, target) then 
							vRP.giveInventoryItem(user_id, itemName, firstItemAmount, false, target)
							vRP.giveInventoryItem(user_id, targetName, targetamount, false, slot)
						end
					end
				else
					if vRP.tryGetInventoryItem(user_id, itemName, amount, false, slot) then
						vRP.giveInventoryItem(user_id, itemName, amount, false, target)
					end
				end
			else
				if vRP.tryGetInventoryItem(user_id, itemName, amount, false, slot) then
					vRP.giveInventoryItem(user_id, itemName, amount, false, target)
				end
			end
		end
	end
end

function src.checkPermission(permission)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.hasPermission(user_id, permission) then
			return true
		end
	end
end

function src.checkConnected()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if GetPlayerPing(source) > 0 then
			return true
		else
			print("Troxa tentando dupar: "..user_id)
		end
	end
end

function checkPlate(plate)
	local rows = vRP.query("vRP/getPlate", {placa = plate} ) or nil
	if not rows[1] then
		return true
	end
end

function checkNumber(numero)
	local rows = vRP.query("vRP/getNumber", {telefone = numero} ) or nil
	if not rows[1] then
		return true
	end
end

function checkRG(numero)
	local rows = vRP.query("vRP/getRegistro", {registro = numero} ) or nil
	if not rows[1] then
		return true
	end
end

function formatNumber(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1-'):reverse())..right
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE INVENTARIO DE VEICULOS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local openedVehicle = {}
local dataVehicle = {}

function src.openVehicles(plate,mName)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	local mPlaca = string.gsub(plate, " ","")

	if user_id then
		if mPlaca and mName then
			local mNome,mPrice,mPortaMalas = vRPclient.getCar(source, mName)
			if openedVehicle[mPlaca] == user_id then

				local inv = vRP.getInventory(user_id)
				local myInventory = {}
				if inv then
					for k,v in pairs(inv) do
						if allItems[v["item"]] then
							v["amount"] = parseInt(v["amount"])
							v["name"] = allItems[v["item"]].name
							v["peso"] = allItems[v["item"]].weight
							v["index"] = allItems[v["item"]].tipo
							v["key"] = v["item"]
							v["slot"] = k
							myInventory[k] = v
						end
					end
				end

				if dataVehicle[mPlaca] == nil then
					local nuser_id = vRP.getUserByPlate(mPlaca)
					if nuser_id then
						local rows = vRP.query("vRP/get_portaMalas",{ user_id = parseInt(nuser_id), veiculo = string.lower(mName) }) or {}
						dataVehicle[mPlaca] = { json.decode(rows[1].portamalas) or {}, mName }
					else
						local rows = vRP.getSData("tmpChest:"..mName.."_"..mPlaca)
						dataVehicle[mPlaca] = { json.decode(rows) or {},mName }
					end
				end

				local myVehicle = {}
				for k,v in pairs(dataVehicle[mPlaca][1]) do
					v["amount"] = parseInt(v["amount"])
					v["name"] = allItems[v["item"]].name
					v["peso"] = allItems[v["item"]].weight
					v["index"] = allItems[v["item"]].tipo
					v["key"] = v["item"]
					v["slot"] = k

					myVehicle[k] = v
					SetTimeout(200, function() v["name"] = nil v["peso"] = nil v["index"] = nil v["key"] = nil v["slot"] = nil end)
				end 

				return myInventory,myVehicle,vRP.computeInvWeight(user_id),vRP.getInventoryMaxWeight(user_id),vRP.computeItemsWeight(myVehicle),mPortaMalas,{identity["nome"].." "..identity["sobrenome"],user_id}, { mPlaca,mNome }
			else
				vCLIENT.closeInventory(source)
			end
			
		end
	end
end

function src.colocarVehicle(item,amount,slot,mPlate,mName)
	local source = source
	local user_id = vRP.getUserId(source)
	local mPlaca = string.gsub(mPlate, " ","")

	if user_id and mPlaca then
		local mNome,mPrice,mPortaMalas = vRPclient.getCar(source, mName)
		if GetPlayerPing(source) > 0 then
			if openedVehicle[mPlaca] == user_id and dataVehicle[mPlaca][1] ~= nil then
				if vRP.computeItemsWeight(dataVehicle[mPlaca][1])+vRP.getItemWeight(item)*parseInt(amount) <= mPortaMalas then
					
					if vRP.tryGetInventoryItem(user_id, item, amount, true) then
						dataVehicle[mPlaca][1][tostring(slot)] =  { amount = amount, item = item }
					end

					vRP.sendLog("BAUCARRO", "** COLOCOU ** O ID "..user_id.." retirou o item "..vRP.getItemName(item).." na quantidade de "..amount.."x do veiculo ".. mName .." placa "..mPlaca.." ")
				else
					TriggerClientEvent( "Notify", source, "negado", "Porta malas cheio.", 5 )
				end
			else
				vCLIENT.closeInventory(source)
			end
		end
	end

end

function src.retirarVehicle(item,amount,slot,target,mPlate,mName)
	local source = source
	local user_id = vRP.getUserId(source)
	local mPlaca = string.gsub(mPlate, " ","")

	if user_id then
		if GetPlayerPing(source) > 0 then
			if openedVehicle[mPlaca] == user_id and dataVehicle[mPlaca][1][tostring(slot)].item ~= nil then
				if vRP.computeInvWeight(user_id)+vRP.getItemWeight(tostring(dataVehicle[mPlaca][1][tostring(slot)].item))*parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
					if item == "money" then
						vRP.giveInventoryItem(user_id, dataVehicle[mPlaca][1][tostring(slot)].item, amount, true, vRP.getItemInSlot(user_id, "money", target))
					else
						vRP.giveInventoryItem(user_id, dataVehicle[mPlaca][1][tostring(slot)].item, amount, true, target)
					end

					dataVehicle[mPlaca][1][tostring(slot)].amount = dataVehicle[mPlaca][1][tostring(slot)].amount - amount
					if dataVehicle[mPlaca][1][tostring(slot)].amount <= 0 then
						dataVehicle[mPlaca][1][tostring(slot)] = nil
					end

					vRP.sendLog("BAUCARRO", "** RETIRAR ** O ID "..user_id.." retirou o item "..vRP.getItemName(item).." na quantidade de "..amount.."x do veiculo ".. mName .." placa "..mPlaca.." ")
				else
					TriggerClientEvent( "Notify", source, "negado", "Mochila cheia.", 5 )
				end
			else
				vCLIENT.closeInventory(source)
			end
		end
	end
	
end

function src.updateVehicleSlots(itemName, slot, target, targetName, targetamount, amount, mPlate, mName)
	local source = source
	local user_id = vRP.getUserId(source)
	local mPlaca = string.gsub(mPlate, " ","")

	if user_id and mPlaca then
		if openedVehicle[mPlaca] == user_id then
			if amount == nil or amount <= 0 then 
				amount = 1 
			end

			if targetamount == nil or targetamount <= 0 then 
				targetamount = 1
			end

			if itemName ~= targetName then
				dataVehicle[mPlaca][1][tostring(slot)].amount = dataVehicle[mPlaca][1][tostring(slot)].amount - amount
				dataVehicle[mPlaca][1][tostring(target)] = { amount = amount, item = itemName }

				if itemName and targetName then
					dataVehicle[mPlaca][1][tostring(slot)] = { amount = targetamount, item = targetName }
				end

				if dataVehicle[mPlaca][1][tostring(slot)].amount <= 0 then
					dataVehicle[mPlaca][1][tostring(slot)] = nil
				end

				if dataVehicle[mPlaca][1][tostring(target)].amount <= 0 then
					dataVehicle[mPlaca][1][tostring(target)] = nil
				end
				
			else
				dataVehicle[mPlaca][1][tostring(slot)].amount = dataVehicle[mPlaca][1][tostring(slot)].amount - amount
				dataVehicle[mPlaca][1][tostring(target)].amount = dataVehicle[mPlaca][1][tostring(target)].amount + amount

				if dataVehicle[mPlaca][1][tostring(slot)].amount <= 0 then
					dataVehicle[mPlaca][1][tostring(slot)] = nil
				end

				if dataVehicle[mPlaca][1][tostring(target)].amount <= 0 then
					dataVehicle[mPlaca][1][tostring(target)] = nil
				end
			end
		else
			vCLIENT.closeInventory(source)
		end

	end
end

function src.checkVehicleOpen(plate)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local mPlaca = string.gsub(plate, " ","")
		if openedVehicle[mPlaca] == nil then
			return true
		else
			TriggerClientEvent("Notify",source,"negado","Este porta malas ja esta sendo utilizado por outra pessoa.", 3)
		end
	end
end

function src.setVehicleOpen(plate, status)
	local source = source
	local user_id = vRP.getUserId(source)
	local mPlaca = string.gsub(plate, " ","")
	if user_id then
		if status then
			openedVehicle[mPlaca] = user_id
		else
			openedVehicle[mPlaca] = nil
		end
	end
end

function save_vehicles_chest()
	local count = 0

	for k,v in pairs(dataVehicle) do
		local nuser_id = vRP.getUserByPlate(k)
		if nuser_id then
			if openedVehicle[k] == nil then
				vRP.execute("vRP/update_portaMalas",{ user_id = nuser_id, veiculo = v[2], portamalas = json.encode(dataVehicle[k][1]) })
				dataVehicle[k] = nil
				count = count + 1
			end
		else
			if openedVehicle[k] == nil then
				vRP.setSData("tmpChest:"..v[2].."_"..k, json.encode(dataVehicle[k][1]))
				dataVehicle[k] = nil
				count = count + 1
			end
		end
	end

	if count > 0 then
		print("^1[INVENTARIO] ^0Total de porta malas salvo(s): ^1"..count)
	end

	SetTimeout(20*1000,save_vehicles_chest)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE INVENTARIO DE FACTOPMS
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local openedOrg = {}
local dataOrgChest = {}

function src.openOrgChest(id,org,maxbau)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		if openedOrg[org] == user_id then

			local inv = vRP.getInventory(user_id)
			local myInventory = {}
			if inv then
				for k,v in pairs(inv) do
					if allItems[v["item"]] then
						if v.amount > 0 then
							v["amount"] = parseInt(v["amount"])
							v["name"] = allItems[v["item"]].name
							v["peso"] = allItems[v["item"]].weight
							v["index"] = allItems[v["item"]].tipo
							v["key"] = v["item"]
							v["slot"] = k

							myInventory[k] = v
						end
					end
				end
			end

			if dataOrgChest[org] == nil then
				local rows = vRP.query("vRP/get_factions", { faction = org })
				dataOrgChest[org] = { json.decode(rows[1].bau) or {} }
			end

			local myOrgChest = {}
			for k,v in pairs(dataOrgChest[org][1]) do
				if v.amount > 0 then
					if allItems[v["item"]] then
						v["amount"] = parseInt(v["amount"])
						v["name"] = allItems[v["item"]].name
						v["peso"] = allItems[v["item"]].weight
						v["index"] = allItems[v["item"]].tipo
						v["key"] = v["item"]
						v["slot"] = k
						
						myOrgChest[k] = v
						SetTimeout(200, function() v["name"] = nil v["peso"] = nil v["index"] = nil v["key"] = nil v["slot"] = nil end)
					end
				end
			end 

			return myInventory,myOrgChest,vRP.computeInvWeight(user_id),vRP.getInventoryMaxWeight(user_id),vRP.computeItemsWeight(myOrgChest),maxbau,{identity["nome"].." "..identity["sobrenome"],user_id}, { id,org }
		else
			vCLIENT.closeInventory(source)
		end
	end
end

function src.colocarOrgChest(item,amount,slot, org, maxBau, id)
	local source = source
	local user_id = vRP.getUserId(source)

	if user_id and org then
		if openedOrg[org] == user_id then
			if vRP.computeItemsWeight(dataOrgChest[org][1])+vRP.getItemWeight(item)*parseInt(amount) <= maxBau then
				if vRP.tryGetInventoryItem(user_id, item, amount, true) then
					dataOrgChest[org][1][tostring(slot)] =  { amount = amount, item = item }

					if cfg.chestOrgs[id] then
						if cfg.chestOrgs[id].weebhook ~= nil then
							vRP.sendLog(cfg.chestOrgs[id].weebhook, "```css\n["..org.."]\n"..os.date("[%d/%m/%Y] [%X]").." O (ID: "..user_id..") colocou o item ("..vRP.getItemName(item).. " " ..amount.."x)```")
						end
					end
				end
			else
				TriggerClientEvent( "Notify", source, "negado", "Bau cheio.", 5 )
			end
		else
			vCLIENT.closeInventory(source)
		end
	end

end

function src.retirarOrgChest(item,amount,slot,target, org, id)
	local source = source
	local user_id = vRP.getUserId(source)

	if user_id then
		if openedOrg[org] == user_id then
			if vRP.computeInvWeight(user_id)+vRP.getItemWeight(tostring(dataOrgChest[org][1][tostring(slot)].item))*parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
				if item == "money" then
					vRP.giveInventoryItem(user_id, dataOrgChest[org][1][tostring(slot)].item, amount, true, vRP.getItemInSlot(user_id, "money", target))
				else
					vRP.giveInventoryItem(user_id, dataOrgChest[org][1][tostring(slot)].item, amount, true, target)
				end

				dataOrgChest[org][1][tostring(slot)].amount = dataOrgChest[org][1][tostring(slot)].amount - amount
				if dataOrgChest[org][1][tostring(slot)].amount <= 0 then
					dataOrgChest[org][1][tostring(slot)] = nil
				end

				if cfg.chestOrgs[id] then
					if cfg.chestOrgs[id].weebhook ~= nil then
						vRP.sendLog(cfg.chestOrgs[id].weebhook, "```css\n["..org.."]\n"..os.date("[%d/%m/%Y] [%X]").." O (ID: "..user_id..") retirou o item ("..vRP.getItemName(item).. " " ..amount.."x)```")
					end
				end
			else
				TriggerClientEvent( "Notify", source, "negado", "Mochila cheia.", 5 )
			end
		else
			vCLIENT.closeInventory(source)
		end
	end
	
end

function src.updateOrgSlots(itemName, slot, target, targetName, targetamount, amount, org)
	local source = source
	local user_id = vRP.getUserId(source)

	if user_id and org then
		if openedOrg[org] == user_id then
			if amount == nil or amount <= 0 then 
				amount = 1 
			end

			if targetamount == nil or targetamount <= 0 then 
				targetamount = 1
			end

			if itemName ~= targetName then
				dataOrgChest[org][1][tostring(slot)].amount = dataOrgChest[org][1][tostring(slot)].amount - amount
				dataOrgChest[org][1][tostring(target)] = { amount = amount, item = itemName }

				if itemName and targetName then
					dataOrgChest[org][1][tostring(slot)] = { amount = targetamount, item = targetName }
				end

				if dataOrgChest[org][1][tostring(slot)].amount <= 0 then
					dataOrgChest[org][1][tostring(slot)] = nil
				end

				if dataOrgChest[org][1][tostring(target)].amount <= 0 then
					dataOrgChest[org][1][tostring(target)] = nil
				end
				
			else
				dataOrgChest[org][1][tostring(slot)].amount = dataOrgChest[org][1][tostring(slot)].amount - amount
				dataOrgChest[org][1][tostring(target)].amount = dataOrgChest[org][1][tostring(target)].amount + amount

				if dataOrgChest[org][1][tostring(slot)].amount <= 0 then
					dataOrgChest[org][1][tostring(slot)] = nil
				end

				if dataOrgChest[org][1][tostring(target)].amount <= 0 then
					dataOrgChest[org][1][tostring(target)] = nil
				end
			end

		else
			vCLIENT.closeInventory(source)
		end
	end
end

function src.checkOrgOpen(org)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if openedOrg[org] == nil then
			return true
		else
			TriggerClientEvent("Notify",source,"negado","Este bau ja esta sendo utilizado por outra pessoa.", 3)
		end
	end
end

function src.setOrgOpen(org, status)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if status then
			openedOrg[org] = user_id
		else
			openedOrg[org] = nil
		end
	end
end

function save_org_chest()
	local count = 0
	for k,v in pairs(dataOrgChest) do
		if openedOrg[k] == nil then
			vRP.execute("vRP/update_chest_factions",{ faction = k, bau = json.encode(dataOrgChest[k][1]) })
			dataOrgChest[k] = nil
			count = count + 1
		end
	end

	if count > 0 then
		print("^1[INVENTARIO] ^0Total de bau de organizacao salvo(s): ^1"..count)
	end

	SetTimeout(20*1000,save_org_chest)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NUIS CALLBACKS INVENTARIO HOUSE
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local openedHouseChest = {}
local dataHouseChest = {}

function src.openHouseChest(id, houseID, maxBau)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		if openedHouseChest[id] == user_id then
			local inv = vRP.getInventory(user_id)
			local myInventory = {}
			if inv then
				for k,v in pairs(inv) do
					if allItems[v["item"]] then
						v["amount"] = parseInt(v["amount"])
						v["name"] = allItems[v["item"]].name
						v["peso"] = allItems[v["item"]].weight
						v["index"] = allItems[v["item"]].tipo
						v["key"] = v["item"]
						v["slot"] = k

						myInventory[k] = v
					end
				end
			end

			if dataHouseChest[id] == nil then
				local rows = vRP.query("mirtin/allInfoHome", { id = id })
				dataHouseChest[id] = { json.decode(rows[1].bau) or {}, houseID, maxBau }
			end

			local myHouseChest = {}
			for k,v in pairs(dataHouseChest[id][1]) do
				v["amount"] = parseInt(v["amount"])
				v["name"] = allItems[v["item"]].name
				v["peso"] = allItems[v["item"]].weight
				v["index"] = allItems[v["item"]].tipo
				v["key"] = v["item"]
				v["slot"] = k
				
				myHouseChest[k] = v
				SetTimeout(200, function() v["name"] = nil v["peso"] = nil v["index"] = nil v["key"] = nil v["slot"] = nil end)
			end 

			return myInventory,myHouseChest,vRP.computeInvWeight(user_id),vRP.getInventoryMaxWeight(user_id),vRP.computeItemsWeight(myHouseChest),dataHouseChest[id][3] + 0.0,{identity["nome"].." "..identity["sobrenome"],user_id}, { houseID }
		else
			TriggerClientEvent("Notify",source,"negado","Este bau ja esta sendo utilizado por outra pessoa.", 3)
			vCLIENT.closeInventory(source)
		end
	end
end

function src.colocarHousehest(item,amount,slot, id)
	local source = source
	local user_id = vRP.getUserId(source)

	if user_id and id then
		if openedHouseChest[id] == user_id or vRP.hasPermission(user_id, "admin.permissao") then
			if vRP.computeItemsWeight(dataHouseChest[id][1])+vRP.getItemWeight(item)*parseInt(amount) <= dataHouseChest[id][3] + 0.0 then
				if vRP.tryGetInventoryItem(user_id, item, amount, true) then
					dataHouseChest[id][1][tostring(slot)] =  { amount = amount, item = item }
				end

				vRP.sendLog("BAUCASAS", "** COLOCOU ** O ID "..user_id.." colocou o item "..vRP.getItemName(item).." na quantidade de "..amount.."x da propriedade "..dataHouseChest[id][2].." ")
			else
				TriggerClientEvent( "Notify", source, "negado", "Bau cheio.", 5 )
			end
		else
			vCLIENT.closeInventory(source)
		end
	end

end

function src.retirarHouseChest(item,amount,slot,target, id)
	local source = source
	local user_id = vRP.getUserId(source)

	if user_id then
		if openedHouseChest[id] == user_id or vRP.hasPermission(user_id, "admin.permissao") then
			if vRP.computeInvWeight(user_id)+vRP.getItemWeight(tostring(dataHouseChest[id][1][tostring(slot)].item))*parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
				if item == "money" then
					vRP.giveInventoryItem(user_id, dataHouseChest[id][1][tostring(slot)].item, amount, true, vRP.getItemInSlot(user_id, "money", target))
				else
					vRP.giveInventoryItem(user_id, dataHouseChest[id][1][tostring(slot)].item, amount, true, target)
				end

				dataHouseChest[id][1][tostring(slot)].amount = dataHouseChest[id][1][tostring(slot)].amount - amount
				if dataHouseChest[id][1][tostring(slot)].amount <= 0 then
					dataHouseChest[id][1][tostring(slot)] = nil
				end

				vRP.sendLog("BAUCASAS", "** RETIRAR ** O ID "..user_id.." retirou o item "..vRP.getItemName(item).." na quantidade de "..amount.."x da propriedade "..dataHouseChest[id][2].." ")
			else
				TriggerClientEvent( "Notify", source, "negado", "Mochila cheia.", 5 )
			end
		else
			vCLIENT.closeInventory(source)
		end
	end
	
end

function src.updateHouseSlots(itemName, slot, target, targetName, targetamount, amount, id)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id and id then
		if openedHouseChest[id] == user_id or vRP.hasPermission(user_id, "admin.permissao") then
			if amount == nil or amount <= 0 then 
				amount = 1 
			end

			if targetamount == nil or targetamount <= 0 then 
				targetamount = 1
			end

			if itemName ~= targetName then
				dataHouseChest[id][1][tostring(slot)].amount = dataHouseChest[id][1][tostring(slot)].amount - amount
				dataHouseChest[id][1][tostring(target)] = { amount = amount, item = itemName }

				if itemName and targetName then
					dataHouseChest[id][1][tostring(slot)] = { amount = targetamount, item = targetName }
				end

				if dataHouseChest[id][1][tostring(slot)].amount <= 0 then
					dataHouseChest[id][1][tostring(slot)] = nil
				end

				if dataHouseChest[id][1][tostring(target)].amount <= 0 then
					dataHouseChest[id][1][tostring(target)] = nil
				end
				
			else
				dataHouseChest[id][1][tostring(slot)].amount = dataHouseChest[id][1][tostring(slot)].amount - amount
				dataHouseChest[id][1][tostring(target)].amount = dataHouseChest[id][1][tostring(target)].amount + amount

				if dataHouseChest[id][1][tostring(slot)].amount <= 0 then
					dataHouseChest[id][1][tostring(slot)] = nil
				end

				if dataHouseChest[id][1][tostring(target)].amount <= 0 then
					dataHouseChest[id][1][tostring(target)] = nil
				end
			end
		else
			vCLIENT.closeInventory(source)
		end
	end
end

function src.checkHouseChest(id)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if openedHouseChest[id] == nil then
			return true
		else
			TriggerClientEvent("Notify",source,"negado","Este bau ja esta sendo utilizado por outra pessoa.", 3)
		end
	end
end

function src.setHouseChest(id, status)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if status then
			openedHouseChest[id] = user_id
		else
			openedHouseChest[id] = nil
		end
	end
end

function save_house_chest()
	local count = 0
	for k,v in pairs(dataHouseChest) do
		if openedHouseChest[k] == nil then
			vRP.execute("mirtin/updateBau", { id = k, bau = json.encode(dataHouseChest[k][1])} )
			dataHouseChest[k] = nil
			count = count + 1
		end
	end

	if count > 0 then
		print("^1[INVENTARIO] ^0Total de bau de casas salvo(s): ^1"..count)
	end

	SetTimeout(20*1000,save_house_chest)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE INVENTARIO REVISTAR
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local openedRevistar = {}

function src.openRevistar(nuser_id)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	local nplayer = vRP.getUserSource(parseInt(nuser_id))
	if user_id then
		if nplayer then
			if openedRevistar[nuser_id] == user_id then
				local identity2 = vRP.getUserIdentity(nuser_id)

				local inv = vRP.getInventory(user_id)
				local myInventory = {}
				if inv then
					for k,v in pairs(inv) do
						if allItems[v["item"]] then
							v["amount"] = parseInt(v["amount"])
							v["name"] = allItems[v["item"]].name
							v["peso"] = allItems[v["item"]].weight
							v["index"] = allItems[v["item"]].tipo
							v["key"] = v["item"]
							v["slot"] = k

							myInventory[k] = v
						end
					end
				end

				local inv2 = vRP.getInventory(nuser_id)
				local myHouseChest = {}
				for k,v in pairs(inv2) do
					if allItems[v["item"]] then
						v["amount"] = parseInt(v["amount"])
						v["name"] = allItems[v["item"]].name
						v["peso"] = allItems[v["item"]].weight
						v["index"] = allItems[v["item"]].tipo
						v["key"] = v["item"]
						v["slot"] = k
						
						myHouseChest[k] = v
						SetTimeout(200, function() v["name"] = nil v["peso"] = nil v["index"] = nil v["key"] = nil v["slot"] = nil end)
					end
				end 
				return myInventory,myHouseChest,vRP.computeInvWeight(user_id),vRP.getInventoryMaxWeight(user_id),vRP.computeItemsWeight(myHouseChest),vRP.getInventoryMaxWeight(nuser_id),{identity["nome"].." "..identity["sobrenome"],user_id}, { identity2.nome, identity2.sobrenome, nuser_id }
			else
				vCLIENT.closeInventory(source)
			end
		

		end
	end
end

function src.checkOpenRevistar()
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		local nplayer = vRPclient.getNearestPlayer(source, 5)
		local nuser_id = vRP.getUserId(nplayer)
		if nplayer then
			
			if arena.inArena(source) or arena.inArena(nplayer) then
				return
			end
			
			if vRP.hasPermission(nuser_id, "perm.policia") and vRP.checkPatrulhamento(nuser_id) then
				TriggerClientEvent("Notify",source,"negado","Você não pode saquear um policia em patrulhamento.", 3)
				return
			end

			if openedRevistar[nuser_id] == nil then
				if vCLIENT.checkAnim(nplayer) or vRPclient.isInComa(nplayer) or vRPclient.isHandcuffed(nplayer) then
					TriggerClientEvent("Notify",source,"sucesso","Iniciando revista...", 3)
					TriggerClientEvent("Notify",nplayer,"negado","Você está sendo revistado...", 3)
	
					local weapons = vRPclient.replaceWeapons(nplayer,{})
					for k,v in pairs(weapons) do
							vRP.giveInventoryItem(nuser_id, k, 1, true)
						if v.ammo > 0 then
							local weapon = string.gsub(k, "WEAPON_","AMMO_")
							vRP.giveInventoryItem(nuser_id, weapon, v.ammo, true)
						end
					end
					
					vCLIENT.updateWeapons(nplayer)
					vCLIENT.closeInventory(nplayer)
					revistando(source,user_id, nplayer, nuser_id)

					return nuser_id
				else
					TriggerClientEvent("Notify",source,"negado","O jogador precisa estar em coma ou rendido.", 3)
				end
			else
				TriggerClientEvent("Notify",source,"negado","Este jogador ja esta sendo revistado por outra pessoa.", 3)
			end
		end

		return false
	end
end

function src.setRevistar(id, status)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if status then
			openedRevistar[id] = user_id
		else
			openedRevistar[id] = nil
		end
	end
end

function src.retirarItemRevistar(id, item, target, amount, slot)
	local source = source
	local user_id = vRP.getUserId(source)
	local nplayer = vRP.getUserSource(id)
	if user_id then
		if nplayer then
			if openedRevistar[id] == user_id then
				if vRP.computeInvWeight(user_id)+vRP.getItemWeight(tostring(item))*parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
					if vRP.tryGetInventoryItem(id, item, amount, true, slot) then
						if item == "money" then
							vRP.giveInventoryItem(user_id, item, amount, true, vRP.getItemInSlot(user_id, "money", target))
						else
							vRP.giveInventoryItem(user_id, item, amount, true, target)
						end

						vRP.sendLog("SAQUEAR", "O ID "..user_id.." saqueou o item "..vRP.getItemName(item).." na quantidade "..amount.."x do ID "..id..".")
					end
				else
					TriggerClientEvent( "Notify", source, "negado", "Mochila cheia.", 5 )
				end
			else
				vCLIENT.closeInventory(source)
			end
		end
	end
end

function revistando(source,user_id, nplayer,nuser_id)
	async(function()
		while true do
			if openedRevistar[nuser_id] == user_id then
				local x,y,z = vRPclient.getPosition(source)
				local nx,ny,nz = vRPclient.getPosition(nplayer)
				if vCLIENT.checkPositions(source, vec3(x,y,z), vec3(nx,ny,nz)) then
					openedRevistar[nuser_id] = nil
					vCLIENT.closeInventory(source)
					vCLIENT.closeInventory(nplayer)
					TriggerClientEvent("Notify",source,"negado","Você se afastou muito do jogador e a revista foi cancelada..", 3)
				end
			end

			Citizen.Wait(1000)
		end
	end)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- NUIS CALLBACKS STORES
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.openStore(id)
	local source = source
	local user_id = vRP.getUserId(source)
	local identity = vRP.getUserIdentity(user_id)
	if user_id then
		local inv = vRP.getInventory(user_id)
		local myInventory = {}
		if inv then
			for k,v in pairs(inv) do
				if (parseInt(v["amount"]) <= 0 or allItems[v.item] == nil) then
					vRP.removeInventoryItem(user_id,v.item,parseInt(v["amount"]))
				else
					v["amount"] = parseInt(v["amount"])
					v["name"] = allItems[v["item"]].name
					v["peso"] = allItems[v["item"]].weight
					v["index"] = allItems[v["item"]].tipo
					v["key"] = v["item"]
					v["slot"] = k

					myInventory[k] = v
				end
			end
		end

		if cfg.stores[id] then
			local items = cfg.stores[id].items
			local myStore = {}
			for k,v in pairs(items) do
				v["name"] = allItems[v.item].name
				v["buyPrice"] = v.priceBuy
				v["sellPrice"] = v.priceSell
				v["key"] = v.item

				myStore[v.slot] = v
			end

			return myInventory,myStore,vRP.computeInvWeight(user_id),vRP.getInventoryMaxWeight(user_id),0,9999,{identity["nome"].." "..identity["sobrenome"],user_id}, { id }
		end

	end
end

function src.buyStore(id, item, target, amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if cfg.stores[id] then
			local items = cfg.stores[id].items
			if items ~= nil and items[item].priceBuy ~= nil then
				if vRP.computeInvWeight(user_id)+vRP.getItemWeight(tostring(item))*parseInt(amount) <= vRP.getInventoryMaxWeight(user_id) then
					if parseInt(items[item].priceBuy) == 0 or vRP.tryPayment(user_id, parseInt(items[item].priceBuy)*amount) then
						vRP.giveInventoryItem(user_id, item, amount, true, target)
						
						if parseInt(items[item].priceBuy)*amount > 0 then
							TriggerClientEvent( "Notify", source, "sucesso", "Você pagou <b>$ "..vRP.format(parseInt(items[item].priceBuy)*amount).."</b>.", 5 )
						end

						vCLIENT.updateInventory(source, "updateStore")
					else
						TriggerClientEvent( "Notify", source, "negado", "Você não possui dinheiro.", 5 )
					end
				else
					TriggerClientEvent( "Notify", source, "negado", "Mochila cheia.", 5 )
				end
			end
		end
	end
end

function src.sellStore(id, item, amount)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if cfg.stores[id] then
			local items = cfg.stores[id].items
			local bonus = cfg.stores[id].bonus
			local dinheiro = cfg.stores[id].money
			
			if dinheiro == "limpo" then dinheiro = "money" elseif dinheiro == "sujo" then dinheiro = "dirty_money" else return end
			if item and items[item] and items[item].sellPrice ~= nil then 
				if vRP.tryGetInventoryItem(user_id, item, amount) then
					if bonus then
						vRP.giveInventoryItem(user_id, dinheiro, vRP.formatBonus(user_id, parseInt(items[item].sellPrice)*amount), true)
					else
						vRP.giveInventoryItem(user_id, dinheiro, parseInt(items[item].sellPrice)*amount, true)
					end
	
					vCLIENT.updateInventory(source, "updateStore")
				else
					TriggerClientEvent( "Notify", source, "negado", "Você não possui dinheiro.", 5 )
				end
			 end
			 
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE DROPAR DROPAR ITEM
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function src.createDropItem(item,count,source)
    local id = idgens:gen()
    local x,y,z = table.unpack(GetEntityCoords(GetPlayerPed(source)))
    droplist[id] = { item = item, count = count, x = x, y = y, z = z, name = vRP.getItemName(item), key = item, index = vRP.getItemType(item), peso = vRP.getItemWeight(item) }
	vCLIENT.updateDrops(-1,id,droplist[id]) 

	local nplayer = vRP.getNearestPlayer(source, 15)
	if nplayer then
		vCLIENT.updateInventory(nplayer, "updateMochila")
	end
end

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES DE UTILIZAÇÃO DE ITENS INVENTARIO
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function play_eat(source, tipo, segundos)
	local prop = ""
	-- COMIDAS
	if tipo == "pao" then
		prop = "prop_food_burg2"
	elseif tipo == "sanduiche" then
		prop = "prop_cs_burger_01"
	elseif tipo == "pizza" then
		prop = "prop_taco_01"
	elseif tipo == "barrac" then
		prop = "prop_choc_meto"
	elseif tipo == "cachorroq" then
		prop = "prop_cs_hotdog_01"
	elseif tipo == "pipoca" then
		prop = "ng_proc_food_chips01b"
	elseif tipo == "donut" then
		prop = "prop_amb_donut"
	elseif tipo == "paoq" then
		prop = "prop_food_cb_nugets"
	elseif tipo == "marmita" then
		prop = "prop_taco_01"
	elseif tipo == "coxinha" then
		prop = "prop_food_cb_nugets"
	else
		prop = "prop_cs_burger_01"
	end

	vRPclient._CarregarObjeto(source,"amb@code_human_wander_eating_donut@male@idle_a","idle_c",prop,49,28422)
	SetTimeout(segundos*1000, function() vRPclient._DeletarObjeto(source) end)
end

function play_drink(source, tipo, segundos)
	local prop = ""
	-- BEBIDAS
	if tipo == "energetico" then
		prop = "prop_energy_drink"
	elseif tipo == "water" then
		prop = "prop_ld_flow_bottle"
	elseif tipo == "cafe" then
		prop = "prop_fib_coffee"
	elseif tipo == "cocacola" then
		prop = "ng_proc_sodacan_01a"
	elseif tipo == "sucol" then
		prop = "ng_proc_sodacan_01b"
	elseif tipo == "sucol2" then
		prop = "ng_proc_sodacan_01b"
	elseif tipo == "sprunk"then
		prop = "ng_proc_sodacan_01b"

	-- BEBIDAS ALCOLICAS
	elseif tipo == "cerveja" then
		prop = "prop_amb_beer_bottle"
	elseif tipo == "whisky" then
		prop = "prop_drink_whisky"
	elseif tipo == "vodka" then
		prop = "p_whiskey_notop" 
	elseif tipo == "royalsalute" then
		prop = "prop_drink_whisky"
	elseif tipo == "corote" then
		prop = "ng_proc_sodacan_01b"
	elseif tipo == "absinto" then
		prop = "prop_drink_whisky"
	elseif tipo == "skolb" then
		prop = "ng_proc_sodacan_01b"
	else
		prop = "prop_ld_flow_bottle"
	end
	
	vRPclient._CarregarObjeto(source,"amb@world_human_drinking@beer@male@idle_a","idle_a",prop,49,28422)
    SetTimeout(segundos*1000, function() vRPclient._DeletarObjeto(source) end)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMANDOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand("vaultadm",function(source,args)
	local source = source
	local user_id = vRP.getUserId(source)
	if user_id then
		if vRP.hasPermission(user_id, "admin.permissao") then
			if tonumber(args[1]) and tonumber(args[1]) > 0 then
				vCLIENT.openSelectedChest(source, "houseChest", tonumber(args[1]))
				vRP.sendLog("HOUSEADMCHEST", "```css\n O Admin "..user_id.." acessou o bau da propriedade ID: "..tonumber(args[1]).. "```")
			end
		end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- COMANDOS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterCommand('rscuba', function(source,args)
	local user_id = vRP.getUserId(source)
    if user_id then
        local ok = vRP.request(source, "Você deseja retirar a sua scuba?", 30)
        if ok and not vRPclient.isInComa(source) and not actived[user_id] and actived[user_id] == nil then
            actived[parseInt(user_id)] = 5
            if vCLIENT.checkScuba(source) then
                vCLIENT.setScuba(source, false)
                TriggerClientEvent("Notify",source,"negado","Você retirou sua scuba, não conseguimos recuperar ela houve um vazamento.", 5)
            else
                TriggerClientEvent("Notify",source,"negado","Você não possui scuba equipada.", 5)
            end
        end
	end
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("tryreparar")
AddEventHandler("tryreparar",function(nveh)
	TriggerClientEvent("syncreparar",-1,nveh)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- REPARAR PNEUS
-----------------------------------------------------------------------------------------------------------------------------------------
RegisterServerEvent("tryrepararpneus")
AddEventHandler("tryrepararpneus",function(nveh)
	TriggerClientEvent("syncrepararpneus",-1,nveh)
end)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- FUNCTIONS
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		if actived then
			for k,v in pairs(actived) do
				if actived[k] > 0 then
					actived[k] = actived[k] - 1

					if actived[k] == 0 then
						actived[k] = nil
					end
				end
			end
		end
		Citizen.Wait(1000)
	end
end)

Citizen.CreateThread(function()
	local rows = vRP.query("vRP/inv_tmpchest",{})
	if #rows > 0 then
		print("^1[INVENTARIO] ^0Bau de veiculos temporario deletado(s): ^1"..#rows)
		vRP.execute("vRP/inv_deltmpchest",{})
	end
end)

async(function()
	allItems = vRP.getAllItens()

	save_org_chest()
	save_vehicles_chest()
	save_house_chest()
end)

AddEventHandler("vRP:playerLeave",function(user_id,source)
	if user_id then 
		for k,v in pairs(openedOrg) do
			if openedOrg[k] == user_id then
				openedOrg[k] = nil
				print("(ID: "..user_id.. ") Crashou com Bau da Organização aberto.")
			end
		end

		for k,v in pairs(openedVehicle) do
			if openedVehicle[k] == user_id then
				openedVehicle[k] = nil
				print("(ID: "..user_id.. ") Crashou com Bau do Carro aberto.")
			end
		end

		for k,v in pairs(openedHouseChest) do
			if openedHouseChest[k] == user_id then
				save_house_chest()
				print("(ID: "..user_id.. ") Crashou com Bau da casa aberta.")
			end
		end
	end
end)


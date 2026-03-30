 local Tunnel = module("vrp", "lib/Tunnel")

function vRP.getHunger(user_id)
    local data = vRP.getUserDataTable(user_id)
    if data then
        return data.hunger
    end

    return 0
end

function vRP.getThirst(user_id)
    local data = vRP.getUserDataTable(user_id)
    if data then
        return data.thirst
    end

    return 0
end

function vRP.setHunger(user_id, value)
    local source = vRP.getUserSource(user_id)
    if source then
        local data = vRP.getUserDataTable(user_id)
        if data then
            data.hunger = value
            if data.hunger < 0 then
                data.hunger = 0
            elseif data.hunger > 100 then
                data.hunger = 100
            end

            TriggerClientEvent("vrp_hud:updateHunger", source, data.hunger)
        end
    end
end

function vRP.setThirst(user_id, value)
    local source = vRP.getUserSource(user_id)
    if source then
        local data = vRP.getUserDataTable(user_id)
        if data then
            data.thirst = value
            if data.thirst < 0 then
                data.thirst = 0
            elseif data.thirst > 100 then
                data.thirst = 100
            end

            TriggerClientEvent("vrp_hud:updateThrist", source, data.thirst)
        end
    end
end

function vRP.varyHunger(user_id, variation)
    local source = vRP.getUserSource(user_id)
    if source then
        local data = vRP.getUserDataTable(user_id)
        if data then
            if not tonumber(data.hunger) then
                data.hunger = 0
            end

            local was_hunger = data.hunger >= 100
            data.hunger = data.hunger + variation

            local is_thunger = data.hunger >= 100
            local overflow = data.hunger - 100

            if overflow > 0 then
                vRPclient._varyHealth(vRP.getUserSource(user_id), -overflow * 1.5)
            end

            if data.hunger < 0 then
                data.hunger = 0
            elseif data.hunger > 100 then
                data.hunger = 100
            end

            TriggerClientEvent("vrp_hud:updateHunger", source, data.hunger)
        end
    end
end

function vRP.varyThirst(user_id, variation)
    local source = vRP.getUserSource(user_id)
    if source then
        local data = vRP.getUserDataTable(user_id)
        if data then
            if not tonumber(data.thirst) then
                data.thirst = 0
            end

            local was_thirsty = data.thirst >= 100
            data.thirst = data.thirst + variation
            local is_thirsty = data.thirst >= 100

            local overflow = data.thirst - 100
            if overflow > 0 then
                vRPclient._varyHealth(source, -overflow * 2)
            end

            if data.thirst < 0 then
                data.thirst = 0
            elseif data.thirst > 100 then
                data.thirst = 100
            end

            TriggerClientEvent("vrp_hud:updateThrist", source, data.thirst)
        end
    end
end

function task_update()
    for k, v in pairs(vRP.users) do
        vRP.varyHunger(v, 0.7)
        vRP.varyThirst(v, 0.8)
    end

    SetTimeout(60000, task_update)
end

AddEventHandler("vRP:playerJoin",function(user_id, source, name)
    local data = vRP.getUserDataTable(user_id)
    if not data.hunger or not data.thirst then
        data.hunger = 0
        data.thirst = 0
    end
end)

async(function()
  task_update()
end)
 
 
AddEventHandler("vRP:playerJoin",function(user_id, source, name)
    local data = vRP.getUserDataTable(user_id)
    if not data.hunger or not data.thirst then
        data.hunger = 0
        data.thirst = 0
    end
end)
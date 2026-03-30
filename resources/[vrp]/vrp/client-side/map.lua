local Tools = module("vrp","lib/Tools")

function tvRP.addBlip(x,y,z,idtype,idcolor,text,scale)
	local blip = AddBlipForCoord(x+0.001,y+0.001,z+0.001)
	SetBlipSprite(blip,idtype)
	SetBlipAsShortRange(blip,true)
	SetBlipColour(blip,idcolor)
	SetBlipScale(blip,scale)

	if text ~= nil then
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(text)
		EndTextCommandSetBlipName(blip)
	end
	return blip
end

function tvRP.removeBlip(id)
	RemoveBlip(id)
end

function tvRP.setGPS(x,y)
	SetNewWaypoint(x+0.0001,y+0.0001)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SETAREA
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local areas = {}
function tvRP.setArea(name,x,y,z,radius,height)
	local area = { coords = vec3(x+0.001,y+0.001,z+0.001), radius = radius }
	areas[name] = area
end

function tvRP.removeArea(name)
	if areas[name] then
		areas[name] = nil
	end
end

local in_area = false

Citizen.CreateThread(function()
	while true do
		local time = 1000
			local pedCoords = GetEntityCoords(PlayerPedId())
			for k,v in pairs(areas) do
				local distance = #(pedCoords - v.coords)

				if distance <= 10 then
					time = 5
					DrawMarker(27,v.coords[1],v.coords[2],v.coords[3]-0.95,0,0,0,0, 0,0,0.8,0.8,0.8, 0,149,254,100, 0,0,0,1)

					if distance <= v.radius then
						in_area = true

						if IsControlJustPressed(0,38) and in_area then
							vRPserver._enterArea(k)
						end

						if IsControlJustPressed(0,194) or IsControlJustPressed(0,25) or IsControlJustPressed(0,200) then
							if in_area then
								vRPserver._leaveArea(k)
								in_area = false
							end
						end
					end

					if in_area then
						if distance >= v.radius then
							vRPserver._leaveArea(k)
							in_area = false
						end
					end
				end

			end

		Citizen.Wait(time)
	end
end)
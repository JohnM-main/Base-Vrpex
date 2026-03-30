--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE PRISAO
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local prisioneiro = false

function tvRP.addPrisioneiro(status)
    prisioneiro = status
end

function tvRP.checkPrisioneiro()
    return prisioneiro
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- SISTEMA DE TAZER
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local tazertime = false
Citizen.CreateThread(function()
	while true do
		local time = 1000
		local ped = PlayerPedId()
        
		if IsPedBeingStunned(ped) then
			SetPedToRagdoll(ped,10000,10000,0,0,0,0)

			if not tazertime then
				tazertime = true
				SetTimecycleModifier("REDMIST_blend")
				ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE",1.0)
			end

		elseif not IsPedBeingStunned(ped) and tazertime then
			tazertime = false

			SetTimeout(5000,function()
				SetTimecycleModifier("hud_def_desat_Trevor")
				SetTimeout(10000,function()
					SetTimecycleModifier("")
					SetTransitionTimecycleModifier("")
					StopGameplayCamShaking()
				end)
			end)
		end

        Citizen.Wait(time)
	end
end)
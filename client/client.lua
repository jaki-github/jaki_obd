ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("jaki_obd:open")
AddEventHandler("jaki_obd:open", function()
    local playerData = ESX.GetPlayerData() 
    local job = playerData.job
    local allowedJobs = { "bennys" } 

    local hasAccess = false
    for _, allowedJob in ipairs(allowedJobs) do
        if job.name == allowedJob then
            hasAccess = true
            break
        end
    end

    if not hasAccess then
        ESX.ShowNotification({ 
            text = 'Du har inte behörighet att använda OBD!' 
        })
        return
    end

    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        local coords = GetEntityCoords(playerPed)
        local vehicleInFront = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)

        if vehicleInFront ~= 0 then
            vehicle = vehicleInFront
        else
            ESX.ShowNotification({ 
                text = 'Inget fordon är i närheten!' 
            })
            return
        end
    end

    local plate = GetVehicleNumberPlateText(vehicle)
    local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))

    local motorHealth = GetVehicleEngineHealth(vehicle)
    local bodyHealth = GetVehicleBodyHealth(vehicle)

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "Openobd",
        plate = plate,
        model = model,
        motorHealth = motorHealth,
        bodyHealth = bodyHealth
    })
end)


RegisterNUICallback("repairVehicle", function(data, cb)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 then
        local coords = GetEntityCoords(playerPed)
        local vehicleInFront = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)

        if vehicleInFront ~= 0 then
            vehicle = vehicleInFront
        else
            ESX.ShowNotification({ 
                text = 'Inget fordon är i närheten!' 
            })
            return
        end
    end

    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(0)
    end

    TaskPlayAnim(playerPed, "mini@repair", "fixing_a_ped", 8.0, -8.0, -1, 49, 0, false, false, false)
    Citizen.Wait(15000)

    SetVehicleEngineHealth(vehicle, 1000.0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehicleFixed(vehicle)

    ClearPedTasksImmediately(playerPed)

    cb("ok")

    SendNUIMessage({
        type = "vehicleRepaired"
    })
end)

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

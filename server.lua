local QBCore = exports['qb-core']:GetCoreObject()
local Config = Config or {}
local MySQL = exports['oxmysql']

function GeneratePlate()
    local charset = {}
    for i = 48, 57 do table.insert(charset, string.char(i)) end 
    for i = 65, 90 do table.insert(charset, string.char(i)) end 

    local plate = ""
    for i = 1, Config.PlateLength or 8 do
        plate = plate .. charset[math.random(1, #charset)]
    end
    return plate
end

function SendNoti(id, text, kind)
    if Config.NotiType == "qb" then
        TriggerClientEvent('QBCore:Notify', id, text, kind, 5000)
    elseif Config.NotiType == "ox_lib" then
        TriggerClientEvent('ox_lib:notify', id, { title = "Vehicle Management", type = kind, description = text,  position = 'top' })
    elseif Config.NotiType == "qs-phone" then
        TriggerClientEvent('qs-phone:client:notify', id, { title = "Vehicle Management", description = text, type = kind, icon = "car" })
    elseif Config.NotiType == "qs-interface" then
        TriggerClientEvent('interface:notification', id, text, "Garage", 5000, "fa-regular fa-truck")
    else
        print("Notification type not recognized: " .. Config.NotiType)
    end
end

QBCore.Commands.Add("givecar", "Give a car to a player", {
    { name = "model", help = "Vehicle model name" },
    { name = "id", help = "Player ID" }
}, true, function(source, args)
    local src = source
    local model = args[1]
    local targetId = tonumber(args[2])
    if not model or not targetId then
        SendNoti(source, "Usage: /givecar <model> <player_id>", "error")
        return
    end

    local Player = QBCore.Functions.GetPlayer(targetId)
    if not Player then
        SendNoti(source, "Player not found.", "error")
        return
    end

    local plate = GeneratePlate()
    local vehicleProps = {
        model = model,
        plate = plate,
    }

    MySQL:insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        Player.PlayerData.license,
        Player.PlayerData.citizenid,
        model,
        GetHashKey(model),
        json.encode(vehicleProps),
        plate,
        Config.DefaultState
    })
    
    if Config.Keys == "wasabi_carlock" then
    	exports['wasabi_carlock']:GiveKeys(plate)
    elseif Config.Keys == "qb-vehiclekeys" then
    	exports['qb-vehiclekeys']:GiveKeys(Player.PlayerData.source, plate)
    end

    SendNoti(src, "Added " .. model .. " (Plate: " .. plate .. ") to " .. GetPlayerName(src) .. "\'s garage!", "success")
    SendNoti(targetId, "You received a vehicle: " .. model .. " (Plate: " .. plate .. ")", "success")

    if Config.GiveCarWebhook ~= "" then
        sendGiveWebhook(source, targetId, model, plate)
    end
end, "god")

QBCore.Commands.Add("removecar", "Remove a car by plate", {
    { name = "plate", help = "Vehicle plate to remove" }
}, true, function(source, args)
    local plate = args[1]
    if not plate then
        SendNoti(source, "Usage: /removecar <plate>", "error")
        return
    end

    MySQL:execute('SELECT * FROM player_vehicles WHERE plate = ?', {plate}, function(result)
        if result and result[1] then
            local vehicle = result[1]
            local citizenid = vehicle.citizenid
            local decoded = json.decode(vehicle.vehicle or "{}")

            print(result)

            -- Get owner's player object if online
            local owner = QBCore.Functions.GetPlayerByCitizenId(citizenid)
            local ownerName = "Offline"
            local ownerSrc = nil

            if owner then
                ownerSrc = owner.PlayerData.source
                ownerName = owner.PlayerData.name
            end

            -- Delete the vehicle
            MySQL:execute('DELETE FROM player_vehicles WHERE plate = ?', {plate})

            if Config.Keys == "wasabi_carlock" then
                exports['wasabi_carlock']:RemoveKey(plate)
            elseif Config.Keys == "qb-vehiclekeys" then
                exports['qb-vehiclekeys']:RemoveKeys(ownerSrc, plate)
            end
            

            -- Notify admin
            SendNoti(source, "Removed plate: " .. plate .. " from " .. ownerName .. "'s garage.", "success")

            -- Notify owner (if online)
            if ownerSrc then
                SendNoti(ownerSrc, "Your plate: " .. plate .. " was removed from your garage by staff.", "error")
            end

            -- Send webhook log
            if Config.RemoveCarWebhook ~= "" then
                sendRemoveWebhook(source, ownerSrc, plate)
            end
        else
            SendNoti(source, "No vehicle found with plate: " .. plate, "error")
        end
    end)
end, "god")

QBCore.Commands.Add("listcars", "Shows the target's vehicles", {
    { name = "id", help = "Target Player ID" }
}, true, function(source, args)
    local targetId = tonumber(args[1])
    if not targetId then
        SendNoti(source, "Invalid target ID", "error")
        return
    end

    local target = QBCore.Functions.GetPlayer(targetId)
    if not target then
        SendNoti(source, "Player not found", "error")
        return
    end

    local identifier = target.PlayerData.citizenid

    MySQL:query('SELECT plate, vehicle FROM player_vehicles WHERE citizenid = ?', {identifier}, function(result)
        if result and #result > 0 then
            local VehicleDataForWebhook = {}
            for _, v in ipairs(result) do
                local modelName = "Unknown"
                if v.vehicle then
                    modelName = v.vehicle or "Unknown"
                end
                table.insert(VehicleDataForWebhook, {
                    plate = v.plate,
                    spawnCode = modelName
                })
                SendNoti(source, "Plate: " .. (v.plate or "N/A") .. ", Model: " .. modelName, "primary")
            end

            if Config.EveryCarWebhook ~= "" then
                sendEveryCarWebhook(source, targetId, VehicleDataForWebhook)
            end
        else
            SendNoti(source, "No vehicles found for this player", "error")
        end
    end)
end, "god")
function sendGiveWebhook(source, targetId, model, plate)
    PerformHttpRequest(Config.GiveCarWebhook, function() end, "POST", json.encode({
        username = "🚗 Fire Vehicle Logger",
        avatar_url = "https://cdn.discordapp.com/attachments/577669001338159164/1360008417439256697/56d5f65ba091d93a26d9bbd343cd6efa.png?ex=681d268a&is=681bd50a&hm=f2bcead2ae3b3a8e827a4e568d56b4150d6c1d50387589d85bea96bb84c1a463&.png", -- optional, replace with your server's branding
        embeds = {{
            title = "🎁 Vehicle Given",
            color = 65280, -- light green
            description = "A new vehicle has been granted to a player.",
            fields = {
                {
                    name = "Admin",
                    value = "```" .. GetPlayerName(source) .. " (ID: " .. source .. ")```",
                    inline = true
                },
                {
                    name = "Recipient ID",
                    value = "```" .. GetPlayerName(targetId) .. " (ID: " .. targetId .. ")```",
                    inline = true
                },
                {
                    name = "Vehicle Model",
                    value = "```" .. model .. "```",
                    inline = true
                },
                {
                    name = "Plate",
                    value = "```" .. plate .. "```",
                    inline = true
                }
            },
            footer = {
                text = "Command: /givecar • Fire Scripts"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }), { ["Content-Type"] = "application/json" })
end

function sendRemoveWebhook(source, targetId, plate)
    PerformHttpRequest(Config.RemoveCarWebhook, function() end, "POST", json.encode({
        username = "🚨 Fire Vehicle Logger",
        avatar_url = "https://cdn.discordapp.com/attachments/577669001338159164/1360008417439256697/56d5f65ba091d93a26d9bbd343cd6efa.png?ex=681d268a&is=681bd50a&hm=f2bcead2ae3b3a8e827a4e568d56b4150d6c1d50387589d85bea96bb84c1a463&.png", -- optional, replace with your server's branding
        embeds = {{
            title = "🔥 Vehicle Removed",
            color = 16711680, -- red
            description = ("A vehicle has been removed by an admin."),
            fields = {
                {
                    name = "Admin",
                    value = "```" .. GetPlayerName(source) .. " (ID: " .. source .. ")```",
                    inline = true
                },
                {
                    name = "Recipient ID",
                    value = "```" .. GetPlayerName(targetId) .. " (ID: " .. targetId .. ")```",
                    inline = true
                },
                {
                    name = "Plate",
                    value = "```" .. plate .. "```",
                    inline = true
                }
            },
            footer = {
                text = "Command: /removecar • Fire Scripts"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }), { ["Content-Type"] = "application/json" })
end

function sendEveryCarWebhook(source, targetId, vData)
    local carData = ""
    
    for _, a in ipairs(vData) do
        carData = carData .. ("Plate: %s | Model: %s\n"):format(a.plate or "N/A", a.spawnCode or "Unknown")
    end

    PerformHttpRequest(Config.EveryCarWebhook, function() end, "POST", json.encode({
        username = "🚨 Fire Vehicle Logger",
        avatar_url = "https://cdn.discordapp.com/attachments/577669001338159164/1360008417439256697/56d5f65ba091d93a26d9bbd343cd6efa.png?ex=681d268a&is=681bd50a&hm=f2bcead2ae3b3a8e827a4e568d56b4150d6c1d50387589d85bea96bb84c1a463&.png", -- optional, replace with your server's branding
        embeds = {{
            title = "🔥 Vehicles List",
            color = 255, -- blue
            description = ("An admin requested a players vehicles."),
            fields = {
                {
                    name = "Admin",
                    value = "```" .. GetPlayerName(source) .. " (ID: " .. source .. ")```",
                    inline = true
                },
                {
                    name = "Recipient ID",
                    value = "```" .. GetPlayerName(targetId) .. " (ID: " .. targetId .. ")```",
                    inline = true
                },
                {
                    name = "Vehicles",
                    value = "```" .. carData .. "```",
                    inline = false
                }
            },
            footer = {
                text = "Command: /listcars • Fire Scripts"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }}
    }), { ["Content-Type"] = "application/json" })
end
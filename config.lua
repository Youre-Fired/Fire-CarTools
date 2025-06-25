Config = {

    -- Vehicle
    DefaultState = 0, -- Default vehicle state (0 = in garage, 1 = out/spawned)
    PlateLength = 8, -- Number of characters for generated license plate

    -- Command Settings
    CommandType = "qb", -- "qb", "ox", "standalone"

    -- Keys and Notifications
    Keys = "qb-vehiclekeys", -- "wasabi_carlock", "qb-vehiclekeys"
    NotiType = "qb-Notify", -- "qb-Notify", "qs-phone", "ox_lib"

    -- Discord Webhooks | Leave empty to disable
    GiveCarWebhook = "",
    RemoveCarWebhook = "",
    EveryCarWebhook = ""
}
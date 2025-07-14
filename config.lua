Config = {

    -- Vehicle
    DefaultState = 0, -- Default vehicle state (0 = in garage, 1 = out/spawned)
    PlateLength = 8, -- Number of characters for generated license plate

    -- Keys and Notifications
    Keys = "wasabi_carlock", -- "wasabi_carlock", "qb-vehiclekeys"
    NotiType = "qb-interface", -- "qb-interface", "qs-phone", "ox_lib"

    -- Discord Webhooks | Leave empty to disable
    GiveCarWebhook = "",
    RemoveCarWebhook = "",
    EveryCarWebhook = ""
}
local cache = {
    ped = PlayerPedId(),
    playerId = PlayerId()
}

lib.onCache('ped', function(ped)
    cache.ped = ped
end)

lib.onCache('playerId', function(playerId)
    cache.playerId = playerId
end)

local HealCooldown = false
local ArmourCoolDown = false
local WhippingDisabled = false

TriggerEvent("chat:addSuggestion", "/heal", "Heal yourself!")
TriggerEvent("chat:addSuggestion", "/armour", "Give yourself some armour!")

RegisterCommand("heal", function()
    if HealCooldown then
        if Config.NotifyEnabled then
            return SendNoti(cache.playerId, "You are on cooldown for this!", "error")
        end
        return
    end

    if not cache.ped or cache.ped == 0 then
        cache.ped = PlayerPedId()
    end

    if LocalPlayer.state.dead or IsEntityDead(cache.ped) then
        if Config.NotifyEnabled then
            return SendNoti(cache.playerId, "You cannot use this whilst dead!", "error")
        else
            print("test")
        end
        return
    end

    SetEntityHealth(cache.ped, 200)
    HealCooldown = true
    if Config.NotifyEnabled then
        SendNoti(cache.playerId, "Health has been restored!", "success")
    end

    -- Wait for 5 minutes (cooldown)
    Wait(5 * 60 * 1000)  -- 5 minutes cooldown
    HealCooldown = false  -- Reset cooldown after wait
end, false)

local function GetArmourAmount()
    return math.random(15, 40)
end

RegisterCommand("armour", function()
    if ArmourCoolDown then
        if Config.NotifyEnabled then
            return SendNoti(cache.playerId, "You are on cooldown for this!", "error")
        end
        return
    end

    if not cache.ped or cache.ped == 0 then
        cache.ped = PlayerPedId()
    end

    if LocalPlayer.state.dead or IsEntityDead(cache.ped) then
        if Config.NotifyEnabled then
            return SendNoti(cache.playerId, "You cannot use this whilst dead!", "error")
        end
        return
    end

    SetPedArmour(cache.ped, GetArmourAmount())
    ArmourCoolDown = true
    if Config.NotifyEnabled then
        SendNoti(cache.playerId, "Armour has been applied!", "success")
    end

    -- Wait for 5 minutes (cooldown)
    Wait(5 * 60 * 1000)  -- 5 minutes cooldown
    ArmourCoolDown = false  -- Reset cooldown after wait
end, false)

local function DisableWhipping()
    CreateThread(function()
        while WhippingDisabled do
            Wait(0)
            DisableControlAction(0, 141, true)  -- Disable whip action
            DisableControlAction(0, 142, true)
        end
    end)
end

lib.onCache("weapon", function(value)
    if value then
        local hasMelee = IsPedArmed(cache.ped, 1)
        if not hasMelee then
            if not WhippingDisabled then
                WhippingDisabled = true
                DisableWhipping()
            end
        else
            WhippingDisabled = false
        end
    else
        WhippingDisabled = false
    end
end)

CreateThread(function()
    SetWeaponDamageModifier(GetHashKey("WEAPON_UNARMED"), 0.3)
    SetWeaponDamageModifier(GetHashKey("WEAPON_NIGHTSTICK"), 0.3)

    while true do
        Wait(500)
        ResetPlayerStamina(cache.playerId)
    end
end)

function SendNoti(playerId, message, type)
    if not message or message == "" then return end

    local messageType, color
    if type == "success" then
        messageType = "SYSTEM"
        color = "~g~"
    elseif type == "error" then
        messageType = "ERROR"
        color = "~r~"
    else
        messageType = "INFO"
        color = "~b~"
    end

    local formattedMessage = string.format("%s[%s] ~w~%s", color, messageType, message)

    if Config.Notify == 0 then
        TriggerEvent('chat:addMessage', {
            args = {formattedMessage}
        })
    elseif Config.Notify == 1 then
        exports['okokNotify']:Alert(Config.Prefix, message, Config.NotifyDuration, type, true)
    elseif Config.Notify == 2 then
        if type == "success" then
            exports["Venice-Notification"]:Notify(message, Config.NotifyDuration, 'check')
        elseif type == "error" then
            exports["Venice-Notification"]:Notify(message, Config.NotifyDuration, 'error')
        end
    elseif Config.Notify == 3 then
        lib.notify({
            title = Config.Prefix,
            description = message,
            type = type,
            position = 'center-right'
        })
    end
end

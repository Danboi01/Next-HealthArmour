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
        return exports["Venice-Notification"]:Notify("You are on cooldown for this!", 5000, "error")
    end

    if not cache.ped or cache.ped == 0 then
        cache.ped = PlayerPedId()
    end

    if LocalPlayer.state.dead or IsEntityDead(cache.ped) then
        return exports["Venice-Notification"]:Notify("You cannot use this whilst dead!", 5000, "error")
    end

    SetEntityHealth(cache.ped, 200)
    HealCooldown = true
    exports["Venice-Notification"]:Notify("Health has been restored!", 5000, "success")

    Wait(5 * 60 * 1000)
    HealCooldown = false
end, false)

local function GetArmourAmount()
    return math.random(15, 40)
end

RegisterCommand("armour", function()
    if ArmourCoolDown then
        return exports["Venice-Notification"]:Notify("You are on cooldown for this!", 5000, "error")
    end

    if not cache.ped or cache.ped == 0 then
        cache.ped = PlayerPedId()
    end

    if LocalPlayer.state.dead or IsEntityDead(cache.ped) then
        return exports["Venice-Notification"]:Notify("You cannot use this whilst dead!", 5000, "error")
    end

    SetPedArmour(cache.ped, GetArmourAmount())
    ArmourCoolDown = true
    exports["Venice-Notification"]:Notify("Armour has been applied!", 5000, "success")

    Wait(5 * 60 * 1000)
    ArmourCoolDown = false
end, false)

local function DisableWhipping()
    CreateThread(function()
        while WhippingDisabled do
            Wait(0)
            DisableControlAction(0, 141, true)
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

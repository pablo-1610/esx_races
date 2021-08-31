---@author Pablo Z.
---@version 1.0
--[[
  File main created at 31/08/2021 01:11
  Script created by Pablo Z.
  
  For any questions or support, please visit https://discord.gg/pablo-dev
  or send mail at pablo.zapata.dev@gmail.com
--]]

ESX = nil

inRace, canInteractWithZones = false, true

local function createGlobalBlip(data)
    local blip = AddBlipForCoord(data.baseZone)
    SetBlipSprite(blip, 38)
    SetBlipColour(blip, 81)
    SetBlipScale(blip, 0.9)
    SetBlipAsShortRange(blip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(("Course \"%s\""):format(data.label))
    EndTextCommandSetBlipName(blip)
end

RegisterNetEvent(event("servercb"))
AddEventHandler(event("servercb"), function(message)
    canInteractWithZone = true
    if message ~= nil then ESX.ShowNotification(message) end
end)

Citizen.CreateThread(function()
    TriggerEvent(Config.esxGetter, function(obj)
        ESX = obj
    end)
    TriggerEvent(event("initMenu"))

    for _, data in pairs(Config.races) do
        if data.blip then
            createGlobalBlip(data)
        end
    end

    while true do
        local interval, pPos = 250, GetEntityCoords(PlayerPedId())
        for id, data in pairs(Config.races) do
            local pos = data.baseZone
            local dst = #(pPos-pos)
            if dst <= 30.0 and canInteractWithZones and not inRace then
                interval = 0
                DrawMarker(22, pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 178, 23, 255, 55555, false, true, 2, false, false, false, false)
                if dst <= 1.0 then
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour accéder au menu de la course")
                    if IsControlJustPressed(0, 51) then
                        canInteractWithZone = false
                        TriggerServerEvent(event("openMenu"), id)
                    end
                end
            end
        end
        Wait(interval)
    end
end)


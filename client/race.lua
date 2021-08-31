---@author Pablo Z.
---@version 1.0
--[[
  File race created at 31/08/2021 02:08
  Script created by Pablo Z.
  
  For any questions or support, please visit https://discord.gg/pablo-dev
  or send mail at pablo.zapata.dev@gmail.com
--]]

local checkPointBlip

local function createCheckpointBlip(coords, isFinal)
    checkPointBlip = AddBlipForCoord(coords)
    SetBlipSprite(checkPointBlip, 1)
    SetBlipColour(checkPointBlip, isFinal and 11 or 5)
    SetBlipScale(checkPointBlip, 0.9)
    SetBlipAsShortRange(checkPointBlip, false)
    SetBlipRoute(checkPointBlip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(isFinal and "Checkpoint" or "Ligne d'arrivée")
    EndTextCommandSetBlipName(checkPointBlip)
end

RegisterNetEvent(event("startRace"))
AddEventHandler(event("startRace"), function(raceId)
    local label = Config.races[raceId].label
    local cMs, cS, cM = 0,0,0
    local fullS = 0
    inRace = true
    DoScreenFadeOut(1500)
    while not IsScreenFadedOut() do Wait(10) end
    local model = GetHashKey(Config.races[raceId].vehicle)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(10) end
    local spawn = Config.races[raceId].start
    local veh = CreateVehicle(model, spawn.pos, spawn.heading, true, true)
    FreezeEntityPosition(veh, true)
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    Wait(1000)
    DoScreenFadeIn(500)
    Wait(500)
    PlaySoundFrontend(-1, "5s_To_Event_Start_Countdown", "GTAO_FM_Events_Soundset", false)
    local started, s = false, 5
    Citizen.CreateThread(function()
        while not started do
            Wait(1000)
            s = s - 1
        end
    end)
    Citizen.CreateThread(function()
        while not started do
            Wait(1)
            RageUI.Text({message = ("Début de la course dans ~r~%s ~s~seconde%s"):format(s, (s > 1 and "s" or ""))})
        end
    end)
    Wait(4500)
    PlaySoundFrontend(-1, "GO", "HUD_MINI_GAME_SOUNDSET", false)
    Wait(500)
    FreezeEntityPosition(veh, false)
    started = true
    Citizen.CreateThread(function()
        while inRace do
            Wait(1000)
            if not inRace then return end
            cS = cS + 1
            fullS = fullS + 1
            if cS > 60 then
                cS = 0
                cM = cM + 1
            end
        end
    end)

    Citizen.CreateThread(function()
        local currentCpx = 1
        createCheckpointBlip(Config.races[raceId].checkpoints[1])
        while inRace do
            local currentDest = Config.races[raceId].checkpoints[currentCpx]
            local pPos = GetEntityCoords(PlayerPedId())
            local dst = #(pPos-currentDest)
            if dst <= 15.0 and IsPedInAnyVehicle(PlayerPedId(), false) then
                local veh2 = GetVehiclePedIsIn(PlayerPedId(), false)
                if veh2 == veh then
                    if currentCpx > #Config.races[raceId].checkpoints then
                        inRace = false
                    end
                    Citizen.CreateThread(function()
                        ESX.Scaleform.ShowFreemodeMessage(("~o~%s"):format(label), ("~n~CheckPoint: ~y~%s~s~/~y~%s~n~~s~Temps: ~o~%s~s~:~o~%s"):format(currentCpx, #Config.races[raceId].checkpoints, cM, cS), 3)
                    end)
                    Wait(10)
                    currentCpx = currentCpx + 1
                    if currentCpx > #Config.races[raceId].checkpoints then
                        inRace = false
                        canInteractWithZones = true
                        TriggerServerEvent(event("finish"), raceId, cM, cS, fullS)
                        PlaySoundFrontend(-1, "RACE_PLACED", "HUD_AWARDS", false)
                        RemoveBlip(checkPointBlip)
                        Citizen.CreateThread(function()
                            Wait(2500)
                            ESX.Scaleform.ShowFreemodeMessage(("~o~%s"):format(label), ("~n~~g~Course terminée~n~~s~Temps: ~o~%s~s~:~o~%s"):format(cM, cS), 10)
                        end)
                        Wait(8500)
                        DoScreenFadeOut(1500)
                        while not IsScreenFadedOut() do Wait(10) end
                        DeleteEntity(veh)
                        SetEntityCoords(PlayerPedId(), Config.races[raceId].baseZone, false, false, false, false)
                        Wait(1000)
                        DoScreenFadeIn(500)
                    else
                        PlaySoundFrontend(-1, "CHECKPOINT_PERFECT", "HUD_MINI_GAME_SOUNDSET", false)
                        RemoveBlip(checkPointBlip)
                        createCheckpointBlip(Config.races[raceId].checkpoints[currentCpx], (currentCpx) == #Config.races[raceId].checkpoints)
                    end
                end
            end
            Wait(0)
        end
    end)
end)
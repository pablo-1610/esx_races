---@author Pablo Z.
---@version 1.0
--[[
  File menu created at 31/08/2021 01:22
  Script created by Pablo Z.
  
  For any questions or support, please visit https://discord.gg/pablo-dev
  or send mail at pablo.zapata.dev@gmail.com
--]]

local title, desc, cat = "Course", "~o~Battez le record", "zRaces"

local isMenuOpened = false

local function sub(subName)
    return ("zRaces_%s"):format(subName)
end

local function customGroupDigits(value)
    local left,num,right = string.match(value,'^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1' .. "."):reverse())..right
end

AddEventHandler(event("initMenu"), function()
    print(cat)
    RMenu.Add(cat, sub("main"), RageUI.CreateMenu(title, desc, nil, nil, "pablo", "black"))
    RMenu:Get(cat, sub("main")).Closed = function()
        isMenuOpened = false
        FreezeEntityPosition(PlayerPedId(), false)
    end

    RMenu.Add(cat, sub("best"), RageUI.CreateSubMenu(RMenu:Get(cat, sub("main")), title, desc, nil, nil, "pablo", "black"))
    RMenu:Get(cat, sub("best")).Closed = function()
    end
end)

RegisterNetEvent(event("cbOpenMenu"))
AddEventHandler(event("cbOpenMenu"), function(raceId, top, ret)
    if isMenuOpened then return end
    isMenuOpened = true
    canInteractWithZones = true
    FreezeEntityPosition(PlayerPedId(), true)
    RageUI.Visible(RMenu:Get(cat, sub("main")), true)
    Citizen.CreateThread(function()
        while isMenuOpened do
            RageUI.IsVisible(RMenu:Get(cat, sub("main")), true, true, true, function()
                RageUI.Separator(("Course: ~y~%s"):format(Config.races[raceId].label))
                if ret ~= nil then RageUI.Separator(("Dernier: ~y~%s ~s~| Meilleur: ~b~%s"):format(ret.last.format, ret.best.format)) end
                RageUI.ButtonWithStyle("Démarrer la course", "Appuyez pour démarrer la course", {RightLabel = ("%s ~s~→→"):format(("~g~%s$"):format(customGroupDigits(Config.races[raceId].priceToParticipate)))}, true, function(_,_,s)
                    if s then
                        RageUI.CloseAll()
                        isMenuOpened = false
                        canInteractWithZone = false
                        FreezeEntityPosition(PlayerPedId(), false)
                        TriggerServerEvent(event("startRace"), raceId)
                    end
                end)
                RageUI.ButtonWithStyle("Top 10 des meilleurs temps", "Appuyez pour accéder au top 10 de cette course", {RightLabel = "→→"}, true, function(_,_,s)
                end, RMenu:Get(cat, sub("best")))
            end, function()
            end)

            RageUI.IsVisible(RMenu:Get(cat, sub("best")), true, true, true, function()
                RageUI.Separator(("Course: ~y~%s"):format(Config.races[raceId].label))
                RageUI.Separator("↓ ~r~Les meilleurs ~s~↓")
                if #top > 0 then
                    for i = 1, 10 do
                        if top[i] then
                            RageUI.ButtonWithStyle(("\"~y~%s~s~\" en ~o~%s~s~ !"):format(top[i].name, (("%s"):format(top[i].format))), nil, {}, true)
                        end
                    end
                else
                    RageUI.ButtonWithStyle("~r~Aucune donnée", nil, {}, true)
                end
            end, function()
            end)
            Wait(0)
        end
    end)
end)
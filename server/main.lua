---@author Pablo Z.
---@version 1.0
--[[
  File main created at 31/08/2021 01:11
  Script created by Pablo Z.
  
  For any questions or support, please visit https://discord.gg/pablo-dev
  or send mail at pablo.zapata.dev@gmail.com
--]]

local ESX

TriggerEvent(Config.esxGetter, function(obj)
    ESX = obj
end)

RegisterNetEvent(event("openMenu"))
AddEventHandler(event("openMenu"), function(raceId)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local identifier = xPlayer.identifier
    MySQL.Async.fetchAll("SELECT * FROM races WHERE identifier = @a AND race = @b", {
        ["a"] = identifier,
        ["b"] = raceId
    }, function(result)
        MySQL.Async.fetchAll("SELECT * FROM races WHERE race = @a", {["a"] = raceId}, function(re)
            local top = {}

            for k, v in pairs(re) do
                local best = json.decode(v.bestTime)
                table.insert(top, {best = best.time, name = v.name, format = best.format})
            end
            table.sort(top, function(a,b) return a.best < b.best  end)
            local ret = nil
            if result[1] then ret = {last = json.decode(result[1].lastTime), best = json.decode(result[1].bestTime)} end
            TriggerClientEvent(event("cbOpenMenu"), _src, raceId, top, ret)
        end)
    end)
end)

RegisterNetEvent(event("startRace"))
AddEventHandler(event("startRace"), function(raceId)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local priceToParticipate = Config.races[raceId].priceToParticipate

    if xPlayer.getMoney() >= priceToParticipate then
        xPlayer.removeMoney(priceToParticipate)
    elseif xPlayer.getAccount("bank").money >= priceToParticipate then
        xPlayer.removeAccountMoney("bank", priceToParticipate)
    else
        TriggerClientEvent(event("servercb"), _src, "~r~Vous n'avez pas assez d'argent pour participer !")
        return
    end

    TriggerClientEvent(event("servercb"), _src, "~g~Bonne chance !")
    TriggerClientEvent(event("startRace"), _src, raceId)
end)

RegisterNetEvent(event("finish"))
AddEventHandler(event("finish"), function(raceId, min,s,fulls)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local identifier = xPlayer.identifier

    MySQL.Async.fetchAll("SELECT * FROM races WHERE identifier = @a AND race = @b", {
        ["a"] = identifier,
        ["b"] = raceId
    }, function(result)
        if result[1] then
            local best = json.decode(result[1].bestTime)
            local last = {format = ("%s:%s"):format(min,s), time = fulls}
            if best.time > fulls then
                best = {format = ("%s:%s"):format(min,s), time = fulls}
            end
            print(json.encode(last))
            print("<>")
            print(json.encode(best))
            MySQL.Async.execute("UPDATE races SET lastTime = @a, bestTime = @b WHERE identifier = @c AND race = @d", {
                ["a"] = json.encode(last),
                ["b"] = json.encode(best),
                ["c"] = identifier,
                ["d"] = raceId
            })
        else
            local best = {format = ("%s:%s"):format(min,s), time = fulls}
            local last = {format = ("%s:%s"):format(min,s), time = fulls}
            MySQL.Async.insert("INSERT INTO races (identifier, name, race, lastTime, bestTime) VALUES(@a,@n, @b,@c,@d)", {
                ["a"] = identifier,
                ["n"] = GetPlayerName(_src),
                ["b"] = raceId,
                ["c"] = json.encode(last),
                ["d"] = json.encode(best)
            })
        end
    end)
end)
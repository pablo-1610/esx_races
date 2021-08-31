---@author Pablo Z.
---@version 1.0
--[[
  File config created at 31/08/2021 01:10
  Script created by Pablo Z.
  
  For any questions or support, please visit https://discord.gg/pablo-dev
  or send mail at pablo.zapata.dev@gmail.com
--]]


-- The last checkpoint will be the end
Config = {
    esxGetter = "esx:getSharedObject",
    races = {
        ["masupercourse1"] = {
            label = "Le tour du concess",
            priceToParticipate = 200,
            vehicle = "zentorno",
            blip = true,
            baseZone = vector3(164.1, -776.71, 31.8),
            start = {pos = vector3(173.43, -783.64, 31.64), heading = 159.27},

            checkpoints = {
                vector3(109.41, -974.12, 29.41),
                vector3(-6.06, -953, 28.74),
                vector3(-94.21, -1118.99, 25.12),
                vector3(102.04, -1025.72, 23.74),
                vector3(186.39, -795.57, 30.75)
            }
        }
    }
}

function event(name)
    return ("zRaces:%s"):format(name)
end
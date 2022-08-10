--!strict

-- CTF
-- Author(s): Sekuriyo
-- Date: 08/10/2022

--[[
    
]]

---------------------------------------------------------------------
-- Services
local RBXReplicatedStorage = game:GetService("ReplicatedStorage")
-- Constants
local MIN_FLAGS = 2 -- There's no reason this or MIN_TEAMS should go beneath 2
local MIN_TEAMS = 2
-- Knit
local Knit = require( RBXReplicatedStorage.Packages.Knit )
local Trove = require( RBXReplicatedStorage.Packages.Trove )
local Promise = require( RBXReplicatedStorage.Packages.Promise )
-- Modules

-- Roblox Services

-- Variables

-- Objects

---------------------------------------------------------------------


local CTF = {}
CTF.__index = CTF

local function newFlag(team)
    local flag
end


function CTF.new( flagTemplate : Instance, flagPositions : {}, teams : {}, callbackFunction ): ( {} )
    local self = setmetatable( {}, CTF )

    --Check to see if the constructor is being called with invalid parameters
    assert( #flagPositions >= MIN_FLAGS, ("Specified flags: %c, required: %c"):format(#flagPositions, MIN_FLAGS) )
    assert( #teams >= MIN_TEAMS, ("Specified flags: %c, required: %c"):format(#teams, MIN_TEAMS) )

    --Setup trove for garbage collection
    self._trove = Trove.new()

    --Setup the callback function so we can return necessary data such as when a point is captured.
    self._cb = callbackFunction

    self._flagTemplate = flagTemplate
    self._flagPositions = flagPositions
    self._teams = teams

    return self
end


function CTF:Play()
    for _, team in ipairs(self._teams) do
        
    end
end


function CTF:Pause()

end


function CTF:Destroy(): ()
    self._trove:Destroy()
end


return CTF
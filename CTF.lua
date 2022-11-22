-- CTF
-- Author(s): Sekuriyo
-- Date: 08/10/2022

--[[
    
]]

---------------------------------------------------------------------
-- Services
local RBXReplicatedStorage = game:GetService("ReplicatedStorage")
local RBXTeams = game:GetService("Teams")
-- Constants
local MIN_FLAGS = 2 -- There's no reason this or MIN_TEAMS should go beneath 2
local MIN_TEAMS = 2
-- Knit
local Knit = require( RBXReplicatedStorage.Packages.Knit )
local Trove = require( RBXReplicatedStorage.Packages.Trove )
local Promise = require( RBXReplicatedStorage.Packages.Promise )
local Signal = require( RBXReplicatedStorage.Packages.Signal )
-- Modules
local Flag = require(RBXReplicatedStorage.KnitShared.Classes.Flag)
-- Variables

-- Objects

---------------------------------------------------------------------


local CTF = {}
CTF.__index = CTF

--[[
function obj.new()
    local self = setmetatable( {}, CTF )
    self._trove = Trove.new()

    local stuffToCleanup = {}
    function stuffToCleanup:Destroy()
        print("Cleaning up!")
    end
    self._trove:Add(stuffToCleanup) -- This will error

    return self
end
]]


--CTF.new(flagTemplate : Instance, flagPositions : {}, teams : {}, maxScore : number) : returns the CTF object itself
function CTF.new( ... ): ( {} )
    local arguments = {...}
    print(arguments)
    local flagTemplate = arguments[1]
    local flagPositions = arguments[2]
    local teams = arguments[3]
    
    

    local self = setmetatable( {}, CTF )

    --Check to see if the constructor is being called with invalid parameters
    assert( #flagPositions >= MIN_FLAGS, ("Specified flags: %c, required: %c"):format(#flagPositions, MIN_FLAGS) )
    assert( #teams >= MIN_TEAMS, ("Specified flags: %c, required: %c"):format(#teams, MIN_TEAMS) )

    --Setup trove for garbage collection
    self._trove = Trove.new()

    self._maxScore = arguments[4]

    self.container = Instance.new("Folder")
    self.container.Parent = workspace
    self.container.Name = "CTF"
    self._trove:Add(self.container)

    self._flagTemplate = flagTemplate
    self._flagPositions = flagPositions
    self._teams = teams
    self._flags = {}
    self._ended = false
    
    --Signals
    self.flagDeposited = Signal.new()
    self.flagStolen = Signal.new()
    self.flagReturned = Signal.new()
    self.maxScoreReached = Signal.new()

    --Quick score initialization so we can index the dictionary by the team object
    self._scores = {}
    for _, team in ipairs (teams) do
        self._scores[team] = 0
    end

    self.callback = function(passed, info)
        if passed == "Capture" then
            local capturingTeam = info.capturingTeam
            if self._scores[capturingTeam] and not self._ended then
                self._scores[capturingTeam] += 1
                if self._scores[capturingTeam] >= self._maxScore then
                    self._ended = true
                    self.maxScoreReached:Fire({
                        winningTeam = capturingTeam;
                        scoreTally = self._scores
                    })
                end
            end
            local flagPosIndex = table.find(teams, info.capturedFlagTeam)
            if flagPosIndex then
                table.insert( self._flags, self:NewFlag(info.capturedFlagTeam, self._flagPositions[flagPosIndex]) )
            end
            self.flagDeposited:Fire(info)
        elseif passed == "Steal" then
            self.flagStolen:Fire(info)
        elseif passed == "Return" then
            self.flagReturned:Fire(info)
            local flagPosIndex = table.find(teams, info.flagReturnedToTeam)
            warn(flagPosIndex)
            if flagPosIndex then
                table.insert( self._flags, self:NewFlag(info.flagReturnedToTeam, self._flagPositions[flagPosIndex]) )
            end
        end
    end

    return self
end


function CTF:NewFlag(team, position, isAwayFromSpawn)
    return self._trove:Add( Flag.new(self._flagTemplate, team, position, self.container, self.callback, isAwayFromSpawn) )
end


function CTF:OnUserDeath(user, character)
    warn(user.Name.. " died!")
    local flag = user:FindFirstChild("Flag")
    if flag then
        local teamFlag = flag.Value
        local humanoidRootPart = character.HumanoidRootPart
        table.insert( self._flags, self:NewFlag(teamFlag, humanoidRootPart.Position, true) )
        flag:Destroy()
    end
end


function CTF:OnUserLeave(user)
    local flag = user:FindFirstChild("Flag")
    if flag then
        local teamFlag = flag.Value
        local index = table.find(self._teams, teamFlag)
        local flagPosition = self._flagPositions[index]
        table.insert( self._flags, self:NewFlag(teamFlag, flagPosition) )
    end
end


function CTF:Play()
    --Setup the flag positions
    for i, team in ipairs(self._teams) do
        table.insert( self._flags, self:NewFlag(team, self._flagPositions[i]) )
    end
end


function CTF:GetScore()
    return(self._scores)
end

function CTF:Pause()

end


function CTF:Destroy(): ()
    self._trove:Destroy()
end


return CTF

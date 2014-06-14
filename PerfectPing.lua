--[[
    Perfect Ping 1.1.1 by Husky
    ========================================================================

    This script automatically pings roaming champions to inform you and your
    team about incoming ganks. This will improve your teamplay and boost your
    elo by making enemy ganks less effective.

    Features:
    ~~~~~~~~~

    - disables itself when the lane phase ends (time based)
    - keeps track of how often enemies were pinged to avoid spam pinging
    - keeps track of enemy positioning to avoid unnessecary pings (champs that
      are chased and were seen already do not get pinged anymore)
    - ability to disable the script ingame (press shift to open menu)
    - doesn't ping champions that leave the lane for a very short period of time
      (to ward for example)
    - pings champions based on their semantic position on the map (inner jungle
      and inner river)
    - script uses fallback pings to not call for engages accidently
    - script doesnt ping champions that show up in the fog of war for 1 single tick (riot bug)
    - option to switch ping type ingame

    Changelog
    ~~~~~~~~~

    1.0     - initial version with the most important features (initial pinging AI)

    1.1     - implemented a fix for riot bug
            - switched back to fallback pings since normal pings make your team engage
            - added a menu option to switch between ping types

    1.1.1   - script uses the Packet library now, to faster address packet changes in the future
]]

-- Load required libraries -----------------------------------------------------

require "MapPosition"

-- Config ----------------------------------------------------------------------

local autoDisableTime      = 1500  -- time in seconds until automatic disable (when lane phase ends)
local heroVisibleTimeout   = 500   -- mimimum time in ms that a hero has to be invisible to be pinged
local heroPingTimeout      = 10000 -- minimum time in ms until the same hero can be pinged again
local pingTimeout          = 3000  -- minimum time in ms between separate pings
local heroChaseRange       = 600   -- how far a champ has to be from opponents to be considered roaming
local heroVisibleThreshold = 100   -- minimum time in ms a hero has to be visible again to get pinged

-- Globals ---------------------------------------------------------------------

local herosVisible = {}
local herosPinged  = {}
local plannedPings = {}
local lastPing     = nil
local mapPosition  = nil

-- Code ------------------------------------------------------------------------

function OnLoad()
    lastPing = GetTickCount()

    for i=1, heroManager.iCount, 1 do
        herosVisible[i] = GetTickCount()
        herosPinged[i]  = GetTickCount()
        plannedPings[i] = false
    end

    mapPosition = MapPosition()

    PerfectPingConfig = scriptConfig("Perfect Ping", "perfectPing")
    PerfectPingConfig:addParam("enabled", "Perfect Ping", SCRIPT_PARAM_ONOFF, true)
    PerfectPingConfig:addParam("useFallback", "Use Fallback Pings", SCRIPT_PARAM_ONOFF, true)
    PerfectPingConfig:permaShow("enabled")

    PerfectPingConfig.enabled = true

    PrintChat(" >> Perfect Ping loaded")
end

function OnTick()
    if not autodisabled and GetInGameTimer() > autoDisableTime then
        autodisabled = true
        PerfectPingConfig.enabled = false

        PrintChat(" >> Perfect Ping disabled (automatically)")
    end

    if PerfectPingConfig.enabled then
        for i=1, heroManager.iCount, 1 do
            hero = heroManager:getHero(i)

            if plannedPings[i] then
                herosVisible[i] = GetTickCount()
                if hero ~= nil and hero.visible and hero.team ~= myHero.team then
                    if GetTickCount() - plannedPings[i] >= heroVisibleThreshold then
                        Packet('S_PING', {
                            x = hero.x,
                            y = hero.z,
                            target = hero,
                            type = PerfectPingConfig.useFallback and PING_FALLBACK or PING_NORMAL
                        }):send()

                        lastPing = GetTickCount()
                        herosPinged[i] = GetTickCount()
                        purgePlannedPings()
                    end
                else
                    plannedPings[i] = false
                end
            else
                if hero ~= nil and hero.visible and hero.team ~= myHero.team then
                    if GetTickCount() - herosVisible[i] >= heroVisibleTimeout and GetTickCount() - herosPinged[i] >= heroPingTimeout and GetTickCount() - lastPing >= pingTimeout and (mapPosition:inInnerJungle(hero) or mapPosition:inInnerRiver(hero)) and not EnemyHeroInRange(hero, heroChaseRange) then
                        plannedPings[i] = GetTickCount()
                    end

                    herosVisible[i] = GetTickCount()
                end
            end
        end
    end
end

function EnemyHeroInRange(hero, range)
    for j=1, heroManager.iCount, 1 do
        hero1 = heroManager:getHero(j)
        if hero1.team ~= hero.team and GetDistance(hero, hero1) <= range then
            return true
        end
    end

    return false
end

function purgePlannedPings()
    for i=1, heroManager.iCount, 1 do
        plannedPings[i] = false
    end
end

SForcedSync = SForcedSync or {}
SForcedSync.Client = {}
local syncInterval = 5
local timeSinceLastSync = 0

local function ForceSyncEvery5Sec()
    local player = getPlayer()
    if not player then return end
    timeSinceLastSync = timeSinceLastSync + getGameTime():getMultiplier() / 60
    if timeSinceLastSync >= syncInterval then
        timeSinceLastSync = 0

        local args = { 
            x = player:getX(), 
            y = player:getY(), 
            z = player:getZ() 
        }

        sendClientCommand(player, 'playersync', 'forcesyncaround', args)
    end
end

Events.OnTick.Add(ForceSyncEvery5Sec)
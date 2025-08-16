require 'Items/ProceduralDistributions'
local function AddLootToType(itemName, containerName, itemChance)
    local containerData = ProceduralDistributions.list[containerName]
    if not containerData then
        print("[Hephas Mod] Warning: Container not found - " .. tostring(containerName))
        return
    end

    table.insert(containerData.items, itemName);
    table.insert(containerData.items, itemChance);
end

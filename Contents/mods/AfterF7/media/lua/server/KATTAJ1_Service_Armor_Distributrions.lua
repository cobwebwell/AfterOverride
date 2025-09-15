----------------------------------------------------------------------------
----------------------------- KATTAJ1 - TTAJ1bl4 ---------------------------
----------------------------------------------------------------------------

require "Items/ProceduralDistributions"


function KATTAJ1_Service_insertItemSetsIntoDistributions(itemSets, suffixes, spawnChances, distributionNames)
    local currentIndex = 1 

    for _, distributionName in ipairs(distributionNames) do
        local distribution = ProceduralDistributions.list[distributionName]

        for i, itemSet in ipairs(itemSets) do
            local baseItem = itemSet.baseItem
            local continuation = itemSet.continuation or ""

            for _, suffix in ipairs(suffixes) do
                local fullItem = "Base." .. baseItem .. suffix .. continuation

                local currentSpawnChance = spawnChances[currentIndex]
                currentIndex = (currentIndex % #spawnChances) + 1

                table.insert(distribution.items, fullItem)
                table.insert(distribution.items, currentSpawnChance)
            end
        end
    end
end

--[[
Service_Jacket_Classic-Green
Service_Pants_Classic-Brown
Service_Shirt_Classic-Brown
Service_Shoes_Classic-Brown
Service_Skirt_Classic-Brown

Service_Patch_PFC
Service_Patch_SPC
Service_Patch_CPL
Service_Patch_SGT
Service_Patch_SSG
Service_Patch_SFC
Service_Patch_2LT
Service_Patch_1LT
Service_Patch_CPT
Service_Patch_MAJ
]]
--[[ local emptySuffixes = {""} 

-- Sandbox Spawn Chances
local spawnChancesServiceUniform = {0.02} 
 
local distributionNames = {"ArmySurplusOutfit", "LockerArmyBedroom", "ArmyStorageOutfit"} 

local itemSets = { 
 
    { baseItem = "Service_Jacket_Classic-Green" }, 
   
    { baseItem = "Service_Pants_Classic-Brown" }, 
  
    { baseItem = "Service_Shirt_Classic-Brown" }, 

    { baseItem = "Service_Shoes_Classic-Brown" }, 
 
    { baseItem = "Service_Skirt_Classic-Brown" }
} 
KATTAJ1_Service_insertItemSetsIntoDistributions(itemSets, emptySuffixes, spawnChancesServiceUniform, distributionNames)

local itemSets1 = { 

    { baseItem = "Service_Patch_PV2" },

    { baseItem = "Service_Patch_PFC" }, 
  
    { baseItem = "Service_Patch_SPC" }, 

    { baseItem = "Service_Patch_CPL" }, 

    { baseItem = "Service_Patch_SGT" }, 

    { baseItem = "Service_Patch_SSG" }, 

    { baseItem = "Service_Patch_SFC" },

    { baseItem = "Service_Patch_2LT" }, 

    { baseItem = "Service_Patch_1LT" }, 

    { baseItem = "Service_Patch_CPT" }, 

    { baseItem = "Service_Patch_SFC" }

} 
KATTAJ1_Service_insertItemSetsIntoDistributions(itemSets1, emptySuffixes, spawnChancesServiceUniform, distributionNames) --]]

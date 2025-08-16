require "HSP_CustomTimedActions"

StalkerPDA = {}
StalkerPDA.openedViaPDA = false
StalkerPDA.original_ISWorldMap_close = nil
StalkerPDA.original_ISReadWorldMap_start = nil
StalkerPDA.original_ISReadWorldMap_perform = nil

-- Open Map with custom sound and prevent any vanilla timed action for instant opening
function StalkerPDA.onShowMap(item, playerObj)
    if not playerObj then return end
    local player = getSpecificPlayer(playerObj:getPlayerNum())
    if not player then return end
    
    -- Add PDA Map Tool for enabling map interaction
    local inv = player:getInventory()
    if not inv:containsType("Hephas_PDAMapTool") then
        inv:AddItem("Base.Hephas_PDAMapTool")
    end

    player:getEmitter():playSound("PDAInteraction")
    StalkerPDA.openedViaPDA = true

    local centerX = player:getX()
    local centerY = player:getY()
    local zoom = 20

    ISTimedActionQueue.clear(player)
    local mapAction = ISReadWorldMap:new(player, centerX, centerY, zoom)
    mapAction.maxTime = 1
    ISTimedActionQueue.add(mapAction)

    --print("Map shown from Stalker PDA.")
end

-- Toggle MiniMap only with PDA 
function StalkerPDA.toggleMiniMapWithPDARequirement(item, playerObj)
    if not playerObj then return end

    local playerNum = playerObj:getPlayerNum()

    -- Play sound manually if sandbox does not override the function
    if SandboxVars.HSP and SandboxVars.HSP.OnlyAllowPDAMinimap ~= true then
        local minimap = getPlayerMiniMap(playerNum)
        if minimap and minimap:isReallyVisible() then
            playerObj:getEmitter():playSound("PDAMinimap") -- closing
        else
            playerObj:getEmitter():playSound("PDAMinimap") -- opening
        end
    end

    -- Then toggle the minimap
    ISMiniMap.ToggleMiniMap(playerNum)
end

-- Weather Forecaster 
function StalkerPDA.getWeatherForecast(item, playerObj)
    if not playerObj then 
        --print("No player object provided.")
        return 
    end

    local clim = getWorld():getClimateManager()
    local forecaster = clim:getClimateForecaster()
    local forecasts = forecaster:getForecasts()

    if not forecasts or forecasts:size() == 0 then
        playerObj:Say(getText("UI_StalkerPDA_WeatherUnavailable"))
        return
    end

    -- Adjusting indices based on the 10-day offset
    local todayIndex = 10
    local tomorrowIndex = todayIndex + 1

    local tomorrowForecast = forecasts:get(tomorrowIndex)

    if not tomorrowForecast then
        playerObj:Say(getText("UI_StalkerPDA_WeatherUnavailableTomorrow"))
        return
    end

    -- Fetch values safely for tomorrow
    local temperatureDayMeanTomorrow = tomorrowForecast:getTemperature() and tomorrowForecast:getTemperature():getDayMean() or 0
    local temperatureNightMeanTomorrow = tomorrowForecast:getTemperature() and tomorrowForecast:getTemperature():getNightMean() or 0

    -- Fahrenheit toggle from sandbox provided addition by ᴀxᴠʟʟ
    local useFahrenheit = SandboxVars.HSP and SandboxVars.HSP.UseFahrenheit
    local function cToF(c) return (c * 9 / 5) + 32 end

    if useFahrenheit then
        temperatureDay = cToF(temperatureDayMeanTomorrow)
        temperatureNight = cToF(temperatureNightMeanTomorrow)
    else
        temperatureDay = temperatureDayMeanTomorrow or 0
        temperatureNight = temperatureNightMeanTomorrow or 0
    end
    --local temperatureDay = useFahrenheit and cToF(temperatureDayMeanTomorrow) or temperatureDayMeanTomorrow
    --local temperatureNight = useFahrenheit and cToF(temperatureNightMeanTomorrow) or temperatureNightMeanTomorrow

    -- Get °C or °F from translation file
    local unitLabel = useFahrenheit and getText("UI_StalkerPDA_Fahrenheit") or getText("UI_StalkerPDA_Celsius")
    
    -- Ensure correct formatting for temperatures
    -- To-Do for later: Render ° correctly
    local formattedDayTemp = string.format("%.1f %s", temperatureDay, unitLabel)
    local formattedNightTemp = string.format("%.1f %s", temperatureNight, unitLabel)

    -- Rain handling
    local rainTomorrow = getText("UI_StalkerPDA_NoRain")
    if tomorrowForecast:isHasHeavyRain() then
        rainTomorrow = getText("UI_StalkerPDA_HeavyRain")
    end

    -- Other weather conditions
    local stormTomorrow = tomorrowForecast:isHasStorm() and "Yes" or "No"
    local blizzardTomorrow = tomorrowForecast:isHasBlizzard() and "Yes" or "No"
    local tropicalStormTomorrow = tomorrowForecast:isHasTropicalStorm() and "Yes" or "No"

    -- Snow handling
    local snowTomorrow = tomorrowForecast:isChanceOnSnow() and "Yes" or "No"

    -- Fog handling
    local fogConditionTomorrow = "No"
    if tomorrowForecast:isHasFog() then
        local fogStrengthTomorrow = tomorrowForecast:getFogStrength() or 0
        if fogStrengthTomorrow > 0.7 then
            fogConditionTomorrow = getText("UI_StalkerPDA_HeavyFog")
        elseif fogStrengthTomorrow > 0.3 then
            fogConditionTomorrow = getText("UI_StalkerPDA_LightFog")
        else
            fogConditionTomorrow = getText("UI_StalkerPDA_ThinFog")
        end
    end

    -- Message Assembly
    local weatherMessage = string.format(
        getText("UI_StalkerPDA_TomorrowTemperature"), formattedDayTemp, formattedNightTemp)

    local conditions = {}

    if rainTomorrow ~= getText("UI_StalkerPDA_NoRain") then
        table.insert(conditions, rainTomorrow)
    end
    if snowTomorrow == "Yes" then
        table.insert(conditions, getText("UI_StalkerPDA_HeavySnow"))
    end
    if fogConditionTomorrow ~= "No" then
        table.insert(conditions, fogConditionTomorrow)
    end
    if stormTomorrow == "Yes" then
        table.insert(conditions, getText("UI_StalkerPDA_Storm"))
    end
    if blizzardTomorrow == "Yes" then
        table.insert(conditions, getText("UI_StalkerPDA_Blizzard"))
    end
    if tropicalStormTomorrow == "Yes" then
        table.insert(conditions, getText("UI_StalkerPDA_TropicalStorm"))
    end

    playerObj:getEmitter():playSound("PDANews")
    playerObj:Say(weatherMessage)
    --print("Generated weather message: " .. weatherMessage)

    if #conditions > 0 then
        local conditionsMessage = getText("UI_StalkerPDA_Conditions") .. " " .. table.concat(conditions, ", ") .. "."
        playerObj:Say(conditionsMessage)
    else
        playerObj:Say(getText("UI_StalkerPDA_NoSignificantWeather"))
    end
    --print("Tomorrow's weather forecast displayed on PDA.")
end


-- PDA Context Menu
function StalkerPDA.onContextMenu(playerIndex, context, items)
    local actualItems = ISInventoryPane.getActualItems(items)
    local playerObj = getSpecificPlayer(playerIndex)
    if not playerObj then return end

    for _, item in ipairs(actualItems) do
        if item:getType() == "Hephas_StalkerPDA" then
            local interactOption = context:addOption(getText("ContextMenu_Interact"), items, nil)
            local subMenu = ISContextMenu:getNew(context)
            context:addSubMenu(interactOption, subMenu)

            subMenu:addOption(getText("ContextMenu_ShowMap"), item, StalkerPDA.onShowMap, playerObj)
            if SandboxVars.Map and SandboxVars.Map.AllowMiniMap then
                subMenu:addOption(getText("ContextMenu_ShowMiniMap"), item, StalkerPDA.toggleMiniMapWithPDARequirement, playerObj)
            end
            subMenu:addOption(getText("ContextMenu_GetWeatherForecast"), item, StalkerPDA.getWeatherForecast, playerObj)
            -- Good example for future use
            --local flashlightLabel = item:isTorchCone() and getText("ContextMenu_TurnFlashlightOff") or getText("ContextMenu_TurnFlashlightOn")
            --subMenu:addOption(flashlightLabel, item, StalkerPDA.toggleFlashlight, playerObj)
        end
    end
end


-- Override for ISWorldMap:close because I cant find a way to properly hook the vanilla version
local function overrideWorldMapClose()
    if StalkerPDA.original_ISWorldMap_close then
        return -- already hooked
    end

    StalkerPDA.original_ISWorldMap_close = ISWorldMap.close

    function ISWorldMap:close()
        self:saveSettings()
        self.symbolsUI:undisplay()
        if self.forgetUI then
            self.forgetUI.no:forceClick()
        end
        --self:closePrintMedia() Doesnt exist in B41
        self:setVisible(false)
        self:removeFromUIManager()

        if getSpecificPlayer(0) then
            getWorld():setDrawWorld(true)
        end

        for i = 1, getNumActivePlayers() do
            if getSpecificPlayer(i - 1) then
                getSpecificPlayer(i - 1):setBlockMovement(false)
            end
        end

        if JoypadState.players[self.playerNum + 1] then
            setJoypadFocus(self.playerNum, self.prevFocus)
        end

        if MainScreen.instance and not MainScreen.instance.inGame then
            self:setHideUnvisitedAreas(true)
            ISWorldMap_instance = nil
            WorldMapVisited.Reset()
        end

        --Remove PDA Map Tool from inventory
        if self.character then
            local inv = self.character:getInventory()
            local tool = inv:FindAndReturn("Base.Hephas_PDAMapTool")
            if tool then inv:Remove(tool) end
        end

        -- Custom sound handling
        if self.character then
            if StalkerPDA.openedViaPDA then
                self.character:getEmitter():playSound("PDATip")
            else
                self.character:playSoundLocal("MapClose")
            end
        end

        -- Reset PDA flag
        StalkerPDA.openedViaPDA = false
    end
end

-- Prevent MapOpen sound and block map if not via PDA
local function overrideWorldMapStart()
    if StalkerPDA.original_ISReadWorldMap_start then
        return -- already hooked
    end

    StalkerPDA.original_ISReadWorldMap_start = ISReadWorldMap.start

    function ISReadWorldMap:start()
        -- Restrict access if sandbox option is active
        if SandboxVars.HSP.OnlyAllowPDAMap == true and not StalkerPDA.openedViaPDA then
            if self.character then
                self.character:Say(getText("UI_StalkerPDA_MapAccess"))
            end
            return -- Block map open
        end

        -- Normal animation and sound
        self:setAnimVariable("ReadType", "newspaper")
        self:setActionAnim(CharacterActionAnims.Read)
        self:setOverrideHandModelsString(nil, "MapInHand")

        if not StalkerPDA.openedViaPDA then
            self.character:playSoundLocal("MapOpen")
        end
    end
end

-- Prevent performing action and the opening animation. 
local function overrideWorldMapPerform()
    if StalkerPDA.original_ISReadWorldMap_perform then
        return -- already hooked
    end

    StalkerPDA.original_ISReadWorldMap_perform = ISReadWorldMap.perform

    function ISReadWorldMap:perform()
        -- Restrict access if sandbox option is active
        if SandboxVars.HSP.OnlyAllowPDAMap == true and not StalkerPDA.openedViaPDA then
            -- Just end the action quietly (we already said "no" in start())
            self:forceStop()
            return
        end

        -- Normal map open
        ISWorldMap.ShowWorldMap(self.playerNum, self.centerX, self.centerY, self.zoom)
        ISBaseTimedAction.perform(self)
    end
end

-- Override MiniMapToggle 
local function overrideMiniMapToggle()
    -- Only override if PDA minimap restriction is enabled
    if not (SandboxVars.HSP and SandboxVars.HSP.OnlyAllowPDAMinimap) then
        --print("[HSP] Skipping MiniMap override: OnlyAllowPDAMinimap is disabled.")
        return
    end

    if ISMiniMap.original_ToggleMiniMap then return end
    --print("[HSP] Overriding ISMiniMap.ToggleMiniMap")

    ISMiniMap.original_ToggleMiniMap = ISMiniMap.ToggleMiniMap

    function ISMiniMap.ToggleMiniMap(playerNum, forceClose)
        local playerObj = getSpecificPlayer(playerNum)
        if not playerObj then return end

        -- Only enforce PDA restriction if not force closing
        if not forceClose then
            local inv = playerObj:getInventory()
            local pda = inv and inv:FindAndReturn("Hephas_StalkerPDA")

            if not pda then
                playerObj:Say(getText("UI_StalkerPDA_MinimapRequiresPDA"))
                return
            end

            local inPrimary = playerObj:getPrimaryHandItem()
            if inPrimary ~= pda then
                local fromContainer = pda:getContainer()
                if fromContainer and fromContainer ~= playerObj:getInventory() then
                    ISTimedActionQueue.add(ISInventoryTransferAction:new(playerObj, pda, fromContainer, playerObj:getInventory(), 0))
                end
                ISTimedActionQueue.add(ISEquipWeaponAction:new(playerObj, pda, 50, true, false))
                ISTimedActionQueue.add(ISAfterEquipMiniMapToggle:new(playerObj))
                return
            end
        end

        -- Only play PDA sound when toggled by player (not forceClose)
        if not forceClose then
            local minimap = getPlayerMiniMap(playerNum)
            local isVisible = minimap and minimap:isReallyVisible()
            playerObj:getEmitter():playSound("PDAMinimap")
        end

        -- Actually toggle the minimap
        ISMiniMap.original_ToggleMiniMap(playerNum, forceClose)
    end
end



-- Enable and disable logic on equipping PDA 
local function onPDAEquipped(playerObj, item)
    if not playerObj then return end

    -- Light toggle logic
    local inv = playerObj:getInventory()
    local pda = inv:FindAndReturn("Hephas_StalkerPDA")

    if item and item:getType() == "Hephas_StalkerPDA" then
        item:setTorchCone(false)
        item:setLightDistance(2)
        item:setLightStrength(0.2)
    elseif pda then
        pda:setTorchCone(false)
        pda:setLightDistance(0)
        pda:setLightStrength(0)
    end

    --  Force minimap off if PDA is not equipped in primary
    -- Only enforce forced minimap toggle if sandbox restriction is active
    if SandboxVars.HSP and SandboxVars.HSP.OnlyAllowPDAMinimap == true
    and SandboxVars.Map and SandboxVars.Map.AllowMiniMap == true then

        local primary = playerObj:getPrimaryHandItem()
        if (not primary or primary:getType() ~= "Hephas_StalkerPDA") then
            local minimap = getPlayerMiniMap(playerObj:getPlayerNum())
            if minimap and minimap:isReallyVisible() then
                ISMiniMap.ToggleMiniMap(playerObj:getPlayerNum(), true) --forceClose = true
                --playerObj:Say(getText("UI_StalkerPDA_MinimapClosedUnequipped"))
            end
        end
    end
end


-- Force minimap off after everything is initialized (single-use)
local function delayedMinimapForceOff()
    for i = 0, getNumActivePlayers() - 1 do
        local player = getSpecificPlayer(i)
        if player
        and SandboxVars.Map and SandboxVars.Map.AllowMiniMap
        and SandboxVars.HSP and SandboxVars.HSP.OnlyAllowPDAMinimap == true then

            --print("[HSP]  Delayed tick: Forcing minimap off for player " .. tostring(i))

            local minimap = getPlayerMiniMap(i)
            if minimap and minimap:isReallyVisible() then
                ISMiniMap.ToggleMiniMap(i, true) -- Force close
                --print("[HSP]  Delayed tick: Minimap toggled off.")
            else
                --print("[HSP]  Delayed tick: Minimap was already off.")
            end

            if i == 0 then
                local settings = WorldMapSettings.getInstance()
                settings:setBoolean("MiniMap.StartVisible", false)
                --print("[HSP] Delayed tick: Set MiniMap.StartVisible = false")
            end
        end
    end

    -- Remove this function after it runs once
    Events.OnTick.Remove(delayedMinimapForceOff)
end



-- Hook into game events
Events.OnTick.Add(delayedMinimapForceOff)

Events.OnEquipPrimary.Add(onPDAEquipped)
Events.OnEquipSecondary.Add(onPDAEquipped)

Events.OnGameStart.Add(overrideMiniMapToggle)
Events.OnGameStart.Add(overrideWorldMapClose)
Events.OnGameStart.Add(overrideWorldMapStart)
Events.OnGameStart.Add(overrideWorldMapPerform)


Events.OnFillInventoryObjectContextMenu.Add(StalkerPDA.onContextMenu)

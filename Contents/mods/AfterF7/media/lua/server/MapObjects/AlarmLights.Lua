AllAlarmLights = {}
tickCount = 0

if isClient() then return end

local function noise(message) print('AlarmLights.lua: '..message) end

--[[
Thoughts on How to proceed:
Create my own light classes using the IsoLightSource, need to create it and figure out how to make it appear in the world
Load in a lightswitch asset and go from there?
]]--

local function CreateObject(square, spriteName, direction) -- Doesn't work
	local modData = {}
	--modData["need:Base.Plank"] = "2"
	--modData["need:Base.Rope"] = "1"
	--modData["need:Base.Nails"] = "4"
	--modData["need:Base.Torch"] = "1"

	local cell = getWorld():getCell()
	local north = false
	local javaObject = IsoThumpable.new(cell, square, spriteName, north, modData)

	
	javaObject:setCanPassThrough(false)
	javaObject:setCanBarricade(false)
	javaObject:setIsContainer(false)
	javaObject:setIsDoor(false)
	javaObject:setIsDoorFrame(false)
	javaObject:setCrossSpeed(1.0)
	javaObject:setBlockAllTheSquare(false)
	javaObject:setName("Emergency Lights")
	javaObject:setIsDismantable(true)
	javaObject:setCanBePlastered(false)
	javaObject:setIsHoppable(false)
	javaObject:setIsThumpable(false)
	--javaObject:setModData(copyTable(modData))
	javaObject:setMaxHealth(200)
	javaObject:setHealth(200)
	javaObject:setBreakSound("BreakObject")
	javaObject:setSpecialTooltip(false)
	

	
	-- light stuff
	local offsetX = 0
	local offsetY = 0
	--[[if direction == "E" then
		offsetX = -1
	elseif direction == "W" then
		offsetX = 1
	elseif direction == "S" then
		offsetY = -1
	elseif direction == "N" then
		offsetY = 1
	end]]--
	
	javaObject:createLightSource(2, offsetX, offsetY, 0, 0, "Base.Battery", nil, nil)

	--local newLight = IsoLightSource.new(square:getX(), square:getY(), square:getZ(),255,0,0,3)
	--[[if newLight ~= nil then
	print("New light created!!!!")
	javaObject:setLightSource(newLight)
	lightSource = javaObject:getLightSource()
	end]]--
	

	
	--Light functions inside IsoThumpable
	--setLightSourceRadius(integar)
	-- local lightSource = javaObject:getLightSource() returns a light source
	-- setLightSource(light source) sets the light to the light parameter
	-- Perhaps something like:
	--[[
	local lightSource = javaObject:getLightSource()
	lightSource:setR(float)
	lightSource:setG(float)
	lightSource:setB(float)
	]]--
	
	
	local fuel = InventoryItemFactory.CreateItem("Base.Battery")
	if fuel then
		fuel:setUsedDelta(1.0)
		local previous = javaObject:insertNewFuel(fuel, nil)
	end
	
	local lightSource = javaObject:getLightSource()
	if lightSource ~= nill then
	print("It worked!!!!!!!!")
	end

	return javaObject
end

--Replaces the base sprite placed in tilezed with the actual javaObject so it can be given the custom code
local function ReplaceExistingObject(isoObject, dir) -- Not being used

	local cell = getWorld():getCell()
	local sq = isoObject:getSquare()
	noise('replacing isoObject at '..sq:getX()..','..sq:getY()..','..sq:getZ())
	local javaObject = CreateObject(sq, isoObject:getSprite():getName(), dir)
	
	local index = isoObject:getObjectIndex()
	sq:transmitRemoveItemFromSquare(isoObject)
	sq:AddSpecialObject(javaObject, index)
	javaObject:transmitCompleteItemToClients()
	
	for i=0,sq:getSpecialObjects():size()-1 do
		local object = sq:getSpecialObjects():get(i)
		if object and instanceof(object, 'IsoThumpable') and object:getLightSourceFuel() then
			object:getLightSourceFuel()
			print("Light was found")
		end
		print("Loopity")
	end

	
end

local function ObjectInstantiate(isoObject, direction)
	local cell = getWorld():getCell()
	local sq = isoObject:getSquare()
	noise('Alarm Light isoObject at '..sq:getX()..','..sq:getY()..','..sq:getZ())
	local object = isoObject:getSprite():getName()
	
	if instanceof(isoObject, "IsoLightSwitch") then
		noise('Alarm Light is a Light Switch')
		local lights = isoObject:getLights()
		lights:get(0):setR(220)
		lights:get(0):setRadius(3)
		--lights:get(0):setActive(true)
		table.insert(AllAlarmLights, isoObject)
		--Events.EveryTenMinutes.Add(ToggleRadius(lights:get(0), 3, 10)) --This works, but is only triggered once
	end
end

function ToggleAllAlarmLights()
	
	--[[for key, value in pairs(AllAlarmLights) do
		noise('Alarm Light toggling at '..value:getX()..','..value:getY()..','..value:getZ())
		ToggleRadius(val, 3, 10)
	end]]--
	
	if tickCount >= 100 then
		noise('Toggling')
		for key in pairs(AllAlarmLights) do
			
			if AllAlarmLights[key]:getLights() ~= nil then
				ToggleRadius(AllAlarmLights[key], 1, 3)
			end
		end
		tickCount = 0
	else
		tickCount = tickCount + 1
	end
end

function ToggleRadius(isoObject, minRadius, maxRadius)

	--if instanceof(isoLight, "IsoLightSource") then
	local isoLight = isoObject:getLights():get(0)
	--isoObject:toggle() actually flips the light on and off, not quite what I want
	
	local radius = isoLight:getRadius()
	
	noise('Alarm IsoLightSource at '..isoLight:getX()..','..isoLight:getY()..','..isoLight:getZ())
	
	noise('Alarm IsoLightSource radius was '..radius)
	
	if radius <= minRadius then --This sets the radius, but the visual never changes
		isoLight:setRadius(maxRadius)
		isoObject:switchLight(true)
	elseif radius >= maxRadius then
		isoLight:setRadius(minRadius)
		isoObject:switchLight(false)
	end
	
	isoObject:update()
	
	
	--isoObject:sendObjectChange('switchLight', {paramBoolean = isoLight:isActive()})
	--isoObject:sendObjectChange('toggle')
	--isoObject:sendObjectChange('lightRoom')
	--isoObject:sendObjectChange('lights[0]')
	noise('Alarm IsoLightSource radius is now '..isoLight:getRadius())
	--else
	--noise('Alarm IsoLightSource not found is')
	--end
end

local function NewObjectN(isoObject)
	ObjectInstantiate(isoObject, "N")
end
local function NewObjectS(isoObject)
	ObjectInstantiate(isoObject, "S")
end
local function NewObjectW(isoObject)
	ObjectInstantiate(isoObject, "W")
end
local function NewObjectE(isoObject)
	ObjectInstantiate(isoObject, "E")
end

local PRIORITY = 5

--For each sprite when it is loaded on the map, call the corresponding function with the set priority

MapObjects.OnNewWithSprite("spy_facility7_0_16", NewObjectN, PRIORITY)
MapObjects.OnNewWithSprite("spy_facility7_0_18", NewObjectS, PRIORITY)
MapObjects.OnNewWithSprite("spy_facility7_0_17", NewObjectW, PRIORITY)
MapObjects.OnNewWithSprite("spy_facility7_0_19", NewObjectE, PRIORITY)



--MapObjects.OnLoadWithSprite("spy_facility7_0_16", NewObjectN, PRIORITY)
--MapObjects.OnLoadWithSprite("spy_facility7_0_18", NewObjectS, PRIORITY)
--MapObjects.OnLoadWithSprite("spy_facility7_0_17", NewObjectW, PRIORITY)
--MapObjects.OnLoadWithSprite("spy_facility7_0_19", NewObjectE, PRIORITY)

--Events.OnTick.Add(ToggleAllAlarmLights)
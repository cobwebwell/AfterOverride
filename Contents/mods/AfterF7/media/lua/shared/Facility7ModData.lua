function initFacility7ModData()
	local modData = ModData.getOrCreate("Facility7Data")
	if not modData.insurgentObjIndex then
		modData.insurgentObjIndex = 0
	end

	if not modData.insurgentObjMaxIndex then
		modData.insurgentObjMaxIndex = 5
	end

	if not modData.FacilityDynamicRadio then
		--modData.FacilityDynamicRadio = {};
	end

	print("Facility-7 Mod Data has been initialized!");
end

function getFacility7ModData()
	local modData = ModData.get("Facility7Data")
	return modData
end

Events.OnInitGlobalModData.Add(initFacility7ModData)
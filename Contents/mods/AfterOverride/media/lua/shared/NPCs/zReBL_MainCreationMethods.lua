if getActivatedMods():contains("zReS_ProfReworkbykERHUS") then return end

zReBLBaseGameCharacterDetails = {}

zReBLBaseGameCharacterDetails.DoTraits = function()

	local nimblefingers = TraitFactory.addTrait("Çilingir", getText("UI_trait_nimblefingers"), 10, getText("UI_trait_nimblefingersDesc"), false);
	nimblefingers:addXPBoost(Perks.Lockpicking, 2)
	nimblefingers:getFreeRecipes():add("Lockpicking");
	nimblefingers:getFreeRecipes():add("Alarm check");
	nimblefingers:getFreeRecipes():add("Create BobbyPin");
	nimblefingers:getFreeRecipes():add("Create BobbyPin2");
	
	TraitFactory.sortList();	
	local traitList = TraitFactory.getTraits()
	for i = 1, traitList:size() do
		local trait = traitList:get(i - 1)
		BaseGameCharacterDetails.SetTraitDescription(trait)
	end

end

Events.OnGameBoot.Add(zReBLBaseGameCharacterDetails.DoTraits);
Events.OnGameBoot.Add(zReBLBaseGameCharacterDetails.DoProfessions);
Events.OnCreateLivingCharacter.Add(zReBLBaseGameCharacterDetails.DoProfessions);
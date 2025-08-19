function SFForage_AddProfession()
    local scavenger = TraitFactory.addTrait("Hurdacý", getText("UI_trait_Scavenger"), 5, getText("UI_trait_ScavengerDesc"), false);
	scavenger:addXPBoost(Perks.PlantScavenging, 3);
	
	TraitFactory.sortList();
	BaseGameCharacterDetails.SetTraitDescription(scavenger)
end

Events.OnGameBoot.Add(SFForage_AddProfession);
-- define here all the clothing that'll be available for a specific profession.
-- the default will always been available
ClothingSelectionDefinitions["insurgent"] = {
	Female = {
		Tshirt = {
			items = {"Base.Tshirt_Profession_VeterenGreen", "Base.Tshirt_Profession_VeterenRed", "Base.Tshirt_CamoGreen", "Base.Tshirt_CamoDesert", "Base.Tshirt_CamoUrban"},
		},

		Shirt = {
			chance = 50,
			items = {"Base.Shirt_CamoGreen","Base.Shirt_CamoDesert","Base.Shirt_CamoUrban"},
		},

		TorsoExtra = {
			chance = 10,
			items = {"Base.Vest_BulletArmy", "Base.Vest_Hunting_Camo", "Base.Vest_Hunting_CamoGreen"},
		},
		
		Pants = {
			items = {"Base.Shorts_CamoGreenLong", "Base.Trousers_CamoGreen", "Base.Trousers_CamoDesert","Base.Shorts_CamoUrbanLong", "Base.Trousers_CamoUrban"},
		},
		
		Shoes = {
			items = {"Base.Shoes_ArmyBoots", "Base.Shoes_ArmyBootsDesert"},
		},

		Hat = {
			chance = 10,
			items = {"Base.Hat_BonnieHat", "Base.Hat_BonnieHat_CamoGreen", "Base.Hat_Beret", "Base.Hat_Army", "Base.Hat_BandanaTiedTINT", "Base.Hat_BalaclavaFull", "Base.Hat_BaseballCapArmy", "Base.Hat_BeretArmy"},
		},

		Jacket = {
			chance = 20,
			items = {"Base.Jacket_ArmyCamoGreen", "Base.Jacket_ArmyCamoDesert"},
		},

		Mask = {
			items = {"Base.Hat_GasMask"},
		},

	},
}
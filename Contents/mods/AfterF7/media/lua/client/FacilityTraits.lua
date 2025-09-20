require('NPCs/MainCreationMethods');
require('OptionScreens/CharacterCreationProfession');
require('OptionScreens/CoopCharacterCreation');
require('OptionScreens/NewGameScreen');
require('TimedActions/ISDestroyStuffAction');
require('XpSystem/XpUpdate');
require"ISUI/ISPanel"
require"ISUI/ISButton"
require"ISUI/ISInventoryPane"
require"ISUI/ISResizeWidget"
require"ISUI/ISMouseDrag"

require"defines"

--[[
LUA notes:
There are NO classes, just objects
Arrays start at 1!!!
table.insert for adding to lists

==================================
TRAITS TO ADD:
+Wasted Potential: "You could have been so much more..." - On level up, random chance to lose a skill
+Untapped Potential: "Your abilities and talents are far greater than you've ever realized..." - On level up, random chance to gain a skill/XP
Unstable Genetics: "Your genes were spliced incorrectly, and are prone to change. Change results in mutation sickness" - Random chance to add or remove traits, will result in mutation sickness (pain, nausea, muscle stiffness?)
Forgetful: "May forget recipes at random" - Random chance to forget learned recipes
Undeveloped: "Not given enough time in tube, your body and mind is a bit undeveloped" - ???
immunocompromised: - EXTREME chance of infection and sickness, do not get hurt, do not get bloody
+Necrotic: "Your body is in a constant state of self destruction" - randomly recieve small injuries and pain
+Amnesiac: "Who am I?" - Hide name, all starting traits and skills start empty. Slowly regain them as you play.
Anhidrosis: "You can't sweat. Cooling is hard." - No sweating, easier overheating, and lower exertion?
Frog-Skin/Amphibious: "" - can't sweat, needs to be wet. Water level increases abilities?
+High-Strung: "You're naturally very anxious." - Being near zombies makes you extremely anxious, gain anxiety slowly.
+Hematophage: "Blood empowers you." - Damage bonus for every body part bleeding. Blood covered levels increases damage. ~ Cancels hemophiliac
+Night Terror: "The darkness turns you into a monster." - Extremely powerful when in the dark, weak in the light?
+(Buggy)Split-Personalities: "There are two different people in your head." - Store a set of two different personalities, every X hours, change. Change is sped up by high stress or head injuries. Second personality has same number of traits as the original (excluding stat traits). Will switch to the opposite of any and all that have it. Otherwise, will randomly select another trait. Antidepressants delay the switch.
+Emotionless: "Your limbic cortex has been artificially modified. You experience almost no emotion." - Emotions max out at 0.15 (15%). Anything greater than that causes a headache and resets to 0.1. ~ Cancels Cowardly/Brave/
Broken Mind: "You've already snapped." - Extremely desensitized/crazy? Constant mood swings, panic attacks, stress.
Beserker: "Killing is your calling" - Get stronger and stronger while killing enemies. Increased exersion? Character will say phrase if on a killing streak.
+Blood Frenzy: "The adrenaline of combat makes you stronger." - Attacking consecutively makes you deal more damage.
Disheartened Killer: "You kill with a heavy heart." - become sad when you kill zombies/players.
Sleeper Agent: "" - ???
Pheromonic: "They can smell your fear, they can smell your weakness." - Attract attention when you're bleeding, highly panicked, or sweating?, would play a small "sound" near you, depending on how bad the blood loss is
???: "" - Can only drink. Can't eat solid foods.
+Running N' Gunning: "Trained for quick combat, movement has no penalty on aiming." - Aiming firearms is not/barely effected by movement.
Catatonic: "May go into shock under high stress." - Becomes immobile/slow when super panicked/stressed.
Relentless: "You know how to push your physical limits." - Slow loss of exersion/fatigue when in dangerous situations; Low HP, lots of spotted enemies
Commander: "Others can push themselves much further with your aid." - When in danger, slow loss of exersion/fatigue for players around you. Slow other's bleeding when near you. Does not effect other commanders.
Telekinetic: "Can interact with distant objects." - Allows for opening of doors, picking up/placing objects, interacting with objects, from further away. Is very mentally taxing, limited "Mana", adds fatigue. Mana drains quickly when hurt/tired. If out of mana then you have to wait for it to recharge. Using mana while reserves are low/tired causes head damage and pain.
+Impregnable Veins Mutation: "You do not bleed." - Can not bleed, what-so-ever. Increased pain, slower healing?
Late Bloomer: "One of your best attributes has yet to be shown." - After X time, your character will gain a random but strong trait you do not currently have. Costs 3. Removes this trait.
+Bulwark: - Running into zombies knocks them back/over
+Doomed: "You were never meant for this world; your clock is ticking."
+Undying/Ironclad/Dauntless: "When on the brink of death, you find the strength to carry on." - On deaths brink, heal up, must fully recover+cooldown before it works again. Activate on dragdown too?
Asymptomatic: "You're already infected but immune to it's killing properties, however, you put others at risk around you." - Will always turn into a zombie at death, can randomly infect others not wearing a mask around you.
Achilles' Heel: "Your body is resitant to damage everwhere but your weakpoints." - Slow loss of health everywhere but your "heel", a randomly chosen body part, which is extremely vulnerable.
CYBORG:
Achilles-Clad: - Invincible everywhere but 3 distinct locations, locations start in pain to show you where.
INSURGENT:
Spawns with 9mm pistol, 2 magazines, if not loadout selected
+Loadout: Rifleman - Spawn with M16, 7 magazines, 210 rounds
+Loadout: Marksman - Spawn with m14? rifle, 7 magazines
+Loadout: Breacher - Spawn with JS shotgun, 210 rounds
+Loadout: Gunslinger - Spawn with .45 pistol, 7 mags
+Loadout: Extra Ammo - Double ammo count on spawn (ammo boxes, not magazines)
Loadout: Commando - Hunting knife, extra pistol ammo, red headband, walkie talkie, Short blade skill
--]]
--getBodyDamage():getBodyPart(BodyPartType.Hand_L):HasInjury() or self.character:getBodyDamage():getBodyPart(BodyPartType.Hand_R):HasInjury()
--Used to call base functions
local oldOnSelectProf = CharacterCreationProfession.onSelectProf
local oldProfCreate = CharacterCreationProfession.create
local oldAddTrait = CharacterCreationProfession.addTrait
local oldRemoveTrait = CharacterCreationProfession.removeTrait
local oldProfList = CharacterCreationProfession.populateProfessionList
local oldResetBuild = CharacterCreationProfession.resetBuild
local oldResetTraits = CharacterCreationProfession.resetTraits
local oldNewPlayerMouse = CoopCharacterCreation.newPlayerMouse
local oldGetSurroundingZs = IsoGameCharacter.getSurroundingAttackingZombies
local oldClickPlay = NewGameScreen.clickPlay
local OldDoProfessions = BaseGameCharacterDetails.DoProfessions
local OldISDestroyStuffAction = ISDestroyStuffAction.perform

--Global Variables
dontAddXp = false;
profExlusiveTraitsList = {};
specOpsExcusiveProfs = {"insurgent"};
deathResistLines = {};
deathNoResistLines = {};
profsList = {};
ccController = {};
hasFilteredProfs = false;
--suspendevasive = false;




    else
        print("Yetki check; Yetkili degilsin mal.")
    end

local function tableContains(t, e)
    for _, value in pairs(t) do
        if value == e then
            return true
        end
    end
    return false
end

local function tableContainsTrait(t, e)
    for _, value in pairs(t) do
        if value.item:getLabel() == e then
            print("Found value in table, returning " .. value.item:getLabel())
            return true
        end
    end
    return false
end

local function addXPNoMultiplier(_player, _perk, _amount)
    local perk = _perk;
    local amount = _amount;
    local player = _player;
    skipxpadd = true;
    player:getXp():AddXPNoMultiplier(perk, amount);
end

local function debugPrint(_string)
    if not getCore():getDebug() then return end; --If not in debug mode
    print("Facility-7: ".._string);
end

--Profession "profName" has a list of exclusive traits exclTraits
profExclTrait = {};

function profExclTrait:new()
    trt = {}
    setmetatable(trt, self)
    self.__index = self
    trt.traitName = "NONE" 
    trt.exclusiveProf = {}
    return trt
end
	
local function initFacilityTraits()
	if getAccessLevel() == "admin" or getAccessLevel() == "gm" or string.find(username, "%-") then
		--print("Yetki check 1-F7; VaaaAaaAay, yetkiye bak! Evinize hosgeldiniz efendim.")
	    local labgrown = TraitFactory.addTrait("Labgrown", getText("UI_trait_Labgrown"), 0, getText("UI_trait_LabgrownDesc"), true);
	    local uPotential = TraitFactory.addTrait("UntappedPotential", getText("UI_trait_UntappedPotential"), 6, getText("UI_trait_UntappedPotentialDesc"), false, false);
        local wPotential = TraitFactory.addTrait("WastedPotential", getText("UI_trait_WastedPotential"), -6, getText("UI_trait_WastedPotentialDesc"), false, false);
	    local doomed = TraitFactory.addTrait("Doomed", getText("UI_trait_Doomed"), -12, getText("UI_trait_DoomedDesc"), false, false);
        local undying = TraitFactory.addTrait("Undying", getText("UI_trait_Undying"), 10, getText("UI_trait_UndyingDesc"), false, false);
        local bulwark = TraitFactory.addTrait("Bulwark", getText("UI_trait_Bulwark"), 8, getText("UI_trait_BulwarkDesc"), false, false);
        local necrotic = TraitFactory.addTrait("Necrotic", getText("UI_trait_Necrotic"), -6, getText("UI_trait_NecroticDesc"), false, false);
        local anxious = TraitFactory.addTrait("HighStrung", getText("UI_trait_HighStrung"), -3, getText("UI_trait_HighStrungDesc"), false, false);
        local personalities = TraitFactory.addTrait("SplitPersonalities", getText("UI_trait_SplitPersonalities"), -5, getText("UI_trait_SplitPersonalitiesDesc"), false, false);
        local amnesiac = TraitFactory.addTrait("Amnesiac", getText("UI_trait_Amnesiac"), -4, getText("UI_trait_AmnesiacDesc"), false, false);
        local emotionless = TraitFactory.addTrait("Emotionless", getText("UI_trait_Emotionless"), 5, getText("UI_trait_EmotionlessDesc"), false, false);
        local impregnable = TraitFactory.addTrait("ImpregnableVeins", getText("UI_trait_ImpregnableVeins"), 10, getText("UI_trait_ImpregnableVeinsDesc"), false, false);
        local runNGun = TraitFactory.addTrait("RunNGun", getText("UI_trait_RunNGun"), 6, getText("UI_trait_RunNGunDesc"), false, false);
        local bFrenzy = TraitFactory.addTrait("BloodFrenzy", getText("UI_trait_BloodFrenzy"), 8, getText("UI_trait_BloodFrenzyDesc"), false, false);
        local nightTerror = TraitFactory.addTrait("NightTerror", getText("UI_trait_NightTerror"), 8, getText("UI_trait_NightTerrorDesc"), false, false);
        local hematophage = TraitFactory.addTrait("Hematophage", getText("UI_trait_Hematophage"), 8, getText("UI_trait_HematophageDesc"), false, false);
        local sus = TraitFactory.addTrait("Susceptible", getText("UI_trait_Susceptible"), 0, getText("UI_trait_SusceptibleDesc"), true);
        local lRifleman = TraitFactory.addTrait("LoadoutRifleman", getText("UI_trait_LoadoutRifleman"), 4, getText("UI_trait_LoadoutRiflemanDesc"), false, false);
        local lMarksman = TraitFactory.addTrait("LoadoutMarksman", getText("UI_trait_LoadoutMarksman"), 4, getText("UI_trait_LoadoutMarksmanDesc"), false, false);
        lMarksman:addXPBoost(Perks.Aiming, 1);
        local lBreacher = TraitFactory.addTrait("LoadoutBreacher", getText("UI_trait_LoadoutBreacher"), 6, getText("UI_trait_LoadoutBreacherDesc"), false, false);
        lBreacher:addXPBoost(Perks.Reloading, 1);
        local lGunslinger = TraitFactory.addTrait("LoadoutGunslinger", getText("UI_trait_LoadoutGunslinger"), 2, getText("UI_trait_LoadoutGunslingerDesc"), false, false);
        local lAmmo = TraitFactory.addTrait("LoadoutExtraAmmo", getText("UI_trait_LoadoutExtraAmmo"), 6, getText("UI_trait_LoadoutExtraAmmoDesc"), false, false);

	
	    --NO HOBBIES WHEN LAB GROWN
	    TraitFactory.setMutualExclusive("Labgrown", "SundayDriver");
	    TraitFactory.setMutualExclusive("SpeedDemon", "Labgrown");
	    TraitFactory.setMutualExclusive("Labgrown", "Mechanics");
	    TraitFactory.setMutualExclusive("Labgrown", "Nutritionist");
	    TraitFactory.setMutualExclusive("Labgrown", "Cook");
	    TraitFactory.setMutualExclusive("Labgrown", "Smoker");
	    TraitFactory.setMutualExclusive("Labgrown", "Tailor");
	    TraitFactory.setMutualExclusive("Labgrown", "Jogger");
	    TraitFactory.setMutualExclusive("Labgrown", "Gardener");
	    TraitFactory.setMutualExclusive("Labgrown", "Fishing");
	    TraitFactory.setMutualExclusive("Labgrown", "Marksman");
	    TraitFactory.setMutualExclusive("Labgrown", "FirstAid");
	    TraitFactory.setMutualExclusive("Labgrown", "Outdoorsman");
	    TraitFactory.setMutualExclusive("Labgrown", "Herbalist");
	    TraitFactory.setMutualExclusive("Labgrown", "Formerscout");
	    TraitFactory.setMutualExclusive("Labgrown", "BaseballPlayer");
	    TraitFactory.setMutualExclusive("Labgrown", "Hiker");
	    TraitFactory.setMutualExclusive("Labgrown", "Hunter");
	    TraitFactory.setMutualExclusive("Labgrown", "Gymnast");
	    TraitFactory.setMutualExclusive("Labgrown", "Handy");
        TraitFactory.setMutualExclusive("Emotionless", "HighStrung");
        TraitFactory.setMutualExclusive("Emotionless", "Cowardly");
        TraitFactory.setMutualExclusive("Emotionless", "Brave");
        TraitFactory.setMutualExclusive("BloodFrenzy", "Pacifist");
        TraitFactory.setMutualExclusive("NightTerror", "Pacifist");
        TraitFactory.setMutualExclusive("Hematophage", "Pacifist");
        TraitFactory.setMutualExclusive("Hematophage", "Hemophobic");
        TraitFactory.setMutualExclusive("LoadoutRifleman", "LoadoutMarksman");
        TraitFactory.setMutualExclusive("LoadoutRifleman", "LoadoutBreacher");
        TraitFactory.setMutualExclusive("LoadoutMarksman", "LoadoutBreacher");

        local uPotential = profExclTrait:new();
        uPotential.traitName = "UntappedPotential";
        table.insert(uPotential.exclusiveProf, "tubesubject");
        table.insert(profExlusiveTraitsList, uPotential);
        print(profExlusiveTraitsList[1].traitName);
        local wPotential = profExclTrait:new();
        wPotential.traitName = "WastedPotential";
        table.insert(wPotential.exclusiveProf, "tubesubject");
        table.insert(profExlusiveTraitsList, wPotential);
        local doomed = profExclTrait:new();
        doomed.traitName = "Doomed";
        table.insert(doomed.exclusiveProf, "tubesubject");
        table.insert(profExlusiveTraitsList, doomed);
        local undying = profExclTrait:new();
        undying.traitName = "Undying";
        table.insert(undying.exclusiveProf, "tubesubject");
        table.insert(undying.exclusiveProf, "insurgent");
        table.insert(profExlusiveTraitsList, undying);
        local bulwark = profExclTrait:new();
        bulwark.traitName = "Bulwark";
        table.insert(bulwark.exclusiveProf, "tubesubject");
        table.insert(bulwark.exclusiveProf, "insurgent");
        table.insert(profExlusiveTraitsList, bulwark);
        local necrotic = profExclTrait:new();
        necrotic.traitName = "Necrotic";
        table.insert(necrotic.exclusiveProf, "tubesubject");
        table.insert(profExlusiveTraitsList, necrotic);
        local personalities = profExclTrait:new();
        personalities.traitName = "SplitPersonalities";
        table.insert(personalities.exclusiveProf, "tubesubject");
        table.insert(profExlusiveTraitsList, personalities);
        local amnesia = profExclTrait:new();
        amnesia.traitName = "Amnesiac";
        table.insert(amnesia.exclusiveProf, "tubesubject");
        table.insert(profExlusiveTraitsList, amnesia);
        local emotionless = profExclTrait:new();
        emotionless.traitName = "Emotionless";
        table.insert(emotionless.exclusiveProf, "tubesubject");
        table.insert(profExlusiveTraitsList, emotionless);
        local impregnable = profExclTrait:new();
        impregnable.traitName = "ImpregnableVeins";
        table.insert(impregnable.exclusiveProf, "tubesubject");
        table.insert(profExlusiveTraitsList, impregnable);
        local bFrenzy = profExclTrait:new();
        bFrenzy.traitName = "BloodFrenzy";
        table.insert(bFrenzy.exclusiveProf, "tubesubject");
        table.insert(bFrenzy.exclusiveProf, "insurgent");
        table.insert(profExlusiveTraitsList, bFrenzy);
        local nightTerror = profExclTrait:new();
        nightTerror.traitName = "NightTerror";
        table.insert(nightTerror.exclusiveProf, "tubesubject");
        table.insert(profExlusiveTraitsList, nightTerror);
        local hema = profExclTrait:new();
        hema.traitName = "Hematophage";
        table.insert(hema.exclusiveProf, "tubesubject");
        table.insert(profExlusiveTraitsList, hema);
        local runNGun = profExclTrait:new();
        runNGun.traitName = "RunNGun";
        table.insert(runNGun.exclusiveProf, "tubesubject");
        table.insert(runNGun.exclusiveProf, "insurgent");
        table.insert(profExlusiveTraitsList, runNGun);
        local lRifleman = profExclTrait:new();
        lRifleman.traitName = "LoadoutRifleman";
        table.insert(lRifleman.exclusiveProf, "insurgent");
        table.insert(profExlusiveTraitsList, lRifleman);
        local lMarksman = profExclTrait:new();
        lMarksman.traitName = "LoadoutMarksman";
        table.insert(lMarksman.exclusiveProf, "insurgent");
        table.insert(profExlusiveTraitsList, lMarksman);
        local lBreacher = profExclTrait:new();
        lBreacher.traitName = "LoadoutBreacher";
        table.insert(lBreacher.exclusiveProf, "insurgent");
        table.insert(profExlusiveTraitsList, lBreacher);
        local lGunslinger = profExclTrait:new();
        lGunslinger.traitName = "LoadoutGunslinger";
        table.insert(lGunslinger.exclusiveProf, "insurgent");
        table.insert(profExlusiveTraitsList, lGunslinger);
        local lAmmo = profExclTrait:new();
        lAmmo.traitName = "LoadoutExtraAmmo";
        table.insert(lAmmo.exclusiveProf, "insurgent");
        table.insert(profExlusiveTraitsList, lAmmo);

        --Add undying voice lines
        local voiceLineCount = 10;
        for i=1, voiceLineCount do
            table.insert(deathResistLines, getText("UI_trait_UndyingLine"..i));
        end
        local voiceLineCountWeak = 5;
        for i=1, voiceLineCountWeak do
            table.insert(deathNoResistLines, getText("UI_trait_UndyingWeakLine"..i));
        end
    else
        --print("Yetki check 1-F7; Yetkili degilsin mal.")
    end
end

local function initFacilityProfs()
	if getAccessLevel() == "admin" or getAccessLevel() == "gm" or string.find(username, "%-") then
		--print("Yetki check 2-F7; VaaaAaaAay, yetkiye bak! Evinize hosgeldiniz efendim.")

        local tubesubject = ProfessionFactory.addProfession("tubesubject", getText("UI_prof_tubesubject"), "profession_tubesubject", 12);
        tubesubject:addFreeTrait("Labgrown");

        local insurgent = ProfessionFactory.addProfession("insurgent", getText("UI_prof_insurgent"), "profession_insurgent", 8);
        insurgent:addFreeTrait("Susceptible");
        insurgent:addXPBoost(Perks.Aiming, 4);
        insurgent:addXPBoost(Perks.Reloading, 4);

	    local profsList = ProfessionFactory.getProfessions()
        for i = 1, profsList:size() do
            local profession = profsList:get(i - 1);
            BaseGameCharacterDetails.SetProfessionDescription(profession);
            debugPrint("Loaded Profesion: " .. profession:getName());
        end
    else
        --print("Yetki check 2-F7; Yetkili degilsin mal.")
    end
end

--[[Function taken from NRK_NeedLightToRead, I'd have never figured this one out on my own.
Bright Night + Cats Eyes = 55 w/ CE = 45
]]--
local function FacilityGetPlayerLight(Player)
	local player_id = Player:getPlayerNum()
	local square = Player:getCurrentSquare()
	local colors = {
		square:getVertLight(0, player_id),
		square:getVertLight(1, player_id),
		square:getVertLight(2, player_id),
		square:getVertLight(3, player_id),
		square:getVertLight(4, player_id),
		square:getVertLight(5, player_id),
		square:getVertLight(6, player_id),
		square:getVertLight(7, player_id),
	}
	local light = 0
	
	for i, color in ipairs(colors) do
		local hex_str = string.format("%x", color) -- exaple: "ffa1b2c3"
		light = math.max(
			tonumber(string.sub(hex_str, 3, 4), 16) or 0, -- "a1"
			tonumber(string.sub(hex_str, 5, 6), 16) or 0, -- "b2"
			tonumber(string.sub(hex_str, 7, 8), 16) or 0, -- "c3"
			light
		)
	end
	
	return light
end

local function isFitnessTrait(trait)
    if trait == "OutofShape" or trait == "Unfit" or trait == "Fit" or trait == "Athletic" or trait == "Weak" or trait == "Feeble" or trait == "Strong" or trait == "Stout" or trait == "Emaciated" or trait == "Underweight" or trait == "Overweight" or trait == "Obese" or trait == "VeryUnderweight" or trait == "Asthmatic" then
        return true;
    else
        return false;
    end
end

function AssignPersonalityTraits(_player)
    local player = _player;
    local secondaryTraitsAccepted = {"Pacifist", "Insomniac", "Smoker", "Outdoorsman", "NightVision", "EagleEyed", "Illiterate", "Hemophobic", "AdrenalineJunkie"};
    for i = 0, player:getTraits():size() - 1 do
        local trait = player:getTraits():get(i);
        debugPrint("Personality Trait is "..trait);
        if not TraitFactory.getTrait(trait):isFree() then
            if not isFitnessTrait(trait) then
                local traitToInsert = nil;
                if trait == "Graceful" then traitToInsert = "Clumsy" elseif trait == "Clumsy" then traitToInsert = "Graceful" end
                if trait == "Agoraphobic" then traitToInsert = "Claustrophobic" elseif trait == "Claustrophobic" then traitToInsert = "Agoraphobic" end
                if trait == "Inconspicuous" then traitToInsert = "Conspicuous" elseif trait == "Conspicuous" then traitToInsert = "Inconspicuous" end
                if trait == "LightEater" then traitToInsert = "HeartyAppitite" elseif trait == "HeartyAppitite" then traitToInsert = "LightEater" end
                if trait == "LowThirst" then traitToInsert = "HighThirst" elseif trait == "HighThirst" then traitToInsert = "LowThirst" end
                if trait == "Lucky" then traitToInsert = "Unlucky" elseif trait == "Unlucky" then traitToInsert = "Lucky" end
                if trait == "Organized" then traitToInsert = "Disorganized" elseif trait == "Disorganized" then traitToInsert = "Organized" end
                if trait == "Brave" then traitToInsert = "Cowardly" elseif trait == "Cowardly" then traitToInsert = "Brave" end
                if trait == "FastReader" then traitToInsert = "SlowReader" elseif trait == "SlowReader" then traitToInsert = "FastReader" end
                if trait == "IronGut" then traitToInsert = "WeakStomach" elseif trait == "WeakStomach" then traitToInsert = "IronGut" end
                if trait == "Dextrous" then traitToInsert = "AllThumbs" elseif trait == "AllThumbs" then traitToInsert = "Dextrous" end
                if trait == "Wakeful" then traitToInsert = "NeedsMoreSleep" elseif trait == "NeedsMoreSleep" then traitToInsert = "Wakeful" end
                if trait == "SpeedDemon" then traitToInsert = "Sundaydriver" elseif trait == "Sundaydriver" then traitToInsert = "SpeedDemon" end
                if trait == "Resilient" then traitToInsert = "PronetoIllness" elseif trait == "PronetoIllness" then traitToInsert = "Resilient" end
                if trait == "FastLearner" then traitToInsert = "SlowLearner" elseif trait == "SlowLearner" then traitToInsert = "FastLearner" end
                if trait == "FastHealer" then traitToInsert = "SlowHealer" elseif trait == "SlowHealer" then traitToInsert = "FastHealer" end
                if traitToInsert == nil then
                    --If haven't found the trait yet, loop through the other accepted traits. If it is on there, then get another random one.
                    for i,trt in ipairs(secondaryTraitsAccepted) do
                        if trait == trt then
                            local t = trait;
                            local r = ZombRand(9)+1;
                            while t == trait do
                                t = secondaryTraitsAccepted[r];
                                if t == trait then
                                    r = ZombRand(9)+1;
                                end
                            end
                            traitToInsert = t;
                            table.remove(secondaryTraitsAccepted, r);
                            break;
                        end
                    end
                end
                if traitToInsert ~= nil then
                    table.insert(player:getModData().mainPersonalityTraits, trait);
                    table.insert(player:getModData().secondPersonalityTraits, traitToInsert);
                end
            end
        end
    end
end

function SwapPersonalityTraits(_player, isSecondPersonality)
    local player = _player;
    for i,trt in ipairs(player:getModData().secondPersonalityTraits) do
        if not isSecondPersonality and player:HasTrait(player:getModData().secondPersonalityTraits[i]) then
            player:getTraits():remove(player:getModData().secondPersonalityTraits[i]);
            player:getTraits():add(player:getModData().mainPersonalityTraits[i]);
        elseif player:HasTrait(player:getModData().mainPersonalityTraits[i]) then
            player:getTraits():remove(player:getModData().mainPersonalityTraits[i]);
            player:getTraits():add(player:getModData().secondPersonalityTraits[i]);
        end
    end
end

local function FacilityAmnesiaInit(_player)
    local player = _player;
    local playerdata = player:getModData();
    if not player:HasTrait("Amnesiac") then return end;

    playerdata.Amnesia.playerNames[1] = player:getDescriptor():getForename();
    player:getDescriptor():setForename("?");
    playerdata.Amnesia.playerNames[2] = player:getDescriptor():getSurname();
    player:getDescriptor():setSurname("?");
    --playerdata.Amnesia.playerNames[3] = player:getDescriptor():getProfession();
    --player:getDescriptor():setProfession("unemployed")

    --Reverse go through list
    for i = player:getTraits():size() - 1, 1, -1 do
        local trait = player:getTraits():get(i);
        if isFitnessTrait(trait) or trait == "Illiterate" or trait == "Amnesiac" then 
            --Do nothing
        else
            --Remove all nonfitness based traits
            table.insert(playerdata.Amnesia.hiddenTraits, trait);

            if trait == "lucky" then playerdata.Amnesia.isLucky = true elseif trait == "unlucky" then playerdata.Amnesia.isUnlucky = true end

            player:getTraits():remove(trait);
            playerdata.Amnesia.hiddenTraitsSize = playerdata.Amnesia.hiddenTraitsSize + 1;
        end
    end
end

function FacilityAmnesiaRemember(_player, _toRemember)
    local player = _player;
    local playerdata = player:getModData();
    --Recall trait or name based on _toRemember
    local chance = ZombRand(100)
    if _toRemember == "name" then
        if chance > 50 and player:getDescriptor():getForename() == "?" then
            player:getDescriptor():setForename(playerdata.Amnesia.playerNames[1]);
            debugPrint("Remembered forename "..playerdata.Amnesia.playerNames[1]);
        elseif chance <= 50 and player:getDescriptor():getSurname() == "?" then
            player:getDescriptor():setSurname(playerdata.Amnesia.playerNames[2]);
            debugPrint("Remembered Surname "..playerdata.Amnesia.playerNames[2]);
        end
    elseif _toRemember == "forename" then
        player:getDescriptor():setForename(playerdata.Amnesia.playerNames[1]);
        debugPrint("Remembered forename "..playerdata.Amnesia.playerNames[1]);
    elseif _toRemember == "surname" then
        player:getDescriptor():setSurname(playerdata.Amnesia.playerNames[2]);
        debugPrint("Remembered Surname "..playerdata.Amnesia.playerNames[2]);
    elseif _toRemember == "profession" then
        player:getDescriptor():setProfession(playerdata.Amnesia.playerNames[3]);
        debugPrint("Remembered Profession "..playerdata.Amnesia.playerNames[3]);
    elseif playerdata.Amnesia.hiddenTraitsSize > 0 then
            local r = ZombRand(playerdata.Amnesia.hiddenTraitsSize)+1;
            player:getTraits():add(playerdata.Amnesia.hiddenTraits[r]);
            debugPrint("Remembered trait "..playerdata.Amnesia.hiddenTraits[r]);
            table.remove(playerdata.Amnesia.hiddenTraits, r);
            playerdata.Amnesia.hiddenTraitsSize = playerdata.Amnesia.hiddenTraitsSize - 1;
    end
end

local function FacilityAmnesiaWhatToRemember(_player)
    local player = _player;
    local playerdata = player:getModData();

    local chance = ZombRand(100);
    if chance > 75 and player:getDescriptor():getForename() == "?" then
        FacilityAmnesiaRemember(player, "name");
    elseif chance > 75 and player:getDescriptor():getSurname() == "?" then
        FacilityAmnesiaRemember(player, "name");
    else
        FacilityAmnesiaRemember(player, "trait");
    end
        
end

local function initFacilityTraitData(_player)
    local player = _player;
    local doomCounter = 6;
    doomCounter = doomCounter + ZombRand(6);
    debugPrint("Player has "..doomCounter.." months guaranteed to live.")
    if player:HasTrait("Lucky") then
        doomCounter = doomCounter + 1;
    end
    if player:HasTrait("Unlucky") then
        if doomCounter > 6 then
            doomCounter = doomCounter - 1;
        end
    end
    --player:getModData().hasSpawnProtection = false;
    player:getModData().doomCounter = doomCounter;
    player:getModData().isDoomed = false;
    player:getModData().willResistDeath = true;
    player:getModData().undyingCooldown = 0;
    player:getModData().necroticCooldown = 12;
    player:getModData().lateBloomerTimer = 0;
    player:getModData().maskDurabilityTick = 0;
    player:getModData().personalitySwitchTimer = 72;
    player:getModData().mainPersonalityTraits = {};
    player:getModData().secondPersonalityTraits = {};
    player:getModData().secondPersonalityActive = false;
    --Amnesia storage
    player:getModData().Amnesia = {};
    player:getModData().Amnesia.isUnlucky = false;
    player:getModData().Amnesia.isLucky = false;
    player:getModData().Amnesia.playerNames = {};
    player:getModData().Amnesia.hiddenTraits = {};
    player:getModData().Amnesia.hiddenTraitsSize = 0;
    --Berserker combat stats
    player:getModData().comboHits = 0;
    player:getModData().comboKills = 0;
    player:getModData().killedLastHour = false;
    player:getModData().frenzyTimer = 0;
    player:getModData().nightTerrorTimer = 0;

    if player:HasTrait("SplitPersonalities") then
        AssignPersonalityTraits(player);
    end
    if player:HasTrait("Amnesiac") then
        FacilityAmnesiaInit(player);
    end
end

local function GetUndyingLine(_onCooldown)
    if _onCooldown == true then
        local index = ZombRand(5) + 1
        if deathNoResistLines[index] == nil then return "UNDYING!" end
        return deathNoResistLines[index]
    end
    local index = ZombRand(10) + 1
    if deathResistLines[index] == nil then return "UNDYING!" end
    return deathResistLines[index]
end


local ogFemale = ClothingSelectionDefinitions.default.Female
local ogMale = ClothingSelectionDefinitions.default.Male

local function ResetClothingOptionsToDefault()
    ClothingSelectionDefinitions.default.Female = ogFemale;
    ClothingSelectionDefinitions.default.Male = ogMale;
end

local function FilterClothingOptions(_prof)
    local filtered = false;
    if _prof == nil then return filtered end;
    if _prof:getType() == "insurgent" then
        ClothingSelectionDefinitions.default.Female.Eyes = {
            chance = 0,
            items = {},
        }
        ClothingSelectionDefinitions.default.Male.Eyes = {
            chance = 0,
            items = {},
        }
        filtered = true;
    elseif _prof:getType() == "tubesubject" then
        ClothingSelectionDefinitions.default.Female = {};
        ClothingSelectionDefinitions.default.Male = {};
        filtered = true;
    end
    return filtered;
end

local function filterProfTraits(self, profession)
    debugPrint("Attempting to filter traits")
    local addTraitToNew = false;

    --Go through exclusive traits, if the current prof is used for the trait and not in the listbox, add it, otherwise, remove it
    for i,traitToCheck in ipairs(profExlusiveTraitsList) do
        addTraitToNew = false;
        for k,prof in ipairs(traitToCheck.exclusiveProf) do
            debugPrint("checking Prof = " .. prof)
            if prof == nil then break end
            if profession == prof then
                debugPrint("profName = " .. prof)
                debugPrint("traitName = " .. traitToCheck.traitName)
                addTraitToNew = true;
                break
            else
                addTraitToNew = false;
            end
        end 
        if addTraitToNew and not tableContainsTrait(self.listboxTrait.items, TraitFactory.getTrait(traitToCheck.traitName):getLabel()) and not tableContainsTrait(self.listboxTraitSelected.items, TraitFactory.getTrait(traitToCheck.traitName):getLabel()) and TraitFactory.getTrait(traitToCheck.traitName):getCost() > 0 then
            
            local newTrait = self.listboxTrait:addItem(TraitFactory.getTrait(traitToCheck.traitName):getLabel(), TraitFactory.getTrait(traitToCheck.traitName));
            newTrait.tooltip = TraitFactory.getTrait(traitToCheck.traitName):getDescription();

        elseif not addTraitToNew and tableContainsTrait(self.listboxTrait.items, TraitFactory.getTrait(traitToCheck.traitName):getLabel()) and TraitFactory.getTrait(traitToCheck.traitName):getCost() > 0 then
            
            self.listboxTrait:removeItem(TraitFactory.getTrait(traitToCheck.traitName):getLabel());
            self.listboxTrait.selected = -1;

        elseif addTraitToNew and not tableContainsTrait(self.listboxBadTrait.items, TraitFactory.getTrait(traitToCheck.traitName):getLabel()) and not tableContainsTrait(self.listboxTraitSelected.items, TraitFactory.getTrait(traitToCheck.traitName):getLabel()) and TraitFactory.getTrait(traitToCheck.traitName):getCost() < 0 then
            
            local newTrait = self.listboxBadTrait:addItem(TraitFactory.getTrait(traitToCheck.traitName):getLabel(), TraitFactory.getTrait(traitToCheck.traitName));
            newTrait.tooltip = TraitFactory.getTrait(traitToCheck.traitName):getDescription();

        elseif not addTraitToNew and tableContainsTrait(self.listboxBadTrait.items, TraitFactory.getTrait(traitToCheck.traitName):getLabel()) and  TraitFactory.getTrait(traitToCheck.traitName):getCost() < 0 then
            
            self.listboxBadTrait:removeItem(TraitFactory.getTrait(traitToCheck.traitName):getLabel());
            self.listboxBadTrait.selected = -1;

        end
        if not addTraitToNew and tableContainsTrait(self.listboxTraitSelected.items, TraitFactory.getTrait(traitToCheck.traitName):getLabel()) and not TraitFactory.getTrait(traitToCheck.traitName):isFree() then
            
            self.listboxTraitSelected:removeItem(TraitFactory.getTrait(traitToCheck.traitName):getLabel());
            self.listboxTraitSelected.selected = -1;
            self.pointToSpend = self.pointToSpend + TraitFactory.getTrait(traitToCheck.traitName):getCost();
        end
    end
end

function CharacterCreationProfession:create()
    --Incase I need to add something
    ccController = self;
    oldProfCreate(self)
end

function CharacterCreationProfession:onSelectProf(item)
    local gm = getWorld():getGameMode()
    if gm == "Facility-7 Special Ops" then
        local professionList = ProfessionFactory.getProfessions();
	    for i = 0, professionList:size() - 1 do
            local prof = professionList:get(i);
            if prof:getName() == "Insurgent" then
		        item = professionList:get(i);
            end
	    end
    end
    oldOnSelectProf(self, item) -- call the original
    -- do something custom
	debugPrint("Item is: " .. item:getType())
	local prof = self.profession:getType();
	debugPrint("Profession is: " .. prof);
    filterProfTraits(self, prof);
    CharacterCreationMain.sort(self.listboxTrait.items);
    CharacterCreationMain.invertSort(self.listboxBadTrait.items);
    CharacterCreationMain.sort(self.listboxTraitSelected.items);
    if not FilterClothingOptions(self.profession) then ResetClothingOptionsToDefault() end;
end

--Recreates the profession list, needs to be rewritten.
function CharacterCreationProfession:populateProfessionList(item)
    profsList = item;
    oldProfList(self, item);
end

function CharacterCreationProfession:resetBuild()
    if hasFilteredProfs then
        --First remove all possible traits
        for i = #self.listboxTraitSelected.items, 1, -1 do
            self.listboxTraitSelected.selected = i;
            if self.listboxTraitSelected.items[self.listboxTraitSelected.selected].item:getCost() ~= 0 then self:onOptionMouseDown(self.removeTraitBtn) end;
        end
        --Then switch to the first prof in the list
        self.listboxProf.selected = 1;
        self:onSelectProf(self.listboxProf.items[self.listboxProf.selected].item);
    else
        oldResetBuild(self);
    end
end

function CharacterCreationProfession:resetTraits()
    if hasFilteredProfs then 
        self:resetBuild() 
    else
        oldResetTraits(self)
    end  
end

local function filterProfList(listbox, gamemode)
    local professionList = ProfessionFactory.getProfessions();
    hasFilteredProfs = true; --Set to true, turns false if incorrect
    if gamemode == "F7SpecOps" then
        listbox.items = {};
        for i = 0, professionList:size() - 1 do
            local prof = professionList:get(i);
            if prof:getName() == "Insurgent" then
		        local newitem = listbox:addItem(i, professionList:get(i));
                newitem.tooltip = professionList:get(i):getDescription();
                ccController:resetBuild();
                return
            end
	    end
    else
        hasFilteredProfs = false;
        listbox.items = {};
        CharacterCreationProfession:populateProfessionList(listbox)
        ccController:onSelectProf(listbox.items[listbox.selected].item)
    end
end

local function checkForProfFilters(listbox)
    local gm = getCore():getGameMode()
    debugPrint("GAMEMODE IS NOW: "..gm);
    if gm == "Facility-7 Special Ops" then --Filter traits, otherwise refilter them to ensure you have all of them.
        filterProfList(listbox, "F7SpecOps")
    else
        filterProfList(listbox, "none")
    end
end

--New profession filter, hooks into click play of new game to ensure it fires
function NewGameScreen:clickPlay()
    oldClickPlay(self);
    checkForProfFilters(profsList);
end

--Couldn't think of a better way with my trait filtering, this hurts compatibility badly and is bound to break
function CoopCharacterCreation:newPlayerMouse()
    ProfessionFactory.Reset();
    BaseGameCharacterDetails.DoProfessions();
	if CoopCharacterCreation.instance then return end
	if UIManager.getSpeedControls() and not IsoPlayer.allPlayersDead() then
		setShowPausedMessage(false)
		UIManager.getSpeedControls():SetCurrentGameSpeed(0)
	end
	CoopCharacterCreation.setVisibleAllUI(false)
	local w = CoopCharacterCreation:new(nil, nil, 0)
	w:initialise()
	w:addToUIManager()
	if w.mapSpawnSelect:hasChoices() then
		w.mapSpawnSelect:fillList()
		w.mapSpawnSelect:setVisible(true)
	else
		w.mapSpawnSelect:useDefaultSpawnRegion()
		w.charCreationProfession:setVisible(true)
        checkForProfFilters(w.charCreationProfession.listboxProf)
	end
end

--Init facility professions when game inits them so they aren't lost, we will have to refilter EVERYTHING though
local function DoFacilityProfessions() 
    OldDoProfessions()
    initFacilityProfs()
end

BaseGameCharacterDetails.DoProfessions = DoFacilityProfessions

local function FacilityBeginGame(_player)
    local player = _player;
    if player:getHoursSurvived() > 0 then return end
    if player:getDescriptor():getProfession() == "tubesubject" then
        player:getInventory():clear();
	    player:clearWornItems();
	    player:getBodyDamage():setWetness(100);
        player:setClothingItem_Feet(nil)
	    player:setClothingItem_Legs(nil)
	    player:setClothingItem_Torso(nil)
    end
    if player:getDescriptor():getProfession() == "insurgent" then
        local inv = player:getInventory();
        local ammoMulti = 1;
        local invBag = inv;
        if player:HasTrait("LoadoutExtraAmmo") then
            ammoMulti = 2 
            --inv:AddItems("Base.Bag_DuffelBagTINT", 1);
            invBag = player:getInventory():AddItem("Base.Bag_DuffelBagTINT");
            player:setClothingItem_Back(invBag);
            invBag = invBag:getItemContainer();
            end
        if player:HasTrait("LoadoutRifleman") then
            inv:AddItems("Base.AssaultRifle", 1);
            invBag:AddItems("Base.556Clip", 7);
            invBag:AddItems("Base.556Box", 4 * ammoMulti);
        elseif player:HasTrait("LoadoutMarksman") then
            inv:AddItems("Base.AssaultRifle2", 1);
            invBag:AddItems("Base.M14Clip", 7);
            invBag:AddItems("Base.308Box", 4 * ammoMulti);
        elseif player:HasTrait("LoadoutBreacher") then
            inv:AddItems("Base.Shotgun", 1);
            invBag:AddItems("Base.ShotgunShellsBox", 8 * ammoMulti);
            inv:AddItems("Base.Sledgehammer", 1);
            --Give a 1 charge sledgehammer
            for i = 0, inv:getItems():size() - 1 do
                local item = player:getInventory():getItems():get(i);
                if item:getName() == "Sledgehammer" then
                    item:setName("Breacher's Hammer");
                    item:setTooltip("One time use, make it count.");
                    item:setCondition(1);
                end
            end
        end
        if player:HasTrait("LoadoutGunslinger") then
            inv:AddItems("Base.Pistol2", 1);
            invBag:AddItems("Base.45Clip", 7);
            invBag:AddItems("Base.Bullets45Box", 3 * ammoMulti);
        else
            invBag:AddItems("Base.9mmClip", 2 * ammoMulti);
            invBag:AddItems("Base.Bullets9mmBox", 1 * ammoMulti);
            inv:AddItems("Base.Pistol", 1);
        end
        inv:AddItems("Base.HolsterSimple", 1);
        inv:AddItems("Base.Hat_GasMask", 1);

        if player:getZ() == 0 then
            local rand = ZombRand(0, 13) + 1
            local posX = Facility7Ops.spawns[rand].x;
            local posY = Facility7Ops.spawns[rand].y;
            local posZ = Facility7Ops.spawns[rand].z;
            player:setX(posX); 
	        player:setLx(posX);
            player:setY(posY);
	        player:setLy(posY);
            player:setZ(posZ);
	        player:setLz(posZ);
        end
    end
end

function ISDestroyStuffAction:perform()
    OldISDestroyStuffAction(self);
    if self.sledge ~= nil then
        if self.sledge:getName() == "Breacher's Hammer" then
            self.sledge:setCondition(0);
            self.character:removeFromHands(self.sledge)
            self.character:getInventory():Remove(self.sledge);
        end
    end
end

local function LabLearning(_player, _perk, _amount)
    if not _player:HasTrait("labgrown") then return end
    if dontAddXp then
        dontAddXp = false
    else
        dontAddXp = true
	    local newXp = 1 + ((_amount * 0.45) * 2);
        _player:getXp():AddXP(_perk, newXp)
        --debugPrint("Test Subject has gained XP: "..newXp)
    end
end

-- when you gain a level you could win or lose perks
local function FacilityPotentialTick(owner, perk, level, addBuffer)
    local hasWastedPotential = owner:HasTrait("WastedPotential")
    local hasUntappedPotential = owner:HasTrait("UntappedPotential")
    if hasWastedPotential or hasUntappedPotential then

        local goodchance = 15;
        local badchance = 15;
        if owner:HasTrait("Lucky") then
            goodchance = goodchance - 5;
        end
        if owner:HasTrait("Unlucky") then
            badchance = badchance + 5;
        end
        local perkChosen = PerkFactory.getPerk(Perks.fromIndex(ZombRand(Perks.getMaxIndex())));
        --Fitness and strength are too tough to level up, don't mess with
        if perkChosen ~= nil and perkChosen:getType() ~= Perks.Strength and perkChosen:getType() ~= Perks.Fitness then
            local perkChangeChance = ZombRand(100);
            debugPrint("Perk Chance " .. perkChangeChance);
            if hasWastedPotential and perkChangeChance < badchance and owner:getPerkLevel(perkChosen:getType()) > 0 then
                owner:LoseLevel(perkChosen:getType());
                owner:getXp():AddXP(perkChosen:getType(), -5);
            elseif hasUntappedPotential and perkChangeChance < goodchance and owner:getPerkLevel(perkChosen:getType()) < 9 then
                debugPrint("Adding perk")
                local info = owner:getPerkInfo(perkChosen:getType());
                if info then
                    local level = info:getLevel()
                    owner:getXp():AddXP(perkChosen:getType(), perkChosen:getTotalXpForLevel(level) * 1.05);
                end
        
            end
        end
    end
end

local function FacilityPersonalityTick()
    local player = getPlayer();
    local playerdata = player:getModData();
    if player:HasTrait("SplitPersonalities") then
        if player:getModData().personalitySwitchTimer <= 0 then
            if player:getModData().secondPersonalityActive then
                SwapPersonalityTraits(player, false);
                player:getModData().secondPersonalityActive = false;
                debugPrint("Player is themselves");
            else
                SwapPersonalityTraits(player, true);
                player:getModData().secondPersonalityActive = true;
                debugPrint("Player is Their alternate version");
            end
            player:getModData().personalitySwitchTimer = ZombRand(72);
            print(player:getModData().secondPersonalityActive);
            debugPrint("Player is swapping personality in "..player:getModData().personalitySwitchTimer);
        else
            player:getModData().personalitySwitchTimer = player:getModData().personalitySwitchTimer - 1;
        end
    end
end

local function FacilityAmnesiaTick()
    local player = getPlayer();
    local playerdata = player:getModData();
    if player:HasTrait("Amnesiac") then
        local rememberHours = ZombRand(6) + 1;
        if player:HasTrait("Lucky") or playerdata.Amnesia.isLucky then
            rememberHours = rememberHours - 4;
        end
        if player:HasTrait("Unlucky") or playerdata.Amnesia.isUnlucky then
            rememberHours = rememberHours + 6;
        end
        debugPrint("Hours before amnesia rememberance is "..tostring(rememberHours));
        if player:getHoursSurvived() > rememberHours then
            local chance = ZombRand(100);
            if player:HasTrait("Unlucky") and chance > 95 then
                FacilityAmnesiaWhatToRemember(player);
            elseif chance > 80 and not player:HasTrait("Unlucky") then
                FacilityAmnesiaWhatToRemember(player);
            elseif player:HasTrait("Lucky") and chance > 75 then
                FacilityAmnesiaWhatToRemember(player);
            end
        end
    end
end

local function FacilityDoomedCheck()
    --Is grace period up? If so, roll to see if you die, then set grace period
    --print(getPlayer():getModData().doomCounter)
    local player = getPlayer();
    local playerdata = player:getModData();
    local stats = player:getStats();
    local timeTillDeath = 720 * playerdata.doomCounter;
    local avoidDeathChance = 50;
    if player:HasTrait("Doomed") then
        if player:getHoursSurvived() > timeTillDeath and not playerdata.isDoomed then
            if player:HasTrait("Lucky") then
                avoidDeathChance = avoidDeathChance - 25;
            end
            if player:HasTrait("Unlucky") then
                avoidDeathChance = avoidDeathChance + 15;
            end
            --Roll your death
            if ZombRand(100) < avoidDeathChance then
                debugPrint("Player has become doomed")
                playerdata.isDoomed = true;
                stats:setStress(1);
                if getCore():getOptionMusicVolume() ~= 0 and not getSoundManager():isPlayingMusic() then
                    getSoundManager():playMusic(MusicChoices.get(5));
                end
            else
                debugPrint("Player has evaided doom")
            end
        end
    end
end

local function FacilityDoomTick()
    local player = getPlayer();
    local playerdata = player:getModData();
    local stats = player:getStats();
    if player:HasTrait("Doomed") and playerdata.isDoomed then
        for i = 0, player:getBodyDamage():getBodyParts():size() - 1 do
            player:getBodyDamage():getBodyParts():get(i):ReduceHealth(1);
        end
        stats:setStress(stats:getStress() + 0.1);
        stats:setPain(1);
    end
end

local function FacilityHighStrungTick()
    local player = getPlayer();
    local playerdata = player:getModData();
    local stats = player:getStats();
    if player:HasTrait("HighStrung") then
        local zeds = player:getSpottedList();
        local zombieStress = 0;
        local baseStresser = 0.02;
        local sadMulti = ((player:getBodyDamage():getUnhappynessLevel() / 100) * 2) + 1;
        local panicMulti = (stats:getPanic() * 3) + 1;
        if zeds:size() > 0 then
            for i = 0, zeds:size() - 1 do
                if zeds:get(i):isZombie() then
                    local multi = 0.05;
                    if zeds:get(i):DistTo(player) <= 3 then
                        multi = 0.08;
                    end
                    zombieStress = zombieStress + multi;
                end
            end
        end
        if stats:getDrunkenness() > 0 or stats:getFatigue() < 0.15 then baseStresser = 0 end;
        stats:setStress(stats:getStress() + (baseStresser * sadMulti * panicMulti) + zombieStress);
    end
end

local function DoEmotionOverloadCheck(_player, _emoteValue, _maxEmote, _headacheRange)
    local bodydamage = _player:getBodyDamage();
    local headacheIntensity = 0;
    local newEmoteVal = _emoteValue;
    if _emoteValue > _headacheRange then
        --If the player is given a sudden influx of emotion, become overwhelmed and given a headache
       headacheIntensity = (_emoteValue - _maxEmote) * 5
       local part = _player:getBodyDamage():getBodyParts():get(8);
       --local part = _player:getBodyDamage():getBodyPart(BodyPartType.FromString("Head"));
       part:setAdditionalPain(headacheIntensity);
       newEmoteVal = _maxEmote * 0.8
    else
        newEmoteVal = _emoteValue - 0.05;
    end
    return newEmoteVal
end

local function FacilityEmotionTick(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    local stats = player:getStats();
    if player:HasTrait("Emotionless") then
        local maxEmote = 0.15
        local headacheRange = 0.75
        --Set Stress
        if stats:getStress() > maxEmote then
            stats:setStress(DoEmotionOverloadCheck(player, stats:getStress(), maxEmote, headacheRange));
        end
        --Set Panic
        if stats:getPanic() > maxEmote then
            stats:setPanic(DoEmotionOverloadCheck(player, stats:getPanic(), maxEmote, 0.9));
        end
        --Set Sadness
        if player:getBodyDamage():getUnhappynessLevel() > maxEmote then
            player:getBodyDamage():setUnhappynessLevel(DoEmotionOverloadCheck(player, player:getBodyDamage():getUnhappynessLevel(), maxEmote, headacheRange))
        end
        --Set Bordedom
        if player:getBodyDamage():getBoredomLevel() > maxEmote then
            player:getBodyDamage():setBoredomLevel(DoEmotionOverloadCheck(player, player:getBodyDamage():getBoredomLevel(), maxEmote, headacheRange))
        end
    end
end

local function FacilitySledgehammerRemovalCheck()
    local player = getPlayer();
    local playerdata = player:getModData();
    local inv = player:getInventory();
    for i = 0, inv:getItems():size() - 1 do
        local item = player:getInventory():getItems():get(i);
        if (item:getName() == "Breacher's Hammer" or item:getName() == "Breacher's Hammer (Broken)") and item:getCondition() <= 0 then
            inv:Remove(item);
            break;
        end
    end
end

local function FacilityUndyingCooldown()
    local player = getPlayer();
    local playerdata = player:getModData();
    if not playerdata.willResistDeath then
        for i = 0, player:getBodyDamage():getBodyParts():size() - 1 do
            if player:getBodyDamage():getBodyParts():get(i):getHealth() < 90 then
                return;
            elseif player:getBodyDamage():getBodyParts():get(i):bleeding() then
                return;
            end
        end
        if playerdata.undyingCooldown > 0 then
            playerdata.undyingCooldown = playerdata.undyingCooldown - 1;
        else
            playerdata.willResistDeath = true;
        end
    end
end

local function FacilityResistDeath(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    local stats = player:getStats();
    local zeds = player:getSpottedList();
    if player:HasTrait("Undying") then
        if player:getBodyDamage():getHealth() <= 10 then
            if playerdata.willResistDeath then
                for i = 0, player:getBodyDamage():getBodyParts():size() - 1 do
                    local b = player:getBodyDamage():getBodyParts():get(i);
                    b:RestoreToFullHealth();
                end
                stats:setAnger(1);
                playerdata.willResistDeath = false;
                playerdata.undyingCooldown = 3;
                if zeds:size() > 0 then
                    for i = 0, zeds:size() - 1 do
                        if zeds:get(i):isZombie() then
                            if zeds:get(i):DistTo(player) <= 1.5 then
                                zeds:get(i):knockDown(false)
                            end
                        end
                    end
                end
                if getCore():getOptionMusicVolume() ~= 0 then
                    getSoundManager():playMusic(MusicChoices.get(100));
                end
                player:Say(GetUndyingLine(false));
            else
                player:Say(GetUndyingLine(true));
            end
        end
    end
end

local function FacilityNecroticTick()
    local player = getPlayer();
    local playerdata = player:getModData();
    local stats = player:getStats();
    if player:HasTrait("Necrotic") then
        local injuryChance = 6;
        local chanceFromStress = (stats:getStress() * 100) / 2;
        local chanceFromPanic = (stats:getPanic() * 100) / 5;
        local chanceFromSadness = (player:getBodyDamage():getUnhappynessLevel() * 100) / 10;
        local chanceFromFatigue = (stats:getFatigue() * 100) / 5;
        injuryChance = injuryChance + chanceFromStress + chanceFromPanic + chanceFromSadness + chanceFromFatigue;
        if player:HasTrait("Unlucky") then
            injuryChance = injuryChance + 4;
        end
        if player:HasTrait("Lucky") then
            injuryChance = injuryChance - 4;
        end
        debugPrint("Necrotic Injury Chance is "..injuryChance);
        if ZombRand(100) < injuryChance and playerdata.necroticCooldown <= 0 then
            --If injury, player recieve injury, check for traits that effect cooldown.
            local cooldown = ZombRand(5) + 1;
            local hurtChance = ZombRand(100);
            if player:HasTrait("Resilient") then
                cooldown = cooldown + ZombRand(5) + 1;
                hurtChance = hurtChance + 2;
            end
            if player:HasTrait("ProneToIllness") then
                cooldown = cooldown / 2;
                hurtChance = hurtChance - 2;
            end 
            if player:HasTrait("ThickSkinned") then
                hurtChance = hurtChance + 15; --Can never be a deep wound, only rarely a laceration.
            end
            if player:HasTrait("Thinskinned") then
                hurtChance = hurtChance - 15; --Much higher chance of deep wound or laceration.
            end
            playerdata.necroticCooldown = cooldown;
            local partIndex = ZombRand(player:getBodyDamage():getBodyParts():size());
            local partTakingDamage = player:getBodyDamage():getBodyParts():get(partIndex);
            if partTakingDamage ~= nil then
                --player:getBodyDamage():AddRandomDamage();
                if hurtChance <= 5 then
                    partTakingDamage:generateDeepWound();
                elseif hurtChance <= 25 then
                    --Laceration
                    partTakingDamage:setCut(true);
                else
                    --Scratch
                    partTakingDamage:SetScratchedWeapon(true);
                end
            end
        elseif playerdata.necroticCooldown > 0 then
            playerdata.necroticCooldown = playerdata.necroticCooldown - 1;
        end
    end
end

--[[Doesn't work, unfortunately
function IsoGameCharacter:getSurroundingAttackingZombies(self)
    local player = getPlayer();
    local playerdata = player:getModData();
    local zeds = player:getSpottedList();
    print("Overwrite successful");
    if player:HasTrait("Undying") and playerdata.willResistDeath then
        local zombieCount = 0;
        for i = 0, zeds:size() - 1 do
            if zeds:get(i):isZombie() then
                if zeds:get(i):DistTo(player) <= 0.9 then
                    zombieCount = zombieCount + 1;
                end
            end
        end
        if zombieCount >= 10 then
            oldGetSurroundingZs(self)
        else
            return 0;
        end
    else
        oldGetSurroundingZs(self)
    end
end]]--

local function FacilityRunNGun(_player)
    local player = _player;
    --local chance = 10 + player:getPerkLevel(Perks.Firearm) * 5;
    if player:HasTrait("RunNGun") and player:IsAiming() and player:isPlayerMoving() then
        if player:getPrimaryHandItem() ~= nil then
            if player:getPrimaryHandItem():getSubCategory() == "Firearm" then
                --print("Player is Runnin' and Gunnin'")
                player:setBeenMovingFor(0);
            end
        end
    end
end

local function FacilityBulwarkKnockdown()
    local player = getPlayer();
    local playerdata = player:getModData();
    local zeds = player:getSpottedList();
    if player:HasTrait("Bulwark") and player:isLocalPlayer() then
        local knockdownChance = 25;
        if player:HasTrait("Stout") or player:HasTrait("Strong") then
            knockdownChance = knockdownChance + 25;
        elseif player:HasTrait("Feeble") then
            knockdownChance = knockdownChance - 10;
        elseif player:HasTrait("Weak") then
            knockdownChance = knockdownChance - 20;
        end
        if player:HasTrait("Runner") then
            knockdownChance = knockdownChance + 10;
        end
        if player:isSprinting() or player:IsRunning() then
            if player:isSprinting() then
                knockdownChance = knockdownChance + 25;
            end
            if zeds:size() > 0 then
                for i = 0, zeds:size() - 1 do
                    if zeds:get(i):isZombie() then
                        if player:isSprinting() and zeds:get(i):DistTo(player) <= 1.1 then
                            if ZombRand(100) < knockdownChance then
                                zeds:get(i):knockDown(true)
                            end
                        elseif player:IsRunning() and zeds:get(i):DistTo(player) <= 0.75 then
                            if ZombRand(100) < knockdownChance then
                                zeds:get(i):knockDown(true)
                            end
                        end
                    end
                end
            end
        end
    end
end

local function FacilityImpregnableTick(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    --local stats = player:getStats();
    if player:HasTrait("ImpregnableVeins") then
        local bodydamage = player:getBodyDamage();
        local bleeding = bodydamage:getNumPartsBleeding();
        if bleeding > 0 then
            for i = 0, player:getBodyDamage():getBodyParts():size() - 1 do
                for i = 0, player:getBodyDamage():getBodyParts():size() - 1 do
                    local part = player:getBodyDamage():getBodyParts():get(i);
                    if part:bleeding() then
                        --If the body part is bleeding, stop bleeding, add a bunch of pain instead.
                        debugPrint("Player has impregnable veins and is bleeding!")
                        part:setBleedingTime(0);
                        part:setBleeding(false);
                        part:setAdditionalPain(100);
                    end
                end
            end
        end
    end
end

local function FacilityBFrenzyTick(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    local stats = player:getStats();
    if player:HasTrait("BloodFrenzy") then
        --If time since attack is <= 0, reset your frenzy.
        if playerdata.frenzyTimer == 0 and playerdata.comboHits > 0 then
            --Reset frenzy
            print("Player Frenzy is Reset");
            playerdata.comboHits = 0;
        elseif playerdata.frenzyTimer > 0 then
            --Subtract from frenzy
            --print("Player Frenzy is "..playerdata.frenzyTimer);
            playerdata.frenzyTimer = playerdata.frenzyTimer - 1;
        end
    end
end

local function FacilityBFrenzyHit(_actor, _target, _weapon, _damage)
    local player = getPlayer();
    local playerdata = player:getModData();
    local weapon = _weapon;
    local damage = _damage;
    --local enemies = player:getSpottedList();
    local stats = player:getStats();
    if _actor == player and player:HasTrait("BloodFrenzy") then
        if weapon:getName() == "Bare Hands" then
            return
        end;
        local addedDamage = player:getModData().comboHits / 100;
        if playerdata.frenzyTimer <= 0 then
            if getCore():getOptionMusicVolume() ~= 0 and not getSoundManager():isPlayingMusic() then
                getSoundManager():playMusic(MusicChoices.get(100));
            end
        end
        playerdata.frenzyTimer = 500;
        if _target:isZombie() then
            --print("Enemy has ".._target:getHealth().." HP")
            --print("Enemy will be at ".. (_target:getHealth() - addedDamage) .." HP")
            _target:setHealth(_target:getHealth() - addedDamage);
        end
        if stats:getAnger() < addedDamage then
            stats:setAnger(addedDamage);
        end
        player:getModData().comboHits = player:getModData().comboHits + 1;
        --player:Say("Combo x"..player:getModData().comboHits);
    end
end

local function FacilityNightTerrorTick(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    if player:HasTrait("NightTerror") then
        --If stepped out of the shadow
        if playerdata.nightTerrorTimer > 0 and FacilityGetPlayerLight(player) > 90 then
            playerdata.nightTerrorTimer = playerdata.nightTerrorTimer - 1;
        end
    end
end

local function checkForEquippedMask(player)
    local inventory = player:getInventory()	
    local items = inventory:getItems();
    if player and inventory then
        for i = 0, items:size()-1 do
            local item = items:get(i);
            if item:getType() == "HazmatSuit" or item:getType() == "Hat_GasMask" or item:getType() == "Hat_NBCmask" or item:getType() == "Hat_GasMask_Improvised"
            or item:getType() == "HCImprovisedgasmask" or item:getType() == "HCImprovisedhazmat" or item:getType() == "Hat_SwatGasMask" or item:getType() == "RogueMask"
            or item:getType() == "Hat_Rebreather" or item:getType() ==  "Mask_HECU"  or item:getType() ==  "Hat_MCU_GasMask" then --Hat_MCU_GasMask
                if player:isEquippedClothing(item) and item:getCondition() > 0 then
                    --print("Protected From Airborne Strand. Condition Threshhold is "..(item:getConditionMax() * 0.075))
                    return true;
                end
            end			
        end
    end
    return false;
end

local function FacilitySusceptibleTick()
    local player = getPlayer();
    local playerdata = player:getModData();
    if player:HasTrait("Susceptible") then
        local zeds = player:getSpottedList();
        local inventory = player:getInventory()	
	    local items = inventory:getItems();
        local infectionDistance = 6;
        local infectionChance = ZombRand(0,100);
        if player:isOutside() then infectionDistance = infectionDistance - 2 end;
        if player:HasTrait("ProneToIllness") then 
        infectionDistance = infectionDistance + 2;
        infectionChance = infectionChance - 20;
        end
        if player:HasTrait("Resilient") then 
        infectionDistance = infectionDistance - 2;
        infectionChance = infectionChance + 20;
        end
        local willInfect = false;

        if zeds:size() > 0 then
            for i = 0, zeds:size() - 1 do
                if zeds:get(i):isZombie() then
                    if zeds:get(i):DistTo(player) <= infectionDistance then
                        --print("Zombie in danger of infecting player!");
                        willInfect = true;
                        if checkForEquippedMask(player) then
                            willInfect = false;
                        end
                        break;
                    end
                else
                    if zeds:get(i):DistTo(player) <= infectionDistance then
                        if zeds:get(i):getBodyDamage():isInfected() and not checkForEquippedMask(zeds:get(i)) then
                            --print("Player in danger of infecting player!");
                            willInfect = true;
                            if checkForEquippedMask(player) then
                                willInfect = false;
                            end
                        end
                    end
                end
            end
        end
        if infectionChance < 20 and willInfect then
            --print("Not Protected From Airborne Strand, Infecting player")
            local bodyDamage = player:getBodyDamage()
            for i = 0, bodyDamage:getBodyParts():size() - 1 do
                local bodyPart = bodyDamage:getBodyParts():get(i)
                bodyPart:SetInfected(true)
            end
            bodyDamage:setInf(true)
        end
    end
end

local function FacilityGasMaskDrain()
    local player = getPlayer();
    local playerdata = player:getModData();
    local stats = player:getStats();
    if player:HasTrait("Susceptible") then
        --drain gasmask condition: (10 / (48 hours * 6)) * exertion(1 + exertion level)
        local inventory = player:getInventory()	
        local items = inventory:getItems();
        local drainCap = 24;
        if player and inventory then
            for i = 0, items:size()-1 do
                local item = items:get(i);
                local isMask = false;
                if item:getType() == "HazmatSuit" then
                    isMask = true;
                    drainCap = 72;
                elseif item:getType() == "Hat_GasMask" or item:getType() == "Hat_NBCmask" then
                    isMask = true;
                    drainCap = 42;
                elseif item:getType() == "Hat_GasMask_Improvised" or item:getType() == "HCImprovisedgasmask" or item:getType() == "HCImprovisedhazmat" or item:getType() == "Hat_SwatGasMask" or item:getType() == "RogueMask" or item:getType() == "Hat_Rebreather" or item:getType() ==  "Mask_HECU"  or item:getType() ==  "Hat_MCU_GasMask" then
                    isMask = true;
                end --Hat_MCU_GasMask
                drainCap = drainCap/item:getConditionMax();
                if player:isEquippedClothing(item) and isMask and item:getCondition() > 0 then
                    --print("Removing Condition: "..((item:getConditionMax() / (24 * 6)) * drainMulti * (2 - stats:getEndurance())));
                    --item:setCondition(item:getCondition() - ((item:getConditionMax() / (24 * 6)) * drainMulti * (2 - stats:getEndurance())));
                    playerdata.maskDurabilityTick = playerdata.maskDurabilityTick + (1 * (2 - stats:getEndurance()));
                    --item:setCondition(item:getCondition() - 1);
                    debugPrint("draining");
                    if playerdata.maskDurabilityTick >= drainCap then
                        debugPrint("Item LOSING CONDITION")
                        item:setCondition(item:getCondition() - 1);
                        playerdata.maskDurabilityTick = 0;
                    end
                end
            end
        end
    end
end

local function FacilityNightTerrorHit(_actor, _target, _weapon, _damage)
    local player = getPlayer();
    local playerdata = player:getModData();
    local weapon = _weapon;
    local damage = _damage;
    --local enemies = player:getSpottedList();
    local stats = player:getStats();
    if _actor == player and player:HasTrait("NightTerror") then
        local addedDamage = damage * 0.5;
        local playerLight = FacilityGetPlayerLight(player);
        debugPrint("Night Terror is dealing an extra "..addedDamage);
        if  playerLight <= 90 or playerdata.nightTerrorTimer > 0 then
            if playerdata.nightTerrorTimer <= 0 then
                if getCore():getOptionMusicVolume() ~= 0 and not getSoundManager():isPlayingMusic() then
                    getSoundManager():playMusic(MusicChoices.get(100));
                end
            end
            if  playerLight <= 90 then
                playerdata.nightTerrorTimer = 1000;
                if stats:getPanic() > 0.4 then
                    stats:setPanic(stats:getPanic() - 0.05);
                end
            end
            _target:setHealth(_target:getHealth() - addedDamage);
        end
    end
end

local function FacilityHematophageHit(_actor, _target, _weapon, _damage)
    local player = getPlayer();
    local playerdata = player:getModData();
    local weapon = _weapon;
    local damage = _damage;
    local stats = player:getStats();
    if _actor == player and player:HasTrait("Hematophage") then
        local addedDamage = damage;
        local bloodpoints = 0;
	    local visual = player:getHumanVisual()

        --Loop through visual for blood on body
	    for i=1,BloodBodyPartType.MAX:index() do
		    local part = BloodBodyPartType.FromIndex(i-1)
		        if visual:getBlood(part) > 0 then
			        bloodpoints = bloodpoints + 1
		        end
	    end

        --Loop through clothes and check for blood on items
        local inventory = player:getInventory()	
        local items = inventory:getItems();
        for i = 0, items:size()-1 do
            local item = items:get(i);
            if instanceof(item, "Clothing") then
                local coveredParts = BloodClothingType.getCoveredParts(item:getBloodClothingType())
                if coveredParts then
                    for i=1,coveredParts:size() do
                        local part = coveredParts:get(i-1)
                        if item:getBlood(part) > 0 then
                            bloodpoints = bloodpoints + 1
                        end
                    end
                end
            end
        end

        --Bleeding damage
        local bodydamage = player:getBodyDamage();
        bloodpoints = bloodpoints + (bodydamage:getNumPartsBleeding() * 2);

        --Calm nerves
        if stats:getPanic() > 0.4 then
            stats:setPanic(stats:getPanic() - 0.025);
        end
        if stats:getStress() > 0.1 then
            stats:setStress(stats:getStress() - 0.05);
        end

        --Tally Damage
        addedDamage = bloodpoints / 50;
        debugPrint("Hematophage is dealing an extra "..addedDamage);

        _target:setHealth(_target:getHealth() - addedDamage);
    end
end

local function FacilityCharacterHit(_actor, _target, _weapon, _damage)
    FacilityNightTerrorHit(_actor, _target, _weapon, _damage);
    FacilityBFrenzyHit(_actor, _target, _weapon, _damage);
    FacilityHematophageHit(_actor, _target, _weapon, _damage);
end

local function FacilityPlayerUpdate(_player)
    local player = _player;
    local playerdata = player:getModData();
    FacilityResistDeath(player, playerdata);
    FacilityImpregnableTick(player, playerdata);
    FacilityBFrenzyTick(player, playerdata);
    FacilityNightTerrorTick(player, playerdata);
    FacilityEmotionTick(player, playerdata);
    FacilitySusceptibleTick();
    FacilityRunNGun(player);
    playerdata.hasSpawnProtection = false;
end

local function FacilityEvery10Minutes()
    FacilityDoomTick();
    FacilityPersonalityTick();
    FacilityHighStrungTick();
    FacilitySledgehammerRemovalCheck();
end


--[[local function initToadTraits()
    local gunspecialist = TraitFactory.addTrait("gunspecialist", getText("UI_trait_gunspecialist"), 8, getText("UI_trait_gunspecialistdesc"), false, false);
    gunspecialist:addXPBoost(Perks.Aiming, 2);
    gunspecialist:addXPBoost(Perks.Reloading, 2);
    local preparedfood = TraitFactory.addTrait("preparedfood", getText("UI_trait_preparedfood"), 1, getText("UI_trait_preparedfooddesc"), false, false);
    local preparedammo = TraitFactory.addTrait("preparedammo", getText("UI_trait_preparedammo"), 1, getText("UI_trait_preparedammodesc"), false, false);
    local preparedmedical = TraitFactory.addTrait("preparedmedical", getText("UI_trait_preparedmedical"), 1, getText("UI_trait_preparedmedicaldesc"), false, false);
    local preparedrepair = TraitFactory.addTrait("preparedrepair", getText("UI_trait_preparedrepair"), 1, getText("UI_trait_preparedrepairdesc"), false, false);
    local preparedcamp = TraitFactory.addTrait("preparedcamp", getText("UI_trait_preparedcamp"), 1, getText("UI_trait_preparedcampdesc"), false, false);
    local preparedweapon = TraitFactory.addTrait("preparedweapon", getText("UI_trait_preparedweapon"), 1, getText("UI_trait_preparedweapondesc"), false, false);
    local preparedpack = TraitFactory.addTrait("preparedpack", getText("UI_trait_preparedpack"), 1, getText("UI_trait_preparedpackdesc"), false, false);
    local swift = TraitFactory.addTrait("swift", getText("UI_trait_swift"), 2, getText("UI_trait_swiftdesc"), false, false);
    swift:addXPBoost(Perks.Lightfoot, 1);
    local generator = TraitFactory.addTrait("generator", getText("UI_trait_generator"), 2, getText("UI_trait_generatordesc"), false, false);
    generator:getFreeRecipes():add("Generator");
    local ingenuitive = TraitFactory.addTrait("ingenuitive", getText("UI_trait_ingenuitive"), 6, getText("UI_trait_ingenuitivedesc"), false, false);
    ingenuitive:getFreeRecipes():add("Generator");
    ingenuitive:getFreeRecipes():add("Make Remote Controller V1");
    ingenuitive:getFreeRecipes():add("Make Remote Controller V2");
    ingenuitive:getFreeRecipes():add("Make Remote Controller V3");
    ingenuitive:getFreeRecipes():add("Make Remote Trigger");
    ingenuitive:getFreeRecipes():add("Craft Makeshift Radio");
    ingenuitive:getFreeRecipes():add("Craft Makeshift HAM Radio");
    ingenuitive:getFreeRecipes():add("Craft Makeshift Walkie Talkie");
    ingenuitive:getFreeRecipes():add("Make Aerosol bomb");
    ingenuitive:getFreeRecipes():add("Make Flame bomb");
    ingenuitive:getFreeRecipes():add("Make Pipe bomb");
    ingenuitive:getFreeRecipes():add("Make Noise generator");
    ingenuitive:getFreeRecipes():add("Make Smoke Bomb");
    ingenuitive:getFreeRecipes():add("Make Metal Walls");
    ingenuitive:getFreeRecipes():add("Make Metal Fences");
    ingenuitive:getFreeRecipes():add("Make Metal Containers");
    ingenuitive:getFreeRecipes():add("Make Metal Sheet");
    ingenuitive:getFreeRecipes():add("Make Small Metal Sheet");
    ingenuitive:getFreeRecipes():add("Make Metal Roof");
    ingenuitive:getFreeRecipes():add("Make Fishing Rod");
    ingenuitive:getFreeRecipes():add("Fix Fishing Rod");
    ingenuitive:getFreeRecipes():add("Get Wire Back");
    ingenuitive:getFreeRecipes():add("Make Fishing Net");
    ingenuitive:getFreeRecipes():add("Make Mildew Cure");
    ingenuitive:getFreeRecipes():add("Make Flies Cure");
    ingenuitive:getFreeRecipes():add("Make Stick Trap");
    ingenuitive:getFreeRecipes():add("Make Snare Trap");
    ingenuitive:getFreeRecipes():add("Make Wooden Cage Trap");
    ingenuitive:getFreeRecipes():add("Make Trap Box");
    ingenuitive:getFreeRecipes():add("Make Cage Trap");
    ingenuitive:getFreeRecipes():add("Make Fork");
    ingenuitive:getFreeRecipes():add("Make Spoon");
    ingenuitive:getFreeRecipes():add("Make Cooking Pot");
    ingenuitive:getFreeRecipes():add("Make Roasting Pan");
    ingenuitive:getFreeRecipes():add("Make Saucepan");
    ingenuitive:getFreeRecipes():add("Make Baking Tray");
    ingenuitive:getFreeRecipes():add("Make Baking Pan");
    ingenuitive:getFreeRecipes():add("Make Pan");
    ingenuitive:getFreeRecipes():add("Make Letter Opener");
    ingenuitive:getFreeRecipes():add("Make Nails");
    ingenuitive:getFreeRecipes():add("Make Paperclips");
    ingenuitive:getFreeRecipes():add("Make Scissors");
    ingenuitive:getFreeRecipes():add("Make Door Knob");
    ingenuitive:getFreeRecipes():add("Make Hinge");
    ingenuitive:getFreeRecipes():add("Make Butter Knife");
    ingenuitive:getFreeRecipes():add("Make Ball Peen Hammer");
    ingenuitive:getFreeRecipes():add("Make Tongs");
    ingenuitive:getFreeRecipes():add("Make Hammer");
    ingenuitive:getFreeRecipes():add("Make Sheet Metal");
    ingenuitive:getFreeRecipes():add("Make Suture Needle Holder");
    ingenuitive:getFreeRecipes():add("Make Tweezers");
    ingenuitive:getFreeRecipes():add("Make Suture Needle");
    ingenuitive:getFreeRecipes():add("Make Metal Drum");
    ingenuitive:getFreeRecipes():add("Make Kitchen Knife");
    ingenuitive:getFreeRecipes():add("Make Saw");
    ingenuitive:getFreeRecipes():add("Make Hunting Knife");
    ingenuitive:getFreeRecipes():add("Make 9mm Bullets Mold");
    ingenuitive:getFreeRecipes():add("Make 308 Bullets Mold");
    ingenuitive:getFreeRecipes():add("Make 223 Bullets Mold");
    ingenuitive:getFreeRecipes():add("Make Shotgun Shells Mold");
    ingenuitive:getFreeRecipes():add("Make 9mm Bullets");
    ingenuitive:getFreeRecipes():add("Make Shotgun Shells");
    ingenuitive:getFreeRecipes():add("Make 308 Bullets");
    ingenuitive:getFreeRecipes():add("Make 223 Bullets");
    ingenuitive:getFreeRecipes():add("Make Crowbar");
    ingenuitive:getFreeRecipes():add("Make Golfclub");
    ingenuitive:getFreeRecipes():add("Make Axe");
    ingenuitive:getFreeRecipes():add("Make Sledgehammer");
    ingenuitive:getFreeRecipes():add("Make Shovel");
    ingenuitive:getFreeRecipes():add("Make Hand Shovel");
    ingenuitive:getFreeRecipes():add("Basic Mechanics");
    ingenuitive:getFreeRecipes():add("Intermediate Mechanics");
    ingenuitive:getFreeRecipes():add("Advanced Mechanics");
    local olympian = TraitFactory.addTrait("olympian", getText("UI_trait_olympian"), 6, getText("UI_trait_olympiandesc"), false, false);
    olympian:addXPBoost(Perks.Sprinting, 1);
    olympian:addXPBoost(Perks.Fitness, 1);
    local bouncer = TraitFactory.addTrait("bouncer", getText("UI_trait_bouncer"), 4, getText("UI_trait_bouncerdesc"), false, false);
    bouncer:addXPBoost(Perks.Strength, 1);
    local martial = TraitFactory.addTrait("martial", getText("UI_trait_martial"), 4, getText("UI_trait_martialdesc"), false, false);
    martial:addXPBoost(Perks.Fitness, 1);
    local flexible = TraitFactory.addTrait("flexible", getText("UI_trait_flexible"), 2, getText("UI_trait_flexibledesc"), false, false);
    flexible:addXPBoost(Perks.Nimble, 1);
    local grunt = TraitFactory.addTrait("grunt", getText("UI_trait_grunt"), 4, getText("UI_trait_gruntdesc"), false, false);
    grunt:addXPBoost(Perks.Woodwork, 1);
    grunt:addXPBoost(Perks.SmallBlunt, 1);
    local quiet = TraitFactory.addTrait("quiet", getText("UI_trait_quiet"), 3, getText("UI_trait_quietdesc"), false, false);
    quiet:addXPBoost(Perks.Sneak, 1);
    local tinkerer = TraitFactory.addTrait("tinkerer", getText("UI_trait_tinkerer"), 6, getText("UI_trait_tinkererdesc"), false, false);
    tinkerer:addXPBoost(Perks.Electricity, 1);
    tinkerer:addXPBoost(Perks.Mechanics, 1);
    tinkerer:addXPBoost(Perks.Tailoring, 1);
    local preparedcar = TraitFactory.addTrait("preparedcar", getText("UI_trait_preparedcar"), 1, getText("UI_trait_preparedcardesc"), false, false);
    local scrapper = TraitFactory.addTrait("scrapper", getText("UI_trait_scrapper"), 3, getText("UI_trait_scrapperdesc"), false, false);
    scrapper:addXPBoost(Perks.MetalWelding, 1);
    scrapper:addXPBoost(Perks.Maintenance, 1);
    scrapper:getFreeRecipes():add("Make Metal Pipe");
    scrapper:getFreeRecipes():add("Make Metal Sheet");
    local wildsman = TraitFactory.addTrait("wildsman", getText("UI_trait_wildsman"), 8, getText("UI_trait_wildsmandesc"), false, false);
    wildsman:addXPBoost(Perks.Fishing, 1);
    wildsman:addXPBoost(Perks.Trapping, 1);
    wildsman:addXPBoost(Perks.PlantScavenging, 1);
    wildsman:addXPBoost(Perks.Spear, 1);
    wildsman:getFreeRecipes():add("Make Stick Trap");
    wildsman:getFreeRecipes():add("Make Snare Trap");
    wildsman:getFreeRecipes():add("Make Fishing Rod");
    wildsman:getFreeRecipes():add("Fix Fishing Rod");
    local natural = TraitFactory.addTrait("natural", getText("UI_trait_natural"), 5, getText("UI_trait_naturaldesc"), false, false);
    natural:addXPBoost(Perks.Cooking, 1);
    natural:addXPBoost(Perks.PlantScavenging, 1);
    local bladetwirl = TraitFactory.addTrait("bladetwirl", getText("UI_trait_bladetwirl"), 5, getText("UI_trait_bladetwirldesc"), false, false);
    bladetwirl:addXPBoost(Perks.LongBlade, 1);
    bladetwirl:addXPBoost(Perks.SmallBlade, 1);
    local blunttwirl = TraitFactory.addTrait("blunttwirl", getText("UI_trait_blunttwirl"), 5, getText("UI_trait_blunttwirldesc"), false, false);
    blunttwirl:addXPBoost(Perks.ShortBlunt, 1);
    blunttwirl:addXPBoost(Perks.Blunt, 1);
    local scrounger = TraitFactory.addTrait("scrounger", getText("UI_trait_scrounger"), 5, getText("UI_trait_scroungerdesc"), false, false);
    local antique = TraitFactory.addTrait("antique", getText("UI_trait_antique"), 4, getText("UI_trait_antiquedesc"), false, false);
    local evasive = TraitFactory.addTrait("evasive", getText("UI_trait_evasive"), 8, getText("UI_trait_evasivedesc"), false, false);
    evasive:addXPBoost(Perks.Nimble, 1);
    local blissful = TraitFactory.addTrait("blissful", getText("UI_trait_blissful"), 2, getText("UI_trait_blissfuldesc"), false, false);
    local specweapons = TraitFactory.addTrait("specweapons", getText("UI_trait_specweapons"), 12, getText("UI_trait_specweaponsdesc"), false, false);
    specweapons:addXPBoost(Perks.Axe, 2);
    specweapons:addXPBoost(Perks.Spear, 2);
    specweapons:addXPBoost(Perks.SmallBlunt, 2);
    specweapons:addXPBoost(Perks.Blunt, 2);
    specweapons:addXPBoost(Perks.LongBlade, 2);
    specweapons:addXPBoost(Perks.SmallBlade, 2);
    specweapons:addXPBoost(Perks.Maintenance, 2);
    local speccrafting = TraitFactory.addTrait("speccrafting", getText("UI_trait_speccrafting"), 12, getText("UI_trait_speccraftingdesc"), false, false);
    speccrafting:addXPBoost(Perks.Woodwork, 2);
    speccrafting:addXPBoost(Perks.Electricity, 2);
    speccrafting:addXPBoost(Perks.MetalWelding, 2);
    speccrafting:addXPBoost(Perks.Mechanics, 2);
    speccrafting:addXPBoost(Perks.Tailoring, 2);
    local specfood = TraitFactory.addTrait("specfood", getText("UI_trait_specfood"), 12, getText("UI_trait_specfooddesc"), false, false);
    specfood:addXPBoost(Perks.Cooking, 2);
    specfood:addXPBoost(Perks.Trapping, 2);
    specfood:addXPBoost(Perks.PlantScavenging, 2);
    specfood:addXPBoost(Perks.Farming, 2);
    specfood:addXPBoost(Perks.Fishing, 2);
    local specguns = TraitFactory.addTrait("specguns", getText("UI_trait_specguns"), 12, getText("UI_trait_specgunsdesc"), false, false);
    specguns:addXPBoost(Perks.Aiming, 4);
    specguns:addXPBoost(Perks.Reloading, 4);
    local specmove = TraitFactory.addTrait("specmove", getText("UI_trait_specmove"), 12, getText("UI_trait_specmovedesc"), false, false);
    specmove:addXPBoost(Perks.Lightfoot, 2);
    specmove:addXPBoost(Perks.Sprinting, 2);
    specmove:addXPBoost(Perks.Sneak, 2);
    specmove:addXPBoost(Perks.Nimble, 2);
    local gordanite = TraitFactory.addTrait("gordanite", getText("UI_trait_gordanite"), 5, getText("UI_trait_gordanitedesc"), false, false);
    gordanite:addXPBoost(Perks.Blunt, 1);
    local indefatigable = TraitFactory.addTrait("indefatigable", getText("UI_trait_indefatigable"), 10, getText("UI_trait_indefatigabledesc"), false, false);
    local hardy = TraitFactory.addTrait("hardy", getText("UI_trait_hardy"), 6, getText("UI_trait_hardydesc"), false, false);
    hardy:addXPBoost(Perks.Strength, 1);
    local bluntperk = TraitFactory.addTrait("problunt", getText("UI_trait_problunt"), 7, getText("UI_trait_probluntdesc"), false, false);
    bluntperk:addXPBoost(Perks.SmallBlunt, 1);
    bluntperk:addXPBoost(Perks.Blunt, 1);
    local bladeperk = TraitFactory.addTrait("problade", getText("UI_trait_problade"), 7, getText("UI_trait_probladedesc"), false, false);
    bladeperk:addXPBoost(Perks.SmallBlade, 1);
    bladeperk:addXPBoost(Perks.LongBlade, 1);
    bladeperk:addXPBoost(Perks.Axe, 1);
    local gunperk = TraitFactory.addTrait("progun", getText("UI_trait_progun"), 7, getText("UI_trait_progundesc"), false, false);
    gunperk:addXPBoost(Perks.Aiming, 1);
    gunperk:addXPBoost(Perks.Reloading, 1);
    local actionhero = TraitFactory.addTrait("actionhero", getText("UI_trait_actionhero"), 8, getText("UI_trait_actionherodesc"), false, false);
    -- local fast = TraitFactory.addTrait("fast", getText("UI_trait_fast"), 6, getText("UI_trait_fastdesc"), false, false);
    local spearperk = TraitFactory.addTrait("prospear", getText("UI_trait_prospear"), 7, getText("UI_trait_prospeardesc"), false, false);
    spearperk:addXPBoost(Perks.Spear, 2);
    local thickblood = TraitFactory.addTrait("thickblood", getText("UI_trait_thickblood"), 4, getText("UI_trait_thickblooddesc"), false, false);
    local expertdriver = TraitFactory.addTrait("expertdriver", getText("UI_trait_expertdriver"), 5, getText("UI_trait_expertdriverdesc"), false, false);
    local superimmune = TraitFactory.addTrait("superimmune", getText("UI_trait_superimmune"), 10, getText("UI_trait_superimmunedesc"), false, false);
    --===========--
    --Bad Traits--
    --===========--
    local injured = TraitFactory.addTrait("injured", getText("UI_trait_injured"), -4, getText("UI_trait_injureddesc"), false, false);
    local drinker = TraitFactory.addTrait("drinker", getText("UI_trait_drinker"), -12, getText("UI_trait_drinkerdesc"), false, false);
    local broke = TraitFactory.addTrait("broke", getText("UI_trait_broke"), -8, getText("UI_trait_brokedesc"), false, false);
    local butterfingers = TraitFactory.addTrait("butterfingers", getText("UI_trait_butterfingers"), -10, getText("UI_trait_butterfingersdesc"), false, false);
    local incomprehensive = TraitFactory.addTrait("incomprehensive", getText("UI_trait_incomprehensive"), -10, getText("UI_trait_incomprehensivedesc"), false, false);
    local depressive = TraitFactory.addTrait("depressive", getText("UI_trait_depressive"), -4, getText("UI_trait_depressivedesc"), false, false);
    local selfdestructive = TraitFactory.addTrait("selfdestructive", getText("UI_trait_selfdestructive"), -4, getText("UI_trait_selfdestructivedesc"), false, false);
    local badteeth = TraitFactory.addTrait("badteeth", getText("UI_trait_badteeth"), -2, getText("UI_trait_badteethdesc"), false, false);
    local albino = TraitFactory.addTrait("albino", getText("UI_trait_albino"), -5, getText("UI_trait_albinodesc"), false, false);
    local amputee = TraitFactory.addTrait("amputee", getText("UI_trait_amputee"), -16, getText("UI_trait_amputeedesc"), false, false);
    local poordriver = TraitFactory.addTrait("poordriver", getText("UI_trait_poordriver"), -5, getText("UI_trait_poordriverdesc"), false, false);
    --  local gimp = TraitFactory.addTrait("gimp", getText("UI_trait_gimp"), -8, getText("UI_trait_gimpdesc"), false, false);
    local anemic = TraitFactory.addTrait("anemic", getText("UI_trait_anemic"), -4, getText("UI_trait_anemicdesc"), false, false);
    local immunocompromised = TraitFactory.addTrait("immunocompromised", getText("UI_trait_immunocompromised"), -10, getText("UI_trait_immunocompromiseddesc"), false, false);
    --Exclusives
    TraitFactory.setMutualExclusive("preparedfood", "preparedammo");
    TraitFactory.setMutualExclusive("preparedfood", "preparedrepair");
    TraitFactory.setMutualExclusive("preparedfood", "preparedmedical");
    TraitFactory.setMutualExclusive("preparedfood", "preparedcamp");
    TraitFactory.setMutualExclusive("preparedfood", "preparedweapon");
    TraitFactory.setMutualExclusive("preparedammo", "preparedrepair");
    TraitFactory.setMutualExclusive("preparedammo", "preparedmedical");
    TraitFactory.setMutualExclusive("preparedammo", "preparedcamp");
    TraitFactory.setMutualExclusive("preparedrepair", "preparedmedical");
    TraitFactory.setMutualExclusive("preparedrepair", "preparedweapon");
    TraitFactory.setMutualExclusive("preparedmedical", "preparedcamp");
    TraitFactory.setMutualExclusive("preparedmedical", "preparedweapon");
    TraitFactory.setMutualExclusive("preparedcamp", "preparedrepair");
    TraitFactory.setMutualExclusive("preparedweapon", "preparedammo");
    TraitFactory.setMutualExclusive("preparedweapon", "preparedcamp");
    TraitFactory.setMutualExclusive("preparedpack", "preparedammo");
    TraitFactory.setMutualExclusive("preparedpack", "preparedrepair");
    TraitFactory.setMutualExclusive("preparedpack", "preparedmedical");
    TraitFactory.setMutualExclusive("preparedpack", "preparedcamp");
    TraitFactory.setMutualExclusive("preparedpack", "preparedfood");
    TraitFactory.setMutualExclusive("preparedpack", "preparedweapon");
    TraitFactory.setMutualExclusive("preparedcar", "preparedweapon");
    TraitFactory.setMutualExclusive("preparedcar", "preparedfood");
    TraitFactory.setMutualExclusive("preparedcar", "preparedammo");
    TraitFactory.setMutualExclusive("preparedcar", "preparedrepair");
    TraitFactory.setMutualExclusive("preparedcar", "preparedmedical");
    TraitFactory.setMutualExclusive("preparedcar", "preparedcamp");
    TraitFactory.setMutualExclusive("preparedcar", "preparedpack");
    TraitFactory.setMutualExclusive("quiet", "Clumsy");
    TraitFactory.setMutualExclusive("flexible", "Obese");
    TraitFactory.setMutualExclusive("olympian", "Unfit");
    TraitFactory.setMutualExclusive("scrounger", "incomprehensive");
    TraitFactory.setMutualExclusive("olympian", "Jogger");
    TraitFactory.setMutualExclusive("blissful", "depressive");
    TraitFactory.setMutualExclusive("blissful", "selfdestructive");
    TraitFactory.setMutualExclusive("specweapons", "speccrafting");
    TraitFactory.setMutualExclusive("specweapons", "specfood");
    TraitFactory.setMutualExclusive("specweapons", "specguns");
    TraitFactory.setMutualExclusive("specweapons", "specmove");
    TraitFactory.setMutualExclusive("speccrafting", "specfood");
    TraitFactory.setMutualExclusive("speccrafting", "specguns");
    TraitFactory.setMutualExclusive("speccrafting", "specmove");
    TraitFactory.setMutualExclusive("specfood", "specguns");
    TraitFactory.setMutualExclusive("specfood", "specmove");
    TraitFactory.setMutualExclusive("specguns", "specmove");
    TraitFactory.setMutualExclusive("problunt", "problade");
    TraitFactory.setMutualExclusive("problunt", "progun");
    TraitFactory.setMutualExclusive("problade", "progun");
    TraitFactory.setMutualExclusive("prospear", "progun");
    TraitFactory.setMutualExclusive("prospear", "problunt");
    TraitFactory.setMutualExclusive("prospear", "problade");
    TraitFactory.setMutualExclusive("actionhero", "bouncer");
    TraitFactory.setMutualExclusive("thickblood", "anemic");
    TraitFactory.setMutualExclusive("generator", "ingenuitive");
    TraitFactory.setMutualExclusive("expertdriver", "poordriver");
    TraitFactory.setMutualExclusive("Resilient", "superimmune");
    TraitFactory.setMutualExclusive("Resilient", "immunocompromised");
    TraitFactory.setMutualExclusive("superimmune", "immunocompromised");
    TraitFactory.setMutualExclusive("ProneToIllness", "superimmune");
    TraitFactory.setMutualExclusive("ProneToIllness", "immunocompromised");
    --  TraitFactory.setMutualExclusive("gimp", "fast");
    --TraitFactory.setMutualExclusive("blissful", "Brooding");
end--]]

--[[local function initToadTraitsItems(_player)
    local player = _player;
    local inv = player:getInventory();
    local traits = player:getTraits();
    if player:HasTrait("preparedfood") then
        inv:AddItem("Base.TinnedBeans");
        inv:AddItem("Base.CannedMushroomSoup");
        inv:AddItem("Base.TinnedSoup");
        inv:AddItem("Base.TunaTin");
        inv:AddItems("Base.PopBottle", 3);
        inv:AddItem("Base.TinOpener");
        inv:AddItems("Base.CannedTomato", 2);
        inv:AddItems("Base.CannedPotato", 2);
        inv:AddItems("Base.CannedCarrots", 2);
        inv:AddItem("Base.Plasticbag");
    end
    if player:HasTrait("preparedammo") then
        inv:AddItems("Base.BulletsBox", 3);
        inv:AddItems("Base.ShotgunShellsBox", 2);
    end
    if player:HasTrait("preparedweapon") then
        inv:AddItem("Base.BaseballBatNails");
        inv:AddItem("farming.Shovel");
        inv:AddItem("Base.HuntingKnife");
        inv:AddItem("Base.Screwdriver");
    end
    if player:HasTrait("preparedmedical") then
        inv:AddItem("Base.Bandaid");
        inv:AddItem("Base.PillsAntiDep");
        inv:AddItem("Base.Disinfectant");
        inv:AddItem("Base.AlcoholWipes");
        inv:AddItem("Base.PillsBeta");
        inv:AddItem("Base.Pills");
        inv:AddItems("Base.Bandage", 4);
        inv:AddItem("Base.SutureNeedle");
        inv:AddItem("Base.Tissue");
        inv:AddItem("Base.Tweezers");
        inv:AddItem("Base.FirstAidKit");
    end
    if player:HasTrait("preparedrepair") then
        inv:AddItem("Base.Hammer");
        inv:AddItem("Base.Screwdriver");
        inv:AddItem("Base.Crowbar");
        inv:AddItem("Base.Saw");
        inv:AddItem("Base.NailsBox");
        inv:AddItems("Base.Garbagebag", 8);
    end
    if player:HasTrait("preparedcamp") then
        inv:AddItems("Base.Matches", 2);
        inv:AddItem("camping.CampfireKit");
        inv:AddItem("camping.CampingTentKit");
        inv:AddItem("Base.BucketEmpty");
        inv:AddItems("Base.BeefJerky", 2);
        inv:AddItems("Base.Pop", 1);
        inv:AddItem("Base.FishingRod");
        inv:AddItem("Base.FishingLine");
        inv:AddItem("Base.FishingTackle");
        inv:AddItems("Base.Battery", 4);
        inv:AddItem("Base.Torch");
        inv:AddItem("Base.Bag_NormalHikingBag");
        inv:AddItem("Base.WaterBottleFull");
    end
    if player:HasTrait("preparedpack") then
        inv:AddItem("Base.Bag_BigHikingBag");
    end
    if player:HasTrait("preparedcar") then
        inv:AddItem("Base.PetrolCan");
        inv:AddItem("Base.CarBatteryCharger");
        inv:AddItem("Base.Screwdriver");
        inv:AddItem("Base.Wrench");
        inv:AddItem("Base.LugWrench");
        inv:AddItem("Base.TirePump");
        inv:AddItem("Base.Jack");
    end
    if player:HasTrait("drinker") then
        inv:AddItem("Base.WhiskeyFull");
    end
end

local function initToadTraitsPerks(_player)
    local player = _player;
    local damage = 20;
    local bandagestrength = 5;
    local splintstrength = 0.9;
    local fracturetime = 20;
    local scratchtimemod = 15;
    local bleedtimemod = 5;
    player:getModData().bToadTraitDepressed = false;
    player:getModData().indefatigablecooldown = 0;
    player:getModData().bindefatigable = false;
    player:getModData().bSatedDrink = true;
    player:getModData().iHoursSinceDrink = 0;

    if player:HasTrait("Lucky") then
        damage = damage - 10;
        bandagestrength = bandagestrength + 3;
        fracturetime = fracturetime - 10;
        splintstrength = splintstrength + 0.1;
        scratchtimemod = scratchtimemod - 5;
        bleedtimemod = bleedtimemod - 2;
    end
    if player:HasTrait("Unlucky") then
        damage = damage + 10;
        bandagestrength = bandagestrength - 2;
        fracturetime = fracturetime + 5;
        splintstrength = splintstrength - 0.1;
        scratchtimemod = scratchtimemod + 5;
        bleedtimemod = bleedtimemod + 2;
    end

    if player:HasTrait("injured") then
        suspendevasive = true;
        --print("Beginning Injury.");
        local bodydamage = player:getBodyDamage();
        local itterations = ZombRand(0, 3) + 2;
        for i = 0, itterations do
            local randompart = ZombRand(0, 16);
            local b = bodydamage:getBodyPart(BodyPartType.FromIndex(randompart));
            local injury = ZombRand(0, 5);
            local skip = false;
            if b:HasInjury() then
                itterations = itterations + 1;
                skip = true;
            end
            if skip == false then
                if injury <= 1 then
                    b:AddDamage(damage);
                    b:setScratched(true, true);
                    b:setBandaged(true, bandagestrength, true, "Base.AlcoholBandage");
                end
                if injury == 2 then
                    b:AddDamage(damage);
                    b:setBurned();
                    b:setBandaged(true, bandagestrength, true, "Base.AlcoholBandage");
                end
                if injury == 3 then
                    b:AddDamage(damage);
                    b:setCut(true, true);
                    b:setBandaged(true, bandagestrength, true, "Base.AlcoholBandage");
                end
                if injury >= 4 then
                    b:AddDamage(damage);
                    b:setDeepWounded(true);
                    b:setStitched(true);
                    b:setBandaged(true, bandagestrength, true, "Base.AlcoholBandage");
                end
            end
        end
        bodydamage:setInfected(false);
    end
    if player:HasTrait("broke") then
        --print("Broke Leg.");
        suspendevasive = true;
        local bodydamage = player:getBodyDamage();
        bodydamage:getBodyPart(BodyPartType.LowerLeg_R):AddDamage(damage);
        bodydamage:getBodyPart(BodyPartType.LowerLeg_R):setFractureTime(fracturetime);
        bodydamage:getBodyPart(BodyPartType.LowerLeg_R):setSplint(true, splintstrength);
        bodydamage:getBodyPart(BodyPartType.LowerLeg_R):setBandaged(true, bandagestrength, true, "Base.AlcoholBandage");
        bodydamage:setInfected(false);
    end
    player:getModData().ToadTraitBodyDamage = nil;
    suspendevasive = false;
end

local function ToadTraitEvasive(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    if player:HasTrait("evasive") then
        local basechance = 33;
        local bMarkForUpdate = false;
        local bodydamage = player:getBodyDamage();
        local modbodydamage = playerdata.ToadTraitBodyDamage;
        if bodydamage:getNumPartsScratched() == nil then
            return
        end ;
        if player:HasTrait("Lucky") then
            basechance = basechance + 5;
        end
        if player:HasTrait("Unlucky") then
            basechance = basechance - 3;
        end
        if modbodydamage == nil then
            modbodydamage = {};
            --Initialize the Body Part Reference Table
            print("Initializing Body Damage");
            for i = 0, bodydamage:getBodyParts():size() - 1 do
                local b = bodydamage:getBodyParts():get(i);
                local temptable = { b:getType(), b:scratched(), b:bitten() };
                table.insert(modbodydamage, temptable);
            end
            playerdata.ToadTraitBodyDamage = modbodydamage;
            print("Body Damage Initialized");
        else
            for n = 0, bodydamage:getBodyParts():size() - 1 do
                local i = bodydamage:getBodyParts():get(n);
                for _, b in pairs(modbodydamage) do
                    if i:getType() == b[1] then
                        if i:scratched() == false and b[2] == true or i:bitten() == false and b[3] == true then
                            bMarkForUpdate = true;
                        end
                        if i:scratched() == true and b[2] == false then
                            print("Scratch Detected On: " .. tostring(i:getType()));
                            if ZombRand(100) <= basechance then
                                print("Attack Dodged!");
                                i:RestoreToFullHealth();
                                i:setScratched(false);
                                i:SetInfected(false);
                                player:Say("*Dodged*");
                            else
                                bMarkForUpdate = true;
                            end

                        elseif i:bitten() == true and b[3] == false then
                            print("Bite Detected On: " .. tostring(i:getType()));
                            if ZombRand(100) <= basechance then
                                print("Attack Dodged!");
                                i:RestoreToFullHealth();
                                i:SetBitten(false, false);
                                i:SetInfected(false);
                                player:Say("*Dodged*");
                            else
                                bMarkForUpdate = true;
                            end
                        end
                    end
                end
            end
        end
        if bMarkForUpdate == true then
            modbodydamage = {};
            --Initialize the Body Part Reference Table
            for i = 0, bodydamage:getBodyParts():size() - 1 do
                local b = bodydamage:getBodyParts():get(i);
                local temptable = { b:getType(), b:scratched(), b:bitten() };
                table.insert(modbodydamage, temptable);
            end
            playerdata.ToadTraitBodyDamage = modbodydamage;
        end
    end
end

local function ToadTraitButter()
    local player = getPlayer();
    if player:HasTrait("butterfingers") and player:isPlayerMoving() then
        local basechance = 5;
        if player:HasTrait("AllThumbs") then
            basechance = basechance + 5;
        end
        if player:HasTrait("Dextrous") then
            basechance = basechance - 5;
        end
        if player:HasTrait("Lucky") then
            basechance = basechance - 5;
        end
        if player:HasTrait("Unlucky") then
            basechance = basechance + 5;
        end
        local weight = player:getInventoryWeight();
        local chancemod = 0;
        if weight > 0 then
            chancemod = math.floor(weight / 5);
        end
        local chance = (basechance + chancemod);
        if chance >= ZombRand(1000) then
            player:dropHandItems();
        end
    end
end

local function ToadTraitScrounger(_target, _name, _container)
    local player = getPlayer();
    if player:HasTrait("scrounger") then
        local basechance = 30;
        local modifier = 1.2;
        if player:HasTrait("Lucky") then
            basechance = basechance + 10;
            modifier = modifier + 0.1;
        end
        if player:HasTrait("Unlucky") then
            basechance = basechance - 5;
            modifier = modifier - 0.1;
        end
        if ZombRand(100) <= basechance then
            local tempcontainer = {};
            for i = 0, _container:getItems():size() - 1 do
                local item = _container:getItems():get(i);
                if item ~= nil then
                    if tableContains(tempcontainer, item:getFullType()) == false then
                        table.insert(tempcontainer, item:getFullType());
                        local count = _container:getNumberOfItem(item:getFullType());
                        if count == 1 then
                            local bchance = 5;
                            if player:HasTrait("Lucky") then
                                bchance = bchance + 2;
                            end
                            if player:HasTrait("Unlucky") then
                                bchance = bchance - 2;
                            end
                            if item:IsFood() then
                                bchance = bchance + 20;
                            end
                            if item:IsDrainable() then
                                bchance = bchance + 10;
                            end
                            if item:IsWeapon() then
                                bchance = bchance + 5;
                            end
                            if ZombRand(100) <= bchance then
                                _container:AddItems(item, 1);
                            end
                        elseif count > 1 and count < 5 then
                            _container:AddItems(item, math.floor(count * modifier));
                        elseif count >= 5 then
                            _container:AddItems(item, math.floor((count * modifier) * 2));
                        end
                    end
                end
            end
        end
    end
end

local function ToadTraitIncomprehensive(_target, _name, _container)
    local player = getPlayer();
    local tempcontainer = {};
    if player:HasTrait("incomprehensive") then
        local basechance = 30;
        if player:HasTrait("Lucky") then
            basechance = basechance - 10;
        end
        if player:HasTrait("Unlucky") then
            basechance = basechance + 5;
        end
        if ZombRand(100) <= basechance then
            for i = 0, _container:getItems():size() - 1 do
                local item = _container:getItems():get(i);
                if item ~= nil then
                    if tableContains(tempcontainer, item) == false then
                        local count = _container:getNumberOfItem(item:getFullType());
                        if count == 1 then
                            local bchance = 5;
                            if player:HasTrait("Lucky") then
                                bchance = bchance - 2;
                            end
                            if player:HasTrait("Unlucky") then
                                bchance = bchance + 2;
                            end
                            if item:IsFood() then
                                bchance = bchance + 20;
                            end
                            if item:IsDrainable() then
                                bchance = bchance + 10;
                            end
                            if item:IsWeapon() then
                                bchance = bchance + 5;
                            end
                            if ZombRand(100) <= bchance then
                                table.insert(tempcontainer, item);
                            end
                        elseif count > 1 and count < 5 then
                            table.insert(tempcontainer, item);
                        elseif count >= 5 then
                            table.insert(tempcontainer, item);
                            table.insert(tempcontainer, item);
                        end
                    end
                end
            end
            if tempcontainer ~= nil then
                for _, i in pairs(tempcontainer) do
                    _container:Remove(i);
                end
            end
        end
    end
end

local function ToadTraitAntique(_target, _name, _container)
    local items = {};
    table.insert(items, "MoreTraits.AntiqueAxe");
    table.insert(items, "MoreTraits.Thumper");
    table.insert(items, "MoreTraits.ObsidianBlade");
    table.insert(items, "MoreTraits.PackerBag");
    table.insert(items, "MoreTraits.BloodyCrowbar");
    table.insert(items, "MoreTraits.Thumper");

    local length = 0
    for k, v in pairs(items) do
        length = length + 1;
    end
    local player = getPlayer();
    if player:HasTrait("antique") then
        local basechance = 2;
        if player:HasTrait("Lucky") then
            basechance = basechance + 2;
        end
        if player:HasTrait("Unlucky") then
            basechance = basechance - 1;
        end
        if player:HasTrait("AllThumbs") then
            basechance = basechance - 1;
        end
        if player:HasTrait("Dextrous") then
            basechance = basechance + 1;
        end
        if player:HasTrait("scrounger") then
            basechance = basechance + 1;
        end
        if player:HasTrait("incomprehensive") then
            basechance = basechance - 1;
        end
        if basechance < 1 then
            basechance = 1;
        end
        if ZombRand(1000) <= basechance then
            local i = ZombRand(length);
            if i == 0 then
                i = 1;
            end
            _container:AddItem(items[i]);
        end
    end
end

local function ToadTraitDepressive()
    local player = getPlayer();
    if player:HasTrait("depressive") then
        local basechance = 5;
        if player:HasTrait("Lucky") then
            basechance = basechance - 2;
        end
        if player:HasTrait("Unlucky") then
            basechance = basechance + 2;
        end
        if player:HasTrait("Brooding") then
            basechance = basechance + 2;
        end
        if ZombRand(100) <= basechance then
            if player:getModData().bToadTraitDepressed == false then
                print("Player is experiencing depression.");
                player:getBodyDamage():setUnhappynessLevel((player:getBodyDamage():getUnhappynessLevel() + 25));
                player:getModData().bToadTraitDepressed = true;
            end
        end
    end
end

local function CheckDepress(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    local depressed = playerdata.bToadTraitDepressed;
    if depressed == nil then
        playerdata.bToadTraitDepressed = false;
    else
        if depressed == true then
            if player:getBodyDamage():getUnhappynessLevel() < 25 then
                playerdata.bToadTraitDepressed = false;
            else
                player:getBodyDamage():setUnhappynessLevel(player:getBodyDamage():getUnhappynessLevel() + 0.001);
            end
        end
    end
end

local function CheckSelfHarm(_player)
    local player = _player;
    local modifier = 3;
    if player:HasTrait("depressive") then
        modifier = modifier - 1;
    end
    if player:HasTrait("selfdestructive") then
        if player:getBodyDamage():getUnhappynessLevel() >= 25 then
            if player:getBodyDamage():getOverallBodyHealth() >= (100 - player:getBodyDamage():getUnhappynessLevel() / modifier) then
                for i = 0, player:getBodyDamage():getBodyParts():size() - 1 do
                    local b = player:getBodyDamage():getBodyParts():get(i);
                    b:AddDamage(0.0005);
                end
            end
        end
    end
end

local function Blissful(_player)
    local player = _player;
    if player:HasTrait("blissful") then
        if player:getBodyDamage():getUnhappynessLevel() >= 10 then
            player:getBodyDamage():setUnhappynessLevel(player:getBodyDamage():getUnhappynessLevel() - 0.01);
        end
        if player:getBodyDamage():getBoredomLevel() >= 10 then
            player:getBodyDamage():setBoredomLevel(player:getBodyDamage():getBoredomLevel() - 0.005);
        end
    end
end

local function Specialization(_player, _perk, _amount)
    local player = _player;
    local perk = _perk;
    local amount = _amount;
    local newamount = 0;
    local skip = false;
    if perk == Perks.Fitness or perk == Perks.Strength then
        skipxpadd = true;
    end
    if skipxpadd == false then
        if player:HasTrait("specweapons") or player:HasTrait("specfood") or player:HasTrait("specguns") or player:HasTrait("specmove") or player:HasTrait("speccrafting") then
            if player:HasTrait("specweapons") then
                if perk == Perks.Axe or perk == Perks.Blunt or perk == Perks.LongBlade or perk == Perks.SmallBlade or perk == Perks.Maintenance or perk == Perks.SmallBlunt then
                    skip = true;
                end
            end
            if player:HasTrait("specfood") then
                if perk == Perks.Cooking or perk == Perks.Farming or perk == Perks.PlantScavenging or perk == Perks.Trapping or perk == Perks.Fishing then
                    skip = true;
                end
            end
            if player:HasTrait("specguns") then
                if perk == Perks.Aiming or perk == Perks.Reloading then
                    skip = true;
                end
            end
            if player:HasTrait("specmove") then
                if perk == Perks.Lightfoot or perk == Perks.Nimble or perk == Perks.Sprinting or perk == Perks.Sneak then
                    skip = true;
                end
            end
            if player:HasTrait("speccrafting") then
                if perk == Perks.Woodwork or perk == Perks.Electricity or perk == Perks.MetalWelding or perk == Perks.Mechanics or perk == Perks.Tailoring then
                    skip = true;
                end
            end
            if skip == false then
                newamount = amount * 0.25;
                local currentxp = player:getXp():getXP(perk);
                local correctamount = currentxp - newamount
                -- print("Current " .. tostring(perk) .. " XP: " .. currentxp);
                --  print("XP Amount (Unmodified): " .. amount);
                -- print("Subtracted Amount: " .. newamount .. " XP");
                player:getXp():AddXP(perk, -1 * amount, false, false);
                --  print("New XP Is: " .. player:getXp():getXP(perk));
                --  print("The player's XP should be: " .. currentxp - newamount);
                while player:getXp():getXP(perk) < correctamount do
                    player:getXp():AddXP(perk, 0.01, false, false);
                    --this is a very terrible way of doing this. But for some reason, some unknown variable within the AddXp function
                    --is fucking up the multiplication.
                    --print("Adjusting XP...");
                    -- print("New XP Is: " .. player:getXp():getXP(perk));
                    --print("The player's XP should be: " .. correctamount);
                end
            end
        end
    else
        skipxpadd = false;
    end
end

local function Gordanite(_player)
    local player = _player;
    if player:HasTrait("gordanite") then
        if player:getPrimaryHandItem() ~= nil then
            if player:getPrimaryHandItem():getDisplayName() == "Crowbar" then
                local crowbar = player:getPrimaryHandItem();
                crowbar:setMinDamage(0.9);
                crowbar:setMaxDamage(2.1);
                crowbar:setPushBackMod(0.6);
                crowbar:setDoorDamage(25);
                crowbar:setCriticalChance(25);
                crowbar:setSwingTime(2);
                crowbar:setName("Crowbar+");
                crowbar:setTooltip("This item's stats are being boosted by one of your traits.");
            end
        end
    end
    if player:HasItem("Crowbar") == true then
        local skip = false;
        if player:getPrimaryHandItem() ~= null then
            if player:getPrimaryHandItem():getName() == "Crowbar+" or player:getPrimaryHandItem():getDisplayName() == "Crowbar" then
                skip = true;
            end
        end
        if skip == false then
            local inv = player:getInventory();
            for i = 0, inv:getItems():size() - 1 do
                local item = player:getInventory():getItems():get(i);
                if item:getName() == "Crowbar+" then
                    inv:Remove(item);
                    inv:AddItem("Base.Crowbar");
                    break ;
                end
            end
        end
    end
end

local function indefatigable(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    local enemies = player:getSpottedList();
    if player:HasTrait("indefatigable") then
        if player:getBodyDamage():getHealth() < 15 then
            print("Health less than 15.");
            if playerdata.bindefatigable == false then
                print("Healed to full.");
                for i = 0, player:getBodyDamage():getBodyParts():size() - 1 do
                    local b = player:getBodyDamage():getBodyParts():get(i);
                    b:RestoreToFullHealth();
                end
                playerdata.bindefatigable = true;
                playerdata.indefatigablecooldown = 0;
                if enemies:size() > 2 then
                    for i = 0, enemies:size() - 1 do
                        if enemies:get(i):isZombie() then
                            if enemies:get(i):DistTo(player) <= 1.5 then
                                --Hit(HandWeapon weapon, IsoGameCharacter wielder, float damageSplit, boolean bIgnoreDamage, float modDelta) 
                                --hitConsequences(HandWeapon weapon, IsoGameCharacter wielder, boolean bIgnoreDamage, float damage, boolean bKnockdown) 
                                enemies:get(i):Hit(player:getUseHandWeapon(), player, ZombRand(1, 12), false, 1);
                            end
                        end
                    end
                end
                player:Say("*Indefatigable*");
            end
        end
    end
end

local function indefatigablecounter()
    local player = getPlayer();
    local playerdata = player:getModData();
    if player:HasTrait("indefatigable") then
        if playerdata.bindefatigable == true then
            if playerdata.indefatigablecooldown >= 7 then
                playerdata.indefatigablecooldown = 0;
                playerdata.bindefatigable = false;
                player:Say("*Indefatigable Is No Longer In Cooldown*");
            else
                playerdata.indefatigablecooldown = playerdata.indefatigablecooldown + 1;
            end
        end
    end
end

local function badteethtrait(_player)
    local player = _player;
    if player:HasTrait("badteeth") then
        if player:getBodyDamage():getHealthFromFoodTimer() > 1000 then
            player:getStats():setPain(player:getBodyDamage():getHealthFromFoodTimer() / 90);
        end
    end
end

local function hardytrait(_player)
    local player = _player;
    if player:HasTrait("hardy") then
        local endurance = player:getStats():getEndurance();
        if endurance < 1 then
            player:getStats():setEndurance(endurance + 0.0001);
        end
    end
end

local function drinkerupdate(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    local stats = player:getStats();
    if player:HasTrait("drinker") then
        local drunkness = stats:getDrunkenness();
        if drunkness > 0 then
            playerdata.bSatedDrink = true;
            playerdata.iHoursSinceDrink = 0;
        end
        if playerdata.bSatedDrink == false then
            if playerdata.iHoursSinceDrink > 48 then
                stats:setPain(playerdata.iHoursSinceDrink / 5);
            end
            if stats:getStress() < 1 then
                stats:setStress(stats:getStress() + 0.0002);
            end
        end
    end
end

local function drinkertick()
    local player = getPlayer();
    local playerdata = player:getModData();
    if player:HasTrait("drinker") then
        local hoursthreshold = 24;
        if player:HasTrait("Lucky") then
            hoursthreshold = hoursthreshold + 4;
        end
        if player:HasTrait("Unlucky") then
            hoursthreshold = hoursthreshold - 2;
        end
        if player:HasTrait("Lightdrinker") then
            hoursthreshold = hoursthreshold - 2;
        end
        playerdata.iHoursSinceDrink = playerdata.iHoursSinceDrink + 1;
        if playerdata.bSatedDrink == true then
            if playerdata.iHoursSinceDrink >= hoursthreshold then
                if ZombRand(100) <= hoursthreshold / 4 then
                    playerdata.bSatedDrink = false;
                    print("Player needs alcohol.");
                    player:Say("I need alcohol.");
                end
            end
        end
    end
end

local function drinkerpoison()
    local player = getPlayer();
    local playerdata = player:getModData();
    if playerdata.iHoursSinceDrink > 72 and playerdata.bSatedDrink == false then
        print("Player is suffering from alcohol withdrawal.");
        player:Say("*Alcohol Withdrawal*");
        player:getBodyDamage():setPoisonLevel((playerdata.iHoursSinceDrink / 5));
    end
end

local function bouncerupdate(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    local chance = 3;
    local enemies = player:getSpottedList();
    if player:HasTrait("bouncer") then
        if player:HasTrait("Lucky") then
            chance = chance + 1;
        end
        if player:HasTrait("Unlucky") then
            chance = chance - 1;
        end
        if playerdata.iBouncercooldown == nil then
            playerdata.iBouncercooldown = 0;
        end
        if playerdata.iBouncercooldown > 0 then
            playerdata.iBouncercooldown = playerdata.iBouncercooldown - 1;
        end
        if enemies:size() > 2 then
            for i = 0, enemies:size() - 1 do
                if enemies:get(i):isZombie() then
                    if enemies:get(i):DistTo(player) <= 1.5 then
                        if ZombRand(0, 101) <= chance then
                            if playerdata.iBouncercooldown <= 0 then
                                enemies:get(i):Hit(player:getUseHandWeapon(), player, ZombRand(1, 12), false, 1);
                                playerdata.iBouncercooldown = 60;
                            end
                        end
                    end
                end
            end
        end
    end
end

local function martial(_actor, _target, _weapon, _damage)
    local player = getPlayer();
    local weapon = _weapon;
    local critchance = 10;
    if _actor == player and player:HasTrait("martial") then
        if player:HasTrait("Lucky") then
            critchance = critchance + 2;
        end
        if player:HasTrait("Unlucky") then
            critchance = critchance - 2;
        end
        critchance = critchance + player:getPerkLevel(Perks.SmallBlunt) * 1.5;
        if _weapon:getName() == "Bare Hands" then
            weapon:setDoorDamage(9);
            weapon:setTreeDamage(1);
            weapon:getCategories():set(0, "SmallBlunt");
            weapon:setMinDamage(1);
            weapon:setMaxDamage(2.4);
            if _target:isZombie() and ZombRand(0, 101) <= critchance then
                _target:setHealth(_target:getHealth() - 100);
            else
                _target:setHealth(_target:getHealth() - (damage * 1.2) * 0.1);
            end
            if _target:getHealth() <= 0 then
                _target:Kill(player);
            end
        end
    end
end

local function problunt(_actor, _target, _weapon, _damage)
    local player = getPlayer();
    local playerdata = player:getModData();
    local weapon = _weapon;
    local critchance = player:getPerkLevel(Perks.Blunt) + player:getPerkLevel(Perks.SmallBlunt) + 5;
    local damage = _damage;
    if _actor == player and player:HasTrait("problunt") then
        if weapon:getCategories():contains("Blunt") or weapon:getCategories():contains("SmallBlunt") then
            if player:HasTrait("Lucky") then
                critchance = critchance + 1;
            end
            if player:HasTrait("Unlucky") then
                critchance = critchance - 1;
            end
            if _target:isZombie() and ZombRand(0, 101) <= critchance then
                _target:setHealth(_target:getHealth() - 100);
            else
                _target:setHealth(_target:getHealth() - (damage * 1.2) * 0.1);
            end
            if _target:getHealth() <= 0 then
                _target:Kill(player);
            end
            if playerdata.iLastWeaponCond == nil then
                playerdata.iLastWeaponCond = weapon:getCondition();
            end
            if playerdata.iLastWeaponCond > weapon:getCondition() then
                playerdata.iLastWeaponCond = weapon:getCondition();
                if weapon:getCondition() < weapon:getConditionMax() then
                    weapon:setCondition(weapon:getCondition() + 1);
                end
            end
        end
    end
end

local function problade(_actor, _target, _weapon, _damage)
    local player = getPlayer();
    local playerdata = player:getModData();
    local weapon = _weapon;
    local critchance = player:getPerkLevel(Perks.Axe) + player:getPerkLevel(Perks.SmallBlade) + player:getPerkLevel(Perks.LongBlade);
    local damage = _damage;
    if _actor == player and player:HasTrait("problade") then
        if weapon:getCategories():contains("SmallBlade") or weapon:getCategories():contains("Axe") or weapon:getCategories():contains("LongBlade") then
            if player:HasTrait("Lucky") then
                critchance = critchance + 1;
            end
            if player:HasTrait("Unlucky") then
                critchance = critchance - 1;
            end
            if _target:isZombie() and ZombRand(0, 101) <= critchance then
                _target:setHealth(_target:getHealth() - 100);
            else
                _target:setHealth(_target:getHealth() - (damage * 1.2) * 0.1);
            end
            if _target:getHealth() <= 0 then
                _target:Kill(player);
            end
            if ZombRand(0, 101) <= 10 then
                if playerdata.iLastWeaponCond == nil then
                    playerdata.iLastWeaponCond = weapon:getCondition();
                end
                if playerdata.iLastWeaponCond > weapon:getCondition() then
                    playerdata.iLastWeaponCond = weapon:getCondition();
                    if weapon:getCondition() < weapon:getConditionMax() then
                        weapon:setCondition(weapon:getCondition() + 1);
                    end
                end
            end
        end
    end
end

local function progun(_actor, _weapon)
    local player = getPlayer();
    local weapon = _weapon;
    local weaponmoddata = weapon:getModData();
    local chance = 10 + player:getPerkLevel(Perks.Firearm) * 5;
    if _actor == player and player:HasTrait("progun") and weapon:getSubCategory() == "Firearm" then
        if player:HasTrait("Lucky") then
            chance = chance + 5;
        end
        if player:HasTrait("Unlucky") then
            chance = chance - 5;
        end
        if ZombRand(0, 101) <= 10 then
            if weapon:getCondition() < weapon:getConditionMax() then
                weapon:setCondition(weapon:getCondition() + 1);
            end
        end
        if ZombRand(0, 101) <= chance then
            if weaponmoddata.currentCapacity < weaponmoddata.maxCapacity and weaponmoddata.currentCapacity > 0 then
                weaponmoddata.currentCapacity = weaponmoddata.currentCapacity + 1;
            end
        end
    end
end

local function prospear(_actor, _target, _weapon, _damage)
    local player = getPlayer();
    local playerdata = player:getModData();
    local weapon = _weapon;
    local critchance = player:getPerkLevel(Perks.Spear) + 5;
    local damage = _damage;
    if _actor == player and player:HasTrait("prospear") then
        if weapon:getCategories():contains("Spear") then
            if player:HasTrait("Lucky") then
                critchance = critchance + 1;
            end
            if player:HasTrait("Unlucky") then
                critchance = critchance - 1;
            end
            if _target:isZombie() and ZombRand(0, 101) <= critchance then
                _target:setHealth(_target:getHealth() - 100);
            else
                _target:setHealth(_target:getHealth() - (damage * 1.2) * 0.1);
            end
            if _target:getHealth() <= 0 then
                _target:Kill(player);
            end
            if playerdata.iLastWeaponCond == nil then
                playerdata.iLastWeaponCond = weapon:getCondition();
            end
            if playerdata.iLastWeaponCond > weapon:getCondition() then
                playerdata.iLastWeaponCond = weapon:getCondition();
                if weapon:getCondition() < weapon:getConditionMax() then
                    weapon:setCondition(weapon:getCondition() + 1);
                end
            end
        end
    end
end
local function albino(_player)
    local player = _player;
    if player:HasTrait("albino") then
        local time = getGameTime();
        if player:isOutside() then
            local tod = time:getTimeOfDay();
            if tod > 6 and tod < 18 then
                local stats = player:getStats();
                local pain = stats:getPain();
                if pain < 25 then
                    stats:setPain(20);
                end

            end
        end
    end
end

local function amputee(_player)
    local player = _player;
    if player:HasTrait("amputee") then
        local handitem = player:getSecondaryHandItem();
        local bodydamage = player:getBodyDamage();
        if handitem ~= nil then
            if handitem:getName() ~= "Bare Hands" then
                player:dropHandItems();
            end
        end

        if bodydamage:getBodyPart(BodyPartType.FromString("UpperArm_L")):HasInjury() then
            bodydamage:getBodyPart(BodyPartType.FromString("UpperArm_L")):SetBitten(false);
            bodydamage:getBodyPart(BodyPartType.FromString("UpperArm_L")):setScratched(false);
            bodydamage:getBodyPart(BodyPartType.FromString("UpperArm_L")):setDeepWounded(false);
            bodydamage:getBodyPart(BodyPartType.FromString("UpperArm_L")):setBleeding(false);
            bodydamage:getBodyPart(BodyPartType.FromString("UpperArm_L")):setHaveGlass(false);
            bodydamage:getBodyPart(BodyPartType.FromString("UpperArm_L")):SetInfected(false);
        end
        if bodydamage:getBodyPart(BodyPartType.FromString("ForeArm_L")):HasInjury() then
            bodydamage:getBodyPart(BodyPartType.FromString("ForeArm_L")):SetBitten(false);
            bodydamage:getBodyPart(BodyPartType.FromString("ForeArm_L")):setScratched(false);
            bodydamage:getBodyPart(BodyPartType.FromString("ForeArm_L")):setDeepWounded(false);
            bodydamage:getBodyPart(BodyPartType.FromString("ForeArm_L")):setBleeding(false);
            bodydamage:getBodyPart(BodyPartType.FromString("ForeArm_L")):setHaveGlass(false);
            bodydamage:getBodyPart(BodyPartType.FromString("ForeArm_L")):SetInfected(false);
        end
        if bodydamage:getBodyPart(BodyPartType.FromString("Hand_L")):HasInjury() then
            bodydamage:getBodyPart(BodyPartType.FromString("Hand_L")):SetBitten(false);
            bodydamage:getBodyPart(BodyPartType.FromString("Hand_L")):setScratched(false);
            bodydamage:getBodyPart(BodyPartType.FromString("Hand_L")):setDeepWounded(false);
            bodydamage:getBodyPart(BodyPartType.FromString("Hand_L")):setBleeding(false);
            bodydamage:getBodyPart(BodyPartType.FromString("Hand_L")):setHaveGlass(false);
            bodydamage:getBodyPart(BodyPartType.FromString("Hand_L")):SetInfected(false);
        end
    end
end

local function actionhero(_actor, _target, _weapon, _damage)
    local player = getPlayer();
    local weapon = _weapon;
    local critchance = 10;
    local damage = _damage * 0.5;
    local enemies = player:getSpottedList();
    local multiplier = 2;
    if _actor == player and player:HasTrait("actionhero") then
        if player:HasTrait("martial") == false and weapon:getName() == "Bare Hands" then
            return
        end ;

        for i = 0, enemies:size() - 1 do
            local enemy = enemies:get(i);
            if enemy:isZombie() then
                local distance = enemy:DistTo(player)
                if distance < 10 and distance > 5 then
                    critchance = critchance + 2;
                    multiplier = multiplier + 0.1;
                elseif distance <= 5 and distance >= 2 then
                    critchance = critchance + 4;
                    multiplier = multiplier + 0.2;
                elseif distance < 2 then
                    critchance = critchance + 7;
                    multiplier = multiplier + 0.5;
                end
            end
        end

        if player:HasTrait("Lucky") then
            critchance = critchance + 2;
        end
        if player:HasTrait("Unlucky") then
            critchance = critchance - 2;
        end
        if _target:isZombie() and ZombRand(0, 101) <= critchance then
            _target:setHealth(_target:getHealth() - 100);
        else
            _target:setHealth(_target:getHealth() - (damage * multiplier) * 0.1);
        end
        if _target:getHealth() <= 0 then
            _target:Kill(player);
        end
    end
end

local function gimp()
    local player = getPlayer();
    local playerdata = player:getModData();
    local modifier = 0.85;
    if player:HasTrait("gimp") and player:isLocalPlayer() then
        if playerdata.fToadTraitsPlayerX ~= nil and playerdata.fToadTraitsPlayerY ~= nil then
            local oldx = playerdata.fToadTraitsPlayerX;
            local oldy = playerdata.fToadTraitsPlayerY;
            local newx = player:getX();
            local newy = player:getY();
            local xdif = (newx - oldx);
            local ydif = (newy - oldy);
            if xdif > 5 or xdif < -5 or ydif > 5 or ydif < -5 then
                playerdata.fToadTraitsPlayerX = player:getX();
                playerdata.fToadTraitsPlayerY = player:getY();

                return
            end
            player:setX((oldx + xdif * modifier));
            player:setY((oldy + ydif * modifier));
        end
        playerdata.fToadTraitsPlayerX = player:getX();
        playerdata.fToadTraitsPlayerY = player:getY();
    end
end

local function fast()
    local player = getPlayer();
    local playerdata = player:getModData();
    local vector = player:getPlayerMoveDir();
    local length = vector:getLength();
    local modifier = 2.15;
    if player:HasTrait("fast") and player:isLocalPlayer() then
        if playerdata.fToadTraitsPlayerX ~= nil and playerdata.fToadTraitsPlayerY ~= nil then
            local oldx = playerdata.fToadTraitsPlayerX;
            local oldy = playerdata.fToadTraitsPlayerY;
            local newx = player:getX();
            local newy = player:getY();
            local xdif = (newx - oldx);
            local ydif = (newy - oldy);
            if xdif > 5 or xdif < -5 or ydif > 5 or ydif < -5 then
                playerdata.fToadTraitsPlayerX = player:getX();
                playerdata.fToadTraitsPlayerY = player:getY();

                return
            end
            if xdif ~= 0 or xdif ~= 0 or ydif ~= 0 or ydif ~= 0 then
                player:setX((oldx + xdif * modifier));
                player:setY((oldy + ydif * modifier));
                playerdata.fToadTraitsPlayerX = player:getX();
                playerdata.fToadTraitsPlayerY = player:getY();
            end
        else
            playerdata.fToadTraitsPlayerX = player:getX();
            playerdata.fToadTraitsPlayerY = player:getY();
        end
    end

end
local function anemic(_player)
    local player = _player;
    if player:HasTrait("anemic") then
        local bodydamage = player:getBodyDamage();
        local bleeding = bodydamage:getNumPartsBleeding();
        if bleeding > 0 then
            for i = 0, player:getBodyDamage():getBodyParts():size() - 1 do
                local b = player:getBodyDamage():getBodyParts():get(i);
                if b:bleeding() and b:IsBleedingStemmed() == false then
                    b:ReduceHealth(0.05);
                end
            end
        end

    end
end
local function thickblood(_player)
    local player = _player;
    if player:HasTrait("thickblood") then
        local bodydamage = player:getBodyDamage();
        local bleeding = bodydamage:getNumPartsBleeding();
        if bleeding > 0 then
            for i = 0, player:getBodyDamage():getBodyParts():size() - 1 do
                local b = player:getBodyDamage():getBodyParts():get(i);
                if b:bleeding() and b:IsBleedingStemmed() == false then
                    b:AddHealth(0.05);
                end
            end
        end

    end
end

local function vehicleCheck(_player)
    local player = _player;
    if player:isDriving() == true then
        local vehicle = player:getVehicle();
        local vmd = vehicle:getModData();
        if vmd.bUpdated == nil then
            vmd.fBrakingForce = vehicle:getBrakingForce();
            vmd.fMaxSpeed = vehicle:getMaxSpeed();
            vmd.iEngineQuality = vehicle:getEngineQuality();
            vmd.iEngineLoudness = vehicle:getEngineLoudness()
            vmd.iEnginePower = vehicle:getEnginePower();
            vmd.sState = "Normal";
            vmd.bUpdated = true;
        else
            if player:HasTrait("expertdriver") and vmd.sState ~= "ExpertDriver" then
                vehicle:setBrakingForce(vmd.fBrakingForce * 2);
                vehicle:setEngineFeature(vmd.iEngineQuality * 1.5, vmd.iEngineLoudness * 0.25, vmd.iEnginePower * 1.5);
                vehicle:setMaxSpeed(vmd.fMaxSpeed * 1.25);
                vmd.sState = "ExpertDriver";
                print("Vehicle State: " .. vmd.sState);
                vehicle:update();
            end
            if player:HasTrait("poordriver") and vmd.sState ~= "PoorDriver" then
                vehicle:setBrakingForce(vmd.fBrakingForce * 0.5);
                vehicle:setEngineFeature(vmd.iEngineQuality * 0.75, vmd.iEngineLoudness * 1.5, vmd.iEnginePower * 0.75);
                vehicle:setMaxSpeed(vmd.fMaxSpeed * 0.75);
                vmd.sState = "PoorDriver";
                print("Vehicle State: " .. vmd.sState);
                vehicle:update();
            end
            if player:HasTrait("expertdriver") == false and player:HasTrait("poordriver") == false and vmd.sState ~= "Normal" then
                vehicle:setBrakingForce(vmd.fBrakingForce);
                vehicle:setEngineFeature(vmd.iEngineQuality, vmd.iEngineLoudness, vmd.iEnginePower);
                vehicle:setMaxSpeed(vmd.fMaxSpeed);
                vmd.sState = "Normal";
                print("Vehicle State: " .. vmd.sState);
                vehicle:update();
            end

        end

    end
end

local function SuperImmune(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    local bodydamage = player:getBodyDamage();
    local chance = 15;
    if player:HasTrait("superimmune") then
        if playerdata.bSuperImmune ~= nil then
            if player:HasTrait("Lucky") then
                chance = chance + 1;
            end
            if player:HasTrait("Unlucky") then
                chance = chance - 1;
            end
            if playerdata.bSuperImmune == true then
                if bodydamage:isInfected() then
                    if ZombRand(0, 101) <= chance then
                        print("Player's Immune system fought-off zombification.");
                        bodydamage:setInfected(false);
                        if ZombRand(0, 101) > chance then
                            print("Do fake infection");
                            bodydamage:setIsFakeInfected(true);
                            bodydamage:setFakeInfectionLevel(0.1);
                        end
                    else
                        print("Immune system failed.");
                        playerdata.bSuperImmune = false;
                    end
                end

            end
        else
            playerdata.bSuperImmune = true;
        end
        if bodydamage:isInfected() == false and playerdata.bSuperImmune == false then
            playerdata.bSuperImmune = true;
        end

        for i = 0, bodydamage:getBodyParts():size() - 1 do
            local b = bodydamage:getBodyParts():get(i);
            if b:HasInjury() then
                if b:isInfectedWound() then
                    b:setInfectedWound(false);
                end
            end

        end

    end
end

local function Immunocompromised(_player, _playerdata)
    local player = _player;
    local playerdata = _playerdata;
    local bodydamage = player:getBodyDamage();
    local chance = 15;
    if player:HasTrait("immunocompromised") then
        for i = 0, bodydamage:getBodyParts():size() - 1 do
            local b = bodydamage:getBodyParts():get(i);
            if b:HasInjury() then
                if b:isInfectedWound() and b:getAlcoholLevel() <= 0 then
                    b:setWoundInfectionLevel(b:getWoundInfectionLevel() + 0.001);
                end
            end

        end

    end
end

local function MainPlayerUpdate(_player)
    local player = _player;
    local playerdata = player:getModData();
    indefatigable(player, playerdata);
    if suspendevasive == false then
        ToadTraitEvasive(player, playerdata);
    end
    anemic(player);
    thickblood(player);
    Gordanite(player);
    CheckDepress(player, playerdata);
    CheckSelfHarm(player);
    Blissful(player);
    badteethtrait(player);
    hardytrait(player);
    drinkerupdate(player, playerdata);
    bouncerupdate(player, playerdata);
    albino(player);
    amputee(player);
    vehicleCheck(player);
    SuperImmune(player, playerdata);
    Immunocompromised(player, playerdata);
end--]]

--local units = 0 Blood stuff
--	local visual = character:getHumanVisual()
--	for i=1,BloodBodyPartType.MAX:index() do
--		local part = BloodBodyPartType.FromIndex(i-1)
--		-- Soap is used for blood but not for dirt.
--		if visual:getBlood(part) > 0 then
--			units = units + 1
--		end
--	end

--Events.OnPlayerMove.Add(gimp);
--Events.OnPlayerMove.Add(fast);
--Events.OnWeaponHitCharacter.Add(problunt);
--Events.OnWeaponHitCharacter.Add(problade);
--Events.OnWeaponHitCharacter.Add(prospear);
--Events.OnWeaponHitCharacter.Add(actionhero);
--Events.OnWeaponSwing.Add(FacilityRunNGun);
--Events.OnWeaponHitCharacter.Add(martial);
--Events.OnDawn.Add(drinkerpoison);
--Events.EveryHours.Add(drinkertick);
--Events.AddXP.Add(LabLearning);
--Events.OnDawn.Add(indefatigablecounter);
--Events.OnPlayerUpdate.Add(MainPlayerUpdate);
--Events.EveryTenMinutes.Add(FacilityDoomTick);
--Events.EveryHours.Add(ToadTraitDepressive);
--Events.OnNewGame.Add(initToadTraitsPerks);
--Events.OnNewGame.Add(LabLearning);
--Events.OnCharacterCreateStats.Add(LabLearning);
--Events.OnCharacterCreateStats.Add(BaseGameCharacterDetails.CreateCharacterStats); Possible way to mess with available perks
--Events.OnWeaponSwing.Add(FacilityRunNGun);

Events.OnWeaponHitCharacter.Add(FacilityCharacterHit);
Events.EveryHours.Add(FacilityNecroticTick);
Events.OnPlayerMove.Add(FacilityBulwarkKnockdown);
Events.OnPlayerUpdate.Add(FacilityPlayerUpdate);
Events.OnDawn.Add(FacilityUndyingCooldown);
Events.OnDawn.Add(FacilityDoomedCheck);
Events.EveryHours.Add(FacilityAmnesiaTick);
Events.EveryHours.Add(FacilityGasMaskDrain);
Events.EveryTenMinutes.Add(FacilityEvery10Minutes);
Events.LevelPerk.Add(FacilityPotentialTick);
Events.AddXP.Add(LabLearning);
Events.OnNewGame.Add(initFacilityTraitData);
Events.OnNewGame.Add(FacilityBeginGame);
Events.OnGameBoot.Add(initFacilityTraits);
Events.OnGameBoot.Add(initFacilityProfs);

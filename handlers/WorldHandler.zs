class ZDA_WorldHandler : EventHandler 
{
    ZDA_StaticHandler staticHandler;
    /*array <string> mapPacks;

    override void WorldLoaded(WorldEvent e)
    {
        if(!mapPacks.Size())
        {
            int levelsCount = LevelInfo.GetLevelInfoCount();
            for(int i=0; i<levelsCount; i++)
            {
                let level = LevelInfo.GetLevelInfo(i);
                if(level.MapExists(level.MapName))
                {
                    if(i > 0)
                    {
                        let prevLevel = LevelInfo.GetLevelInfo(i-1);
                        if(prevLevel.MapName.Left(prevLevel.MapName.length()-2) == level.MapName.Left(level.MapName.length()-2) || level.LookupLevelName() == "UAC Outpost") 
                            continue;
                    }
                    string mapName = level.MapName.Left(level.MapName.length()-2);
                    string mapPackName = Stringtable.Localize("$C_"..mapName);
                    mapPacks.Push(mapPackName);
                }
            }
        }
    }*/


    // Map<int, Weapon> WeaponsMap;
    // Map<int, ZDA_WeaponStats> WeaponStatsMap;
    // Map<int, int> WeaponsToWeaponStatsMap;

    // override void WorldLoaded(WorldEvent e)
    // {
    //     if(!staticHandler) {
    //         staticHandler = ZDA_StaticHandler(StaticEventHandler.Find("ZDA_StaticHandler"));
    //     }
    // }

    // override void NewGame()
    // {
        
    // }

    override void WorldThingDamaged (WorldEvent e)
    {
        if (e.Thing && e.Thing.Player 
        && ((e.inflictor && e.inflictor.bIsMonster)
        || e.damageSource && e.damageSource.bIsMonster)) {
            let itemStatsController = ZDA_ItemStatsController(e.Thing.Player.mo.FindInventory('ZDA_ItemStatsController'));
            if(itemStatsController && itemStatsController.reflectDamage && itemStatsController.reflectDamage > 0) {
                e.damageSource.DamageMobj(e.Thing, e.Thing, itemStatsController.reflectDamage, 'None');
            }
        }
    }

    override void WorldThingSpawned(WorldEvent e)
    {
        if (e.Thing && (e.Thing is "Weapon" && !Inventory(e.Thing).owner/*|| e.Thing is "ZDA_Armor"*/))
        {
            GenerateItemStats(Inventory(e.Thing));
        }
    }

    override void WorldThingDied(WorldEvent e)
    {
        if (e.Thing && e.Thing.bIsMonster)
        {
            //e.Thing.A_GenericFreezeDeath();
            //e.Thing.A_FreezeDeathChunks();
            //e.Thing.Destroy();
        }
    }
    
    // override void WorldThingDamaged(WorldEvent e)
    // {
    //     if (e.Thing && e.Thing.bIsMonster)
    //     {
    //         let playerMo = Players[0].mo;
    //         e.Thing.DamageMobj(playerMo, playerMo, 999, 'Ice');
    //     }
    // }

    static ZDA_StaticHandler GetStaticHandler()
    {
        return ZDA_StaticHandler(StaticEventHandler.Find("ZDA_StaticHandler"));
    }

    static ZDA_ItemStats GenerateItemStats(Inventory item)
    {
        let ItemStatsObject = new("ZDA_ItemStats");   
        ItemStatsObject.ItemObject = item;
        ItemStatsObject.ItemClassName = item.GetClassName();
        PrepareItemProperties(ItemStatsObject);
        
        for(int i = 0; i < Players.Size(); i++)
        {
            if(PlayerInGame[i]) {
                let ItemStatsController = ZDA_ItemStatsController(Players[i].mo.FindInventory("ZDA_ItemStatsController"));
                let PlayerInventory = ZDA_PlayerInventory(Players[i].mo.FindInventory("ZDA_PlayerInventory"));
                if(ItemStatsController) {
                    ItemStatsController.itemStats.Push(ItemStatsObject);
                }
            }
        }           

        if(ItemStatsObject.Rarity == "Quality") {
            item.A_SetTranslation('Ice');
        } 
        else if(ItemStatsObject.Rarity == "Exceptional") {
            item.Translation = 2;
        }

        return ItemStatsObject;
    } 

    static void PrepareItemProperties(ZDA_ItemStats ItemStatsObject)
    {
        ItemStatsObject.Rarity = SetItemRarity(ItemStatsObject);
        SetAffixesCount(ItemStatsObject);
        SetItemAffixes(ItemStatsObject);
    }

    static string SetItemRarity(ZDA_ItemStats ItemStatsObject)
    {
        let staticHandler = GetStaticHandler();
        //int i = staticHandler.ITEM_RARITY_NORMAL;
        //let RarityRoll = random(0, 10000);

        // // normal
        // if(RarityRoll <= 5500) {}

        // // quality
        // if(RarityRoll > 5500 && RarityRoll <= 9000) {
        //     i = staticHandler.ITEM_RARITY_QUALITY;
        // }

        // // exceptional
        // if(RarityRoll > 9000 && RarityRoll <= 9999) {
        //     i = staticHandler.ITEM_RARITY_EXCEPTIONAL;
        // }

        // // unique
        // if(RarityRoll == 10000) {
        //     i = staticHandler.ITEM_RARITY_LEGENDARY;
        // }

        let i = staticHandler.ITEM_RARITY_LEGENDARY;
        
        return staticHandler.itemRarities[i];
    }

    static void SetAffixesCount(ZDA_ItemStats ItemStatsObject)
    {
        let staticHandler = GetStaticHandler();

        int minCount = 0;
        vector2 affixCountRange;

        ItemStatsObject.PrefixesCount = 0;
        ItemStatsObject.SuffixesCount = 0;
        // normal: 0 affixes
        if(ItemStatsObject.Rarity == staticHandler.itemRarities[staticHandler.ITEM_RARITY_NORMAL]) return;

        // quality: 1-2 affixes
        if(ItemStatsObject.Rarity == staticHandler.itemRarities[staticHandler.ITEM_RARITY_QUALITY]) {
            minCount = 1;
            affixCountRange = (0, 1);
        }

        // exceptional: 3-4 affixes
        if(ItemStatsObject.Rarity == staticHandler.itemRarities[staticHandler.ITEM_RARITY_EXCEPTIONAL]) {
            minCount = 3;
            affixCountRange = (1, 2);
        }

        // legendary: 5-6 affixes
        if(ItemStatsObject.Rarity == staticHandler.itemRarities[staticHandler.ITEM_RARITY_LEGENDARY]) {
            minCount = 5;
            affixCountRange = (2, 3);
        }

        while(ItemStatsObject.PrefixesCount + ItemStatsObject.SuffixesCount < minCount) {
            ItemStatsObject.PrefixesCount = random(affixCountRange.x, affixCountRange.y);
            ItemStatsObject.SuffixesCount = random(affixCountRange.x, affixCountRange.y);
        }
        return;
    }

    static void SetItemAffixes(ZDA_ItemStats ItemStatsObject)
    {
        let staticHandler = GetStaticHandler();
        
        if(ItemStatsObject.Rarity == staticHandler.itemRarities[staticHandler.ITEM_RARITY_NORMAL]) return;

        if(ItemStatsObject.ItemObject is "Weapon") {
            selectAffixes(ItemStatsObject, ItemStatsObject.PrefixesCount, staticHandler.weaponPrefixes, staticHandler.weaponRarePrefixes);
            selectAffixes(ItemStatsObject, ItemStatsObject.SuffixesCount, staticHandler.weaponSuffixes, staticHandler.weaponRareSuffixes);
            return;
        }

        selectAffixes(ItemStatsObject, ItemStatsObject.PrefixesCount, staticHandler.armorPrefixes, staticHandler.armorRarePrefixes);
        selectAffixes(ItemStatsObject, ItemStatsObject.SuffixesCount, staticHandler.armorSuffixes, staticHandler.armorRareSuffixes);
    }

    static void selectAffixes(ZDA_ItemStats ItemStatsObject, int AffixCount, array <string> affixArray, array <string> rareAffixArray)
    {
        array <string> usedAffixes;

        for(int i = 0; i < AffixCount; i++) {
            let affix = createAffix(affixArray, rareAffixArray, usedAffixes);
            affix.ItemStatsObject = ItemStatsObject;
            affix.ItemObject = ItemStatsObject.ItemObject;
            ItemStatsObject.Affixes.Push(affix);
        }
    }

    static ZDA_Affix createAffix(array <string> affixArray, array <string> rareAffixArray, out array <string> usedAffixes)
    {
        let affixClassName = "";
            
        // select from list of basic affixes
        let sourceArray = affixArray;
        let arrayType = "basic";

        let RareAffixRoll = random(1, 15);
        if(RareAffixRoll == 15) {
            // select from rare affixes instead
            sourceArray = rareAffixArray;
            arrayType = "rare";
        }

        let arrayIndex = random(0, sourceArray.Size()-1);
        // if item already has this affix = select another one from same list (rare if duplicate is rare, otherwise basic)
        while(usedAffixes.Find(arrayType .. arrayIndex) != usedAffixes.Size()) {
            arrayIndex = random(0, sourceArray.Size()-1);
        }
        affixClassName = sourceArray[arrayIndex];
        usedAffixes.Push(arrayType .. arrayIndex);

        return ZDA_Affix(new(affixClassName)).InitFull();
    }
}
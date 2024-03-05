class ZDA_StaticHandler : StaticEventHandler 
{
    const ITEM_RARITY_NORMAL      = 0;
    const ITEM_RARITY_QUALITY     = 1;
    const ITEM_RARITY_EXCEPTIONAL = 2;
    const ITEM_RARITY_LEGENDARY   = 3;

    array <string> itemRarities;

    array <string> weaponPrefixes;
    array <string> weaponRarePrefixes;
    
    array <string> weaponSuffixes;
    array <string> weaponRareSuffixes;
    
    array <string> armorPrefixes;
    array <string> armorRarePrefixes;
    
    array <string> armorSuffixes;
    array <string> armorRareSuffixes;

    override void WorldLoaded(WorldEvent e)
    {
        let worldHandler = ZDA_WorldHandler(EventHandler.Find("ZDA_WorldHandler"));
        worldHandler.staticHandler = self;
    }
    
    override void OnRegister ()
    {
        // item rarities
        itemRarities.PushV(
            "\cjNormal",
            "\cnQuality",
            "\ckExceptional",
            "\ciLegendary"         
        );

        prepareClassesArrays();
        console.printf("weaponPrefixes: %d", weaponPrefixes.Size());
        console.printf("weaponRarePrefixes: %d", weaponRarePrefixes.Size());
        console.printf("weaponSuffixes: %d", weaponSuffixes.Size());
        console.printf("weaponRareSuffixes: %d", weaponRareSuffixes.Size());
    }

    void prepareClassesArrays()
    {
        for (int i=0; i<allclasses.size(); i++) {
            if(!(allclasses[i] is "ZDA_Affix")) continue;
            
            if(allclasses[i].GetParentClass() == 'ZDA_Affix')
            {
                let className = allclasses[i].GetClassName();
                let affix = ZDA_Affix(new(className)).InitFull();
                if(affix.AffixType == ZDA_Affix.AFFIXTYPE_WEAPON) {
                    if(affix.AffixCategory == ZDA_Affix.AFFIXCATEGORY_PREFIX) {
                        prepareAffixArray(affix, weaponPrefixes, weaponRarePrefixes);
                        continue;
                    }
                    prepareAffixArray(affix, weaponSuffixes, weaponRareSuffixes);
                    continue;
                }

                if(affix.AffixType == ZDA_Affix.AFFIXTYPE_ARMOR) {
                    if(affix.AffixCategory == ZDA_Affix.AFFIXCATEGORY_PREFIX) {
                        prepareAffixArray(affix, armorPrefixes, armorRarePrefixes);
                        continue;
                    }
                    prepareAffixArray(affix, armorSuffixes, armorRareSuffixes);
                    continue;
                }
            }
        }
    }

    void prepareAffixArray(ZDA_Affix affix, array <string> affixArray, array <string> rareAffixArray)
    {
        if(affix.IsRare == true) {
            rareAffixArray.Push(affix.GetClassName());
            return;
        }
        affixArray.Push(affix.GetClassName());
    }
}
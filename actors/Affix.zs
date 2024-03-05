class ZDA_Affix play {
    ZDA_ItemStats ItemStatsObject;
    Inventory ItemObject;
    int AffixType;
    int AffixCategory;
    string AffixCategoryShortcode;
    string Description;
    bool IsRare;
    bool IsGlobal;
    bool IsApplied;
    
    enum AffixTypes {
        AFFIXTYPE_WEAPON,
        AFFIXTYPE_ARMOR,
    }

    enum AffixCategories {
        AFFIXCATEGORY_PREFIX,
        AFFIXCATEGORY_SUFFIX,
    }

    enum AffixCategoriesShortcodes {
        AFFIXCATEGORYSHORTCODE_PREFIX = "\cy[P]\c-",
        AFFIXCATEGORYSHORTCODE_SUFFIX = "\cx[S]\c-",
    }

    virtual ZDA_Affix InitFull() {
        Init();
        InitDefault();
        return self;
    }

    virtual ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_PREFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.IsRare = false;
        self.IsGlobal = false;
        return self;
    }

    virtual ZDA_Affix InitDefault() {
        self.AffixCategoryShortcode = GetAffixCategoryShortcode(self.AffixCategory);
        return self;
    }

    string GetAffixCategoryShortcode(int AffixCategory) {
        if(AffixCategory == AFFIXCATEGORY_PREFIX)
            return AFFIXCATEGORYSHORTCODE_PREFIX;
        return AFFIXCATEGORYSHORTCODE_SUFFIX;
    }

    // static Object Create(string className) {
    //     let affix = ZDA_Affix(new(className)).Init();
    //     return affix;
    // }

    void ApplyEffect() {
        //console.printf("applying effect...");
        if(ItemStatsObject && ItemStatsObject.ItemStatsController && !IsApplied) {
            EnableAffixEffect();
            //ItemStatsObject.ItemObject.owner.GiveInventory("SuperShotgun", 1);
            IsApplied = true;
            //console.printf("...applied.");
        }
    }

    void RevertEffect() {
        //console.printf("reverting effect...");
        if(ItemStatsObject && ItemStatsObject.ItemStatsController && IsApplied) {
            DisableAffixEffect();
            //ItemStatsObject.ItemObject.owner.GiveInventory("SuperShotgun", 1);
            IsApplied = false;
            //console.printf("...reverted.");
        }
    }

    virtual void EnableAffixEffect() {}
    virtual void DisableAffixEffect() {}
}
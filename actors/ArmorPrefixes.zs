class ZDA_PrefixArmorAddDefense : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_PREFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_ARMOR;
        self.IsRare = false;
        self.IsGlobal = false;
        return self;
    }
}

class ZDA_PrefixArmorAddMoreDefense : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_PREFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_ARMOR;
        self.IsRare = true;
        self.IsGlobal = false;
        return self;
    }
}
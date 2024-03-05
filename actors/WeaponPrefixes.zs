class ZDA_PrefixWeaponIncreaseBaseDamageMultiplier : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_PREFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "10% increased base Damage";
        self.IsRare = false;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.baseDamageMultiplier += 0.1;
    }

    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.baseDamageMultiplier -= 0.1;
    }
}

class ZDA_PrefixWeaponIncreaseBaseFlatDamage : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_PREFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "+5 to base Damage";
        self.IsRare = false;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.baseFlatDamageBeforeMultiplier += 5;
    }

    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.baseFlatDamageBeforeMultiplier -= 5;
    }
}

class ZDA_PrefixWeaponIncreaseFlatDamage : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_PREFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "+5 to final Damage";
        self.IsRare = false;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.flatDamageAfterMultiplier += 5;
    }

    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.flatDamageAfterMultiplier -= 5;
    }
}

class ZDA_PrefixWeaponAttackSpeed : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_PREFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "100% increased Attack Speed";
        self.IsRare = true;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.weaponSpeed += 1;
    }

    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.weaponSpeed -= 1;
    }
}

class ZDA_PrefixWeaponIceDamageType : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_PREFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "Weapon inflicts Ice damage";
        self.IsRare = true;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.newDamageType = 'Ice';
    }

    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.newDamageType = '';
    }
}

class ZDA_PrefixWeaponDoubleDamage : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_PREFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "10% chance to inflict Double Damage";
        self.IsRare = true;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.doubleDamageChance += 10;
    }

    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.doubleDamageChance -= 10;
    }
}

class ZDA_PrefixWeaponPerfectAccuracy : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_PREFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "Perfect Accuracy";
        self.IsRare = false;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.perfectAccuracy = true;
    }

    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.perfectAccuracy = false;
    }
}
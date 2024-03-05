class ZDA_SuffixWeaponAddHealth : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_SUFFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "+20 to maximum Health";
        self.IsRare = false;
        self.IsGlobal = true;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.owner.player.mo.MaxHealth = ItemStatsObject.ItemStatsController.owner.player.mo.GetMaxHealth() + 20;
    }

    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.owner.player.mo.MaxHealth = ItemStatsObject.ItemStatsController.owner.player.mo.GetMaxHealth() - 20;
    }
}

class ZDA_SuffixWeaponMovespeed : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_SUFFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "20% increased Movement Speed";
        self.IsRare = false;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.owner.player.mo.speed += 0.2;
    }

    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.owner.player.mo.speed -= 0.2;
    }
}

class ZDA_SuffixWeaponDamageReduction : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_SUFFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "Incoming damage reduced by 3";
        self.IsRare = false;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.damageReduction += 100;
    }

    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.damageReduction -= 100;
    }
}

class ZDA_SuffixWeaponRegen : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_SUFFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "+0.5 Health Regeneration";
        self.IsRare = true;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.regenPower += 1;
    }
    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.regenPower -= 1;
    }
}

class ZDA_SuffixWeaponSilencer : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_SUFFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "Weapon is silenced";
        self.IsRare = false;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        if(ItemStatsObject.ItemStatsController.owner.player.ReadyWeapon) {
            ItemStatsObject.ItemStatsController.owner.player.ReadyWeapon.bNoAlert = true;
            ItemStatsObject.ItemStatsController.owner.player.ReadyWeapon.A_SoundVolume(1, 0.1);
        }
    }
    override void DisableAffixEffect() {
        if(ItemStatsObject.ItemStatsController.owner.player.ReadyWeapon) {
            ItemStatsObject.ItemStatsController.owner.player.ReadyWeapon.bNoAlert = false;
            ItemStatsObject.ItemStatsController.owner.player.ReadyWeapon.A_SoundVolume(1, 1);
        }
    }
}


// TODO: REFLECTED DAMAGE CAN FREEZE IF ICE PREFIX EQUIPPED
class ZDA_SuffixWeaponReflect : ZDA_Affix
{
    override ZDA_Affix Init() {
        self.AffixCategory = ZDA_Affix.AFFIXCATEGORY_SUFFIX;
        self.AffixType = ZDA_Affix.AFFIXTYPE_WEAPON;
        self.Description = "5 Damage reflected to the attacker";
        self.IsRare = true;
        self.IsGlobal = false;
        return self;
    }

    override void EnableAffixEffect() {
        ItemStatsObject.ItemStatsController.reflectDamage += 5;
    }
    override void DisableAffixEffect() {
        ItemStatsObject.ItemStatsController.reflectDamage -= 5;
    }
}
class ZDA_Utility: Inventory
{
    Default {
        Inventory.Amount 0;
        Inventory.MaxAmount 1;
        +Inventory.PersistentPower;
    }
}

class ZDA_WeaponSpeedScaling: ZDA_Utility
{
    private PSpriteSpeedScalerSet scalers;
	
	override void Tick() {
		Super.Tick();
		
		if (Owner && Owner.player && Owner.player.ReadyWeapon)
        {
            let itemStatsController = ZDA_ItemStatsController(owner.FindInventory("ZDA_ItemStatsController"));
            scalers.Tick(Owner.player.ReadyWeapon, 1 - itemStatsController.weaponSpeed);
        }
		else if (scalers.first)
			scalers.Clear();
	}
}
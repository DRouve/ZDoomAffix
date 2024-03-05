class ZDA_FighterPlayer : FighterPlayer replaces FighterPlayer
{
	ZDA_ItemStatsController ItemStatsController;
	override void Tick()
	{
		super.Tick();
		if(!ItemStatsController) {
			ItemStatsController = ZDA_ItemStatsController(player.mo.FindInventory("ZDA_ItemStatsController"));
		}
	}

    override bool CanTouchItem(Inventory item) {
		if(item is 'Weapon') {
			let weapon = Weapon(player.mo.FindInventory(item.GetClassName()));
			if(weapon) {
				console.printf('zztouch');
				ItemStatsController.touchedItem = item;
				ItemStatsController.touchedItemPos = (item.pos.x, item.pos.y, item.pos.z);
				ItemStatsController.touchTimer = 2;
				return false;
			}
		}
		return super.CanTouchItem(item);
	}
}
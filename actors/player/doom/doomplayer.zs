class ZDA_DoomPlayer : DoomPlayer replaces DoomPlayer
{
	ZDA_ItemStatsController ItemStatsController;
	ZDA_PlayerInventory PlayerInventory;
	override void Tick()
	{
		super.Tick();
		if(!ItemStatsController) {
			ItemStatsController = ZDA_ItemStatsController(player.mo.FindInventory("ZDA_ItemStatsController"));
		}
		if(!PlayerInventory) {
			PlayerInventory = ZDA_PlayerInventory(player.mo.FindInventory("ZDA_PlayerInventory"));
		}
	}

	// override void CheckWeaponChange ()
	// {
		

	// 	let player = self.player;
	// 	if (!player) return;	
	// 	if ((player.WeaponState & WF_DISABLESWITCH) || // Weapon changing has been disabled.
	// 		player.morphTics != 0)					// Morphed classes cannot change weapons.
	// 	{ // ...so throw away any pending weapon requests.
	// 		player.PendingWeapon = WP_NOCHANGE;
	// 	}

	// 	// Put the weapon away if the player has a pending weapon or has died, and
	// 	// we're at a place in the state sequence where dropping the weapon is okay.
	// 	if ((player.PendingWeapon != WP_NOCHANGE || player.health <= 0) &&
	// 		player.WeaponState & WF_WEAPONSWITCHOK)
	// 	{
	// 		DropWeapon();
	// 	}

	// 	// if(player.PendingWeapon) {
	// 	// 	console.printf("..... pending: %s ....", player.PendingWeapon.GetClassName());
	// 	// }
	// 	if(player.PendingWeapon != WP_NOCHANGE) {
	// 		console.printf("NOT NOCHANGE");
	// 	}

	// 	//player.PendingWeapon = player.ReadyWeapon;
	// }

    override bool CanTouchItem(Inventory item) {
		//player.mo.A_Print(item.GetClassName());
		if(item is 'Weapon' || item is 'ZDA_Sphere') {
			// can't pick up if inventory is full
			if(PlayerInventory.Items.Size() >= PlayerInventory.inventorySlots) {
				return false;
			}

			// can't pick up if no itemStats attached (impossible under normal circumstances)
			let itemStats = ItemStatsController.GetItemStats(item);
			if(!itemStats && !(item is 'ZDA_Sphere')) {
				return false;
			}

			let duplicateWeapon = Inventory(player.mo.FindInventory(item.GetClassName()));
			console.printf("equipped: %d", ZDA_ItemStatsController.countEquippedWeapons(player.mo));
			console.printf("max: %d", PlayerInventory.maxWeapons);
			
			if(
				// duplicated weapons go to the inventory
				duplicateWeapon 
				// not duplicated weapons should go to the inventory if max weapons equipped
				|| (!duplicateWeapon && ZDA_ItemStatsController.countEquippedWeapons(player.mo) >= PlayerInventory.maxWeapons) 
				// non-weapons go to the inventory, too
				|| !(item is 'Weapon')
			) {
				let weapon = Inventory(item);
				let spawnState = weapon.FindState("Spawn");
				let icon = spawnState.GetSpriteTexture(0);

				let emptySlot = PlayerInventory.findEmptySlot();

				let inventoryItem = new("ZDA_InventoryItem").Init(
					weapon.GetClassName(),
					itemStats,
					icon,
					weapon.GetTag(),
					emptySlot
				);
				PlayerInventory.Items.Push(inventoryItem);
				emptySlot.heldItem = inventoryItem; // error here when picking with full weapon slots?
				//item.CallTryPickup(ItemStatsController);
				//return false;
				
				// pick up and destroy duplicate "AmmoGive1 = 0" items like Chainsaw + simulate picking up
				if (Weapon(item).AmmoGive1 == 0 && Weapon(item).AmmoGive2 == 0) {
					player.bonuscount = Inventory.BONUSADD;
					item.PlayPickupSound(player.mo);
					item.Destroy();
				}				
			}

			

			
			//if(weapon) {
				// todo: serialize, add to inventory
				// let itemStats = ItemStatsController.GetItemStats(weapon);
				// if(itemStats && PlayerInventory.Items.Size() < PlayerInventory.inventorySlots) {
				// 	// bool apply;
				// 	// TextureID icon;
				// 	// [icon, apply] = BaseStatusBar.GetInventoryIcon(Inventory(weapon), 0);
				// 	let spawnState = weapon.FindState("Spawn");
            	// 	let icon = spawnState.GetSpriteTexture(0);

				// 	let inventoryItem = new("ZDA_InventoryItem").Init(
				// 		weapon,
				// 		itemStats,
				// 		icon,
				// 		weapon.GetTag()
				// 	);
				// 	PlayerInventory.Items.Push(inventoryItem);
				// }
				

				// item recycling: + ammo & shards
				// if(ItemStatsController.isRecycling) {
				// 	ItemStatsController.isRecycling = false;
				// 	if(ItemStatsController.touchedItem) {
				// 		let playerInventory = ZDA_PlayerInventory(player.mo.FindInventory("ZDA_PlayerInventory"));
				// 		let res = ItemStatsController.touchedItem.CallTryPickup(player.mo);
				// 		let recycleItem = ItemStatsController.touchedItem;
				// 		player.bonuscount = Inventory.BONUSADD;
				// 		recycleItem.PlayPickupSound(player.mo);
				// 		recycleItem.Destroy();
				// 	}
				// }
				// if(ItemStatsController.touchedItem && ItemStatsController.touchedItem != item) {
				// 	ItemStatsController.touchTimer = 0;
				// }
				// ItemStatsController.touchedItem = item;
				// ItemStatsController.touchedItemPos = (item.pos.x, item.pos.y, item.pos.z);
				// ItemStatsController.touchTimer = 2;
				// return false;
			//}
		}
		return super.CanTouchItem(item);
	}

	// override Weapon PickWeapon(int slot, bool checkammo) {
	// 	player.mo.GiveInventory("Chaingun", 1);
	// 	let weapon = Weapon(player.mo.FindInventory("Chaingun"));
	// 	return weapon;
	// } 
}
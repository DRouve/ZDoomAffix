class ZDA_PlayerInventory : Inventory
{
    ZDA_ItemStatsController ItemStatsController;

    array <ZDA_InventorySlot> slots;
    array <ZDA_InventorySlot> weaponSlots;

    array <ZDA_InventoryItem> items;
    array <ZDA_InventoryItem> weapons;

    array <ZDA_ItemStats> currentWeaponItemStats;

    // player's item inventory size
    int inventorySlots;

    // equipped weapon slots
    int maxWeapons;

    Weapon oldWeapon;
    Weapon newWeapon;

    // boolean to indicate that first held weapon was remembered after game started
    bool isOldWeaponSet;

    property inventorySlots : inventorySlots;

    property maxWeapons : maxWeapons;

    Default {
        // number of inventory slots
        ZDA_PlayerInventory.inventorySlots 10;

        // number of equipped weapons slots
        ZDA_PlayerInventory.maxWeapons 4;
    }

    override void AttachToOwner (Actor other) 
    {
        Super.AttachToOwner(other);
        for(int i = 0; i < self.inventorySlots; i++) {
            let emptySlot = new('ZDA_InventorySlot');
            emptySlot.Init(i+1);
            self.slots.Push(emptySlot);
        }

        for(int i = 0; i < self.maxWeapons; i++) {
            let emptySlot = new('ZDA_InventorySlot');
            emptySlot.Init(i+1);
            self.weaponSlots.Push(emptySlot);
        }
    } 

    override void Tick()
    {
        Super.Tick();
        if(!ItemStatsController) {
			ItemStatsController = ZDA_ItemStatsController(owner.FindInventory("ZDA_ItemStatsController"));
		}
        if(!oldWeapon && !isOldWeaponSet) {
            if(owner.player.ReadyWeapon) {
                console.printf("----old weapon saved----");
                oldWeapon = owner.player.ReadyWeapon;
                isOldWeaponSet = true;
            }
        }

        if(owner.player.ReadyWeapon) {
            newWeapon = owner.player.ReadyWeapon;
        } else {
            // if no weapons left
            return;
        }

        if(!oldWeapon || newWeapon != oldWeapon) {
            console.printf("------------- weapon changed -------------");
            oldWeapon = newWeapon;
            ItemStatsController.currentStats = ItemStatsController.GetItemStats(Inventory(newWeapon));
            refreshEquippedWeaponStats();
        }
    }

    ZDA_InventorySlot findEmptySlot() {
        for(int i = 0; i < slots.Size(); i++) {
            if(slots[i] && !slots[i].heldItem) {
                return slots[i];
            }
        }
        return null;
    }

    ZDA_InventorySlot findEmptyWeaponSlot() {
        for(int i = 0; i < weaponSlots.Size(); i++) {
            if(slots[i] && !weaponSlots[i].heldItem) {
                return weaponSlots[i];
            }
        }
        return null;
    }

    bool isPlayerOwnThisStatsObject(ZDA_ItemStats itemStats) {
        for(int i = 0; i < weapons.Size(); i++) {
            if(weapons[i] && weapons[i].itemStats == itemStats) {
                return true;
            }
        }
        for(int i = 0; i < items.Size(); i++) {
            if(items[i] && items[i].itemStats == itemStats) {
                return true;
            }
        }
        return false;
    }

    void refreshEquippedWeaponStats()
    {
        currentWeaponItemStats.Clear();
        for(int i = 0; i < weaponSlots.Size(); i++) {
            // ignore empty slots
            if(!weaponSlots[i].heldItem) {
                continue;
            }

            if(
                // if currently weapon equipped and slot's weapon Class and weapon Class are same
                owner.player.ReadyWeapon && weaponSlots[i].heldItem.className == owner.player.ReadyWeapon.GetClassName()
                // or no weapon equipped, but pending to new weapon and this weapon's Class equals to slot's
                || !owner.player.ReadyWeapon && weaponSlots[i].heldItem.className == owner.player.PendingWeapon.GetClassName()
            ) {
                currentWeaponItemStats.Push(weaponSlots[i].heldItem.itemStats);
            }

            // if(owner.player.PendingWeapon != WP_NOCHANGE) {
            //     console.printf("PENDING");
            // }
        }
        for(int i = 0; i < currentWeaponItemStats.Size(); i++) {
            console.printf(currentWeaponItemStats[i].Rarity);
        }
    }
}
class ZDA_PlayerHandler : EventHandler 
{
    override void WorldLoaded(WorldEvent e)
    {
        array <Inventory> equippedWeapons;
        ZDA_ItemStats ItemStatsObject;

        for(int i = 0; i<Players.Size(); i++)
		{
            let playerMo = Players[i].mo;
			if(playerMo)
			{
                if(!playerMo.CountInv("ZDA_ItemStatsController")) 
                    playerMo.GiveInventory("ZDA_ItemStatsController", 1);
                if(!playerMo.CountInv("ZDA_WeaponSpeedScaling")) 
                    playerMo.GiveInventory("ZDA_WeaponSpeedScaling", 1);
                if(!playerMo.CountInv("ZDA_PlayerInventory")) 
                    playerMo.GiveInventory("ZDA_PlayerInventory", 1);

                
                equippedWeapons.Clear();
                let ItemStatsController = ZDA_ItemStatsController(playerMo.FindInventory("ZDA_ItemStatsController"));
                let PlayerInventory = ZDA_PlayerInventory(playerMo.FindInventory("ZDA_PlayerInventory"));
                if(ItemStatsController && !ItemStatsController.isStatsGenerated) {
                    let item = playerMo.inv; 
                    while (item != NULL) {
                        if (item is "Weapon") {
                            equippedWeapons.Push(item);
                        }
                        item = item.inv;
                    }
                    for(int j = 0; j < equippedWeapons.Size(); j++)
                    {
                        ItemStatsObject = ZDA_WorldHandler.GenerateItemStats(equippedWeapons[j]);

                        // add weapon to inventory menu
                        let weapon = Weapon(equippedWeapons[j]);
                        // console.printf("added weapon to owner: %s", weapon.GetClassName());
                        let spawnState = weapon.FindState("Spawn");
                        let icon = spawnState.GetSpriteTexture(0);

                        let inventoryItem = new("ZDA_InventoryItem").Init(
                            weapon.GetClassName(),
                            ItemStatsObject,
                            icon,
                            weapon.GetTag()
                        );
                        PlayerInventory.Weapons.Push(inventoryItem);

                        let emptyWeaponSlot = PlayerInventory.findEmptyWeaponSlot();
                        emptyWeaponSlot.heldItem = inventoryItem;
                    }
                    ItemStatsController.isStatsGenerated = true;
                }
            }            
        }
    }

    override bool InputProcess(InputEvent e)
    {
        if (e.type == InputEvent.Type_KeyDown)
		{
            if(checkSlotKeys(e) || checkPrevNextWeaponKeys(e)) {
                return true;
            }
        }
        return false;
    }

    ui bool checkPrevNextWeaponKeys(InputEvent e)
    {
        array <int> arr;
        array <int> allSlotKeys;
        string cmd;

        if(!players[consoleplayer].ReadyWeapon) {
            return false;
        }

        cmd = "weapnext";
        Bindings.GetAllKeysForCommand(arr, cmd);
        allSlotKeys.Append(arr);
        // доделать! проверка на нажатую кнопку
        for(let i = 0; i < allSlotKeys.Size(); i++) {
            if(e.KeyScan == allSlotKeys[i]) {
                // get current weapon's slot number
                bool isAssignedToSlot;
                int assignedSlot;
                int currentWeaponAssignedSlot;

                let playerInventory = ZDA_PlayerInventory(players[consoleplayer].mo.FindInventory("ZDA_PlayerInventory"));
                let itemStatsController = ZDA_ItemStatsController(players[consoleplayer].mo.FindInventory("ZDA_ItemStatsController"));

                [isAssignedToSlot, currentWeaponAssignedSlot] = players[consoleplayer].weapons.LocateWeapon(players[consoleplayer].ReadyWeapon.GetClassName());

                // count weapons in this slot
                int weaponsInSlot = 0;
                let item = players[consoleplayer].mo.inv; 
                while (item != NULL) {
                    if (item is "Weapon") {
                        [isAssignedToSlot, assignedSlot] = players[consoleplayer].weapons.LocateWeapon(item.GetClassName());
                        if(assignedSlot == currentWeaponAssignedSlot) {
                            weaponsInSlot++;
                        }
                        if(weaponsInSlot >= 2) {
                            break;
                        }
                    }
                    item = item.inv;
                }

                // skip if only one weapon of this class equipped
                if(playerInventory.currentWeaponItemStats.Size() <= 1) {
                    return false;
                }

                // find index of current ItemStats
                int currentIndex = 0;
                if (playerInventory.currentWeaponItemStats.Find(itemStatsController.currentStats) != playerInventory.currentWeaponItemStats.Size()) {
                    currentIndex = playerInventory.currentWeaponItemStats.Find(itemStatsController.currentStats);
                }

                // if current index is last index of array
                if(currentIndex == playerInventory.currentWeaponItemStats.Size()-1) {
                    // if only one weapon in this slot - restart from first index
                    // if(weaponsInSlot == 1) {
                    //     SendNetworkEvent("SwitchCurrentWeaponStats:" .. 0);
                    //     console.printf("---- restart ----");
                    //     return true;
                    // }
                    return false;
                }

                // change current ItemStats to the next in array
                SendNetworkEvent("SwitchCurrentWeaponStats:" .. currentIndex+1);
                return true;
            }
        }
        return false;
    }

    ui bool checkSlotKeys(InputEvent e)
    {
        array <int> arr;
        array <int> allSlotKeys;
        string cmd;

        for(int i = 0; i < 10; i++) {
            cmd = "slot " .. i;
            Bindings.GetAllKeysForCommand(arr, cmd);
            allSlotKeys.Append(arr);
        }

        for(let i = 0; i < allSlotKeys.Size(); i++) {
            // if one of the slot keys are pressed
            if(e.KeyScan == allSlotKeys[i]) {
                console.printf("key: %s", Bindings.GetBinding(allSlotKeys[i]));
                // get slot number from key name
                cmd = Bindings.GetBinding(allSlotKeys[i]);
                array <string> cmdSplit;
                cmd.split(cmdSplit, "slot ");
                // if slot number exists
                if (cmdSplit.Size() != 0 && cmdSplit[1]) {
                    //SendNetworkEvent("WeaponSlotKeyPressed:" .. cmdSplit[1]);
                    let slotNumber = cmdSplit[1];

                    // get current weapon's slot number
                    bool isAssignedToSlot;
                    int assignedSlot;

                    let playerInventory = ZDA_PlayerInventory(players[consoleplayer].mo.FindInventory("ZDA_PlayerInventory"));
                    let itemStatsController = ZDA_ItemStatsController(players[consoleplayer].mo.FindInventory("ZDA_ItemStatsController"));

                    [isAssignedToSlot, assignedSlot] = players[consoleplayer].weapons.LocateWeapon(players[consoleplayer].ReadyWeapon.GetClassName());
                    
                    // if pressed slot equals current weapon's slot
                    if(assignedSlot == slotNumber.ToInt()) {
                        // count weapons in this slot
                        int weaponsInSlot = 0;
                        let item = players[consoleplayer].mo.inv; 
                        while (item != NULL) {
                            if (item is "Weapon") {
                                [isAssignedToSlot, assignedSlot] = players[consoleplayer].weapons.LocateWeapon(item.GetClassName());
                                if(assignedSlot == slotNumber.ToInt()) {
                                    weaponsInSlot++;
                                }
                                if(weaponsInSlot >= 2) {
                                    break;
                                }
                            }
                            item = item.inv;
                        }

                        // skip if one weapon of this class equipped
                        if(playerInventory.currentWeaponItemStats.Size() <= 1) {
                            return false;
                        }

                        // find index of current ItemStats
                        int currentIndex = 0;
                        if (playerInventory.currentWeaponItemStats.Find(itemStatsController.currentStats) != playerInventory.currentWeaponItemStats.Size()) {
                            currentIndex = playerInventory.currentWeaponItemStats.Find(itemStatsController.currentStats);
                        }

                        // console.printf("current index: %d", currentIndex);

                        // console.printf("size: %d", playerInventory.currentWeaponItemStats.Size()-1);

                        // if current index is last index of array
                        if(currentIndex == playerInventory.currentWeaponItemStats.Size()-1) {
                            // if only one weapon in this slot - restart from first index
                            if(weaponsInSlot == 1) {
                                SendNetworkEvent("SwitchCurrentWeaponStats:" .. 0);
                                console.printf("---- restart ----");
                                return true;
                            }
                            return false;
                        }

                        // change current ItemStats to the next in array
                        SendNetworkEvent("SwitchCurrentWeaponStats:" .. currentIndex+1);
                        return true;

                        // for(int i = 0; i < playerInventory.currentWeaponItemStats.Size(); i++) {
                        //     if(i == playerInventory.currentWeaponItemStats.Size()-1) {
                        //         return false;
                        //     } else {
                        //         // playerInventory.currentWeaponItemStats.Delete(i);
                        //         // players[consoleplayer].PendingWeapon = players[consoleplayer].ReadyWeapon;
                        //         SendNetworkEvent("SwitchCurrentWeaponStats:" .. i);
                        //         console.printf("switch index: %d", i);
                        //         return true;
                        //     }
                        // }
                    }
                }
                //return true;
            }
        }
        return false;
    }



    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Player < 0 || !PlayerInGame[e.Player] || !(players[e.Player].mo))
            return;    

        if (e.Name ~== "refreshEquippedWeaponStats" && players[e.Player].mo.health > 0)
        {
            let playerInventory = ZDA_PlayerInventory(players[e.Player].mo.FindInventory("ZDA_PlayerInventory"));
            playerInventory.refreshEquippedWeaponStats();
        }

        if(e.Name.IndexOf("SwitchCurrentWeaponStats") >= 0) 
        {
            Array <String> index;
            e.Name.split(index, ":");
            if (index.Size() != 0) {
                let playerInventory = ZDA_PlayerInventory(players[e.Player].mo.FindInventory("ZDA_PlayerInventory"));
                let itemStatsController = ZDA_ItemStatsController(players[e.Player].mo.FindInventory("ZDA_ItemStatsController"));
                //playerInventory.currentWeaponItemStats.Delete(index[1].ToInt());
                players[e.Player].PendingWeapon = players[e.Player].ReadyWeapon;
                itemStatsController.currentStats = playerInventory.currentWeaponItemStats[index[1].ToInt()];

                // for(int i = 0; i < ItemStatsController.itemStats.Size(); i++) {
                //     if(ItemStatsController.itemStats[i].ItemObject == players[e.Player].PendingWeapon) {
                //         for(int j = 0; j < ItemStatsController.itemStats[i].Affixes.Size(); j++) {
                //             ItemStatsController.itemStats[i].Affixes[j].RevertEffect();
                //             ItemStatsController.itemStats[i].Affixes[j].ItemObject = NULL;
                //         } 
                //         ItemStatsController.itemStats[i].ItemObject = NULL;
                //     }
                // } 

                // playerInventory.weaponSlots[i].heldItem.itemStats.ItemObject = Inventory(players[e.Player].PendingWeapon);
                // for(int j = 0; j < playerInventory.weaponSlots[i].heldItem.itemStats.Affixes.Size(); j++) {
                //     playerInventory.weaponSlots[i].heldItem.itemStats.Affixes[j].ItemObject = Inventory(players[e.Player].PendingWeapon);
                // } 
            }
        }

        if(e.Name.IndexOf("WeaponSlotKeyPressed") >= 0) 
        {
            Array <String> slotNumber;
            bool isAssignedToSlot;
            int assignedSlot;

            let playerInventory = ZDA_PlayerInventory(players[e.Player].mo.FindInventory("ZDA_PlayerInventory"));
            let itemStatsController = ZDA_ItemStatsController(players[e.Player].mo.FindInventory("ZDA_ItemStatsController"));

            e.Name.split(slotNumber, ":");
            if (slotNumber.Size() != 0) {
                // get current weapon's slot
                [isAssignedToSlot, assignedSlot] = players[e.Player].weapons.LocateWeapon(players[e.Player].ReadyWeapon.GetClassName());
                // if pressed slot equals current weapon's slot
                if(assignedSlot == slotNumber[1].ToInt()) {
                    // skip if one weapon of this class equipped
                    if(playerInventory.currentWeaponItemStats.Size() <= 1) {
                        return;
                    }

                    for(int i = 0; i < playerInventory.currentWeaponItemStats.Size(); i++) {
                        if(i == playerInventory.currentWeaponItemStats.Size()-1) {
                            return;
                        } else {
                            playerInventory.currentWeaponItemStats.Delete(i);
                            players[e.Player].PendingWeapon = players[e.Player].ReadyWeapon;
                            return;
                        }
                    }

                    // check for other equipped weapons with this class name
                    for(int i = 0; i < playerInventory.weaponSlots.Size(); i++) {
                        // ignore empty slots
                        if(!playerInventory.weaponSlots[i].heldItem) {
                            continue;
                        }
                        // ignore current weapon
                        if(playerInventory.weaponSlots[i].heldItem.itemStats.ItemObject == Inventory(players[e.Player].ReadyWeapon)) {
                            continue;
                        }
                        // imitate weapon switching
                        if(playerInventory.weaponSlots[i].heldItem.className == players[e.Player].ReadyWeapon.GetClassName()) {
                            // for(int j = 0; j < playerInventory.weaponSlots[i].heldItem.itemStats.Affixes.Size(); j++) {
                            //     let affix = playerInventory.weaponSlots[i].heldItem.itemStats.Affixes[j];
                            //     console.printf(affix.Description);
                            // }
                            players[e.Player].PendingWeapon = players[e.Player].ReadyWeapon;
                            for(int j = 0; j < ItemStatsController.itemStats.Size(); j++) {
                                if(ItemStatsController.itemStats[j].ItemObject == players[e.Player].PendingWeapon) {
                                    for(int k = 0; k < ItemStatsController.itemStats[j].Affixes.Size(); k++) {
                                        ItemStatsController.itemStats[j].Affixes[k].ItemObject = NULL;
                                    } 
                                    ItemStatsController.itemStats[i].ItemObject = NULL;
                                }
                            } 

                            playerInventory.weaponSlots[i].heldItem.itemStats.ItemObject = Inventory(players[e.Player].PendingWeapon);
                            for(int j = 0; j < playerInventory.weaponSlots[i].heldItem.itemStats.Affixes.Size(); j++) {
                                playerInventory.weaponSlots[i].heldItem.itemStats.Affixes[j].ItemObject = Inventory(players[e.Player].PendingWeapon);
                            }   
                        }
                    }
                }
                
                
                //console.printf("slot number: %s", slotNumber[1]);
                // let weapon = Inventory(players[e.Player].mo.FindInventory(itemClassName[1]));
                // if (weapon)
                //     players[e.Player].mo.TakeInventory(itemClassName[1], 1);
            } 
        }

        if(e.Name.IndexOf("TakeInventory") >= 0) 
        {
            Array <String> itemClassName;
            e.Name.split(itemClassName, ":");
            if (itemClassName.Size() != 0) {
                let weapon = Inventory(players[e.Player].mo.FindInventory(itemClassName[1]));
                if (weapon)
                    players[e.Player].mo.TakeInventory(itemClassName[1], 1);
            } 
        }

        if(e.Name.IndexOf("AddInventory") >= 0) 
        {
            console.printf(e.Name);
            Array <String> itemClassName;
            e.Name.split(itemClassName, ":");
            if (itemClassName.Size() != 0) {
                let ItemStatsController = ZDA_ItemStatsController(players[e.Player].mo.FindInventory("ZDA_ItemStatsController"));
                let item = Inventory(Actor.Spawn(itemClassName[1]));
                let weap = Weapon(item);
                if (weap) {
                    weap.AmmoGive1 = weap.AmmoGive2 = 0;
                }
                bool res;
                Actor check;
                // setting to true to avoid adding item to first empty slot
                ItemStatsController.weaponAdded = true;
                [res, check] = item.CallTryPickup(players[e.Player].mo);
                if (!res)
                {
                    item.Destroy();
                    item = NULL;
                }

                if(itemClassName[2]) {
                    if(ItemStatsController) {
                        let key = itemClassName[2].ToInt();
                        ItemStatsController.itemStats[key].ItemObject = item;
                        for(int i = 0; i < ItemStatsController.itemStats[key].Affixes.Size(); i++) {
                            ItemStatsController.itemStats[key].Affixes[i].ItemObject = item;
                        }   
                    }
                }
            } 
        }

        if (e.Name ~== "DropWeapon" && players[e.Player].mo.health > 0)
        {
            let weapon = Weapon(players[e.Player].ReadyWeapon);
            if (weapon)
                players[e.Player].mo.DropInventory(weapon);
            let ItemStatsController = ZDA_ItemStatsController(players[e.Player].mo.FindInventory("ZDA_ItemStatsController"));
            if(ItemStatsController && ItemStatsController.touchedItem)
                ItemStatsController.touchedItem.Touch(players[e.Player].mo);
        }

        if (e.Name ~== "CompareWeapons" && players[e.Player].mo.health > 0)
        {
            let ItemStatsController = ZDA_ItemStatsController(players[e.Player].mo.FindInventory("ZDA_ItemStatsController"));
            if (ItemStatsController && ItemStatsController.touchedItem) {
                ItemStatsController.isComparingItems = !ItemStatsController.isComparingItems;
            }
        }

        if (e.Name ~== "Recycle" && players[e.Player].mo.health > 0)
        {
            let ItemStatsController = ZDA_ItemStatsController(players[e.Player].mo.FindInventory("ZDA_ItemStatsController"));
            if (ItemStatsController && ItemStatsController.touchedItem) {
                ItemStatsController.isRecycling = true;
            }
        }

        if (e.Name ~== "ShowEquippedInfo" && players[e.Player].mo.health > 0)
        {
            let weapon = Weapon(players[e.Player].ReadyWeapon);
            let ItemStatsController = ZDA_ItemStatsController(players[e.Player].mo.FindInventory("ZDA_ItemStatsController"));
            if (weapon && ItemStatsController) {
                for(int i = 0; i < ItemStatsController.ItemStats.Size(); i++) {
                    if(ItemStatsController.ItemStats[i].ItemObject == weapon) {
                        ItemStatsController.isShowEquippedInfo = !ItemStatsController.isShowEquippedInfo;
                        break;
                    }
                }
                for(int i = 0; i < ItemStatsController.ItemStats.Size(); i++) {
                    for(int j = 0; j < ItemStatsController.ItemStats[i].Affixes.Size(); j++) {
                        console.printf("network: %s", ZDA_Affix(ItemStatsController.ItemStats[i].Affixes[j]).AffixCategoryShortcode);
                    }
                }
            }
        }

        if (e.Name ~== "ReplaceWeapon" && players[e.Player].mo.health > 0)
        {
            let ItemStatsController = ZDA_ItemStatsController(players[e.Player].mo.FindInventory("ZDA_ItemStatsController"));
            if(ItemStatsController && ItemStatsController.touchedItem) {
                let weapon = Weapon(players[e.Player].mo.FindInventory(ItemStatsController.touchedItem.GetClassName()));
                if (weapon) {
                    players[e.Player].mo.DropInventory(weapon);
                    ItemStatsController.touchedItem.Touch(players[e.Player].mo);
                }
            }
        }
    }
}
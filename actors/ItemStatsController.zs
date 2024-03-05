class ZDA_ItemStatsController : Inventory
{
    array <ZDA_ItemStats> itemStats;

    ZDA_PlayerInventory PlayerInventory;

    // damage formula variables
    int baseFlatDamageBeforeMultiplier;
    double baseDamageMultiplier;
    int baseFlatDamageAfterMultiplier;

    int flatDamageBeforeMultiplier;
    double damageMultiplier;
    int flatDamageAfterMultiplier;

    // weapon speed
    double weaponSpeed;

    // damage type override
    name newDamageType;

    // HP regen
    int regenPower;

    // chance for double damage (0% - 100%)
    double doubleDamageChance;

    // incoming damage reduction
    int damageReduction;

    // reflect damage to the attacker
    int reflectDamage;

    bool perfectAccuracy;

    Inventory touchedItem;
    ZDA_ItemStats touchedItemStats;
    // is player currently touching duplicate item?
    int touchTimer;

    // touched item's position
    vector3 touchedItemPos;

    // compares weapon on the ground with same class weapon in inventory
    bool isComparingItems;

    // shows stats of ReadyWeapon on HUD
    bool isShowEquippedInfo;

    // is player currently trying to recycle item from ground?
    bool isRecycling;

    // does player got his initial equipment stats generated?
    bool isStatsGenerated;

    // ticks count of cooldown before next recycle
    int recycleTimer;

    // weapon was added through AddInventory recently
    bool weaponAdded;

    // currently active ItemStats instance (and its affixes)
    ZDA_ItemStats currentStats;

    property baseFlatDamageBeforeMultiplier : baseFlatDamageBeforeMultiplier;
    property baseDamageMultiplier           : baseDamageMultiplier;
    property baseFlatDamageAfterMultiplier  : baseFlatDamageAfterMultiplier;
    property flatDamageBeforeMultiplier     : flatDamageBeforeMultiplier;
    property damageMultiplier               : damageMultiplier;
    property flatDamageAfterMultiplier      : flatDamageAfterMultiplier;

    property weaponSpeed : weaponSpeed;

    Default {
        Inventory.Amount 1;
        Inventory.MaxAmount 1;

        ZDA_ItemStatsController.baseFlatDamageBeforeMultiplier 0;
        ZDA_ItemStatsController.baseDamageMultiplier 1;
        ZDA_ItemStatsController.baseFlatDamageAfterMultiplier 0;

        ZDA_ItemStatsController.flatDamageBeforeMultiplier 0;
        ZDA_ItemStatsController.damageMultiplier 1;
        ZDA_ItemStatsController.flatDamageAfterMultiplier 0;

        // weapon animations speed; 1 = default; 2 = 2x faster
        ZDA_ItemStatsController.weaponSpeed 1;
    }

    override bool HandlePickup(Inventory item) {
        
        if(item is 'Weapon') {
            let duplicateWeapon = Inventory(owner.FindInventory(item.GetClassName()));
            // force new weapons into backpack if max weapon count reached
            if(duplicateWeapon || !duplicateWeapon && countEquippedWeapons(owner.player.mo) >= PlayerInventory.maxWeapons) {
                // make control item pick up item - player won't receive weapon, but will receive ammo
                item.CallTryPickup(self);
                item.bPickupgood = true;
                return true;
            }

            // add to equipped weapons instead
            let weapon = Weapon(item);
            console.printf("added weapon to owner: %s", weapon.GetClassName());
            let spawnState = weapon.FindState("Spawn");
            let icon = spawnState.GetSpriteTexture(0);

            ZDA_ItemStats ItemStatsObject = null;
            for(int i = 0; i < self.ItemStats.Size(); i++) {
                if(self.ItemStats[i].ItemObject == item) {
                    ItemStatsObject = self.ItemStats[i];
                    break;
                }
            }

            let inventoryItem = new("ZDA_InventoryItem").Init(
                weapon.GetClassName(),
                ItemStatsObject,
                icon,
                weapon.GetTag()
            );
            PlayerInventory.Weapons.Push(inventoryItem);  

            // bool attachedToSlot = false;
            // for(int i = 0; i < PlayerInventory.weaponSlots.Size(); i++) {
            //     if(PlayerInventory.weaponSlots[i].heldItem == inventoryItem) {
            //         console.printf("##############LAL#############");
            //         attachedToSlot = true;
            //         break;
            //     }
            // }

            if(!weaponAdded) {
                let emptyWeaponSlot = PlayerInventory.findEmptyWeaponSlot();
                emptyWeaponSlot.heldItem = inventoryItem; // error here when picking with full weapon slots?
                console.printf("----------- HAHA -----------");
            } else {
                weaponAdded = false;
            }
        }
        return super.HandlePickup(item);
    }

    override void Tick() {
        Super.Tick();

        if(!PlayerInventory) {
			PlayerInventory = ZDA_PlayerInventory(owner.FindInventory("ZDA_PlayerInventory"));
		}

        if(regenPower && GameTic % regenPower == 0) {
            owner.GiveBody(1);
        }
        if(perfectAccuracy) {
            owner.player.refire = 0;
        }
        // if(touchedItemPos.x) {
        //     console.printf('playerX: %d', owner.player.mo.pos.x);
        //     console.printf('playerY: %d', owner.player.mo.pos.y);
        //     console.printf('playerZ: %d', owner.player.mo.pos.Z);
        //     console.printf('itemX: %d', touchedItemPos.x);
        //     console.printf('itemY: %d', touchedItemPos.y);
        //     console.printf('itemZ: %d', touchedItemPos.z);
        //     console.printf('absX: %d', abs(touchedItemPos.x - owner.player.mo.pos.x));
        //     console.printf('absY: %d', abs(touchedItemPos.y - owner.player.mo.pos.y));
        //     console.printf('absZ: %d', abs(touchedItemPos.z - owner.player.mo.pos.z));
        //     console.printf('timer: %d', touchTimer);
        //     if(touchedItem) {
        //         console.printf('touchedItem: %s', touchedItem.GetClassName());
        //     }
        //     if(touchedItemStats) {
        //         console.printf('touchedItemStats: %s', touchedItemStats.GetClassName());
        //     }   
        // }

        // if(recycleTimer) {
        //     recycleTimer--;
        // }

        // if(touchTimer && touchedItem && touchedItemStats
        // && (touchedItem.owner || (abs(touchedItemPos.x - owner.player.mo.pos.x) >= 45
        // || abs(touchedItemPos.y - owner.player.mo.pos.y) >= 45
        // || abs(touchedItemPos.z - owner.player.mo.pos.z) >= 45))) {
        //     touchTimer--;
        //     touchedItem = null;
        //     touchedItemStats = null;
        //     isComparingItems = false;
        // }

        if(!owner.player.ReadyWeapon) {
            currentStats = null;
            // if no weapons left - no affixes would apply, so quitting
            return;
        }

        if(!currentStats) {
            if(owner.player.ReadyWeapon) {
                currentStats = GetItemStats(Inventory(owner.player.ReadyWeapon));
            } else {
                currentStats = null;
            }
        }

        for(int i = 0; i < itemStats.Size(); i++) {
            if(
                // if stats exist
                itemStats[i] &&
                // and stats doesn't have linked controller
                !itemStats[i].ItemStatsController
                // OR has linked controller, but it's owner isn't same as current controller's owner AND current owner has InventoryItem with this ItemStats
                || itemStats[i].ItemStatsController && itemStats[i].ItemStatsController.owner != owner && playerInventory.isPlayerOwnThisStatsObject(itemStats[i])
            ) {
                itemStats[i].ItemStatsController = ZDA_ItemStatsController(owner.FindInventory("ZDA_ItemStatsController"));
            }
            if(itemStats[i] && itemStats[i].Affixes.Size() > 0) {
                for(int j = 0; j < itemStats[i].Affixes.Size(); j++) {
                    if(itemStats[i].Affixes[j].isGlobal) {
                        itemStats[i].Affixes[j].ApplyEffect();
                    } else {
                        ApplyConditionalEffects(itemStats[i].Affixes[j]);
                    }
                }
            }


            // if(itemStats[i] && itemStats[i].ItemObject) {
            //     if(itemStats[i].ItemObject is "Weapon") {
                    // if(itemStats[i].ItemObject.owner && !itemStats[i].ItemStatsController) {
                    //     itemStats[i].ItemStatsController = ZDA_ItemStatsController(itemStats[i].ItemObject.owner.FindInventory("ZDA_ItemStatsController"));
                    // }

                    // if(touchedItem && !touchedItemStats && touchedItem == itemStats[i].ItemObject) {
                    //     touchedItemStats = itemStats[i];
                    // }
                    
                    //let weapon = Weapon(itemStats[i].ItemObject);
                    //let weaponDefaults = GetDefaultByType((class<Weapon>)(itemStats[i].ItemObject.GetClassName()));
                    // if(itemStats[i].Affixes.Size() > 0) {
                    //     for(int j = 0; j < itemStats[i].Affixes.Size(); j++) {
                    //         if(itemStats[i].Affixes[j].isGlobal) {
                    //             itemStats[i].Affixes[j].ApplyEffect();
                    //         } else {
                    //             ApplyConditionalEffects(itemStats[i].Affixes[j]);
                    //         }
                    //     }
                    // }
                    // if(itemStats.Size() && (GameTic % 35) == 0) {
                    //     // console.printf("---");
                    //     // console.printf(itemStats[i].ItemObject.GetClassName());
                    //     // if(weapon.ammotype1) {
                    //     //     console.printf(weapon.ammotype1.GetClassName());
                    //     // } 
                    //     // if(itemStats[i].ItemObject.owner && itemStats[i].ItemObject.owner.GetClassName() == "ZDA_DoomPlayer") {
                    //     //     console.printf(itemStats[i].ItemObject.owner.GetClassName());
                    //     // }  

                    //     // console.printf(itemStats[i].Rarity);
                    //     // console.printf("%d", itemStats[i].PrefixesCount);
                    //     // console.printf("%d", itemStats[i].SuffixesCount);

                    //     // if(itemStats[i].Affixes.Size() > 0) {
                    //     //     for(int j = 0; j < itemStats[i].Affixes.Size(); j++) {
                    //     //         console.printf(itemStats[i].Affixes[j].AffixCategory .. itemStats[i].Affixes[j].GetClassName());
                    //     //     }
                    //     // }
                    //     // if(reflectDamage) {
                    //     //     console.printf("reflect damage: %d", reflectDamage);
                    //     // }
                    //     //console.printf(owner.player.ReadyWeapon.GetClassName());
                    //     //class<Ammo> a = itemStats[i].ItemObject.ammotype1.GetClass();
                    //     //console.printf(a);
                    // }   
               // }
                
            //} else if(itemStats[i]) {
            //    itemStats[i].Destroy();
            // }
        }
    }

    void ApplyConditionalEffects(ZDA_Affix affix) {
        //console.printf(affix.ItemObject.GetClassName());
        //console.printf(owner.player.ReadyWeapon.GetClassName());
        if(affix.ItemStatsObject.ItemClassName == owner.player.ReadyWeapon.GetClassName() && affix.ItemStatsObject == currentStats)
        {
            let weap = owner.player.ReadyWeapon;
            let psp = owner.player.FindPSprite(PSP_WEAPON);

            if(owner.player.mo.health > 0
            && !Actor.InStateSequence(psp.CurState, weap.ResolveState('Select'))
            && !Actor.InStateSequence(psp.CurState, weap.ResolveState('Deselect')))
            {
                affix.ApplyEffect();
                //console.printf("applying");
                return;
            }
        }
        affix.RevertEffect();
    }

    override void ModifyDamage (int damage, Name damageType, out int newdamage, bool passive, Actor inflictor, Actor source, int flags) 
	{
        if (!passive && damage > 0) {
            let calculatedDamage = CalculateTotalDamage(damage, source);
            if(doubleDamageChance) {
                let doubleDamageCheck = random(0, 100);
                if(doubleDamageChance >= doubleDamageCheck) {
                    calculatedDamage *= 2;
                    console.printf("----!!!DOUBLE DAMAGE!!!----");
                }
            }
            if(newDamageType && newDamageType != '') {
                newdamage = -1;
                source.DamageMobj(inflictor, inflictor, calculatedDamage, 'Ice');
            } else {
                newdamage = calculatedDamage;
            }
            
            console.printf(damageType);
            console.printf("health: %d", source.health);
            //if(source.Health - newdamage < 0) {
                //source.A_FreezeDeathChunks();
                //source.Destroy();
            //}
		}  

        if (passive && damage > 0) {
            // if(inflictor.player || inflictor.bMissile && inflictor.target.player) {
            //     return;
            // }
            // if(reflectDamage) {
            //     if(inflictor.bMissile && inflictor.target) {
            //         inflictor.target.DamageMobj(source, source, reflectDamage, 'None');
            //     } else {
            //         inflictor.DamageMobj(source, source, reflectDamage, 'None');
            //     }
            // }
            //newdamage = 0;
		}   
	}

    override void AbsorbDamage (int damage, Name damageType, out int newdamage, Actor inflictor, Actor source, int flags)
    {
        if(damageReduction) {
            if(damage <= damageReduction) {
                newdamage = 1;
            } else {
                newdamage = damage - damageReduction;
            }
        } else {
            newdamage = damage;
        }
    }

    int CalculateTotalDamage(int currentDamage, Actor target)
    {
        console.printf("current damage: %d", currentDamage);

        int newDamage;
        newDamage = AddBaseFlatDamageBeforeMultiplier(currentDamage);
        console.printf("base flat before: %d", newDamage);
        newDamage = AddBaseDamageMultiplier(newDamage);
        console.printf("base mult: %d", newDamage);
        newDamage = AddBaseFlatDamageAfterMultiplier(newDamage);
        console.printf("base flat after: %d", newDamage);

        newDamage = AddFlatDamageBeforeMultiplier(newDamage);
        console.printf("flat before: %d", newDamage);
        newDamage = AddDamageMultiplier(newDamage);
        console.printf("mult: %d", newDamage);
        newDamage = AddFlatDamageAfterMultiplier(newDamage);
        console.printf("flat after: %d", newDamage);
        
        console.printf("final damage affix: %d", newDamage);
        return newDamage;
    }

    int AddBaseFlatDamageBeforeMultiplier(int currentDamage)
    {
        return currentDamage + baseFlatDamageBeforeMultiplier;
    }

    int AddBaseDamageMultiplier(int currentDamage)
    {
        return currentDamage * (baseDamageMultiplier * 100) / 100;
    }

    int AddBaseFlatDamageAfterMultiplier(int currentDamage)
    {
        return currentDamage + baseFlatDamageAfterMultiplier;
    }

    int AddFlatDamageBeforeMultiplier(int currentDamage)
    {
        return currentDamage + flatDamageBeforeMultiplier;
    }

    int AddDamageMultiplier(int currentDamage)
    {
        return currentDamage * (damageMultiplier * 100) / 100;
    }

    int AddFlatDamageAfterMultiplier(int currentDamage)
    {
        return currentDamage + flatDamageAfterMultiplier;
    }

    ZDA_ItemStats GetItemStats(Inventory item) {
        for(int i = 0; i < ItemStats.Size(); i++) {
            if(ItemStats[i].ItemObject == item) {
                return ItemStats[i];
            }
        }
        return null;
    }

    static int countEquippedWeapons(PlayerPawn playerMo) {
		int i = 0;
		let item = playerMo.inv; 
		while (item != NULL) {
			if (item is "Weapon") {
				i++;
			}
			item = item.inv;
		}
		return i;
	}

    ui int GetItemStatsId(ZDA_ItemStats itemStatsInstance) {
        for(int i = 0; i < ItemStats.Size(); i++) {
            if(ItemStats[i] == itemStatsInstance) {
                return i;
            }
        }
        return 0;
    }
}
/*
 * DynamicElementCreation.ZS:
 * This example shows how to create elements dynamically by displaying a list of
 * the player's weapons. Dynamically-created elements can be used for things like
 * lists, for example.
*/

// The menu's command handler.
// This is needed so we can make our menu interactable.
class ZDA_ZF_InventoryMenuHandler : ZDA_ZF_Handler
{
    // The menu this command handler belongs to.
    // We need this to be able to do anything with our menu.
    ZDA_ZF_InventoryMenu menu;
    ZDA_PlayerHandler playerHandler; 

    override void buttonClickCommand (ZDA_ZF_Button caller, Name command)
    {
        if(!menu) {
            return;
        }

        string commandString = command;

        if(commandString.IndexOf("UseItem") >= 0) 
        {
            console.printf("item is used");
        }

        if(commandString.IndexOf("InventorySlotAction") >= 0) 
        {
            let slot = ZDA_ZF_InventorySlot(caller);
            //console.printf("id: %d", slot.id);
            
            // picking up
            if(slot && slot.itemImage && !menu.pickedItem && !menu.pickedItemImage) {
                console.printf("picking up");

                // get item's slot info
                menu.SelectedItemSlot = slot;

                pickItem(slot.heldItem);
                clearSlot(slot);
            } 

            // replacing item
            else if(slot && slot.itemImage && menu.pickedItemImage && slot.itemImage != menu.pickedItemImage) {
                console.printf("replacing item");
                let originalIconSize = menu.pickedItemImage.GetSize();
                let newIconSize = slot.itemImage.GetSize();

                // let originalItem = ZDA_InventoryItem(new("ZDA_InventoryItem")).Init(
                //     menu.SelectedItemSlot.heldItem.className,
                //     menu.SelectedItemSlot.heldItem.itemStats,
                //     menu.SelectedItemSlot.heldItem.icon,
                //     menu.SelectedItemSlot.heldItem.name,
                // );

                let newItem = recreateItem(slot.heldItem);
                let newImage = recreateItemImage(newItem);

                clearSlot(slot);

                moveItem(slot);

                //slot.itemImage.setImage(TexMan.GetName(menu.pickedItem.icon));
                //slot.itemImage.setBox(slot.itemImage.GetPos(), originalIconSize);

                pickItem(newItem);
                
                menu.pickedItemImage.setImage(TexMan.GetName(newItem.icon));
                menu.pickedItemImage.setBox(menu.pickedItemImage.GetPos(), newIconSize);

                //menu.pickedItem = newItem;
                //slot.heldItem = originalItem;

                ZDA_ZF_InventorySlot.centerItemIcon(slot.itemImage, slot);
            } 

            // moved to empty
            else if(slot && !slot.itemImage && menu.pickedItem && menu.pickedItemImage) {                
                console.printf("moved to empty");
                console.printf("slot: %d", slot.playerInventorySlot.id);

                moveItem(slot);
            }

            // empty slot clicked
            else if(slot && !slot.itemImage && !menu.pickedItemImage) {
                console.printf("empty slot clicked");
            }

            // returned to same slot - deprecated, should never be triggered
            else {
                console.printf("returned to same slot");
                menu.pickedItemImage = null;
                ZDA_ZF_InventorySlot.centerItemIcon(slot.itemImage, slot);
            }

            menu.refreshSlotTextures();
        }

        if(commandString.IndexOf("zzz") >= 0) 
        {
            let slot = ZDA_ZF_InventorySlot(caller);
            if(slot.heldItem) {
                //console.printf(slot.heldItem.weaponObj.GetClassName());
            } else {
                console.printf("empty");   
            }
        }
    }

    override void elementHoverChanged(ZDA_ZF_Element caller, Name command, bool unhovered) {
        if (command == "InventorySlotAction") {
            if (!unhovered) {
                let button = ZDA_ZF_InventorySlot(caller);
                if(button.heldItem && button.heldItem.className) {
                    menu.HoveredItemSlot = button;
                } else {
                    menu.HoveredItemSlot = null;
                }
			}
		}
    }

    ZDA_InventoryItem recreateItem(ZDA_InventoryItem item) {
        // recreate item and store it
        return ZDA_InventoryItem(new("ZDA_InventoryItem")).Init(
            item.className,
            item.itemStats,
            item.icon,
            item.name
        );
    }

    ZDA_ZF_Image recreateItemImage(ZDA_InventoryItem item) {
        // recreate image and store it
        vector2 iconSize;
        [iconSize.x, iconSize.y] = TexMan.GetSize(item.icon);

        // set item's image to mouse cursor
        let image = ZDA_ZF_Image.Create
        (
            (0, 0),
            iconSize*2,
            TexMan.GetName(item.icon),
            ZDA_ZF_Image.AlignType_TopLeft,
            (2, 2)
        );

        // make image at top of everything
        image.setDontBlockMouse(true);
        image.pack(menu.mainFrame);

        return image;
    }

    void pickItem(ZDA_InventoryItem item) {
        menu.pickedItem = recreateItem(item);
        menu.pickedItemImage = recreateItemImage(menu.pickedItem);
        playerHandler.SendNetworkEvent("refreshEquippedWeaponStats");
    }

    void moveItem(ZDA_ZF_InventorySlot slot) {
        // add weapon from player inventory if moving item to weapon slot
        if(slot.isWeaponSlot) {
            let itemStatsId = menu.itemStatsController.GetItemStatsId(menu.pickedItem.itemStats);
            playerHandler.SendNetworkEvent("AddInventory:" .. menu.pickedItem.className .. ":" .. itemStatsId);           
        }

        // set new slot's image to picked item's image
        slot.itemImage = menu.pickedItemImage;

        // link picked up item to new slot
        menu.pickedItem.inventorySlot = slot.playerInventorySlot;

        // link new inventory slot to picked up item
        slot.playerInventorySlot.heldItem = menu.pickedItem;

        // link new UI slot to picked up item
        slot.heldItem = menu.pickedItem;

        // clear original slot's image pointer
        menu.pickedItemImage = null;

        // clear original slot's pointer
        menu.SelectedItemSlot = null;

        // clear item pointer    
        menu.pickedItem = null;
        
        ZDA_ZF_InventorySlot.centerItemIcon(slot.itemImage, slot);

        playerHandler.SendNetworkEvent("refreshEquippedWeaponStats");
    }

    void clearSlot(ZDA_ZF_InventorySlot slot) {
        // remove weapon from player inventory if picking up item from weapon slot
        if(slot.isWeaponSlot) {
            let multipleWeaponCopies = false;
            // count same weapon copies
            for(int i = 0; i < menu.playerInventory.weaponSlots.Size(); i++) {
                if(slot.heldItem == menu.playerInventory.weaponSlots[i].heldItem || !menu.playerInventory.weaponSlots[i].heldItem) {
                    continue;
                }
                if(slot.heldItem.className == menu.playerInventory.weaponSlots[i].heldItem.className) {
                    multipleWeaponCopies = true;
                    break;
                }
            }
            console.printf("sameWeaponsCount: %d", multipleWeaponCopies);
            // remove from inventory if this is the only weapon of this class
            if(!multipleWeaponCopies) {
                playerHandler.SendNetworkEvent("TakeInventory:" .. slot.heldItem.className);
            }
        }
        
        // let playerInventory = ZDA_PlayerInventory(players[consoleplayer].mo.FindInventory("ZDA_PlayerInventory"));
        // for(int i=0; i<playerInventory.weapons.Size(); i++)
        // {
        //     if(playerInventory.weapons[i] == slot.playerInventorySlot.heldItem) {
        //         playerHandler.SendNetworkEvent("TakeInventory:" .. slot.heldItem.className);
        //     }
        // }
        
        // remove item from inventory slot
        slot.playerInventorySlot.heldItem = null;

        // remove item from UI slot
        slot.heldItem = null;

        // hide image and remove it
        slot.itemImage.hide();
        slot.itemImage = null;
    }
}

class ZDA_ZF_InventoryMenu : ZDA_ZF_GenericMenu
{
    // A font to use for text.
    Font smallFont;
    Font bigFont;
    Font optionsFont;

    vector2 baseRes;

    ZDA_ZF_InventoryMenuHandler handler;

    ZDA_ZF_Image pickedItemImage;
    ZDA_ZF_InventorySlot SelectedItemSlot;
    ZDA_ZF_InventorySlot HoveredItemSlot;

    ZDA_InventoryItem oldHeldItem;

    ZDA_ZF_Label HoveredItemName;
    array <ZDA_ZF_Label> HoveredItemAffixLabels;

    ZDA_InventoryItem pickedItem;

    ZDA_ZF_BoxTextures inventorySlotIdle;
    ZDA_ZF_BoxTextures inventorySlotWithItem;
    ZDA_ZF_BoxTextures inventorySlotHover;

    array <ZDA_ZF_InventorySlot> inventorySlots;

    array <Weapon> equippedWeapons;

    ZDA_ZF_Frame inventoryFrame;
    ZDA_ZF_Frame itemDescriptionFrame;
    ZDA_ZF_BoxImage itemDescriptionBox;

    ZDA_ItemStatsController itemStatsController;
    ZDA_PlayerInventory playerInventory;

    override void Init (Menu parent)
    {
        // Call GenericMenu's 'Init' function to do some required initialization.
        Super.Init (parent);
        // Set our base resolution to 320x200.
        baseRes = (1920, 1080);
        SetBaseResolution (baseRes);
        menuactive = Menu.OnNoPause; 

        // Get the smallfont.
        smallFont = Font.GetFont ("SmallFont");
        bigFont = Font.GetFont ("BigFont");
        optionsFont = OptionFont ();

        // Create an instance of the handler.
        handler = new ('ZDA_ZF_InventoryMenuHandler');
        handler.menu = self;

        itemStatsController = ZDA_ItemStatsController(players[consoleplayer].mo.FindInventory("ZDA_ItemStatsController"));

        playerInventory = ZDA_PlayerInventory(players[consoleplayer].mo.FindInventory("ZDA_PlayerInventory"));

        inventorySlotIdle = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/bbs/MISSBOXB3.png", true);
        inventorySlotWithItem = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/bbs/MISSBOXB3_darkblue.png", true);
        inventorySlotHover = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/bbs/MISSBOXB3_darkgreen.png", true);

        inventoryFrame = ZDA_ZF_Frame.create(
            (0, 0), 
            baseRes
        );
        inventoryFrame.pack(mainFrame);
        //inventoryFrame.show();

        createInventory();

        createItemDescriptionBox();

        refreshSlotTextures();
    }

    void createItemDescriptionBox() {
        itemDescriptionFrame = ZDA_ZF_Frame.create(
            (0,0),
            baseRes
        );
        itemDescriptionFrame.hide();
        itemDescriptionFrame.pack(inventoryFrame);
        itemDescriptionFrame.setDontBlockMouse(true);

        let itemDescriptionBoxTexture = ZDA_ZF_BoxTextures.CreateTexturePixels
        (
            // The texture itself.
            "graphics/ZFormsExamples/BoxTexture.png",
            // The top-left corner of the middle of the box.
            (32, 32),
            // The bottom-right corner of the middle of the box.
            (64, 64),
            // Whether to scale (true) or tile (false) the sides.
            false,
            // Whether to scale (true) or tile (false) the middle.
            false
        );

        itemDescriptionBox = ZDA_ZF_BoxImage.Create
        (
            // Position
            
            //((baseRes.X - boxSize.X) / testDouble, (baseRes.Y - boxSize.Y) / testDouble),
            (0, 0),
            // Size
            (300, 300),
            // Texture
            itemDescriptionBoxTexture,
            // Scale
            (0.25, 0.25)
        );

        itemDescriptionBox.pack(itemDescriptionFrame); // index: 0

        // let itemDescription = ZDA_ZF_Label.Create(
        //     // Position.
        //     (100, 200),
        //     // Size.
        //     (100, 100),
        //     // The label's text.
        //     text: '',
        //     // The font to use.
        //     fnt: smallFont,
        //     // Whether to automatically wrap the text or not.
        //     wrap: true,
        //     // Whether to automatically resize the element based on the text width.
        //     autoSize: true,
        //     // The text's colour.
        //     textColor: Font.CR_WHITE
        // );
        // itemDescription.pack(itemDescriptionFrame);

        // HoveredItemAffixLabels = itemDescription;

        let itemName = ZDA_ZF_Label.Create(
            // Position.
            (100, 50),
            // Size.
            (itemDescriptionBox.GetWidth() / 2, 100),
            // The label's text.
            //text: HoveredItemSlot.heldItem.className,
            text: '',
            // The font to use.
            fnt: bigFont,
            // Whether to automatically wrap the text or not.
            wrap: true,
            // Whether to automatically resize the element based on the text width.
            autoSize: true,
            // The text's colour.
            textColor: Font.CR_WHITE
        );
        itemName.pack(itemDescriptionFrame);

        HoveredItemName = itemName;


    }

    void createInventory() {
        array <int> blocksCount;
        array <int> rowsCount;

        //int equippedWeaponsCount = 0;
		// let item = players[consoleplayer].mo.inv; 
		// while (item != NULL) {
        //     // if(item.GetClassName() == "Fist") {
        //     //     item = item.inv;
        //     //     continue;
        //     // }
		// 	if (item is "Weapon") {
        //         equippedWeapons.Push(Weapon(item));
		// 		//equippedWeaponsCount++;
		// 	}
		// 	item = item.inv;
		// }

        // create active weapon slots
        for(int i=0; i<playerInventory.weaponSlots.Size(); i++)
        {
            ZDA_InventoryItem inventoryItem = null;
            //if(i < equippedWeapons.Size()) {
            if(playerInventory.weaponSlots[i].heldItem) {
                //console.printf("myprint: %s", playerInventory.weapons[i].className);
                inventoryItem = playerInventory.weaponSlots[i].heldItem;   
            }
            CreateInventorySlot(blocksCount, rowsCount, playerInventory.weaponSlots[i], inventoryItem, true);
        }

        // offset vertically 2 rows
        rowsCount.Push(1);
        rowsCount.Push(1);

        // reset horizontal offset
        blocksCount.Clear();

        // create backpack inventory
        for(int i=0; i<playerInventory.slots.Size(); i++)
        {
            ZDA_InventoryItem inventoryItem = null;
            console.printf("i = %d", i);
            if(playerInventory.slots[i].heldItem) {
                //console.printf(playerInventory.items[i].weaponObj.GetClassName());
                inventoryItem = playerInventory.slots[i].heldItem;
                console.printf("item = %s", playerInventory.slots[i].heldItem.GetClassName());

            }
            CreateInventorySlot(blocksCount, rowsCount, playerInventory.slots[i], inventoryItem);
        }

        // for(int i=0; i<playerInventory.inventorySlots; i++)
        // {
        //     ZDA_InventoryItem inventoryItem = null;
        //     if(i < playerInventory.items.Size()) {
        //         //console.printf(playerInventory.items[i].weaponObj.GetClassName());
        //         inventoryItem = playerInventory.items[i];   
        //     }
        //     CreateInventorySlot(blocksCount, rowsCount, inventoryItem);
        // }

        
    }

    void CreateInventorySlot(out array <int> blocksCount, out array <int> rowsCount, ZDA_InventorySlot playerInventorySlot, ZDA_InventoryItem inventoryItem, bool isWeaponSlot = false) 
    {
        
        // let boxTexture = ZDA_ZF_BoxTextures.CreateTexturePixels
        // (
        //     // The texture itself.
        //     "graphics/ZFormsExamples/BoxTextureGreen.png",
        //     // The top-left corner of the middle of the box.
        //     (32, 32),
        //     // The bottom-right corner of the middle of the box.
        //     (64, 64),
        //     // Whether to scale (true) or tile (false) the sides.
        //     false,
        //     // Whether to scale (true) or tile (false) the middle.
        //     false
        // );

        let offsetY = 75;
        // Add a box image.
        let boxSize = (88, 88);
        if((50 + boxSize.X) * blocksCount.Size() > baseRes.X)
        {
            blocksCount.Clear();
            rowsCount.Push(1);
        }
        let boxOffset = offsetY + boxSize.X * blocksCount.Size() - (blocksCount.Size() * 10);
        let boxInnerOffset = 0;

        // let buttonFrame = ZDA_ZF_Frame.create(
        //     (boxOffset + boxInnerOffset, offsetY + (rowsCount.Size() * (boxSize.X) - (rowsCount.Size() * 10))),
        //     boxSize
        // );

        // buttonFrame.pack(inventoryFrame);
        // buttonFrames.Push(buttonFrame);

        // background = ZDA_ZF_Image.Create
        // (
        //     // Position
        //     (boxOffset + boxInnerOffset, offsetY + (rowsCount.Size() * (boxSize.X) - (rowsCount.Size() * 10))),
        //     // Size
        //     (88, 88),
        //     // Image path/name
        //     "graphics/bbs/MISSBOXB3.png",
        //     // Alignment options
        //     ZDA_ZF_Image.AlignType_TopLeft,
        //     (2, 2)
        // );
        // // Add the image element into the main frame.
        // background.Pack (inventoryFrame);

        /*let aBoxImage = ZDA_ZF_BoxImage.Create
        (
            // Position
            
            //((baseRes.X - boxSize.X) / testDouble, (baseRes.Y - boxSize.Y) / testDouble),
            (0, 0),
            // Size
            boxSize,
            // Texture
            boxTexture,
            // Scale
            (0.25, 0.25)
        );
        // Add the box image element into the main frame.
        aBoxImage.Pack (buttonFrame);*/

        // Create the button's textures.
        // if(inventoryItem) {
        //     buttonIdle = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/bbs/MISSBOXB3_darkblue.png", true);
        //     buttonHover = ZDA_ZF_BoxTextures.CreateSingleTexture ("graphics/bbs/MISSBOXB3_darkgreen.png", true);
        // }

        let buttonSideSize = 88;
        let buttonPosX = boxOffset + boxInnerOffset + 88 / 2 - buttonSideSize / 2;
        let buttonPosY = offsetY + (rowsCount.Size() * (boxSize.X + 32)) + 88 / 2 - buttonSideSize / 2;

        //console.printf("inventoryItem: " .. inventoryItem);

        // // cached version
        // let aButtonCache = ZDA_ZF_InventorySlot.Create
        // (
        //     // Position
        //     //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
        //     (boxOffset + boxInnerOffset, offsetY + (rowsCount.Size() * (boxSize.X) - (rowsCount.Size() * 10))),
        //     // Size
        //     (buttonSideSize, buttonSideSize),
        //     // Our command handler
        //     cmdHandler: handler,
        //     // A command string for the button
        //     command: "PickItem",
        //     // The button's textures
        //     //inactive: buttonIdle,
        //     //hover: buttonHover,
        //     //click: buttonClick
        //     heldItem: inventoryItem
        // );
        // aButtonCache.Pack (inventoryFrame);
        // aButtonCache.setDontBlockMouse(true);
        //aButtonCache.hide();

        //Add a button.
        let aButton = ZDA_ZF_InventorySlot.Create
        (
            // Position
            //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
            (boxOffset + boxInnerOffset, 300 + (rowsCount.Size() * (boxSize.X) - (rowsCount.Size() * 10))),
            // Size
            (buttonSideSize, buttonSideSize),
            // Our command handler
            cmdHandler: handler,
            // A command string for the button
            command: "InventorySlotAction",
            rmbCommand: "UseItem",
            // The button's textures
            inactive: inventorySlotIdle,
            hover: inventorySlotIdle,
            click: inventorySlotIdle,
            playerInventorySlot: playerInventorySlot,
            heldItem: inventoryItem,
            isWeaponSlot: isWeaponSlot
        );
        
        // // Add the button element into the main frame.
        aButton.Pack (inventoryFrame);
        

        inventorySlots.Push(aButton);

        if(inventoryItem) {
            let itemIcon = ZDA_ZF_BoxTextures.CreateSingleTexture (TexMan.GetName(inventoryItem.icon), true);
            vector2 iconSize;
            [iconSize.x, iconSize.y] = TexMan.GetSize(inventoryItem.icon);

            let aBoxImage = ZDA_ZF_Image.Create
            (
                // Position
                //(boxOffset + boxInnerOffset, offsetY + (rowsCount.Size() * (boxSize.X) - (rowsCount.Size() * 10))),
                (0, 0),
                // Size
                iconSize *2,
                // Image path/name
                TexMan.GetName(inventoryItem.icon),
                // Alignment options
                ZDA_ZF_Image.AlignType_TopLeft,
                (2, 2)
            );
            aBoxImage.setDontBlockMouse(true);
            aBoxImage.Pack (mainFrame);

            // // cached version
            // let aBoxImageCache = ZDA_ZF_Image.Create
            // (
            //     // Position
            //     //(boxOffset + boxInnerOffset, offsetY + (rowsCount.Size() * (boxSize.X) - (rowsCount.Size() * 10))),
            //     (0, 0),
            //     // Size
            //     iconSize *2,
            //     // Image path/name
            //     TexMan.GetName(inventoryItem.icon),
            //     // Alignment options
            //     ZDA_ZF_Image.AlignType_TopLeft,
            //     (2, 2)
            // );
            // aBoxImageCache.setDontBlockMouse(true);
            // aBoxImageCache.Pack (mainFrame);
            // aBoxImageCache.hide();

            // // Add a button.
            // let bButton = ZDA_ZF_Button.Create
            // (
            //     // Position
            //     //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
            //     (boxOffset + boxInnerOffset, offsetY + (rowsCount.Size() * (boxSize.X) - (rowsCount.Size() * 10))),
            //     // Size
            //     iconSize *2,
            //     // Our command handler
            //     cmdHandler: handler,
            //     // A command string for the button
            //     command: "PickItem",
            //     // The button's textures
            //     inactive: itemIcon,
            //     hover: itemIcon,
            //     click: itemIcon
            // );
            // // Add the button element into the main frame.
            // bButton.Pack (mainFrame);
            aButton.itemImage = aBoxImage;
            //aButtonCache.itemImage = aBoxImageCache;
            ZDA_ZF_InventorySlot.centerItemIcon(aBoxImage, aButton);
        }

        blocksCount.Push(1);
    }

    void refreshSlotTextures() {
        for(int i=0; i<inventorySlots.Size(); i++)
        {
            // empty slot
            if(!inventorySlots[i].heldItem) {
                // hover with picked item over empty slot
                if(SelectedItemSlot) {
                    inventorySlots[i].SetTextures(inventorySlotIdle, inventorySlotHover, inventorySlotHover, null);
                    continue;
                }
                inventorySlots[i].SetTextures(inventorySlotIdle, inventorySlotIdle, inventorySlotIdle, null);
                continue;
            }
            // hover with picked item over same origin slot
            if(SelectedItemSlot && SelectedItemSlot == inventorySlots[i]) {
                inventorySlots[i].SetTextures(inventorySlotIdle, inventorySlotHover, inventorySlotHover, null);
                continue;
            }

            // slot with item
            inventorySlots[i].SetTextures(inventorySlotWithItem, inventorySlotHover, inventorySlotHover, null);
        }
    }

    void showItemDescription(ZDA_InventoryItem item) {
        let offsetY = 100; 
        for(int i=0; i<item.itemStats.Affixes.Size(); i++) {
            let affix = item.itemStats.Affixes[i];
            let affixLabel = ZDA_ZF_Label.Create(
                // Position.
                (20, offsetY),
                // Size.
                (itemDescriptionBox.GetWidth() - 2*20, 100),
                // The label's text.
                //text: HoveredItemSlot.heldItem.className,
                text: affix.Description,
                // The font to use.
                fnt: optionsFont,
                // Whether to automatically wrap the text or not.
                wrap: true,
                // Whether to automatically resize the element based on the text width.
                autoSize: true,
                // The text's colour.
                textColor: Font.CR_WHITE
            );

            let lines = optionsFont.breakLines(affix.Description, int(affixLabel.GetWidth() / 1));

            if(lines.count() >= 2) {
                offsetY += 15;    
            }
            offsetY += 25;
            affixLabel.pack(itemDescriptionFrame);

            HoveredItemAffixLabels.Push(affixLabel);
        }
    }

    void clearItemDescription()
    {
        if(HoveredItemAffixLabels.Size() > 0) {
            for(int i=0; i<HoveredItemAffixLabels.Size(); i++) {
                HoveredItemAffixLabels[i].unpack();
            }
            HoveredItemAffixLabels.Clear();
        }
    }

    override void Ticker ()
    {
        if(pickedItemImage) {
            pickedItemImage.SetBox(mainFrame.screenToRel(GetMousePos()) - pickedItemImage.GetSize() / 2, pickedItemImage.GetSize());
        }

        // set hovered item's name and description
        if(HoveredItemSlot && HoveredItemSlot.heldItem && !pickedItem) {
            HoveredItemName.setText(HoveredItemSlot.heldItem.className);
            //HoveredItemAffixLabels.setText(HoveredItemSlot.heldItem.className);

            // detect hovered slot change => refresh item description
            if(HoveredItemSlot.heldItem != oldHeldItem) {
                clearItemDescription();
            }

            if(HoveredItemAffixLabels.Size() == 0 && HoveredItemSlot.heldItem.itemStats) {
                showItemDescription(HoveredItemSlot.heldItem);
                oldHeldItem = HoveredItemSlot.heldItem;
            }
            
            itemDescriptionFrame.setPos((HoveredItemSlot.GetPosX() + HoveredItemSlot.GetWidth(), HoveredItemSlot.GetPosY()));
            itemDescriptionFrame.pack(mainFrame);
            itemDescriptionFrame.show();
        } else {
            clearItemDescription();
            itemDescriptionFrame.hide();
        }

        // Remove all existing labels from the menu, and delete them.
        // while (weaponNameLabels.Size () > 0)
        // {
        //     let label = weaponNameLabels [0];
        //     weaponNameLabels.Delete (0, 1);

        //     label.Unpack ();
        //     label.Destroy ();
        // }

        // Sanity checking: Do nothing if there's no consoleplayer
        if (players [consoleplayer].mo == NULL)
        {
            return;
        }

        // // Iterate through the player's inventory to find all of their weapons.
        // int labelCount = 0; // We need this to calculate the position of the labels.
        // let playerInventory = ZDA_PlayerInventory(players[consoleplayer].mo.FindInventory("ZDA_PlayerInventory"));
        // let itemOffset = 0;
        // ZDA_ZF_Button aButton;

        // if(inventorySlots.Size() > 0 && !SelectedItem) {
        //     for(int i = 0; i < inventorySlots.Size(); i++) {
        //         if(inventorySlots[i].heldItem) {
        //             //console.printf("my item: " .. inventorySlots[i].heldItem.weaponObj.GetClassName());
        //             //console.printf("posx: %d", inventorySlots[i].GetPosX());
        //             let itemIcon = ZDA_ZF_BoxTextures.CreateSingleTexture (TexMan.GetName(inventorySlots[i].heldItem.icon), true);
        //             vector2 iconSize;
        //             [iconSize.x, iconSize.y] = TexMan.GetSize(inventorySlots[i].heldItem.icon);

        //             // Add a button.
        //             aButton = ZDA_ZF_Button.Create
        //             (
        //                 // Position
        //                 //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
        //                 (inventorySlots[i].GetPosX() + 15, inventorySlots[i].GetPosY() + 40),
        //                 // Size
        //                 iconSize *2,
        //                 // Our command handler
        //                 cmdHandler: handler,
        //                 // A command string for the button
        //                 command: "PickItem",
        //                 // The button's textures
        //                 inactive: itemIcon,
        //                 hover: itemIcon,
        //                 click: itemIcon
        //             );
        //             // Add the button element into the main frame.
        //             aButton.Pack (mainFrame);
        //             inventorySlots[i].itemImage = aButton;
        //         }
        //     }
        // }
        

        // for(int i = 0; i < playerInventory.Items.Size(); i++) {
        //     let itemIcon = ZDA_ZF_BoxTextures.CreateSingleTexture (TexMan.GetName(playerInventory.Items[i].icon), true);
        //     vector2 iconSize;
        //     [iconSize.x, iconSize.y] = TexMan.GetSize(playerInventory.Items[i].icon);

        //     // Add a button.
        //     let aButton = ZDA_ZF_Button.Create
        //     (
        //         // Position
        //         //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
        //         (300, 300 + itemOffset),
        //         // Size
        //         iconSize * 3,
        //         // Our command handler
        //         cmdHandler: handler,
        //         // A command string for the button
        //         command: "PickItem",
        //         // The button's textures
        //         inactive: itemIcon,
        //         hover: itemIcon,
        //         click: itemIcon
        //     );
        //     // Add the button element into the main frame.
        //     aButton.Pack (mainFrame);

        //     // let aBoxImage = ZDA_ZF_Image.Create
        //     // (
        //     //     // Position
        //     //     (300, 300 + itemOffset),
        //     //     // Size
        //     //     (150, 150),
        //     //     // Image path/name
        //     //     texman.GetName(icon),
        //     //     // Alignment options
        //     //     ZDA_ZF_Image.AlignType_TopLeft,
        //     //     (2, 2)
        //     // );
        //     // aBoxImage.Pack (mainFrame);
        //     itemOffset += 50;
        // }

        // while (item != NULL)
        // {
        //     // If the inventory item isn't a weapon...
        //     if (!(item is "Weapon"))
        //     {
        //         // Set "item" to the next item in the player's inventory.
        //         item = item.inv;
        //         // Continue the loop.
        //         continue;
        //     }

        //     // If there's no space left in the screen...
        //     if (labelCount > 16)
        //     {
        //         // Break out of the loop.
        //         break;
        //     }

        //     // Get the weapon's name.
        //     let weaponName = item.GetTag ();

        //     bool apply;
        //     TextureID icon;
        //     [icon, apply] = BaseStatusBar.GetInventoryIcon(Inventory(item), 0);
        //     if(icon && item.GetClassName() != "Fist") {
        //         let itemIcon = ZDA_ZF_BoxTextures.CreateSingleTexture (TexMan.GetName(icon), true);
        //         vector2 iconSize;
        //         [iconSize.x, iconSize.y] = TexMan.GetSize(icon);

        //         // Add a button.
        //         let aButton = ZDA_ZF_Button.Create
        //         (
        //             // Position
        //             //((baseRes.X - 18.) / 2, (baseRes.Y - 18.) / 2),
        //             (300, 300 + itemOffset),
        //             // Size
        //             iconSize * 3,
        //             // Our command handler
        //             cmdHandler: handler,
        //             // A command string for the button
        //             command: "PickItem",
        //             // The button's textures
        //             inactive: itemIcon,
        //             hover: itemIcon,
        //             click: itemIcon
        //         );
        //         // Add the button element into the main frame.
        //         aButton.Pack (mainFrame);

        //         // let aBoxImage = ZDA_ZF_Image.Create
        //         // (
        //         //     // Position
        //         //     (300, 300 + itemOffset),
        //         //     // Size
        //         //     (150, 150),
        //         //     // Image path/name
        //         //     texman.GetName(icon),
        //         //     // Alignment options
        //         //     ZDA_ZF_Image.AlignType_TopLeft,
        //         //     (2, 2)
        //         // );
        //         // aBoxImage.Pack (mainFrame);
        //         itemOffset += 50;
        //     }

        //     // Add a label.
        //     let label = ZDA_ZF_Label.Create
        //     (
        //         // Position.
        //         (
        //             // Horizontal position.
        //             14,
        //             // Calculate the vertical position.
        //             // Initial offset + ((label text height + spacing) * label count)
        //             14 + ((smallfont.GetHeight () + 1) * labelCount)
        //         ),
        //         // Size.
        //         (
        //             // Calculate the horizontal size of the text.
        //             smallfont.StringWidth (weaponName),
        //             // Get the font's height.
        //             smallFont.GetHeight ()
        //         ),
        //         // The label's text.
        //         text: weaponName,
        //         // The font to use.
        //         fnt: smallFont,
        //         // Whether to automatically wrap the text or not.
        //         wrap: false,
        //         // Whether to automatically resize the element based on the text width.
        //         autoSize: true,
        //         // The text's colour.
        //         textColor: Font.CR_WHITE
        //     );

        //     // Add the label element to the main frame.
        //     label.Pack (mainFrame);
        //     // Add the label to the labels list.
        //     weaponNameLabels.Push (label);

        //     // Increment labelCount.
        //     labelCount++;

        //     // Set "item" to the next item in the player's inventory.
        //     item = item.inv;
        // }
    }
}

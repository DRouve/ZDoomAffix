class ZDA_HUD : DoomStatusBar
{
    HUDFont fontSmall;
    HUDFont fontBig;
    HUDFont fontBigNoMono;

    ZDA_ItemStatsController ItemStatsController;

    Inventory touchedItem;

    override void Init()
    {
        super.Init();
        Font fnt = "BIGFONT";
        fontBig = HUDFont.Create(fnt, fnt.GetCharWidth("0"), true, 2, 2);
        fontBigNoMono = HUDFont.Create(fnt, 1, false, 2, 2);
        fnt = "SMALLFONT";
        fontSmall = HUDFont.Create(fnt);
    }

    override void Draw (int state, double TicFrac)
	{
		Super.Draw (state, TicFrac);
        if(!ItemStatsController) {
            ItemStatsController = ZDA_ItemStatsController(CPlayer.mo.FindInventory("ZDA_ItemStatsController"));
        }

        DrawItemInfo();
	}

    void DrawItemInfo() {
        if(!ItemStatsController) {
            ItemStatsController = ZDA_ItemStatsController(CPlayer.mo.FindInventory("ZDA_ItemStatsController"));
        }

        let itemInfoOffset = 700;
        if(ItemStatsController.touchTimer && ItemStatsController.touchedItem && ItemStatsController.touchedItemStats) {
            itemInfoOffset = 450;
            // bool apply;
            // TextureID icon;
            // [icon, apply] = GetInventoryIcon(Inventory(ItemStatsController.touchedItem), 0);

            let wspawn = ItemStatsController.touchedItem.FindState("Spawn");
            let icon = wspawn.GetSpriteTexture(0);
            
            if(icon) {
                DrawTexture(icon, (700, 250), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW);
            }
            DrawString(fontBigNoMono, ItemStatsController.touchedItem.GetClassName(), (700, 250), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW);
            let offset = 270;
            DrawString(fontSmall, ItemStatsController.touchedItemStats.Rarity, (700, offset), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW, Font.CR_GRAY);
            offset += 20;
            for(int i = 0; i < ItemStatsController.touchedItemStats.Affixes.Size(); i++) {
                offset += 10;
                DrawString(fontSmall, ItemStatsController.touchedItemStats.Affixes[i].AffixCategoryShortcode .. "   " .. ItemStatsController.touchedItemStats.Affixes[i].Description, (700, offset), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW);
            }
        }

        if(ItemStatsController.touchedItem && ItemStatsController.isComparingItems) {
            let playerCompareItem = Weapon(CPlayer.mo.FindInventory(ItemStatsController.touchedItem.GetClassName()));
            if(playerCompareItem) {
                for(int i = 0; i < ItemStatsController.ItemStats.Size(); i++) {
                    if(ItemStatsController.ItemStats[i].ItemObject == playerCompareItem) {
                        DrawString(fontBigNoMono, ItemStatsController.ItemStats[i].ItemObject.GetClassName(), (itemInfoOffset, 250), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW);
                        let ItemInfo = ItemStatsController.ItemStats[i];
                        let offset = 270;
                        let itemEquippedText = "In inventory";
                        if(playerCompareItem == CPlayer.ReadyWeapon) {
                            itemEquippedText = "Currently equipped";
                        }
                        DrawString(fontSmall, ItemStatsController.ItemStats[i].Rarity, (itemInfoOffset, offset), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW, Font.CR_GRAY);
                        DrawString(fontSmall, itemEquippedText, (itemInfoOffset, offset+15), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW, Font.CR_GRAY);
                        offset += 20;
                        for(int i = 0; i < ItemInfo.Affixes.Size(); i++) {
                            offset += 10;
                            DrawString(fontSmall, ItemInfo.Affixes[i].AffixCategoryShortcode .. "   " .. ItemInfo.Affixes[i].Description, (itemInfoOffset, offset), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW);
                        }
                        break;
                    }
                }
            }
        }

        if(ItemStatsController.isShowEquippedInfo) {
            if(ItemStatsController.isComparingItems) {
                itemInfoOffset = 200;
            }
            let playerCurrentItem = CPlayer.ReadyWeapon;
            if(playerCurrentItem) {
                for(int i = 0; i < ItemStatsController.ItemStats.Size(); i++) {
                    if(ItemStatsController.ItemStats[i].ItemClassName == playerCurrentItem.GetClassName() && ItemStatsController.ItemStats[i] == ItemStatsController.currentStats) {
                        DrawString(fontBigNoMono, ItemStatsController.ItemStats[i].ItemClassName, (itemInfoOffset, 250), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW);
                        let ItemInfo = ItemStatsController.ItemStats[i];
                        let offset = 270;
                        DrawString(fontSmall, ItemStatsController.ItemStats[i].Rarity, (itemInfoOffset, offset), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW, Font.CR_GRAY);
                        DrawString(fontSmall, "Currently equipped", (itemInfoOffset, offset+15), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW, Font.CR_GRAY);
                        offset += 20;
                        for(int i = 0; i < ItemInfo.Affixes.Size(); i++) {
                            offset += 10;
                            console.printf("HUDaffixShortcode: %s", ItemInfo.Affixes[i].AffixCategoryShortcode);
                            DrawString(fontSmall, ItemInfo.Affixes[i].AffixCategoryShortcode .. "   " .. ItemInfo.Affixes[i].Description, (itemInfoOffset, offset), DI_TEXT_ALIGN_LEFT|DI_NOSHADOW);
                        }
                        break;
                    }
                }
            }
        }
    }
}
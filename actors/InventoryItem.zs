class ZDA_InventoryItem
{
    string className;
    ZDA_ItemStats itemStats;
    TextureID icon;
    string name;
    ZDA_InventorySlot inventorySlot;

    ZDA_InventoryItem Init(
        string className, 
        ZDA_ItemStats itemStats, 
        TextureID icon, 
        string name,
        ZDA_InventorySlot inventorySlot = null
    ) {
        self.className = className;
        self.itemStats = itemStats;
        self.icon = icon;
        self.name = name;
        self.inventorySlot = inventorySlot;
        return self;
    }
}
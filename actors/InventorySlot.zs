class ZDA_InventorySlot
{
    int id;
    ZDA_InventoryItem heldItem;

    ZDA_InventorySlot Init(
        int id = 1,
        ZDA_InventoryItem heldItem = null
    ) {
        self.id = id;
        self.heldItem = heldItem;
        return self;
    }
}
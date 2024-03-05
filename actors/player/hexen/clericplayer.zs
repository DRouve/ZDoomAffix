class ZDA_ClericPlayer : ClericPlayer replaces ClericPlayer
{
	override bool CanTouchItem(Inventory item) {
		return false;
	}
}
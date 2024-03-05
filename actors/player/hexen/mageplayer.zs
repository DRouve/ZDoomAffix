class ZDA_MagePlayer : MagePlayer replaces MagePlayer
{
	override bool CanTouchItem(Inventory item) {
		return false;
	}
}
#include <tf2items>

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
	TF2Items_SetClassname(hItem, classname);		
	TF2Items_SetItemIndex(hItem, iItemDefinitionIndex);
	TF2Items_SetNumAttributes(hItem, 7);
	TF2Items_SetAttribute(hItem, 0, 406, 1.0);
	if(iItemDefinitionIndex == 594)
	{
		TF2Items_SetAttribute(hItem, 1, 116, 0.0);
		TF2Items_SetAttribute(hItem, 2, 356, 0.0);
	}
	TF2Items_SetAttribute(hItem, 3, 731, 1.0);
	
	if(StrEqual(classname, "tf_weapon_pistol"))
	{
		TF2Items_SetAttribute(hItem, 4, 44, 1.0);
		TF2Items_SetAttribute(hItem, 5, 518, 5.0);
		TF2Items_SetAttribute(hItem, 6, 1, 0.1);
	}
	return Plugin_Changed;
}
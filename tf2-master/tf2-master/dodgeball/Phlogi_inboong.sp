#include <tf2items>

new Handle:Cvarinboong = INVALID_HANDLE;

public OnPluginStart()
{
	Cvarinboong = CreateConVar("sm_phlo_iboong", "1", "인붕할거냐 말거냐");
}


// public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
// {
	// hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
	// TF2Items_SetClassname(hItem, classname);		
	// TF2Items_SetItemIndex(hItem, iItemDefinitionIndex);
	// if(iItemDefinitionIndex == 594)
	// {
		// TF2Items_SetNumAttributes(hItem, 5);
		// TF2Items_SetAttribute(hItem, 0, 116, 0.0);
		// TF2Items_SetAttribute(hItem, 1, 356, 0.0);
		// TF2Items_SetAttribute(hItem, 2, 406, 1.0);
		
		// switch(GetConVarInt(Cvarinboong))
		// {
			// case 0: TF2Items_SetAttribute(hItem, 3, 254, 0.0);
			// case 1: TF2Items_SetAttribute(hItem, 4, 254, 4.0);
		// }
	// }
	// else
	// {
		// TF2Items_SetNumAttributes(hItem, 3);
		// TF2Items_SetAttribute(hItem, 0, 406, 1.0);
		
		// switch(GetConVarInt(Cvarinboong))
		// {
			// case 0: TF2Items_SetAttribute(hItem, 1, 254, 0.0);
			// case 1: TF2Items_SetAttribute(hItem, 2, 254, 4.0);
		// }
	// }
	// return Plugin_Changed;
// }

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
	TF2Items_SetClassname(hItem, classname);		
	TF2Items_SetItemIndex(hItem, iItemDefinitionIndex);
	if(iItemDefinitionIndex == 594)
	{
		TF2Items_SetNumAttributes(hItem, 5);
		TF2Items_SetAttribute(hItem, 0, 116, 0.0);
		TF2Items_SetAttribute(hItem, 1, 356, 0.0);
		TF2Items_SetAttribute(hItem, 2, 406, 1.0);
		TF2Items_SetAttribute(hItem, 3, 640, 1.0);
		
		switch(GetConVarInt(Cvarinboong))
		{
			case 0: TF2Items_SetAttribute(hItem, 4, 254, 0.0);
			case 1: TF2Items_SetAttribute(hItem, 4, 254, 4.0);
		}
	}
	else
	{
		TF2Items_SetNumAttributes(hItem, 3);
		
		TF2Items_SetAttribute(hItem, 0, 406, 1.0);
		TF2Items_SetAttribute(hItem, 1, 640, 1.0);
		
		switch(GetConVarInt(Cvarinboong))
		{
			case 0: TF2Items_SetAttribute(hItem, 2, 254, 0.0);
			case 1: TF2Items_SetAttribute(hItem, 2, 254, 4.0);
		}
	}
	return Plugin_Changed;
}
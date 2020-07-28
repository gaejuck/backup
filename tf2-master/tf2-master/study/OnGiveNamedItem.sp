PRESERVE_ATTRIBUTES //기본 능력치 보존

public Event_InventoryApplication(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	new iEnt = -1;
	
	if(on[client] == true)
	{ 
		while((iEnt = FindEntityByClassname(iEnt, "tf_wearable")) != -1)
		{
			if(GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client)
			{
				decl String:strItemSlot[16];
						 
				TF2II_GetItemSlotName(GetEntProp(iEnt, Prop_Send, "m_iItemDefinitionIndex"), strItemSlot, sizeof(strItemSlot) );
				if( StrEqual( strItemSlot , "head", false ) )
				{
					TF2Attrib_SetByDefIndex(iEnt, 134, 62.0);
				}
			}
		}
	}
	else
		TF2Attrib_RemoveByDefIndex(client ,134);
		
}

public TF2Items_OnGiveNamedItem_Post(client, String:classname[], index, level, quality, entity)
{
	switch (index)
	{
		case 38, 457, 1000: // Axtinguisher item indexes
		{
			TF2Attrib_SetByName(entity, "axtinguisher properties", 0.0); // Remove its new mechanic
			TF2Attrib_SetByName(entity, "crit vs burning players", 1.0); // Add this one back in
		}
	}
}

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	if (StrEqual(classname, "tf_wearable"))
		return Plugin_Continue;  
	
	hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
	TF2Items_SetClassname(hItem, classname);		
	TF2Items_SetItemIndex(hItem, iItemDefinitionIndex);
	
	TF2Items_SetNumAttributes(hItem, 1);
	TF2Items_SetAttribute(hItem, 0, 542, 1.0);
	
----------------------------------------------------------------------------------
	
	if(iItemDefinitionIndex == 309)
	{
		hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
		TF2Items_SetClassname(hItem, classname);		
	//	TF2Items_SetItemIndex(hItem, 309);
		
		TF2Items_SetNumAttributes(hItem, 1);
		TF2Items_SetAttribute(hItem, 0, 134,80.0);
	}
	
	return Plugin_Changed;
	
	
----------------------------------------------------------------------------------
	
	if (StrEqual(classname, "tf_wearable_demoshield"))
	{
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
	
	
----------------------------------------------------------------------------------
	if(iItemDefinitionIndex == 594)
	{
		new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "116 ; 0.0 ; 356 ; 0.0");

		if (hItemOverride != INVALID_HANDLE)
		{
			hItem = hItemOverride;

			return Plugin_Changed;
		}
	}
}

public Action:WeaponMenu(client)
{
	decl String:Classname[64], String:Attribute[256], String:name[50], String:class[64];
	new String:temp[256];
	
	new Handle:menu = CreateMenu(select_weapon);
	DB = CreateKeyValues("custom_weapon"); 
	
	SetMenuTitle(menu, "무기고르삼", client);
		
	FileToKeyValues(DB, WeaponConfig);
	if(KvGotoFirstSubKey(DB))
	{
		do
		{
			KvGetSectionName(DB, name, sizeof(name));
			KvGetString(DB, "classname", Classname, sizeof(Classname));
			KvGetString(DB, "attribute", Attribute, sizeof(Attribute));
			new Index = KvGetNum(DB, "index", 0);
			new Level = KvGetNum(DB, "level", 1);
			new Slot = KvGetNum(DB, "slot", 0);
			new Qual = KvGetNum(DB, "qual", 1);
			KvGetString(DB, "class", class, sizeof(class));
			
			Format(temp, sizeof(temp), "%s*%d*%d*%d*%d*%s", Classname, Slot, Index, Level, Qual, Attribute);
			
			if(GetConVarInt(Class) == 1)
			{
				if(StrEqual(class, "공통", true))
					if(TF2_GetPlayerClass(client) != TFClassType:TFClass_Unknown)
						AddMenuItem(menu, temp, name);
			}
			else
				AddMenuItem(menu, temp, name);
		}
		while(KvGotoNextKey(DB));
		
		KvGoBack(DB);
	}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	// SetMenuExitButton(menu, true);
	KvRewind(DB);
	return Plugin_Handled;
}

public select_weapon(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}

	if(action == MenuAction_Select)
	{
		decl String:info[256], String:aa[6][256];
		GetMenuItem(menu, select, info, sizeof(info));
		ExplodeString(info, "*", aa, 6, 256);

		
		SpawnWeapon(client, aa[0], StringToInt(aa[1]), StringToInt(aa[2]), StringToInt(aa[3]),
		StringToInt(aa[4]), aa[5]);
		
		CloseHandle(DB);
		
		if(GetConVarInt(menu_hide) == 1)
			WeaponMenu(client);
	}
}

stock SpawnWeapon(client,String:name[],slot,index,level,qual,String:att[])
{
	new Flags = OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL
	| OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES | FORCE_GENERATION;
	
	new Handle:newItem = TF2Items_CreateItem(OVERRIDE_ALL);
	
	if (newItem == INVALID_HANDLE)
		return -1;
		
	TF2Items_SetClassname(newItem, name);
	
	if (StrEqual(name, "tf_weapon_revolver", false) || StrEqual(name, "tf_weapon_pistol", false))
		Flags |= FORCE_GENERATION;
		
	TF2Items_SetItemIndex(newItem, index);
	TF2Items_SetLevel(newItem, level);
	TF2Items_SetQuality(newItem, qual);
	TF2Items_SetFlags(newItem, Flags);
	
	new String:atts[32][32]; 
	new count = ExplodeString(att, " ; ", atts, 32, 32);
	
	if (count > 1)
	{
		TF2Items_SetNumAttributes(newItem, count/2);
		new i2 = 0;
		for (new i = 0;  i < count;  i+= 2)
		{
			TF2Items_SetAttribute(newItem, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
		TF2Items_SetNumAttributes(newItem, 0);
		
	TF2_RemoveWeaponSlot(client, slot);
	new entity = TF2Items_GiveNamedItem(client, newItem);
	
	EquipPlayerWeapon(client, entity);
	
	CloneHandle(newItem);
	return entity;
}
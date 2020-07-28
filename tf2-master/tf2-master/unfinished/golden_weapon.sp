#include <tf2_stocks>
#include <tf2items>
#include <tf2itemsinfo>

new g_iHealth[MAXPLAYERS+1] = -1;

new ClientWeapon[MAXPLAYERS+1][3];
new Float:ClientGold[MAXPLAYERS+1][3];

public OnPluginStart()
{
	RegConsoleCmd("sm_gold", melee_weapon);
}

public OnClientPostAdminCheck(client)
{ 
	g_iHealth[client] = -1;
	
	for (new i = 0; i < 3; i++)
		ClientWeapon[client][i] = 0;
		
	for (new i = 0; i < 3; i++)
		ClientGold[client][i] = 0.0;
}

public OnClientDisconnected(client)
{
	g_iHealth[client] = -1;
	
	for (new i = 0; i < 3; i++)
		ClientWeapon[client][i] = 0;
		
	for (new i = 0; i < 3; i++)
		ClientGold[client][i] = 0.0;
}
	

public Action:melee_weapon(client, args)
{
	new Handle:info = CreateMenu(Menu_Information);
	SetMenuTitle(info, "근접무기");

	if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Scout)
	{
		AddMenuItem(info, "200", "오스트레일륨 스캐터건"); 
		AddMenuItem(info, "45", "오스트레일륨 자연의 섭리"); 
	}
	
	if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Soldier)
	{
		AddMenuItem(info, "205", "오스트레일륨 로켓발사기"); 
		AddMenuItem(info, "228", "오스트레일륨 블랙 박스"); 
	}
	
	DisplayMenu(info, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public Menu_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
		new slot = GetPlayerWeaponSlot(client, 0);
		new item = GetEntProp(slot, Prop_Send, "m_iItemDefinitionIndex");
		
		new String:name[32], String:classname[32];
		TF2II_GetItemName(item, name, sizeof(name));
		TF2II_GetItemClass(item, classname, sizeof(classname)); 
		
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Scout)
		{
			if(StrEqual(classname, "tf_weapon_scattergun", false))
			{
				decl String:info[64];
				GetMenuItem(menu, select, info, sizeof(info));
			
				ClientGold[client][0] = 1.0;
				ClientWeapon[client][0] = StringToInt(info);
				PrintToChat(client, "%d", StringToInt(info)); 
				TF2_ForceGive(client);
			}
			else
			{
				ClientGold[client][0] = 0.0;
				ClientWeapon[client][0] = 0;
				PrintToChat(client, "\x03스캐터건을 끼셔야 합니다.");
			}
		}
		
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Soldier)
		{
			if(StrEqual(classname, "tf_weapon_rocketlauncher", false))
			{
				decl String:info[64];
				GetMenuItem(menu, select, info, sizeof(info));
			
				ClientGold[client][0] = 1.0;
				ClientWeapon[client][0] = StringToInt(info);
				PrintToChat(client, "%d", StringToInt(info)); 
				TF2_ForceGive(client);
			}
			else
			{
				ClientGold[client][0] = 0.0;
				ClientWeapon[client][0] = 0;
				PrintToChat(client, "\x03로켓발사기를 끼셔야 합니다.");
			}
		}
		
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	new TF2ItemSlot:slot = TF2II_GetItemSlot(iItemDefinitionIndex);
	switch (slot)
	{
		case 0:
		{
			if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Scout)
			{
				if(iItemDefinitionIndex == 220 || iItemDefinitionIndex == 448 || iItemDefinitionIndex == 772)
				{
					ClientWeapon[client][0] = 0;
					ClientGold[client][0] = 0.0; 
				}
				
				if(ClientWeapon[client][0] != 0 && ClientGold[client][0] != 0.0)
				{
					hItem = OnGive(hItem, ClientWeapon[client][0], ClientGold[client][0], OVERRIDE_ITEM_DEF|OVERRIDE_ATTRIBUTES);
					return Plugin_Changed;
				}
					
				if(ClientWeapon[client][0] != 0)
				{
					hItem = OnGive(hItem, ClientWeapon[client][0], _, OVERRIDE_ITEM_DEF);
					return Plugin_Changed;
				}
				if(ClientGold[client][0] != 0.0)
				{
					hItem = OnGive(hItem, _, ClientGold[client][0], OVERRIDE_ATTRIBUTES);
					return Plugin_Changed;
				}
			}
			
			if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Soldier)
			{
				if(iItemDefinitionIndex == 127 || iItemDefinitionIndex == 1104)
				{
					ClientWeapon[client][0] = 0;
					ClientGold[client][0] = 0.0; 
				}
				
				if(ClientWeapon[client][0] != 0 && ClientGold[client][0] != 0.0)
				{
					hItem = OnGive(hItem, ClientWeapon[client][0], ClientGold[client][0], OVERRIDE_ITEM_DEF|OVERRIDE_ATTRIBUTES);
					return Plugin_Changed;
				}
					
				if(ClientWeapon[client][0] != 0)
				{
					hItem = OnGive(hItem, ClientWeapon[client][0], _, OVERRIDE_ITEM_DEF);
					return Plugin_Changed;
				}
				if(ClientGold[client][0] != 0.0)
				{
					hItem = OnGive(hItem, _, ClientGold[client][0], OVERRIDE_ATTRIBUTES);
					return Plugin_Changed;
				}
			}
			
			// if(ClientWeapon[client][0] != 0 && ClientGold[client][0] != 0.0)
			// {
				// hItem = OnGive(hItem, ClientWeapon[client][0], ClientGold[client][0], OVERRIDE_ITEM_DEF|OVERRIDE_ATTRIBUTES);
				// return Plugin_Changed;
			// }
				
			// if(ClientWeapon[client][0] != 0)
			// {
				// hItem = OnGive(hItem, ClientWeapon[client][0], _, OVERRIDE_ITEM_DEF);
				// return Plugin_Changed;
			// }
			// if(ClientGold[client][0] != 0.0)
			// {
				// hItem = OnGive(hItem, _, ClientGold[client][0], OVERRIDE_ATTRIBUTES);
				// return Plugin_Changed;
			// }
		}
	}
	return Plugin_Continue;
}

stock Handle:OnGive(Handle:hItem, index = -1, Float:gold = 0.0, flags)
{
	hItem = TF2Items_CreateItem(flags);
	
	if (index != -1)
	{
		TF2Items_SetItemIndex(hItem, index);
	}

	
	TF2Items_SetNumAttributes(hItem, 1);
	
	TF2Items_SetAttribute(hItem, 0, 542, gold);
	
	TF2Items_SetFlags(hItem, flags);
	return hItem;
}

//RemoveWearable(client, "tf_wearable", "CTFWearable");
stock TF2_ForceGive(client)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		g_iHealth[client] = GetEntProp(client, Prop_Data, "m_iHealth");
		TF2_RemoveAllWeapons(client);
		TF2_RemoveAllWearables(client);
		TF2_RegeneratePlayer(client);
		CreateTimer(0.2, Timer_Regenerate, any:client);
	}
}

public Action:Timer_Regenerate(Handle:timer, any:client)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		TF2_RegeneratePlayer(client);
		if (g_iHealth[client] != -1)
		{
			SetEntProp(client, Prop_Data, "m_iHealth", g_iHealth[client]);
		}
	}
}

stock TF2_RemoveAllWearables(client)
{
	RemoveWearable(client, "tf_weapon_scattergun", "CTFScatterGun");
	RemoveWearable(client, "tf_weapon_handgun_scout_primary", "CTFPistol_ScoutPrimary");
	RemoveWearable(client, "tf_weapon_pep_brawler_blaster", "CTFPEPBrawlerBlaster");

	RemoveWearable(client, "tf_weapon_pistol", "CTFPistol");
	RemoveWearable(client, "tf_weapon_lunchbox_drink", "CTFLunchBox_Drink");
	RemoveWearable(client, "tf_weapon_jar_milk", "CTFJarMilk");
	RemoveWearable(client, "tf_weapon_handgun_scout_secondary", "CTFPistol_ScoutSecondary");
	RemoveWearable(client, "tf_weapon_cleaver", "CTFCleaver");
}

stock RemoveWearable(client, String:classname[], String:networkclass[])
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		new edict = MaxClients+1;
		while((edict = FindEntityByClassname2(edict, classname)) != -1)
		{
			decl String:netclass[32];
			if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, networkclass))
			{
				if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client)
				{
					AcceptEntityInput(edict, "Kill"); 
				}
			}
		}
	}
}

stock bool:IsValidClient(client)
{
	if (client <= 0) return false;
	if (client > MaxClients) return false;
	return IsClientInGame(client);
}

stock FindEntityByClassname2(startEnt, const String:classname[])
{
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

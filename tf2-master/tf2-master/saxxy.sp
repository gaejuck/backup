#include <tf2_stocks>
#include <tf2items>
#include <tf2itemsinfo>
#include <sdkhooks>

new g_iHealth[MAXPLAYERS+1] = -1;

new ClientWeapon[MAXPLAYERS+1][3];
new ClientGold[MAXPLAYERS+1][3];

new bool:inSpawn[MAXPLAYERS + 1];

public Plugin:myinfo = {
	name		= "tf2 saxxy mod",
	author	  = "TAKE 2",
	description = "Oh! Saxxy!!",
	version	 = "1.0",
	url		 = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
};

public OnPluginStart()
{
	RegAdminCmd("sm_mweapon", melee_weapon, ADMFLAG_KICK);
}

public OnClientPostAdminCheck(client)
{
	g_iHealth[client] = -1;
	
	for (new i = 0; i < 3; i++)
		ClientWeapon[client][i] = 0;
		
	for (new i = 0; i < 3; i++)
		ClientGold[client][i] = 0;
}

public OnClientDisconnected(client)
{
	g_iHealth[client] = -1;
	
	for (new i = 0; i < 3; i++)
		ClientWeapon[client][i] = 0;
		
	for (new i = 0; i < 3; i++)
		ClientGold[client][i] = 0;
		
	if(inSpawn[client] == true)
		inSpawn[client] = false;
}

public Action:melee_weapon(client, args)
{
	if(inSpawn[client] == false)
	{
		PrintToChat(client, "\x03스폰지점에서 사용하세요 또는 스폰지점 중앙부분에서 사용하세요");
		return Plugin_Handled;
	}
	
	new Handle:info = CreateMenu(Menu_Information);
	SetMenuTitle(info, "근접무기");

	new String:classname[32], String:index[32], String:name[64];
	
	for(new i = 0; i <= 1127; i++)
	{
		TF2II_GetItemClass(i, classname, sizeof(classname)); 
		TF2II_GetItemName(i, name, sizeof(name));
				
		if(StrEqual(classname, "saxxy", false)) 
		{
			Format(index, sizeof(index), "%d", i);
			AddMenuItem(info, index, name); 
		}
	}

	DisplayMenu(info, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public Menu_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		if(inSpawn[client] == false)
		{
			PrintToChat(client, "\x03스폰지점에서 사용하세요 또는 스폰지점 중앙부분에서 사용하세요");
			return;
		}
		
		new slot = GetPlayerWeaponSlot(client, 2);
		new item = GetEntProp(slot, Prop_Send, "m_iItemDefinitionIndex");
		
		new String:classname[32];
		TF2II_GetItemClass(item, classname, sizeof(classname)); 
		
		if(StrEqual(classname, "saxxy", false))
		{
			decl String:info[64];
			GetMenuItem(menu, select, info, sizeof(info));
			
			if(StrEqual(info, "423", false))
			{
				ClientGold[client][0] = 1;
				ClientWeapon[client][0] = StringToInt(info);
			}
			else if(StrEqual(info, "1071", false))
			{
				ClientGold[client][0] = 1;
				ClientWeapon[client][0] = StringToInt(info);
			}
			else
			{
				ClientGold[client][0] = 0;
				ClientWeapon[client][0] = StringToInt(info);
			}
			TF2_ForceGive(client);
		}
		else
		{
			PrintToChat(client, "\x03공용 밀리무기를 끼셔야 선택이 가능합니다.");
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
		case 2:
		{
			if(!StrEqual(classname, "saxxy", false))
			{
				ClientWeapon[client][0] = 0;
				ClientGold[client][0] = 0;
			}
			if(ClientWeapon[client][0] != 0 && ClientGold[client][0] != 0)
			{
				hItem = OnGive(hItem, ClientWeapon[client][0], ClientGold[client][0], OVERRIDE_ITEM_DEF|OVERRIDE_ATTRIBUTES);
				return Plugin_Changed;
			}
				
			if(ClientWeapon[client][0] != 0)
			{
				hItem = OnGive(hItem, ClientWeapon[client][0], _, OVERRIDE_ITEM_DEF);
				return Plugin_Changed;
			}
			if(ClientGold[client][0] != 0)
			{
				hItem = OnGive(hItem, _, ClientGold[client][0], OVERRIDE_ATTRIBUTES);
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public OnEntityCreated(entity, const String:classname[])
{
    if (StrEqual(classname, "func_respawnroom", false)) {
        SDKHook(entity, SDKHook_StartTouch, StartTouchSpawn);
        SDKHook(entity, SDKHook_EndTouch, EndTouchSpawn);
    }
}

public Action:StartTouchSpawn(spawn, client)
{
	if (AliveCheck(client))
		inSpawn[client] = true;
} 

public Action:EndTouchSpawn(spawn, client)
{
	if (AliveCheck(client))
		inSpawn[client] = false;
}

stock Handle:OnGive(Handle:hItem, index = -1, gold = 0, flags)
{
	hItem = TF2Items_CreateItem(flags);
	
	if (index != -1)
	{
		TF2Items_SetItemIndex(hItem, index);
	}

	
	if(gold == 1) //황프
	{
		TF2Items_SetNumAttributes(hItem, 2);
		TF2Items_SetAttribute(hItem, 0, 542, 0.0);
		TF2Items_SetAttribute(hItem, 1, 150, 1.0);
	}
	
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

public bool:AliveCheck(client)
{
	if(client > 0 && client <= MaxClients)
		if(IsClientConnected(client) == true)
			if(IsClientInGame(client) == true)
				if(IsPlayerAlive(client) == true) return true;
				else return false;
			else return false;
		else return false;
	else return false;
}

stock FindEntityByClassname2(startEnt, const String:classname[])
{
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

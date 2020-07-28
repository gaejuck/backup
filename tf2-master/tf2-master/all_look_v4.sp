#include <sdktools>
#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2items>
#include <steamtools>

public Plugin:myinfo =
{
	name = "TF2 Wearable Plugin",
	author = "TAKE 2",
	description = "룩을 꾸미시오오",
	version = "1.0",
	url = "x2x"
} 

enum Item_Enum
{
	MyWearableSlot, 
	MyWearableSlot2, 
	MyWearableSlot3, 
	
	WearableSlot, 
	WearableSlot2, 
	WearableSlot3
};

enum Attribute_Enum
{
	Float:UnusualSlot,
	Float:UnusualSlot2,
	Float:UnusualSlot3,
	
	Float:PaintSlot,
	Float:PaintSlot2,
	Float:PaintSlot3
};

new Item[MAXPLAYERS+1][Item_Enum][10];
new Float:Attribute[MAXPLAYERS+1][Attribute_Enum][10];
new bool:RandomItem[MAXPLAYERS+1] = false; 

new ItemCount[MAXPLAYERS+1];

new String:Cvar_Item[120];
new String:Cvar_Unusual[120];
new String:Cvar_Paint[120];
new String:test[120];

new Handle:db = INVALID_HANDLE;
new Handle:ItemArray[MAXPLAYERS+1] = INVALID_HANDLE;

new on;

public OnPluginStart()
{
	BuildPath(Path_SM, Cvar_Item, sizeof(Cvar_Item), "configs/wearables/item.cfg");
	BuildPath(Path_SM, Cvar_Unusual, sizeof(Cvar_Unusual), "configs/wearables/look_unusual.cfg");
	BuildPath(Path_SM, Cvar_Paint, sizeof(Cvar_Paint), "configs/wearables/paint.cfg");
	BuildPath(Path_SM, test, sizeof(test), "on.txt");
	
	RegAdminCmd("sm_item", ItemCommand, 0);
	RegAdminCmd("sm_unusual", UnusualCommand, 0);
	RegAdminCmd("sm_paint", PaintCommand, 0);
	RegAdminCmd("sm_reset", ResetCommand, 0);
	RegAdminCmd("sm_random", RandomCommand, 0);
		
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("post_inventory_application", inventory);
	
	decl String:error[256];
	error[0] = '\0';
		
	if(SQL_CheckConfig("look")) db = SQL_Connect("look", true, error, sizeof(error));
		
	if(on != 1 && db==INVALID_HANDLE || error[0])
	{
		LogError("[look] Could not connect to look database: %s", error);
		return;
	}	
		
	PrintToServer("[look] Connection successful.");
		
	SQL_TQuery(db, SQLErrorCallback, "SET NAMES 'UTF8'", 0, DBPrio_High);
	SQL_TQuery(db, SQLErrorCallback, "create table if not exists user_slot(steamid varchar(64) not null PRIMARY KEY, name varchar(256) not null) ENGINE=MyISAM DEFAULT CHARSET=utf8;");
	SQL_TQuery(db, SQLErrorCallback, "create table if not exists unusual(steamid varchar(64) not null PRIMARY KEY, name varchar(256) not null) ENGINE=MyISAM DEFAULT CHARSET=utf8;");
	SQL_TQuery(db, SQLErrorCallback, "create table if not exists paint(steamid varchar(64) not null PRIMARY KEY, name varchar(256) not null) ENGINE=MyISAM DEFAULT CHARSET=utf8;");
		
	SQL_TQuery(db, SQLQuerySlotField, "select * from user_slot;", DBPrio_High);
	SQL_TQuery(db, SQLQueryUnusualField, "select * from unusual;", DBPrio_High);
	SQL_TQuery(db, SQLQueryPaintField, "select * from paint;", DBPrio_High);
}

public OnConfigsExecuted()
{
	if(FileExists(test)) DeleteFile(test);
	
	new HTTPRequestHandle:Rekest3 = Steam_CreateHTTPRequest(HTTPMethod_GET, "https://api.steampowered.com/IEconItems_440/GetStoreStatus/v1/");
	Steam_SetHTTPRequestGetOrPostParameter(Rekest3, "key", "3A87ED6B2826B78073B23F143CF5EA66");
	Steam_SetHTTPRequestGetOrPostParameter(Rekest3, "format", "vdf");
	Steam_SendHTTPRequest(Rekest3, OnSteamAPI3);
}

public OnSteamAPI3(HTTPRequestHandle:request, bool:successful, HTTPStatusCode:statusCode) 
{
	if(!successful || statusCode != HTTPStatusCode_OK) 
	{
		if(successful && (_:statusCode < 500 || _:statusCode >= 600)) 
			LogError("Steam API error. Request %s, status code %d.", successful ? "successful" : "unsuccessful", _:statusCode);

		Steam_ReleaseHTTPRequest(request);
		return;
	}
	Steam_WriteHTTPResponseBody(request, test);
	Steam_ReleaseHTTPRequest(request);
	
	new Handle:DB = CreateKeyValues("status");
	FileToKeyValues(DB, test);
	on = KvGetNum(DB, "status", 0);
	CloseHandle(DB);
}

public OnClientPostAdminCheck(client)
{
	if(on == 1 && !IsFakeClient(client))
	{
		Reset(client);
		
		new String:SteamID[64], String:query[256];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
		
		Format(query, 256, "select * from user_slot where steamid = '%s';", SteamID);
		SQL_TQuery(db, SQLQuerySlot, query, client, DBPrio_High);
		
		Format(query, 256, "select * from unusual where steamid = '%s';", SteamID);
		SQL_TQuery(db, SQLQueryUunsual, query, client, DBPrio_High);
		
		Format(query, 256, "select * from paint where steamid = '%s';", SteamID);
		SQL_TQuery(db, SQLQueryPaint, query, client, DBPrio_High);
	}
}


public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(on == 1 && RandomItem[client])
	{
		new Handle:DB = CreateKeyValues("Item");
		
		FileToKeyValues(DB, Cvar_Item);
		
		decl String:indexd[32];
		
		if(KvGotoFirstSubKey(DB))
		{
			do
			{
				KvGetSectionName(DB, indexd, sizeof(indexd));
				PushArrayCell(ItemArray[client], StringToInt(indexd));
			}
			while(KvGotoNextKey(DB));
			
			KvGoBack(DB);
		}
		KvRewind(DB);
	
		new slot, slot2, slot3;
		
		for(new i = 0; i < GetArraySize(ItemArray[client]); i++) 
		{
			slot = GetArrayCell(ItemArray[client], GetRandomInt(0, i));
			slot2 = GetArrayCell(ItemArray[client], GetRandomInt(0, i));
			slot3 = GetArrayCell(ItemArray[client], GetRandomInt(0, i));
		}
		
		Item[client][WearableSlot][TF2_GetPlayerClass(client)] = slot;
		Item[client][WearableSlot2][TF2_GetPlayerClass(client)] = slot2;
		Item[client][WearableSlot3][TF2_GetPlayerClass(client)] = slot3;
		
		decl String:SteamID[64];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
		
		Item_Update(client, SteamID);
		
		TF2_RemoveAllWeapons(client);
		TF2_RemoveAllWearables(client);
		ChangePlayerWeaponSlot(client, 0);
		CreateTimer(0.2, Timer_Regenerate, client);
		CloseHandle(DB);
	}
}

public Action:inventory(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(on != 1) return Plugin_Continue;
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	ItemCount[client] = 0;
	return Plugin_Continue;
}

public Action:ResetCommand(client, args)
{
	if(on != 1)
	{
		PrintToChat(client, "플러그인 유효기간이 지났습니다.");
		return Plugin_Handled;
	}
	
	Item[client][WearableSlot][TF2_GetPlayerClass(client)] = 0;
	Item[client][WearableSlot2][TF2_GetPlayerClass(client)] = 0;
	Item[client][WearableSlot3][TF2_GetPlayerClass(client)] = 0;
	for(new i = 0; i <= 5; i++) Attribute[client][i][TF2_GetPlayerClass(client)] = 0.0;
	
	if(RandomItem[client])
	{
		if(ItemArray[client] != INVALID_HANDLE) CloseHandle(ItemArray[client]);
		RandomItem[client] = false;
	}
	
	TF2_RemoveAllWeapons(client);
	TF2_RemoveAllWearables(client);
		
	CreateTimer(0.2, Timer_Regenerate, client);
	return Plugin_Handled;
}

public Action:RandomCommand(client, args)
{
	if(on != 1)
	{
		PrintToChat(client, "플러그인 유효기간이 지났습니다.");
		return Plugin_Handled;
	}
	
	if(!RandomItem[client])
	{
		ItemArray[client] = CreateArray(64, 0);
		PrintToChat(client, "\x07FFFFFF이제부터 리스폰시 랜덤룩이 적용됩니다.");
		RandomItem[client] = true;
	}
	else
	{
		if(ItemArray[client] != INVALID_HANDLE) CloseHandle(ItemArray[client]);
		PrintToChat(client, "\x07FFFF랜덤룩 적용이 해제되었씁니다.");
		RandomItem[client] = false;
	}
	return Plugin_Handled;
}

public Action:ItemCommand(client, args)
{
	if(on != 1)
	{
		PrintToChat(client, "플러그인 유효기간이 지났습니다.");
		return Plugin_Handled;
	}
	new String:Num[10], String:Search[64];
	GetCmdArg(1, Num, sizeof(Num));
	GetCmdArgString(Search, sizeof(Search));
	ItemMenu(client, 0, Search);
	return Plugin_Handled;
}

public Action:UnusualCommand(client, args)
{
	if(on != 1)
	{
		PrintToChat(client, "플러그인 유효기간이 지났습니다.");
		return Plugin_Handled;
	}
	new String:Num[10], String:Search[64];
	GetCmdArg(1, Num, sizeof(Num));
	GetCmdArgString(Search, sizeof(Search));
	ItemMenu(client, 1, Search);
	return Plugin_Handled;
}

public Action:PaintCommand(client, args)
{
	if(on != 1)
	{
		PrintToChat(client, "플러그인 유효기간이 지났습니다.");
		return Plugin_Handled;
	}
	new String:Num[10], String:Search[64];
	GetCmdArg(1, Num, sizeof(Num));
	GetCmdArgString(Search, sizeof(Search));
	ItemMenu(client, 2, Search);
	return Plugin_Handled;
}

stock ItemMenu(client, num, String:Search[])
{
	new SearchValue, Handle:DB, String:temp[32];
	
	if(num == 0) DB =CreateKeyValues("item");
	else if(num == 1) DB =CreateKeyValues("unusual");
	else if(num == 2) DB =CreateKeyValues("paint");
	
	new Handle:menu = CreateMenu(Item_Select);
	
	decl String:ItemIndex[64], String:ItemName[64];
	
	SetMenuTitle(menu, "착용할 아이템을 고르세요.", client);
	if(num == 0) AddMenuItem(menu, "1", "!item <검색> 할 수 있음", ITEMDRAW_DISABLED);
	else if(num == 1) AddMenuItem(menu, "1", "!item 1 <검색> 할 수 있음", ITEMDRAW_DISABLED);
	else if(num == 2) AddMenuItem(menu, "1", "!item 2 <검색> 할 수 있음", ITEMDRAW_DISABLED);
	
	if(num == 0) FileToKeyValues(DB, Cvar_Item);
	else if(num == 1) FileToKeyValues(DB, Cvar_Unusual);
	else if(num == 2) FileToKeyValues(DB, Cvar_Paint);
	
	if(KvGotoFirstSubKey(DB))
	{
		do
		{
			if(num == 0)
			{
				KvGetSectionName(DB, ItemIndex, sizeof(ItemIndex));
				KvGetString(DB, "name", ItemName, sizeof(ItemName));
				
				Format(temp, sizeof(temp), "item_%d", StringToInt(ItemIndex));

				if(StrContains(ItemName, Search, false) > -1)
				{
					AddMenuItem(menu, temp, ItemName);
					SearchValue++;
				}
			}
			else
			{
				KvGetSectionName(DB, ItemName, sizeof(ItemName));
				new index = KvGetNum(DB, "index");
				
				if(num == 1) Format(temp, sizeof(temp), "unusual_%d", index);
				else if(num == 2) Format(temp, sizeof(temp), "paint_%d", index);
				
				if(StrContains(ItemName, Search, false) > -1)
				{
					AddMenuItem(menu, temp, ItemName);
					SearchValue++;
				}
			}
		}
		while(KvGotoNextKey(DB));
		
		KvGoBack(DB);
	}
	
	if(!SearchValue) PrintToChat(client, "\x03이름이 잘못되었거나 없는 이름입니다.");
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	KvRewind(DB);
	CloseHandle(DB); 
}

public Item_Select(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:info[32], String:aa[2][32];
		GetMenuItem(menu, select, info, sizeof(info));		
		ExplodeString(info, "_", aa, 2, 32);	
		
		if(StrEqual(aa[0], "item")) ItemSlot(client, 0, StringToInt(aa[1]));
		else if(StrEqual(aa[0], "unusual")) ItemSlot(client, 1, StringToInt(aa[1]));
		else if(StrEqual(aa[0], "paint")) ItemSlot(client, 2, StringToInt(aa[1]));
	}
	else if(action == MenuAction_End) CloseHandle(menu);
}
public ItemSlot(client, num, index)
{
	new Handle:info = CreateMenu(EquipItemSelect);
	SetMenuTitle(info, "아이템 슬롯을 고르세요.");
	
	new String:temp[32];
	Format(temp, sizeof(temp), "%d_%d", num, index)
	
	AddMenuItem(info, temp, "첫번째 로드아웃 슬롯");  
	AddMenuItem(info, temp, "두번째 로드아웃 슬롯");  
	AddMenuItem(info, temp, "세번째 로드아웃 슬롯");  
	SetMenuExitButton(info, true);
	DisplayMenu(info, client, MENU_TIME_FOREVER);
} 

public EquipItemSelect(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
		decl String:info[12], String:aa[2][12];
		GetMenuItem(menu, select, info, sizeof(info));		
		ExplodeString(info, "_", aa, 2, 12);	 
		
		new type = StringToInt(aa[0]);
		new index = StringToInt(aa[1]);
		new Float:findex = StringToFloat(aa[1]);
		
		if(select == 0)
		{
			if(type == 0) Item[client][WearableSlot][TF2_GetPlayerClass(client)] = index;
			else if(type == 1) Attribute[client][UnusualSlot][TF2_GetPlayerClass(client)] = findex;
			else if(type == 2) Attribute[client][PaintSlot] [TF2_GetPlayerClass(client)]= findex;
		}
		else if(select == 1)
		{
			if(type == 0) Item[client][WearableSlot2][TF2_GetPlayerClass(client)] = index;
			else if(type == 1) Attribute[client][UnusualSlot2][TF2_GetPlayerClass(client)] = findex;
			else if(type == 2) Attribute[client][PaintSlot2] [TF2_GetPlayerClass(client)]= findex;
		}
		else if(select == 2)
		{
			if(type == 0) Item[client][WearableSlot3][TF2_GetPlayerClass(client)] = index;
			else if(type == 1) Attribute[client][UnusualSlot3][TF2_GetPlayerClass(client)] = findex;
			else if(type == 2) Attribute[client][PaintSlot3] [TF2_GetPlayerClass(client)]= findex;
		}
		
		decl String:SteamID[64];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
		
		Item_Update(client, SteamID);
		
		TF2_RemoveAllWeapons(client);
		TF2_RemoveAllWearables(client);
		
		CreateTimer(0.2, Timer_Regenerate, client);
	}	
	else if(action == MenuAction_End) CloseHandle(menu);
}


public Action:TF2Items_OnGiveNamedItem(client, String:szClassName[], index, &Handle:hItem)
{
	if (on != 1) return Plugin_Continue;
	if (!StrEqual(szClassName, "tf_wearable")) return Plugin_Continue;
	if (ItemCount[client] >= 3) return Plugin_Continue;
	if (index == 133 || index == 57 || index == 444 || index == 405 
		|| index == 996 || index == 231 || index == 642) return Plugin_Continue;
	
	Item[client][ItemCount[client]][TF2_GetPlayerClass(client)] = index;
	ItemCount[client]++;

	if(index == Item[client][MyWearableSlot][TF2_GetPlayerClass(client)])
	{
		if(Item[client][WearableSlot][TF2_GetPlayerClass(client)] != 0)
		{
			hItem = OnGive(hItem, Item[client][WearableSlot][TF2_GetPlayerClass(client)], Attribute[client][UnusualSlot][TF2_GetPlayerClass(client)], Attribute[client][PaintSlot][TF2_GetPlayerClass(client)], OVERRIDE_ITEM_DEF|OVERRIDE_ATTRIBUTES);
			return Plugin_Changed;
		}
		else Item[client][WearableSlot][TF2_GetPlayerClass(client)] = Item[client][MyWearableSlot][TF2_GetPlayerClass(client)];
	}
		
	if(index == Item[client][MyWearableSlot2][TF2_GetPlayerClass(client)])
	{
		if(Item[client][WearableSlot2][TF2_GetPlayerClass(client)] != 0)
		{
			hItem = OnGive(hItem, Item[client][WearableSlot2][TF2_GetPlayerClass(client)], Attribute[client][UnusualSlot2][TF2_GetPlayerClass(client)], Attribute[client][PaintSlot2][TF2_GetPlayerClass(client)], OVERRIDE_ITEM_DEF|OVERRIDE_ATTRIBUTES);
			return Plugin_Changed;
		}
		else Item[client][WearableSlot2][TF2_GetPlayerClass(client)] = Item[client][MyWearableSlot2][TF2_GetPlayerClass(client)];
	}
	
	if(index == Item[client][MyWearableSlot3][TF2_GetPlayerClass(client)])
	{
		if(Item[client][WearableSlot3][TF2_GetPlayerClass(client)] != 0)
		{
			hItem = OnGive(hItem, Item[client][WearableSlot3][TF2_GetPlayerClass(client)], Attribute[client][UnusualSlot3][TF2_GetPlayerClass(client)], Attribute[client][PaintSlot3][TF2_GetPlayerClass(client)], OVERRIDE_ITEM_DEF|OVERRIDE_ATTRIBUTES);
			return Plugin_Changed;
		}
		else Item[client][WearableSlot3][TF2_GetPlayerClass(client)] = Item[client][MyWearableSlot3][TF2_GetPlayerClass(client)];
	}
	return Plugin_Continue;
}

public SQLQuerySlot(Handle:owner, Handle:hndl, const String:error[], any:client) 
{
	if(!IsClientInGame(client)) return;
	if(hndl==INVALID_HANDLE) LogError("Query failed: %s", error);
	else if(SQL_GetRowCount(hndl))
	{
		new counted = SQL_GetRowCount(hndl);
		if(counted > 0)
		{
			if(SQL_HasResultSet(hndl))
			{
				while(SQL_FetchRow(hndl))
				{
					new a = -1, b = 0, c = 1;
					for(new i = 1; i <= 9; i++)
					{
						a = a + 3; b = b + 3; c = c + 3;
						
						Item[client][WearableSlot][i] = SQL_FetchInt(hndl, a);
						Item[client][WearableSlot2][i] = SQL_FetchInt(hndl, b);
						Item[client][WearableSlot3][i] = SQL_FetchInt(hndl, c);
					}
				}
			}
		}
	}
	else
	{
		decl String:old_name[MAX_NAME_LENGTH], String:new_name[(MAX_NAME_LENGTH*2)+1], String:SteamID[64], String:query[256];
        
		GetClientName(client, old_name, sizeof(old_name));
		SQL_EscapeString(db, old_name, new_name, sizeof(new_name));
		
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
		
		Format(query, 256, "insert into user_slot (steamid, name) VALUES ('%s', '%s');", SteamID, new_name);
		SQL_TQuery(db, SQLErrorCallback, query);
	}
}

public SQLQueryUunsual(Handle:owner, Handle:hndl, const String:error[], any:client) 
{
	if(!IsClientInGame(client)) return;
	if(hndl==INVALID_HANDLE) LogError("Query failed: %s", error);
	else if(SQL_GetRowCount(hndl))
	{
		new counted = SQL_GetRowCount(hndl);
		if(counted > 0)
		{
			if(SQL_HasResultSet(hndl))
			{
				while(SQL_FetchRow(hndl))
				{	
					new a = -1, b = 0, c = 1;
					for(new i = 1; i <= 9; i++)
					{
						a = a + 3; b = b + 3; c = c + 3;
						
						Attribute[client][UnusualSlot][i] = SQL_FetchFloat(hndl, a);
						Attribute[client][UnusualSlot2][i] = SQL_FetchFloat(hndl, b);
						Attribute[client][UnusualSlot3][i] = SQL_FetchFloat(hndl, c);
					}
				}
			}
		}
	}
	else
	{
		decl String:old_name[MAX_NAME_LENGTH], String:new_name[(MAX_NAME_LENGTH*2)+1], String:SteamID[64], String:query[256];
        
		GetClientName(client, old_name, sizeof(old_name));
		SQL_EscapeString(db, old_name, new_name, sizeof(new_name));
		
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
		
		Format(query, 256, "insert into unusual (steamid, name) VALUES ('%s', '%s');", SteamID, new_name);
		SQL_TQuery(db, SQLErrorCallback, query);
	}
}

public SQLQueryPaint(Handle:owner, Handle:hndl, const String:error[], any:client) 
{
	if(!IsClientInGame(client)) return;
	if(hndl==INVALID_HANDLE) LogError("Query failed: %s", error);
	else if(SQL_GetRowCount(hndl))
	{
		new counted = SQL_GetRowCount(hndl);
		if(counted > 0)
		{
			if(SQL_HasResultSet(hndl))
			{
				while(SQL_FetchRow(hndl))
				{
					new a = -1, b = 0, c = 1;
					for(new i = 1; i <= 9; i++)
					{
						a = a + 3; b = b + 3; c = c + 3;
						
						Attribute[client][PaintSlot][i] = SQL_FetchFloat(hndl, a);
						Attribute[client][PaintSlot2][i] = SQL_FetchFloat(hndl, b);
						Attribute[client][PaintSlot3][i] = SQL_FetchFloat(hndl, c);
					}
				}
			}
		}
	}
	else
	{
		decl String:old_name[MAX_NAME_LENGTH], String:new_name[(MAX_NAME_LENGTH*2)+1], String:SteamID[64], String:query[256];
        
		GetClientName(client, old_name, sizeof(old_name));
		SQL_EscapeString(db, old_name, new_name, sizeof(new_name));
		
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
		
		Format(query, 256, "insert into paint (steamid, name) VALUES ('%s', '%s');", SteamID, new_name);
		SQL_TQuery(db, SQLErrorCallback, query);
	}
}

stock Item_Update(client, String:SteamID[])
{
	for(new i = 1; i <= 9; i++)
	{
	
		decl String:old_name[MAX_NAME_LENGTH], String:new_name[(MAX_NAME_LENGTH*2)+1];
		GetClientName(client, old_name, sizeof(old_name));
		SQL_EscapeString(db, old_name, new_name, sizeof(new_name));
		
		new String:query[256];
		Format(query, sizeof(query), "UPDATE user_slot SET %d_slot = %d, name = '%s' WHERE steamid= '%s';", i, Item[client][WearableSlot][i], new_name, SteamID);
		SQL_TQuery(db, SQLErrorCallback, query);
			
		Format(query, sizeof(query), "UPDATE user_slot SET %d_slot2 = %d, name = '%s' WHERE steamid= '%s';", i, Item[client][WearableSlot2][i], new_name, SteamID);
		SQL_TQuery(db, SQLErrorCallback, query);
			
		Format(query, sizeof(query), "UPDATE user_slot SET %d_slot3 = %d, name = '%s' WHERE steamid= '%s';", i, Item[client][WearableSlot3][i], new_name, SteamID);
		SQL_TQuery(db, SQLErrorCallback, query);
			
			
		Format(query, sizeof(query), "UPDATE unusual SET %d_slot = %.1f, name = '%s' WHERE steamid= '%s'", i, Attribute[client][UnusualSlot][i], new_name, SteamID);
		SQL_TQuery(db, SQLErrorCallback, query);
			
		Format(query, sizeof(query), "UPDATE unusual SET %d_slot2 = %.1f, name = '%s' WHERE steamid= '%s'", i, Attribute[client][UnusualSlot2][i], new_name, SteamID);
		SQL_TQuery(db, SQLErrorCallback, query);
			
		Format(query, sizeof(query), "UPDATE unusual SET %d_slot3 = %.1f, name = '%s' WHERE steamid= '%s'", i, Attribute[client][UnusualSlot3][i], new_name, SteamID);
		SQL_TQuery(db, SQLErrorCallback, query);
			
			
		Format(query, sizeof(query), "UPDATE paint SET %d_slot = %.1f, name = '%s' WHERE steamid= '%s'", i, Attribute[client][PaintSlot][i], new_name, SteamID);
		SQL_TQuery(db, SQLErrorCallback, query);
			
		Format(query, sizeof(query), "UPDATE paint SET %d_slot2 = %.1f, name = '%s' WHERE steamid= '%s'", i, Attribute[client][PaintSlot2][i], new_name, SteamID);
		SQL_TQuery(db, SQLErrorCallback, query);
			
		Format(query, sizeof(query), "UPDATE paint SET %d_slot3 = %.1f, name = '%s' WHERE steamid= '%s'", i, Attribute[client][PaintSlot3][i], new_name, SteamID);
		SQL_TQuery(db, SQLErrorCallback, query);
	}
}

public SQLQuerySlotField(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	if(hndl==INVALID_HANDLE) LogError("Query failed: %s", error);
	
	decl field;
	if(!SQL_FieldNameToNum(hndl, "1_slot", field)) 
	{
		for(new i = 1; i <= 9; i++)
		{
			new String:temp[256];
			Format(temp, 256, "ALTER TABLE user_slot ADD %d_slot BIGINT NULL DEFAULT '-1'", i);
			SQL_TQuery(db, SQLErrorCallback, temp);
			
			Format(temp, 256, "ALTER TABLE user_slot ADD %d_slot2 BIGINT NULL DEFAULT '-1'", i);
			SQL_TQuery(db, SQLErrorCallback, temp);
			
			Format(temp, 256, "ALTER TABLE user_slot ADD %d_slot3 BIGINT NULL DEFAULT '-1'", i);
			SQL_TQuery(db, SQLErrorCallback, temp);
		}
	}
}

public SQLQueryUnusualField(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	if(hndl==INVALID_HANDLE) LogError("Query failed: %s", error);
	
	decl field;
	if(!SQL_FieldNameToNum(hndl, "1_slot", field)) 
	{
		for(new i = 1; i <= 9; i++)
		{
			new String:temp[256];
			Format(temp, 256, "ALTER TABLE unusual ADD %d_slot float NULL DEFAULT '0.0'", i);
			SQL_TQuery(db, SQLErrorCallback, temp);
			
			Format(temp, 256, "ALTER TABLE unusual ADD %d_slot2 float NULL DEFAULT '0.0'", i);
			SQL_TQuery(db, SQLErrorCallback, temp);
			
			Format(temp, 256, "ALTER TABLE unusual ADD %d_slot3 float NULL DEFAULT '0.0'", i);
			SQL_TQuery(db, SQLErrorCallback, temp);
		}
	}
}

public SQLQueryPaintField(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	if(hndl==INVALID_HANDLE) LogError("Query failed: %s", error);
	
	decl field;
	if(!SQL_FieldNameToNum(hndl, "1_slot", field)) 
	{
		for(new i = 1; i <= 9; i++)
		{
			new String:temp[256];
			Format(temp, 256, "ALTER TABLE paint ADD %d_slot float NULL DEFAULT '0.0'", i);
			SQL_TQuery(db, SQLErrorCallback, temp);
			
			Format(temp, 256, "ALTER TABLE paint ADD %d_slot2 float NULL DEFAULT '0.0'", i);
			SQL_TQuery(db, SQLErrorCallback, temp);
			
			Format(temp, 256, "ALTER TABLE paint ADD %d_slot3 float NULL DEFAULT '0.0'", i);
			SQL_TQuery(db, SQLErrorCallback, temp);
		}
	}
}


public SQLErrorCallback(Handle:owner, Handle:hndl, const String:error[], any:data)
{
    if(!StrEqual("", error)) LogError("Query failed: %s", error);
    return false;
}


stock Reset(client)
{
	for(new i = 0; i <= 9; i++)
	{
		Item[client][WearableSlot][i] = 0;
		Item[client][WearableSlot2][i] = 0;
		Item[client][WearableSlot3][i] = 0;
	}
	for(new i = 0; i <= 5; i++) for(new j = 0; j <= 9; j++) Attribute[client][i][j] = 0.0;
	
	if(RandomItem[client])
	{
		if(ItemArray[client] != INVALID_HANDLE) CloseHandle(ItemArray[client]);
		RandomItem[client] = false;
	}
}

stock Handle:OnGive(Handle:hItem, index = 0, Float:unusual = 0.0, Float:paint = 0.0, flags)
{
	hItem = TF2Items_CreateItem(flags);
	
	if (index != 0) TF2Items_SetItemIndex(hItem, index);
	
	if (unusual != 0.0)
	{	
		TF2Items_SetNumAttributes(hItem, 1);
		TF2Items_SetAttribute(hItem, 0, 134, unusual);
	}
	if (paint != -0.0)
	{
		TF2Items_SetNumAttributes(hItem, TF2Items_GetNumAttributes(hItem) + 1); //수정
		if(paint <= 5.0 && paint >= 0.0)
		{
			TF2Items_SetAttribute(hItem, TF2Items_GetNumAttributes(hItem) - 1, 1004, paint);
		}
		else
		{
			TF2Items_SetAttribute(hItem, TF2Items_GetNumAttributes(hItem) - 1, 261, paint);
			TF2Items_SetAttribute(hItem, TF2Items_GetNumAttributes(hItem) - 1, 142, paint);
		}
	}
	TF2Items_SetFlags(hItem, flags);
	CloneHandle(hItem);
	return hItem;
}

public Action:Timer_Regenerate(Handle:timer, any:client)
{
	if(AliveCheck(client))
	{
		if(!RandomItem[client])
		{
			decl Float:pos[3];
			GetClientAbsOrigin(client, pos);
			TF2_RespawnPlayer(client);
			TeleportEntity(client, pos, NULL_VECTOR, NULL_VECTOR);
		}
		else
		{
			TF2_RegeneratePlayer(client);
			ChangePlayerWeaponSlot(client, 0);
		}
	}
}

stock TF2_RemoveAllWearables(client)
{
	RemoveWearable(client, "tf_wearable", "CTFWearable");
	RemoveWearable(client, "tf_powerup_bottle", "CTFPowerupBottle");
}

stock RemoveWearable(client, String:classname[], String:networkclass[])
{
	if (AliveCheck(client))
	{
		new edict = MaxClients+1;
		while((edict = FindEntityByClassname2(edict, classname)) != -1)
		{
			decl String:netclass[32];
			if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, networkclass))
				if (GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client) AcceptEntityInput(edict, "Kill"); 
		}
	}
}

stock bool:ChangePlayerWeaponSlot(iClient, iSlot) {
    new iWeapon = GetPlayerWeaponSlot(iClient, iSlot);
    if (iWeapon > MaxClients) {
        SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", iWeapon);
        return true;
    }

    return false;
}

stock FindEntityByClassname2(startEnt, const String:classname[])
{
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
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
//http://steamcommunity.com/dev/apikey

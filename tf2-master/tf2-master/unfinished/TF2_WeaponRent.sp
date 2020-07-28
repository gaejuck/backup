#include <tf2items>
#include <tf2_stocks>

public Plugin:myinfo =
{
	name = "Tf2 Weapon Rent",
	author = "ㅣ",
	description = "무기를 대여합니다.",
	version = "1.2",
	url = "http://steamcommunity.com/id/Error_Error_Error_Error/"
}

new Handle:Class = INVALID_HANDLE;
new Handle:menu_hide = INVALID_HANDLE;
new Handle:number = INVALID_HANDLE;

new String:PrimaryConfig[120];
new String:SecondaryConfig[120];
new String:MeleeConfig[120]; 

new Handle:P_menu[MAXPLAYERS+1];
new Handle:S_menu[MAXPLAYERS+1];
new Handle:M_menu[MAXPLAYERS+1];

new bool:P_menu_Check[MAXPLAYERS+1];
new bool:S_menu_Check[MAXPLAYERS+1];
new bool:M_menu_Check[MAXPLAYERS+1];

new limit[MAXPLAYERS+1] = 0;

new search[MAXPLAYERS+1][3];

public OnPluginStart()
{
	BuildPath(Path_SM, PrimaryConfig, sizeof(PrimaryConfig), "configs/weapon_rent/Primary_weapon.cfg");
	BuildPath(Path_SM, SecondaryConfig, sizeof(SecondaryConfig), "configs/weapon_rent/Secondary_weapon.cfg");
	BuildPath(Path_SM, MeleeConfig, sizeof(MeleeConfig), "configs/weapon_rent/Melee_weapon.cfg");

	RegConsoleCmd("sm_weapon", weaponmenu, "컨픽에 적은 무기들을 메뉴로 꺼내 볼 수 있는 명령어입니다.");
	RegConsoleCmd("sm_we", cccc, "채팅이나 콘솔로 빠르게 무기를 만들어 볼 수 있는 명령어 입니다.");
	
	Class = CreateConVar("sm_weapon_class", "1", "컨픽에 적은 각 클래스에 맞는 무기로 쓸 것인가? 1 / 0");
	menu_hide = CreateConVar("sm_weapon_menu", "1", "무기를 선택후 메뉴창이 뜰 것인가? 1 / 0");
	number = CreateConVar("sm_weapon_limit", "3", "무기 제한 설정");
	
	HookEvent("player_death", OnPlayerDeath);
	HookEvent("player_spawn", OnPlayerDeath);
	
	HookEvent("player_changeclass", player_changeclass);
	
	RegConsoleCmd("sm_psweapon", psearch);
	RegConsoleCmd("sm_ssweapon", ssearch);
	RegConsoleCmd("sm_msweapon", msearch);
	
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_Say);
}

public Action:psearch(client, args)
{
	if(client == 0) return Plugin_Continue;
	PrintToChat(client, "\x03채팅창에 무기 이름 일부를 입력하세요.");
	search[client][0] = true;
	return Plugin_Continue;
}

public Action:ssearch(client, args)
{
	if(client == 0) return Plugin_Continue;
	PrintToChat(client, "\x03채팅창에 무기 이름 일부를 입력하세요.");
	search[client][1] = true;
	return Plugin_Continue;
}

public Action:msearch(client, args)
{
	if(client == 0) return Plugin_Continue;
	PrintToChat(client, "\x03채팅창에 무기 이름 일부를 입력하세요.");
	search[client][2] = true;
	return Plugin_Continue;
}

public Action:Command_Say(client, args)
{
	decl String:CurrentChat[128];
	if(GetCmdArgString(CurrentChat, sizeof(CurrentChat)) < 1 || (client == 0) || IsChatTrigger()) return Plugin_Continue;

	if(search[client][0]) {
		FakeClientCommand(client, "sm_psweapon %s", CurrentChat);
		search[client][0] = false;
		return Plugin_Handled;
	}
	else if(search[client][1]) {
		FakeClientCommand(client, "sm_ssweapon %s", CurrentChat);
		search[client][1] = false;
		return Plugin_Handled;
	}
	else if(search[client][2]) {
		FakeClientCommand(client, "sm_msweapon %s", CurrentChat);
		search[client][2] = false;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public OnClientDisconnected(client)
{
	limit[client] = 0;
	
	if(P_menu_Check[client] == true)
	{
		if(P_menu[client] != INVALID_HANDLE)
		{
			CancelMenu(P_menu[client]);
			P_menu[client] = INVALID_HANDLE;
		}
		P_menu_Check[client] = false;
	}
	
	if(S_menu_Check[client] == true)
	{
		if(S_menu[client] != INVALID_HANDLE)
		{
			CancelMenu(S_menu[client]);
			S_menu[client] = INVALID_HANDLE;
		}
		S_menu_Check[client] = false;
	}
	
	if(M_menu_Check[client] == true)
	{
		if(M_menu[client] != INVALID_HANDLE)
		{
			CancelMenu(M_menu[client]);
			M_menu[client] = INVALID_HANDLE;
		}
		M_menu_Check[client] = false;
	}
}

public Action:weaponmenu(client, args)
{
	weapon_menu(client);
	return Plugin_Handled;
}
public weapon_menu(client)
{
	new Handle:Main_menu;
	Main_menu = CreateMenu(Menu_Information);
	SetMenuTitle(Main_menu, "고르삼");
	AddMenuItem(Main_menu, "1", "주무기");  
	AddMenuItem(Main_menu, "2", "보조무기");
	AddMenuItem(Main_menu, "3", "근접무기");
	SetMenuExitButton(Main_menu, true);

	DisplayMenu(Main_menu, client, MENU_TIME_FOREVER);
}

public Menu_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
		if(select == 0)
			PrimaryWeapon(client, 0);
		else if(select == 1)
			SecondaryWeapon(client, 0);
		else if(select == 2)
			MeleeWeapon(client, 0);
	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_Exit)
		{
			CloseHandle(menu);
		}
	} 
}

//주무기

public Action:PrimaryWeapon(client, args)
{
	decl String:Classname[64], String:Attribute[256], String:name[50], String:class[64];
	new String:temp[256];
	
	if(args == 1)
	{
		new String:SearchWord[16], SearchValue;
		GetCmdArgString(SearchWord, sizeof(SearchWord));
		
		P_menu[client] = CreateMenu(Primary_weapon_select);
		new Handle:DB = CreateKeyValues("custom_weapon"); 
		
		SetMenuTitle(P_menu[client], "무기고르삼", client);
		AddMenuItem(P_menu[client], "검색", "검색");
		
		FileToKeyValues(DB, PrimaryConfig);
		if(KvGotoFirstSubKey(DB))
		{
			do
			{
				KvGetSectionName(DB, name, sizeof(name));
				KvGetString(DB, "classname", Classname, sizeof(Classname));
				KvGetString(DB, "attribute", Attribute, sizeof(Attribute));
				new Index = KvGetNum(DB, "index", 0);
				new Level = KvGetNum(DB, "level", 1);
				new Qual = KvGetNum(DB, "qual", 1);
				KvGetString(DB, "class", class, sizeof(class));
				
				Format(temp, sizeof(temp), "%s*%d*%d*%d*%s", Classname,  Index, Level, Qual, Attribute);
				
				
				if(GetConVarInt(Class) == 1)
				{
					if(StrContains(name, SearchWord, false) > -1)
					{
						class_menu(client, P_menu[client], temp, name, class);
						SearchValue++;
					}
				}
				else
				{
					if(StrContains(name, SearchWord, false) > -1)
					{
						AddMenuItem(P_menu[client], temp, name);
						SearchValue++;
					}
				}
			}
			while(KvGotoNextKey(DB));
			
			KvGoBack(DB);
		}
		
		DisplayMenu(P_menu[client], client, MENU_TIME_FOREVER);
		KvRewind(DB);
		CloseHandle(DB);
		
		P_menu_Check[client] = true;
	}
	else
	{
	
		P_menu[client] = CreateMenu(Primary_weapon_select);
		new Handle:DB = CreateKeyValues("custom_weapon"); 
		
		SetMenuTitle(P_menu[client], "무기고르삼", client);
		AddMenuItem(P_menu[client], "검색", "검색");
		
		FileToKeyValues(DB, PrimaryConfig);
		if(KvGotoFirstSubKey(DB))
		{
			do
			{
				KvGetSectionName(DB, name, sizeof(name));
				KvGetString(DB, "classname", Classname, sizeof(Classname));
				KvGetString(DB, "attribute", Attribute, sizeof(Attribute));
				new Index = KvGetNum(DB, "index", 0);
				new Level = KvGetNum(DB, "level", 1);
				new Qual = KvGetNum(DB, "qual", 1);
				KvGetString(DB, "class", class, sizeof(class));
				
				Format(temp, sizeof(temp), "%s*%d*%d*%d*%s", Classname,  Index, Level, Qual, Attribute);
				
				
				if(GetConVarInt(Class) == 1)
				{
					class_menu(client, P_menu[client], temp, name, class);
				}
				else
				{
					AddMenuItem(P_menu[client], temp, name);
				}
			}
			while(KvGotoNextKey(DB));
			
			KvGoBack(DB);
		}
		
		DisplayMenu(P_menu[client], client, MENU_TIME_FOREVER);
		KvRewind(DB);
		CloseHandle(DB);
		
		P_menu_Check[client] = true;
	}
	
	return Plugin_Handled;
}

public Primary_weapon_select(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:info[256], String:aa[6][256];
		GetMenuItem(menu, select, info, sizeof(info));
		
		if(StrEqual(info, "검색"))
			search[client][0] = true;
		if(limit[client] < GetConVarInt(number))
		{
			ExplodeString(info, "*", aa,6,256);

				
			SpawnWeapon(client, aa[0], 0, StringToInt(aa[1]), StringToInt(aa[2]),
			StringToInt(aa[3]), aa[4]);
				
			if(GetConVarInt(menu_hide) == 1)
					weapon_menu(client);
			limit[client]++;
			P_menu_Check[client] = false;
		}
		else
		{
			PrintToChat(client, "%d개 까지 가능함", GetConVarInt(number));
			P_menu_Check[client] = false;
		}
	}
	
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_Exit)
		{
			P_menu_Check[client] = false;
		}
		P_menu_Check[client] = false;
	}
	
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

//보조무기

public Action:SecondaryWeapon(client, args)
{
	decl String:Classname[64], String:Attribute[256], String:name[50], String:class[64];
	new String:temp[256];
	
	new String:SearchWord[16], SearchValue;
	GetCmdArgString(SearchWord, sizeof(SearchWord));
	
	S_menu[client] = CreateMenu(Secondary_weapon_select);
	new Handle:DB = CreateKeyValues("custom_weapon"); 
	
	
	SetMenuTitle(S_menu[client], "무기고르삼", client);
		
	FileToKeyValues(DB, SecondaryConfig);
	if(KvGotoFirstSubKey(DB))
	{
		do
		{
			KvGetSectionName(DB, name, sizeof(name));
			KvGetString(DB, "classname", Classname, sizeof(Classname));
			KvGetString(DB, "attribute", Attribute, sizeof(Attribute));
			new Index = KvGetNum(DB, "index", 0);
			new Level = KvGetNum(DB, "level", 1);
			new Qual = KvGetNum(DB, "qual", 1);
			KvGetString(DB, "class", class, sizeof(class));
			
			Format(temp, sizeof(temp), "%s*%d*%d*%d*%s", Classname,  Index, Level, Qual, Attribute);
			
			if(GetConVarInt(Class) == 1)
			{
				if(StrContains(name, SearchWord, false) > -1)
				{
					class_menu(client, S_menu[client], temp, name, class);
					SearchValue++;
				}
			}
			else
			{
				if(StrContains(name, SearchWord, false) > -1)
				{
					AddMenuItem(S_menu[client], temp, name);
					SearchValue++;
				}
			}
		}
		while(KvGotoNextKey(DB));
		
		KvGoBack(DB);
	}
	
	DisplayMenu(S_menu[client], client, MENU_TIME_FOREVER);
	KvRewind(DB);
	CloseHandle(DB);
	
	S_menu_Check[client] = true;
	return Plugin_Handled;
}

public Secondary_weapon_select(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:info[256], String:aa[6][256];
		GetMenuItem(menu, select, info, sizeof(info));
	
		if(limit[client] < GetConVarInt(number))
		{
			ExplodeString(info, "*", aa,6,256);

				
			SpawnWeapon(client, aa[0], 1, StringToInt(aa[1]), StringToInt(aa[2]),
			StringToInt(aa[3]), aa[4]);
				
			if(GetConVarInt(menu_hide) == 1)
					weapon_menu(client);
			limit[client]++;
			S_menu_Check[client] = false;
		}
		else
		{
			PrintToChat(client, "%d개 까지 가능함", GetConVarInt(number));
			S_menu_Check[client] = false;
		}	
	}
	
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_Exit)
		{
			S_menu_Check[client] = false;
		}
		S_menu_Check[client] = false;
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

//밀리무기

public Action:MeleeWeapon(client, args)
{
	decl String:Classname[64], String:Attribute[256], String:name[50], String:class[64];
	new String:temp[256];
	
	new String:SearchWord[16], SearchValue;
	GetCmdArgString(SearchWord, sizeof(SearchWord));
	
	M_menu[client] = CreateMenu(Melee_weapon_select);
	new Handle:DB = CreateKeyValues("custom_weapon"); 
	
	SetMenuTitle(M_menu[client], "무기고르삼", client);
		
	FileToKeyValues(DB, MeleeConfig);
	if(KvGotoFirstSubKey(DB))
	{
		do
		{
			KvGetSectionName(DB, name, sizeof(name));
			KvGetString(DB, "classname", Classname, sizeof(Classname));
			KvGetString(DB, "attribute", Attribute, sizeof(Attribute));
			new Index = KvGetNum(DB, "index", 0);
			new Level = KvGetNum(DB, "level", 1);
			new Qual = KvGetNum(DB, "qual", 1);
			KvGetString(DB, "class", class, sizeof(class));
			
			Format(temp, sizeof(temp), "%s*%d*%d*%d*%s", Classname,  Index, Level, Qual, Attribute);
			
			if(GetConVarInt(Class) == 1)
			{
				if(StrContains(name, SearchWord, false) > -1)
				{
					class_menu(client, M_menu[client], temp, name, class);
					SearchValue++;
				}
			}
			else
			{
				if(StrContains(name, SearchWord, false) > -1)
				{
					AddMenuItem(M_menu[client], temp, name);
					SearchValue++;
				}
			}
		}
		while(KvGotoNextKey(DB));
		
		KvGoBack(DB);
	}
	
	DisplayMenu(M_menu[client], client, MENU_TIME_FOREVER);
	KvRewind(DB);
	CloseHandle(DB);
	
	M_menu_Check[client] = true;
	
	return Plugin_Handled;
}

public Melee_weapon_select(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:info[256], String:aa[6][256];
		GetMenuItem(menu, select, info, sizeof(info));
		
		if(limit[client] < GetConVarInt(number))
		{
			ExplodeString(info, "*", aa,6,256);
			
			SpawnWeapon(client, aa[0], 2, StringToInt(aa[1]), StringToInt(aa[2]),
			StringToInt(aa[3]), aa[4]);
				
			if(GetConVarInt(menu_hide) == 1)
					weapon_menu(client);
			limit[client]++;
			
			M_menu_Check[client] = false;
		}
		else
		{
			PrintToChat(client, "%d개 까지 가능함", GetConVarInt(number));
			M_menu_Check[client] = false;
		}	
	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_Exit)
		{
			M_menu_Check[client] = false;
		}
		M_menu_Check[client] = false;
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:OnPlayerDeath(Handle:event, String:strEventName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	limit[client] = 0;
}

public Action:player_changeclass(Handle:event, String:strEventName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(P_menu_Check[client] == true)
	{
		if(P_menu[client] != INVALID_HANDLE)
		{
			CancelMenu(P_menu[client]);
			P_menu[client] = INVALID_HANDLE;
		}
	}
	
	if(S_menu_Check[client] == true)
	{
		if(S_menu[client] != INVALID_HANDLE)
		{
			CancelMenu(S_menu[client]);
			S_menu[client] = INVALID_HANDLE;
		}
	}
	
	if(M_menu_Check[client] == true)
	{
		if(M_menu[client] != INVALID_HANDLE)
		{
			CancelMenu(M_menu[client]);
			M_menu[client] = INVALID_HANDLE;
		}
	}
}

public Action:cccc(client, args)
{
	if (args < 6)
	{
		ReplyToCommand(client, "classname, index, slot,level, qual, att");
		return Plugin_Handled;
	}
	new String:classname[192];
	new String:index[64];
	new String:slot[12];
	new String:level[64];
	new String:qual[64];
	new String:att[128];
	new String:explodeStr[16][64];
	
	GetCmdArg(1, classname, sizeof(classname));
	GetCmdArg(2, index, sizeof(index));
	GetCmdArg(3, slot, sizeof(slot));
	GetCmdArg(4, level, sizeof(level));
	GetCmdArg(5, qual, sizeof(qual));
	
	new Handle:newItem = TF2Items_CreateItem(OVERRIDE_ALL);
	new Flags = OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL | OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES;
		
	if (strcmp(classname, "saxxy", false) != 0) Flags |= FORCE_GENERATION;	
	
	TF2Items_SetClassname(newItem, classname);
	TF2Items_SetItemIndex(newItem, StringToInt(index));
	TF2Items_SetLevel(newItem, StringToInt(level));
	TF2Items_SetQuality(newItem, StringToInt(qual));
	TF2Items_SetFlags(newItem, Flags);
		
	new NumAttribs = args - 5;
	for (new i = 0; i < NumAttribs; i ++)
	{
		GetCmdArg(i+6, att, sizeof(att));
		ExplodeString(att, ";", explodeStr, 2, 64);
		
		new iAttributeIndex = StringToInt(explodeStr[0]);
		new Float:fAttributeValue = StringToFloat(explodeStr[1]);
		//apply
		TF2Items_SetAttribute(newItem, i, iAttributeIndex, fAttributeValue);
	}
	if (NumAttribs != 0)
	{
		TF2Items_SetNumAttributes(newItem, NumAttribs);
	}
	TF2_RemoveWeaponSlot(client, StringToInt(slot));
	new entity = TF2Items_GiveNamedItem(client, newItem);
	EquipPlayerWeapon(client, entity);
	CloneHandle(newItem);
	return Plugin_Handled;
}


stock class_menu(client, Handle:cmenu, String:save[], String:wname[], String:wclass[])
{
	if(StrEqual(wclass, "스카웃", true))
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Scout)
				AddMenuItem(cmenu, save, wname);
				
	if(StrEqual(wclass, "솔저", true))
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Soldier)
			AddMenuItem(cmenu, save, wname);
						
	if(StrEqual(wclass, "파이로", true))
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Pyro)
			AddMenuItem(cmenu, save, wname);

	if(StrEqual(wclass, "데모맨", true))
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_DemoMan)
			AddMenuItem(cmenu, save, wname);
						
	if(StrEqual(wclass, "헤비", true))
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Heavy)
			AddMenuItem(cmenu, save, wname);
						
	if(StrEqual(wclass, "엔지니어", true))
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Engineer)
			AddMenuItem(cmenu, save, wname);
						
	if(StrEqual(wclass, "메딕", true))
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Medic)
			AddMenuItem(cmenu, save, wname);
						
	if(StrEqual(wclass, "스나이퍼", true))
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Sniper)
			AddMenuItem(cmenu, save, wname);
						
	if(StrEqual(wclass, "스파이", true))
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Spy)
			AddMenuItem(cmenu, save, wname);
						
	if(StrEqual(wclass, "공통", true))
		if(TF2_GetPlayerClass(client) != TFClassType:TFClass_Unknown)
			AddMenuItem(cmenu, save, wname);
}

stock SpawnWeapon(client,String:name[],slot,index,level,qual,String:att[])
{
	new Flags = OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL | OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES;
	
	new Handle:newItem = TF2Items_CreateItem(OVERRIDE_ALL);
	
	if (newItem == INVALID_HANDLE)
		return -1;
		
	TF2Items_SetClassname(newItem, name);
	
	if (strcmp(name, "saxxy", false) != 0) Flags |= FORCE_GENERATION;
		
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
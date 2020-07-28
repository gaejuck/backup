#include <tf2_stocks>
#include <tf2items>

new String:PrimaryConfig[120];

public Plugin:myinfo =
{
	name = "Tf2 Weapon Rent",
	author = "ㅣ",
	description = "무기를 대여합니다.",
	version = "2.0",
	url = ""
}


public OnPluginStart()
{
	BuildPath(Path_SM, PrimaryConfig, sizeof(PrimaryConfig), "configs/weapon.cfg");
	
	RegConsoleCmd("sm_weapon", WeaponMenu, "컨픽에 적은 무기들을 메뉴로 꺼내 볼 수 있는 명령어입니다.");
	RegConsoleCmd("sm_we", WeaponCommand, "채팅이나 콘솔로 빠르게 무기를 만들어 볼 수 있는 명령어 입니다.");
}


public Action:WeaponMenu(client, args)
{
	new String:SearchWord[16], SearchValue;
	GetCmdArgString(SearchWord, sizeof(SearchWord));

	decl String:Classname[64], String:Attribute[256], String:name[50];
	new String:temp[256];
	
	new Handle:menu = CreateMenu(Primary_weapon_select);
	new Handle:DB = CreateKeyValues("custom_weapon"); 
	
	SetMenuTitle(menu, "무기고르삼", client);
		
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
			new Slot = KvGetNum(DB, "slot", 0);
			
			Format(temp, sizeof(temp), "%s*%d*%d*%d*%s*%d", Classname,  Index, Level, Qual, Attribute, Slot);
			
			if(StrContains(name, SearchWord, false) > -1)
			{
				AddMenuItem(menu, temp, name);
				SearchValue++;
			}
		}
		while(KvGotoNextKey(DB));
		
		KvGoBack(DB);
	}
	
	if(!SearchValue)
	{
		PrintToChat(client, "\x03이름이 잘못되었거나 없는 이름입니다.");
	}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	KvRewind(DB);
	CloseHandle(DB);
	
	return Plugin_Handled;
}

public Primary_weapon_select(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:info[256], String:aa[6][256];
		GetMenuItem(menu, select, info, sizeof(info));
		
		ExplodeString(info, "*", aa, 6, 256);
		SpawnWeapon(client, aa[0], StringToInt(aa[5]), StringToInt(aa[1]), StringToInt(aa[2]), StringToInt(aa[3]), aa[4], TF2_GetPlayerClass(client));
	}
	else if(action == MenuAction_End) CloseHandle(menu);
}

public Action:WeaponCommand(client, args)
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
	
	GetCmdArg(1, classname, sizeof(classname));
	GetCmdArg(2, index, sizeof(index));
	GetCmdArg(3, slot, sizeof(slot));
	GetCmdArg(4, level, sizeof(level));
	GetCmdArg(5, qual, sizeof(qual));
	GetCmdArg(6, att, sizeof(att));
	
	SpawnWeapon(client, classname, StringToInt(slot), StringToInt(index), StringToInt(level), StringToInt(qual), att, TF2_GetPlayerClass(client));
	return Plugin_Handled;
}

stock SpawnWeapon(client,String:name[],slot,index,level,qual,String:att[], TFClassType:classbased = TFClass_Unknown)
{
	new Flags = OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL | OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES;
	
	new Handle:newItem = TF2Items_CreateItem(Flags);
	
	if (newItem == INVALID_HANDLE)
		return -1;
	
	if (strcmp(name, "saxxy", false) != 0) Flags |= FORCE_GENERATION;
	
	if (StrEqual(name, "tf_weapon_shotgun", false)) strcopy(name, 64, "tf_weapon_shotgun_soldier");
	if (strcmp(name, "tf_weapon_shotgun_hwg", false) == 0 || strcmp(name, "tf_weapon_shotgun_pyro", false) == 0 || strcmp(name, "tf_weapon_shotgun_soldier", false) == 0)
	{
		switch (classbased)
		{
			case TFClass_Heavy: strcopy(name, 64, "tf_weapon_shotgun_hwg");
			case TFClass_Soldier: strcopy(name, 64, "tf_weapon_shotgun_soldier");
			case TFClass_Pyro: strcopy(name, 64, "tf_weapon_shotgun_pyro");
		}
	}
	
	TF2Items_SetClassname(newItem, name);
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

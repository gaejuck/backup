#include <tf2_stocks>
#include <tf2items>
#include <tf2itemsinfo>

new String:PrimaryConfig[120];

public Plugin:myinfo =
{
	name = "PSF Weapon Rent",
	author = "TAKE 2",
	description = "무기를 대여합니다.",
	version = "1.0",
	url = ""
} 

public OnPluginStart()
{
	BuildPath(Path_SM, PrimaryConfig, sizeof(PrimaryConfig), "configs/psf/weapon.cfg");
	
	RegConsoleCmd("sm_weapon", WeaponMenu, "컨픽에 적은 무기들을 메뉴로 꺼내 볼 수 있는 명령어입니다.");
}

public Action:WeaponMenu(client, args)
{
	new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	new wepIndex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	new String:Weapon_Classname[64];
	
	decl String:Classname[64], String:Attribute[256], String:Index[32], String:name[64];
	new String:temp[256];
	
	new Handle:menu = CreateMenu(Primary_weapon_select);
	new Handle:DB = CreateKeyValues("custom_weapon"); 
	
	SetMenuTitle(menu, "무기를 고르세요.", client);
		
	FileToKeyValues(DB, PrimaryConfig);
	if(KvGotoFirstSubKey(DB))
	{
		do
		{
			KvGetSectionName(DB, name, sizeof(name));
			KvGetString(DB, "classname", Classname, sizeof(Classname));
			KvGetString(DB, "attribute", Attribute, sizeof(Attribute));
			KvGetString(DB, "index", Index, sizeof(Index));
			new replace = KvGetNum(DB, "replace_index", 0);
			new Level = KvGetNum(DB, "level", 1);
			new Qual = KvGetNum(DB, "qual", 1);
			
			ReplaceString(Classname, sizeof(Classname), "스카웃_스캐터건", "tf_weapon_scattergun");
			
			ReplaceString(Classname, sizeof(Classname), "스나이퍼_저격소총", "tf_weapon_sniperrifle");
			ReplaceString(Classname, sizeof(Classname), "스나이퍼_활", "tf_weapon_compound_bow");
			ReplaceString(Classname, sizeof(Classname), "스나이퍼_smg", "tf_weapon_smg");
			
			ReplaceString(Classname, sizeof(Classname), "스파이_리볼버", "tf_weapon_revolver");
			ReplaceString(Classname, sizeof(Classname), "권총", "tf_weapon_pistol");
			
			ReplaceString(Index, sizeof(Index), "스카웃_스캐터건", "13");
				
			GetEdictClassname(weapon, Weapon_Classname, sizeof(Weapon_Classname));
			if (StrContains(Weapon_Classname, "tf_weapon_pistol", false) != -1)
				ReplaceString(Index, sizeof(Index), "권총", "23");
				
			ReplaceString(Index, sizeof(Index), "스나이퍼_저격소총", "14");
			ReplaceString(Index, sizeof(Index), "스나이퍼_활", "56");
			ReplaceString(Index, sizeof(Index), "스나이퍼_smg", "16");
			
			ReplaceString(Index, sizeof(Index), "스파이_리볼버", "24");
			
			Format(temp, sizeof(temp), "%s*%d*%d*%d*%s", Classname,  replace, Level, Qual, Attribute);
			
			if(StringToInt(Index) ==  wepIndex || StringToInt(Index) == 23)
			{
				AddMenuItem(menu, temp, name);
			}
		}
		while(KvGotoNextKey(DB));
		
		KvGoBack(DB);
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
		decl String:info[256], String:aa[5][256];
		GetMenuItem(menu, select, info, sizeof(info));
		
		ExplodeString(info, "*", aa, 5, 256);
			
		new TF2ItemSlot:slot = TF2II_GetItemSlot(StringToInt(aa[1]));
				
		SpawnWeapon(client, aa[0], slot, StringToInt(aa[1]), StringToInt(aa[2]), StringToInt(aa[3]), aa[4]);
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
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

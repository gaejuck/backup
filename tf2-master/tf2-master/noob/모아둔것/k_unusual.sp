#include <sourcemod>
#include <tf2>
#include <tf2items>
#include <tf2itemsinfo>
#include <tf2attributes> 
#include <sdktools>

public Plugin:myinfo = 
{
	name = "unusual",
	author = "TAKE 2",
	description = "ㅇㅇ 언유",
	version = "1.0", 
	url = "x"
};

new Handle:g_hItem = INVALID_HANDLE;
new Float:aaa[MAXPLAYERS+1] = 0.0;
new String:propConfig[120];

public OnPluginStart()
{
	BuildPath(Path_SM, propConfig, sizeof(propConfig), "configs/k-unusual.cfg");
	
	RegAdminCmd("sm_un", unusual_command, ADMFLAG_RESERVATION);
}

public OnClientPutInServer(client){
	if(aaa[client] > 0.0)
		aaa[client] = 0.0;
}
public OnClientDisconnect(client){
	if(aaa[client] > 0.0)
		aaa[client] = 0.0;
}

public Action:unusual_command(client, args)
{
	new Handle:menu = CreateMenu(unusual_select); new Handle:DB = CreateKeyValues("unusual");
	new amount = 0, String:name[50], String:temp[120];
	SetMenuTitle(menu, "언유 메뉴", client);
	FileToKeyValues(DB, propConfig);
	if(KvGotoFirstSubKey(DB))
	{
		KvGetString(DB, "name", name, sizeof(name), "NULL_NAME");
		amount = KvGetNum(DB, "number", 1);
		Format(temp, sizeof(temp), "%d", amount);
		AddMenuItem(menu, temp, name);
		while(KvGotoNextKey(DB))
		{
			KvGetString(DB, "name", name, sizeof(name), "NULL_NAME");
			amount = KvGetNum(DB, "number", 1);
			Format(temp, sizeof(temp), "%d", amount);
			AddMenuItem(menu, temp, name);
		}
	}
	KvRewind(DB);
	CloseHandle(DB);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	SetMenuExitButton(menu, true);
	
	return Plugin_Handled;
}

public unusual_select(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if(action == MenuAction_Select)
	{
		decl String:info[12];
		
		GetMenuItem(menu, param2, info, sizeof(info));
		
		new Float:unsunal_code = StringToFloat(info);
		aaa[client] = unsunal_code;
	}
}

// public TF2Items_OnGiveNamedItem_Post(client, String:classname[], index, level, quality, entity)
// {
	// if (StrEqual(classname, "tf_wearable"))
	// {
		// if (aaa[client] == 0.0)
			// return;
		
		// new TFClassType:Class = TF2_GetPlayerClass(client);
		// if(TF2ItemSlot:TF2II_GetSlotByName("head", Class))
		// {
			// TF2Attrib_SetByDefIndex(entity, 134, aaa[client]);
		// }
	// }
// }

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	if (StrEqual(classname, "tf_wearable"))
	{
		new TFClassType:Class = TF2_GetPlayerClass(client);
		if(TF2ItemSlot:TF2II_GetSlotByName("head", Class))
			return Plugin_Continue;
	}
	
	g_hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
	TF2Items_SetNumAttributes(g_hItem, 1);
	TF2Items_SetAttribute(g_hItem, 0, 134, aaa[client]);
	hItem = g_hItem;
	return Plugin_Changed;
}



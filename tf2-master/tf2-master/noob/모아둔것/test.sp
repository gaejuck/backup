#include <tf2_stocks>
#include <sdktools>
#include <sdkhooks>
#include <tf2itemsinfo>
#include <tf2attributes> 

public OnPluginStart()
{
	RegConsoleCmd("sm_test", aaaa, "");
	AddCommandListener(taunt, "taunt");
	HookEvent("player_spawn", PlayerSpawn);
}

public Action:taunt(client, const String:command[], argc)
{
	PrintToChat(client, "도발을 하지요");
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	TF2Attrib_SetByDefIndex(client, 689, 50.0); // 소생
} 

public Action:aaaa(client, args)
{
	if (client && IsClientConnected(client)) 
    {
        new Handle:hKV = CreateKeyValues("menu");
        KvSetString(hKV, "title", "Press ESC to continue to Menu Panel!");
        KvSetNum(hKV, "level", 1);
        KvSetColor(hKV, "color", 255, 255, 255, 255);
        KvSetNum(hKV, "time", 20);
        
        KvSetString(hKV, "msg", "Do you want to receive Advertisements on server?");

        KvJumpToKey(hKV, "1", true);
        KvSetString(hKV, "msg", "No!");
        KvSetString(hKV, "command", "ads_off");
        
        KvJumpToKey(hKV, "2", true);
        KvSetString(hKV, "msg", "Yes");
        KvSetString(hKV, "command", "ads_on");
        
        CreateDialog(client, hKV, DialogType_Menu);
        CloseHandle(hKV);
    }
}

// public TF2Items_OnGiveNamedItem_Post(client, String:classname[], index, level, quality, entity)
// {
	// if (StrEqual(classname, "tf_wearable"))
	// {
		// new TFClassType:Class = TF2_GetPlayerClass(client);
		// if(TF2ItemSlot:TF2II_GetSlotByName("head", Class))
		// {
			// TF2Attrib_SetByDefIndex(entity, 134, 80.0);
		// }
	// }
// }

// public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
// {
	// if (StrEqual(classname, "tf_wearable"))
		// return Plugin_Continue;
	
	// new TFClassType:Class = TF2_GetPlayerClass(client);
	// decl String:WeapName[64];
//	TF2II_GetItemName(iItemDefinitionIndex, WeapName, sizeof(WeapName));
	// new qual = TF2II_GetItemQuality(iItemDefinitionIndex);
	// TF2II_GetItemClass(iItemDefinitionIndex, qual, Class);
	// if(TF2II_GetSlotByName("head", Class))
	// {
	
	// hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
	// TF2Items_SetClassname(hItem, classname);		
	// TF2Items_SetItemIndex(hItem, iItemDefinitionIndex);
	
	// TF2Items_SetNumAttributes(hItem, 1);
	// TF2Items_SetAttribute(hItem, 0, 542, 1.0);
	
//	PrintToChatAll("%N is getting some particles", client);
	
	// return Plugin_Changed;
// }

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

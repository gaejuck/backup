#include <sourcemod>
#include <sdktools>
#include <tf2itemsinfo>
#include <tf2items>

// new String:temp[MAXPLAYERS+1][256];
new String:Tclassname[MAXPLAYERS+1][3][64];
new Tslot[MAXPLAYERS+1][3];
new Tindex[MAXPLAYERS+1][3];
new Tlevel[MAXPLAYERS+1][3];
new Tqul[MAXPLAYERS+1][3];
new String:Tatt[MAXPLAYERS+1][3][64];

public OnPluginStart()
{
	RegAdminCmd("b", Cmd_GetOffSet, ADMFLAG_GENERIC, "Get offset of m_hMyWearables");
	HookEvent("post_inventory_application", post_inventory_application);
}

public OnClientPostAdminCheck(client)
{
	Tclassname[client] = "";
	Tslot[client] = 0;
	Tindex[client] = 0;
	Tlevel[client] = 0;
	Tqul[client] = 0;
	Tatt[client] = "";
}

public Action:Cmd_GetOffSet(client, args)
{
	Tclassname[client] = "tf_weapon_scattergun";
	Tslot[client] = 0;
	Tindex[client] = 200;
	Tlevel[client] = 44;
	Tqul[client] = 7;
	Tatt[client] = "542 ; 1";
}


public Action:post_inventory_application(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	SpawnWeapon(client, Tclassname[client], Tslot[client], Tindex[client], Tlevel[client],Tqul[client], Tatt[client]);
	return Plugin_Changed;
}

stock SpawnWeapon(client, String:name[],slot,index,level,qual,String:att[])
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
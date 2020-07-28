#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2attributes> 
#include <tf2itemsinfo>
#include <tf2items>

 new Handle:info = INVALID_HANDLE;
 

public OnPluginStart()
{
	info = CreateConVar("sm_tf_index", "19", "켜기 끄기 1/0");
	
	// HookEvent("player_spawn", PlayerSpawn);
	HookEvent("post_inventory_application", post_inventory_application);
}

public Action:post_inventory_application(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(TF2_GetPlayerClass(client) != TFClassType:TFClass_DemoMan)
	{
		TF2_SetPlayerClass(client, TFClass_DemoMan);
		TF2_RespawnPlayer(client);
		TF2Attrib_SetByDefIndex(client, 280, GetConVarFloat(info));
		SpawnWeapon(client, "tf_weapon_grenadelauncher", 0, 15158, 69, 5, "");
	} 
	for (new iSlot = 1; iSlot < 5; iSlot++)
    {
        new iEntity = GetPlayerWeaponSlot(client, iSlot);
        if (iEntity != -1)	RemoveEdict(iEntity);
    }
}

public Action:OnPlayerRunCmd(iClient, &iButtons, &iImpulse, Float:fVelocity[3], Float:fAngles[3], &iWeapon)
{
    iButtons &= ~IN_ATTACK2;
    return Plugin_Continue;
}

public OnEntityCreated(entity, const String:classname[])
{
	if(GetConVarFloat(info) == 19.0)
		if(StrEqual(classname, "tf_projectile_arrow"))
			SDKHook(entity, SDKHook_StartTouch, OnExplode);
}

public Action:OnExplode(entity, other) 
{
	if (!IsAClient(other))
		AcceptEntityInput(entity, "Kill");
	return Plugin_Handled;
}

IsAClient(index)
{
	if (1<=index<=MaxClients&&IsClientInGame(index))
		return true;
	else
		return false;
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

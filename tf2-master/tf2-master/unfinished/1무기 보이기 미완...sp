#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2items>
#include <bonemerge_test>

#define rocket "models/weapons/w_models/w_rocketlauncher.mdl"

new aaa[MAXPLAYERS+1];

public OnPluginStart()
{
	RegConsoleCmd("sm_ww", ww);
	
	HookEvent("player_death", Player_Death);
}

public Action:ww(client, args)
{
	SpawnWeapon(client, "tf_weapon_rocketlauncher", 0, 15057, 69, 7, "");
	return Plugin_Handled;
}

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(aaa[client] != INVALID_ENT_REFERENCE)
	{
		TF2_RegeneratePlayer(client);
		Attachable_UnhookEntity(client, aaa[client]);
		aaa[client] = INVALID_ENT_REFERENCE;
		PrintToChat(client, "모자 삭제"); 
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
	
	PrecacheModel(rocket);
	
	EquipPlayerWeapon(client, entity);
	
	// SetEntityRenderMode(entity, RENDER_NONE);
	// SetEntityRenderColor(entity, 0, 0, 0, 0);
	
	aaa[client] = EntIndexToEntRef(Attachable_CreateAttachable(client, client, rocket));
	// SetEntProp(aaa[client], Prop_Send, "m_nSkin", 1);
	
	if(GetEntProp(aaa[client], Prop_Data, "m_spawnflags") & 4)
	{
		SetEntProp(aaa[client], Prop_Data, "m_spawnflags", 0);
		SetEntProp(aaa[client], Prop_Send, "m_CollisionGroup", 5);
	}

	CloneHandle(newItem);
	return entity;
}
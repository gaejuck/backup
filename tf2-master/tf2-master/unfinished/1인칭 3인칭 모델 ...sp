#include <sourcemod>
#include <tf2items>
#include <tf2_stocks>
#include <customweaponstf>

new Handle:g_hSdkEquipWearable;

public OnPluginStart()
{
	HookEvent("player_spawn", Event_Player_Spawn);
}

public Action:Event_Player_Spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	CusWepsTF_EquipItemByName(client, "Iron Defense Solution");

	return Plugin_Continue;
}

stock EquipWearable(client, String:Mdl[], bool:vm, weapon = 0, bool:visactive = true)
{ // ^ bad name probably
	new wearable = CreateWearable(client, Mdl, vm);
	if (wearable == -1) return -1;
	wearableOwner[wearable] = client;
	if (weapon > MaxClients)
	{
		tiedEntity[wearable] = weapon;
		hasWearablesTied[weapon] = true;
		onlyVisIfActive[wearable] = visactive;
		
		new effects = GetEntProp(wearable, Prop_Send, "m_fEffects");
		if (weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")) SetEntProp(wearable, Prop_Send, "m_fEffects", effects & ~32);
		else SetEntProp(wearable, Prop_Send, "m_fEffects", effects |= 32);
	}
	return wearable;
}

// stock SpawnWeapon(client, String:name[], slot, index, level, qual, String:fmodel[], String:tmodel[], String:att[])
// {
	// new Flags = OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL | OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES;
	
	// new Handle:newItem = TF2Items_CreateItem(OVERRIDE_ALL);
	
	// if (newItem == INVALID_HANDLE)
		// return -1;
		
	// TF2Items_SetClassname(newItem, name);
	
	// if (strcmp(name, "saxxy", false) != 0) Flags |= FORCE_GENERATION;
		
	// TF2Items_SetItemIndex(newItem, index);
	// TF2Items_SetLevel(newItem, level);
	// TF2Items_SetQuality(newItem, qual);
	// TF2Items_SetFlags(newItem, Flags);
	
	// new String:atts[32][32]; 
	// new count = ExplodeString(att, " ; ", atts, 32, 32);
	
	// if (count > 1)
	// {
		// TF2Items_SetNumAttributes(newItem, count/2);
		// new i2 = 0;
		// for (new i = 0;  i < count;  i+= 2)
		// {
			// TF2Items_SetAttribute(newItem, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			// i2++;
		// }
	// }
	// else
		// TF2Items_SetNumAttributes(newItem, 0);
		
	// TF2_RemoveWeaponSlot(client, slot);
	// new entity = TF2Items_GiveNamedItem(client, newItem);
	// CloneHandle(newItem);
	
	// new vm = CreateVM(client, fmodel);
	// SetEntPropEnt(vm, Prop_Send, "m_hWeaponAssociatedWith", entity);
	// SetEntPropEnt(entity, Prop_Send, "m_hExtraWearableViewModel", vm);
	
	// new worldmodel = PrecacheModel(tmodel);
	// SetEntProp(entity, Prop_Send, "m_iWorldModelIndex", worldmodel);
	// SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", worldmodel, _, 0);
	
	// EquipPlayerWeapon(client, entity);

	// return entity;
// }


stock CreateVM(client, String:model[])
{
	new ent = CreateEntityByName("tf_wearable_vm");
	if (!IsValidEntity(ent)) return -1;
	SetEntProp(ent, Prop_Send, "m_nModelIndex", PrecacheModel(model));
	SetEntProp(ent, Prop_Send, "m_fEffects", (1 << 0)|(1 << 7));
	SetEntProp(ent, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntProp(ent, Prop_Send, "m_usSolidFlags", 4);
	SetEntProp(ent, Prop_Send, "m_CollisionGroup", 11);
	DispatchSpawn(ent);
	SetVariantString("!activator");
	ActivateEntity(ent);
	TF2_EquipWearable(client, ent);
	return ent;
}

stock TF2_EquipWearable(client, entity)
{
	if (g_hSdkEquipWearable == INVALID_HANDLE)
	{
		new Handle:hGameConf = LoadGameConfigFile("tf2items.randomizer");
		if (hGameConf == INVALID_HANDLE)
		{
			SetFailState("Couldn't load SDK functions. Could not locate tf2items.randomizer.txt in the gamedata folder.");
			return;
		}
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable");
		PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
		g_hSdkEquipWearable = EndPrepSDKCall();
		if (g_hSdkEquipWearable == INVALID_HANDLE)
		{
			SetFailState("Could not initialize call for CTFPlayer::EquipWearable");
			CloseHandle(hGameConf);
			return;
		}
	}
	if (g_hSdkEquipWearable != INVALID_HANDLE) SDKCall(g_hSdkEquipWearable, client, entity);
}
#include <sourcemod>
#include <tf2items>
#include <tf2_stocks>
#include <sdkhooks>

new bool:bSDKStarted = false;
new Handle:hSDKEquipWearable;

public OnPluginStart()
{
	HookEvent("player_spawn", Event_Player_Spawn);
	TF2_SdkStartup();
}

public Action:Event_Player_Spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	decl String:classname[64];
	new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	GetEdictClassname(weapon, classname, sizeof(classname));
	if (StrEqual(classname, "tf_weapon_scattergun"))
	{
		new vm = CreateVM(client, "models/weapons/c_models/c_blackbox/c_blackbox_xmas.mdl");
		SetEntPropEnt(vm, Prop_Send, "m_hWeaponAssociatedWith", weapon);
		SetEntPropEnt(weapon, Prop_Send, "m_hExtraWearableViewModel", vm);
		
		new worldmodel = PrecacheModel("models/weapons/c_models/c_grenadelauncher/c_grenadelauncher_xmas.mdl"); //3인칭
		SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", worldmodel);
		SetEntProp(weapon, Prop_Send, "m_nModelIndexOverrides", worldmodel, _, 0);
	}
	// SpawnWeapon(client, "tf_weapon_scattergun", 0, 799, 1, 1, "models/weapons/w_models/w_scattergun.mdl", 
	// "models/weapons/c_models/c_grenadelauncher/c_grenadelauncher_xmas.mdl","542 ; 1");
	return Plugin_Continue;
}

stock SpawnWeapon(client, String:name[], slot, index, level, qual, String:fmodel[], String:tmodel[], String:att[])
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
	CloneHandle(newItem);
	
	new vm = CreateVM(client, fmodel);
	SetEntPropEnt(vm, Prop_Send, "m_hWeaponAssociatedWith", entity);
	SetEntPropEnt(entity, Prop_Send, "m_hExtraWearableViewModel", vm);
	
	new worldmodel = PrecacheModel(tmodel);
	SetEntProp(entity, Prop_Send, "m_iWorldModelIndex", worldmodel);
	SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", worldmodel, _, 0);
	
	// SetEntProp(entity, Prop_Send, "m_nModelIndex", worldmodel);
	
	// new gunslingerfix = -1;
	// new TFClassType:class = FixReload(client, entity, name, gunslingerfix);
	
	EquipPlayerWeapon(client, entity);
	
	// if (class != TFClass_Unknown)
	// {
		// TF2_SetPlayerClass(client, class, _, false);
	// }
	return entity;
}

stock TFClassType:FixReload(client, weapon, String:classname[], &realindex)
{
	new TFClassType:class = TF2_GetPlayerClass(client);
	new bool:found = false;
	new bool:gunslinger = false;//(GetIndexOfWeaponSlot(client, TFWeaponSlot_Melee) == 142);
	if (StrEqual(classname, "tf_weapon_revolver", false) && realindex != 24 && realindex != 210 && (class != TFClass_Spy || gunslinger))
	{
		found = true;
		TF2_SetPlayerClass(client, TFClass_Spy, _, false);
		if (gunslinger) SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", 24);
	}
	if (StrEqual(classname, "tf_weapon_syringegun_medic", false) && realindex != 17 && realindex != 204 && (class != TFClass_Medic || gunslinger))
	{
		found = true;
		TF2_SetPlayerClass(client, TFClass_Medic, _, false);
		if (gunslinger) SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", 17);
	}
	if (StrEqual(classname, "tf_weapon_smg", false) && (class != TFClass_Sniper))// || gunslinger))
	{
		found = true;
		TF2_SetPlayerClass(client, TFClass_Sniper, _, false);
//		if (gunslinger) SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", 16);
	}
	if (strncmp(classname, "tf_weapon_handgun_scout_primary", 23, false) == 0 && (class != TFClass_Scout || gunslinger))
	{
		found = true;
		TF2_SetPlayerClass(client, TFClass_Scout, _, false);
		if (gunslinger) SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", 13);
	}
	if (strncmp(classname, "tf_weapon_handgun_scout_secondary", 23, false) == 0 && (class != TFClass_Scout))// || gunslinger))
	{
		found = true;
		TF2_SetPlayerClass(client, TFClass_Scout, _, false);
//		if (gunslinger) SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", 22);
	}
	if (strncmp(classname, "tf_weapon_pistol", 16, false) == 0 && class != TFClass_Scout && class != TFClass_Engineer)
	{
		found = true;
		TF2_SetPlayerClass(client, TFClass_Scout, _, false);
	}
	if (StrEqual(classname, "tf_weapon_soda_popper", false) && (class != TFClass_Scout || gunslinger))
	{
		found = true;
		TF2_SetPlayerClass(client, TFClass_Scout, _, false);
		if (gunslinger) SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", 13);
	}
	if (StrEqual(classname, "tf_weapon_scattergun", false) && realindex == 45 && (class != TFClass_Scout || gunslinger))
	{
		found = true;
		TF2_SetPlayerClass(client, TFClass_Scout, _, false);
		if (gunslinger) SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", 13);
	}
	if (StrEqual(classname, "tf_weapon_rocketlauncher", false) && realindex == 730 && (class != TFClass_Soldier || gunslinger))
	{
		found = true;
		TF2_SetPlayerClass(client, TFClass_Soldier, _, false);
		if (gunslinger) SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", 18);
	}
	if (StrEqual(classname, "tf_weapon_crossbow", false) && ((class != TFClass_Medic && class != TFClass_Soldier) || gunslinger))
	{
		found = true;
		TF2_SetPlayerClass(client, TFClass_Medic, _, false);
		if (gunslinger) SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", 17);
	}
	if (StrEqual(classname, "tf_weapon_compound_bow", false) && (class != TFClass_Sniper || gunslinger))
	{
		found = true;
		TF2_SetPlayerClass(client, TFClass_Sniper, _, false);
		if (gunslinger) SetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex", 14);
	}
	if (!found) return TFClass_Unknown;
	return class;
}

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

stock bool:TF2_SdkStartup()
{
	new Handle:hGameConf = LoadGameConfigFile("tf2items.randomizer");
	if (hGameConf == INVALID_HANDLE)
	{
		LogMessage("Couldn't load SDK functions (GiveWeapon). Make sure tf2items.randomizer.txt is in your gamedata folder! Restart server if you want wearable weapons.");
		return false;
	}
	if (hSDKEquipWearable == INVALID_HANDLE)
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable");
		PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
		hSDKEquipWearable = EndPrepSDKCall();
	}
	CloseHandle(hGameConf);
	bSDKStarted = true;
	return true;
}

stock TF2_EquipWearable(client, entity)
{
	if (bSDKStarted == false || hSDKEquipWearable == INVALID_HANDLE)
	{
		TF2_SdkStartup();
		LogMessage("Error: Can't call EquipWearable, SDK functions not loaded! If it continues to fail, reload plugin or restart server. Make sure your gamedata is intact!");
	}
	else
	{
		if (TF2_IsEntityWearable(entity)) SDKCall(hSDKEquipWearable, client, entity);
		else LogMessage("Error: Item %i isn't a valid wearable.", entity);
	}
}
stock bool:TF2_IsEntityWearable(entity)
{
	if (entity > MaxClients && IsValidEdict(entity))
	{
		new String:strClassname[32]; GetEdictClassname(entity, strClassname, sizeof(strClassname));
		return (strncmp(strClassname, "tf_wearable", 11, false) == 0 || strncmp(strClassname, "tf_powerup", 10, false) == 0);
	}

	return false;
}
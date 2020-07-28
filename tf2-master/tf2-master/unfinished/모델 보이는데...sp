#include <bonemerge_test>
#include <sdktools>
#include <sdkhooks>
#include <tf2items>

#define wings "models/workshop/player/items/medic/sf14_purity_wings/sf14_purity_wings.mdl"
#define hat "models/workshop/player/items/spy/sf14_hw2014_spy_voodoo_hat/sf14_hw2014_spy_voodoo_hat.mdl"
#define rocket "models/weapons/c_models/c_blackbox/c_blackbox_xmas.mdl"
#define zombie "models/player/items/scout/scout_zombie.mdl"
#define car "models/player/items/taunts/bumpercar/parts/bumpercar.mdl"
#define ball "models/props_halloween/hwn_kart_ball01.mdl"
#define asd "models/props_soho/skybox_redsign001.mdl"

new aaa[MAXPLAYERS+1];
new portal[MAXPLAYERS+1];

new bool:bSDKStarted = false;
new Handle:hSDKEquipWearable;

public OnPluginStart()
{
	RegAdminCmd("sm_t", AFO, 0);
	RegAdminCmd("sm_tt", NFO, 0);
	RegAdminCmd("sm_pt", pt, 0);
	RegAdminCmd("sm_ptt", ptt, 0);
	
	TF2_SdkStartup();
}

public Action:AFO(client, args)
{
	PrecacheModel(asd);
	
	aaa[client] = Attachable_CreateAttachable(client, client, asd);
	SetEntProp(aaa[client], Prop_Send, "m_nSkin", 1);
	
	if(GetEntProp(aaa[client], Prop_Data, "m_spawnflags") & 4)
	{
		SetEntProp(aaa[client], Prop_Data, "m_spawnflags", 0);
		SetEntProp(aaa[client], Prop_Send, "m_CollisionGroup", 5);
	}
}

public Action:NFO(client, args)
{
	Attachable_UnhookEntity(client, aaa[client]);
}

public OnMapStart()
{	
	AddFileToDownloadsTable("materials/models/weapons/c_items/baz_rocket.vmt");
	AddFileToDownloadsTable("materials/models/weapons/c_items/baz_rocket.vtf");
	AddFileToDownloadsTable("materials/models/weapons/c_items/bazooka.vmt");
	AddFileToDownloadsTable("materials/models/weapons/c_items/bazooka_blu.vmt");
	AddFileToDownloadsTable("materials/models/weapons/c_items/bazooka_blu.vtf");
	AddFileToDownloadsTable("materials/models/weapons/c_items/bazooka_n.vtf");
	AddFileToDownloadsTable("materials/models/weapons/c_items/bazooka_red.vtf");
	
	
	AddFileToDownloadsTable("models/weapons/c_models/c_rocketlauncher/tk_rocketlauncher.dx80.vtx");
	AddFileToDownloadsTable("models/weapons/c_models/c_rocketlauncher/tk_rocketlauncher.dx90.vtx");
	AddFileToDownloadsTable("models/weapons/c_models/c_rocketlauncher/tk_rocketlauncher.mdl");
	AddFileToDownloadsTable("models/weapons/c_models/c_rocketlauncher/tk_rocketlauncher.phy");
	AddFileToDownloadsTable("models/weapons/c_models/c_rocketlauncher/tk_rocketlauncher.sw.vtx");
	AddFileToDownloadsTable("models/weapons/c_models/c_rocketlauncher/tk_rocketlauncher.vvd");
}

public Action:pt(client, args)
{
	SpawnWeapon(client, "tf_weapon_rocketlauncher", 0, 205, 69, 7, "");
	
	//1인칭인데 모든 슬롯에 나옴..
	new WeaponID 	= GetPlayerWeaponSlot(client, 0);
	EquipWearable(client, rocket , WeaponID);
	
	// 아래꺼는 3인칭인데 모든 슬롯에 나옴..;;
	portal[client] = Attachable_CreateAttachable(client, client, "models/weapons/c_models/c_rocketlauncher/tk_rocketlauncher.mdl");
	
	// new vm = CreateVM(client, "models/weapons/c_models/c_rocketlauncher/tk_rocketlauncher.mdl");
	// SetEntPropEnt(vm, Prop_Send, "m_hWeaponAssociatedWith", WeaponID);
	// SetEntPropEnt(WeaponID, Prop_Send, "m_hExtraWearableViewModel", vm)

	// SetEntProp(WeaponModel, Prop_Send, "m_nSequence", 3);
	
	// new worldmodel = PrecacheModel("models/weapons/c_models/c_grenadelauncher/c_grenadelauncher_xmas.mdl");
	// SetEntProp(WeaponID, Prop_Send, "m_iWorldModelIndex", worldmodel);
	// SetEntProp(WeaponID, Prop_Send, "m_nModelIndexOverrides", worldmodel, _, 0);
}

public Action:ptt(client, args)
{
	Attachable_UnhookEntity(client, portal[client]);
}


stock EquipWearable(client, String:Mdl[],  weapon = 0)
{
	new wearable = CreateVM(client, Mdl);
	if (wearable == -1)
		return -1;

	new effects = GetEntProp(wearable, Prop_Send, "m_fEffects");
	if (weapon == GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")) 
			SetEntProp(wearable, Prop_Send, "m_fEffects", effects & ~32);
	else 
		SetEntProp(wearable, Prop_Send, "m_fEffects", effects |= 32);
	return wearable;
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
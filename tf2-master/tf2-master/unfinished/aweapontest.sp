#include <sourcemod>
#include <tf2items>
#include <tf2_stocks>

#define tp "models/weapons/w_models/w_rocketlauncher.mdl"

new g_effectsOffset;

new Handle:g_hSdkEquipWearable;


public OnPluginStart()
{
	HookEvent("player_spawn", Event_Player_Spawn);
	
	if ((g_effectsOffset = FindSendPropInfo("CBaseViewModel","m_fEffects"))  == -1)
	{	
		SetFailState("could not locate CBaseViewModel:m_fEffects");
	}
}

public Action:Event_Player_Spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	// if(!IsClientAdmin(client)) return Plugin_Continue;
	
	new iEnt = -1;
	decl String:szName[30];
	while((iEnt = FindEntityByClassname2(iEnt, "prop_dynamic_override")) != -1)
	{
		GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
		if(IsValidEdict(iEnt))
		{
			if(StrEqual(szName, "model_taunt"))
				AcceptEntityInput(iEnt, "Kill");
		}
	}
	while((iEnt = FindEntityByClassname2(iEnt, "tf_taunt_prop")) != -1)
	{
		GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
		if(IsValidEdict(iEnt))
		{
			if(StrEqual(szName, "DispenserLink"))
				AcceptEntityInput(iEnt, "Kill");
		}
	}
	
	SpawnWeapon(client, "tf_weapon_rocketlauncher", 0, 15052, 69, 10, "");
	ParentHatEntity(client, tp, "weapon_bone", -3.0, 1.0, "default");

	return Plugin_Continue;
}

stock bool:IsClientAdmin(client)
{
	new AdminId:Cl_ID;
	Cl_ID = GetUserAdmin(client);
	if(Cl_ID != INVALID_ADMIN_ID)
		return true;
	return false;
}

stock SpawnWeapon(client, String:name[], slot, index, level, qual, String:att[])
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
	
	new worldmodel = PrecacheModel(tp);
	SetEntProp(entity, Prop_Send, "m_iWorldModelIndex", worldmodel);
	SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", worldmodel, _, 0);
	
	new vm = -1;
	while( ( vm = FindEntityByClassname2( vm, "tf_viewmodel" ) ) != -1 )
	{
		if(client == GetEntPropEnt(vm, Prop_Send, "m_hOwner"))
		{
			SetEntProp(vm, Prop_Send, "m_fEffects", GetEntProp(vm, Prop_Send, "m_fEffects") & ~(1 << 5));
			ChangeEdictState(vm, g_effectsOffset);
		}
	}
	SetEntityRenderMode(entity, RENDER_TRANSCOLOR);
	SetEntityRenderColor(entity, 0, 0, 0, 0);
	
	SetEntProp(entity, Prop_Send, "m_nSkin", 9);
	
	CreateVM(client, "models/weapons/c_models/c_soldier_arms.mdl");
	vm = CreateVM(client, tp);
	
	if(vm != -1)
	{
		SetEntPropEnt(vm, Prop_Send, "m_hWeaponAssociatedWith", entity);
		SetEntPropEnt(entity, Prop_Send, "m_hExtraWearableViewModel", vm);
	}
	
	EquipPlayerWeapon(client, entity);
	return entity;
}

stock CreateVM(client, String:model[]) // Randomizer code :3
{
	new ent = CreateEntityByName("tf_wearable_vm");
	if (!IsValidEntity(ent)) return -1;
	SetEntProp(ent, Prop_Send, "m_nModelIndex", PrecacheModel(model));
	SetEntProp(ent, Prop_Send, "m_fEffects", 129);
	SetEntProp(ent, Prop_Send, "m_iTeamNum", GetClientTeam(client));
	SetEntProp(ent, Prop_Send, "m_usSolidFlags", 4);
	SetEntProp(ent, Prop_Send, "m_CollisionGroup", 11);
	DispatchSpawn(ent);
	SetVariantString("!activator");
	ActivateEntity(ent);
	TF2_EquipWearable(client, ent); // urg
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

stock FindEntityByClassname2(startEnt, const String:classname[])	// because legacy
{
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

stock ParentHatEntity(client, const String:smodel[], String:attach[], Float:flZOffset = 0.0, Float:flModelScale, const String:strAnimation[])
{
	new Float:pPos[3], Float:pAng[3];
	new prop = CreateEntityByName("prop_dynamic_override");

	new String:strModelPath[PLATFORM_MAX_PATH];
	if(IsValidEntity(prop))
	{
		if(!StrEqual(strModelPath, "", false))
			DispatchKeyValue(prop, "model", strModelPath); 
		else
		{
			DispatchKeyValue(prop, "model", smodel); 
			
		}
		
		SetEntPropFloat(prop, Prop_Send, "m_flModelScale", flModelScale);
		
		DispatchKeyValue(prop, "targetname", "model_taunt");

		DispatchSpawn(prop);
		AcceptEntityInput(prop, "Enable");
		SetEntProp(prop, Prop_Send, "m_nSkin", GetClientTeam(client) - 2);

		SetVariantString("!activator");
		AcceptEntityInput(prop, "SetParent", client);
		

		new iLink = CreateLink(client, attach);

		SetVariantString("!activator");
		AcceptEntityInput(prop, "SetParent", iLink); 
		
		SetVariantString(attach); 
		AcceptEntityInput(prop, "SetParentAttachment", iLink); 
		
		if(StrEqual(attach, "head"))
		{
			pPos[0] -= 100;
		}

		SetEntPropEnt(prop, Prop_Send, "m_hEffectEntity", iLink);
		
		GetEntPropVector(prop, Prop_Send, "m_vecOrigin", pPos);
		GetEntPropVector(prop, Prop_Send, "m_angRotation", pAng);
		
		if(!StrEqual(strAnimation, "default", false))
		{
			SetVariantString(strAnimation);
			AcceptEntityInput(prop, "SetAnimation");  
			SetVariantString(strAnimation);
			AcceptEntityInput(prop, "SetDefaultAnimation");
		}
		
		pPos[2] += flZOffset;
		
		pPos[0] += 20.0;	//This moves it up/down
		// pPos[1] -= 20.0;
		
		pAng[0] += 90.0;
			
		
		SetEntPropVector(prop, Prop_Send, "m_vecOrigin", pPos);
		SetEntPropVector(prop, Prop_Send, "m_angRotation", pAng);
		
	}
}

stock CreateLink(iClient, String:attach[])
{
	new iLink = CreateEntityByName("tf_taunt_prop");
	DispatchKeyValue(iLink, "targetname", "DispenserLink");
	DispatchSpawn(iLink); 
	
	char strModel[PLATFORM_MAX_PATH];
	GetEntPropString(iClient, Prop_Data, "m_ModelName", strModel, PLATFORM_MAX_PATH);
	
	SetEntityModel(iLink, strModel);
	
	SetEntProp(iLink, Prop_Send, "m_fEffects", 16|64);
	
	SetVariantString("!activator"); 
	AcceptEntityInput(iLink, "SetParent", iClient); 
	
	SetVariantString(attach);
	
	AcceptEntityInput(iLink, "SetParentAttachment", iClient);
	
	
	new Float:pPos[3];
	pPos[2] += 20;

	SetEntPropVector(iLink, Prop_Send, "m_vecOrigin", pPos);
	
	return iLink;
}
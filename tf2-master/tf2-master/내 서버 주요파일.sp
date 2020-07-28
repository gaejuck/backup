#include <tf2attributes>
#include <sdktools>
#include <tf2_stocks>
#include <sdkhooks>

new String:EntityConfig[120];
new Float:g_pos[3];

new pc;

new Handle:db_burstammo;

public OnPluginStart()
{
	RegAdminCmd("sm_pet", conga, ADMFLAG_KICK);
	RegAdminCmd("sm_entity", EntityMenu, ADMFLAG_KICK);
	RegAdminCmd("sm_robot", robot, ADMFLAG_KICK);
	RegAdminCmd("sm_rain", aa, ADMFLAG_KICK);

	HookEvent("player_death", Player_Death, EventHookMode_Pre);
	
	BuildPath(Path_SM, EntityConfig, sizeof(EntityConfig), "configs/entity.cfg");
	
	db_burstammo = FindConVar("tf_flamethrower_burstammo");
}

#define QQ "materials/ghost"


public OnMapStart()
{
	decl String:vmt[PLATFORM_MAX_PATH];
	decl String:vtf[PLATFORM_MAX_PATH];
	
	Format(vmt, sizeof(vmt), "%s.vmt", QQ);
	Format(vtf, sizeof(vtf), "%s.vtf", QQ);
	
	AddFileToDownloadsTable(vmt);
	AddFileToDownloadsTable(vtf);
	PrecacheDecal(vmt, true);
	PrecacheDecal(vtf, true);
}


public TF2_OnWaitingForPlayersStart() SetConVarInt(db_burstammo,0);

public Action:aa(client, args)
{
	if(!PlayerCheck(client)) return Plugin_Handled;
	
	new Handle:menu = CreateMenu(Menu_Weather_Ans);

	SetMenuTitle(menu, "하느를 고르시오");

	AddMenuItem(menu, "0", "기본");
	AddMenuItem(menu, "1", "비");

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	PrintToChat(client, "%d", client);
	
	return Plugin_Handled;
}

public Menu_Weather_Ans(Handle:menu, MenuAction:action, client, args)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if(action == MenuAction_Select)
	{
		new entity = -1;
		while( (entity = FindEntityByClassname(entity, "func_precipitation")) != INVALID_ENT_REFERENCE )
		{
			AcceptEntityInput(entity, "Kill");
		}
		
		if(args != 0)
		{
			decl String:WeatherID[2];
			GetMenuItem(menu, args, WeatherID, sizeof(WeatherID));
			
			ChangeWeather(WeatherID);
		}
	}
}

ChangeWeather(String:WeatherID[2])
{
	new value, entity = -1;
	while( (entity = FindEntityByClassname(entity, "func_precipitation")) != INVALID_ENT_REFERENCE )
	{
		value = GetEntProp(entity, Prop_Data, "m_nPrecipType");
		if( value < 0 || value == 4 || value > 5 )
			AcceptEntityInput(entity, "Kill");
	}
	entity = CreateEntityByName("func_precipitation");
	if( entity != -1 )
	{
		decl String:buffer[128];
		GetCurrentMap(buffer, sizeof(buffer));
		Format(buffer, sizeof(buffer), "maps/%s.bsp", buffer);
		DispatchKeyValue(entity, "model", buffer);
		DispatchKeyValue(entity, "targetname", "silver_rain");
		DispatchKeyValue(entity, "preciptype", WeatherID);
		DispatchKeyValue(entity, "renderamt", "255");
		DispatchKeyValue(entity, "minSpeed", "25");
		DispatchKeyValue(entity, "maxSpeed", "35");

		new Float:vMins[3], Float:vMaxs[3];
		GetEntPropVector(0, Prop_Data, "m_WorldMins", vMins);
		GetEntPropVector(0, Prop_Data, "m_WorldMaxs", vMaxs);
		SetEntPropVector(entity, Prop_Send, "m_vecMins", vMins);
		SetEntPropVector(entity, Prop_Send, "m_vecMaxs", vMaxs);
		
		decl Float:vBuff[3];
		vBuff[0] = vMins[0] + vMaxs[0];
		vBuff[1] = vMins[1] + vMaxs[1];
		vBuff[2] = vMins[2] + vMaxs[2];
		
		DispatchSpawn(entity);
		ActivateEntity(entity);
		TeleportEntity(entity, vBuff, NULL_VECTOR, NULL_VECTOR);
	}
	else
		LogError("Failed to create 'func_precipitation'");
}

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client  = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker  = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(PlayerCheck(client) && PlayerCheck(attacker)) 
	{
		// CreateTimer(0.1, timerRespawn, client);
		if(client != attacker)
		{
			if(IsClientAdmin(attacker))
			{
				switch(GetRandomInt(0,8))
				{
					case 0: SetEventInt(event, "customkill", TF_CUSTOM_BACKSTAB);
					case 1:
					{
						SetEventString(event, "weapon_logclassname", "goomba");
						SetEventString(event, "weapon", "taunt_scout");
					}
					case 2: SetEventInt(event, "customkill", TF_CUSTOM_HEADSHOT);
					case 3: SetEventInt(event, "customkill", TF_CUSTOM_GOLD_WRENCH);
					case 4:
					{
						SetEventString(event, "weapon", "necro_smasher");
						SetEventString(event, "weapon_logclassname", "necro_smasher");
					}
					case 5: 
					{
						SetEventString(event, "weapon_logclassname", "taunt_medic");
						SetEventString(event, "weapon", "taunt_medic");
					}
					case 6:
					{
						SetEventString(event, "weapon", "unarmed_combat");
						SetEventString(event, "weapon_logclassname", "unarmed_combat");
					}
					case 7:
					{
						SetEventString(event, "weapon", "spellbook_skeleton"); 
						SetEventString(event, "weapon_logclassname", "spellbook_skeleton");
					}
					case 8: SetEventInt(event, "customkill", TF_CUSTOM_PUMPKIN_BOMB);
				}
			}
				
		}
	}
	return Plugin_Continue;
}

public Action:timerRespawn(Handle:timer, any:client)
{
    TF2_RespawnPlayer(client);
    return Plugin_Stop;
}


public Action:conga(client, args)
{
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
	
	switch(GetRandomInt(0,5))
	{
		case 0: ParentHatEntity(client, "models/player/engineer.mdl", "head", -3.0, 1.0, "taunt_conga");
		case 1: ParentHatEntity(client, "models/player/pyro.mdl", "head", -3.0, 1.0, "taunt_pyro_pool");
		case 2: ParentHatEntity(client, "models/player/pyro.mdl", "head", -3.0, 1.0, "taunt_aerobic_B");
		case 3: ParentHatEntity(client, "models/player/heavy.mdl", "head", -3.0, 3.0, "taunt_zoomin_broom");
		case 4: ParentHatEntity(client, "models/player/pyro.mdl", "head", -3.0, 5.0, "pyro_taunt_replay");
		case 5: ParentHatEntity(client, "models/player/pyro.mdl", "head", -3.0, 4.0, "primary_death_headshot");
	}
	return Plugin_Handled;
}

public Action:robot(client, args)
{
	decl Float:flStartPos[3], Float:flEyeAng[3], Float:flEndPos[3];
	GetClientEyePosition(client, flStartPos);
	GetClientEyeAngles(client, flEyeAng);
			
	new Handle:hTrace = TR_TraceRayFilterEx(flStartPos, flEyeAng, MASK_SHOT, RayType_Infinite, TraceRayDontHitEntity, client);
	TR_GetEndPosition(flEndPos, hTrace);
	CloseHandle(hTrace);
			
	SpawnRobot(client, flEndPos, flEyeAng);
	return Plugin_Handled;
} 

public Action:EntityMenu(client, args)
{
	decl String:EntityName[64], String:name[64];
	
	new Handle:menu = CreateMenu(EntitySelect);
	new Handle:DB = CreateKeyValues("entity"); 
	
	SetMenuTitle(menu, "엔티티 목록", client);
		
	FileToKeyValues(DB, EntityConfig);
	if(KvGotoFirstSubKey(DB))
	{
		do
		{
			KvGetSectionName(DB, name, sizeof(name));
			KvGetString(DB, "entity", EntityName, sizeof(EntityName));

			AddMenuItem(menu, EntityName, name);
		} 
		while(KvGotoNextKey(DB));
		
		KvGoBack(DB);
	}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	KvRewind(DB);
	CloseHandle(DB);
	
	return Plugin_Handled;
}

public EntitySelect(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(menu, select, info, sizeof(info));
		
		decl Float:flStartPos[3], Float:flEyeAng[3], Float:flEndPos[3];
		GetClientEyePosition(client, flStartPos);
		GetClientEyeAngles(client, flEyeAng);
				
		new Handle:hTrace = TR_TraceRayFilterEx(flStartPos, flEyeAng, MASK_SHOT, RayType_Infinite, TraceRayDontHitEntity, client);
		TR_GetEndPosition(flEndPos, hTrace);
		CloseHandle(hTrace);
		
		new iEnt = CreateEntityByName(info);
		if(IsValidEntity(iEnt))
		{
			g_pos[2] -= 10.0;
			
			DispatchSpawn(iEnt);
			AcceptEntityInput(iEnt, "Enable");
			TeleportEntity(iEnt, flStartPos, flEyeAng, NULL_VECTOR);
			CreateTimer(5.0, EntityTimer, iEnt);
			PrintToChat(client, "엔티티 소환!");
		}
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:EntityTimer(Handle:timer, any:ent)
	if(IsValidEntity(ent))
		AcceptEntityInput(ent, "kill");

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	new index = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	if(IsValidEntity(weapon) && AliveCheck(client))
	{
		if(StrEqual(weaponname, "tf_weapon_rocketlauncher") && index != 730 || StrEqual(weaponname, "tf_weapon_rocketlauncher_directhit") ||
			StrEqual(weaponname, "tf_weapon_grenadelauncher"))
		{
			SetEntProp(weapon, Prop_Send, "m_iClip1", 5);
		}
			
		if(StrEqual(weaponname, "tf_weapon_pipebomblauncher"))
		{
			SetEntProp(weapon, Prop_Send, "m_iClip1", 9);
			TF2Attrib_SetByDefIndex(weapon, 671, 1.0);
		}
	}
	return Plugin_Continue;
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
	pPos[0] += 200;
	SetEntPropVector(iLink, Prop_Send, "m_vecOrigin", pPos);
	
	return iLink;
}

public bool:TraceRayDontHitEntity(entity, mask, any:data)
{
	if (entity == data) return false;
	return true;
}


stock SpawnRobot(client, Float:flPos[3], Float:flAng[3])
{
	// RemoveRobot(client);
	
	new String:targetname0[PLATFORM_MAX_PATH], String:targetname1[PLATFORM_MAX_PATH];
	
	new iPath[2];
	iPath[0] = CreateEntityByName("path_track");
	iPath[1] = CreateEntityByName("path_track");
	
	if (IsValidEntity(iPath[0]) && IsValidEntity(iPath[1]))
	{
		Format(targetname0, sizeof(targetname0), "path_%i_%i", client, iPath[0]);
		Format(targetname1, sizeof(targetname1), "path_%i_%i", client, iPath[1]);
		DispatchKeyValueVector(iPath[0], "origin", flPos);
		DispatchKeyValueVector(iPath[1], "origin", flPos);
		DispatchKeyValueVector(iPath[0], "angles", flAng);
		DispatchKeyValueVector(iPath[1], "angles", flAng);
		DispatchKeyValue(iPath[0], "targetname", targetname0);
		DispatchKeyValue(iPath[1], "targetname", targetname1);
		DispatchKeyValue(iPath[0], "orientationtype", "1");
		DispatchKeyValue(iPath[1], "orientationtype", "1");
		DispatchKeyValue(iPath[0], "target", targetname1);
		DispatchKeyValue(iPath[1], "target", targetname0);
		DispatchSpawn(iPath[0]);
		DispatchSpawn(iPath[1]);
		ActivateEntity(iPath[0]);
		ActivateEntity(iPath[1]);
	}
	
	new SpawnGroup = CreateEntityByName("tf_robot_destruction_spawn_group");
	if (SpawnGroup != -1)
	{
		new String:team[2];
		Format(team, 2, "%i", GetClientTeam(client));
		DispatchKeyValueVector(SpawnGroup, "origin", flPos);
		DispatchKeyValueVector(SpawnGroup, "angles", flAng);
		DispatchKeyValue(SpawnGroup, "group_number", "1");
		DispatchKeyValue(SpawnGroup, "hud_icon", "../HUD/hud_bot_worker3_outline_blue");
		DispatchKeyValue(SpawnGroup, "respawn_time", "60");
		DispatchKeyValue(SpawnGroup, "targetname", "botgroup");
		DispatchKeyValue(SpawnGroup, "team_number", team);
		DispatchSpawn(SpawnGroup);
		ActivateEntity(SpawnGroup);
	}
	
	new Spawner = CreateEntityByName("tf_robot_destruction_robot_spawn");
	if (Spawner != -1)
	{
		DispatchKeyValueVector(Spawner, "origin", flPos);
		DispatchKeyValueVector(Spawner, "angles", flAng);
		DispatchKeyValue(Spawner, "gibs", "0");
		DispatchKeyValue(Spawner, "startpath", targetname0);
		DispatchKeyValue(Spawner, "health", "200");
		DispatchKeyValue(Spawner, "spawngroup", "botgroup");
		DispatchKeyValue(Spawner, "type", "0"); //Smallest one
		DispatchSpawn(Spawner);
		ActivateEntity(Spawner);
		AcceptEntityInput(Spawner, "SpawnRobot");
		AcceptEntityInput(SpawnGroup, "Kill");
		AcceptEntityInput(Spawner, "Kill");
	}
}


stock Handle:CreateParticle(String:type[], entity, attach=0, Float:xOffs=0.0, Float:yOffs=0.0, Float:zOffs=0.0)
{
    pc = CreateEntityByName("info_particle_system");
    
    if (IsValidEdict(pc)) {
        decl Float:pos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
        pos[0] += xOffs;
        pos[1] += yOffs;
        pos[2] += zOffs;
        TeleportEntity(pc, pos, NULL_VECTOR, NULL_VECTOR);
        DispatchKeyValue(pc, "effect_name", type);

        if (attach != 0) {
            SetVariantString("!activator");
            AcceptEntityInput(pc, "SetParent", entity, pc, 0);
        
            if (attach == 2) {
                SetVariantString("head");
                AcceptEntityInput(pc, "SetParentAttachmentMaintainOffset", pc, pc, 0);
            }
        }
        DispatchKeyValue(pc, "targetname", "present");
        DispatchSpawn(pc);
        ActivateEntity(pc);
        AcceptEntityInput(pc, "Start");
        
    }
    
    return INVALID_HANDLE;
}


stock FindEntityByClassname2(startEnt, const String:classname[])
{
	while(startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

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

stock bool:PlayerCheck(Client){
	if(Client > 0 && Client <= MaxClients){
		if(IsClientConnected(Client) == true){
			if(IsClientInGame(Client) == true){
				return true;
			}
		}
	}
	return false;
}

stock bool:IsClientAdmin(client)
{
	new AdminId:Cl_ID;
	Cl_ID = GetUserAdmin(client);
	if(Cl_ID != INVALID_ADMIN_ID)
		return true;
	return false;
}

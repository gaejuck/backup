#include <sdkhooks>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <devzones>

#define ZOMBIEMODEL "models/bots/skeleton_sniper/skeleton_sniper.mdl"

new bool:zombie[MAXPLAYERS+1] = false;
new bool:finish[MAXPLAYERS+1] = false;

new Float:SkillJumpTime[MAXPLAYERS+1];

public OnPluginStart()
{
	RegConsoleCmd("sm_drop", dd);
	RegConsoleCmd("sm_dd", dd2);
	
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_death", Player_Death);
	HookEvent("player_hurt", EventHurt);
	HookEvent("post_inventory_application", OnPlayerInventory, EventHookMode_Post);
}

public OnClientPostAdminCheck(client)
{
	zombie[client] = false;
	finish[client] = false;
}

public Action:dd(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(GetClientTeam(i) == 3)
				zombie[i] = true;
		}
	}
	return Plugin_Handled;
}

public Action:dd2(client, args)
{
	// Jump_Skill(client);
	PrintToChat(client, "나의 체력은 : %d", GetClientHealth(client));
	return Plugin_Handled;
}

public Zone_OnClientEntry(client, String:zone[])
{
	if(!IsClientInGame(client))
		return;
	if(StrContains(zone, "출구", false) == 0)
	{
		finish[client] = true;
		new count;
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(i) == 2)
			{
				if(!finish[i])
					count++;
			}
		}
		if(count == 0)
		{
			PrintToChatAll("닝겐이 승리하였습니다.");
		}
		else
			PrintToChat(client, "%d명 남음", count); 
				
	}
}

public Action:OnPlayerInventory(Handle:hEvent, String:strEventName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (!AliveCheck(client)) return;
    
	if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Sniper)
	{
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 1);
	}
	
	if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Pyro)
	{
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 1);
	}
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(GetClientTeam(client) == 3)
	{
		MakeZombie(client);
	}
	else
		MakeHuman(client);
}

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(PlayerCheck(client))
	{
		zombie[client] = false;
			
		SetVariantString("");
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	}
}

public Action:EventHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new client = GetClientOfUserId(GetEventInt(event, "userid")); 
	
	if(AliveCheck(client) && AliveCheck(attacker) && client != attacker)
	{
		if(!zombie[client])
		{
			MakeZombie(client);
		}
	}
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(zombie[client])
	{
		if(CheckSkillJumpCoolTime(client, 3.0) && GetEntityFlags(client) & FL_ONGROUND)
		{
			if(GetClientButtons(client) & IN_ATTACK2)
			{
				CreateTimer(3.0, SkillJumpTimer, client);
				Jump_Skill(client);
				SkillJumpTime[client] = GetEngineTime();
				new a[50] ;
				
				a[0]= GetClientHealth(client)

			}
		}
	}
}

public Action:SkillJumpTimer(Handle:timer, any:client)
{
	PrintToChat(client, "점프 스킬을 다시 사용할 수 있습니다.");
}

stock MakeHuman(client)
{
	if(IsPlayerAlive(client))
	{
		TF2_SetPlayerClass(client, TFClass_Pyro);
		TF2_RegeneratePlayer(client);
		
		if(GetClientTeam(client) != 2)
		{
			SetEntProp(client, Prop_Send, "m_lifeState", 2);
			ChangeClientTeam(client, 2);
			SetEntProp(client, Prop_Send, "m_lifeState", 0);
		}
		// zombie[client] = true;
	}
}


stock MakeZombie(client)
{
	if(IsPlayerAlive(client))
	{
		PrintToChat(client, "당신은 좀비입니다.");
		
		TF2_SetPlayerClass(client, TFClass_Sniper);
		TF2_RegeneratePlayer(client);
		
		if(GetClientTeam(client) != 3)
		{
			SetEntProp(client, Prop_Send, "m_lifeState", 2);
			ChangeClientTeam(client, 3);
			SetEntProp(client, Prop_Send, "m_lifeState", 0);
		}
		
		PrecacheModel(ZOMBIEMODEL, true);
		SetVariantString(ZOMBIEMODEL);
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		
		ChangePlayerWeaponSlot(client, 2);
		zombie[client] = true;
	}
}

stock Jump_Skill(client)
{
	new Float:vecView[3], Float:vecFwd[3], Float:vecPos[3], Float:vecVel[3];
	new Float:ePos[3];

	GetClientEyeAngles(client, vecView);
	GetAngleVectors(vecView, vecFwd, NULL_VECTOR, NULL_VECTOR);
	GetClientEyePosition(client, vecPos);
	
	new Handle:trace = TR_TraceRayFilterEx(vecPos, vecView, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(ePos, trace);
		if (GetVectorDistance(ePos, vecPos, false) < 45.0)
		{
			PrintToChat(client, "[SM] You are too close to a wall or something to do that...");
			return;
		}
	}

	vecPos[0]+=vecFwd[0]*70.0;
	vecPos[1]+=vecFwd[1]*50.0;

	GetEntPropVector(client, Prop_Send, "m_vecOrigin", vecFwd);

	SubtractVectors(vecPos, vecFwd, vecVel);
	ScaleVector(vecVel, 10.0);

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecVel);
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > MaxClients || !entity;
}

stock bool:CheckSkillJumpCoolTime(any:iClient, Float:fTime)
{
	if(!AliveCheck(iClient)) return false;
	if(GetEngineTime() - SkillJumpTime[iClient] >= fTime) return true;
	else return false;
}

stock SetOverlay(client, const String:szOverlay[])
{
    SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & ~FCVAR_CHEAT);
    ClientCommand(client, "r_screenoverlay \"%s\"", szOverlay); 
    SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") | FCVAR_CHEAT);
}

stock bool:ChangePlayerWeaponSlot(iClient, iSlot) {
    new iWeapon = GetPlayerWeaponSlot(iClient, iSlot);
    if (iWeapon > MaxClients) {
        SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", iWeapon);
        return true;
    }

    return false;
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


// stock SpawnWep(client, index) 
// {
    // new Entity = CreateEntityByName("tf_dropped_weapon");
    // SetEntProp(Entity, Prop_Send, "m_iItemDefinitionIndex", index);
    // SetEntProp(Entity, Prop_Send, "m_iEntityLevel", 5);
    // SetEntProp(Entity, Prop_Send, "m_iEntityQuality", 6);
    // SetEntProp(Entity, Prop_Send, "m_bInitialized", 1);
    // decl Float:coordinates[3];
    // GetClientAbsOrigin(client, coordinates);
    // GetEntPropVector(client, Prop_Send, "m_vecOrigin", coordinates);
    // TeleportEntity(Entity, coordinates, NULL_VECTOR, NULL_VECTOR);
    // SetEntityModel(Entity, "models/weapons/c_models/c_directhit/c_directhit.mdl");
    // DispatchSpawn(Entity);
// }  

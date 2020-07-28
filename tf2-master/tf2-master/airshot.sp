#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#include <utilsext>
#include <tf2attributes>

new bool:check[MAXPLAYERS+1] = false;
new bool:aa[MAXPLAYERS+1] = false;


#define height 150
#define height2 1.5

public OnPluginStart() 
{
	RegAdminCmd("ar", aaaa, ADMFLAG_KICK);
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("post_inventory_application", ev);
	HookEvent("player_death", Player_Death, EventHookMode_Pre);
}

public OnClientPutInServer(i)
{
	SDKHook(i, SDKHook_PostThink, HeightHook);
	SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
	check[i] = false;
}

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(PlayerCheck(client) && IsFakeClient(client))
	{
		CreateTimer(2.0, timerRespawn, client);
	}
}
 
public Action:timerRespawn(Handle:timer, any:client)
{
	decl Float:ori[3];
	ori[0] = -1495.097167;
	ori[1] = 6477.926757
	ori[2] = -1971.567871
	
	TeleportEntity(client, ori, NULL_VECTOR, NULL_VECTOR);
	return Plugin_Stop;
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsFakeClient(client))
	{
		TF2_SetPlayerClass(client, TFClass_Soldier);
		TF2_RegeneratePlayer(client);
		ChangeClientTeam(client, 2);
	}

}

public Action:timerRespawn_cl(Handle:timer, any:client) ChangeClientTeam(client, 3);

public Action:ev(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	TF2Attrib_SetByDefIndex(client, 100, 0.1);
}

public Action:aaaa(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			SDKHook(i, SDKHook_PostThink, HeightHook);
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
		}
	}
	PrintToChat(client, "리로드 완료");
	return Plugin_Handled;
} 


//https://forums.alliedmods.net/showthread.php?p=2411649
public HeightHook(client)
{
	if (AliveCheck(client))
	{
		new Float:dist = DistanceAboveGround(client);
		if (dist >= height) // 130
		{
			SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
			check[client] = true;
		}
		else 
		{
			SetEntProp(client, Prop_Data, "m_takedamage", 1, 1);
			check[client] = false;
		}
		
		// if(height > 250 && dist <= 350) PrintToChat(client, "높이 %.1f", dist);
	}
}

public Action:OnTakeDamage(attacker, &client, &inflictor, &Float:fDamage, &iDamagetype, &iWeapon, Float:fForce[3], Float:fForcePos[3])
{
	if (AliveCheck(attacker) && AliveCheck(client))
	{
		if(attacker != client)
		{
			decl String:szClassName[64];
			new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			if (!IsValidEntity(weapon)) return Plugin_Continue; 
			GetEntityClassname(weapon, szClassName, sizeof(szClassName));
			
			if(StrEqual(szClassName, "tf_weapon_rocketlauncher") || StrEqual(szClassName, "tf_weapon_rocketlauncher_directhit") 
			|| StrEqual(szClassName, "tf_weapon_grenadelauncher"))
			{
				if(check[attacker])
				{
					fDamage = 500.0;
					return Plugin_Changed;
				}
				else RequestFrame(BoostVectors, attacker);
			}
		}
		else TF2_RegeneratePlayer(client);
	}
	return Plugin_Continue; 
}


public Action:OnPlayerRunCmd(client, &iButtons, &iImpulse, Float:fVelocity[3], Float:fAngles[3], &iWeapon)
{
	if(AliveCheck(client) && IsFakeClient(client))
	{

		decl Float:fClientEyePosition[3];
		GetClientEyePosition(client, fClientEyePosition);

		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsPlayerAlive(i) && GetClientTeam(client) != GetClientTeam(i))
			{
				new Float:target_point[3], Float:vNothing[3], Float:eye_to_target[3];
				new iBone = FindBestHitbox(client, i);
				if(iBone == -1) return Plugin_Continue;
				
				utils_EntityGetBonePosition(i, iBone, target_point, vNothing);
				
				if(!check[i]) target_point[2] += 2.3;
				else target_point[2] -= 10.0;
				
				new Float:dist = DistanceAboveGround(client);

				if(height > 0 && dist <= height) target_point[2] += 1.0;
				else if(height > dist && dist <= 250) target_point[2] += -10.0;
				else if (250 >= dist && dist <= 350) target_point[2] += -15.0;
				else if (350 >= dist && dist <= 450) target_point[2] += -20.0;
				else target_point[2] += 35.0;
				
				
				// new Float:fall = GetEntPropFloat(i, Prop_Send, "m_flFallVelocity");
				// if(fall >= 300 && fall <= 400)
				// {
					// target_point[2]-= 20.0;
					// PrintToChat(i, "\x03A");
				// }
				
				// if(fall >= 300 && fall <= 400)
				// {
					// target_point[2]-= 30.0;
					// PrintToChat(i, "\x03B");
				// }
				
				// else if(fall >= 600)
				// {
					// target_point[2] -= 50.0;
					// PrintToChat(i, "\x04C");
				// }
				
				SubtractVectors(target_point, fClientEyePosition, eye_to_target);
				GetVectorAngles(eye_to_target, eye_to_target);
				
				eye_to_target[0] = AngleNormalize(eye_to_target[0]);
				eye_to_target[1] = AngleNormalize(eye_to_target[1]);
				eye_to_target[2] = 0.0;
				
				// TeleportEntity(client, NULL_VECTOR, eye_to_target, NULL_VECTOR);
				fAngles = eye_to_target;
			}
		} //if (other > 0 && other <= MaxClients) if (entity > 0 && entity <= MaxClients)
	}
	
	if(iButtons & IN_RELOAD)
	{
		if(aa[client] == false)
		{
			new Float:fall = GetEntPropFloat(client, Prop_Send, "m_flFallVelocity");
			PrintToChat(client, "높이 %.1f", fall);
			aa[client] = true;
		}
	}
	else
	{
		aa[client] = false;
	}

	return Plugin_Continue;
}

public BoostVectors(client)
{
	new Float:vecClient[3];
	new Float:vecBoost[3];

	GetEntPropVector(client, Prop_Data, "m_vecVelocity", vecClient);

	vecBoost[0] = vecClient[0];
	vecBoost[1] = vecClient[1];
	if(vecClient[2] > 0) vecBoost[2] = vecClient[2] * height2; // 1.2
	else vecBoost[2] = vecClient[2];

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vecBoost);
} 

//https://github.com/Lange/MGEMod/blob/d79ce1bd854f702434d4df1f659213fdea236d17/addons/sourcemod/scripting/mgemod.sp#L5197

Float:DistanceAboveGround(victim)
{
	decl Float:vStart[3];
	decl Float:vEnd[3];
	new Float:vAngles[3]={90.0,0.0,0.0};
	GetClientAbsOrigin(victim,vStart);
	new Handle:trace = TR_TraceRayFilterEx(vStart, vAngles, MASK_PLAYERSOLID, RayType_Infinite,TraceEntityFilterPlayer);

	new Float:distance = -1.0;
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(vEnd, trace);
		distance = GetVectorDistance(vStart, vEnd, false);
	}

	CloseHandle(trace);
	return distance;
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > MaxClients || !entity;
}

stock float AngleNormalize( float angle )
{
	angle = angle - 360.0 * RoundToFloor(angle / 360.0);
	while (angle > 180.0) angle -= 360.0;
	while (angle < -180.0) angle += 360.0;
	return angle;
}

stock FindBestHitbox(client, target)
{
	new iNumBones = utils_EntityGetNumBones(target);
	if(iNumBones < 17)
		return -1;

	new iBestHitBox = utils_EntityLookupBone(target, "bip_spine_2");
	new iActiveWeapon = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
	
	if(TF2_GetPlayerClass(client) == TFClass_Soldier || TF2_GetPlayerClass(client) == TFClass_DemoMan)
	{
		if(iActiveWeapon == GetPlayerWeaponSlot(client, 0))
		{
			iBestHitBox = utils_EntityLookupBone(target, "bip_foot_r");
		}
	}
	
	if(iBestHitBox != -1 && IsBoneVisible(client, target, iBestHitBox))
	{
		return iBestHitBox;
	}
	else
	{
		iBestHitBox = -1;
	}
	
	return iBestHitBox;
}

stock bool IsBoneVisible(looker, target, bone)
{
	new Float:vecEyePosition[3];
	GetClientEyePosition(looker, vecEyePosition);

	new Float:vNothing[3], Float:vOrigin[3];
	utils_EntityGetBonePosition(target, bone, vOrigin, vNothing);
	
	TR_TraceRayFilter(vecEyePosition, vOrigin, MASK_SHOT, RayType_EndPoint, AimTargetFilter, looker);
	if(TR_DidHit() && TR_GetEntityIndex() == target)
	{
		return true;
	}
	
	return false;
}

public bool:AimTargetFilter(entity, contentsMask, any:iExclude)
{
	new String:class[64];
	GetEntityClassname(entity, class, sizeof(class));
	
	if(StrEqual(class, "player"))
	{
		if(GetClientTeam(entity) == GetClientTeam(iExclude))
		{
			return false;
		}
	}
	else if(StrEqual(class, "entity_medigun_shield"))
	{
		if(GetEntProp(entity, Prop_Send, "m_iTeamNum") == GetClientTeam(iExclude))
		{
			return false;
		}
	}
	else if(StrEqual(class, "func_respawnroomvisualizer"))
	{
		return false;
	}
	
	return !(entity == iExclude);
}

public bool:AliveCheck(client)
{
	if(client > 0 && client <= MaxClients)
		if(IsClientConnected(client))
			if(IsClientInGame(client))
				if(IsPlayerAlive(client)) return true;
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

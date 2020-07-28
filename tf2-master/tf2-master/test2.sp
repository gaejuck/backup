#include <sdktools>
#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2>

// #define BOX "models/props_hydro/barrel_crate_half.mdl"
#define SOUND_DUCKED	"misc/halloween/merasmus_spell.wav"
#define MODEL_DUCK		"models/workshop/player/items/pyro/eotl_ducky/eotl_bonus_duck.mdl"


public OnPluginStart()
{
	RegAdminCmd("sm_mvm", m_shield, ADMFLAG_ROOT , "명령어 !tr"); 
	RegAdminCmd("sm_td", td, ADMFLAG_ROOT , "명령어 !tr"); 
	RegAdminCmd("sm_box", box, ADMFLAG_ROOT , "명령어 !tr"); 
	RegAdminCmd("sm_test", test, ADMFLAG_ROOT , "명령어 !tr"); 
	RegAdminCmd("sm_test2", test2, ADMFLAG_ROOT , "명령어 !tr"); 
}

public OnMapStart()
{
	// PrecacheModel(BOX, true);
	PrecacheModel("models/props_2fort/oildrum.mdl", true);
	
	PrecacheModel(MODEL_DUCK);
	PrecacheSound(SOUND_DUCKED);
}

#define Radius 100.0
#define degree  60.0

public Action:test2(client, args)
{
	decl Float:client_pos[3], Float:attacker_pos[3], Float:attacker_angle[3];
	GetClientAbsOrigin(client, client_pos);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (AliveCheck(i) && GetClientTeam(client) != GetClientTeam(i))
		{
			GetClientAbsOrigin(i, attacker_pos);
			GetClientEyePosition(i, attacker_angle);
			
			if (GetVectorDistance(client_pos, attacker_pos) <= 900.0)
			{
				ShootLaser(client, "merasmus_zap", client_pos, attacker_pos);
				Knockback(i, attacker_angle, 100.0);
			}
		}
	}
}

stock Knockback(client, Float:angle[3], Float:power)
{
	decl Float:forwardVec[3], Float:vec[3];
	GetAngleVectors(angle, forwardVec, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(forwardVec, forwardVec);
	
	ScaleVector(vec, -power);
	
	GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vec);
	
	// vec[0] = -forwardVec[0]*1000.0;
	// vec[1] = -forwardVec[1]*1000.0;
	// vec[2] = -forwardVec[2]*1000.0;
	
	// pos[2] += 15.0;
	
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vec);
}
stock ShootLaser(weapon, const String:strParticle[], Float:flStartPos[3], Float:flEndPos[3])
{
	new tblidx = FindStringTable("ParticleEffectNames");
	if (tblidx == INVALID_STRING_TABLE) 
	{
		LogError("Could not find string table: ParticleEffectNames");
		return;
	}
	new String:tmp[256];
	new count = GetStringTableNumStrings(tblidx);
	new stridx = INVALID_STRING_INDEX;
	new i;
	for (i = 0; i < count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if (StrEqual(tmp, strParticle, false))
		{
			stridx = i;
			break;
		}
	}
	if (stridx == INVALID_STRING_INDEX)
	{
		LogError("Could not find particle: %s", strParticle);
		return;
	}

	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", flStartPos[0]);
	TE_WriteFloat("m_vecOrigin[1]", flStartPos[1]);
	TE_WriteFloat("m_vecOrigin[2]", flStartPos[2] -= 32.0);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	TE_WriteNum("entindex", weapon);
	TE_WriteNum("m_iAttachType", 2);
	TE_WriteNum("m_iAttachmentPointIndex", 0);
	TE_WriteNum("m_bResetParticles", 0);    
	TE_WriteNum("m_bControlPoint1", 1);    
	TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", 5);  
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", flEndPos[0]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", flEndPos[1]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", flEndPos[2]);
	TE_SendToAll();
}
public Action:test(client, args)
{
	decl Float:bosspos[3], Float:targetpos[3], Float:ang[3], Float:rt[3], Float:up[3], Float:targetvector[3];
	
	decl playerarray[MAXPLAYERS + 1];
	new players;
	
	GetClientEyePosition(client, bosspos);
	GetClientAbsAngles(client, ang);
	GetAngleVectors(ang, ang, rt, up);
	
	bosspos[0] += rt[0] * 30.0 - up[0] * 35.0;
	bosspos[1] += rt[1] * 30.0 - up[1] * 35.0;
	bosspos[2] += rt[2] * 30.0 - up[2] * 35.0;
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (AliveCheck(i) && GetClientTeam(client) != GetClientTeam(i)) //77
		{
			GetClientAbsOrigin(i, targetpos);
			targetpos[2] += 40.0;
			if (GetVectorDistance(bosspos, targetpos) <= 900.0)
			{
				MakeVectorFromPoints(bosspos, targetpos, targetvector);
				NormalizeVector(targetvector, targetvector);
				
				playerarray[players] = i; 
				players++;
			}
		}
	}
	
	for (new i; i < players; i++)
	{
		if (i >= 32)
		{
			break;
		}
		SDKHooks_TakeDamage(playerarray[i], client, client, 500.0, DMG_SHOCK);
		
		targetpos[2] -= 20.0;
		TE_Particle("merasmus_zap", bosspos, targetpos, NULL_VECTOR, 
			_,  // entity to attach to
			_,  // start_at_origin(1), start_at_attachment(2), follow_origin(3), follow_attachment(4)
			_,  // attachment point index on entity
			true, 
			0,  // probably 0/1/2
			NULL_VECTOR,  // rgb colors?
			NULL_VECTOR,  // rgb colors?
			0,  // second entity to attach to
			1,  // attach type
			NULL_VECTOR,  // offset to maintain
			GetRandomFloat(0.0, 0.25));
		
		skill(playerarray[i]);
	}
	return Plugin_Handled;
}
stock skill(client)
{
	decl Float:pos[3], Float:ang[3];
	GetClientAbsOrigin(client, pos);
	GetClientAbsAngles(client, ang);
	
	EmitAmbientSound(SOUND_DUCKED, pos);
				
	new prop = CreateEntityByName("prop_physics_override");
	if (prop != -1)
	{
		DispatchKeyValueVector(prop, "origin", pos);
		DispatchKeyValueVector(prop, "angles", ang);
		DispatchKeyValue(prop, "model", MODEL_DUCK);
		DispatchKeyValue(prop, "disableshadows", "1");
					
		decl String:skin[3];
		IntToString(2 + _:TF2_GetPlayerClass(client), skin, sizeof(skin));
		DispatchKeyValue(prop, "skin", skin);
					
		SetEntProp(prop, Prop_Send, "m_CollisionGroup", 1);
		SetEntProp(prop, Prop_Send, "m_usSolidFlags", 16);
					
		DispatchSpawn(prop);
					
		ActivateEntity(prop);
		AcceptEntityInput(prop, "DisableMotion");
		
		CreateTimer(3.0, killll, EntIndexToEntRef(prop), TIMER_FLAG_NO_MAPCHANGE);
					
		// SetEntPropFloat(prop, Prop_Send, "m_flModelScale", DUCK_SCALE);
		new ent = CreateEntityByName("info_particle_system");
		if (ent != -1)
		{
			DispatchKeyValueVector(ent, "origin", pos);
			DispatchKeyValue(ent, "effect_name", "ghost_appearation");
			DispatchSpawn(ent);
					
			ActivateEntity(ent);
			AcceptEntityInput(ent, "Start");
					
			CreateTimer(2.0, killll, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
		}
		ent = CreateEntityByName("info_particle_system");
		if (ent != -1)
		{
			pos[2] += 5.0;
					
			DispatchKeyValueVector(ent, "origin", pos);
			DispatchKeyValue(ent, "effect_name", "unusual_spellbook_circle_purple");
			DispatchSpawn(ent);
					
			ActivateEntity(ent);
			AcceptEntityInput(ent, "Start");
					
			SetVariantString("!activator");
			AcceptEntityInput(ent, "SetParent", prop);
					
			AcceptEntityInput(ent, "SetParentAttachment");
					
			CreateTimer(5.0, killll, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	// new explos = CreateEntityByName("env_explosion");
	// DispatchKeyValue(explos, "RadiusOverride", "120");
	// DispatchKeyValue(explos, "spawnflags", "1");
	// DispatchSpawn(explos);
	// new Float:pos[3];
	// GetClientAbsOrigin(client, pos);
	// TeleportEntity(explos, pos, NULL_VECTOR, NULL_VECTOR);
	// AcceptEntityInput(explos, "Explode");
	// SDKHooks_TakeDamage(client, client, client, 120.0, DMG_CRUSH, 20);
}

stock TE_Particle(String:Name[], Float:origin[3] = NULL_VECTOR, Float:start[3] = NULL_VECTOR, Float:angles[3] = NULL_VECTOR, 
	entindex = -1,  // entity to attach to
	attachtype = -1,  // start_at_origin(1), start_at_attachment(2), follow_origin(3), follow_attachment(4)
	attachpoint = -1,  // attachment point index on entity
	bool:resetParticles = true, 
	customcolors = 0,  // probably 0/1/2
	Float:color1[3] = NULL_VECTOR,  // rgb colors?
	Float:color2[3] = NULL_VECTOR,  // rgb colors?
	controlpoint = -1,  // second entity to attach to
	controlpointattachment = -1,  // attach type
	Float:controlpointoffset[3] = NULL_VECTOR,  // offset to maintain
	Float:delay = 0.0)
{
	// find string table
	new tblidx = FindStringTable("ParticleEffectNames");
	if (tblidx == INVALID_STRING_TABLE)
	{
		LogError("Could not find string table: ParticleEffectNames");
		return;
	}
	
	// find particle index
	new String:tmp[256];
	new count = GetStringTableNumStrings(tblidx);
	new stridx = INVALID_STRING_INDEX;
	new i;
	for (i = 0; i < count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if (StrEqual(tmp, Name, false))
		{
			stridx = i;
			break;
		}
	}
	if (stridx == INVALID_STRING_INDEX)
	{
		LogError("Could not find particle: %s", Name);
		return;
	}
	
	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteFloat("m_vecStart[0]", start[0]);
	TE_WriteFloat("m_vecStart[1]", start[1]);
	TE_WriteFloat("m_vecStart[2]", start[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	if (entindex != -1)
	{
		TE_WriteNum("entindex", entindex);
	}
	if (attachtype != -1)
	{
		TE_WriteNum("m_iAttachType", attachtype);
	}
	if (attachpoint != -1)
	{
		TE_WriteNum("m_iAttachmentPointIndex", attachpoint);
	}
	TE_WriteNum("m_bResetParticles", resetParticles ? 1:0);
	
	if (customcolors)
	{
		TE_WriteNum("m_bCustomColors", customcolors);
		TE_WriteVector("m_CustomColors.m_vecColor1", color1);
		if (customcolors == 2)
		{
			TE_WriteVector("m_CustomColors.m_vecColor2", color2);
		}
	}
	if (controlpoint != -1)
	{
		TE_WriteNum("m_bControlPoint1", controlpoint);
		if (controlpointattachment != -1)
		{
			TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", controlpointattachment);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", controlpointoffset[0]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", controlpointoffset[1]);
			TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", controlpointoffset[2]);
		}
	}
	
	TE_SendToAll(delay);
}

new Float:JumpTime[MAXPLAYERS+1];

public Action:OnPlayerRunCmd(client, &iButtons, &iImpulse, Float:fVel[3], Float:fAng[3], &iWeapon)
{
	// if(IsPlayerAlive(client) && CheckJumpCoolTime(client, 5.0))
	// {
		// decl Float:pos[3];
		// GetClientAbsOrigin(client, pos);
		
		// new Float:vel[3];
		// vel[0] = 0.0;
		// vel[1] = 0.0;
		// vel[2] = 786.0;
		// TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		
		// JumpTime[client] = GetEngineTime();
	// }
}

stock bool:CheckJumpCoolTime(any:iClient, Float:fTime)
{
	if(!AliveCheck(iClient)) return false;
	if(!IsFakeClient(iClient)) return false;
	if(GetEngineTime() - JumpTime[iClient] >= fTime) return true;
	else return false;
}

public Action:box(client, args)
{
	// decl Float:player_pos[3];
	// GetClientAbsOrigin(client, player_pos);
	
	// new iEnt = CreateEntityByName("item_sodacan");
	// DispatchKeyValue(iEnt, "targetname", "tt");
	
	// SetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity", client);
	// SetEntProp(iEnt,	Prop_Send, "m_iTeamNum", GetClientTeam(client));
	
	// DispatchSpawn(iEnt);
	// SetEntityModel(iEnt, BOX);
	
	// player_pos[2] += 50.0;
	
	// TeleportEntity(iEnt, player_pos, NULL_VECTOR, NULL_VECTOR);
	
	// CreateTimer(60.0, killll, EntIndexToEntRef(iEnt));
	return Plugin_Handled;
}

public Action:killll(Handle:timer, any:iEntityRef)
{
	new ent = EntRefToEntIndex(iEntityRef);
	if(!IsValidEntity(ent)) return Plugin_Stop;
	AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}
	
	
public Action:td(client, args)
{
	decl Float:player_pos[3];
	GetClientAbsOrigin(client, player_pos);
	
	new iEnt = CreateEntityByName("tf_projectile_energy_ball");
	DispatchKeyValue(iEnt, "targetname", "asd");
	
	SetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(iEnt,	Prop_Send, "m_iTeamNum", GetClientTeam(client));
	
	DispatchSpawn(iEnt);
	AcceptEntityInput(iEnt, "Enable");
	
	player_pos[2] += 50.0;
	
	TeleportEntity(iEnt, player_pos, NULL_VECTOR, NULL_VECTOR);
	
	CreateTimer(0.01, dd, EntIndexToEntRef(iEnt), TIMER_REPEAT);
	return Plugin_Handled;
}

#define increment 45.0
#define dist 30.0

public Action:dd(Handle:timer, any:iEntityRef)
{
	new ent = EntRefToEntIndex(iEntityRef);
	if(!IsValidEntity(ent)) return Plugin_Stop;
	new client = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if(!AliveCheck(client)) return Plugin_Stop;
	
	decl Float:player_pos[3];
	GetClientAbsOrigin(client, player_pos);
	
	// decl Float:vAngles[3];
	// GetClientAbsOrigin(client, vAngles);

	// decl Float:pos[3];
	// GetEntPropVector(ent, Prop_Data, "m_vecOrigin", pos);
	
	decl Float:vAngles[3];
	// GetEntPropVector(ent, Prop_Data, "m_angRotation", vAngles);
	
	GetClientEyeAngles(client, vAngles); 
	
	vAngles[1] += increment;
	vAngles[1] = fmod(vAngles[1], 360.0);

	new Float:velocity[3];
	GetAngleVectors(player_pos, velocity, NULL_VECTOR, NULL_VECTOR);
	
	new Float:speed = GetVectorLength(velocity); 
	
	velocity[0] = speed*Sine(DegToRad(vAngles[1])) * dist;
	velocity[1] = speed*Cosine(DegToRad(vAngles[1])) * dist;
	velocity[2] = speed*Sine(vAngles[1]); 
	
	TeleportEntity(ent, NULL_VECTOR, vAngles, velocity); 
	
	// pos[0] = player_pos[0] + Sine(DegToRad(vAngles[1])) * dist;
	// pos[1] = player_pos[1] + Cosine(DegToRad(vAngles[1])) * dist;
	// pos[2] = player_pos[2] + 32.0;
	
	// TeleportEntity(ent, pos, vAngles, NULL_VECTOR);
	return Plugin_Continue;
}

stock Float:fmod(Float:lhs, Float:rhs)
{
    return lhs - rhs * RoundFloat(lhs / rhs);
} 
public Action:m_shield(client, args)
{
	decl Float:vpos[3], Float:vAngle[3];
	GetClientEyeAngles(client, vpos);
	GetClientEyePosition(client, vAngle);
	
	int shield = CreateEntityByName("entity_medigun_shield");	
	if(IsValidEntity(shield))
	{
		SetEntPropEnt(shield, Prop_Send, "m_hOwnerEntity", client);  
		SetEntProp(shield, Prop_Send, "m_iTeamNum", GetClientTeam(client));  
		SetEntProp(shield, Prop_Data, "m_iInitialTeamNum", GetClientTeam(client));  
				
		if (TF2_GetClientTeam(client) == TFTeam_Red) 
			DispatchKeyValue(shield, "skin", "0");
		else if (TF2_GetClientTeam(client) == TFTeam_Blue) 
			DispatchKeyValue(shield, "skin", "1");
				
		SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 200.0);
		SetEntProp(client, Prop_Send, "m_bRageDraining", 1);
		SetEntityModel(shield, "models/props_mvm/mvm_player_shield2.mdl");
				
		DispatchSpawn(shield);
		
		SetVariantString("!activator");
		AcceptEntityInput(shield, "SetParent", client);
		
		// SetVariantString("flag");
		// AcceptEntityInput(shield, "SetParentAttachment", client);
		
		// int iLink = CreateEntityByName("tf_taunt_prop");
		// DispatchKeyValue(iLink, "targetname", "DispenserLink");
		// DispatchSpawn(iLink); 
		
		// char strModel[PLATFORM_MAX_PATH];
		// GetEntPropString(client, Prop_Data, "m_ModelName", strModel, PLATFORM_MAX_PATH);
		
		// SetEntityModel(iLink, strModel);
		
		// SetEntProp(iLink, Prop_Send, "m_fEffects", 16|64);
		// SetEntPropEnt(client, Prop_Send, "m_hEffectEntity", iLink);
		
		// SetVariantString("!activator"); 
		// AcceptEntityInput(iLink, "SetParent", client); 
		
		// SetVariantString("flag");
		// AcceptEntityInput(iLink, "SetParentAttachment", client);
	}

	return Plugin_Handled;
}

stock int CreateLink(int iClient)
{
	int iLink = CreateEntityByName("tf_taunt_prop");
	DispatchKeyValue(iLink, "targetname", "DispenserLink");
	DispatchSpawn(iLink); 
	
	char strModel[PLATFORM_MAX_PATH];
	GetEntPropString(iClient, Prop_Data, "m_ModelName", strModel, PLATFORM_MAX_PATH);
	
	SetEntityModel(iLink, strModel);
	
	SetEntProp(iLink, Prop_Send, "m_fEffects", 16|64);
	
	SetVariantString("!activator"); 
	AcceptEntityInput(iLink, "SetParent", iClient); 
	
	SetVariantString("flag");
	AcceptEntityInput(iLink, "SetParentAttachment", iClient);
	
	return iLink;
}

public OnEntityCreated(entity,const String:classname[])
{
	if (IsValidEntity(entity))
	{
		// if (StrEqual(classname, "tf_projectile_pipe")) SDKHook(entity, SDKHook_SpawnPost, pipe);
		if (StrEqual(classname, "tf_projectile_pipe_remote")) SDKHook(entity, SDKHook_StartTouch, remote);

		if (StrContains(classname, "tf_projectile", false) != -1 && !StrEqual(classname, "tf_projectile_rocket"))
		{
			SDKHook(entity, SDKHook_StartTouch, OnStartTouch);
		}
	}
}

public OnGameFrame()
{
	new i = -1; 
	while ((i=FindEntityByClassname(i, "tf_projectile_pipe_remote"))!=INVALID_ENT_REFERENCE)
	{
		new client = GetEntPropEnt(i, Prop_Data, "m_hOwnerEntity");
		
		if(IsValidEntity(client))
		{
			SDKHook(i, SDKHook_SpawnPost, pipe);
		}
	}
}

public pipe(ent)
{
	SetEntPropFloat(ent, Prop_Data, "m_flDetonateTime", GetGameTime() + 6.0);
    // new Float:first = GetEntPropFloat(ent, Prop_Data, "m_flDetonateTime");
    // PrintToChatAll("first = %f", first);
}

public Action:remote(entity, client)
{
	if(AliveCheck(client))
	{
		decl Float:pos[3];
		GetClientAbsOrigin(client, pos);
		
		decl Float:vpos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vpos);
		
		if(GetVectorDistance(pos, vpos) <= 100.0)
		{
			new Float:vel[3];
			vel[0] = 0.0;
			vel[1] = 0.0;
			vel[2] = 768.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
		}
	}
}

public Action:OnStartTouch(entity, other)
{
	if(AliveCheck(other))
	{
		new client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
		if(AliveCheck(client))
		{
			SDKHook(entity, SDKHook_Touch, OnTouch);
		}
	}
	return Plugin_Handled;
}

public Action:OnTouch(entity, other)
{
	decl Float:vOrigin[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vOrigin);
	
	decl Float:vAngles[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", vAngles);
	
	decl Float:vVelocity[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vVelocity);
	
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceRayDontHitEntity, entity);
	
	if(!TR_DidHit(trace))
	{
		CloseHandle(trace);
		return Plugin_Continue;
	}
	
	decl Float:vNormal[3];
	TR_GetPlaneNormal(trace, vNormal);
	
	//PrintToServer("Surface Normal: [%.2f, %.2f, %.2f]", vNormal[0], vNormal[1], vNormal[2]);
	
	CloseHandle(trace);
	
	new Float:dotProduct = GetVectorDotProduct(vNormal, vVelocity);
	
	ScaleVector(vNormal, dotProduct);
	ScaleVector(vNormal, 2.0);
	
	decl Float:vBounceVec[3];
	SubtractVectors(vVelocity, vNormal, vBounceVec);
	
	decl Float:vNewAngles[3];
	GetVectorAngles(vBounceVec, vNewAngles);
	
	TeleportEntity(entity, NULL_VECTOR, vNewAngles, vBounceVec);
	
	SDKUnhook(entity, SDKHook_Touch, OnTouch);
	return Plugin_Handled;
}

public bool TraceRayDontHitEntity(entity, mask, any:data)
{
	if (entity == data) 
		return false;
	
	return true;
}

stock ShootProjectile(client, Float:vPosition[3], Float:vAngles[3] = NULL_VECTOR, String:strEntname[], String:targetname[], Float:Speed, Float:dmg)
{
	new iTeam = GetClientTeam(client);
	new iProjectile = CreateEntityByName(strEntname);
	
	if (!IsValidEntity(iProjectile))
		return -1;
	
	decl Float:vVelocity[3];
	decl Float:vBuffer[3];
	
	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
	
	vVelocity[0] = vBuffer[0]*Speed;
	vVelocity[1] = vBuffer[1]*Speed;
	vVelocity[2] = vBuffer[2]*Speed;
	
	SetEntPropEnt(iProjectile, Prop_Send, "m_hOwnerEntity", client);
	if (IsCritBoosted(client)) SetEntProp(iProjectile, Prop_Send, "m_bCritical", 1);
	else SetEntProp(iProjectile, Prop_Send, "m_bCritical", 0);
	SetEntProp(iProjectile,    Prop_Send, "m_iTeamNum", iTeam, 1);
	SetEntProp(iProjectile,    Prop_Send, "m_nSkin", (iTeam-2));
	DispatchKeyValue(iProjectile, "targetname", targetname);

	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "SetTeam", -1, -1, 0);
	if (strcmp(strEntname, "tf_projectile_rocket", false) == 0) SetEntDataFloat(iProjectile, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, dmg, true);
	else SetEntPropFloat(iProjectile, Prop_Send, "m_flDamage", dmg);
	
	new Float:fRadius = 200.0;

	vPosition[0] = vPosition[0] + fRadius * Cosine(DegToRad(vAngles[1]));
	vPosition[1] = vPosition[1] + fRadius * Sine(DegToRad(vAngles[1]));
	TeleportEntity(iProjectile, vPosition, vAngles, vVelocity); 
	DispatchSpawn(iProjectile);
	return iProjectile;
}


stock bool:IsCritBoosted(client)
{
	if (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged) || TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy) || TF2_IsPlayerInCondition(client, TFCond_CritCanteen) || TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood) || TF2_IsPlayerInCondition(client, TFCond_CritOnWin) || TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture) || TF2_IsPlayerInCondition(client, TFCond_CritOnKill) || TF2_IsPlayerInCondition(client, TFCond_CritMmmph) || TF2_IsPlayerInCondition(client, TFCond_CritOnDamage))
	{
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

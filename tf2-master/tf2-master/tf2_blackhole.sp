#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>

#define Particle_Black "eyeboss_tp_vortex"
#define Particle_Field "eyeboss_doorway_vortex"

new Float:bh_time[MAXPLAYERS+1]
new Float:blackholePos[3];

new g_iPathLaserModelIndex;

new Handle:cvar_bh = INVALID_HANDLE;
new Handle:cvar_bt = INVALID_HANDLE;
new Handle:cvar_fi = INVALID_HANDLE;

public OnPluginStart()
{
	RegAdminCmd("sm_bh", aaaa, ADMFLAG_KICK);
	
	cvar_bh = CreateConVar("sm_blackhole_force", "1000");
	cvar_bt = CreateConVar("sm_blackhole_distance", "800");
	cvar_fi = CreateConVar("sm_field_force", "1000");
}

public OnClientPutInServer(client)
{
	bh_time[client] = 0.0;
}

public OnMapStart()
{
	g_iPathLaserModelIndex = PrecacheModel("materials/sprites/laserbeam.vmt");
}

public Action:aaaa(client, args)
{
	if(args != 1)
	{
		ReplyToCommand(client, "\x03!bh < 1 ~ 25 >");
		return Plugin_Handled;
	}
	
	decl String:arg[10];
	
	GetCmdArg(1, arg, sizeof(arg));
	
	bh_time[client] = StringToFloat(arg);
	
	PrintToChat(client, "지속시간 : %.1f", bh_time[client]);

	return Plugin_Handled;
}

public OnEntityDestroyed(iEntity)
{
	if(!IsValidEdict(iEntity)) return;
	decl String:szBuffer[64];
	GetEdictClassname(iEntity, szBuffer, 64);
	
	if(StrEqual(szBuffer, "tf_projectile_pipe"))
	{
		new client = GetEntPropEnt(iEntity, Prop_Send, "m_hThrower");
		if(!AliveCheck(client))	return;
		if(!IsClientAdmin(client))	return;
		
		GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", blackholePos);
		
		effect(iEntity, blackholePos, bh_time[client], Particle_Black);
	}
	else if(StrEqual(szBuffer, "tf_projectile_pipe_remote"))
	{
		
		new client = GetEntPropEnt(iEntity, Prop_Send, "m_hThrower");
		if(!AliveCheck(client))	return;
		if(!IsClientAdmin(client))	return;
		
		GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", blackholePos);
		
		if(bh_time[client] >= 2)
		{	
			effect(iEntity, blackholePos, bh_time[client], Particle_Field);
			
			int color[4] =  { 0, 0, 255, 255 };
			TE_SetupBeamRingPoint(blackholePos, (300.0 + 80.0)*1.4, (300.0 + 81.0)*1.4, g_iPathLaserModelIndex, g_iPathLaserModelIndex, 0, 15, bh_time[client], 10.0, 10.0, color, 1, 0);
			TE_SendToAll();
		}
		else PrintToChat(client, "지속시간 2초 이상일 경우 가능합니다.");
		// EmitAmbientSoundAny("ambient/energy/force_field_loop1.wav", blackholePos, particle,_,_, 5.0);
	}
	else if(StrEqual(szBuffer, "tf_projectile_syringe"))
	{
		new client = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
		if(!AliveCheck(client))	return;
		if(!IsClientAdmin(client))	return;
		GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", blackholePos);
		SpawnExplosion(iEntity);
	}
	else if(StrEqual(szBuffer, "tf_projectile_flare"))
	{
		new client = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
		if(!AliveCheck(client))	return;
		if(!IsClientAdmin(client))	return;
		GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", blackholePos);
		SpawnImplosion(iEntity);
	}
}

public void OnGameFrame()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if(AliveCheck(client))
		{
			decl Float:clientPos[3], String:szName[128], Float:ParticlePos[3];
			GetClientAbsOrigin(client, clientPos);
			
			int iEnt = MaxClients + 1;
			while((iEnt = FindEntityByClassname(iEnt, "info_particle_system")) != -1)
			{
				GetEntPropString(iEnt, Prop_Data, "m_iszEffectName", szName, 128, 0);
				GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", ParticlePos);
						
				float distance = GetVectorDistance(clientPos, ParticlePos);
				if(distance < 1000)
				{
					if(StrEqual(szName, Particle_Black)) PushPlayersToBlackHole(client, iEnt);		
					else if(StrEqual(szName, Particle_Field)) PushPlayersAwayFromForceField(client, iEnt);
				}
				if(StrEqual(szName, Particle_Black)) PushToBlackHole(iEnt);
				else if(StrEqual(szName, Particle_Field)) PushAwayFromForceField(iEnt);
			}
		}
	}
}
#define blackhole_distance GetConVarInt(cvar_bt)
#define blackhole_force GetConVarInt(cvar_bh)

void PushPlayersToBlackHole(int client, iEnt)
{

	decl Float:clientPos[3], Float:ParticlePos[3];
	GetClientAbsOrigin(client, clientPos);
	
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", ParticlePos);
			
	float distance = GetVectorDistance(clientPos, ParticlePos);

			// if(distance < 20.0)
			// {
				// if(g_hBlackholeshakePlayer.BoolValue)
					// ShakeScreen(client, g_hBlackholeshakeIntensity.FloatValue, 0.1, g_BlackholeFrequency.FloatValue);
								
				// if(g_hBlackholesetting.IntValue == 1)
					// SDKHooks_TakeDamage(client, iBlackhole, iBlackhole, g_BlackholeDamage.FloatValue, DMG_DROWN, -1);
			// }
	if(distance < blackhole_distance)
	{
				// if(g_hBlackholeshakePlayer.BoolValue)
					// ShakeScreen(client, g_hBlackholeshakeIntensity.FloatValue, 0.1, g_BlackholeFrequency.FloatValue);
						
		SetEntPropEnt(client, Prop_Data, "m_hGroundEntity", -1);

		float direction[3];
		SubtractVectors(ParticlePos, clientPos, direction);
					
		float gravityForce = FindConVar("sv_gravity").FloatValue * (((blackhole_force * blackhole_distance / 50) * 20.0) / GetVectorLength(direction,true));
		gravityForce = gravityForce / 20.0;
					
		NormalizeVector(direction, direction);
		ScaleVector(direction, gravityForce);
					
		float playerVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", playerVel);
		NegateVector(direction);
		ScaleVector(direction, distance / 300);
		SubtractVectors(playerVel, direction, direction);
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, direction);
	}
}

void PushToBlackHole(iEnt2)
{
	int iEnt = MaxClients + 1;
	while((iEnt = FindEntityByClassname(iEnt, "tf_projectile_*")) != -1)
	{
		float propPos[3];
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", propPos);
		
		new Float:ParticlePos[3];

		GetEntPropVector(iEnt2, Prop_Send, "m_vecOrigin", ParticlePos);
			
		float distance = GetVectorDistance(propPos, ParticlePos);
		if(distance > 20.0 && distance < blackhole_distance)
		{
			float direction[3];
			SubtractVectors(ParticlePos, propPos, direction);
					
			float gravityForce = FindConVar("sv_gravity").FloatValue * (((blackhole_force * blackhole_distance / 50) * 20.0) / GetVectorLength(direction,true));
			gravityForce = gravityForce / 20.0;
					
			NormalizeVector(direction, direction);
			ScaleVector(direction, gravityForce);
					
			float entityVel[3];
			GetEntPropVector(iEnt, Prop_Data, "m_vecVelocity", entityVel);
			NegateVector(direction);
			ScaleVector(direction, distance / 300);
			SubtractVectors(entityVel, direction, direction);
			TeleportEntity(iEnt, NULL_VECTOR, NULL_VECTOR, direction);
		}
	}
}

#define ForceField_distance 300
#define ForceField_force GetConVarInt(cvar_fi)


void PushPlayersAwayFromForceField(int client, iEnt)
{
	decl Float:clientPos[3], Float:ParticlePos[3];
	GetClientAbsOrigin(client, clientPos);
	
	GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", ParticlePos);
		
	float distance = GetVectorDistance(clientPos, ParticlePos);

	if(distance < ForceField_distance)
	{
		SetEntPropEnt(client, Prop_Data, "m_hGroundEntity", -1);
					
		float direction[3];
		SubtractVectors(ParticlePos, clientPos, direction);
					
		float gravityForce = FindConVar("sv_gravity").FloatValue * (((ForceField_force * ForceField_distance / 50) * 20.0) / GetVectorLength(direction,true));
		gravityForce = gravityForce / 20.0;
					
		NormalizeVector(direction, direction);
		ScaleVector(direction, gravityForce);
					
		float playerVel[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", playerVel);

		ScaleVector(direction, distance / 300);
		SubtractVectors(playerVel, direction, direction);
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, direction);
	}
}

void PushAwayFromForceField(iEnt2)
{
	int iEnt = MaxClients + 1;
	while((iEnt = FindEntityByClassname(iEnt, "tf_projectile_*")) != -1)
	{
		decl Float:propPos[3], Float:ParticlePos[3];
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", propPos);
		
		GetEntPropVector(iEnt2, Prop_Send, "m_vecOrigin", ParticlePos);
						
		float distance = GetVectorDistance(propPos, ParticlePos);
		if(distance < ForceField_distance)
		{
			float direction[3];
			SubtractVectors(ParticlePos, propPos, direction);
								
			float gravityForce = FindConVar("sv_gravity").FloatValue * (((ForceField_force * ForceField_distance / 50) * 20.0) / GetVectorLength(direction,true));
			gravityForce = gravityForce / 20.0;
								
			NormalizeVector(direction, direction);
			ScaleVector(direction, gravityForce);
								
			float entityVel[3];
			GetEntPropVector(iEnt, Prop_Data, "m_vecVelocity", entityVel);
					
			ScaleVector(direction, distance / 300);
			SubtractVectors(entityVel, direction, direction);
			TeleportEntity(iEnt, NULL_VECTOR, NULL_VECTOR, direction);
		}
	}
}

//--

#define Explosion_disance 300
#define Explosion_force 800.0

stock SpawnExplosion(int entity)
{
	// int owner = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(owner < 1 || owner > MaxClients)
		return;
	if(!IsClientInGame(owner))
		return;
	 
	AcceptEntityInput(entity, "Kill")
	
	new particle = effect(entity, blackholePos, bh_time[owner], "xms_snowburst");
	
	for (int client = 1; client <= MaxClients; client++)
	{
		if(AliveCheck(client))
		{
			float clientPos[3], explosionPos[3];
			GetClientAbsOrigin(client, clientPos);
			GetEntPropVector(particle, Prop_Send, "m_vecOrigin", explosionPos);
			clientPos[2] += 30.0;
			float distance = GetVectorDistance(clientPos, explosionPos);
		
			if(distance < Explosion_disance)
			{
				SetEntPropEnt(client, Prop_Data, "m_hGroundEntity", -1);
				float direction[3];
				SubtractVectors(clientPos, explosionPos, direction);
				NormalizeVector(direction, direction);
				if (distance <= 20.0) distance = 20.0;
				ScaleVector(direction, Explosion_force);
		
				float playerVel[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", playerVel);
				AddVectors(playerVel, direction, direction);
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, direction);
			}
		}
	}
	PushAwayFromExplosion(particle);
}

stock PushAwayFromExplosion(int entity)
{
	int iEnt = MaxClients + 1;
	while((iEnt = FindEntityByClassname(iEnt, "tf_projectile_*")) != -1)
	{
		float propPos[3], entityPos[3];
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", propPos);
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityPos);
		entityPos[2] -= 30.0;
		float distance = GetVectorDistance(propPos, entityPos);
		if(distance < Explosion_disance)
		{
			float direction[3];
			SubtractVectors(propPos, entityPos, direction);
			NormalizeVector(direction, direction);
			if (distance <= 20.0) distance = 20.0;
			ScaleVector(direction, Explosion_force);

			float propVel[3];
			GetEntPropVector(iEnt, Prop_Data, "m_vecVelocity", propVel);
			AddVectors(propVel, direction, direction);

			TeleportEntity(iEnt, NULL_VECTOR, NULL_VECTOR, direction);
		}
	}
}

//---

#define Implosion_distance 1000

stock SpawnImplosion(int entity)
{
	// int owner = GetEntPropEnt(entity, Prop_Data, "m_hThrower");
	int owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(owner < 1 || owner > MaxClients)
		return;
	if(!IsClientInGame(owner))
		return;
	
	new particle = effect(entity, blackholePos, bh_time[owner], "xms_snowburst");

	for (int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client))
		{
			int ownerteam = GetClientTeam(owner);
			if((ownerteam != GetClientTeam(client)) || client == owner)
			{
				float clientPos[3], implosionPos[3];
				GetClientAbsOrigin(client, clientPos);
				GetEntPropVector(particle, Prop_Send, "m_vecOrigin", implosionPos);
					
				float distance = GetVectorDistance(clientPos, implosionPos);
		
				if(distance < Implosion_distance)
				{
					SetEntPropEnt(client, Prop_Data, "m_hGroundEntity", -1);
					float direction[3];
					SubtractVectors(implosionPos, clientPos, direction);
		
					direction[2] +=  (200.0 + (distance * 0.6));
					TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, direction);
				}
			}
		}
	}
	
	PushToImplosion(particle);
}

stock PushToImplosion(int entity)
{
	int iEnt = MaxClients + 1;
	while((iEnt = FindEntityByClassname(iEnt, "tf_projectile_*")) != -1)
	{
		float propPos[3], entityPos[3];
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", propPos);
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityPos);
		
		float distance = GetVectorDistance(propPos, entityPos);
		if(distance < Implosion_distance)
		{
			float direction[3];
			SubtractVectors(entityPos, propPos, direction);
			
			direction[2] +=  (200.0 + (distance * 0.4));
			TeleportEntity(iEnt, NULL_VECTOR, NULL_VECTOR, direction);
		}
	}
}


stock effect(entity, Float:pos[3], Float:time, String:effect[], bool:pp = false)
{
	new ent = CreateEntityByName("info_particle_system");
	if (ent != -1)
	{
		DispatchKeyValueVector(ent, "origin", pos);
		DispatchKeyValue(ent, "effect_name", effect);
		DispatchSpawn(ent);
					
		ActivateEntity(ent);
		AcceptEntityInput(ent, "Start");
		
		if(pp)
		{
			SetVariantString("!activator");
			AcceptEntityInput(ent, "SetParent", entity);
		}
					
		CreateTimer(time, DeleteParticle, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
	}
	return ent;
}

public Action:DeleteParticle(Handle:timer, any:pc)
{
    if (IsValidEntity(pc))
    {
        new String:classN[64];
        GetEdictClassname(pc, classN, sizeof(classN));
        if (StrEqual(classN, "info_particle_system", false))
        {
            RemoveEdict(pc);
        }
    }
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


stock bool:IsClientAdmin(client)
{
	new AdminId:Cl_ID;
	Cl_ID = GetUserAdmin(client);
	if(Cl_ID != INVALID_ADMIN_ID)
		return true;
	return false;
}

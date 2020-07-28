#include <sdktools>
#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2>

public OnMapStart()
{
	PrecacheSound("take/hanzo.mp3", true);
	AddFileToDownloadsTable("sound/take/hanzo.mp3");
}


public OnEntityCreated(entity,const String:classname[])
{
	if (IsValidEntity(entity))
	{
		if (StrEqual(classname, "tf_projectile_arrow", false))
		{
			SDKHook(entity, SDKHook_Spawn, soldier);
		}
	}
}

public soldier(iEntity)
{
	SetEntityMoveType(iEntity, MOVETYPE_NOCLIP);
	EmitSoundToAll("take/hanzo.mp3");
	
	CreateParticle("ghost_firepit", 2.0, iEntity, 1);
	CreateTimer(0.1, ThinkHook, EntIndexToEntRef(iEntity), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:ThinkHook(Handle:hTimer, any:iEntityRef)
{
	new ent = EntRefToEntIndex(iEntityRef);
	if(!IsValidEntity(ent)) return Plugin_Stop;
	new client = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if(!AliveCheck(client)) return Plugin_Stop;
	
	decl Float:pos[3];
	GetEntPropVector(ent, Prop_Data, "m_vecOrigin", pos);
	
	if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Sniper)
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			if(AliveCheck(i) && GetClientTeam(client) != GetClientTeam(i))
			{
				new Float:vEPosit[3], Float:Dist;
				GetClientAbsOrigin(i, vEPosit);
				Dist = GetVectorDistance(pos, vEPosit);
				if(Dist <= 400.0) SlapPlayer(i, 999);//ForcePlayerSuicide(i);
			}
		}
	}
	CreateTimer(2.0, killll, EntIndexToEntRef(ent));
	return Plugin_Continue;
}

public Action:killll(Handle:timer, any:iEntityRef)
{
	new ent = EntRefToEntIndex(iEntityRef);
	if(!IsValidEntity(ent)) return Plugin_Stop;
	AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}

stock Handle:CreateParticle(String:type[], Float:time, entity, attach=0, Float:xOffs=0.0, Float:yOffs=0.0, Float:zOffs=0.0)
{
	if(IsValidEntity(entity))
	{
		new particle = CreateEntityByName("info_particle_system");
		if (IsValidEdict(particle)) {
			decl Float:pos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			pos[0] += xOffs;
			pos[1] += yOffs;
			pos[2] += zOffs;
			TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(particle, "effect_name", type);

			if (attach != 0) {
				SetVariantString("!activator");
				AcceptEntityInput(particle, "SetParent", entity, particle, 0);

				if (attach == 2) {
					SetVariantString("head");
					AcceptEntityInput(particle, "SetParentAttachmentMaintainOffset", particle, particle, 0);
				}
			}
			DispatchKeyValue(particle, "targetname", "present");
			DispatchSpawn(particle);
			ActivateEntity(particle);
			AcceptEntityInput(particle, "Start");
			return CreateTimer(time, DeleteParticle, particle);
		} else {
			LogError("(CreateParticle): Could not create info_particle_system");
		}
	}

	return INVALID_HANDLE;
}

public Action:DeleteParticle(Handle:timer, any:particle)
{
	if (IsValidEdict(particle))
	{
		new String:classname[64];
		GetEdictClassname(particle, classname, sizeof(classname));

		if (StrEqual(classname, "info_particle_system", false))
			RemoveEdict(particle);
	}
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

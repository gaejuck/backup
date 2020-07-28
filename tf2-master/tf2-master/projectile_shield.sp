#include <sourcemod>
#include <sdktools>
#include <tf2>

#define SOUND_PYRO_AIRBLAST_REFLECT		"weapons/flame_thrower_airblast_rocket_redirect.wav"

// #define MODEL_CRAP "models/player/scout.mdl"
// #define SOUND_CAGECLOSE					"doors/door_chainlink_close1.wav"
public OnMapStart()
{
	PrecacheSound(SOUND_PYRO_AIRBLAST_REFLECT, true);
	// PrecacheSound(SOUND_CAGECLOSE, true);
	// PrecacheModel(MODEL_CRAP, true);
}

public Action:OnPlayerRunCmd(client, &iButtons, &iImpulse, Float:fVel[3], Float:fAng[3], &iWeapon)
{
	if(AliveCheck(client) && IsFakeClient(client))
	{
		new entityCount = GetEntityCount();
		new ent = 0;
		new Float:pos[3];
		new Float:clientPos[3];
		new Float:distance;
		new projectileOwner;
		new String:classname[128];
		new projectileTeam;
		new builder;
		new Float:RocketPos[3];
		new Float:RocketAng[3];
		new Float:RocketVec[3];
		new Float:newRocketVec[3];
		new remote_touched;
		new Float:RocketSpeed;
		
		while(ent < entityCount)
		{
			ent++;
			if(IsValidEntity(ent))
			{
				GetEdictClassname(ent, classname, sizeof(classname));
				if(StrContains(classname, "projectile", false) != -1 && StrContains(classname, "syringe", false) == -1 && !StrEqual(classname, "tf_projectile_energy_ring", false))
				{
					if(StrContains(classname, "pipe", false) != -1 || StrContains(classname, "jar", false) != -1 || StrContains(classname, "stun_ball", false) != -1
						|| StrContains(classname, "cleaver", false) != -1 || StrContains(classname, "ball_ornament", false) != -1)
						projectileOwner = GetEntPropEnt(ent, Prop_Data, "m_hThrower");
					else projectileOwner = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity");
					
					if(projectileOwner > MaxClients)
					{
						builder = GetEntDataEnt2(projectileOwner, FindSendPropInfo("CObjectSentrygun","m_hBuilder"));
						if(builder > 0 && builder <= MaxClients)
						{
							if(IsClientInGame(client))
							{
								projectileTeam = GetClientTeam(builder);
							}
						}
					}
					else if(projectileOwner != -1)
					{
						projectileTeam = GetClientTeam(projectileOwner);
					}
					
					GetClientEyePosition(client, clientPos);
					GetEntPropVector(ent, Prop_Data, "m_vecOrigin", pos);
					distance = GetVectorDistance(clientPos, pos);
//190
					if(distance < 230.0 && projectileOwner != client && projectileTeam != GetClientTeam(client))
					{
						remote_touched = 0;
						
						GetEntPropVector(ent, Prop_Data, "m_vecAbsOrigin", RocketPos);
						GetEntPropVector(ent, Prop_Data, "m_angRotation", RocketAng);
						GetEntPropVector(ent, Prop_Data, "m_vecAbsVelocity", RocketVec);
						
						RocketSpeed = GetVectorLength(RocketVec);
						
						if(projectileOwner > 0 && projectileOwner <= MaxClients)
						{
							GetClientEyePosition(projectileOwner, clientPos);
						}
						else if(projectileOwner != -1)
						{
							if(IsValidEntity(projectileOwner))
								GetEntPropVector(projectileOwner, Prop_Data, "m_vecAbsOrigin", clientPos);
						}

						SubtractVectors(clientPos, RocketPos, newRocketVec);

						NormalizeVector(newRocketVec, newRocketVec);
						
						if(StrContains(classname, "pipe", false) != -1 || StrContains(classname, "jar", false) != -1 || StrContains(classname, "stun_ball", false) != -1
							|| StrContains(classname, "cleaver", false) != -1 || StrContains(classname, "ball_ornament", false) != -1)
						{
							if(StrContains(classname, "pipe_remote", false) != -1) remote_touched = GetEntProp(ent, Prop_Send, "m_bTouched");
							else
							{
								SetEntProp(ent, Prop_Send, "m_iDeflected", GetEntProp(ent, Prop_Send, "m_iDeflected")+1);
								SetEntProp(ent, Prop_Send, "m_iTeamNum", GetClientTeam(client));
								SetEntPropEnt(ent, Prop_Data, "m_hThrower", client);
								SetEntPropEnt(ent, Prop_Send, "m_hDeflectOwner", client);
							}
							ScaleVector(newRocketVec, 500.0);
							TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, newRocketVec);
						}
						else
						{
						
							SetEntProp(ent, Prop_Send, "m_iDeflected", GetEntProp(ent, Prop_Send, "m_iDeflected")+1);
							SetEntProp(ent, Prop_Send, "m_iTeamNum", GetClientTeam(client));
							SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
							GetVectorAngles(newRocketVec, RocketAng);
							SetEntPropVector (ent, Prop_Data, "m_angRotation", RocketAng);
							ScaleVector(newRocketVec, RocketSpeed);
							SetEntPropVector(ent, Prop_Data, "m_vecAbsVelocity", newRocketVec);
						}

						if(!remote_touched)
						{
							AttachTempParticle(ent, "pyro_blast", 3.0, false, "", 0.0, false);
							EmitSoundToAll(SOUND_PYRO_AIRBLAST_REFLECT, ent, SNDCHAN_AUTO);
						}
					}
				}
			}
		}
	}
	// else
	// {
		// KillTimer(Timer);
	// }
}

public AttachTempParticle(entity, String:particleType[], Float:lifetime, bool:parent, String:parentName[], Float:zOffset, bool:randOffset)
{	
	new particle = CreateEntityByName("info_particle_system");
	if (IsValidEdict(particle))
	{	
		//set the bloods entity
		DispatchKeyValue(particle, "targetname", "tf2particle");
		SetEntPropEnt(particle, Prop_Data, "m_hOwnerEntity", entity);
		
		new Float: particlePos[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", particlePos);
		
		new Float: particleAng[3];
		GetEntPropVector(entity, Prop_Data, "m_angRotation", particleAng);
		if(randOffset)
		{
			particlePos[0] += GetRandomInt(-40,40);
			particlePos[1] += GetRandomInt(-40,40);
			particlePos[2] += GetRandomInt(-40,40);
		}else{
			particlePos[2] += zOffset;
		}
		
		TeleportEntity(particle, particlePos, particleAng, NULL_VECTOR);
		
		DispatchKeyValue(particle, "effect_name", particleType);
		
		DispatchKeyValue(particle, "parentname", parentName);
		DispatchSpawn(particle);
		
		if(parent)
		{
			SetVariantString(parentName);
			AcceptEntityInput(particle, "SetParent");
			
			//for the medic, lets get this point outta here
			//DispatchKeyValue(particle, "cpoint1", parentName);
			//DispatchKeyValue(particle, "cpoint2", parentName);
		}
		
		
		// send "kill" event to the event queue
		killEntityIn(particle, lifetime);
		
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
	}
	
	return particle;
}

public killEntityIn(entity, Float:seconds)
{
	if(IsValidEdict(entity))
	{
		new String:addoutput[64];
		Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::%f:1",seconds);
		SetVariantString(addoutput);
		AcceptEntityInput(entity, "AddOutput");
		AcceptEntityInput(entity, "FireUser1");
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

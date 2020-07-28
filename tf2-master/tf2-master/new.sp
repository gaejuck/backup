#include <sdktools>
#include <sourcemod>
#include <sdkhooks>

new OffAW                                = -1;

public OnPluginStart()
{
	OffAW = FindSendPropInfo("CBasePlayer", "m_hActiveWeapon");
}
stock SpawnJar(client, Float:tspeed)
{
	new Float:gnSpeed = tspeed;
	
	new Float:startpt[3], Float:angle[3], Float:speed[3], loat:playerspeed[3];
	
	GetClientEyePosition(client, startpt);
	GetClientEyeAngles(client, angle);
	GetAngleVectors(angle, speed, NULL_VECTOR, NULL_VECTOR);
	speed[2] += 0.2;
	speed[0]*=gnSpeed; speed[1]*=gnSpeed; speed[2]*=gnSpeed;
	
	GetEntPropVector(client, Prop_Data, "m_vecVelocity", playerspeed);
	AddVectors(speed, playerspeed, speed);
	
	new ent = CreateEntityByName("tf_projectile_jar");
	if ( ent == -1 )
	{
		ReplyToCommand(client, "Failed to create Crap!");
		return;
	}
	
	SetEntProp(ent, Prop_Data, "m_takedamage", 2);
	
	DispatchSpawn(ent);
	SetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity", client);
	
	decl String:crapName[32];
	Format(crapName, 32, "crap_%i", ent);
	DispatchKeyValue(ent, "targetname", crapName);
	
	new iTeam = GetEntProp(client, Prop_Data, "m_iTeamNum");
	SetVariantInt(iTeam);
	
	AcceptEntityInput(ent, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);
	AcceptEntityInput(ent, "SetTeam", -1, -1, 0);
	
	
	SetEntProp(ent, Prop_Data, "m_takedamage", 2);
	SetEntProp(ent, Prop_Data, "m_takedamage", 2);
	SetEntProp(ent, Prop_Data, "m_iMaxHealth", 1);
	SetEntProp(ent, Prop_Data, "m_iHealth", 1);
	
	AcceptEntityInput(ent, "DisableCollision");
	AcceptEntityInput(ent, "EnableCollision");
	
	TeleportEntity(ent, startpt, NULL_VECTOR, speed);
	
	return;
}

stock SetRateFire(client, Float:Time)
{
	new Float:Amount = 1.0;
	new ent = GetEntDataEnt2(client, OffAW);
	if (ent != -1)
	{
		new Float:m_flNextPrimaryAttack = GetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack");
		new Float:m_flNextSecondaryAttack = GetEntPropFloat(ent, Prop_Send, "m_flNextSecondaryAttack");
		
		if (Amount > 12) SetEntPropFloat(ent, Prop_Send, "m_flPlaybackRate", 12.0);
		else SetEntPropFloat(ent, Prop_Send, "m_flPlaybackRate", Amount);

		new Float:GameTime = GetGameTime();
		new Float:PeTime = (m_flNextPrimaryAttack - GameTime) - ((Amount - 1.0) / 50);
		new Float:SeTime = (m_flNextSecondaryAttack - GameTime) - ((Amount - 1.0) / 50);
		
		new Float:FinalP = PeTime+GameTime;
		new Float:FinalS = SeTime+GameTime;
		
		SetEntPropFloat(ent, Prop_Send, "m_flNextPrimaryAttack", FinalP + Time);
		SetEntPropFloat(ent, Prop_Send, "m_flNextSecondaryAttack", FinalS + Time);
	}
}

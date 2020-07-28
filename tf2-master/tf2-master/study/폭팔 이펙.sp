#include <sdkhooks> 
#include <sdktools> 

public OnPluginStart()
{
	RegConsoleCmd("sm_tt", bbbbb);
}

public Action:bbbbb(client, args)
{
	new Float:flPos[3];
	GetClientEyeAngles(client,flPos);
	Explode(flPos, 50.0, 500.0, "halloween_explosion", "ui/duel_challenge_rejected_with_restriction.wav");
}

stock Explode(Float:flPos[3], Float:flDamage, Float:flRadius, const String:strParticle[], const String:strSound[])
{
    new iBomb = CreateEntityByName("tf_generic_bomb");
    DispatchKeyValueVector(iBomb, "origin", flPos);
    DispatchKeyValueFloat(iBomb, "damage", flDamage);
    DispatchKeyValueFloat(iBomb, "radius", flRadius);
    DispatchKeyValue(iBomb, "health", "1");
    DispatchKeyValue(iBomb, "explode_particle", strParticle);
    DispatchKeyValue(iBomb, "sound", strSound);
    DispatchSpawn(iBomb);

    AcceptEntityInput(iBomb, "Detonate");
}  


public Action:BigExplode(Handle:timer, Handle:Pack)
{
	ResetPack(Pack);
	new Float:radius = ReadPackFloat(Pack);
//	new CountExplode = ReadPackCell(Pack);
	new Float:fDamage = ReadPackFloat(Pack);
	new boss = ReadPackCell(Pack);
	new iEnt = ReadPackCell(Pack);

//	static countx = 0;
	new particle = CreateEntityByName("info_particle_system");
//	PrintToChatAll("폭");
/*	if(countx > CountExplode) {
		countx = 0;
		return Plugin_Stop;
	}*/

	if(IsValidEntity(particle)) {
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", boss);
//		fMisslePos[2] += 20;
		TeleportEntity(particle, fMisslePos, NULL_VECTOR, NULL_VECTOR);
//		DispatchKeyValue(particle, "effect_name", "cinefx_goldrush");
		DispatchKeyValue(particle, "effect_name", "fireSmokeExplosion_trackb");
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(0.1, DeleteParticles, particle);

		if(!IsSoundPrecached(BOMB_SOUND)) PrecacheSound(BOMB_SOUND);

		PrefetchSound(BOMB_SOUND);
		EmitAmbientSound(BOMB_SOUND, fMisslePos, boss, SNDLEVEL_SCREAMING);
		AdmDamage(fMisslePos, particle, radius, fDamage, boss, iEnt);
//		PrintToChatAll("8");
	}
	return Plugin_Continue;
}

stock AdmDamage(Float:po[3], any:ent, Float:radius, Float:dmg, any:Boss, any:iEnt)
{
	if((IsValidEntity(ent) && IsValidEdict(ent))) {
		for(new i = 1 ; i <= MaxClients ; i++) {
			if(IsClientInGame(i) && IsPlayerAlive(i) && (GetClientTeam(i) != GetClientTeam(Boss))) {
				new Float:pos[3], Float:dist;

				GetClientAbsOrigin(i, pos);
				dist = GetVectorDistance(pos, po);

				if(dist <= radius) {
					new Handle:Tracing = TR_TraceRayFilterEx(po, pos, MASK_PLAYERSOLID, RayType_EndPoint, AllowPlayers, iEnt); //MASK_SOLID MASK_PLAYERSOLID
					new index = TR_GetEntityIndex(Tracing);
					if(index == i) {
						new Float:damage, attacker;
						damage = dmg * ((radius - dist) / radius);
						attacker = Boss;
						if(i != Boss) SDKHooks_TakeDamage(i, attacker, attacker, damage, (1 << 3));
						hitSentry(po, _:damage, radius);
						continue;
					}
					CloseHandle(Tracing);
				}
			}
		}
	}
}

public bool:AllowPlayers(entity, mask, any:data)
{
	if(entity == data) return false;
	return entity > 0 && entity <= MaxClients;
}

stock hitSentry(Float:xyz[3], damage, Float:radius)
{
	new Float:pos2[3], Float:distance;
	new ent = -1;
	while((ent = FindEntityByClassname2(ent, "obj_sentrygun")) != -1) {
//		new client = GetEntPropEnt(ent, Prop_Send, "m_hBuilder");
		GetEntityAbsOrigin(ent, pos2);
		distance = GetVectorDistance(xyz, pos2);
		if(distance <= radius) {
			SetVariantInt(9999);
			AcceptEntityInput(ent, "RemoveHealth");
		}
	}

	ent = -1;
	while((ent = FindEntityByClassname2(ent, "obj_dispenser")) != -1) {
//		new client = GetEntPropEnt(ent, Prop_Send, "m_hBuilder");
		GetEntityAbsOrigin(ent, pos2);
		distance = GetVectorDistance(xyz, pos2);
		if(distance <= radius) {
			SetVariantInt(9999);
			AcceptEntityInput(ent, "RemoveHealth");
		}
	}

	ent = -1;
	while((ent = FindEntityByClassname2(ent, "obj_teleporter")) != -1) {
//		new client = GetEntPropEnt(ent, Prop_Send, "m_hBuilder");
		GetEntityAbsOrigin(ent, pos2);
		distance = GetVectorDistance(xyz, pos2);
		if(distance <= radius) {
			SetVariantInt(9999);
			AcceptEntityInput(ent, "RemoveHealth");
		}
	}
}
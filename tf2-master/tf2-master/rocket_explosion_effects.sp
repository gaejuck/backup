#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>

new RocketEffect[MAXPLAYERS+1];
new RocketEffectCount[MAXPLAYERS+1];

public OnPluginStart()
{
	RegConsoleCmd("sm_exp", rocket);
}

public OnClientPutInServer(client)
{
	RocketEffect[client] = 0;
	RocketEffectCount[client] = 3;
}

public Action:rocket(client, args)
{
	if(args < 1)
	{
		PrintToChat(client, "\x03sm_exp < effect: 1 ~ 3 > < count: 1 ~ 3 >");
		return Plugin_Handled;
	}
	
	decl String:Effect[10], String:EffectCount[10];
	GetCmdArg(1, Effect, sizeof(Effect));
	GetCmdArg(2, EffectCount, sizeof(EffectCount));
	
	if(StrEqual(Effect, "1"))
	{
		PrintToChat(client, "\x04Rocket Effect : +");
	}
	else if(StrEqual(Effect, "2"))
	{
		PrintToChat(client, "\x04Rocket Effect : x");
	}
	
	else if(StrEqual(Effect, "3"))
	{
		PrintToChat(client, "\x04Rocket Effect : *");
	}
	
	if(StrEqual(EffectCount, ""))
	{
		RocketEffectCount[client] = 3;
	}
	else 
	{
		RocketEffectCount[client] = StringToInt(EffectCount);
		PrintToChat(client, "\x04Rocket Count : %d", RocketEffectCount[client]);
	}
	
	RocketEffect[client] = StringToInt(Effect);
	
	
	return Plugin_Handled;
}

public OnEntityDestroyed(iEntity)
{
	if(!IsValidEdict(iEntity)) return;
	decl String:szBuffer[64];
	GetEdictClassname(iEntity, szBuffer, 64);
	if(!StrEqual(szBuffer, "tf_projectile_rocket")) return;
	
	new client = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
	if(!AliveCheck(client))	return;
	
	for(new i = 0; i <= 4; i++) exex2(client, iEntity, i, 90.0, 120.0, "");
}

stock exex2(client, entity, select, Float:dmg, Float:radius, String:effect[])
{
	decl Float:pos[3];
	new Float:pos2[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos2);
	
	
	if(RocketEffect[client] == 1 || RocketEffect[client] == 3)
	{
		if(select == 1)
		{
			for(new i = 0; i <= RocketEffectCount[client]; i++)
			{
				switch(i)
				{	 
					case 0: pos[1] += 130.0;
					case 1: pos[1] += 150.0;
					case 2: pos[1] += 170.0;
					case 3: pos[1] += 190.0;
				}
				new ent = Explode(client, pos, 0.0, radius, effect, ""); 
				AdmDamage(pos, ent, radius, dmg, client, entity);
			}
		}
		
		else if(select == 2)
		{
			for(new i = 0; i <= RocketEffectCount[client]; i++)
			{
				switch(i)
				{
					case 0: pos[1] -= 130.0;
					case 1: pos[1] -= 150.0;
					case 2: pos[1] -= 170.0;
					case 3: pos[1] -= 190.0;
				}
				new ent = Explode(client, pos, 0.0, radius, effect, "");
				AdmDamage(pos, ent, radius, dmg, client, entity);
			}
		}
		
		if(select == 3)
		{
			for(new i = 0; i <= RocketEffectCount[client]; i++)
			{
				switch(i)
				{
					case 0: pos[0] += 130.0;
					case 1: pos[0] += 150.0;
					case 2: pos[0] += 170.0;
					case 3: pos[0] += 190.0;
				}
				new ent = Explode(client, pos, 0.0, radius, effect, "");
				AdmDamage(pos, ent, radius, dmg, client, entity);
			}
		}
		else if(select == 4)
		{
			for(new i = 0; i <= RocketEffectCount[client]; i++)
			{
				switch(i)
				{
					case 0: pos[0] -= 130.0;
					case 1: pos[0] -= 150.0;
					case 2: pos[0] -= 170.0;
					case 3: pos[0] -= 190.0;
				}
				new ent = Explode(client, pos, 0.0, radius, effect, "");
				AdmDamage(pos, ent, radius, dmg, client, entity);
			}
		}
	}
	
	if(RocketEffect[client] == 2 || RocketEffect[client] == 3)
	{
		if(select == 1)
		{
			for(new i = 0; i <= RocketEffectCount[client]; i++)
			{
				switch(i)
				{
					case 0:
					{
						pos2[0] += 130.0;
						pos2[1] += 130.0;
					}
					
					case 1:
					{
						pos2[0] += 150.0;
						pos2[1] += 150.0;
					}
					
					case 2:
					{
						pos2[0] += 170.0;
						pos2[1] += 170.0;
					}
					case 3:
					{
						pos2[0] += 190.0;
						pos2[1] += 190.0;
					}
				}
				new ent = Explode(client, pos2, 0.0, radius, effect, ""); 
				AdmDamage(pos2, ent, radius, dmg, client, entity);
			}
		}
		else if(select == 2)
		{
			for(new i = 0; i <= RocketEffectCount[client]; i++)
			{

				switch(i)
				{
					case 0:
					{
						pos2[0] -= 130.0;
						pos2[1] -= 130.0;
					}
					
					case 1:
					{
						pos2[0] -= 150.0;
						pos2[1] -= 150.0;
					}
					
					case 2:
					{
						pos2[0] -= 170.0;
						pos2[1] -= 170.0;
					}
					case 3:
					{
						pos2[0] -= 190.0;
						pos2[1] -= 190.0;
					}
				}
				new ent = Explode(client, pos2, 0.0, radius, effect, ""); 
				AdmDamage(pos2, ent, radius, dmg, client, entity);
			}
		}
		
		if(select == 3)
		{
			for(new i = 0; i <= RocketEffectCount[client]; i++)
			{

				switch(i)
				{
					case 0:
					{
						pos2[0] += 130.0;
						pos2[1] -= 130.0;
					}
					
					case 1:
					{
						pos2[0] += 150.0;
						pos2[1] -= 150.0;
					}
					
					case 2:
					{
						pos2[0] += 170.0;
						pos2[1] -= 170.0;
					}
					case 3:
					{
						pos2[0] += 190.0;
						pos2[1] -= 190.0;
					}
				}
				new ent = Explode(client, pos2, 0.0, radius, effect, ""); 
				AdmDamage(pos2, ent, radius, dmg, client, entity);
			}
		}
		else if(select == 4)
		{
			for(new i = 0; i <= RocketEffectCount[client]; i++)
			{
				switch(i)
				{
					case 0:
					{
						pos2[0] -= 130.0;
						pos2[1] += 130.0;
					}
					
					case 1:
					{
						pos2[0] -= 150.0;
						pos2[1] += 150.0;
					}
					
					case 2:
					{
						pos2[0] -= 170.0;
						pos2[1] += 170.0;
					}
					case 3:
					{
						pos2[0] -= 190.0;
						pos2[1] += 190.0;
					} 
				}
				new ent = Explode(client, pos2, 0.0, radius, effect, ""); 
				AdmDamage(pos2, ent, radius, dmg, client, entity);
			}
		}
	}/*
	if(RocketEffect[client] == 4)
	{
		if(select == 1)
		{
			for(new i = 0; i <= RocketEffectCount[client]; i++)
			{
				switch(i)
				{
					case 0: pos[1] += 130.0;
					case 1: pos[1] += 150.0;
					case 2: pos[1] += 170.0;
					case 3: pos[1] += 190.0;
				}
				new ent = Explode(client, pos, 0.0, radius, effect, ""); 
				AdmDamage(pos, ent, radius, dmg, client, entity);
			}
		}
		if(select == 2)
		{
			for(new i = 0; i <= RocketEffectCount[client]; i++)
			{
				switch(i)
				{
					case 0:
					{
						pos[0] += 130.0;
						pos[1] += 130.0;
					}
					
					case 1:
					{
						pos[0] += 150.0;
						pos[1] += 150.0;
					}
					
					case 2:
					{
						pos[0] += 170.0;
						pos[1] += 170.0;
					}
					
					case 3:
					{
						pos[0] += 190.0;
						pos[1] += 190.0;
						
					}
				}
				new ent = Explode(client, pos, 0.0, radius, effect, ""); 
				AdmDamage(pos, ent, radius, dmg, client, entity);
			}
		}
		
		if(select == 3)
		{
			for(new i = 0; i <= RocketEffectCount[client]; i++)
			{
				switch(i)
				{
					case 0:
					{
						pos[0] -= 130.0;
						pos[1] += 130.0;
					}
					
					case 1: pos[1] += 150.0;
					case 2: pos[1] += 170.0;
					case 3: pos[1] += 170.0;
				}
				new ent = Explode(client, pos, 0.0, radius, effect, ""); 
				AdmDamage(pos, ent, radius, dmg, client, entity);
			}
		}

	}*/
}
//-----------------------------------------------------------------
stock test(client, entity, select)
{
	new explos = CreateEntityByName("env_explosion");
	if(!IsValidEntity(explos)) return;
	DispatchKeyValue(explos, "iMagnitude", "90");
	DispatchKeyValue(explos, "RadiusOverride", "120");
	SetEntPropEnt(explos, Prop_Data, "m_hOwnerEntity", client);
	DispatchSpawn(explos);
	
	new Float:pos[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", pos);
	
	
	if(select == 1)
	{
		for(new i = 0; i <= 3; i++)
		{
			switch(i)
			{
				case 0:
				{
					pos[0] += 130.0;
					pos[1] += 130.0;
				}
				
				case 1:
				{
					pos[0] += 150.0;
					pos[1] += 150.0;
				}
				
				case 2:
				{
					pos[0] += 170.0;
					pos[1] += 170.0;
				}
				case 3:
				{
					pos[0] += 190.0;
					pos[1] += 190.0;
				}
			}
			TeleportEntity(explos, pos, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(explos, "Explode");
		}
	}
	else if(select == 2)
	{
		for(new i = 0; i <= 3; i++)
		{

			switch(i)
			{
				case 0:
				{
					pos[0] -= 130.0;
					pos[1] -= 130.0;
				}
				
				case 1:
				{
					pos[0] -= 150.0;
					pos[1] -= 150.0;
				}
				
				case 2:
				{
					pos[0] -= 170.0;
					pos[1] -= 170.0;
				}
				case 3:
				{
					pos[0] -= 190.0;
					pos[1] -= 190.0;
				}
			}
			TeleportEntity(explos, pos, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(explos, "Explode");
		}
	}
	
	if(select == 3)
	{
		for(new i = 0; i <= 3; i++)
		{

			switch(i)
			{
				case 0:
				{
					pos[0] += 130.0;
					pos[1] -= 130.0;
				}
				
				case 1:
				{
					pos[0] += 150.0;
					pos[1] -= 150.0;
				}
				
				case 2:
				{
					pos[0] += 170.0;
					pos[1] -= 170.0;
				}
				case 3:
				{
					pos[0] += 190.0;
					pos[1] -= 190.0;
				}
			}
			TeleportEntity(explos, pos, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(explos, "Explode");
		}
	}
	else if(select == 4)
	{
		for(new i = 0; i <= 3; i++)
		{
			switch(i)
			{
				case 0:
				{
					pos[0] -= 130.0;
					pos[1] += 130.0;
				}
				
				case 1:
				{
					pos[0] -= 150.0;
					pos[1] += 150.0;
				}
				
				case 2:
				{
					pos[0] -= 170.0;
					pos[1] += 170.0;
				}
				case 3:
				{
					pos[0] -= 190.0;
					pos[1] += 190.0;
				} 
			}
			TeleportEntity(explos, pos, NULL_VECTOR, NULL_VECTOR);
			AcceptEntityInput(explos, "Explode");
		}
	} 
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
						// hitSentry(po, _:damage, radius);
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

stock Explode(client, Float:flPos[3], Float:flDamage, Float:flRadius, const String:strParticle[], const String:strSound[])
{
	new iBomb = CreateEntityByName("tf_generic_bomb");
	SetEntPropEnt(iBomb, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValueVector(iBomb, "origin", flPos);
	DispatchKeyValueFloat(iBomb, "damage", flDamage);
	DispatchKeyValueFloat(iBomb, "radius", flRadius);
	DispatchKeyValue(iBomb, "health", "1");
	DispatchKeyValue(iBomb, "explode_particle", strParticle);
	DispatchKeyValue(iBomb, "sound", strSound);
	DispatchSpawn(iBomb);

	AcceptEntityInput(iBomb, "Detonate");
	// AcceptEntityInput(iBomb, "Kill");
	CreateTimer(2.0, killll, EntIndexToEntRef(iBomb));
	
	return iBomb;
}  

public Action:killll(Handle:timer, any:iEntityRef)
{
	new ent = EntRefToEntIndex(iEntityRef);
	if(!IsValidEntity(ent)) return Plugin_Stop;
	AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
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

#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>

// new g_iPlayerGlowEntity[MAXPLAYERS + 1];

public OnPluginStart()
{
	HookEvent("player_hurt", EventHurt);
	HookEvent("player_spawn", PlayerSpawn);
}
public Action:EventHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new client = GetClientOfUserId(GetEventInt(event, "userid")); 
	
	if(AliveCheck(client) && AliveCheck(attacker) && client != attacker)
	{
		TF2_CreateGlow(client);
		
		// if(IsValidEntity(iGlow))
		// {
			// g_iPlayerGlowEntity[client] = EntIndexToEntRef(iGlow);
		// }
	}
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	TF2_RemoveWeaponSlot(client, 0);
	TF2_RemoveWeaponSlot(client, 1);
}

stock TF2_CreateGlow(client)
{
	char oldEntName[64];
	GetEntPropString(client, Prop_Data, "m_iName", oldEntName, sizeof(oldEntName));

	char strName[126], strClass[64];
	GetEntityClassname(client, strClass, sizeof(strClass));
	Format(strName, sizeof(strName), "%s%i", strClass, client);
	DispatchKeyValue(client, "targetname", strName);
	
	int ent = CreateEntityByName("env_viewpunch");
	DispatchKeyValue(ent, "targetname", "punch");
	DispatchKeyValue(ent, "target", strName);
	new Float:flEyeAng[3];
	
	switch(GetRandomInt(0,2))
	{
		case 0: flEyeAng[0] = 40.0;
		case 1: flEyeAng[1] = 40.0;
		case 2: flEyeAng[2] = 70.0;
	}
	DispatchKeyValueVector(ent, "punchangle", flEyeAng);
	DispatchSpawn(ent);
	
	AcceptEntityInput(ent, "Enable");
	
	SetVariantInt(50);
	AcceptEntityInput(ent, "ViewPunch");
	
	//Change name back to old name because we don't need it anymore.
	SetEntPropString(client, Prop_Data, "m_iName", oldEntName);

	return ent;
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

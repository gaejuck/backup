#include <sdktools>
#include <sdkhooks>

public Plugin:myinfo = 
{
	name = "Spawn God",
	author = "TAKE 2",
	description = "스폰일때 무적",
	version = "1.0", 
	url = "x"
};

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
}

public OnPostThinkPost(client)
{
	new ent = -1;
	while ((ent = FindEntityByClassname(ent, "func_respawnroom")) != -1)
	{
		HookThisRoom(ent);
	}
}


HookThisRoom(room) {
	SDKHook(room, SDKHook_StartTouch, StartTouchSpawn);
	SDKHook(room, SDKHook_EndTouch, EndTouchSpawn);
}

public Action:StartTouchSpawn(spawn, client)
{
	if (AliveCheck(client))
	{
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	}
} 

public Action:EndTouchSpawn(spawn, client)
{
	if (AliveCheck(client))
	{
		SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
		SDKUnhook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	}
}

public Action:OnTakeDamage(iVictim, &attacker, &inflictor, &Float:flDamage, &damagetype) 
{ 
	if (AliveCheck(iVictim)) 
	{	
		if(attacker)
		{
			flDamage = 0.0;
			return Plugin_Changed;
		}
	}     
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

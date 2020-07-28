#include <tf2attributes>
#include <tf2_stocks>
#include <sdkhooks>

public OnPluginStart()
{
	HookEvent("post_inventory_application", post_inventory_application);
}

public OnClientPutInServer(client)
	if(!IsFakeClient(client)) 
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

public Action:post_inventory_application(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsFakeClient(client)) 
	{
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Spy)
			TF2Attrib_SetByDefIndex(client, 26, 999999999.0);
		else
			TF2Attrib_RemoveByDefIndex(client, 26);
	}	
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if (AliveCheck(victim) && AliveCheck(attacker))
	{
		if(TF2_GetPlayerClass(attacker) != TFClassType:TFClass_Spy)
		{
			if(TF2_GetPlayerClass(victim) == TFClassType:TFClass_Spy)
			{
				damage = 333333333.0;
				return Plugin_Changed;
			}
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

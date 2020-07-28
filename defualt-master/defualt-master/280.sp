#include <tf2attributes>
#include <sdkhooks>
#include <tf2_stocks>

public OnClientPutInServer(client)
	if(!IsFakeClient(client)) 
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	TF2Attrib_SetByDefIndex(weapon, 280, 2.0);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if (AliveCheck(attacker))
	{
		if(TF2_GetPlayerClass(attacker) != TFClassType:TFClass_Engineer)
		{
			damage = 75.0; 
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

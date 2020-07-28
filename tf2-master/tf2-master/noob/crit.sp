#include <sourcemod>
#include <tf2_stocks>

new bool:crit[MAXPLAYERS+1] = false;

public OnPluginStart()
{
	RegConsoleCmd("sm_cri", cri);
}
public Action:cri(client, args)
{
	if(crit[client] == false)
	{
		PrintToChat(client, "\x03크리 적용 완료");
		crit[client] = true;
		CreateTimer(3.0, Regen, client, TIMER_REPEAT);
	}
	else
	{
		PrintToChat(client, "\x03크리 해제");
		crit[client] = false;
	}
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if(crit[client] == true)
	{
		result = true;
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public Action:Regen(Handle:timer, any:client)
{
	if(AliveCheck(client))
		if(crit[client] == true)
			TF2_RegeneratePlayer(client);
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

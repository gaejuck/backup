#include <sourcemod>
#include <sdkhooks>

new health[MAXPLAYERS + 1];

public OnPluginStart()
{
	HookEvent("player_hurt", Event_PlayerHurt_FrameMod);
}

public Action:Event_PlayerHurt_FrameMod(Handle:event, const String:name[], bool:dontBroadcast)
{	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new damage = health[client] - GetClientHealth(client);

	if(PlayerCheck(attacker))
	{
		SetHudTextParams(0.65, 0.25, 1.0, 255, 255, 255, 255);
		ShowHudText(attacker, 1, "공격 한 데미지 : %d", damage);
	}
	else if(PlayerCheck(client))
	{
		SetHudTextParams(0.65, 0.15, 1.0, 255, 255, 255, 255);
		ShowHudText(client, 1, "내가 받은 데미지 : %d", damage);
	}
	
	return Plugin_Continue; 
}


public OnGameFrame()
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (IsClientInGame(client))
		{
			health[client] = GetClientHealth(client);
		}
	}
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
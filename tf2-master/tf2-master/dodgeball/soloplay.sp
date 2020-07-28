#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>

new Handle:cvar_friendlyfire = INVALID_HANDLE;

new bool:RO[2048];

public OnPluginStart()
{
	RegServerCmd("tf_dodgeball_soloplay", SoloPlay)
	cvar_friendlyfire = FindConVar("mp_friendlyfire");
	
	HookEvent("player_death", Player_Death, EventHookMode_Pre);
}

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast) //최근에 수정함 게임 안 끝나는 시스템
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(AliveCheck(i))
		{
			if(i == 1) ChangeClientTeamAlive(client, 2);
			else if(i+i) ChangeClientTeamAlive(client, 3); // 2 4 6 8 10
			else if(i+2) ChangeClientTeamAlive(client, 2); // 1 3 5 7 9 11
		}
	}
}

public Action:SoloPlay(iArgs)
{
	if(iArgs != 1)
	{
		PrintToServer("Usage: tf_dodgeball_soloplay @rocket")
		return Plugin_Handled;
	}
	new String:strBuffer[32];
	GetCmdArg(1, strBuffer, sizeof(strBuffer)); new itarget = StringToInt(strBuffer, 10);
	SetConVarInt(cvar_friendlyfire, 1);
	
	RO[itarget] = true;
	return Plugin_Handled;
}

public OnGameFrame()
{
	new rocket = -1; 
	while ((rocket=FindEntityByClassname(rocket, "tf_projectile_rocket"))!=INVALID_ENT_REFERENCE)
	{
		if(IsValidEntity(rocket) && RO[rocket])
		{
			SetEntData(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_iTeamNum"), 1, true);
			SetEntData(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_bCritical"), 1, 1, true);
		}
	}
} 

public OnEntityDestroyed(iEntity)
{
	if(!IsValidEdict(iEntity)) return;
	decl String:szBuffer[64];
	GetEdictClassname(iEntity, szBuffer, 64);
	if(!StrEqual(szBuffer, "tf_projectile_rocket")) return;
	
	// SetConVarInt(cvar_friendlyfire, 0);
	if(RO[iEntity]) RO[iEntity] = false;
}

stock ChangeClientTeamAlive(client, team){
	if(IsPlayerAlive(client))
	{
		SetEntProp(client, Prop_Send, "m_lifeState", 2);
		ChangeClientTeam(client, team);
		SetEntProp(client, Prop_Send, "m_lifeState", 0);
	}
	else ChangeClientTeam(client, team);
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

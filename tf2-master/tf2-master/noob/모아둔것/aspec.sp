#include<sdkhooks>

public OnPluginStart()
{
    HookEvent("player_team", EventJoin);
}

public EventJoin( Handle:Spawn_Event, const String:Death_Name[], bool:Death_Broadcast )
{
	new client = GetClientOfUserId(GetEventInt(Spawn_Event, "userid"));
	new team = GetEventInt(Spawn_Event, "team");
	
	if(IsFakeClient(client))
	{
		if(team == 3)
		{
			ChangeClientTeam(client, 2);
		}
	}
	else
	{
		if(team == 2)
		{
			return Plugin_Continue;
	//		PrintToChat(client, "\x0897B3DBEE레드팀엔 들어갈수 없습니다.");
		}
	}
	return Plugin_Continue;

}
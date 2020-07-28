#include <sourcemod>
// #include <steamtools>

public Plugin:myinfo =
{
	name = "TF2 bot command",
	author = "ㅣ",
	description = "bot bot bot...",
	version = "1.0",
	url = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
}


public OnPluginStart()  
{ 
	AddMultiTargetFilter("@redbots", red_bots, "All Red bots", false);
	AddMultiTargetFilter("@bluebots", blue_bots, "All Blue bots", false); 
	AddMultiTargetFilter("@blubots", blue_bots, "All Blue bots", false); 
}  

public bool:red_bots(const String:pattern[], Handle:clients)
{	
	for (new i = 1; i <= MaxClients; i++)
		if (PlayerCheck(i) && IsFakeClient(i) && GetClientTeam(i) == 2)
			PushArrayCell(clients, i);
	return true;
}

public bool:blue_bots(const String:pattern[], Handle:clients)
{	
	for (new i = 1; i <= MaxClients; i++)
		if (PlayerCheck(i) && IsFakeClient(i) && GetClientTeam(i) == 3)
			PushArrayCell(clients, i);
	return true;
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
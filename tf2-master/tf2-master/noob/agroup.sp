#include <sourcemod>
#include <SteamWorks>

new bool:officer[MAXPLAYERS+1] = false;
new bool:member[MAXPLAYERS+1] = false;

public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(officer[client] == true)
		PrintToChat(client,"마스터!");
	if(member[client] == true)
		PrintToChat(client,"맴버");
}

public SteamWorks_OnClientGroupStatus(authid, groupid, bool:isMember, bool:isOfficer)
{
	if (groupid == 11341854)
		if(isOfficer)
			officer[authid] = true;
		else if(isMember)
			member[authid] = true;
}
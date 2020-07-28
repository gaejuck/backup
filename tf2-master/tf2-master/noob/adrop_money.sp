#include <sourcemod> 
#include <sdktools>
#include <sdkhooks>
#include tf2_stocks

new Point[MAXPLAYERS+1];

public OnPluginStart()
{
	RegConsoleCmd("sm_mmo", aaaa, "");
	HookEvent("player_death", Player_Death);
}

public Action:aaaa(client, args)
{
	PrintToChat(client, "내가 소지중인 돈 : %d", Point[client]);
}

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	decl Roll;
	Roll = 5;
	Point[attacker] += Roll;
	
	PrintToChat(attacker, "5원 얻음");
}

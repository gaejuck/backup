#include <sdktools>
#include <sdkhooks>


public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn) 
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	CreateTimer(5.0, sam, client, TIMER_REPEAT);	
}

public Action:sam(Handle:timer, any:client)
{
	decl String:see[MAX_NAME_LENGTH];
	
	GetClientName(client, see, sizeof(see)); //쳐다보고 있는 사람
	new target = GetClientAimTarget(client); //나
	if(IsValidClient(target))
	{
		PrintToChat(target, "\x0700FBFF%s\x07FFFFFF님이 \x0700FF6E님을\x07FFFFFF 쳐다보고 있습니다.", see);
	}
}

stock IsValidClient(client)
{
	if(client <= 0 || client > MaxClients) return false;
	if(!IsClientInGame(client)) return false;
	if(GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	return true;
}
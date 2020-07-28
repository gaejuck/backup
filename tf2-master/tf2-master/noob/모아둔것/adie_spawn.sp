

#include <sourcemod>
#include <sdktools>

new Float:OR[MAXPLAYERS+1][3];

//플러그인 시작
public OnPluginStart()
{
	HookEvent("player_spawn", Event_Spawn);
	HookEvent("player_death", Event_Death);
}

public Event_Death(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{	
	new Client = GetClientOfUserId(GetEventInt(Spawn_Event, "userid"));
	
	GetClientAbsOrigin(Client, OR[Client]);
}

//살아날 경우
public Event_Spawn(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new Client = GetClientOfUserId(GetEventInt(Spawn_Event, "userid"));

	Tele(Client);
}


public Tele(Client)
{
	TeleportEntity(Client, OR[Client], NULL_VECTOR, NULL_VECTOR);
}

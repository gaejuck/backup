#include <tf2>


public Plugin:myinfo =
{
	name = "[TF2] jump jump",
	author = "TAKE 2",
	description = "TAKE!!!!!!!!!",
	version = "1.0",
	url = "smf"
}

public OnPluginStart()
{
	HookEvent("player_spawn", EventSpawn);
}

public EventSpawn(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new Client = GetClientOfUserId(GetEventInt(Spawn_Event, "userid"));
	
	TF2_AddCondition(Client, TFCond_HalloweenSpeedBoost,9999.0);
	TF2_AddCondition(Client, TFCond_Sapped,99999.0);
}
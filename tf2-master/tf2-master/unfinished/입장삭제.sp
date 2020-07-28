#include <sourcemod>

public OnPluginStart()
{
  HookEvent("player_connect", Hide_Event, EventHookMode_Pre);
}

public Action:Hide_Event(Handle:event, const String:name[], bool:dontBroadcast)
{
  SetEventBroadcast(event, true);
}

public OnClientPutInServer(client)
{
	decl String:aName[MAX_NAME_LENGTH];
	GetClientName(client, aName, sizeof(aName));
	PrintToChat(client, "\x04%s\x07FFFFFF님이 게임에 참가하였습니다.", aName);
}

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public OnPluginStart()
{
	RegConsoleCmd("sm_d", Command_Drown);
}

public Action:Command_Drown(client, args)
{
	SDKHook(client, SDKHook_PreThink, PreThinkEvent);
	return Plugin_Handled;
}

public PreThinkEvent(client)
{
    SetEntProp(client, Prop_Send, "m_nWaterLevel", 3);
}
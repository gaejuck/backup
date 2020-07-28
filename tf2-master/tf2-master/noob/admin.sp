#pragma semicolon 1
#define PLUGIN_VERSION "1.0"

#include <sourcemod>

public Plugin:myinfo =
{
	name = "TOG Admin Targeting",
	author = "That One Guy",
	description = "Adds @admins targeting method",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net"
}

public OnPluginStart()
{
	CreateConVar("togadmintargeting_version", PLUGIN_VERSION, "TOG Admin Targeting: Version", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	AddMultiTargetFilter("@admins", bAdminFilter, "Admins", true);
	AddMultiTargetFilter("@!admins", bNonAdminFilter, "Non-admins", true);
}

public bool:bAdminFilter(const String:sPattern[], Handle:hClients)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && CheckCommandAccess(i, "sm_admin", ADMFLAG_GENERIC, true))
		{
			PushArrayCell(hClients, i);
		}
	}

	return true;
}

public bool:bNonAdminFilter(const String:sPattern[], Handle:hClients)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsValidClient(i) && !CheckCommandAccess(i, "sm_admin", ADMFLAG_GENERIC, true))
		{
			PushArrayCell(hClients, i);
		}
	}

	return true;
}

bool:IsValidClient(client, bool:bIncludeBots = false)
{
	if(!(1 <= client <= MaxClients) || !IsClientInGame(client) || (IsFakeClient(client) && !bIncludeBots))
	{
		return false;
	}
	return true;
}
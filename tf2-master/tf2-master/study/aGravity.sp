#pragma semicolon 1

#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_VERSION "1.0"

public Plugin:myinfo =
{
	name = "TF2 Gravity",
	author = "TAKE 2",
	description = "Gravity",
	version = PLUGIN_VERSION,
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	new String:Game[32];
	GetGameFolderName(Game, sizeof(Game));
	if(!StrEqual(Game, "tf"))
	{
		Format(error, err_max, "This plugin only works for Team Fortress 2");
		return APLRes_Failure;
	}
	return APLRes_Success;
}

new Float:g_clientGravity[MAXPLAYERS+1] = 0.0;

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	CreateConVar("sm_setGravity_version", PLUGIN_VERSION, "중력 버전임", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	RegConsoleCmd("sm_gr", Command_SetGravity, "Usage: sm_Gravity \"Gravity\"");
}

public OnClientPutInServer(client)
{
	g_clientGravity[client] = 0.0;
}

public OnClientDisconnect_Post(client)
{
	g_clientGravity[client] = 0.0;
}

public Action:Command_SetGravity(client, args)
{
	
	if(args != 1)
	{
		ReplyToCommand(client, "!gr 0.01 ~ 10");
		return Plugin_Handled;
	}

	new String:strGravity[32], Float:Gravity;

	GetCmdArg(1, strGravity, sizeof(strGravity));
	Gravity = StringToFloat(strGravity);
	
	if(Gravity < 0.01 || Gravity > 10)
	{
		ReplyToCommand(client, "\x04중력은 0.01에서 10까지");
		return Plugin_Handled;
	}

	for(new i = 0; i < client; i++)
	{
		g_clientGravity[client] = Gravity;	
		ReplyToCommand(client, "\x04중력은 0.01에서 10까지");
	}
	return Plugin_Handled;
}

public OnGameFrame()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsPlayerAlive(i))
		{
			if(g_clientGravity[i] && !TF2_IsPlayerInCondition(i, TFCond_Charging))
			{
				SetEntityGravity(i, g_clientGravity[i]);
			}	
		}
	}
}
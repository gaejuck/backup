#pragma semicolon 1

#include <sourcemod>
#include <tf2>
#include <tf2_stocks>

#define PLUGIN_VERSION "1.0"

public Plugin:myinfo =
{
	name = "TF2 GameSpeed",
	author = "TAKE 2",
	description = "GameSpeed",
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

new Float:g_clientGameSpeed[MAXPLAYERS+1] = 0.0;

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	CreateConVar("sm_setGameSpeed_version", PLUGIN_VERSION, "게임 스피드 버전임", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	RegAdminCmd("sm_cc", Command_SetGameSpeed, ADMFLAG_SLAY, "Usage: sm_GameSpeed \"GameSpeed\"");
	
	
	RegConsoleCmd("addcond", Command_Suicide, "addcond를 막는 커맨드 입니다!");
	RegConsoleCmd("noclip", Command_Suicide, "noclip을 막는 커맨드 입니다!");
	RegConsoleCmd("buddha", Command_Suicide, "buddha를 막는 커맨드 입니다!");
	RegConsoleCmd("impulse", Command_Suicide, "impulse를 막는 커맨드 입니다!");
	RegConsoleCmd("currency_give", Command_Suicide, "currency_give를 막는 커맨드 입니다!");
	RegConsoleCmd("hurtme", Command_Suicide, "hurtme를 막는 커맨드 입니다!");
	RegConsoleCmd("ent_create", Command_Suicide, "ent_create를 막는 커맨드 입니다!");
	RegConsoleCmd("Debug commands", Command_Suicide, "commands를 막는 커맨드 입니다!");
} 

public Action:Command_Suicide(client, args)
{
	return Plugin_Handled;
}

public OnClientPutInServer(client)
{
	g_clientGameSpeed[client] = 0.0;
}

public OnClientDisconnect_Post(client)
{
	g_clientGameSpeed[client] = 0.0;
}

public Action:Command_SetGameSpeed(client, args)
{
	
	if(args != 1)
	{
		ReplyToCommand(client, "\x04!cc 0.1 ~ 10");
		return Plugin_Handled;
	}

	new String:strGameSpeed[32], Float:GameSpeed;

	GetCmdArg(1, strGameSpeed, sizeof(strGameSpeed));
	GameSpeed = StringToFloat(strGameSpeed);
	
	if(GameSpeed < 0.1 || GameSpeed > 10)
	{
		ReplyToCommand(client, "\x04게임 스피드는 0.1에서 10까지");
		return Plugin_Handled;
	}

	for(new i = 0; i < client; i++)
	{
		g_clientGameSpeed[client] = GameSpeed;	
	}
	return Plugin_Handled;
}

public OnGameFrame()
{ 
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(g_clientGameSpeed[i] && !TF2_IsPlayerInCondition(i, TFCond_Charging))
			{
				SetConVarInt(FindConVar("sv_cheats"), 1);
				SetConVarFloat(FindConVar("host_timescale"), g_clientGameSpeed[i]);
			}
		}
	}
}

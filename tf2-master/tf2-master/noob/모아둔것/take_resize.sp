#include <sourcemod>
#include <sdkhooks>
#include <tf2attributes>
#include <tf2_stocks>

public Plugin:myinfo = 
{
	name = "TAKE Resize",
	author = "TAKE 2",
	description = "RRResize",
	version = "1.5",
	url = "http://steamcommunity.com/id/hydra76/"
}

new Float:g_clientTS[MAXPLAYERS+1] = 1.0;

new bool:Admin[MAXPLAYERS+1] = false;

#include "take_size/body_size.sp"
#include "take_size/head_size.sp"
#include "take_size/taunt_speed.sp"  
#include "take_size/voice_speed.sp"
#include "take_size/weapon_size.sp" 

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

public OnPluginStart()
{
	LoadTranslations("take_command.phrases");
	
	RegConsoleCmd("sm_hd", head_size, "");
	RegConsoleCmd("sm_ws", weapon_size, "");
	RegConsoleCmd("sm_ws2", weapon_size2, "");
	RegConsoleCmd("sm_bs", body_size, "");
	RegConsoleCmd("sm_bs2", body_size2, "");
	RegConsoleCmd("sm_vs", voice_speed, "");
	
	RegConsoleCmd("sm_ts", Command_SetTS, "!ts <0.1 ~ 10>");
	 
	RegConsoleCmd("sm_reset", us_reset, "");
	RegAdminCmd("sm_event", admin_reset, ADMFLAG_KICK);
} 

public OnClientPutInServer(client) 
{
	SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
	SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost2);

	g_clientTS[client] = 1.0;
	 
	Admin[client] = false;   
}

public OnClientDisconnect_Post(client)
{
	g_clientTS[client] = 0.0;
	
	Admin[client] = false;
}

public Action:us_reset(client, args)
{
	new String:RESET[256];
	if(PlayerCheck(client))
	{
		g_clientTS[client] = 1.0;
			
		TF2Attrib_SetByDefIndex(client, 620, 1.0); //body size
		TF2Attrib_SetByDefIndex(client, 444, 1.0); //head size
		TF2Attrib_SetByDefIndex(client, 2048, 1.0); //voice speed
		TF2Attrib_SetByDefIndex(client, 699, 1.0); //weapon size
			
		PrintToChat(client, "\x03%t", "Reset", RESET);
	} 
	return Plugin_Handled;	
}

public Action:admin_reset(client, args)
{
	Admin[client] = true;
	
	if(Admin[client] == true)
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			if(PlayerCheck(i))
			{
				TF2Attrib_SetByDefIndex(i, 620, 1.0); //body size
				TF2Attrib_SetByDefIndex(i, 444, 1.0); //head size
				TF2Attrib_SetByDefIndex(i, 2048, 1.0); //voice speed
				TF2Attrib_SetByDefIndex(i, 699, 1.0); //weapon size
			}
		}
	 
		PrintToChat(client, "\x03리사이즈 리셋!");
	}
	
	CreateTimer(1.0, Admin_reset_timer, client);
	return Plugin_Handled;	
}

public Action:Admin_reset_timer(Handle:timer, any:client)
{
	Admin[client] = false;
	return Plugin_Handled;	
}

public OnPostThinkPost2(client)
{
	new TFClassType:Class = TF2_GetPlayerClass(client);
	if(Class == TFClass_Sniper)
	{
		if(!TF2Attrib_SetByDefIndex(client, 620, 1.0)) //만약에 bs가 1이 아니라면 1로 바꺼라
		{
			TF2Attrib_SetByDefIndex(client, 620, 1.0);
		}
		
		else if(!TF2Attrib_SetByDefIndex(client, 444, 1.0))
		{
			TF2Attrib_SetByDefIndex(client, 444, 1.0);
		}
	}
}

stock bool:PlayerCheck(Client){
	if(Client > 0 && Client <= MaxClients){
		if(IsClientConnected(Client) == true){
			if(IsClientInGame(Client) == true){
				return true;
			}
		}
	}
	return false;
}


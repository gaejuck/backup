#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>

#define SPECMODE_NONE 				0
#define SPECMODE_FIRSTPERSON 		4
#define SPECMODE_3RDPERSON 			5
#define SPECMODE_FREELOOK	 		6

#define UPDATE_DISABLED 0
#define UPDATE_ONGAMEFRAME 1
#define UPDATE_TIMER 2

new g_iButtonsPressed[MAXPLAYERS+1] = {0,...};

new bool:g_bShowOwnKeys[MAXPLAYERS+1] = {false,...};

new Handle:g_hCVUpdateMode;
new Handle:g_hCVUpdateRate;
new Handle:g_hCVFrameSkip;

new g_iUpdateMode;
new g_iFrameSkip;

new Handle:g_hUpdateKeyDisplay = INVALID_HANDLE;

new g_iCurrentFrame = 0;

new bool:jumping[MAXPLAYERS+1] = false;

#include "take_jump/showkeys.sp"
#include "take_jump/jump_main.sp"

public OnPluginStart()
{
	g_hCVUpdateMode = CreateConVar("sm_showkeys_updatemode", "1", "How should we update the key display? 0: Disabled, 1: OnGameFrame (most accurate, high load with many players), 2: Repeated timer (less accurate, low load)", FCVAR_PLUGIN, true, 0.0, true, 2.0);
	g_hCVUpdateRate = CreateConVar("sm_showkeys_updaterate", "0.1", "How often in seconds should we update the key display when using updatemode 2?", FCVAR_PLUGIN, true, 0.01, true, 1.0);
	g_hCVFrameSkip = CreateConVar("sm_showkeys_frameskip", "1", "Update the keys each x frames when using updatemode 1?", FCVAR_PLUGIN, true, 1.0);
	
	HookConVarChange(g_hCVUpdateMode, ConVarChanged_UpdateMode);
	HookConVarChange(g_hCVUpdateRate, ConVarChanged_UpdateRepeat);
	HookConVarChange(g_hCVFrameSkip, ConVarChanged_FrameSkip);
	
	RegConsoleCmd("sm_jump", jump, "Toggle showing your own pressed keys.");
}

public OnClientDisconnect(client)
{
	g_iButtonsPressed[client] = 0;
	g_bShowOwnKeys[client] = false;
	
	if(jumping[client] == true)
	{
		jumping[client] = false;
	}
}


public OnClientPutInServer(client)
{
	CreateTimer(3.0, regen, client, TIMER_REPEAT);
}

public Action:jump(client, args)
{
	if(PlayerCheck(client))
	{
		if(g_iUpdateMode == UPDATE_DISABLED)
		{
			g_bShowOwnKeys[client] = false;
			PrintToChat(client, "\x04적용 해제");
			return Plugin_Handled;
		}
		
		if(jumping[client] == false)
		{
			PrintToChat(client, "\x04적용 완료", client);
			g_bShowOwnKeys[client] = true;
			jumping[client] = true;
		}
		else
		{
		 	PrintToChat(client, "\x04적용 해제", client);
			jumping[client] = false;
			g_bShowOwnKeys[client] = false;
		}
	}
	return Plugin_Handled;
}
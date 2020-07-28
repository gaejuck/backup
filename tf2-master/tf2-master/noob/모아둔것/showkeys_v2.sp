#include <sourcemod>

#define SPECMODE_NONE 				0
#define SPECMODE_FIRSTPERSON 		4
#define SPECMODE_3RDPERSON 			5
#define SPECMODE_FREELOOK	 		6

new bool:g_bShowOwnKeys[MAXPLAYERS+1] = {false,...};
new g_iButtonsPressed[MAXPLAYERS+1] = {0,...};

new Handle:g_hTimer;
new Handle:HudMessage;

public OnPluginStart()
{
	
	RegConsoleCmd("sm_sk", Cmd_ShowKeys, "Toggle showing your own pressed keys.");
	
	HudMessage = CreateHudSynchronizer();
}


public OnMapStart()
{
	g_hTimer = CreateTimer(0.1, UpdateKeyDisplay, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public OnMapEnd()
{
	if (g_hTimer != INVALID_HANDLE) 
	{
		KillTimer(g_hTimer);
	}
    
	g_hTimer = CreateTimer(0.1, UpdateKeyDisplay, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public OnClientDisconnect(client)
{
	g_iButtonsPressed[client] = 0;
	g_bShowOwnKeys[client] = false;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	g_iButtonsPressed[client] = buttons;
}

public Action:Cmd_ShowKeys(client, args)
{
	if(g_bShowOwnKeys[client] == false)
	{
		g_bShowOwnKeys[client] = true;
		PrintToChat(client, "on");
	}
	else
	{
		g_bShowOwnKeys[client] = false;
		PrintToChat(client, "off");
	}
	return Plugin_Handled;
}
public Action:UpdateKeyDisplay(Handle:timer, any:client)
{
	if(g_bShowOwnKeys[client] == true)
	{
		new iClientToShow, iButtons, iObserverMode;
		
		for(new i=1;i<=MaxClients;i++)
		{
			// Ignore that player, if he's not using this plugin at all
			if(!g_bShowOwnKeys[i])
				continue;
			
			if(IsClientInGame(i) && (g_bShowOwnKeys[i] && IsPlayerAlive(i)) || (!IsPlayerAlive(i) || IsClientObserver(i) ))
			{
				// Show own buttons by default
				iClientToShow = i;
				
				// Get target he's spectating
				if(!IsPlayerAlive(i) || IsClientObserver(i))
				{
					iObserverMode = GetEntProp(i, Prop_Send, "m_iObserverMode");
					if(iObserverMode == SPECMODE_FIRSTPERSON || iObserverMode == SPECMODE_3RDPERSON)
					{
						iClientToShow = GetEntPropEnt(i, Prop_Send, "m_hObserverTarget");
						
						// Check client index
						if(iClientToShow <= 0 || iClientToShow > MaxClients)
							continue;
					}
					else
					{
						continue; // don't proceed, if in freelook..
					}
				}
			
				iButtons = g_iButtonsPressed[iClientToShow];

				SetHudTextParams(0.75, 0.3, 1.0, 49, 237, 247, 255);
						
				// Is he pressing "w"?
				if(iButtons & IN_FORWARD)
					ShowSyncHudText(i, HudMessage, "     W     ");
				else
					ShowSyncHudText(i, HudMessage, "           ");
						
				// Is he pressing "space"?
				if(iButtons & IN_JUMP)
					ShowSyncHudText(i, HudMessage, "       JUMP\n");
				else
					ShowSyncHudText(i, HudMessage, "           \n");
						
				// Is he pressing "a"?
				if(iButtons & IN_MOVELEFT)
					ShowSyncHudText(i, HudMessage, "    A");
				else
					ShowSyncHudText(i, HudMessage, "     ");
							
				// Is he pressing "s"?
				if(iButtons & IN_BACK)
					ShowSyncHudText(i, HudMessage, "    S");
				else
					ShowSyncHudText(i, HudMessage, "     ");
							
				// Is he pressing "d"?
				if(iButtons & IN_MOVERIGHT)
					ShowSyncHudText(i, HudMessage, "    D");
				else
					ShowSyncHudText(i, HudMessage, "     ");
						
				// Is he pressing "ctrl"?
				if(iButtons & IN_DUCK)
					ShowSyncHudText(i, HudMessage, "       DUCK\n");
				else
					ShowSyncHudText(i, HudMessage, "           \n");
							
				// Is he pressing "e"?
				if(iButtons & IN_ATTACK3)
					ShowSyncHudText(i, HudMessage, "    Wheels\n");
				else
					ShowSyncHudText(i, HudMessage, "       ");
						
				// Is he pressing "tab"?
				if(iButtons & IN_SCORE)
					ShowSyncHudText(i, HudMessage, "    SCORE\n");
				else
					ShowSyncHudText(i, HudMessage, "        \n");
							
				// Is he pressing "mouse1"?
				if(iButtons & IN_ATTACK)
					ShowSyncHudText(i, HudMessage, "MOUSE1");
				else
					ShowSyncHudText(i, HudMessage, "      ");
						
				// Is he pressing "mouse1"?
				if(iButtons & IN_ATTACK2)
					ShowSyncHudText(i, HudMessage, "  MOUSE2");
				else
					ShowSyncHudText(i, HudMessage, "        ");
			}
		}
	}
}
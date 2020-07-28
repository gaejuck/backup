#include <sourcemod>
#include <clientprefs>
#include <sdktools>

#define PLUGIN_VERSION "2.1.0"

new bool:g_bThirdPersonEnabled[MAXPLAYERS+1] = false;

new Handle:g_Cookie = INVALID_HANDLE;

public Plugin:myinfo =
{
	name = "[TF2] Thirdperson",
	author = "DarthNinja",
	description = "Allows players to use thirdperson without having to enable client sv_cheats",
	version = PLUGIN_VERSION,
	url = "DarthNinja.com"
};

public OnPluginStart()
{
	CreateConVar("thirdperson_version", PLUGIN_VERSION, "Plugin Version",  FCVAR_PLUGIN|FCVAR_NOTIFY);
	RegAdminCmd("sm_thirdperson", EnableThirdperson, 0, "Usage: sm_thirdperson");
	RegAdminCmd("tp", EnableThirdperson, 0, "Usage: sm_thirdperson");
	RegAdminCmd("sm_tmenu", tptp, 0, "Usage: sm_tp user list");
	RegAdminCmd("sm_firstperson", DisableThirdperson, 0, "Usage: sm_firstperson");
	RegAdminCmd("fp", DisableThirdperson, 0, "Usage: sm_firstperson");
	RegAdminCmd("sm_fmenu", fpfp, 0, "Usage: sm_fp user list");
	HookEvent("player_spawn", OnPlayerSpawned);
	HookEvent("player_class", OnPlayerSpawned);
	
	g_Cookie = RegClientCookie("sm_tfp", "spawn tp",CookieAccess_Protected);
	
	for(new i = MaxClients; i > 0; --i)
	{
		if (!AreClientCookiesCached(i))
		{
			continue;
		}
		OnClientCookiesCached(i);
	}
}

public OnClientCookiesCached(client)
{
    decl String:sBuffer[16];

    GetClientCookie(client, g_Cookie, sBuffer, sizeof(sBuffer));
    if(strlen(sBuffer) == 1 || StrEqual(sBuffer, "Yes"))
        g_bThirdPersonEnabled[client] = true;
    else
        g_bThirdPersonEnabled[client] = false;
    
    // Set default value
    if(strlen(sBuffer) == 1)
        SetClientCookie(client, g_Cookie, "Yes");
}


public Action:OnPlayerSpawned(Handle:event, const String:name[], bool:dontBroadcast)
{
	new userid = GetEventInt(event, "userid");
	if (g_bThirdPersonEnabled[GetClientOfUserId(userid)])
		CreateTimer(0.2, SetViewOnSpawn, userid);
}

public Action:SetViewOnSpawn(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (client != 0)	//Checked g_bThirdPersonEnabled in hook callback, dont need to do it here~
	{
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
	}
}

public Action:EnableThirdperson(client, args)
{
	if(!IsPlayerAlive(client))
		PrintToChat(client, "[SM] Thirdperson view will be enabled when you spawn.");
	SetVariantInt(1);
	AcceptEntityInput(client, "SetForcedTauntCam");
	SetClientCookie(client, g_Cookie, "Yes");
	g_bThirdPersonEnabled[client] = true;
	return Plugin_Handled;
}

public Action:DisableThirdperson(client, args)
{
	if(!IsPlayerAlive(client))
		PrintToChat(client, "[SM] Thirdperson view disabled!");
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");
	SetClientCookie(client, g_Cookie, "No");
	g_bThirdPersonEnabled[client] = false;
	return Plugin_Handled;
}

public Action:tptp(client, args)
{
	decl String:EVN[MAX_NAME_LENGTH];
	new Handle:menu = CreateMenu(tp);
	SetMenuTitle(menu, "tp user (3인칭 유저)");
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(g_bThirdPersonEnabled[i] == true)
			{
				GetClientName(i, EVN, sizeof(EVN));
				AddMenuItem(menu, EVN, EVN);
			}
		}
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public tp(Handle:menu, MenuAction:action, client, param)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:fpfp(client, args)
{
	decl String:EVN[MAX_NAME_LENGTH];
	new Handle:menu = CreateMenu(fp);
	SetMenuTitle(menu, "fp user (1인칭 유저)");
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(g_bThirdPersonEnabled[i] == false)
			{
				GetClientName(i, EVN, sizeof(EVN));
				AddMenuItem(menu, EVN, EVN);
			}
		}
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public fp(Handle:menu, MenuAction:action, client, param)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public OnClientDisconnect(client)
{
	g_bThirdPersonEnabled[client] = false;
}

#include <tf2attributes>

new Float:DSPID[MAXPLAYERS+1] = 0.0

public Plugin:myinfo = 
{
	name = "[TF2] DSP Effects",
	author = "A.I, Hurp Durp",
	description = "Allows you to apply a DSP Effect to your class's voice",
	version ="1.1",
	url = "www.lemonparty.org"
}

public OnPluginStart()
{
	RegAdminCmd("sm_dsp", DSPFX, ADMFLAG_RESERVATION)
	RegAdminCmd("sm_voicefx", DSPFX, ADMFLAG_RESERVATION)

	HookEvent("player_spawn", PlayerSpawn, EventHookMode_Post)
	HookEvent("post_inventory_application", OnPostInventoryApplication);
}

public OnClientDisconnect(client)
{
	if(DSPID[client] > 0.0)
	{
		DSPID[client] = 0.0
	}
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(DSPID[client] > 0.0)
	{
		TF2Attrib_SetByName(client, "SET BONUS: special dsp", DSPID[client]);
	}
}

public Action:DSPFX(client, args)
{
	new Handle:ws = CreateMenu(DSPFXCALLBACK);
	SetMenuTitle(ws, "Choose Your DSP Effect");

	AddMenuItem(ws, "0", "기본");
	AddMenuItem(ws, "X", "----------", ITEMDRAW_DISABLED);
	AddMenuItem(ws, "5", "1");
	AddMenuItem(ws, "20", "2");
	AddMenuItem(ws, "23", "3");
	AddMenuItem(ws, "130", "4");
	AddMenuItem(ws, "44", "5");
	AddMenuItem(ws, "45", "6");
	AddMenuItem(ws, "30", "7");
	AddMenuItem(ws, "126", "8");
	AddMenuItem(ws, "55", "9");
	AddMenuItem(ws, "38", "10");
	AddMenuItem(ws, "56", "11");
	AddMenuItem(ws, "33", "12");
	AddMenuItem(ws, "37", "13");
	AddMenuItem(ws, "134", "14");
	AddMenuItem(ws, "135", "15");

	DisplayMenu(ws, client, MENU_TIME_FOREVER);

	return Plugin_Handled;
}

public DSPFXCALLBACK(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_End) CloseHandle(menu);

	if(action == MenuAction_Select)
	{
		decl String:info[12];
		GetMenuItem(menu, param2, info, sizeof(info));

		new Float:weapon_glow = StringToFloat(info);
		DSPID[client] = weapon_glow
		if(weapon_glow == 0.0)
		{
			TF2Attrib_RemoveByName(client, "SET BONUS: special dsp")
		}
		else
		{
			TF2Attrib_SetByName(client, "SET BONUS: special dsp", weapon_glow);
		}
	}
}

public OnPostInventoryApplication(Handle:hEvent, const String:szName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	TF2Attrib_SetByName(client, "SET BONUS: special dsp", DSPID[client]);
}
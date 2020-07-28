#include <sourcemod>
#include <sdktools>
#include <sdkhooks>


#define red 255, 0, 0, 255
#define orange 255, 127, 0, 255
#define yellow 255, 255, 0, 255
#define green 0, 255, 0, 255
#define blue 0, 0, 255, 255
#define nam 111, 0, 255, 255
#define purple 143, 0, 255, 255

new bool:g_bEnabled;	

public OnPluginStart()
{
	RegAdminCmd("sm_ra", aaaa, ADMFLAG_ROOT);
	RegAdminCmd("sm_rw", aaab, ADMFLAG_ROOT);
	
	hookEvent("post_inventory_application", OnPlayerInventory, EventHookMode_Post);
}

public Action:OnPlayerInventory(Handle:hEvent, String:strEventName[], bool:bDontBroadcast)
{
	if (g_bEnabled == true)
	{
		new iClient = GetClientOfUserId(GetEventInt(hEvent, "userid"));
		if (!IsValidClient(iClient)) return;

		for (new iSlot = 1; iSlot < 5; iSlot++)
		{
			new iEntity = GetPlayerWeaponSlot(iClient, iSlot);
			if (iEntity != -1) RemoveEdict(iEntity);
		}
	}
}
 
public Action:aaaa(client, args)
{
	rainbow(client);
}

public Action:aaab(client, args)
{
	new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	rainbow(weapon);
}

public rainbow(client)
{ 
	CreateTimer(0.1, ready, client);
}

public Action:ready(Handle:timer, any:client)
{
	CreateTimer(0.8, b_color, client, TIMER_REPEAT);
}

public Action:b_color(Handle:timer, any:client)
{
	CreateTimer(0.1, b_color_red, client);
	CreateTimer(0.2, b_color_orange, client);
	CreateTimer(0.3, b_color_yellow, client);
	CreateTimer(0.4, b_color_green, client);
	CreateTimer(0.5, b_color_blue, client);
	CreateTimer(0.6, b_color_nam, client);
	CreateTimer(0.7, b_color_purple, client);
}

public Action:b_color_red(Handle:timer, any:client)
{
	SetEntityRenderColor(client, red);
}

public Action:b_color_orange(Handle:timer, any:client)
{
	SetEntityRenderColor(client, orange);
}

public Action:b_color_yellow(Handle:timer, any:client)
{
	SetEntityRenderColor(client, yellow);
}

public Action:b_color_green(Handle:timer, any:client)
{
	SetEntityRenderColor(client, green);
}

public Action:b_color_blue(Handle:timer, any:client)
{
	SetEntityRenderColor(client, blue);
}

public Action:b_color_nam(Handle:timer, any:client)
{
	SetEntityRenderColor(client, nam);
}

public Action:b_color_purple(Handle:timer, any:client)
{
	SetEntityRenderColor(client, purple);
}

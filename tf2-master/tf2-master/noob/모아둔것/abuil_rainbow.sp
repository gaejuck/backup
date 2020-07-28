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

public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "obj_dispenser"))
		SDKHook(entity, SDKHook_Spawn, rainbow)
		
	if(StrEqual(classname, "obj_teleporter"))
		SDKHook(entity, SDKHook_Spawn, rainbow)
		
	if(StrEqual(classname, "obj_sentry"))
		SDKHook(entity, SDKHook_Spawn, rainbow)
}

public rainbow(entity)
{ 
	CreateTimer(0.1, ready, entity);
}

public Action:ready(Handle:timer, any:entity)
{
	CreateTimer(0.8, b_color, entity, TIMER_REPEAT);
}

public Action:b_color(Handle:timer, any:entity)
{
	CreateTimer(0.1, b_color_red, entity);
	CreateTimer(0.2, b_color_orange, entity);
	CreateTimer(0.3, b_color_yellow, entity);
	CreateTimer(0.4, b_color_green, entity);
	CreateTimer(0.5, b_color_blue, entity);
	CreateTimer(0.6, b_color_nam, entity);
	CreateTimer(0.7, b_color_purple, entity);
}

public Action:b_color_red(Handle:timer, any:entity)
{
	SetEntityRenderColor(entity, red);
}

public Action:b_color_orange(Handle:timer, any:entity)
{
	SetEntityRenderColor(entity, orange);
}

public Action:b_color_yellow(Handle:timer, any:entity)
{
	SetEntityRenderColor(entity, yellow);
}

public Action:b_color_green(Handle:timer, any:entity)
{
	SetEntityRenderColor(entity, green);
}

public Action:b_color_blue(Handle:timer, any:entity)
{
	SetEntityRenderColor(entity, blue);
}

public Action:b_color_nam(Handle:timer, any:entity)
{
	SetEntityRenderColor(entity, nam);
}

public Action:b_color_purple(Handle:timer, any:entity)
{
	SetEntityRenderColor(entity, purple);
}

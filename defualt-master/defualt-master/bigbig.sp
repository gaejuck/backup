#include <sourcemod>
#include <sdkhooks>
#include <sdktools>
#include <tf2_stocks>

public OnPluginStart()
{	
	HookEvent("player_builtobject", Event_Player_BuiltObject, EventHookMode_Post);
}
 
public OnEntityCreated(entity, const String:classname[])
{
	if(StrContains(classname, "tf_projectile") != -1 || StrContains(classname, "item_ammopack") != -1
	|| StrContains(classname, "item_healthkit") != -1 || StrContains(classname, "tf_weapon") != -1
	|| StrEqual(classname, "tf_powerup_bottle", false) || StrContains(classname, "tf_wearable") != -1
	|| StrEqual(classname, "team_control_point", false))
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", GetRandomFloat(2.0, 5.0));
}

public Action:Event_Player_BuiltObject(Handle:event, const String:name[], bool:dontBroadcast)
{		
	new index = GetEventInt(event, "index");
	
	decl String:classname[32];
	GetEdictClassname(index, classname, sizeof(classname));
	
	if(StrContains("obj_", classname))
		SetEntPropFloat(index, Prop_Send, "m_flModelScale", GetRandomFloat(2.0, 5.0));

	return Plugin_Handled;
}

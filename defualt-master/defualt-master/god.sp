
#include <sourcemod>

public OnPluginStart()
{	
	RegConsoleCmd("sm_god", Command_God, "무적임");	
	RegConsoleCmd("sm_gg", Command_ngod, "무적풀림");
}

public Action:Command_God(client,args)
{
	SetEntProp(client, Prop_Data, "m_takedamage", 0, 1);
	PrintToChat(client, "무적");
}

public Action:Command_ngod(client,args)
{
	SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
	PrintToChat(client, "해제");
}

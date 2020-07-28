#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public OnPluginStart()
{
	RegConsoleCmd("li", aaaa);
}

public OnEntityCreated(iEntity, const String:classname[]) 
{
	LogMessage("Created : '%s'", classname);
}

public Action:aaaa(client, args)
{
	new String:color[64] = "144 195 212";
	new ent = MaxClients+1;
	while ((ent = FindEntityByClassname2(ent, "light")) != -1)
	{
		if (IsValidEntity(ent))
		{
			DispatchKeyValue(ent, "rendercolor", color);
			AcceptEntityInput(ent, "TurnOff");
		}
	}
	
	new ent2 = MaxClients+1;
	while ((ent2 = FindEntityByClassname2(ent2, "light_spot")) != INVALID_ENT_REFERENCE)
	{
		if (IsValidEntity(ent2))
		{
			DispatchKeyValue(ent2, "rendercolor", color);
			AcceptEntityInput(ent2, "TurnOff");
		}
	}
	
	new ent3 = MaxClients+1;
	while ((ent3 = FindEntityByClassname2(ent3, "light_dynamic")) != INVALID_ENT_REFERENCE)
	{
		if (IsValidEntity(ent3))
		{
			DispatchKeyValue(ent3, "rendercolor", color);
			AcceptEntityInput(ent3, "TurnOff");
		}
	}
	
	new ent4 = MaxClients+1;
	while ((ent4 = FindEntityByClassname2(ent4, "point_spotlight")) != INVALID_ENT_REFERENCE)
	{
		if (IsValidEntity(ent4))
		{
			DispatchKeyValue(ent4, "rendercolor", color);
			AcceptEntityInput(ent4, "TurnOff");
		}
	}
	return Plugin_Handled;
}

stock FindEntityByClassname2(startEnt, const String:classname[])
{
	while(startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

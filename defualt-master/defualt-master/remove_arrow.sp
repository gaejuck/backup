#include <sdktools>
#include <sdkhooks>

// new Handle:time = INVALID_HANDLE;

public OnPluginStart()
{
	// Enabled = CreateConVar("sm_rocket_enabled", "1", "켜기 끄기 1/0");
}

public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "tf_projectile_arrow"))
	{
		SDKHook(entity, SDKHook_StartTouch, OnExplode);
	}
}

public Action:OnExplode(entity, other) 
{
	if (!IsAClient(other))
	{
		AcceptEntityInput(entity, "Kill");
	}
	return Plugin_Handled;
}


IsAClient(index)
{
	if (1<=index<=MaxClients&&IsClientInGame(index))
	{
		return true;
	}
	else
	{
		return false;
	}
}

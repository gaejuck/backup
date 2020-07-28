#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "tf_projectile_rocket"))
	{
		SDKHook(entity, SDKHook_StartTouch, OnExplode);
	}
}

public Action:OnExplode(entity, other) 
{
	if (IsAClient(other))
	{
		expppplod(entity);
	}
	return Plugin_Handled;
}

public expppplod(entity)
{
	new explode = CreateEntityByName("env_explosion");
	if (IsValidEdict(explode))
	{
		decl Float:entitypos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
		
		// new Float:ClientOrigin[3];
		// GetClientAbsOrigin(other, ClientOrigin);
		
		DispatchKeyValue(explode, "iMagnitude", "2000")
		DispatchKeyValue(explode, "iRadiusOverride", "15")
		DispatchSpawn(explode);
		TeleportEntity(explode, entitypos, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(explode);
		AcceptEntityInput(explode, "Explode");
		CreateTimer(3.0, KillExplosion, explode)
	}
}

public Action:KillExplosion(Handle:timer, any:ent)
{
    if (IsValidEntity(ent))
    {
        new String:classname[256]
        GetEdictClassname(ent, classname, sizeof(classname))
        if (StrEqual(classname, "env_explosion", false))
        {
            RemoveEdict(ent)
        }
    }
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
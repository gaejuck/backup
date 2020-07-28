#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>

new Handle:cvar_friendlyfire = INVALID_HANDLE;

public OnPluginStart()
{
	RegServerCmd("tf_dodgeball_owner", SpeedAnnounce)
	cvar_friendlyfire = FindConVar("mp_friendlyfire");
}

public Action:SpeedAnnounce(iArgs)
{
	if(iArgs != 1)
	{
		PrintToServer("Usage: tf_dodgeball_owner @rocket")
		return Plugin_Handled;
	}
	new String:strBuffer[32];
	GetCmdArg(1, strBuffer, sizeof(strBuffer)); new itarget = StringToInt(strBuffer, 10);
	
	SetEntData(itarget, FindSendPropInfo("CTFProjectile_Rocket", "m_hOwnerEntity"), 0, true);
	return Plugin_Handled;
}

public OnGameFrame()
{
	new rocket = -1; 
	while ((rocket=FindEntityByClassname(rocket, "tf_projectile_sentryrocket"))!=INVALID_ENT_REFERENCE)
	{
		if(IsValidEntity(rocket))
		{
			SetEntData(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_iTeamNum"), 1, true);
			SetEntData(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_bCritical"), 1, 1, true);
		}
	}
} 

public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "tf_projectile_rocket"))
	{
		SDKHook(entity, SDKHook_Spawn, tf_projectile_rocket);
	}
	
	if(StrEqual(classname, "tf_projectile_sentryrocket"))
	{
		SDKHook(entity, SDKHook_Spawn, nuke);
		SDKHook(entity, SDKHook_StartTouch, OnExplode);
	}
}

public tf_projectile_rocket(entity)
{
	new friendlyfire = GetConVarInt(cvar_friendlyfire);
	if(friendlyfire == 1)
		SetConVarInt(cvar_friendlyfire, 0);
}

public nuke(entity)
{
	new friendlyfire = GetConVarInt(cvar_friendlyfire);
	if(friendlyfire == 0)
		SetConVarInt(cvar_friendlyfire, 1);
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

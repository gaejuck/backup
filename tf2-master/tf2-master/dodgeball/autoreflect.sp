#pragma semicolon 1

// ====[ INCLUDES ]============================================================
#include <sourcemod>
#include <sdktools>

// ====[ DEFINES ]=============================================================
#define PLUGIN_NAME				"Pyro Auto Reflect"
#define PLUGIN_VERSION			"1.0"

new Handle:g_hCvarAimClients,	bool:g_bCvarAimClients;

// ====[ VARIABLES ]===========================================================
new g_iOffsetActiveWeapon;
new g_bAutoReflecting			[MAXPLAYERS + 1]; 

// ====[ PLUGIN ]==============================================================
public Plugin:myinfo =
{
	name = "Auto Reflect",
	author = "ReFlexPoison",
	description = "Automatically reflect projectiles coming toward you as Pyro",
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
}

// ====[ EVENTS ]==============================================================
public OnPluginStart()
{
	CreateConVar("sm_autoreflect_version", PLUGIN_VERSION, PLUGIN_NAME, FCVAR_PLUGIN | FCVAR_SPONLY | FCVAR_DONTRECORD | FCVAR_NOTIFY);
	
	g_hCvarAimClients = CreateConVar("sm_autoreflect_aimclients", "1", "Aim at closest clients?\n0 = No\n1 = Yes", _, true, 0.0, true, 1.0);
	g_bCvarAimClients = GetConVarBool(g_hCvarAimClients);
	HookConVarChange(g_hCvarAimClients, OnConVarChange);

	HookEvent("player_spawn", PlayerSpawn);

	g_iOffsetActiveWeapon = FindSendPropInfo("CBasePlayer", "m_hActiveWeapon");

	for(new i = 1; i <= MaxClients; i++) if(IsValidClient(i))
		OnClientConnected(i);
}

public OnConVarChange(Handle:hConvar, const String:strOldValue[], const String:strNewValue[])
{
	if(hConvar == g_hCvarAimClients)
		g_bCvarAimClients = GetConVarBool(g_hCvarAimClients);
}

public OnClientConnected(iClient)
{
	g_bAutoReflecting[iClient] = false;
}


public Action:OnPlayerRunCmd(iClient, &iButtons, &iImpulse, Float:fVelocity[3], Float:fAngles[3], &iWeapon)
{
	if(!IsValidClient(iClient) || !g_bAutoReflecting[iClient])
		return Plugin_Continue;

	if(!IsPlayerAlive(iClient))
		return Plugin_Continue;

	new iCurrentWeapon = GetEntDataEnt2(iClient, g_iOffsetActiveWeapon);
	if(iCurrentWeapon == -1)
		return Plugin_Continue;

	decl Float:fClientEyePosition[3];
	GetClientEyePosition(iClient, fClientEyePosition);

	new iEntity = -1;
	while((iEntity = FindEntityByClassname(iEntity, "tf_projectile_*")) != INVALID_ENT_REFERENCE)
	{
		decl Float:fEntityLocation[3];
		GetEntPropVector(iEntity, Prop_Send, "m_vecOrigin", fEntityLocation);

		decl Float:fVector[3];
		MakeVectorFromPoints(fEntityLocation, fClientEyePosition, fVector);

		decl Float:fAngle[3];
		GetVectorAngles(fVector, fAngle);
		fAngle[0] *= -1.0;
		fAngle[1] += 180.0;

		if(GetVectorLength(fVector) < 350.0)
		{
			ModRateOfFire(iClient, iCurrentWeapon);
			TeleportEntity(iClient, NULL_VECTOR, fAngle, NULL_VECTOR);
			iButtons |= IN_ATTACK2;
			return Plugin_Changed;
		}
	}

	if(g_bCvarAimClients)
	{
		new iClosest = GetClosestClient(iClient);
		if(!IsValidClient(iClosest))
			return Plugin_Continue;

		decl Float:fClosestLocation[3];
		GetClientAbsOrigin(iClosest, fClosestLocation);
		fClosestLocation[2] += 90;

		decl Float:fVector[3];
		MakeVectorFromPoints(fClosestLocation, fClientEyePosition, fVector);

		decl Float:fAngle[3];
		GetVectorAngles(fVector, fAngle);
		fAngle[0] *= -1.0;
		fAngle[1] += 180.0;

		TeleportEntity(iClient, NULL_VECTOR, fAngle, NULL_VECTOR);
	}

	return Plugin_Continue;
}

// ====[ COMMANDS ]============================================================
public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsFakeClient(client))
		g_bAutoReflecting[client] = true;
}

// ====[ STOCKS ]==============================================================
stock bool:IsValidClient(iClient, bool:bReplay = true)
{
	if(iClient <= 0 || iClient > MaxClients)
		return false;
	if(!IsClientInGame(iClient))
		return false;
	if(bReplay && (IsClientSourceTV(iClient) || IsClientReplay(iClient)))
		return false;
	return true;
}

stock GetClosestClient(iClient)
{
	decl Float:fClientLocation[3];
	GetClientAbsOrigin(iClient, fClientLocation);
	decl Float:fEntityOrigin[3];

	new iClosestEntity = -1;
	new Float:fClosestDistance = -1.0;
	for(new i = 1; i < MaxClients; i++) if(IsValidClient(i))
	{
		if(GetClientTeam(i) != GetClientTeam(iClient) && IsPlayerAlive(i) && i != iClient)
		{
			GetClientAbsOrigin(i, fEntityOrigin);
			new Float:fEntityDistance = GetVectorDistance(fClientLocation, fEntityOrigin);
			if((fEntityDistance < fClosestDistance) || fClosestDistance == -1.0)
			{
				fClosestDistance = fEntityDistance;
				iClosestEntity = i;
			}
		}
	}
	return iClosestEntity;
}

//이 부분이 공격 속도 빨라지게 하는 부분

stock ModRateOfFire(iClient, iWeapon)
{
	new Float:m_flNextPrimaryAttack = GetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack");
	new Float:m_flNextSecondaryAttack = GetEntPropFloat(iWeapon, Prop_Send, "m_flNextSecondaryAttack");
	// SetEntPropFloat(iWeapon, Prop_Send, "m_flPlaybackRate", 10.0);

	new Float:fGameTime = GetGameTime();
	new Float:fPrimaryTime = ((m_flNextPrimaryAttack - fGameTime) - 0.99);
	new Float:fSecondaryTime = ((m_flNextSecondaryAttack - fGameTime) - 0.99);

	SetEntPropFloat(iWeapon, Prop_Send, "m_flNextPrimaryAttack", fPrimaryTime + fGameTime);
	SetEntPropFloat(iWeapon, Prop_Send, "m_flNextSecondaryAttack", fSecondaryTime + fGameTime);
}
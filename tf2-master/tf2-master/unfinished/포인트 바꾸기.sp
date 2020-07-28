#pragma semicolon 1
#include <sdktools>
#pragma newdecls required
#include <sourcemod>
#include <sdkhooks>

#define PLUGIN_VERSION "1.0"

ConVar ConVars[4] = {null, ...};
int gEnabled;
float gKills, gAssists, gDeaths;
float gScore[MAXPLAYERS+1];

public Plugin myinfo = 
{
	name = "[TF2] Score Points Changer",
	author = "Tak (Chaosxk)",
	description = "Changes how much points you get from kills / assists",
	version = PLUGIN_VERSION,
	url = ""
}

public void OnPluginStart()
{
	CreateConVar("sm_blackhole_version", "1.0", PLUGIN_VERSION, FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	ConVars[0] = CreateConVar("sm_spc_enabled", "1", "Enables/Disables Black hole rockets.");
	ConVars[1] = CreateConVar("sm_spc_kills", "3.0", "How many poitns for each kill?");
	ConVars[2] = CreateConVar("sm_spc_assists", "2.0", "How many points for each assist?");
	ConVars[3] = CreateConVar("sm_spc_deaths", "1.0", "How many points for each death?");
	
	for(int i = 0; i < 4; i++)
		ConVars[i].AddChangeHook(OnConvarChanged);
		
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
}

public void OnConfigsExecuted()
{
	gEnabled = !!GetConVarInt(ConVars[0]);
	gKills = GetConVarFloat(ConVars[1]);
	gAssists = GetConVarFloat(ConVars[2]);
	gDeaths = GetConVarFloat(ConVars[3]);
	
	FindPlayerManager();
}

public void OnConvarChanged(Handle convar, char[] oldValue, char[] newValue) 
{
	if (StrEqual(oldValue, newValue, true))
		return;
		
	float iNewValue = StringToFloat(newValue);
	
	if(convar == ConVars[0])
		gEnabled = !!RoundFloat(iNewValue);
	else if(convar == ConVars[1])
		gKills = iNewValue;
	else if(convar == ConVars[2])
		gAssists = iNewValue;
	else if(convar == ConVars[3])
		gDeaths = iNewValue;
}

public void OnClientPostAdminCheck(int client) 
{
	gScore[client] = 0.0;
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
	if(!gEnabled) 
		return Plugin_Continue;
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	int attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	int assister = GetClientOfUserId(GetEventInt(event, "assister"));
	if(IsClientValid(client)) 
	{
		if(gScore[client] > 0.0)
		{
			gScore[client] -= gDeaths;
		}
	}
	if(IsClientValid(attacker) && attacker != client)
	{
		gScore[attacker] += gKills;
	}
	if(IsClientValid(assister))
	{
		gScore[assister] += gAssists;
	}
	return Plugin_Continue;
}

public void Hook_ThinkPost(int entity) 
{
	if(!gEnabled)
		return;
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i) || gScore[i] < 0) 
			continue;
		int iScore = RoundToFloor(gScore[i]);
		SetEntProp(entity, Prop_Send, "m_iTotalScore", iScore, _, i);
	}
}

public void FindPlayerManager()
{
	int entity = GetPlayerResourceEntity();
	SDKHook(entity, SDKHook_ThinkPost, Hook_ThinkPost);
}

public bool IsClientValid(int client)
{
	return (1 <= client <= MaxClients && IsClientInGame(client));
}
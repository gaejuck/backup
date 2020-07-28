#include <sdkhooks>

bool g_bShot[MAXPLAYERS + 1];
int g_iShots[MAXPLAYERS + 1];
int g_iShotsHit[MAXPLAYERS + 1];
bool g_bShotCounter[MAXPLAYERS + 1];

Handle g_hHudShotCounter;

public void OnPluginStart()
{
	g_hHudShotCounter = CreateHudSynchronizer();
	
	RegConsoleCmd("sm_hit", aaaa);
}

public Action:aaaa(client, args)
{
	if(g_bShotCounter[client] == false)
	{
	
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i) && IsFakeClient(i))
			{
				SDKHook(i, SDKHook_TraceAttackPost, TraceAttack);
			}
		}
		g_bShotCounter[client] = true;
		PrintToChat(client, "ok");
	}
	else
	{
		g_bShotCounter[client] = false;
		PrintToChat(client, "no");
	}
	return Plugin_Handled;
}

public Action TF2_CalcIsAttackCritical(int client, int weapon, char[] weaponname, bool &result)
{
	g_bShot[client] = true;
	g_iShots[client]++;
	
	RequestFrame(DidHit, GetClientUserId(client));
	return Plugin_Continue;
}

public void TraceAttack(int victim, int attacker, int inflictor, float damage, int damagetype, int ammotype, int hitbox, int hitgroup)
{
	if(attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker))
	{
		RequestFrame(TraceAttackDelay, GetClientUserId(attacker));
	}
}
public void TraceAttackDelay(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client > 0)
	{
		if(g_bShot[client])
		{
			g_bShot[client] = false;
		}
	}
}

public void DidHit(int userid)
{
	int client = GetClientOfUserId(userid);
	if(client > 0)
	{
		if(!g_bShot[client])
			g_iShotsHit[client]++;
	}
}

public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(IsFakeClient(client) || !IsPlayerAlive(client)) 
		return Plugin_Continue;	
	
	if(g_bShotCounter[client])
	{
		SetHudTextParams(-1.0, 0.75, 0.1, 255, 0, 255, 0, 0, 0.0, 0.0, 0.0);
		
		int iShots = g_iShots[client];
		int iHits = g_iShotsHit[client];
		float flHitPerc = (float(iHits) / float(iShots)) * 100;
		
		ShowSyncHudText(client, g_hHudShotCounter, "Shots hit %i/%i [%.0f%%]", iHits, iShots, flHitPerc);
	}
	return Plugin_Continue;	
}

stock bool:IsValidClient(client)
{
	if(client<=0 || client>MaxClients)
	{
		return false;
	}

	if(!IsClientConnected(client) || !IsClientInGame(client))
	{
		return false;
	}
	return true;
}
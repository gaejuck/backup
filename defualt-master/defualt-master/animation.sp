#include <sourcemod>
#include <tf2items>
#include <tf2_stocks>
#include <sdkhooks>

#define SOLDIER "models/player/soldier.mdl"
#define PYRO "models/player/pyro.mdl"
#define HEAVY "models/player/heavy.mdl"
#define SCOUT "models/player/scout.mdl"

new check[MAXPLAYERS+1];


public OnPluginStart()
{
	RegConsoleCmd("sm_an", Animation);
}

public OnClientPutInServer(client) check[client] = 0;

public Action:Animation(client, args)
{
	new Handle:info = CreateMenu(AnimationSelect);
	SetMenuTitle(info, "애니메이션");
	AddMenuItem(info, "x", "없음");  
	AddMenuItem(info, "pyro_headshot", "파이로 헤드샷");  
	AddMenuItem(info, "pyro_pool", "파이로 풀");  
	AddMenuItem(info, "pyro_swim", "[어드민] 파이로 수영");  
	AddMenuItem(info, "pyro_god", "파이로 신이시여!!!");  
	AddMenuItem(info, "heavy_freeze", "얼린 돼지");  
	AddMenuItem(info, "pyro_backstob", "파이로 백스텝");   
	AddMenuItem(info, "scout_dark", "스카웃 저주의 신이시여!!!");  
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public AnimationSelect(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:info[24];
		GetMenuItem(menu, select, info, sizeof(info));
		
		if(StrEqual(info, "x")) 
		{
			check[client] = 0;
			
			new iEnt = -1; decl String:szName[30];
			while((iEnt = FindEntityByClassname(iEnt, "prop_dynamic_override")) != -1)
			{
				if(IsValidEntity(iEnt))
				{
					// new owner = GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity");
					GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
					if(StrEqual(szName, "animation")) AcceptEntityInput(iEnt, "Kill");
				}
			}
		}
		else if(StrEqual(info, "pyro_headshot"))
			check[client] = 1;
		else if(StrEqual(info, "pyro_pool"))
			check[client] = 2;
		else if(StrEqual(info, "pyro_swim"))
		{
			if(IsClientAdmin(client))
			{
				check[client] = 3;
			}
			else
			{
				check[client] = 0;
				PrintToChat(client, "\x03 어드민 전용입니다.");
			}
		}
		else if(StrEqual(info, "pyro_god"))
			check[client] = 4;
		else if(StrEqual(info, "heavy_freeze"))
			check[client] = 5;
		else if(StrEqual(info, "pyro_backstob"))
			check[client] = 6;
		else if(StrEqual(info, "scout_dark"))
			check[client] = 7;
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if(AliveCheck(client))
	{
		if(check[client] == 0) return Plugin_Continue;
		
		if(check[client] == 1)
			PlayAnimation(client, PYRO, "primary_death_headshot");
		else if(check[client] == 2)
			PlayAnimation(client, PYRO, "taunt_pyro_pool");
		else if(check[client] == 3)
			PlayAnimation(client, PYRO, "s_swimAlign_LOSER");
		else if(check[client] == 4)
			PlayAnimation(client, PYRO, "dieviolent");
		else if(check[client] == 5)
			PlayAnimation(client, HEAVY, "freeze");
		else if(check[client] == 6)
			PlayAnimation(client, PYRO, "primary_death_backstab");
		else if(check[client] == 7)
			PlayAnimation(client, SCOUT, "dieviolent");
	}
	return Plugin_Continue;
}


stock PlayAnimation(client, String:model[], String:anim[])
{
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
	// SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	// SetEntityRenderColor(client, 255, 255, 255, 0);
	
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 0);	
	// SetEntityMoveType(client, MOVETYPE_NONE);
	
	float vecOrigin[3], vecAngles[3];
	GetClientAbsOrigin(client, vecOrigin);
	GetClientAbsAngles(client, vecAngles);
	// vecAngles[0] = 0.0;

	new animationentity = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(animationentity))
	{
		DispatchKeyValueVector(animationentity, "origin", vecOrigin);
		DispatchKeyValueVector(animationentity, "angles", vecAngles);
		DispatchKeyValue(animationentity, "model", model);
		DispatchKeyValue(animationentity, "defaultanim", anim);
		DispatchKeyValue(animationentity, "targetname", "animation");
		DispatchSpawn(animationentity);
		SetEntPropEnt(animationentity, Prop_Send, "m_hOwnerEntity", client);
		
		if(GetEntProp(client, Prop_Send, "m_iTeamNum") == 0)
			SetEntProp(animationentity, Prop_Send, "m_nSkin", GetEntProp(client, Prop_Send, "m_nForcedSkin"));
		else
			SetEntProp(animationentity, Prop_Send, "m_nSkin", GetClientTeam(client) - 2);
			
		// SetEntPropFloat(animationentity, Prop_Send, "m_flModelScale", 2.0);
		SetEntProp(animationentity, Prop_Data, "m_spawnflags", 0);
		SetEntProp(animationentity, Prop_Send, "m_CollisionGroup", 5);
		
		SetVariantString("OnAnimationDone !self:KillHierarchy::0.0:1");
		AcceptEntityInput(animationentity, "AddOutput");
		
		HookSingleEntityOutput(animationentity, "OnAnimationDone", OnAnimationDone, true);
		// CreateTimer(0.5, ResetTaunt, client);
	}
}

public OnAnimationDone(const String:output[], caller, activator, Float:delay)
{	
	if(IsValidEntity(caller))
	{
		new client = GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity");
		if(client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client)) SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);	
	}
}

public bool:AliveCheck(client)
{
	if(client > 0 && client <= MaxClients)
		if(IsClientConnected(client) == true)
			if(IsClientInGame(client) == true)
				if(IsPlayerAlive(client) == true) return true;
				else return false;
			else return false;
		else return false;
	else return false;
}

stock bool:IsValidClient(iClient) {
    if (iClient <= 0) return false;
    if (iClient > MaxClients) return false;
    if (!IsClientConnected(iClient)) return false;
    return IsClientInGame(iClient);
}

stock bool:IsClientAdmin(client)
{
	new AdminId:Cl_ID;
	Cl_ID = GetUserAdmin(client);
	if(Cl_ID != INVALID_ADMIN_ID)
		return true;
	return false;
}

stock FindEntityByClassname2(startEnt, const String:classname[])	// because legacy
{
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

#include <sourcemod>
#include <tf2items>
#include <tf2_stocks>
#include <sdkhooks>

#define tp "models/weapons/v_smg1.mdl"
// #define tp "models/weapons/v_superphyscannon.mdl"

#define ATTACK "fire03"
#define IDLE "idle01"
#define ani 28

new g_effectsOffset;

new Handle:g_hSdkEquipWearable;


public OnPluginStart()
{
	HookEvent("player_spawn", Event_Player_Spawn);
	
	if ((g_effectsOffset = FindSendPropInfo("CBaseViewModel","m_fEffects"))  == -1)
	{	
		SetFailState("could not locate CBaseViewModel:m_fEffects");
	}
}
public OnPluginEnd()
{
	new iEnt = -1;
	decl String:szName[16];
	while ((iEnt = FindEntityByClassname(iEnt, "prop_dynamic")) != -1) 
	{
		GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
		if(StrEqual(szName, "fm_fakephysgun"))
			AcceptEntityInput(iEnt, "Kill");
	}
}

public Action:Event_Player_Spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	PrecacheModel(tp, true);
	CreateFakeHL2Model(client, tp);
	
	for(new i = 0; i <= 5; i++)
	{
		new iWeapon = GetPlayerWeaponSlot(client,i);
		if (IsValidEntity(iWeapon))
		{
			SetEntityRenderMode(iWeapon, RENDER_TRANSCOLOR);
			SetEntityRenderColor(iWeapon, 0, 0, 0, 0);
		}
	}

	return Plugin_Continue;
}
public Action:TF2_CalcIsAttackCritical(client, iWeapon, String:strWeaponname[], &bool:bResult)
{
	new iEnt = -1;
	decl String:szName[16];
	while ((iEnt = FindEntityByClassname(iEnt, "prop_dynamic")) != -1) 
	{
		if (GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client)
		{
		
			GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
			if(StrEqual(szName, "fm_fakephysgun"))
			{
				SetVariantString(ATTACK);
				AcceptEntityInput(iEnt, "SetAnimation", -1, -1, 0);
			}
		}
	}
}


CreateFakeHL2Model(iClient, String:sModel[])
{
	new iEntity = CreateEntityByName("prop_dynamic", -1);
	if (IsValidEntity(iEntity))
	{
		new Float:vecPos[3];
		new Float:vecAng[3];
		new Float:vecTempAng[3];
		new Float:vecPreAng[3];
		GetClientEyeAngles(iClient, vecTempAng);
		vecPreAng[0] = vecTempAng[0];
		vecPreAng[1] = vecTempAng[1];
		vecPreAng[2] = vecTempAng[2]; 
		
		TeleportEntity(iClient, NULL_VECTOR, vecTempAng, NULL_VECTOR);
		GetClientAbsOrigin(iClient, vecPos);
		GetClientEyeAngles(iClient, vecAng);
		SetEntityModel(iEntity, sModel);
		DispatchKeyValue(iEntity, "targetname", "fm_fakephysgun");
		DispatchKeyValue(iEntity, "solid", "6");
		DispatchKeyValue(iEntity, "renderfx", "0");
		DispatchKeyValue(iEntity, "rendercolor", "255 255 255");
		DispatchKeyValue(iEntity, "renderamt", "255");
		DispatchKeyValue(iEntity, "DefaultAnim", IDLE);
		DispatchKeyValue(iEntity, "disablereceiveshadows", "0");
		DispatchKeyValue(iEntity, "disableshadows", "1");
	
		SetEntProp(iEntity, Prop_Send, "m_nSolidType", 6);
		
		DispatchSpawn(iEntity);
		TeleportEntity(iEntity, vecPos, vecAng, NULL_VECTOR);
		SetEntProp(iClient, Prop_Send, "m_bDrawViewmodel", 1);
		
		SetParent(iEntity, GetEntPropEnt(iClient, Prop_Send, "m_hViewModel"));
		if (0 < iClient)
		{
			SetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity", iClient);
		}
		GetClientEyeAngles(iClient, vecTempAng);
		if (vecAng[1] != vecTempAng[1])
		{
			TeleportEntity(iEntity, NULL_VECTOR, vecTempAng, NULL_VECTOR);
		}
		TeleportEntity(iClient, NULL_VECTOR, vecPreAng, NULL_VECTOR);
	}
}

SetParent(iChild, iParent)
{
	DispatchKeyValue(iParent, "targetname", "23");
	DispatchKeyValue(iChild, "parentname", "23");
	SetVariantString("23");
	AcceptEntityInput(iChild, "SetParent", iChild, iChild, 0);
}

stock bool:IsClientAdmin(client)
{
	new AdminId:Cl_ID;
	Cl_ID = GetUserAdmin(client);
	if(Cl_ID != INVALID_ADMIN_ID)
		return true;
	return false;
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

stock FindEntityByClassname2(startEnt, const String:classname[])	// because legacy
{
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

#include <sdktools>
#include <sdkhooks>

// #define TIME 99.0

#define TEST "backpack/workshop/player/items/all_class/zoomin_broom/zoomin_broom_large"

new L;

public OnPluginStart()
{
	RegConsoleCmd("sm_he", Command_SpawnHeli);
}
public OnMapStart()
{
	new String:VmtCode[256], String:VtfCode[256];
	Format(VmtCode, 256, "materials/%s.vmt", TEST);
	Format(VtfCode, 256, "materials/%s.vtf", TEST);
	
	L = PrecacheModel(VmtCode, true); 

	AddFileToDownloadsTable(VmtCode);
	AddFileToDownloadsTable(VtfCode);
	
	PrecacheModel(VmtCode, true);
}

public Action:Command_SpawnHeli(client, args)
{
	new Float:LeftPos[3];
	GetClientEyePosition(client, LeftPos);

	
	LeftPos[0] += 100.0; //옆
	LeftPos[1] -= 120.0; //뒤
	LeftPos[2] += 20.0; //위
	
	TE_SetupGlowSprite(LeftPos, L, 3.0, 0.3, 255);
	TE_SendToAll();
	
	PropSpawn(LeftPos);
	
	new Float:RightPos[3];
	GetClientEyePosition(client, RightPos);
	
	RightPos[0] -= 150.0;
	RightPos[1] -= 100.0;
	RightPos[2] += 20.0;
	
	TE_SetupGlowSprite(RightPos, L, 3.0, 0.3, 255);
	TE_SendToAll();
	
	PropSpawn(RightPos);
	
	return Plugin_Handled;
}

stock PropSpawn(const Float:pos[3])
{
	new iEnt =  CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(iEnt, "model", "models/props_medieval/medieval_door.mdl");
	DispatchSpawn(iEnt);
	 
	SetEntityRenderMode(iEnt,RENDER_GLOW)
	SetEntityRenderColor(iEnt, 255, 255, 255, 0)
	
	SetEntProp(iEnt, Prop_Send, "m_nSolidType", 6);
	
	DispatchKeyValue(iEnt, "targetname", "prop");
	TeleportEntity(iEnt, pos, NULL_VECTOR, NULL_VECTOR);
	
	CreateTimer(3.0, RemoveProp, iEnt);
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if(AliveCheck(client))
	{
		new Float:flStartPos[3], Float:flEyeAng[3], Float:flHitPos[3];
		GetClientEyePosition(client, flStartPos);
		GetClientEyeAngles(client, flEyeAng);
		
		new Handle:hTrace = TR_TraceRayFilterEx(flStartPos, flEyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer, client);
		TR_GetEndPosition(flHitPos, hTrace);
		new iHitEntity = TR_GetEntityIndex(hTrace);
		CloseHandle(hTrace);
		
		if(iHitEntity > 0)
		{
			decl String:szName[64];
			GetEntPropString(iHitEntity, Prop_Data, "m_iName", szName, 16, 0);
			if(StrEqual(szName, "prop"))
			{
				switch(GetRandomInt(0,1))
				{
					case 0: PrintToChat(client, "방어");
					case 1: PrintToChat(client, "공격");
				}
			}
		}
	}
	return Plugin_Continue;
}
	//ServerCommand("sm_tauntem #%i %i", GetClientUserId(entity), 1118);
public Action:RemoveProp(Handle:timer, any:entity)
	AcceptEntityInput(entity, "Kill");

public bool:TraceEntityFilterPlayer(entity, mask, any:data)
{
	if (entity == data) 
		return false;
	
	return true;
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
#include <sdktools>
#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>

public Plugin:myinfo = 
{
	name = "랜덤 쓰리 로켓",
	author = "TAKE 2",
	description = "로켓 터질시 랜덤으로 3개의 로켓이 나옵니다.",
	version = "1.0",
	url = "x"
} 

new bool:toggle[MAXPLAYERS+1] = false;

new Handle:CvarSpeed = INVALID_HANDLE;
new Handle:CvarDmg = INVALID_HANDLE;

public OnPluginStart()
{
	CvarSpeed = CreateConVar("sm_tr_speed", "1000", "로켓 스피드");
	CvarDmg = CreateConVar("sm_tr_damage", "90", "로켓 데미지");
	RegAdminCmd("sm_tr", three_rocket, ADMFLAG_ROOT , "명령어 !tr");
}

public OnClientDisconnected(client)
	if(toggle[client]) toggle[client] = false;

public Action:three_rocket(client, args)
{
	decl String:arg[65];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM]\x03 sm_tr <name>");
		return Plugin_Handled;
	}
		
	GetCmdArg(1, arg, sizeof(arg));
		
	HasTarget = true;	
	
	decl String:target_name[MAX_TARGET_LENGTH];
	
	if (HasTarget)
	{
		decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
		
		if ((target_count = ProcessTargetString(
				arg,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_CONNECTED,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
		{
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}
		
		for (new i = 0; i < target_count; i++)
		{
			if(!toggle[target_list[i]])
			{
				toggle[target_list[i]] = true;
				PrintToChat(target_list[i], "\x07FFFFFF쓰리 로켓이 활성화되었습니다.");
			}
			else
			{
				toggle[target_list[i]] = false;
				PrintToChat(target_list[i], "\x07FFFFFF쓰리 로켓이 비 활성화되었습니다.");
			}
		}
	}
	return Plugin_Handled;
}

public OnEntityDestroyed(entity)
{
	if (IsValidEntity(entity))
	{
		new String:classname[32];
		new owner = GetEntPropEnt(entity,Prop_Data,"m_hOwnerEntity");
		
		if(AliveCheck(owner) && toggle[owner])
		{
			GetEntPropString(entity,Prop_Data,"m_iClassname",classname,sizeof(classname))
			
			decl String:szName[16];
			GetEntPropString(entity, Prop_Data, "m_iName", szName, 16, 0);
			
			if(StrEqual(classname, "tf_projectile_rocket") && StrEqual(szName, ""))
			{
				decl Float:fPos[3];
				decl Float:vAngles[3];
				
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", fPos);
				GetEntPropVector(entity, Prop_Data, "m_angRotation", vAngles);
				
				new Float:one[3], Float:two[3], Float:three[3];
				new Float:two_pos[3], Float:three_pos[3];
				
				one[0] = -vAngles[0];
				one[1] = -vAngles[1];
				one[2] = -vAngles[2];
				
				
				two[0] = -vAngles[0];
				two[1] = -vAngles[1] * GetRandomFloat(2.0, 7.0);
				two[2] = -vAngles[2];
				
				two_pos[0] = fPos[0];
				two_pos[1] = fPos[1] + 2;
				two_pos[2] = fPos[2];
				
				
				three[0] = -vAngles[0];
				three[1] = -vAngles[1] * GetRandomFloat(-2.0, -7.0);
				three[2] = -vAngles[2];
				
				three_pos[0] = fPos[0];
				three_pos[1] = fPos[1] - 2;
				three_pos[2] = fPos[2];
				
				ShootProjectile(owner, fPos, one, "tf_projectile_rocket", "asdf", GetConVarFloat(CvarSpeed), GetConVarFloat(CvarDmg)); 
				ShootProjectile(owner, two_pos, two, "tf_projectile_rocket", "asdf", GetConVarFloat(CvarSpeed), GetConVarFloat(CvarDmg));
				ShootProjectile(owner, three_pos, three, "tf_projectile_rocket", "asdf", GetConVarFloat(CvarSpeed), GetConVarFloat(CvarDmg));
			}
		}
	}
}

ShootProjectile(client, Float:vPosition[3], Float:vAngles[3] = NULL_VECTOR, String:strEntname[], String:targetname[], Float:Speed, Float:dmg)
{
	new iTeam = GetClientTeam(client);
	new iProjectile = CreateEntityByName(strEntname);
	
	if (!IsValidEntity(iProjectile))
		return -1;
	
	decl Float:vVelocity[3];
	decl Float:vBuffer[3];
	
	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
	
	vVelocity[0] = vBuffer[0]*Speed;
	vVelocity[1] = vBuffer[1]*Speed;
	vVelocity[2] = vBuffer[2]*Speed;
	
	SetEntPropEnt(iProjectile, Prop_Send, "m_hOwnerEntity", client);
	if (IsCritBoosted(client)) SetEntProp(iProjectile, Prop_Send, "m_bCritical", 1);
	else SetEntProp(iProjectile, Prop_Send, "m_bCritical", 0);
	SetEntProp(iProjectile,    Prop_Send, "m_iTeamNum", iTeam, 1);
	SetEntProp(iProjectile,    Prop_Send, "m_nSkin", (iTeam-2));
	DispatchKeyValue(iProjectile, "targetname", targetname);

	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "SetTeam", -1, -1, 0);
	if (strcmp(strEntname, "tf_projectile_rocket", false) == 0) SetEntDataFloat(iProjectile, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, dmg, true);
	else SetEntPropFloat(iProjectile, Prop_Send, "m_flDamage", dmg);
	TeleportEntity(iProjectile, vPosition, vAngles, vVelocity); 
	DispatchSpawn(iProjectile);
	return iProjectile;
}

public bool:AliveCheck(client)
{
	if(client > 0 && client <= MaxClients)
		if(IsClientConnected(client) == true)
			if(IsClientInGame(client) == true) return true;
			else return false;
		else return false;
	else return false;
}

stock bool:IsCritBoosted(client)
{
	if (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged) || TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy) || TF2_IsPlayerInCondition(client, TFCond_CritCanteen) || TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood) || TF2_IsPlayerInCondition(client, TFCond_CritOnWin) || TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture) || TF2_IsPlayerInCondition(client, TFCond_CritOnKill) || TF2_IsPlayerInCondition(client, TFCond_CritMmmph) || TF2_IsPlayerInCondition(client, TFCond_CritOnDamage))
	{
		return true;
	}
	return false;
}

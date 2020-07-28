#include <sourcemod>
#include <sdktools>

#define SPEED 500.0
#define DAMAGE 90.0
#define TEAM 0
#define DOWN -2000.0

#define ROCKETMODEL "models/weapons/w_models/w_baseball.mdl"

public OnPluginStart() 
{
	RegAdminCmd("z", aaaa, 0);
}

public OnMapStart()
{
	AddFileToDownloadsTable(ROCKETMODEL);
	PrecacheModel(ROCKETMODEL);
}

public Action:aaaa(client, args)
{
	new Float:pos[3]; 
	GetClientEyePosition(client,pos);
	
	pos[2] -= 10.0;
	
	new Float:ang[3];
	
	GetClientEyeAngles(client, ang);

	new ball = FireTeamRocket("tf_projectile_rocket", pos, ang, client, TEAM, SPEED, DAMAGE);
	
	SetEntityModel(ball, ROCKETMODEL);
	SetEntPropFloat(ball, Prop_Send, "m_flModelScale", 3.0); 
		
	return Plugin_Handled;
}

stock FireTeamRocket(String:classname[], Float:vPos[3], Float:vAng[3], iOwner = 0, iTeam = 0, Float:flSpeed = 1100.0, Float:flDamage = 90.0, bool:bCrit = false, iWeapon = -1)
{
	new iRocket = CreateEntityByName(classname);
	if (IsValidEntity(iRocket))
	{
		decl Float:vVel[3]; // Determine velocity based on given speed/angle
		GetAngleVectors(vAng, vVel, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vVel, flSpeed);
        
		if(!StrEqual(classname, "tf_projectile_energy_ball"))
			SetEntProp(iRocket, Prop_Send, "m_bCritical", bCrit);

		SetRocketDamage(iRocket, flDamage);

		SetEntProp(iRocket, Prop_Send, "m_nSkin", iTeam); // 0 = RED 1 = BLU
		SetEntProp(iRocket, Prop_Send, "m_iTeamNum", iTeam, 1);
		SetVariantInt(iTeam);
		AcceptEntityInput(iRocket, "TeamNum");
		SetVariantInt(iTeam);
		AcceptEntityInput(iRocket, "SetTeam");

		if (iOwner != -1)
		{
			SetEntPropEnt(iRocket, Prop_Send, "m_hOwnerEntity", iOwner);
		}
		TeleportEntity(iRocket, vPos, vAng, vVel);
		
		if(GetClientButtons(iOwner) & IN_ATTACK2)
		{
			vVel[2] = DOWN;
			TeleportEntity(iRocket, NULL_VECTOR, NULL_VECTOR, vVel);
		}
		DispatchSpawn(iRocket);

		if (iWeapon != -1)
		{
			SetEntPropEnt(iRocket, Prop_Send, "m_hOriginalLauncher", iWeapon); 
			SetEntPropEnt(iRocket, Prop_Send, "m_hLauncher", iWeapon); 
		}
		
		CreateTimer(0.1, button, EntIndexToEntRef(iRocket), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
        
		return iRocket;
	}
	return -1; 
}

public Action:button(Handle:hTimer, any:iEntityRef)
{
	new iEntity = EntRefToEntIndex(iEntityRef);
	if(!IsValidEntity(iEntity)) return Plugin_Stop;
	new iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
	
	if(GetClientButtons(iOwner) & IN_ATTACK2)
	{
		new Float:vVel[3];
		new Float:ang[3];
		vVel[2] = -800.0;
		ang[1] = -800.0;
		TeleportEntity(iEntity, NULL_VECTOR, ang, vVel);
	}
	return Plugin_Continue;
}

static s_iRocketDmgOffset = -1;

stock SetRocketDamage(iRocket, Float:flDamage)
{
    if (s_iRocketDmgOffset == -1)
    {
        s_iRocketDmgOffset = FindSendPropOffs("CTFProjectile_Rocket", "m_iDeflected") + 4; // Credit to voogru
    }
    SetEntDataFloat(iRocket, s_iRocketDmgOffset, flDamage, true);
}

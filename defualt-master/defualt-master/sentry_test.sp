#include <sdktools>
#include <sdkhooks>

public OnPluginStart()
{
	RegAdminCmd("sr", gg, 0);
}

//서버 터트림
public Action:gg(client, args)
{
	new Float:PA[3]; 
	new Float:PB[3]; 
	
	new Float:PC[3]; 
	new Float:PD[3]; 
	
	new Float:cow[3]; 

	GetClientEyePosition(client,PA);
	GetClientEyePosition(client,PB);
	
	GetClientEyePosition(client,PC);
	GetClientEyePosition(client,PD);
	
	GetClientEyePosition(client,cow);
	
	PA[1] += -70.0; 	PA[2] += 30.0; 	//왼쪽 
	PB[1] += 70.0;		PB[2] += 30.0;	//오른쪽
	
	PC[1] += -70.0; 	PC[2] += -60.0;
	PD[1] += 70.0;		PD[2] += -60.0;
	
	new Float:AA[3];
	
	GetClientEyeAngles(client, AA);

	FireTeamRocket("tf_projectile_sentryrocket", PA, AA, client, 0, 500.0);
	FireTeamRocket("tf_projectile_sentryrocket", PB, AA, client, 0, 500.0);
	
	FireTeamRocket("tf_projectile_sentryrocket", PC, AA, client, 0, 500.0);
	FireTeamRocket("tf_projectile_sentryrocket", PD, AA, client, 0, 500.0);
	
	
	FireTeamRocket("tf_projectile_energy_ball", cow, AA, client, 0, 500.0);
	
	
	
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
        
        // I found this offset while trying to fix the sudden-explode issue with these rockets. it's another instance
        // of the owner entity, so why the hell not copy this over...probably useful for some things.
        // new iTestOffset = FindSendPropOffs("CTFProjectile_Rocket", "m_bCritical") - 4;
        // SetEntDataEnt2(iRocket, iTestOffset, iOwner, true); // GetEntDataEnt2(baseRocket, iTestOffset)

        TeleportEntity(iRocket, vPos, vAng, vVel);
        DispatchSpawn(iRocket);
        
        //SetEntProp(iRocket, Prop_Send, "m_nSolidType", );       // GetEntProp(baseRocket, Prop_Send, "m_nSolidType")
        //SetEntProp(iRocket, Prop_Send, "m_usSolidFlags", );     // GetEntProp(baseRocket, Prop_Send, "m_usSolidFlags")
        //SetEntProp(iRocket, Prop_Send, "m_CollisionGroup", );   // GetEntProp(baseRocket, Prop_Send, "m_CollisionGroup")
        // if (iOwner != -1)
        // {
        //     SetEntDataEnt2(iRocket, iTestOffset, iOwner, true);      // GetEntDataEnt2(baseRocket, testOffset)
        // }
        
        if (iWeapon != -1)
        {
            SetEntPropEnt(iRocket, Prop_Send, "m_hOriginalLauncher", iWeapon); 
			// GetEntPropEnt(baseRocket, Prop_Send, "m_hOriginalLauncher")
            SetEntPropEnt(iRocket, Prop_Send, "m_hLauncher", iWeapon); 
			// GetEntPropEnt(baseRocket, Prop_Send, "m_hLauncher")
        }
        

        //if (false) SetEntProp(iRocket, Prop_Send, "m_nModelIndex", ); // GetEntProp(baseRocket, Prop_Send, "m_nModelIndex")
        
        // trail override
        //if (strlen(MS_TrailEffectOverride[bossClientIdx]) > 3)
        //{
        //  new particle = AttachParticle(iRocket, MS_TrailEffectOverride[bossClientIdx]);
        //  if (IsValidEntity(particle))
        //      CreateTimer(MS_ROCKET_LIFE, RemoveEntity, EntIndexToEntRef(particle));
        //}
        
        return iRocket;
    }
    return -1;
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

stock Float:GetRocketDamage(iRocket)
{
    if (s_iRocketDmgOffset == -1)
    {
        s_iRocketDmgOffset = FindSendPropOffs("CTFProjectile_Rocket", "m_iDeflected") + 4; // Credit to voogru
    }
    return GetEntDataFloat(iRocket, s_iRocketDmgOffset);
}

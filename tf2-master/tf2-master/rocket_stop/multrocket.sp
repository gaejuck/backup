new RocketAmount[2049] = {1, ...};

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if(Check[client] && ToolNum[client] == 1)
	{
		if(IsValidEntity(weapon) && AliveCheck(client))
		{
			if(StrEqual(weaponname, "tf_weapon_rocketlauncher"))
			{
				RocketAmount[weapon] = RocketNum[client] -1;
						
				new Float:vAngles[3], Float:vAngles2[3], Float:vPosition[3], Float:vPosition2[3];
				new Float:Axis = (0.0-(RocketAmount[weapon]*2.5));

				GetClientEyeAngles(client, vAngles2);
				GetClientEyePosition(client, vPosition2);
				new counter = 0; 

				vPosition[0] = vPosition2[0];
				vPosition[1] = vPosition2[1];
				vPosition[2] = vPosition2[2];
				for (new i = 0; i <= RocketAmount[weapon]; i++)
				{
					vAngles[0] = vAngles2[0];
					vAngles[1] = vAngles2[1]+Axis; 
					Axis += 5.0;

					new i2 = i%4;
					switch (i2)
					{
						case 0:
						{
							counter++;
							vPosition[0] = vPosition2[0] + counter;
						}
						case 1: vPosition[1] = vPosition2[1] + counter;
						case 2: vPosition[0] = vPosition2[0] - counter;
						case 3: vPosition[1] = vPosition2[1] - counter;
					}
					
					if(RocketToolNum[client] == 1) ShootProjectile(client, vPosition, vAngles, "tf_projectile_rocket", "", 1100.0, 90.0);
					else if(RocketToolNum[client] == 2) ShootProjectile(client, vPosition, vAngles, "tf_projectile_rocket", "Ice_Rocket",1100.0, 90.0);
					else ShootProjectile(client, vPosition, vAngles, "tf_projectile_rocket", "Fire_Rocket", 1100.0, 90.0);
				}
			}
		}
	}
	return Plugin_Continue;
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

stock bool:IsCritBoosted(client)
{
	if (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged) || TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy) || TF2_IsPlayerInCondition(client, TFCond_CritCanteen) || TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood) || TF2_IsPlayerInCondition(client, TFCond_CritOnWin) || TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture) || TF2_IsPlayerInCondition(client, TFCond_CritOnKill) || TF2_IsPlayerInCondition(client, TFCond_CritMmmph) || TF2_IsPlayerInCondition(client, TFCond_CritOnDamage))
	{
		return true;
	}
	return false;
}
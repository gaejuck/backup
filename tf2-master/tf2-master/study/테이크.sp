public OnClientPutInServer(client)
	if(!IsFakeClient(client)) 
		SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
		
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if (AliveCheck(victim) && AliveCheck(attacker)) //일반 클래스가 스파이를 때리면 데미지 3방에 스파이 사망 그런어미 ㅇㅇ
	{
		if(TF2_GetPlayerClass(attacker) != TFClassType:TFClass_Spy)
		{
			if(TF2_GetPlayerClass(victim) == TFClassType:TFClass_Spy)
			{
				damage = 333333333.0;
				return Plugin_Changed;
			}
		}
	}     
	return Plugin_Continue; 
}

public Action:OnTakeDamage(iVictim, &attacker, &inflictor, &Float:flDamage, &damagetype)
{
	decl String:sWeapon[64];
	
	if(AliveCheck(attacker) && AliveCheck(iVictim))
	{
		GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
		if(StrEqual(sWeapon, "tf_weapon_shovel")
		{
			flDamage *= 0.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

//다른 온테이크데미지 임
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damagecustom)
{
	if (AliveCheck(attacker))
	{
		if(TF2_GetPlayerClass(attacker) == TFClassType:TFClass_Spy)
		{
			if (damagecustom & TF_CUSTOM_BACKSTAB)
			{
				if(BackstabAllow == false)
				{
					damage = 15.0;
					return Plugin_Changed;
				}
				else
				{
					damage = 9999.0;
					return Plugin_Changed;
				}
			}
		}
	}     
	return Plugin_Continue; 
}

if (damagetype & DMG_CRIT)  //크리 데미지 수정
{
}
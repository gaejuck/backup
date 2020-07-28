#include <sourcemod>
#include <sdkhooks>
#include <sdktools> 
#include <tf2attributes>

public OnGameFrame()
{
	new rocket = -1; 
	while ((rocket=FindEntityByClassname(rocket, "tf_projectile_rocket"))!=INVALID_ENT_REFERENCE)
	{
		if(IsValidEntity(rocket))
		{
			SetEntData(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_iTeamNum"), 0, true);
			SetEntData(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_bCritical"), 1, 1, true); 
		}
	}
} 

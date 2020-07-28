#include <sourcemod>
#include <sdkhooks>

public OnGameFrame()
{
	for(new i = 1; i <= MaxClients; i++)
	{
		new rocket = -1;
		decl Float:entityposition[3];
		while ((rocket=FindEntityByClassname(rocket, "tf_projectile_*"))!=INVALID_ENT_REFERENCE)
		{
			// GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", entityposition);
		//	entityposition[2] = entityposition[2] + 10.0;
			// if(IsValidEntity(rocket) && GetEntPropEnt(rocket, Prop_Send, "m_hOwnerEntity") == i)
			// {
			TeleportEntity(i, entityposition, NULL_VECTOR, NULL_VECTOR);
			// }
		}
	}
}


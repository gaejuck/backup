#include <sdktools>
#include <tf2_stocks>

#define JUMP -650.0
#define VEL 0.300
#define GROUND 0


// =========================================================================
// >> EVENT
// =========================================================================

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if(IsValidEntity(weapon) && AliveCheck(client))
	{
		if(TF2_GetPlayerClass(client) != TFClassType:TFClass_Soldier || TF2_GetPlayerClass(client) != TFClassType:TFClass_DemoMan)
            PlayerKnockback(client);
	}
}

// =========================================================================
// >> PLAYER
// =========================================================================

public void PlayerKnockback(int iPlayer)
{
    // === Check if the player is on the ground
    if (!(GetEntityFlags(iPlayer) & FL_ONGROUND) || GROUND)
    {
        float vVelocity[3];
        float vEyeAngles[3];
        float vInvVector[3];
        
        // === Get the player data
        GetEntPropVector(iPlayer, Prop_Data, "m_vecVelocity", vVelocity);
        GetClientEyeAngles(iPlayer, vEyeAngles);
        
        // === Compute the vectors
        GetAngleVectors(vEyeAngles, vInvVector, NULL_VECTOR, NULL_VECTOR);
        ScaleVector(vInvVector, JUMP);
        ScaleVector(vVelocity, VEL);
        AddVectors(vVelocity, vInvVector, vVelocity);
            
        // === Apply the new velocity to the player
        TeleportEntity(iPlayer, NULL_VECTOR, NULL_VECTOR, vVelocity);
    }
}

// =========================================================================

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
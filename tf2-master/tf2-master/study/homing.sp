#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

public OnGameFrame()
{
	new rocket = -1;
	// decl Float:entityposition[3];
	while ((rocket=FindEntityByClassname(rocket, "tf_projectile_rocket"))!=INVALID_ENT_REFERENCE)
	{
		SetHomingProjectile(rocket, "tf_projectile_rocket");
	}
}

SetHomingProjectile(client, const String:classname[])
{
	new entity = -1; 
	while((entity = FindEntityByClassname(entity, classname))!=INVALID_ENT_REFERENCE)
	{
		new owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
		if(!IsValidEntity(owner)) continue;
		if(StrEqual(classname, "tf_projectile_sentryrocket", false)) owner = GetEntPropEnt(owner, Prop_Send, "m_hBuilder");		
		new Target = GetClosestTarget(entity, owner);
		if(!Target) continue;
		if(owner == client)
		{
			new Float:ProjLocation[3], Float:ProjVector[3], Float:ProjSpeed, Float:ProjAngle[3], Float:TargetLocation[3], Float:AimVector[3];			
			GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", ProjLocation);
			GetClientAbsOrigin(Target, TargetLocation);
			TargetLocation[2] += 40.0;
			MakeVectorFromPoints(ProjLocation, TargetLocation , AimVector);
			GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", ProjVector);					
			ProjSpeed = GetVectorLength(ProjVector);					
			AddVectors(ProjVector, AimVector, ProjVector);	
			NormalizeVector(ProjVector, ProjVector);
			GetEntPropVector(entity, Prop_Data, "m_angRotation", ProjAngle);
			GetVectorAngles(ProjVector, ProjAngle);
			SetEntPropVector(entity, Prop_Data, "m_angRotation", ProjAngle);					
			ScaleVector(ProjVector, ProjSpeed);
			SetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", ProjVector);
		}
	}	
}

GetClosestTarget(entity, owner)
{
	new Float:TargetDistance = 0.0;
	new ClosestTarget = 0;
	for(new i = 1; i <= MaxClients; i++) 
	{
		if(!IsClientConnected(i) || !IsPlayerAlive(i) || i == owner || (GetClientTeam(owner) == GetClientTeam(i))) continue;
		new Float:EntityLocation[3], Float:TargetLocation[3];
		GetEntPropVector(entity, Prop_Data, "m_vecAbsOrigin", EntityLocation);
		GetClientAbsOrigin(i, TargetLocation);
		
		new Float:distance = GetVectorDistance(EntityLocation, TargetLocation);
		if(TargetDistance)
		{
			if(distance < TargetDistance) 
			{
				ClosestTarget = i;
				TargetDistance = distance;			
			}
		}
		else
		{
			ClosestTarget = i;
			TargetDistance = distance;
		}
	}
	return ClosestTarget;
}


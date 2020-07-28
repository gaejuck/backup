#include <sourcemod>
#include <sdktools>
#include "sdkhooks"
#include <tf2_stocks>

new String:TempString[32];

new Float:EyeAngle[3];
new Float:PlayerVel[3];

new Handle:cvar_pyrofly;

new GroundEntity;

public OnPluginStart()
{
	cvar_pyrofly = CreateConVar("pyro_fly", "1", "파이로 하느을 나알기이");
}

public OnGameFrame()
{
	for(new i = 1; i <= GetMaxClients(); i++)
	{
		if(IsClientConnectedIngame(i))
		{
			GroundEntity = GetEntPropEnt(i, Prop_Send, "m_hGroundEntity");
			GetEntPropVector(i, Prop_Data, "m_vecVelocity", PlayerVel);             
             
			if(GroundEntity != -1){} 

			GetClientWeapon(i,TempString,32); 
			if( (strcmp(TempString,"tf_weapon_flamethrower") == 0) && cvar_pyrofly && (GetClientButtons(i) & IN_ATTACK))  
			{ 
				GetClientEyeAngles(i, EyeAngle); 
							 
				PlayerVel[2] = PlayerVel[2] + ( 18.7 * Sine(EyeAngle[0]*3.14159265/80.0) ); 
							 
				if(PlayerVel[2] > 700.0) 
				{ 
					PlayerVel[2] = 700.0; 
				} 
							 
				PlayerVel[0] = PlayerVel[0] - ( 3.0 * Cosine(EyeAngle[0]*3.14159265/80.0) * Cosine(EyeAngle[1]*3.14159265/80.0) ); 
				PlayerVel[1] = PlayerVel[1] - ( 3.0 * Cosine(EyeAngle[0]*3.14159265/80.0) * Sine(EyeAngle[1]*3.14159265/80.0) ); 
							 
				TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, PlayerVel); 
			} 
		}	
	}	
	
	for(new i = 1; i <= GetMaxClients(); i++)
	{
		if(IsClientConnectedIngame(i))
		{
			GroundEntity = GetEntPropEnt(i, Prop_Send, "m_hGroundEntity");
			GetEntPropVector(i, Prop_Data, "m_vecVelocity", PlayerVel);             
             
			if(GroundEntity != -1){} 

			GetClientWeapon(i,TempString,32); 
			if( (strcmp(TempString,"tf_weapon_syringegun_medic") == 0) && cvar_pyrofly && (GetClientButtons(i) & IN_ATTACK))  
			{ 
				GetClientEyeAngles(i, EyeAngle); 
							 
				PlayerVel[2] = PlayerVel[2] + ( 18.7 * Sine(EyeAngle[0]*3.14159265/80.0) ); 
							 
				if(PlayerVel[2] > 700.0) 
				{ 
					PlayerVel[2] = 700.0; 
				} 
							 
				PlayerVel[0] = PlayerVel[0] - ( 3.0 * Cosine(EyeAngle[0]*3.14159265/80.0) * Cosine(EyeAngle[1]*3.14159265/80.0) ); 
				PlayerVel[1] = PlayerVel[1] - ( 3.0 * Cosine(EyeAngle[0]*3.14159265/80.0) * Sine(EyeAngle[1]*3.14159265/80.0) ); 
							 
				TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, PlayerVel); 
			} 
		}	
	}	
	
	for(new i = 1; i <= GetMaxClients(); i++)
	{
		if(IsClientConnectedIngame(i))
		{
			GroundEntity = GetEntPropEnt(i, Prop_Send, "m_hGroundEntity");
			GetEntPropVector(i, Prop_Data, "m_vecVelocity", PlayerVel);             
             
			if(GroundEntity != -1){} 

			GetClientWeapon(i,TempString,32); 
			if ((strcmp(TempString,"tf_weapon_minigun") == 0) && cvar_pyrofly && (GetClientButtons(i) & IN_ATTACK))
			{ 
				GetClientEyeAngles(i, EyeAngle); 
							 
				PlayerVel[2] = PlayerVel[2] + ( 18.7 * Sine(EyeAngle[0]*3.14159265/80.0) ); 
							 
				if(PlayerVel[2] > 700.0) 
				{ 
					PlayerVel[2] = 700.0; 
				} 
							 
				PlayerVel[0] = PlayerVel[0] - ( 3.0 * Cosine(EyeAngle[0]*3.14159265/80.0) * Cosine(EyeAngle[1]*3.14159265/80.0) ); 
				PlayerVel[1] = PlayerVel[1] - ( 3.0 * Cosine(EyeAngle[0]*3.14159265/80.0) * Sine(EyeAngle[1]*3.14159265/80.0) ); 
							 
				TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, PlayerVel); 
			} 
		}	
	}	
}  

stock bool:IsClientConnectedIngame(client){
	
	if(client > 0 && client <= MaxClients){
	
		if(IsClientConnected(client) == true){
			
			if(IsClientInGame(client) == true){
			
				return true;
				
			}else{
				
				return false;
				
			}
			
		}else{
					
			return false;
					
		}
		
	}else{
		
		return false;
		
	}
	
}

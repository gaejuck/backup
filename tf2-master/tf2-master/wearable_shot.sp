#include <sdkhooks>
#include <tf2_stocks>
#include <tf2itemsinfo>
#include <tf2items>

public void OnPluginStart()
{
	for (int client = 1; client <= MaxClients; client++)
	{
		if(IsClientInGame(client))
		{
			SDKHook(client, SDKHook_TraceAttack, TraceAttack);
		}
	}
	
	HookEvent("post_inventory_application", inventory, EventHookMode_Pre);
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_TraceAttackPost, TraceAttack);
}

new PlayerItem[MAXPLAYERS+1][3];
new ItemCount[MAXPLAYERS+1];
new Float:PlayerDamage[MAXPLAYERS+1];

public Action:inventory(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	ItemCount[client] = 0;

	new iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "tf_wearable")) != -1) 
	{
		if(GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client && IsValidEntity(iEnt))
		{
			new index = GetEntProp(iEnt, Prop_Send, "m_iItemDefinitionIndex");
			
			if (ItemCount[client] >= 4) return Plugin_Continue;
			
			SetEntProp(client, Prop_Data, "m_takedamage", 1, 1);
			
			PlayerItem[client][ItemCount[client]] = index;
			ItemCount[client]++;
		}
	}
	return Plugin_Continue;
}

public Action TraceAttack(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if(attacker > 0 && attacker <= MaxClients && IsClientInGame(attacker) 
	&& victim > 0 && victim <= MaxClients && IsClientInGame(victim) && IsPlayerAlive(victim))
	// && hitgroup == 1 && TF2_GetPlayerClass(attacker) == TFClass_Sniper && IsPlayerAlive(victim))
	{
		int weapon = GetEntPropEnt(attacker, Prop_Data, "m_hActiveWeapon");
		if(IsValidEntity(weapon))
		{
			if (ItemCount[victim] > 0)
			{
				if(PlayerDamage[victim] <= 100.0)
				{
					PlayerDamage[victim] = PlayerDamage[victim] + damage;		
					// PrintToChat(victim, "%.1f", PlayerDamage[victim]);
				}
				else
				{
					int iHat = FindPlayerWearable(victim);
					if(IsValidEntity(iHat))
					{

						int index = GetEntProp(iHat, Prop_Send, "m_iItemDefinitionIndex");
							
						if(PlayerItem[victim][0] == index) ItemCount[victim]--;		
						if(PlayerItem[victim][1] == index) ItemCount[victim]--;		
						if(PlayerItem[victim][2] == index) ItemCount[victim]--;
									
						char strModelPath[PLATFORM_MAX_PATH];
						GetEntPropString(iHat, Prop_Data, "m_ModelName", strModelPath, PLATFORM_MAX_PATH);
								
						float flPos[3], flAng[3];
						GetClientEyePosition(victim, flPos);
						GetClientEyeAngles(victim, flAng);
									
						TF2_RemoveWearable(victim, iHat);
						AcceptEntityInput(iHat, "Kill");
									
						int ent = CreateEntityByName("tf_ammo_pack");
						if (IsValidEntity(ent))
						{
							PrecacheModel(strModelPath);
							PrintToChatAll("%s", strModelPath);
							DispatchKeyValueVector(ent, "origin", flPos);
							DispatchKeyValueVector(ent, "angles", flAng);
									
							new Float:basevec[3] = {0.0, 30.0, 0.0};
							new Float:vec[3] = {0.0, 10.0, 0.0};
							DispatchKeyValueVector(ent, "basevelocity", basevec);
							DispatchKeyValueVector(ent, "velocity", vec);
							DispatchKeyValue(ent, "model", strModelPath);
							DispatchKeyValue(ent, "OnPlayerTouch", "!self,Kill,,0,-1"); 		
							DispatchSpawn(ent);
										
							SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
							if(TF2_GetClientTeam(victim) != TFTeam_Red) SetEntProp(ent, Prop_Send, "m_nSkin", GetEntProp(ent, Prop_Send, "m_nSkin") + 1);
										
							char addoutput[64];
							Format(addoutput, sizeof(addoutput), "OnUser1 !self:kill::60:1");
							SetVariantString(addoutput);
										
							AcceptEntityInput(ent, "AddOutput");
							AcceptEntityInput(ent, "FireUser1");
							
							PrintToChat(victim, "룩 하나가 사라졋따");
							PlayerDamage[victim] = 0.0;
						}
					}
				}
			}
			else
			{
				PrintToChat(victim, "룩이 전부 사라져 받는 데미지 2배를 입습니다.");
				SetEntProp(victim, Prop_Data, "m_takedamage", 2, 1);
					
				damage *= 2.0;
				return Plugin_Changed;
			}
		}
	}
	
	return Plugin_Continue;
}

stock int FindPlayerWearable(int client)
{
	int iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "tf_wearable")) != -1) 
	{
		if(GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client)
		{
			return iEnt;
		}
	}
	
	return iEnt;
}

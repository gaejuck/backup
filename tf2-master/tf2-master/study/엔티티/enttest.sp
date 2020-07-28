#include <sourcemod>
#include <sdktools>
#include <tf2items>
#include <tf2>
#include <tf2_stocks>
#include <tf2itemsinfo>

public OnPluginStart()
{
	RegConsoleCmd("sm_jump", jump);
	RegConsoleCmd("sm_fo", follow);
	RegConsoleCmd("sm_ent", ent);
}

public Action:ent(client, args)
{
	new Float:flPos[3], Float:flAng[3];
	GetClientEyePosition(client, flPos);
	GetClientEyeAngles(client, flAng);
	new Handle:hTrace = TR_TraceRayFilterEx(flPos, flAng, MASK_SHOT, RayType_Infinite, TraceFilterIgnorePlayers, client);
	if(hTrace != INVALID_HANDLE && TR_DidHit(hTrace)) 
	{
		decl Float:flEndPos[3];
		TR_GetEndPosition(flEndPos, hTrace);
		flEndPos[2] += 5.0;
		decl Float:absOri[3];
		GetClientAbsOrigin(client, absOri);
		CloseHandle(hTrace);
		
		// new iEnt = CreateEntityByName("tf_zombie");
		new iEnt = CreateEntityByName("tf_projectile_rocket");
		if(IsValidEntity(iEnt))
		{
			DispatchSpawn(iEnt);
			PrecacheModel("models/weapons/w_models/tw_rocket.mdl", true);
			SetEntityModel(iEnt, "models/weapons/w_models/tw_rocket.mdl");
			
			// for(new i = 1; i <= MaxClients; i++)
			// {
				// if(IsClientInGame(i))
				// {
					// new Float:vEPosit[3], Float:Dist;
					// GetClientAbsOrigin(i, vEPosit);
					// Dist = GetVectorDistance(flEndPos, vEPosit);
					// if(Dist <= 100.0)
						// SetEntPropEnt(iEnt, Prop_Data, "m_target", i);
					// else
					// {
						// if(GetClientTeam(i) == 2)
						// {
							// SetEntPropEnt(iEnt, Prop_Data, "m_target", i);
						// }
					// }
				// }
			// } 
				// SetEntProp(iEnt, Prop_Data, "m_target", client);
				
			TeleportEntity(iEnt, absOri, NULL_VECTOR, NULL_VECTOR);
		}
	}
	return Plugin_Handled;
}

public bool:TraceFilterIgnorePlayers(entity, contentsMask, any:client)
{
	if(entity >= 1 && entity <= MaxClients) return false;
	return true;
}

public Action:jump(client, args)
{
	new Float:Angle[3], Float:AngleVec[3], Float:pos[3], Float:vec[3];

	GetClientEyeAngles(client, Angle);
	GetAngleVectors(Angle, AngleVec, NULL_VECTOR, NULL_VECTOR);
	GetClientEyePosition(client, pos);

	pos[0]+=AngleVec[0]*70.0;
	pos[1]+=AngleVec[1]*50.0;

	GetEntPropVector(client, Prop_Send, "m_vecOrigin", AngleVec);

	SubtractVectors(pos, AngleVec, vec);
	ScaleVector(vec, 10.0);

	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vec);
	
	// decl Float:vOrigin[3], Float:vAngles[3],Float:Fwd[3],Float:result[3];
	// GetClientEyePosition(client, vOrigin); //눈깔위치구하기
	// GetClientEyeAngles(client,vAngles);//눈깔각도구하기
	// GetAngleVectors(vAngles,Fwd,NULL_VECTOR,NULL_VECTOR); // 앵글각도를잡아준뒤 앞쪽으로갑니다잉
	// NormalizeVector(Fwd,Fwd); // 값을 노말화시킵니다.
	// ScaleVector(Fwd, 300.0); //노말화시킨값에 값을넣습니다.
	// Fwd[2] += 180.0;

	// TeleportEntity(client, result, NULL_VECTOR, Fwd);

	return Plugin_Handled;
}

public Action:follow(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(AliveCheck(i))
		{
			if(GetClientTeam(client) != GetClientTeam(i))
			{
				decl Float:vOrigin[3], Float:vOrigin2[3], Float:vVector[3];
				GetClientEyePosition(client, vOrigin);
				GetClientEyePosition(i, vOrigin2);
				MakeVectorFromPoints(vOrigin, vOrigin2, vVector);
				  
				NormalizeVector(vVector, vVector);
				ScaleVector(vVector, -1000.0);
				
				vVector[2] += 300.0;
				  
				TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, vVector);
			}
		}
	}
	return Plugin_Handled;
}
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

stock bool:PlayerCheck(Client){
	if(Client > 0 && Client <= MaxClients){
		if(IsClientConnected(Client) == true){
			if(IsClientInGame(Client) == true){
				return true;
			}
		}
	}
	return false;
}


stock SpawnWeapon(client,String:name[],slot,index,level,qual,String:att[], TFClassType:classbased = TFClass_Unknown)
{
	new Flags = OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL | OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES;
	
	new Handle:newItem = TF2Items_CreateItem(OVERRIDE_ALL);
	
	if (newItem == INVALID_HANDLE)
		return -1;
	
	if (strcmp(name, "saxxy", false) != 0) Flags |= FORCE_GENERATION;
	
	if (StrEqual(name, "tf_weapon_shotgun", false)) strcopy(name, 64, "tf_weapon_shotgun_soldier");
	if (strcmp(name, "tf_weapon_shotgun_hwg", false) == 0 || strcmp(name, "tf_weapon_shotgun_pyro", false) == 0 || strcmp(name, "tf_weapon_shotgun_soldier", false) == 0)
	{
		switch (classbased)
		{
			case TFClass_Heavy: strcopy(name, 64, "tf_weapon_shotgun_hwg");
			case TFClass_Soldier: strcopy(name, 64, "tf_weapon_shotgun_soldier");
			case TFClass_Pyro: strcopy(name, 64, "tf_weapon_shotgun_pyro");
		}
	}
	
	TF2Items_SetClassname(newItem, name);
	TF2Items_SetItemIndex(newItem, index);
	TF2Items_SetLevel(newItem, level);
	TF2Items_SetQuality(newItem, qual);
	TF2Items_SetFlags(newItem, Flags);
	
	new String:atts[32][32]; 
	new count = ExplodeString(att, " ; ", atts, 32, 32);
	
	if (count > 1)
	{
		TF2Items_SetNumAttributes(newItem, count/2);
		new i2 = 0;
		for (new i = 0;  i < count;  i+= 2)
		{
			TF2Items_SetAttribute(newItem, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
		TF2Items_SetNumAttributes(newItem, 0);
		
	TF2_RemoveWeaponSlot(client, slot);
	new entity = TF2Items_GiveNamedItem(client, newItem);
	
	EquipPlayerWeapon(client, entity);

	CloneHandle(newItem);
	return entity;
}
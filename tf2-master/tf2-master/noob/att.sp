#include <sdkhooks> 
#include <tf2items>
#include <tf2attributes>
#include <tf2_stocks>
#include <tf2>
 
new Handle:mod = INVALID_HANDLE;
new bool:regen[MAXPLAYERS+1] = false;

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnClientDisconnected(client)
	if(regen[client] == true)
		regen[client] = false;

public OnPluginStart()
{
	mod = CreateConVar("sm_mod_enabled", "1", "1 = Rocket Jump mod, 2 = bow mod, 3 = pipe mod, 4 = rocket mod");
	
	RegAdminCmd("sm_rj", aaaa, ADMFLAG_KICK);
	RegAdminCmd("sm_regen", RegenCommand, 0);
	
	HookEvent("player_spawn", PlayerSpawn);
}

public Action:RegenCommand(client, args)
{
	if(GetConVarInt(mod) == 1)
	{
		if(regen[client] == false)
		{
			PrintToChat(client, "\x03리젠 적용 완료");
			regen[client] = true;
			CreateTimer(3.0, RegenTimer, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			PrintToChat(client, "\x03리젠 적용 해제");
			regen[client] = false;
		}
	}
	else
		PrintToChat(client, "\x03로켓 점프 모드가 적용중이지 않습니다.");
}

public Action:aaaa(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(AliveCheck(i))
		{
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			PrintToChat(i, "ok");
		}
	}
	return Plugin_Handled;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(GetConVarInt(mod) == 1 || GetConVarInt(mod) == 2 || GetConVarInt(mod) == 4)
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_DemoMan)
			buttons &= ~IN_ATTACK2;
	return Plugin_Continue;

}

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	if(GetConVarInt(mod) == 1)
	{
		if(StrEqual(classname, "tf_wearable_demoshield") || StrEqual(classname, "tf_weapon_cannon")
		|| StrEqual(classname, "tf_weapon_pistol") || StrEqual(classname, "tf_weapon_minigun")
		|| StrEqual(classname, "tf_weapon_shotgun_building_rescue") || StrEqual(classname, "tf_weapon_mechanical_arm")
		|| StrEqual(classname, "tf_weapon_syringegun_medic") || StrEqual(classname, "tf_weapon_smg")
		|| StrEqual(classname, "tf_weapon_flamethrower") || StrEqual(classname, "tf_weapon_handgun_scout_secondary")
		|| StrEqual(classname, "tf_weapon_charged_smg"))
		{
			return Plugin_Handled;
		}
		TF2Attrib_RemoveByDefIndex(client, 280);
		TF2Attrib_SetByDefIndex(client, 280, 2.0);
	}
	else if(GetConVarInt(mod) == 2)
	{
		if (StrEqual(classname, "tf_wearable_demoshield") || StrEqual(classname, "tf_weapon_cannon"))
		// || iItemDefinitionIndex == 1150)
			return Plugin_Handled;
		TF2Attrib_RemoveByDefIndex(client, 280);
		TF2Attrib_SetByDefIndex(client, 280, 19.0);
	}
	else if(GetConVarInt(mod) == 3)
	{
		if (StrEqual(classname, "tf_wearable_demoshield") || StrEqual(classname, "tf_weapon_cannon"))
			return Plugin_Handled;
		TF2Attrib_RemoveByDefIndex(client, 280);
		TF2Attrib_SetByDefIndex(client, 280, 3.0);
	}
	else if(GetConVarInt(mod) == 4)
	{
		if (StrEqual(classname, "tf_weapon_pistol") || StrEqual(classname, "tf_weapon_handgun_scout_secondary"))
			return Plugin_Handled;
		TF2Attrib_RemoveByDefIndex(client, 280);
		TF2Attrib_SetByDefIndex(client, 280, 2.0);
	}
	else
	{
		TF2Attrib_RemoveByDefIndex(client, 280);
	}
	
	return Plugin_Continue;
}

public Action:OnTakeDamage(iVictim, &attacker, &inflictor, &Float:flDamage, &damagetype)
{
	if(iVictim == attacker)
	{
		if(GetConVarInt(mod) > 0)
		{
			TF2_AddCondition(iVictim, TFCond:14, 0.001);
		}
	}

	if(AliveCheck(attacker) && AliveCheck(iVictim))
	{
		decl String:ClientDamage[64];
		decl String:AttackDamge[64];
		
		GetClientWeapon(iVictim, ClientDamage, sizeof(ClientDamage));
		GetClientWeapon(attacker, AttackDamge, sizeof(AttackDamge));
		
		if(GetConVarInt(mod) == 1)
		{		
			if(!StrEqual(ClientDamage, "tf_weapon_rocketlauncher"))
			{
				flDamage = GetRandomFloat(48.0, 51.0);
				return Plugin_Changed;
			}
		}
		
		else if(GetConVarInt(mod) == 2)
		{
			GetClientWeapon(attacker, AttackDamge, sizeof(AttackDamge));
			if(StrEqual(AttackDamge, "tf_weapon_grenadelauncher") || StrEqual(AttackDamge, "tf_weapon_pipebomblauncher"))
			{
				flDamage = GetRandomFloat(98.0, 102.0);
				return Plugin_Changed;
			}
		}
		
		else if(GetConVarInt(mod) == 3)
		{
			GetClientWeapon(attacker, AttackDamge, sizeof(AttackDamge));
			if(StrEqual(AttackDamge, "tf_weapon_grenadelauncher") || StrEqual(AttackDamge, "tf_weapon_pipebomblauncher"))
			{
				flDamage = GetRandomFloat(100.0, 105.0);
				return Plugin_Changed;
			}
		}
		
		else if(GetConVarInt(mod) == 4)
		{		
			if(StrEqual(ClientDamage, "tf_weapon_scattergun"))
			{
				flDamage = GetRandomFloat(48.0, 51.0);
				return Plugin_Changed;
			}
			
			else if(StrEqual(AttackDamge, "tf_weapon_scattergun"))
			{
				flDamage = GetRandomFloat(10.0, 15.0);
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(GetConVarInt(mod) == 2 || GetConVarInt(mod) == 3)
	{
		TF2_SetPlayerClass(client, TFClass_DemoMan);
		TF2_RegeneratePlayer(client);
	}
	if(GetConVarInt(mod) == 4)
	{
		TF2_SetPlayerClass(client, TFClass_Scout);
		TF2_RegeneratePlayer(client);
	}
}

public Action:RegenTimer(Handle:timer, any:client)
{
	if(GetConVarInt(mod) == 1)
	{
		if(AliveCheck(client))
		{
			TF2_RegeneratePlayer(client);
		}
	}
	else
	{
		CloseHandle(timer);
		return Plugin_Stop;
	}
	return Plugin_Continue;
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
#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

new bool:Enabled[MAXPLAYERS+1];
new bool:Soolle[MAXPLAYERS+1];
new g_delay[MAXPLAYERS+1];
// new g_time[MAXPLAYERS+1];

new FogIndex = -1;

new Float:mapFogStart = 0.0;
new Float:mapFogEnd = 150.0;
new Float:mapFogDensity = 0.99;

new count;

new offset_ammo;
new offset_clip;

public OnPluginStart()
{
	RegAdminCmd("sm_catch", SolleCommand, ADMFLAG_RESERVATION);
	
	HookEvent("player_spawn", Player_Spawn);
	HookEvent("player_death", Player_Death);
	HookEvent("post_inventory_application", OnPlayerInventory, EventHookMode_Post);
	
	offset_ammo = FindSendPropInfo("CBasePlayer", "m_iAmmo");
	offset_clip = FindSendPropInfo("CBaseCombatWeapon", "m_iClip1");
}

public OnClientPutInServer(client) 
{
	Enabled[client] = false;
	Soolle[client] = false;
	g_delay[client] = 0;
}
 
public OnMapStart()
{
    new ent; 
    ent = FindEntityByClassname(-1, "env_fog_controller");
    if (ent != -1) 
    {
        FogIndex = ent;
    }
    else
    {
        FogIndex = CreateEntityByName("env_fog_controller");
        DispatchSpawn(FogIndex);
    }
    DoFog();
    AcceptEntityInput(FogIndex, "TurnOff");
}

public Action:SolleCommand(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(AliveCheck(i))
		{
			g_delay[i] = 6;
			// g_time[i] = 300;
			PrintToChat(i, "\x07FFFFFF술래잡기 모드가 시작되었습니다.");
			PrintToChat(i, "\x07FFFFFF5초 후에 술래를 고릅니다.");
			CreateTimer(1.0, Timer_Delay, i, TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(9.0, Timer_Alive, i, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	count = 0;
	CreateTimer(7.0, Timer_soole, client, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
} 

public Action:Player_Spawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(Enabled[client])
	{
		if(GetClientTeam(client) == 3)
		{
			if(TF2_GetPlayerClass(client) != TFClassType:TFClass_Pyro)
			{
				TF2_SetPlayerClass(client, TFClass_Pyro);
				TF2_RegeneratePlayer(client);
			}
			ServerCommand("sm_beacon #%i", GetClientUserId(client)); 
			SetEntProp(client, Prop_Data, "m_takedamage", 1, 1);
		}
		else
		{
			if(TF2_GetPlayerClass(client) != TFClassType:TFClass_Scout)
			{
				TF2_SetPlayerClass(client, TFClass_Scout);
				TF2_RegeneratePlayer(client);
			}
			count++;
		}
	}
	else SetEntProp(client, Prop_Data, "m_takedamage", 2, 1);
}

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(PlayerCheck(client) && Enabled[client])
	{
		ChangeClientTeam(client, 1);
		PrintToChat(client, "\x07FFFFFF관전으로 이동합니다.");
		count--;
	}
}

public Action:OnPlayerInventory(Handle:hEvent, String:strEventName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (!AliveCheck(client)) return;
	if (!Enabled[client]) return;
    
	if(GetClientTeam(client) == 3)
	{
		TF2_RemoveWeaponSlot(client, 1);
		TF2_RemoveWeaponSlot(client, 2);
	}
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if(IsValidEntity(weapon) && AliveCheck(client) && Enabled[client])
	{
		if(GetClientTeam(client) == 3 && TF2_GetPlayerClass(client) == TFClassType:TFClass_Pyro)
		{
			new ammotype = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType")*4;
			SetEntData(weapon, offset_clip, 99, 4, true);
			SetEntData(client, ammotype+offset_ammo, 99, 4, true);
		}
	}
}
//-------------------------------- 시작 카운트 --------------------------------//

public Action:Timer_Delay(Handle:timer, any:client)
{
	g_delay[client]--;
	if (g_delay[client])
	{
		if(g_delay[client] != 1)
		{
			SetHudTextParams(-1.0, -1.0, 1.0, 0, 255, 0, 200);
			ShowHudText(client, -1, "%i초 !", g_delay[client]);
			CreateTimer(1.0, Timer_Delay, client, TIMER_FLAG_NO_MAPCHANGE);
		}
		else
		{
			SetHudTextParams(-1.0, -1.0, 1.0, 0, 255, 0, 200);
			ShowHudText(client, -1, "%i초 !", g_delay[client]);
			CreateTimer(1.0, Timer_Delay, client, TIMER_FLAG_NO_MAPCHANGE);
			return Plugin_Stop;
		}
	}

	return Plugin_Handled;
}

//-------------------------------- 술래 고름 --------------------------------//

public Action:Timer_soole(Handle:timer, any:client)
{
	new user = GetRandomSoolle();
	PrintToChatAll("%N님 술래!!", user);
	Soolle[user] = true;
	CreateTimer(1.0, Timer_TeamChange, client, TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Handled;
}

//-------------------------------- 팀 이동 & fog 생성 --------------------------------//

public Action:Timer_TeamChange(Handle:timer, any:client)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(AliveCheck(i))
		{	
			if(Soolle[i]) ChangeClientTeam(i, 3);
			else ChangeClientTeam(i, 2);
			
			Enabled[i] = true;
			TF2_RespawnPlayer(i);
		}
	}
	AcceptEntityInput(FogIndex, "TurnOn");
}

//-------------------------------- 생존자 & 모드 승리 --------------------------------//

public Action:Timer_Alive(Handle:timer, any:client)
{
	if(Enabled[client])
	{
		if(count == 0) 
		{
			PrintToChat(client, "\x07FFFFFF술래잡기 모드가 끝났습니다.");
			AcceptEntityInput(FogIndex, "TurnOff");   			
			Enabled[client] = false;
			
			if(GetClientTeam(client) == 3)
			{
				ServerCommand("sm_beacon #%i", GetClientUserId(client)); 
			}
			
			TF2_RegeneratePlayer(client);
			TF2_RespawnPlayer(client);
			return Plugin_Stop;
		}
		else
		{
			SetHudTextParams(0.05, 0.15, 1.0, 0, 255, 234, 255);
			ShowHudText(client, -1, "생존자 수 : %d", count);
			CreateTimer(1.0, Timer_Alive, client, TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Handled;
}

// public Action:Game_Time(Handle:timer, any:client)
// {
	// g_delay[client]--;
	// if (g_delay[client] && Enabled[client])
	// {
			// SetHudTextParams(-1.0, -1.0, 1.0, 0, 255, 0, 200);
			// ShowHudText(client, -1, "%i초 !", g_delay[client]);
			// CreateTimer(1.0, Timer_Delay, client, TIMER_FLAG_NO_MAPCHANGE);
		// }
	// }
	
	// 300/6 = 5
	// 4분 30초

	// return Plugin_Handled;
// }

stock GetRandomSoolle() 
{ 
	new iTerList[MAXPLAYERS]; 
	new iTerCount; 
	
	for (new i = 1; i <= MaxClients; i++) 
	{ 
		if (!AliveCheck(i)) 
			continue; 
			
		if (IsFakeClient(i)) 
			continue; 
			
		if (GetClientTeam(i) == 1) 
			continue; 
			
		iTerList[iTerCount] = i; 
		iTerCount++; 
	}  

	if (iTerCount == 0) 
		return -1; 
		
	new iRandomIndex = GetRandomInt(0, iTerCount-1); 
	return iTerList[iRandomIndex]; 
}

stock DoFog()
{
    if(FogIndex != -1) 
    {
        DispatchKeyValue(FogIndex, "fogblend", "0");
        DispatchKeyValue(FogIndex, "fogcolor", "0 0 0");
        DispatchKeyValue(FogIndex, "fogcolor2", "0 0 0");
        DispatchKeyValueFloat(FogIndex, "fogstart", mapFogStart);
        DispatchKeyValueFloat(FogIndex, "fogend", mapFogEnd);
        DispatchKeyValueFloat(FogIndex, "fogmaxdensity", mapFogDensity);
    }
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

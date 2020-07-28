#include <sdktools>
#include <sdkhooks>
#include <tf2items>
#include <tf2itemsinfo>

new bool:DuelCheck[MAXPLAYERS+1];
new duel[MAXPLAYERS+1];
new point[MAXPLAYERS+1]

public OnPluginStart()
{
	RegConsoleCmd("sm_duel", Duel);
	RegConsoleCmd("sm_duel2", Duel2);
	
	HookEvent("player_death", player_death);
}

public OnMapStart()
{
	PrecacheSound("ui/duel_challenge.wav");
	PrecacheSound("ui/duel_challenge_accepted.wav");
	PrecacheSound("ui/duel_challenge_rejected.wav");
}

public Action:player_death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(PlayerCheck(client) && PlayerCheck(attacker) && (client != attacker))
	{
		if(duel[client])
			if(point[client] <= 2 || point[duel[client]] <= 2)
				point[client]++;
				
		else if(duel[duel[client]])
			if(point[client] <= 2 || point[duel[client]] <= 2)
				point[duel[client]]++;
		
		// if(duel[client] && point[client] <= 2)
			// point[client]++;
		// else if(duel[duel[client]] && point[duel[client]] <= 2)
			// point[duel[client]]++;
		else
		{
			point[client] = 0;
			point[duel[client]] = 0;
			
			duel[duel[client]] = 0;
			duel[client] = 0;
			
			DuelCheck[client] = false;
			DuelCheck[duel[client]] = false;
		}
	}
	PrintToChatAll("%N %d : %N %d", duel[client], point[client], duel[duel[client]], point[duel[client]]);
}

public Action:Duel2(client, args)
{
	decl String:arg[65];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM]\x03!db <name>");
		return Plugin_Handled;
	}
		
	GetCmdArg(1, arg, sizeof(arg));
		
	HasTarget = true;	
	
	decl String:target_name[MAX_TARGET_LENGTH];
	
	new bot;
	
	if (HasTarget)
	{
		decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
		
		if ((target_count = ProcessTargetString(
				arg,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_CONNECTED,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
		{
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}
	
		for (new i = 0; i < target_count; i++)
		{
			new target = GetClientSerial(target_list[i]);
			bot = GetClientFromSerial(target); 
			duel[bot] = client;
			duel[client] = bot;
		}
	}
	
	DuelCheck[duel[bot]] = true;
	DuelCheck[duel[client]] = true;
	
	PrintToChatAll("%N님이 %N님과의 결투에 동의 하셨습니다", duel[bot], duel[client]);
	
	return Plugin_Handled;
}

public Action:Duel(client, args)
{
	new Handle:menu = CreateMenu(PlayerList);
	SetMenuTitle(menu, "유저 목록");
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			decl String:user[24], String:strName[256];
			Format(user, sizeof(user), "%d", GetClientSerial(i));
			
			if(DuelCheck[i])
			{
				if(client != i)
				{
					Format(strName, sizeof(strName), "%N [듀얼 중]", i);
					AddMenuItem(menu, user, strName);
				}
			}
			else
			{
				if(client != i)
				{
					Format(strName, sizeof(strName), "%N", i);
					AddMenuItem(menu, user, strName);  
				}
			}
		}
	}
	SetMenuExitButton(menu, true);

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public PlayerList(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
		decl String:info[64];
		GetMenuItem(menu, select, info, sizeof(info));
		
		new iInfo = StringToInt(info); 
		new iTarget = GetClientFromSerial(iInfo); 
		
		new Handle:menu2 = CreateMenu(DuelMenu);
		SetMenuTitle(menu2, "%N님이 듀얼을 신청 했습니다.", client);
		
		AddMenuItem(menu2, "좋아", "좋아");  
		AddMenuItem(menu2, "싫어", "싫어"); 

		SetMenuExitButton(menu2, true);		
		DisplayMenu(menu2, iTarget, MENU_TIME_FOREVER);
		
		duel[iTarget] = client;
		
		EmitSoundToClient(iTarget, "ui/duel_challenge.wav");
		
		
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public DuelMenu(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
		decl String:info[64];
		GetMenuItem(menu, select, info, sizeof(info));
		
		if(StrEqual(info, "좋아"))
		{
			PrintToChatAll("%N님이 %N님과의 결투에 동의 하셨습니다", client, duel[client]);
			EmitSoundToClient(client, "ui/duel_challenge_accepted.wav");
			EmitSoundToClient(duel[client], "ui/duel_challenge_accepted.wav");
			
			// CardSpawn(client);
			// CardSpawn(duel[client]);
			
			DuelCheck[client] = true;
			DuelCheck[duel[client]] = true;
			
			duel[duel[client]] = client;
			
			PrintToChatAll("%N VS %N", duel[client], duel[duel[client]]);
		}
		else
		{
			PrintToChatAll("%N님이 %N님과의 결투에 동의 하지 않았습니다.", client, duel[client]);
			EmitSoundToClient(client, "ui/duel_challenge_rejected.wav");
			EmitSoundToClient(duel[client], "ui/duel_challenge_rejected.wav");
		}
	}
	if(action == MenuAction_Cancel)
	{
		PrintToChatAll("%N님이 %N님과의 결투에 동의 하지 않았습니다.", client, duel[client]);
	}
}

// public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
// {
	// for(new i = 1; i <= MaxClients; i++)
	// {
		// if(IsClientInGame(i))
		// {
			// if(AliveCheck(duel[client]) && DuelCheck[client] == true && DuelCheck[i] == true && duel[client] == i)
			// {
				// new Float:flStartPos[3], Float:flEyeAng[3], Float:flHitPos[3];
				// GetClientEyePosition(client, flStartPos);
				// GetClientEyeAngles(client, flEyeAng);
				
				// new Handle:hTrace = TR_TraceRayFilterEx(flStartPos, flEyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer, client);
				// TR_GetEndPosition(flHitPos, hTrace);
				// new iHitEntity = TR_GetEntityIndex(hTrace);
				// CloseHandle(hTrace);
				
				// if(iHitEntity > 0)
				// {
					// decl String:szName[64];
					// GetEntPropString(iHitEntity, Prop_Data, "m_iName", szName, 16, 0);
					// if(StrEqual(szName, "prop"))
					// {
						// switch(GetRandomInt(0,1))
						// {
							// case 0:
							// {
								// PrintToChat(client, "방어");
							// }
							// case 1: 
							// {
								// PrintToChat(client, "공격");
								// ServerCommand("sm_slap #%i 100", GetClientUserId(duel[client]));
							// }
						// }
					// }
				// }
			// }
		// }
	// }
	// return Plugin_Continue;
// }
	//ServerCommand("sm_tauntem #%i %i", GetClientUserId(entity), 1118);
	
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

// public bool:TraceEntityFilterPlayer(entity, mask, any:data)
// {
	// if (entity == data) 
		// return false;
	
	// return true;
// }
	
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

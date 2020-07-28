#include <sdktools>
#include <sdkhooks>
#include <tf2items>
#include <tf2itemsinfo>

#define TIME 10.0

#define TEST "backpack/workshop/player/items/all_class/zoomin_broom/zoomin_broom_large"

new L;

new bool:DuelCheck[MAXPLAYERS+1];
new duel[MAXPLAYERS+1];

public OnPluginStart()
{
	RegConsoleCmd("sm_duel", Duel);
	RegConsoleCmd("sm_duel2", Duel2);

	// AddCommandListener(Taunt, "+taunt");
	// AddCommandListener(Taunt, "taunt");
	
	// AddCommandListener(Taunt, "+use_action_slot_item_server");
	// AddCommandListener(Taunt, "use_action_slot_item_server");
}

public OnMapStart()
{
	new String:VmtCode[256], String:VtfCode[256];
	Format(VmtCode, 256, "materials/%s.vmt", TEST);
	Format(VtfCode, 256, "materials/%s.vtf", TEST);
	
	L = PrecacheModel(VmtCode, true); 

	AddFileToDownloadsTable(VmtCode);
	AddFileToDownloadsTable(VtfCode);
	
	PrecacheModel(VmtCode, true);
	
	PrecacheSound("ui/duel_challenge.wav");
	PrecacheSound("ui/duel_challenge_accepted.wav");
	PrecacheSound("ui/duel_challenge_rejected.wav");
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
	
	CardSpawn(duel[bot]);
	CardSpawn(duel[client]);
	
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
			
			CardSpawn(client);
			CardSpawn(duel[client]);
			
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
		// EmitSoundToClient(client, "ui/duel_challenge_rejected.wav");
		// EmitSoundToClient(duel[client], "ui/duel_challenge_rejected.wav");
	}
}

stock CardSpawn(client)
{
	new Float:LeftPos[3];
	GetClientEyePosition(client, LeftPos);

	
	LeftPos[0] += 100.0; //옆
	LeftPos[1] -= 120.0; //뒤
	LeftPos[2] += 20.0; //위
	
	TE_SetupGlowSprite(LeftPos, L, TIME, 0.3, 255);
	TE_SendToAll();
	
	PropSpawn(client, LeftPos);
	
	new Float:RightPos[3];
	GetClientEyePosition(client, RightPos);
	
	RightPos[0] -= 150.0;
	RightPos[1] -= 100.0;
	RightPos[2] += 20.0;
	
	TE_SetupGlowSprite(RightPos, L, TIME, 0.3, 255);
	TE_SendToAll();
	
	PropSpawn(client, RightPos);
}

stock PropSpawn(client, const Float:pos[3])
{
	new iEnt =  CreateEntityByName("prop_dynamic_override");
	DispatchKeyValue(iEnt, "model", "models/props_medieval/medieval_door.mdl");
	DispatchSpawn(iEnt);
	 
	SetEntityRenderMode(iEnt,RENDER_GLOW)
	SetEntityRenderColor(iEnt, 255, 255, 255, 0)
	
	SetEntProp(iEnt, Prop_Send, "m_nSolidType", 6);
	
	DispatchKeyValue(iEnt, "targetname", "prop");
	TeleportEntity(iEnt, pos, NULL_VECTOR, NULL_VECTOR);
	
	CreateTimer(TIME, RemoveProp, iEnt);
	CreateTimer(TIME, ResetDuel, client);
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(AliveCheck(duel[client]) && DuelCheck[client] == true && DuelCheck[i] == true && duel[client] == i)
			{
				new Float:flStartPos[3], Float:flEyeAng[3], Float:flHitPos[3];
				GetClientEyePosition(client, flStartPos);
				GetClientEyeAngles(client, flEyeAng);
				
				new Handle:hTrace = TR_TraceRayFilterEx(flStartPos, flEyeAng, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer, client);
				TR_GetEndPosition(flHitPos, hTrace);
				new iHitEntity = TR_GetEntityIndex(hTrace);
				CloseHandle(hTrace);
				
				if(iHitEntity > 0)
				{
					decl String:szName[64];
					GetEntPropString(iHitEntity, Prop_Data, "m_iName", szName, 16, 0);
					if(StrEqual(szName, "prop"))
					{
						switch(GetRandomInt(0,1))
						{
							case 0:
							{
								PrintToChat(client, "방어");
							}
							case 1: 
							{
								PrintToChat(client, "공격");
								ServerCommand("sm_slap #%i 100", GetClientUserId(duel[client]));
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
	//ServerCommand("sm_tauntem #%i %i", GetClientUserId(entity), 1118);
public Action:RemoveProp(Handle:timer, any:entity)
	AcceptEntityInput(entity, "Kill");
	
public Action:ResetDuel(Handle:timer, any:client)
	DuelCheck[client] = false;

public bool:TraceEntityFilterPlayer(entity, mask, any:data)
{
	if (entity == data) 
		return false;
	
	return true;
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
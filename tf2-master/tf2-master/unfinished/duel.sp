#include <sdktools>

new bool:duelon[MAXPLAYERS+1] = false;
new bool:check[MAXPLAYERS+1] = false;

new CLTA[MAXPLAYERS+1];
new point[MAXPLAYERS+1];

new String:red_spawn[64], String:blu_spawn[64];
new String:strPath[PLATFORM_MAX_PATH];


public OnPluginStart()
{
	RegConsoleCmd("sm_duel", duel);
	RegConsoleCmd("sm_pos", pos);
	RegConsoleCmd("sm_duellist", duellist);
	
	HookEvent("player_death", Player_Death);
	HookEvent("player_spawn", PlayerSpawn);
}

public OnConfigsExecuted()
{
	decl String:strMapName[64]; GetCurrentMap(strMapName, sizeof(strMapName));
	decl String:strMapFile[PLATFORM_MAX_PATH]; Format(strMapFile, sizeof(strMapFile), "%s.cfg", strMapName);
	ConfigFile(strMapFile);
}

public OnClientDisconnected(client)
{
	CLTA[client] = 0;
	point[client] = 0;
	check[client] = false;
}

public Action:duel(client, args)
{
	DuelPlayerMenu(client);
	PrintToChat(client, "\x03%d", CLTA[client]);
	return Plugin_Handled;
}

public Action:pos(client, args)
{
	new Float:Position[3];
	GetClientAbsOrigin(client, Position);
	PrintToChat(client, "\x03X: %f\nY: %f\nZ: %f", Position[0], Position[1], Position[2]);
	return Plugin_Handled;
}

public Action:duellist(client, args)
{
	new Handle:info = CreateMenu(Menu_Information);
	SetMenuTitle(info, "듀얼 번호");
	for(new i = 1; i <= MaxClients; i++)
	{
		if(PlayerCheck(i))
		{
			if(duelon[i] == true)
			{
				if(CLTA[i])
				{
					decl String:aName[MAX_NAME_LENGTH];
					new String:temp[64];
					GetClientName(i, aName, sizeof(aName));
					
					Format(temp, sizeof(temp), "%s [%d]", aName, CLTA[i]);
					AddMenuItem(info, aName, temp);  
				}
			}
		}
	}
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Menu_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
		if(select == 0)
		{
			
		}
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	// for(new i = 1; i <= MaxClients; i++)
	// {
		// if(PlayerCheck(i))
		// {
			 // if(duelon[i] == true)
			 // {
				// teleportCLTA(client, attacker);
	
	// if(PlayerCheck(client) && (PlayerCheck(attacker)))
		// if(duelon[client])
			// teleportCLTA(client, attacker);
}

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(PlayerCheck(client) && (PlayerCheck(attacker)))
	{
		if(duelon[client] == true && duelon[attacker] == true)
		{
			if(client != attacker)
			{
				if(CLTA[client] == CLTA[attacker])
				{
					point[attacker]++;
					PrintToChat(attacker, "%d : %d", point[attacker], point[client]);
					PrintToChat(client, "%d : %d", point[attacker], point[client]);
				}
				
				if(point[client] == 3)
				{
					if(point[attacker] > 3)
					{
						PrintToChat(client, "듀얼이 끝났습니다.");
						PrintToChat(attacker, "듀얼이 끝났습니다.");
						
						PrintToChat(client, "%d : %d로 졌습니다.", point[attacker], point[client]);
						end(client); end(attacker);
					}
					else
					{
						PrintToChat(client, "%d : %d로 이겼습니다.", point[attacker], point[client]);
						end(client); end(attacker);
					}
				}
				
				
				if(point[attacker] == 3)
				{
					if(point[client] < 3)
					{
						
						PrintToChat(client, "듀얼이 끝났습니다.");
						PrintToChat(attacker, "듀얼이 끝났습니다.");
						
						PrintToChat(attacker, "%d : %d로 졌습니다.", point[attacker], point[client]);
						end(client); end(attacker);
					}
					else
					{
						PrintToChat(attacker, "%d : %d로 이겼습니다.", point[attacker], point[client]);
						end(client); end(attacker);
					}
				}
			}
		}
	}
}


public Action:DuelPlayerMenu(client)
{
	new Handle:menu = CreateMenu(DuelPlayerMenuSelect);
	decl String:PlayerName[MAX_NAME_LENGTH], String:user[32];
	
	SetMenuTitle(menu, "결투할 플레이어를 고르세요");
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(PlayerCheck(i))
		{
			Format(user, sizeof(user), "%d", GetClientSerial(i));
			
			if(GetClientTeam(client) == 2) 
			{
				if(GetClientTeam(i) == 3)
				{
					GetClientName(i, PlayerName, sizeof(PlayerName));
					AddMenuItem(menu, user, PlayerName);
				}
			}
			
			else if(GetClientTeam(client) == 3)
			{
				if(GetClientTeam(i) == 2)
				{
					GetClientName(i, PlayerName, sizeof(PlayerName));
					AddMenuItem(menu, user, PlayerName);
				}
			} 
		}
	}
	SetMenuExitButton(menu, true);

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
} 

public DuelPlayerMenuSelect(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
		decl String:Player[32];
		GetMenuItem(menu, select, Player, sizeof(Player));
			
		new info = StringToInt(Player); 
		new userid = GetClientFromSerial(info);
		
		
		if(PlayerCheck(userid))
		{
			DuelSelectPlayerMenu(client, userid);
		}
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


public Action:DuelSelectPlayerMenu(client, target)
{
	new Handle:menu = CreateMenu(DuelSelectPlayerMenuSelect), String:temp[256];
	
	decl String:targetName[MAX_NAME_LENGTH]; decl String:clientName[MAX_NAME_LENGTH];
	
	GetClientName(target, targetName, sizeof(targetName));
	GetClientName(client, clientName, sizeof(clientName));
	
	SetMenuTitle(menu, "%s님이 결투를 원합니다.", clientName);
		
	if(PlayerCheck(client))
		Format(temp, sizeof(temp), "%d", GetClientSerial(client));
	
	AddMenuItem(menu, temp, "결투");  
	AddMenuItem(menu, temp, "아니요");  
	SetMenuExitButton(menu, true);

	DisplayMenu(menu, target, MENU_TIME_FOREVER);
} 

public DuelSelectPlayerMenuSelect(Handle:menu, MenuAction:action, target, select)
{
	if(action == MenuAction_Select)
	{ 
		decl String:Player[32];
		GetMenuItem(menu, select, Player, sizeof(Player));
		
		new user = StringToInt(Player), iuser = GetClientFromSerial(user);
		
		decl String:userName[MAX_NAME_LENGTH], String:targetName[MAX_NAME_LENGTH];
		
		GetClientName(iuser, userName, sizeof(userName)); GetClientName(target, targetName, sizeof(targetName));
		
		if(select == 0)
		{
			CLTA[iuser]++;	CLTA[target]++;
			
			
			
			for(new i = 1; i <= MaxClients; i++)
			{
				if(CLTA[iuser] == CLTA[target]) //내 번호와 상대방 번호가 같으며
				{
					if(CLTA[iuser] != CLTA[i] &&  CLTA[target] != CLTA[i]) //다른 사람들과 번호가 다르다면
					{
						duelon[iuser] = true; duelon[target] = true; //듀얼 온 한다.
					}
					else //내 번호와 상대방 번호가 같고 다른 사람들과도 번호가 같다면
					{
						check[iuser] = true; check[target] = true; //체크 함수를 사용한다.
						duelon[iuser] = false; duelon[target] = false;
					}
				}
			}
			
			if(check[iuser] == true && check[target] == true)
			{
				CLTA[iuser] = 0;	CLTA[target] = 0;
				CLTA[iuser]++;	CLTA[target]++;
				check[iuser] = false; check[target] = false;
			}
			
			if(duelon[iuser] == true && duelon[target] == true) //온 했을 경우
			{
				PrintToChat(iuser, "\x04%d", CLTA[iuser]);
				PrintToChat(target, "\x04%d", CLTA[target]);
					
				PrintToChat(iuser, "%s님이 결투에 승낙하였습니다.", targetName);
				PrintToChat(target, "%s님이 결투에 승낙하였습니다.", targetName);
				
				teleportCLTA(iuser, target);
			}
		} 
		else
		{
			PrintToChat(iuser, "%s님이 결투에 거절하였습니다.", targetName);
			end(iuser); end(target);
		}
	}
	
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}


stock teleportCLTA(iuser, target)
{
	new String:red_array[3][32], String:blu_array[3][32];
	new Float:red_pos[3], Float:blu_pos[3];
	
	ExplodeString(red_spawn, " ", red_array, 3, 32);
	ExplodeString(blu_spawn, " ", blu_array, 3, 32);
				
	red_pos[0]	= StringToFloat(red_array[0]);
	red_pos[1]	= StringToFloat(red_array[1]);
	red_pos[2]	= StringToFloat(red_array[2]);
				
	blu_pos[0]	= StringToFloat(blu_array[0]);
	blu_pos[1]	= StringToFloat(blu_array[1]);
	blu_pos[2]	= StringToFloat(blu_array[2]);
				
	if(GetClientTeam(iuser) == 2)
	{
		TeleportEntity(iuser, red_pos, NULL_VECTOR, NULL_VECTOR);
	}
	else if(GetClientTeam(iuser) == 3)
	{
		TeleportEntity(iuser, blu_pos, NULL_VECTOR, NULL_VECTOR);
	}
				
	if(GetClientTeam(target) == 2)
	{
		TeleportEntity(target, red_pos, NULL_VECTOR, NULL_VECTOR);
	}
				
	else if(GetClientTeam(target) == 3)
	{
		TeleportEntity(target, blu_pos, NULL_VECTOR, NULL_VECTOR);
	}
} 

// public Action:DuelOptions(client)
// {
	// new Handle:info = CreateMenu(OptionsSelect);
	// SetMenuTitle(info, "옵션");
	// AddMenuItem(info, "1", "클래스 선택");  
	// SetMenuExitButton(info, true);

	// DisplayMenu(info, client, MENU_TIME_FOREVER);
// } 

// public OptionsSelect(Handle:menu, MenuAction:action, client, select)
// {
	// if(action == MenuAction_Select)
	// { 
		// if(select == 0)
		// {
			// CloseHandle(menu);
		// }
	// }
	// if(action == MenuAction_End)
	// {
		// CloseHandle(menu);
	// }
// }

// public Action:DuelClass(client)
// {
	// new Handle:info = CreateMenu(ClassSelect);
	// SetMenuTitle(info, "클래스");
	// AddMenuItem(info, "scout", "스카웃");  
	// AddMenuItem(info, "soldier", "솔저");  
	// AddMenuItem(info, "pyro", "파이로");  
	// AddMenuItem(info, "De", "데모맨");  
	// AddMenuItem(info, "he", "헤비");  
	// AddMenuItem(info, "en", "엔지니어");  
	// AddMenuItem(info, "me", "메딕");  
	// AddMenuItem(info, "sn", "스나이퍼");  
	// AddMenuItem(info, "spy", "스파이");  
	// SetMenuExitButton(info, true);

	// DisplayMenu(info, client, MENU_TIME_FOREVER);
// } 

// public ClassSelect(Handle:menu, MenuAction:action, client, select)
// {
	// if(action == MenuAction_Select)
	// { 
		// if(select == 0)
		// {
			// CloseHandle(menu);
		// }
	// }
	// if(action == MenuAction_End)
	// {
		// CloseHandle(menu);
	// }
// }

public bool:ConfigFile(String:file[])
{
    // Parse configuration
	decl String:strFileName[PLATFORM_MAX_PATH];
	// decl String:serverName[PLATFORM_MAX_PATH];
	Format(strFileName, sizeof(strFileName), "configs/duel/%s", file);
	BuildPath(Path_SM, strPath, sizeof(strPath), strFileName);
	
	
       
	// Try to parse if it exists
	LogMessage("%s 파일이 정상적으로 로드 되었습니다.", strPath);    
	if (FileExists(strPath, true))
	{
		new Handle:kvConfig = CreateKeyValues("duel");
		if (FileToKeyValues(kvConfig, strPath) == false) SetFailState("파일에 문제가 있습니다.");
		if(KvGotoFirstSubKey(kvConfig))
		{
			KvGetString(kvConfig, "red_spawn", red_spawn, sizeof(red_spawn));
			KvGetString(kvConfig, "blu_spawn", blu_spawn, sizeof(blu_spawn));
		}
		CloseHandle(kvConfig);
	}
}

stock end(client)
{
	duelon[client] = false;
	CLTA[client] = 0;
	point[client] = 0;
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
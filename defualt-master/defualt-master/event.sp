#include <sourcemod>

new bool:admin_event[MAXPLAYERS+1] = false;
new bool:event[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "Event Plugin",
	author = "TAKE 2",
	description = "이베에에ㅔ에엔트",
	version = "3.0",
	url = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
}


public OnPluginStart()   
{
	RegConsoleCmd("sm_ev", User_event, "이벤트 참여를 위한 명령어"); 
	RegAdminCmd("sm_evo", Event_ONOFF, ADMFLAG_KICK, "이벤트 시작 or 끝날때 반드시 해야할 명령어");
	RegAdminCmd("sm_evlist", Event_list, ADMFLAG_KICK, "이벤트 유저의 목록을 보는 명령어");
	
	AddMultiTargetFilter("@event", Event_Filter, "All event user", false);
}

public OnClientDisconnect(client)
	if(event[client] == true)
		event[client] = false;

public bool:Event_Filter(const String:pattern[], Handle:clients)
{
	for (new i = 1; i <= MaxClients; i++)
		if(PlayerCheck(i) && IsClientevent(i))
			PushArrayCell(clients, i)
	return true;
}

public Action:Event_ONOFF(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(PlayerCheck(i))
		{
			if(admin_event[i] == false)
			{
				PrintToChat(i, "\x03이벤트가 시작되었습니다. 참여하실 분은 !ev를 치세요.");
				admin_event[i] = true;
			}
			else
			{
				PrintToChat(i, "\x03이벤트가 끝났습니다.");
				admin_event[i] = false;
				event[i] = false;
			}
		}
	}
	return Plugin_Handled;
}

public Action:User_event(client, args)
{
	if(PlayerCheck(client))
	{
		if(admin_event[client] == true)
		{
			if(event[client] == false)
			{
				PrintToChat(client, "\x03적용이 되었습니다.");
				event[client] = true;
			} 
			else
			{
				PrintToChat(client, "\x03이미 이벤트에 참여하셨습니다.");
			}
		}
		else
		{
			PrintToChat(client, "\x03이벤트가 진행 중이지 않습니다.");
		}
	}
	return Plugin_Handled;
}


public Action:Event_list(client, args)
{
	// new Handle:menu = CreateMenu(list_menu);
	new Handle:menu = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Valve), list_menu); 
	
	decl String:user_id[24], String:name[MAX_NAME_LENGTH], String:display[MAX_NAME_LENGTH+12];
	
	SetMenuTitle(menu, "이벤트에 참여한 유저 목록");
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			if(event[i] == true)
			{
				Format(user_id, sizeof(user_id), "%d", GetClientSerial(i));
				GetClientName(i, name, sizeof(name));
				Format(display, sizeof(display), "%s", name);
				AddMenuItem(menu, user_id, display);
			}
		}
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public list_menu(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if(action == MenuAction_Select)
	{
		decl String:info[32];
		decl String:User_Name[MAX_NAME_LENGTH];
		GetMenuItem(menu, select, info, sizeof(info));
     
		new iInfo = StringToInt(info); 
		new iUserid = GetClientFromSerial(iInfo); 
		
		GetClientName(iUserid, User_Name, sizeof(User_Name));
		
		remove_es_user(client, iUserid, User_Name); 
	}
}


public Action:remove_es_user(client, target, String:name[])
{
	// new Handle:info = CreateMenu(remove_es_user_menu);
	new Handle:info = CreateMenuEx(GetMenuStyleHandle(MenuStyle_Valve), remove_es_user_menu); 
	
	decl String:User_Name[MAX_NAME_LENGTH]; new String:temp[14];
	
	SetMenuTitle(info, "%s 유저를 이벤트에서 제외 하시겠습니까?", name);
	
	GetClientName(target, User_Name, sizeof(User_Name));
	Format(temp, sizeof(temp), "%d;%s", target, User_Name);
	
	AddMenuItem(info, temp, "네");  
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
} 

public remove_es_user_menu(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if(action == MenuAction_Select)
	{
		decl String:info[64], String:aa[2][64];
		GetMenuItem(menu, select, info, sizeof(info));
		ExplodeString(info, ";", aa,2,64);
		
     
		new target = StringToInt(aa[0]); 

		event[target] = false;
		PrintToChat(client, "\x03%s 유저를 이벤트에서 제외하였습니다.", aa[1]);
	}
}


stock bool:IsClientevent(client)
{
	if(event[client] == true)
	{
		return true;
	}
	return false;
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

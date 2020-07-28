
//메뉴쪽 #1
decl String:user_id[12];
IntToString(GetClientUserId(i), user_id, sizeof(user_id));
AddMenuItem(menu, user_id, temp);

//#2
decl String:user_id[24];
Format(user_id, sizeof(user_id), "%d", GetClientSerial(i));
AddMenuItem(menu, user_id, temp);


//#3
decl String:user[8];
Format(user, sizeof(user), "%i", i);


//메뉴 선택쪽 #1
decl String:info[32];
GetMenuItem(menu, select, info, sizeof(info));
new iInfo = StringToInt(info); 
new iUserid = GetClientOfUserId(iInfo);


//#2
decl String:info[32];
GetMenuItem(menu, select, info, sizeof(info));
new iInfo = StringToInt(info); 
new iUserid = GetClientFromSerial(iInfo); 


//#3
decl String:info[8];
GetMenuItem(menu, select, info, sizeof(info));
new user = StringToInt(info);


//----------------------------------------------------

public Action:asd(client)
{
	new Handle:info = CreateMenu(Menu_Information);
	SetMenuTitle(info, "asd");
	AddMenuItem(info, "1", "zxc");  
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
} 

public Menu_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
		if(select == 0)
		{
			CloseHandle(menu);
		}
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}



//--------------------------------------------------------- 타겟 한명씩
	new Handle:info = CreateMenu(profile_menu);
	SetMenuTitle(info, "플레이어 정보");
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(i > 0 && i <= MaxClients && IsClientInGame(i) && !IsFakeClient(i))
		{
			decl String:aName[MAX_NAME_LENGTH];
			GetClientName(client, aName, sizeof(aName));
			decl String:user[8];
			
			Format(user, sizeof(user), "%i", i);
			AddMenuItem(info, user, aName);  
		}
	}
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
	return Plugin_Handled;

///////////////////////////////////////////////////////////////
new Handle:enu[MAXPLAYERS+1];

public Action:asd(client, args)
{
	enu[client] = CreateMenu(Menu_Information);
	SetMenuTitle(enu[client], "asd");
	AddMenuItem(enu[client], "1", "zxc");   
	SetMenuExitButton(enu[client], true);

	DisplayMenu(enu[client], client, MENU_TIME_FOREVER);
} 

	if( enu[client] != INVALID_HANDLE )
	{
		CancelMenu( enu[client] );
		enu[client] = INVALID_HANDLE;
	}
	
///////////////////////////////////////////////////////////////

AddMenuItem(menu, "A", "A 클릭시");

GetMenuItem(menu, select, info, sizeof(info))
if(StrEqual(info, "A"))
{
}

////////////////////////////////////////////////////////////////


public Action:remove_es_user(client, target, String:name[])
{
	new Handle:info = CreateMenu(remove_es_user_menu);
	
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

		event[target] = 0;
		PrintToChat(client, "%s 유저를 이벤트에서 제외하였습니다.", aa[1]);
	}
}
#include <geoip>

public OnPluginStart()
{
	LoadTranslations("take_command.phrases");
	
	RegConsoleCmd("sm_command", us_command, "");
	
	RegAdminCmd("sm_ac", admin_command, ADMFLAG_KICK);
}

public OnClientSayCommand_Post(client, const String:command[], const String:sArgs[])
{	
	if (strcmp(sArgs, "!명령어", false) == 0)
	{
		user_command(client);
	}
}

public Action:admin_command(client, args)
{
	new Handle:info = CreateMenu(Admin_Menu); 
	SetMenuTitle(info, "어드민 명령어"); 
	AddMenuItem(info, "1", "!resizehead (대상) (숫자) :대상 머리 크기 변경");
	AddMenuItem(info, "1", "!ev : 이벤트 할때 반드시 유저에게 치라고 시켜야될 명령어"); //	
	AddMenuItem(info, "1", "@event : !ev를 친 유저 전부를 말함"); //		
	AddMenuItem(info, "1", "@admin : 접속되어 있는 어드민을 위한것"); //	
	AddMenuItem(info, "1", "@vip : 접속되어 있는 기부자를 위한것"); //	
	AddMenuItem(info, "1", "골뱅이로 시작하는 것들의 사용법은 /bring @event"); //
	AddMenuItem(info, "1", "!event : 이벤트를 위한 명령어이므로 전부 리셋!"); //
	AddMenuItem(info, "1", "!evfi : 이벤트가 종료될때 반드시 쳐야할 명령어"); //
	AddMenuItem(info, "1", "!un : 언유 효과");
	AddMenuItem(info, "1", "!acar (대상) : 차를 태움");
	AddMenuItem(info, "1", "!rcar (대상) : 차를 제거함");
	AddMenuItem(info, "1", "!goto (대상) : 대상에게 감");
	AddMenuItem(info, "1", "!bring (대상) : 대상을 데리고옴");
	AddMenuItem(info, "1", "!god : 갓 모드");
	AddMenuItem(info, "1", "!buddha : 로점 가능한 갓 모드");
	AddMenuItem(info, "1", "!nuke : 에임 위치에 핵");
	AddMenuItem(info, "1", "!pipe : 점착 이펙트");
	AddMenuItem(info, "1", "!rof (대상) (숫자) : 공격 속도 증가");
	AddMenuItem(info, "1", "!sw : 수영 모드");
	AddMenuItem(info, "1", "!aia :(대상) (0/1) : 총알 무한)"); 
	AddMenuItem(info, "1", "!aia2 :(대상) (시간(초)) ~초 동안 대상에게 총알무한");
	AddMenuItem(info, "1", "!a (대상) (시간(초)) : 탄환 궤적. -1하면 무한");
	AddMenuItem(info, "1", "!b (대상) (시간(초)) : 투명화. -1하면 무한");
	AddMenuItem(info, "1", "!c (대상) (시간(초)) : 히든 스파이 모드. -1하면 무한");
	AddMenuItem(info, "1", "!d (대상) (시간(초)) : 무한 더블 점프. -1하면 무한");
	AddMenuItem(info, "1", "!h (대상) (수치) : 피 증가");
	AddMenuItem(info, "1", "!ba (대상) : 백스텝 불가");
	
	SetMenuExitButton(info, true); //

	DisplayMenu(info, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public Action:us_command(client, args)
{
	user_command(client);
	return Plugin_Handled;
}

public user_command(client)
{
	// decl String:ip[20];
	// decl String:code2[3];
	// decl String:country[50];

		new String:store[256];
	
	// GetClientIP(client, ip, sizeof(ip), false);
		
	// GeoipCode2(ip, code2);
	// strcopy(country, sizeof(country), code2);
	
	// if (StrEqual(country, ""))
	// {
		Format(store, sizeof(store), "%T", "Store", client);
	//여기서 번역이란걸 넣는거임 
	
		new Handle:info = CreateMenu(User_Menu); 
		SetMenuTitle(info, "%T", "menu name",client);  
		AddMenuItem(info, "1", store);

		SetMenuExitButton(info, true); //

		DisplayMenu(info, client, MENU_TIME_FOREVER);

}

public Admin_Menu(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
	}
}

public User_Menu(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
	}
}
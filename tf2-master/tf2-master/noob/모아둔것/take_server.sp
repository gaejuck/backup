#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>

public Plugin:myinfo = 
{
	name = "Connect Server",
	author = "K",
	description = "ㅇㅇ 서버이동",
	version = "1.0", 
	url = "http://steamcommunity.com/id/kimh0192/"
};

new Handle:ConnectTime;
new String:ServerConfig[120];

public OnPluginStart()
{
	ConnectTime = CreateConVar("sm_connect_time", "1.0", "커넥트 박스 시간 조절");
	
	BuildPath(Path_SM, ServerConfig, sizeof(ServerConfig), "configs/custom-server.cfg");
	
	RegConsoleCmd("sm_server", CS);
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");
}

public Action:CS(client, args)
{
	ConnectServer(client);
	return Plugin_Handled;
}
public Action:ConnectServer(client)
{
	new Handle:menu = CreateMenu(server_select); new Handle:DB = CreateKeyValues("server");
	new String:ip[192], String:serverName[256];
	SetMenuTitle(menu, "서버가 즐겨찾기한 서버들", client);
	FileToKeyValues(DB, ServerConfig);
	KvGotoFirstSubKey(DB)
	do
	{
		KvGetSectionName(DB, serverName, sizeof(serverName));
		KvGetString(DB, "ip", ip, sizeof(ip), "NULL_IP");
		AddMenuItem(menu, ip, serverName);
	}
	while (KvGotoNextKey(DB));
	
	KvRewind(DB);
	CloseHandle(DB);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	SetMenuExitButton(menu, true);
}

public server_select(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if(action == MenuAction_Select)
	{
		decl String:info[192];
		
		GetMenuItem(menu, param2, info, sizeof(info));
		DisplayAskConnectBox(client, GetConVarFloat(ConnectTime), info);
	}
}

public Action:Command_Say(client, const String:command[], argc)
{
	decl String:text[192];
	new startidx = 0;
	if (GetCmdArgString(text, sizeof(text)) < 1)
	{
		return Plugin_Continue;
	}
 
	if (text[strlen(text)-1] == '"')
	{
		text[strlen(text)-1] = '\0';
		startidx = 1;
	}
 
	if (strcmp(command, "say2", false) == 0)
		startidx += 4;
		
	if (strcmp(text[startidx], "!서버", false) == 0)
	{
		ConnectServer(client);
		return Plugin_Handled;
	}
	else if (strcmp(text[startidx], "/서버", false) == 0)
	{
		ConnectServer(client);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

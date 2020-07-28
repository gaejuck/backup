#include <sourcemod>
#include <sdktools>

public Plugin:myinfo =
{
	name = "Take Music",
	author = "TAKE 2",
	description = "Take Music",
	version = "1.0",
	url = "http://steamcommunity.com/id/asdlkjasdlkjasd/"
}

new String:ServerConfig[120];

public OnPluginStart()
{
	RegConsoleCmd("sm_music", music);
	RegConsoleCmd("sm_stop", music_stop);
	RegConsoleCmd("sm_iu", Iu_Song);
	RegConsoleCmd("sm_musiclist", Music_List);
	
	BuildPath(Path_SM, ServerConfig, sizeof(ServerConfig), "configs/music.cfg");
}

public Action:music(client, args)
{
	
	if(args != 1)
	{
		ReplyToCommand(client, "Usage: !music <music name>");
		return Plugin_Handled;
	}

	new String:MusicName[256], String:MN[512];
	GetCmdArgString(MusicName, sizeof(MusicName));

	Format(MN, sizeof(MN), "http://www.google.com/search?tbm=vid&btnI=1&q=%s", MusicName);
	
	new Handle:setup = CreateKeyValues("data");
	
	KvSetString(setup, "title", "Music");
	KvSetNum(setup, "type", MOTDPANEL_TYPE_URL);
	KvSetString(setup, "msg", MN);
	
	ShowVGUIPanel(client, "info", setup, true);
	CloseHandle(setup);
	
	return Plugin_Handled;
}

public Action:music_stop(client, args) {
	new Handle:setup = CreateKeyValues("data");
	
	KvSetString(setup, "title", "");
	KvSetNum(setup, "type", MOTDPANEL_TYPE_URL);
	KvSetString(setup, "msg", "http://naver.com");
	
	ShowVGUIPanel(client, "info", setup, false);
	CloseHandle(setup);
	return Plugin_Handled;
}

public Action:Music_List(client, args)
{
	new Handle:menu = CreateMenu(music_select); new Handle:DB = CreateKeyValues("server");
	new String:url[192], String:Music_Name[256];
	SetMenuTitle(menu, "노래, 영상 리스트", client);
	FileToKeyValues(DB, ServerConfig);
	KvGotoFirstSubKey(DB)
	do
	{
		KvGetSectionName(DB, Music_Name, sizeof(Music_Name));
		KvGetString(DB, "url", url, sizeof(url), "NULL_url");
		AddMenuItem(menu, url, Music_Name);
	}
	while (KvGotoNextKey(DB));
	
	KvRewind(DB);
	CloseHandle(DB);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	SetMenuExitButton(menu, true);
}

public music_select(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if(action == MenuAction_Select)
	{
		decl String:info[192];
		
		GetMenuItem(menu, param2, info, sizeof(info));
		
		new Handle:setup = CreateKeyValues("data");
		
		KvSetString(setup, "title", "Music"); 
		KvSetNum(setup, "type", MOTDPANEL_TYPE_URL);
		KvSetString(setup, "msg", info);
		
		ShowVGUIPanel(client, "info", setup, true);
		CloseHandle(setup);
	}
}

public Action:Iu_Song(client, args)
{
	new Handle:setup = CreateKeyValues("data");
	
	KvSetString(setup, "title", "");
	KvSetNum(setup, "type", MOTDPANEL_TYPE_URL);
	KvSetString(setup, "msg", "https://www.youtube.com/watch?v=ktVsDf5R0HI&list=PLFJKpN3vOsCHxvruakGgdDg8BQSbYsPpj&index=2");
	
	ShowVGUIPanel(client, "info", setup, true);
	CloseHandle(setup);
	return Plugin_Handled;
}
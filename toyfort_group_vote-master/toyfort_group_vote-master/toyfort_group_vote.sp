#include <sdktools>

public OnPluginStart() RegConsoleCmd("sm_rv", rv);

public Action:rv(client, args)
{
	Vote_Menu(client);
	return Plugin_Handled;
}

public Vote_Menu(client)
{ 
	new Handle:info = CreateMenu(vote_select);
	SetMenuTitle(info, "랭킹 초기화에 찬성합니까?");
	AddMenuItem(info, "1", "1번 방지", ITEMDRAW_DISABLED);  
	AddMenuItem(info, "1", "2번 방지", ITEMDRAW_DISABLED);  
	AddMenuItem(info, "1", "",ITEMDRAW_DISABLED);  
	AddMenuItem(info, "찬성", "찬성");  
	AddMenuItem(info, "반대", "반대");  
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
} 

public vote_select(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:FileName[PLATFORM_MAX_PATH], String:SteamID[32], String:info[64];
		
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
		
		BuildPath(Path_SM, FileName, sizeof(FileName), "data/vote.txt");
		
		GetMenuItem(menu, select, info, sizeof(info))
		
		new Handle:DB = CreateKeyValues("rank_reset");
		FileToKeyValues(DB, FileName);
		
		// new chan, ban;
		
		if(KvJumpToKey(DB, SteamID, true))
		{
			if(StrEqual(info, "찬성"))
			{
				// chan = 1;
				PrintToChat(client, "\x07FFFFFF당신은 찬성 버튼을 누르셨습니다.");
				KvSetNum(DB, "yes", 1);
			}
			else
			{
				// ban = 1;
				PrintToChat(client, "\x07FFFFFF당신은 반대 버튼을 누르셨습니다.");
				KvSetNum(DB, "yes", 0);
			}
		}
		
		KvRewind(DB); 
		KeyValuesToFile(DB, FileName);
		CloseHandle(DB);
		
		if(!FileExists(FileName, true))
		{
			EmitSoundToClient(client, "replay/cameracontrolerror.wav");
			PrintToChat(client, "파일이 존재하지 않습니다.");
		}
		
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

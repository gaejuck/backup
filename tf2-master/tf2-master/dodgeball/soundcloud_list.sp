#define size 256
#define one size-1
#define MAXNAME 1

char soundcloud_menu[120];

Handle SearchMusic;
Handle SearchMusic2;

char soundlist[MAXPLAYERS+1][2][size];
int count[MAXPLAYERS+1];
int songcount[MAXPLAYERS+1];

public Plugin myinfo = {
	name		= "SoundCloud list (dodgeball version)",
	author	  = "ㅣ",
	description = "사운드 클라우드 리스트",
	version	 = "2.0",
	url		 = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
};


public void OnPluginStart()
{
	BuildPath(Path_SM, soundcloud_menu, sizeof(soundcloud_menu), "configs/soundcloud.cfg");
	
	RegConsoleCmd("sm_scch", chochun);
	RegConsoleCmd("sm_scchlistus", scchlistus);
	RegAdminCmd("sm_scall", scall, ADMFLAG_KICK);
	RegAdminCmd("sm_scchlist", chochunlist, ADMFLAG_KICK);
	RegAdminCmd("sm_sclist", song, ADMFLAG_KICK);
	
	SearchMusic = CreateArray(size,0);
	SearchMusic2 = CreateArray(size,0);
}
public void OnClientDisconnected(int client)
{
	ClearArray(SearchMusic);
	ClearArray(SearchMusic2);
	
	soundlist[client][0] = "";
	soundlist[client][1] = "";
	count[client] = 0;
	songcount[client] = 0;
}

public Action scall(int client, int args)
{
	char SearchWord[size];
	GetCmdArgString(SearchWord, sizeof(SearchWord));
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			FakeClientCommand(i, "sm_ccvvdwwaqzx %s", SearchWord);
		}
	}
	return Plugin_Handled;
}
public Action chochun(int client, int args)
{
	char SearchWord[size];
	GetCmdArgString(SearchWord, sizeof(SearchWord));
	
	if(StrEqual(SearchWord, ""))
	{
		PrintToChat(client, "\x07FFFFFF!노래신청 <노래 제목과 가수 이름까지 써주세요>");
		return Plugin_Handled;
	}
	
	if(count[client] < 2)
	{
		char temp[size], minute[21];
		
		FormatTime(minute, sizeof(minute), "%M", -1);
		
		Format(temp, sizeof(temp), "%s분 %N님의 노래 ːː %s", minute, client, SearchWord);
		soundlist[client][count[client]] = temp; PushArrayString(SearchMusic2, temp);
		count[client]++;
		PrintToChat(client, "\x07FFFFFF성공적으로 어드민에게 전달하였습니다. 취소할 노래는 !노래취소로 가능합니다.");
	}
	else
		PrintToChat(client, "\x07FFFFFF노래 신청은 2개까지 또는 한개를 더 들어야합니다.");
	return Plugin_Handled;
}

public Action scchlistus(int client, int args)
{
	Handle menu = CreateMenu(us_select);
	SetMenuTitle(menu, "신청한 노래 목록 (누르면 취소됩니다.)", client);
	
	
	for(new j = 0; j <= 1; j++)
	{
		if(!StrEqual(soundlist[client][j], ""))
		{		
			char temp[2][size];
			ExplodeString(soundlist[client][j], "ːː", temp, 2, size);
			
			AddMenuItem(menu, soundlist[client][j], temp[1]);
		}
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public us_select(Handle menu, MenuAction action, int client, int select)
{
	if(action == MenuAction_Select)
	{
		char name[size], temp[2][size];
		GetMenuItem(menu, select, name, sizeof(name));
		
		for(new j = 0; j <= 1; j++)
		{
			if(!StrEqual(soundlist[client][j], ""))
			{
				if(StrEqual(soundlist[client][j], name))
				{
					ExplodeString(soundlist[client][j], "ːː", temp, 2, size);
					PrintToChat(client, "\x07FFFFFF '%s' 노래를 취소합니다.", temp[1]);
					soundlist[client][j] = "";
					songcount[client]++;
							
					if(songcount[client] == 2)
					{
						songcount[client] = 0;
						count[client] = 0; 
					}
				}
			}
		}
		// PrintToChat(client, "\x07FFFFFF '%s' 노래를 취소합니다.", temp[1]);
		
		if(action == MenuAction_End)
		{
			CloseHandle(menu);
		}
	}
}

public Action chochunlist(int client, int args)
{
	Handle menu = CreateMenu(asdasd);
	SetMenuTitle(menu, "추천 노래 리스트", client);
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			for(new j = 0; j <= 1; j++)
			{
				if(!StrEqual(soundlist[i][j], ""))
				{		
					AddMenuItem(menu, soundlist[i][j], soundlist[i][j]);
				}
			} 
		}
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public asdasd(Handle menu, MenuAction action, int client, int select)
{
	if(action == MenuAction_Select)
	{ 
		char name[size];
		GetMenuItem(menu, select, name, sizeof(name));
		
		char temp[2][size];
		ExplodeString(name, "ːː", temp, 2, size);
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				FakeClientCommand(i, "sm_ccvvdwwaqzx %s", temp[1]);
				for(new j = 0; j <= 1; j++)
				{
					if(!StrEqual(soundlist[i][j], ""))
					{
						if(StrEqual(soundlist[i][j], name))
						{
							soundlist[i][j] = "";
							songcount[i]++;
							
							if(songcount[i] == 2)
							{
								songcount[i] = 0;
								count[i] = 0;
							}
						}
					}
				}
			}
		}
					
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action song(int client, int args)
{
	char SearchWord[16], SearchValue;
	GetCmdArgString(SearchWord, sizeof(SearchWord));
	
	Handle DB = CreateKeyValues("soundcloud");
	Handle menu = CreateMenu(song_select);
	
	char name[size], SongName[size];
	
	SetMenuTitle(menu, "추천 노래 리스트", client);
	AddMenuItem(menu, "1", "!노래목록 <검색>도 가능합니다.", ITEMDRAW_DISABLED);
	AddMenuItem(menu, "랜덤", "랜덤");
		
	FileToKeyValues(DB, soundcloud_menu);
	if(KvGotoFirstSubKey(DB))
	{
		do
		{
			KvGetSectionName(DB, name, sizeof(name));
			KvGetString(DB, "name", SongName, sizeof(SongName));
			PushArrayString(SearchMusic, SongName);
			
			if(StrContains(name, SearchWord, false) > -1)
			{
				AddMenuItem(menu, SongName, name);  
				SearchValue++;
			}
		}
		while(KvGotoNextKey(DB));
		
		KvGoBack(DB);
	}
	
	if(!SearchValue)
	{
		PrintToChat(client, "\x03이름이 잘못되었거나 없는 이름입니다.");
	}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	KvRewind(DB);
	CloseHandle(DB);
	return Plugin_Handled;
} 

public song_select(Handle menu, MenuAction action, int client, int select)
{
	if(action == MenuAction_Select)
	{ 
		char name[size];
		char SongName[size];
		GetMenuItem(menu, select, name, sizeof(name));
		
		if(StrEqual(name, "랜덤"))
		{
			for(int i = 0; i < GetArraySize(SearchMusic); i++) 
			{
				GetArrayString(SearchMusic, GetRandomInt(0, i), SongName, sizeof(SongName));
					
				int array = FindStringInArray(SearchMusic, SongName);
				if (array != -1)
				{
					RemoveFromArray(SearchMusic, array);
				}
			}
			
			for(new h = 1; h <= MaxClients; h++)
				if(IsClientInGame(h))
					FakeClientCommand(h, "sm_ccvvdwwaqzx %s",  SongName);
		}
		else
		{
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i))
				{
					FakeClientCommand(i, "sm_ccvvdwwaqzx %s",  name);
				}
			}
		}

	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

stock bool PlayerCheck(int Client){
	if(Client > 0 && Client <= MaxClients){
		if(IsClientConnected(Client) == true){
			if(IsClientInGame(Client) == true){
				return true;
			}
		}
	}
	return false;
}
#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>

public Plugin:myinfo = 
{
	name = "K Music",
	author = "K",
	description = "뮤직뮤직",
	version = "1.0", 
	url = "http://steamcommunity.com/id/kimh0192/"
};

new String: custom_sound[255];
// new String: ServerConfig[PLATFORM_MAX_PATH];

public OnPluginStart()
{
	RegConsoleCmd("sm_music", KM);
	RegAdminCmd("sm_reloadsounds", Reload_sounds, ADMFLAG_CHEATS);
	
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");
}

public OnMapStart()
{
	PrecacheSounds(-1);
}

public Action:KM(client, args)
{
	KMusicMenu(client);
	return Plugin_Handled;
}

public Action:KMusicMenu(client)
public Action:Reload_sounds(client, args)
{
    new Handle:menu = CreateMenu(server_music);
    Handle kv = CreateKeyValues("k_music"); 
	new String:serverName[256], String:files[256];
	
	SetMenuTitle(menu, "뮤직", client);
    FileToKeyValues(kv, "addons/sourcemod/configs/KMusic.cfg"); 
     
    if (!KvGotoFirstSubKey(kv)) 
        return -1; 
    do 
    { 
		KvGetSectionName(kv, serverName, sizeof(serverName));
		KvGetString(kv, "file", files, sizeof(files));
		AddMenuItem(menu, serverName, serverName);

         
    }while (KvGotoNextKey(kv)); 
    CloseHandle(kv);   
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	SetMenuExitButton(menu, true);
}  

public server_music(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	
	if(action == MenuAction_Select)
	{
		decl String:info[192];
		
		GetMenuItem(menu, param2, info, sizeof(info));
		EmitSoundToAll(info);
	}
}


public Action:Reload_sounds(client, args)
{
	if(client != 0)
		PrecacheSounds(true);
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
		
	if (strcmp(text[startidx], "!뮤직", false) == 0)
	{
		KMusicMenu(client);
		return Plugin_Handled;
	}
	else if (strcmp(text[startidx], "/뮤직", false) == 0)
	{
		KMusicMenu(client);
		return Plugin_Handled;
	}
	return Plugin_Continue;
}

public PrecacheSounds(client)
{
	decl String: downloadpath[255];
	new Handle: kv = CreateKeyValues("k_music");
	FileToKeyValues(kv, "addons/sourcemod/configs/KMusic.cfg");

	if (!KvGotoFirstSubKey(kv))
	{
		return;
	}

	do {
		KvGetString(kv, "file", custom_sound, sizeof(custom_sound));

		Format(downloadpath, sizeof(downloadpath), "sound/%s", custom_sound);
		AddFileToDownloadsTable(downloadpath);
		PrecacheSound(custom_sound, true);

	} while (KvGotoNextKey(kv));

	CloseHandle(kv);
	
	if(client != -1)
		PrintToChat(client, "\x03Sounds reloaded !");
		
}
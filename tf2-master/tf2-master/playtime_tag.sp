#include <steamtools>
#include <chat-processor>

new TF2Hours[MAXPLAYERS+1][2];

public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	
	for(new i = 1; i <= MaxClients; i++) if(IsValidClient(i)) OnClientConnected(i);
}

public OnClientConnected(client) if(IsClientF2P(client)) KickClient(client, "무료 유저는 출입 불가능합니다.");

public Action CP_OnChatMessage(int& author, ArrayList recipients, char[] flagstring, char[] name, char[] message, bool& processcolors, bool& removecolors)
{
	decl String:SteamID[32];
	GetClientAuthId(author, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	if(TF2Hours[author][1] >= 120) Format(name, MAXLENGTH_NAME, "\x07FFFFFF[2주플탐 %d] \x03%s",  TF2Hours[author][1], name);
	else if(TF2Hours[author][1] == -1) Format(name, MAXLENGTH_NAME, "\x07FFFFFF[프로필 비공개] \x03%s", name);
	else
	{
		if(StrEqual(SteamID, "STEAM_0:0:71646400")) Format(name, MAXLENGTH_NAME, "\x07FFFFFF[%d 시간] \x03%s", TF2Hours[author][0]+4958, name);
		else Format(name, MAXLENGTH_NAME, "\x07FFFFFF[%d 시간] \x03%s", TF2Hours[author][0], name);
	}
	return Plugin_Changed;
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	decl String:SteamID[32];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
	if(StrEqual(SteamID, "STEAM_0:0:71646400")) PrintToChat(client, "\x07FFFFFF당신의 플탐은 %d 시간이며 2주 플탐은 %d 시간입니다.", TF2Hours[client][0]+4958, TF2Hours[client][1]);
	else if(TF2Hours[client][1] > -1) PrintToChat(client, "\x07FFFFFF당신의 플탐은 %d 시간이며 2주 플탐은 %d 시간입니다.", TF2Hours[client][0], TF2Hours[client][1]);
}

public OnClientAuthorized(client, const String:auth[]) 
{
	if(IsFakeClient(client) || StrEqual(auth, "BOT", false)) return; 
	
	TF2Hours[client][0] = -1;
	TF2Hours[client][1] = -1;
	
	decl String:steamid[64];
	Steam_GetCSteamIDForClient(client, steamid, sizeof(steamid));
	
	new HTTPRequestHandle:Rekest2 = Steam_CreateHTTPRequest(HTTPMethod_GET, "http://api.steampowered.com/IPlayerService/GetOwnedGames/v1/");
	Steam_SetHTTPRequestGetOrPostParameter(Rekest2, "key", "3A87ED6B2826B78073B23F143CF5EA66");
	Steam_SetHTTPRequestGetOrPostParameter(Rekest2, "steamid", steamid);
	Steam_SetHTTPRequestGetOrPostParameter(Rekest2, "format", "vdf");
	Steam_SetHTTPRequestGetOrPostParameter(Rekest2, "include_played_free_games", "1");
	Steam_SendHTTPRequest(Rekest2, OnSteamAPI2, GetClientUserId(client));
}

public OnSteamAPI2(HTTPRequestHandle:request, bool:successful, HTTPStatusCode:statusCode, any:userid) 
{
	new client = GetClientOfUserId(userid);
	if(client == 0) 
	{
		Steam_ReleaseHTTPRequest(request);
		return;
	}
	if(!successful || statusCode != HTTPStatusCode_OK) 
	{
		if(successful && (_:statusCode < 500 || _:statusCode >= 600)) 
			LogError("%L Steam API error. Request %s, status code %d.", client, successful ? "successful" : "unsuccessful", _:statusCode);

		Steam_ReleaseHTTPRequest(request);
		return;
	}
	
	decl String:path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, path, sizeof(path), "data/tf2hours.txt");
	
	Steam_WriteHTTPResponseBody(request, path);
	Steam_ReleaseHTTPRequest(request);
	
	new Handle:kv = CreateKeyValues("response");
	FileToKeyValues(kv, path);
	
	if (!KvGotoFirstSubKey(kv)) return;
	
	decl String:strSection[255];
	
	do
	{
		KvGetSectionName(kv, strSection, sizeof(strSection));    // == game_count OR games
		
		if(StrEqual("games", strSection, true)) //Not sure if it does work .-.
		{
			if (!KvGotoFirstSubKey(kv))
			{
				LogError("Steam API returned invalid KeyValues. (Empty file)");
				return;
			}
			
			do
			{
				decl String:appid[10];
				
				KvGetString(kv, "appid", appid, sizeof(appid));
				if(StringToInt(appid) == 440)
				{
					TF2Hours[client][0] = KvGetNum(kv, "playtime_forever") / 60;
					TF2Hours[client][1] = KvGetNum(kv, "playtime_2weeks") / 60;
					break;
				}
				
			} while (KvGotoNextKey(kv));
		}
		
	} while (KvGotoNextKey(kv));
	
	CloseHandle(kv);
}

stock bool:IsValidClient(iClient, bool:bReplay = true)
	return (0 < iClient <= MaxClients && IsClientInGame(iClient) && (!bReplay || !IsClientSourceTV(iClient) && !IsClientReplay(iClient)));


stock bool:IsClientF2P(client)
{
	if(Steam_CheckClientSubscription(client, 0) && !Steam_CheckClientDLC(client, 459)) return true;
	return false;
}

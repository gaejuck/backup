#include <sourcemod>
#include <sdkhooks>
#include <scp>

new Handle:kcfg = INVALID_HANDLE;
new kill[MAXPLAYERS + 1];
new String:SL_File[64];

public Plugin:myinfo =
{
	name = "Kill Tag Plugin",
	author = "ㅣ",
	description = "킬 할수록 태그가 달라집니다.",
	version = "1.1",
	url = "http://steamcommunity.com/id/Error_Error_Error_Error/"
}


public OnPluginStart()
{
	HookEvent("player_death", EventDeath);
	RegAdminCmd("sm_save", save_admin, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_load", load_admin, ADMFLAG_RESERVATION);
	LoadConfig();
}

LoadConfig()
{
	if(kcfg != INVALID_HANDLE)
		CloseHandle(kcfg);
	kcfg = CreateKeyValues("kill_tag"); 
	decl String:tagConfig[64];
	BuildPath(Path_SM, tagConfig, sizeof(tagConfig), "configs/akt/kill_tag.cfg");
	if(!FileToKeyValues(kcfg, tagConfig))
		SetFailState("Config file missing");
	
	BuildPath(Path_SM, SL_File, sizeof(SL_File), "configs/akt/user.cfg");
}

public Action:save_admin(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
		Save(i);
	return Plugin_Handled;
}

public Action:load_admin(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
		CreateTimer(0.1, Load, i);
	return Plugin_Handled;
}

public OnClientPutInServer(Client)
	CreateTimer(0.1, Load, Client);

public OnClientDisconnect(Client)
	Save(Client);
	
public Save(client)
{
	if(PlayerCheck(client))
	{
		new String:SteamID[32];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	
		decl Handle:Vault;
		Vault = CreateKeyValues("kill_tag");
	
		if(FileExists(SL_File))
			FileToKeyValues(Vault, SL_File);
		
		if(kill[client] > 0)
		{	
			KvJumpToKey(Vault, "kill", true);
			KvSetNum(Vault, SteamID, kill[client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "kill", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}

		KvRewind(Vault);
		KeyValuesToFile(Vault, SL_File);
		CloseHandle(Vault);
	}
}


public Action:Load(Handle:Timer, any:client)
{
	if(PlayerCheck(client))
	{
		new String:SteamID[32];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));

		decl Handle:Vault;
		Vault = CreateKeyValues("kill_tag");

		FileToKeyValues(Vault, SL_File);
		KvJumpToKey(Vault, "kill", false);
		kill[client] = KvGetNum(Vault, SteamID);

		KvRewind(Vault);

		CloseHandle(Vault);
	}
}

public Action:OnChatMessage(&author, Handle:recipients, String:name[], String:message[])
{
	KvRewind(kcfg);
	if(KvGotoFirstSubKey(kcfg))
	{
		do
		{
			decl String:Color[64], String:tag[256];
			KvGetSectionName(kcfg, tag, sizeof(tag));
			KvGetString(kcfg, "color", Color, sizeof(Color)); 
			new kill_min = KvGetNum(kcfg, "kill min");
			new kill_max = KvGetNum(kcfg, "kill max");
				
			if(kill_max >= kill[author] >= kill_min)
			{
				Format(name, MAXLENGTH_NAME, "\x07%s%s \x03%s", Color, tag, name);
				return Plugin_Handled;
			}
		}
		while(KvGotoNextKey(kcfg)); 
	}
	return Plugin_Changed;
}


public EventDeath(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(Spawn_Event, "userid"));
	new Attacker = GetClientOfUserId(GetEventInt(Spawn_Event, "attacker"));

	if(client != Attacker)
		kill[Attacker] ++;
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

#include <sourcemod>
#include <sdkhooks>
#include <scp>

new Handle:kcfg = INVALID_HANDLE;
new Handle:db = INVALID_HANDLE;

new kill[MAXPLAYERS + 1];

public Plugin:myinfo =
{
	name = "Kill Tag Plugin",
	author = "TAKE 2",
	description = "킬 할수록 태그가 달라집니다.",
	version = "1.1",
	url = "http://steamcommunity.com/id/Error_Error_Error_Error/"
}

public OnPluginStart()
{
	HookEvent("player_death", EventDeath);
	
	SQL_TConnect(connect, "kill_tag"); 
	LoadConfig()
}

LoadConfig()
{
	if(kcfg != INVALID_HANDLE)
		CloseHandle(kcfg);
	kcfg = CreateKeyValues("kill_tag"); 
	decl String:tagConfig[64];
	BuildPath(Path_SM, tagConfig, sizeof(tagConfig), "configs/akt/kill_tag.cfg");
	if(!FileToKeyValues(kcfg, tagConfig))
		SetFailState("Kill tag Config file missing");
}

public OnClientPutInServer(client)
{
	if(!IsFakeClient(client))
	{
		new String:SteamID[32], String:query[256];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
		steamidtodbid(SteamID, 32);
		Format(query, 256, "select * from KillTag where steamid = '%s';", SteamID);
		SQL_TQuery(db, Loadb, query, client);
	}
}

public OnClientDisconnect(client)
	if(!IsFakeClient(client))
		kill[client] = 0;

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
	{
		kill[Attacker] ++;
		Save_Player_kill(Attacker);
	}
}

public Save_Player_kill(client) //세이브 킬
{
	new String:clientsteamid[32], String:query[256], String:Client_Name[MAX_NAME_LENGTH];
	GetClientAuthId(client, AuthId_Steam2, clientsteamid, sizeof(clientsteamid));
	GetClientName(client, Client_Name, sizeof(Client_Name));
	
	SetPreventSQLInject(Client_Name, Client_Name, sizeof(Client_Name));
		
	Format(query, 256, "update KillTag set Player_Name = '%s' where steamid = '%s';", Client_Name, clientsteamid);
	SQL_TQuery(db, updatedata, query, client);
		
	Format(query, 256, "update KillTag set Player_Kill = '%d' where steamid = '%s';", kill[client], clientsteamid);
	SQL_TQuery(db, updatedata, query, client);
}

public Loadb(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	new String:query[2048], String:Name[MAX_NAME_LENGTH], String:clientsteamid[32];
	GetClientAuthId(client, AuthId_Steam2, clientsteamid, sizeof(clientsteamid));
	steamidtodbid(clientsteamid, 32);
	GetClientName(client, Name, sizeof(Name));
	
	if (hndl == INVALID_HANDLE)
	{
		LogError("Kill tag Loadb failed %s", error);
		PrintToServer("Kill tag Loadb failed %s", error);
	}
	else if(SQL_GetRowCount(hndl) != 0)
	{
		if(SQL_HasResultSet(hndl))
		{
			while(SQL_FetchRow(hndl))
			{
				if(PlayerCheck(client) == true)
				{
					kill[client] = SQL_FetchInt(hndl, 2);	
				}
			}
		}
	}
	else if(SQL_GetRowCount(hndl) == 0)
	{
		Format(query, sizeof(query), "insert into KillTag(steamid, Player_Name, Player_Kill) values('%s', '%s', '%d') on duplicate key update Player_Name = '%s';", clientsteamid, Name, kill[client], Name);
		SQL_TQuery(db, insertdb, query, 0);
	}
}

public connect(Handle:owner, Handle:hd, const String:error[], any:data)
{
	if (hd == INVALID_HANDLE)
	{
		PrintToServer("Kill tag Failed to connect: %s", error);
		return;
	}
	else
	{	
		PrintToServer("Kill tag Query Connected!");
		db = hd;
		SQL_TQuery(db, dbname, "SET NAMES 'UTF8'", 0, DBPrio_High);
		SQL_TQuery(db, createtable, "create table if not exists KillTag(steamid varchar(64), Player_Name varchar(64), Player_Kill int) ENGINE=MyISAM  DEFAULT CHARSET=utf8;", 0);
	}
}

public insertdb(Handle:owner, Handle:hd, const String:error[], any:data)
	if (hd == INVALID_HANDLE)
		LogError("Kill tag query insertdb failed %s", error);
		
public updatedata(Handle:owner, Handle:hndl, const String:error[], any:data)
	if(hndl == INVALID_HANDLE)
		LogError("Kill tag query update failed %s", error);

public dbname(Handle:owner, Handle:hd, const String:error[], any:data)
{
	if (hd == INVALID_HANDLE) 
		LogError("Kill tag query dbname failed : %s", error);
	else PrintToServer("Kill tag Successful dbname query");
}
		
public createtable(Handle:owner, Handle:hd, const String:error[], any:data)
{
	if (hd == INVALID_HANDLE)
		LogError("Kill tag table query create failed %s", error);
	else PrintToServer("Kill tag table query create success");	
}



stock SetPreventSQLInject(const String:input[], String:output[], oplength)
{
	new String:tempstr[512];
	
	strcopy(tempstr, sizeof(tempstr), input);
	
	ReplaceString(tempstr, sizeof(tempstr), "'", "''", false);
	ReplaceString(tempstr, sizeof(tempstr), "`", "`", false);
	ReplaceString(tempstr, sizeof(tempstr), "\\", "\\\\", false);
	
	strcopy(output, oplength, tempstr);
}

public steamidtodbid(String:steamid[], maxlength)
	ReplaceString(steamid, maxlength, ":", ":", false);

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

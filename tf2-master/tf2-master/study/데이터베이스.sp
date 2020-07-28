#include <sourcemod>
#include <sdktools>
#include <scp>

new Handle:kcfg = INVALID_HANDLE;
new Handle:db = INVALID_HANDLE;
new Load_Check[MAXPLAYERS+1];
new Player_Kill[MAXPLAYERS+1];
new Player_Death[MAXPLAYERS+1];

public Plugin:myinfo =
{
	name = "kill tag",
	author = "ㅣ",
	description = "킬 할수록 태그가 달라집니다.",
	version = "1.4",
	url = "http://steamcommunity.com/id/Error_Error_Error_Error/"
}

public OnPluginStart()
{
	HookEvent("player_death", EventDeath);
	LoadConfig();
}

LoadConfig()
{
	// SQL_TConnect(Sqlcon, "kill_tag");
	if(kcfg != INVALID_HANDLE)
		CloseHandle(kcfg);
	kcfg = CreateKeyValues("kill_tag"); 
	decl String:tagConfig[64];
	BuildPath(Path_SM, tagConfig, sizeof(tagConfig), "configs/kill_tag.cfg");
	if(!FileToKeyValues(kcfg, tagConfig))
		SetFailState("Config file missing");
}

public OnMapStart()
{
	SQL_TConnect(Sqlcon, "kill_tag");
}

public OnClientPutInServer(Client)
{
	PlayerDateReset(Client);
	if(!IsFakeClient(Client)) CreateTimer(GetRandomFloat(1.0, 3.0), Load_Player_Data, Client);
}

public OnClientDisconnect(Client)
{
	if(!IsFakeClient(Client)) Save_Player_Data(Client);
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
				
			if(kill_max >= Player_Kill[author] >= kill_min)
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
	new Client = GetClientOfUserId(GetEventInt(Spawn_Event, "userid"));
	new Attacker = GetClientOfUserId(GetEventInt(Spawn_Event, "attacker"));

	if(Client != Attacker)
	{
		Player_Kill[Attacker] ++;
		Player_Death[Client] ++;
		// Save_Player_Data(Attacker);
	}
}

public Action:Load_Player_Data(Handle:timer, any:Client)
{
	new String:clientsteamid[32], String:query[256];
	GetClientAuthId(Client, AuthId_Steam2, clientsteamid, sizeof(clientsteamid));
	steamidtodbid(clientsteamid, 32);
	Format(query, 256, "select * from PlayerInfo where steamid = '%s';", clientsteamid);
	SQL_TQuery(db, existcheck, query, Client);
}

public existcheck(Handle:owner, Handle:hndl, const String:error[], any:Client)
{
	new String:query[2048], String:Name[256], String:clientsteamid[32];
	GetClientAuthId(Client, AuthId_Steam2, clientsteamid, sizeof(clientsteamid));
	steamidtodbid(clientsteamid, 32);
	GetClientName(Client, Name, sizeof(Name));
	
	if (hndl == INVALID_HANDLE)
	{
		LogError("exist check failed %s", error);
		PrintToServer("exist check failed %s", error);
	}
	else if(SQL_GetRowCount(hndl) != 0)
	{
		if(SQL_HasResultSet(hndl))
		{
			while(SQL_FetchRow(hndl))
			{
				if(JoinCheck(Client) == true)
				{
					Player_Kill[Client] = SQL_FetchInt(hndl, 2);
					Player_Death[Client] = SQL_FetchInt(hndl, 3);
				}
				Load_Check[Client] = 1;
			}
		}
	}
	else if(SQL_GetRowCount(hndl) == 0)
	{
		Format(query, sizeof(query), "insert into PlayerInfo(steamid, username, Player_Kill, Player_Death) values('%s', '%s', '%d', '%d');", clientsteamid, Name, Player_Kill[Client], Player_Death[Client]);
		SQL_TQuery(db, insertdata, query, 0);
	}
}

public Save_Player_Data(Client)
{
	new String:clientsteamid[32], String:query[256], String:Client_Name[256];
	GetClientAuthId(Client, AuthId_Steam2, clientsteamid, sizeof(clientsteamid));
	GetClientName(Client, Client_Name, 32);
	
	if(Load_Check[Client] == 1)
	{
		SetPreventSQLInject(Client_Name, Client_Name, sizeof(Client_Name));
		
		Format(query, 256, "update PlayerInfo set username = '%s' where steamid = '%s';", Client_Name, clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update PlayerInfo set Player_Kill = '%d' where steamid = '%s';", Player_Kill[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update PlayerInfo set Player_Death = '%d' where steamid = '%s';", Player_Death[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
	}
}

public Sqlcon(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		PrintToServer("Failed to connect: %s", error);
	}
	else
	{	
		PrintToServer("[QueryNotice] Query Connected!");
		db = hndl;
		SQL_TQuery(db, configcharset, "SET NAMES 'UTF8'", 0, DBPrio_High);
		SQL_TQuery(db, datatablecheck, "SHOW TABLES LIKE 'PlayerInfo'", 0);
	}
}

public datatablecheck(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE)
		LogError("table query exists failed %s", error);
	else if(SQL_GetRowCount(hndl) != 0)
		PrintToServer("[QueryNotice] PlayerInfo Table Check OK!");
	else SQL_TQuery(db, createdatatable, "create table if not exists PlayerInfo(steamid varchar(64), username varchar(64), Player_Kill int, Player_Death int, primary key(username)) ENGINE=MyISAM  DEFAULT CHARSET=utf8;", 0);
}

public configcharset(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE) 
		LogError("Failed attempt to set the charset : %s", error);
	else PrintToServer("[QueryNotice] Successful attempt to set the charset");
}

public createdatatable(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
		LogError("table query create failed %s", error);
	else PrintToServer("[QueryNotice] table query create success");	
}

public steamidtodbid(String:steamid[], maxlength)
{
	ReplaceString(steamid, maxlength, ":", ":", false);
}

public insertdata(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
		LogError("query insert failed %s", error);
}

public updatedata(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
		LogError("query update failed %s", error);
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

public PlayerDateReset(Client)
{
	Player_Kill[Client] = 0;
	Player_Death[Client] = 0;
}

stock bool:JoinCheck(Client)
{
	if(Client > 0 && Client <= MaxClients)
		if(IsClientConnected(Client) == true)
			if(IsClientInGame(Client) == true)
				return true;
			else return false;
		else return false;
	else return false;
}

stock bool:AliveCheck(Client)
{
	if(JoinCheck(Client) == true)
		if(IsPlayerAlive(Client) == true)
			return true;
		else return false;
	else return false;
}

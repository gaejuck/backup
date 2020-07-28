#include <dbvip/dbvip>

#define KillPoint 2
#define AssiPoint 1
#define vipranker 3

new Handle:db = INVALID_HANDLE;

new point[MAXPLAYERS+1];
new top10[MAXPLAYERS+1];
new vip[MAXPLAYERS+1];

new Handle:cvartop10 = INVALID_HANDLE;

public OnPluginStart()
{
	SQL_TConnect(connect, "tk_rank"); 
	
	RegConsoleCmd("sm_top", top100);
	RegConsoleCmd("sm_rank", urank);
	
	HookEvent("player_death", Player_Death);
	
	cvartop10 = CreateConVar("sm_rank_top", "3", "1위부터 5위까지 vip 효과");
}

public OnClientPutInServer(client)
{
	if(!IsFakeClient(client))
	{
		new String:SteamID[32], String:query[256];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
		steamidtodbid(SteamID, 32);
		Format(query, 256, "select * from tk_rank where steamid = '%s';", SteamID);
		SQL_TQuery(db, Loadb, query, client);
		
		
		if(IsClientAdmin(client))
		{
			IsClientAddVip(client);
		}
		
		decl String:query2[256];		
		Format(query2, 256, "select count(*)+1 from tk_rank where Point > (select Point from tk_rank where steamid = \"%s\");", SteamID);
		SQL_TQuery(db, vipuser, query2, client);
	}
}

public vipuser(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	if (hndl == INVALID_HANDLE)
	{
		LogError("[TK_RANK] Query failed! %s", error);
	}
	else
	{
		new rank;

		while (SQL_FetchRow(hndl))
		{
			rank = SQL_FetchInt(hndl, 0);
		}

		top10[client] = rank;
		
		if(top10[client] <= GetConVarInt(cvartop10))
		{
			IsClientAddVip(client);
		}
		else
		{
			if(!IsClientAdmin(client))
			{
				IsClientRemoveVip(client);
			}
		}
	}
}


public Action:urank(client, args)
{
	new Handle:menu = CreateMenu(Menu_top);
	SetMenuTitle(menu, "내 정보");
	
	new String:text[64], String:text2[64], String:text3[64];
	
	Format(text, sizeof(text),"랭킹 %d위", top10[client]);
	Format(text2, sizeof(text2),"포인트 : %d 포인트", point[client]);	
	Format(text3, sizeof(text3),"랭킹 %d위까지 vip 혜택을 받을 수 있습니다.", vipranker);	

	
	AddMenuItem(menu, "", text, ITEMDRAW_DISABLED);	
	AddMenuItem(menu, "", text2, ITEMDRAW_DISABLED);	
	AddMenuItem(menu, "", text3, ITEMDRAW_DISABLED);	
	
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Action:vvip(client, args)
{
	new Handle:menu = CreateMenu(Menu_top);
	SetMenuTitle(menu, "vip list");
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(PlayerCheck(i))
		{
			decl String:aName[MAX_NAME_LENGTH];
			GetClientName(i, aName, sizeof(aName));
			
			if(IsClientVip(i))
				AddMenuItem(menu, "", aName);	
		}
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Action:top100(client, args)
{
	decl String:bufferss[200];
	Format(bufferss, 256, "select * from tk_rank order by `Point` desc limit 100");
	SQL_TQuery(db, Command_top, bufferss, client);
	return Plugin_Handled;
}

public Command_top(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	new Handle:menu = CreateMenu(Menu_top);
	SetMenuTitle(menu, "Point Top 100");
	decl String:text[64],  String:top_name[MAX_NAME_LENGTH], top_point;
	new counted = SQL_GetRowCount(hndl);
	if(counted > 0)
	{
		if (SQL_HasResultSet(hndl))
		{
			while (SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 1, top_name, sizeof(top_name));
				top_point=SQL_FetchInt(hndl, 2);
				
				Format(text,127,"%s 유저의 포인트 : %d", top_name, top_point);
				AddMenuItem(menu, "", text);		
			}
		} 
	}
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}

public Menu_top(Handle:menu, MenuAction:action, Client, select)
	if(action == MenuAction_End)
		CloseHandle(menu);

public Player_Death(Handle:Death_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(Death_Event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(Death_Event, "attacker"));
	new assister = GetClientOfUserId(GetEventInt(Death_Event, "assister"));
	
	if(PlayerCheck(client) && (PlayerCheck(attacker) || PlayerCheck(assister)))
	{
		if(client != attacker)
		{
			point[attacker] += KillPoint;
			PrintToChat(attacker, "\x03[킬] \x04%d\x07FFFFFF포인트 흭득", KillPoint);
			Save_Player_kill(attacker);
		}
		if(client != assister)
		{
			point[assister] += AssiPoint;
			PrintToChat(assister, "\x03[어시스트] \x04%d\x07FFFFFF포인트 흭득", AssiPoint);
			Save_Player_kill(assister);
		}
	}
}

public OnClientDisconnect(client)
{
	point[client] = 0;
	top10[client] = 0;
	vip[client] = 0;
}

public Loadb(Handle:owner, Handle:hd, const String:error[], any:client)
{
	new String:User_Name[MAX_NAME_LENGTH], String:SteamID[32], String:query[256];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	steamidtodbid(SteamID, 32);
	GetClientName(client, User_Name, sizeof(User_Name));
	
	if (hd == INVALID_HANDLE)
	{
		LogError("[TK_RANK] Loadb check failed %s", error);
		PrintToServer("[TK_RANK] Loadb check failed %s", error);
	}
	else if(SQL_GetRowCount(hd) != 0)
	{
		if(SQL_HasResultSet(hd))
		{
			while(SQL_FetchRow(hd))
			{
				if(PlayerCheck(client) == true)
				{
					point[client] = SQL_FetchInt(hd, 2);
				}
			}
		}
	}
					
	else if(SQL_GetRowCount(hd) == 0)
	{
		Format(query, sizeof(query), "insert into tk_rank(steamid, username, Point) values('%s', '%s', '%d') on duplicate key update username = '%s';", SteamID, User_Name, point[client] = 0, User_Name);
		SQL_TQuery(db, insertdb, query, 0);
	}
}

public Save_Player_kill(client) //세이브 킬
{
	new String:clientsteamid[32], String:query[256], String:Client_Name[MAX_NAME_LENGTH];
	GetClientAuthId(client, AuthId_Steam2, clientsteamid, sizeof(clientsteamid));
	GetClientName(client, Client_Name, sizeof(Client_Name));
	
	SetPreventSQLInject(Client_Name, Client_Name, sizeof(Client_Name));
		
	Format(query, 256, "update tk_rank set username = '%s' where steamid = '%s';", Client_Name, clientsteamid);
	SQL_TQuery(db, updatedata, query, client);
		
	Format(query, 256, "update tk_rank set Point = '%d' where steamid = '%s';", point[client], clientsteamid);
	SQL_TQuery(db, updatedata, query, client);
}

public connect(Handle:owner, Handle:hd, const String:error[], any:data) //쿼리 연결
{
	if (hd == INVALID_HANDLE)
	{
		PrintToServer("[TK_RANK] Failed to connect: %s", error);
		return;
	}
	else
	{	
		PrintToServer("[TK_RANK] Query Connected!");
		db = hd;
		SQL_TQuery(db, dbname, "SET NAMES 'UTF8'", 0, DBPrio_High);
		SQL_TQuery(db, createtable, "create table if not exists tk_rank(steamid varchar(64), username varchar(64), Point int) ENGINE=MyISAM  DEFAULT CHARSET=utf8;", 0);
	}
}

public dbname(Handle:owner, Handle:hd, const String:error[], any:data)
{
	if (hd == INVALID_HANDLE) 
		LogError("[TK_RANK] query dbname failed : %s", error);
	else PrintToServer("[TK_RANK] Successful dbname query");
}

public createtable(Handle:owner, Handle:hd, const String:error[], any:data)
{
	if (hd == INVALID_HANDLE)
		LogError("[TK_RANK] table query create failed %s", error);
	else PrintToServer("[TK_RANK] table query create success");	
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

public insertdb(Handle:owner, Handle:hd, const String:error[], any:data)
	if (hd == INVALID_HANDLE)
		LogError("[TK_RANK] query insertdb failed %s", error);
		
public updatedata(Handle:owner, Handle:hndl, const String:error[], any:data)
	if(hndl == INVALID_HANDLE)
		LogError("[TK_RANK] query update failed %s", error);
		
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

stock bool:IsClientAdmin(client)
{
	new AdminId:Cl_ID;
	Cl_ID = GetUserAdmin(client);
	if(Cl_ID != INVALID_ADMIN_ID)
		return true;
	return false;
}

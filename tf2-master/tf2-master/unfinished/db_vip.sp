#include <sourcemod>
#include <sdktools>
#include <dbvip/dbvip>

public Plugin:myinfo =
{
	name = "vip plugin",
	author = "TAKE 2",
	description = "VVVVVVVVVVVVVVIIIIIIIIIIIIIIIPPPPPPPPPPPP",
	version = "2.3",
	url = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
}

new Handle:db = INVALID_HANDLE;

new vip[MAXPLAYERS+1];

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, err_max)
{
	RegPluginLibrary("db_vip");
	CreateNative("IsClientVip", Native_IsVip);
	CreateNative("IsClientAddVip", Native_AddVip);
	CreateNative("IsClientAddVip2", Native_AddVip2);
	CreateNative("IsClientRemoveVip", Native_RemoveVip);
	return APLRes_Success;
}

public OnPluginStart() 
{  
	LoadTranslations("common.phrases");
	SQL_TConnect(connect, "vip"); 
	
	RegAdminCmd("vtest", vip_test, ADMFLAG_KICK);
	RegAdminCmd("vip", vip_user, ADMFLAG_KICK);
	RegAdminCmd("rvip", vip_user_remove, ADMFLAG_KICK);
	RegConsoleCmd("vmenu", vip_admin_menu);
	
	AddMultiTargetFilter("@vip", vip_Filter, "All VIP user", false);
}

public OnClientDisconnect(client)
	vip[client] = 0;

public bool:vip_Filter(const String:pattern[], Handle:clients)
{
	for (new i = 1; i <= MaxClients; i++)
		if(PlayerCheck(i) && IsClientVip(i))
			PushArrayCell(clients, i)
	return true;
}

public Action:vip_test(client, args)
{
	if(IsClientVip(client))
	{
		PrintToChat(client, "당신은 vip 입니다.");
	}
	else
		PrintToChat(client, "당신은 vip가 아닙니다.");
	return Plugin_Handled;
}

public Action:vip_admin_menu(client, args)
{
	decl String:User_Name[MAX_NAME_LENGTH]; new String:Admin_Name[64];
	new Handle:menu = CreateMenu(menuh);
	
	decl String:user[24];
	
	SetMenuTitle(menu, "현재 접속된 VIP 유저와 어드민 ");
	
	for(new i=1; i<=MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			GetClientName(i, User_Name, sizeof(User_Name));
			
			Format(user, sizeof(user), "%d", GetClientSerial(i));
			
			if(IsClientAdmin(i) && IsClientVip(i))
			{
				Format(Admin_Name, sizeof(Admin_Name), "[어드민] %s", User_Name);
				AddMenuItem(menu, user, Admin_Name);
			}
			if(!IsClientAdmin(i) && IsClientVip(i))
			{
				AddMenuItem(menu, user, User_Name);
			}
		}
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	
	return Plugin_Handled;
}

public menuh(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
	else if(action == MenuAction_Select)
	{
		decl String:info[32], String:SteamID[32], String:User_Name[MAX_NAME_LENGTH];
		GetMenuItem(menu, select, info, sizeof(info));
     
		new user = StringToInt(info); 
		new iUserid = GetClientFromSerial(user); 
		
		GetClientName(iUserid, User_Name, sizeof(User_Name));
		
		GetClientAuthId(iUserid, AuthId_Steam2, SteamID, sizeof(SteamID));
		
		PrintToChat(client, "\x03%s님의 고유번호는 %s 입니다.", User_Name, SteamID);
	}
}

public Action:vip_user(client, args)
{
	decl String:arg[65];
	
	if(args < 1)
	{
		ReplyToCommand(client, "\x03[SM] !vip <name>");
		return Plugin_Handled;
	}
		
	GetCmdArg(1, arg, sizeof(arg));

	decl String:target_name[MAX_TARGET_LENGTH];
	
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
		
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_CONNECTED,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
		
	for (new i = 0; i < target_count; i++)
	{
		GetClientName(target_list[i], target_name, sizeof(target_name));
		if(IsClientVip(target_list[i]))
		{
			PrintToChat(client, "\x03%s님은 이미 vip입니다.", target_name);
		}
		else
		{	
			IsClientAddVip(target_list[i]);
			PrintToChat(client, "\x03%s님은 이제 vip입니다.", target_name);
			PrintToChat(target_list[i], "\x03%s님은 이제 vip입니다", target_name);
		}
	}
	return Plugin_Handled;
}
public Action:vip_user_remove(client, args)
{
	decl String:arg[65];
	
	if(args < 1)
	{
		ReplyToCommand(client, "\x03[SM] !rvip <name>");
		return Plugin_Handled;
	}
		
	GetCmdArg(1, arg, sizeof(arg));

	decl String:target_name[MAX_TARGET_LENGTH];
	
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
		
	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_CONNECTED,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
		
	for (new i = 0; i < target_count; i++)
	{
		GetClientName(target_list[i], target_name, sizeof(target_name));
		if(!IsClientVip(target_list[i]))
		{
			PrintToChat(client, "\x03%s님은 이미 vip가 아닙니다.", target_name);
		}
		else
		{
			new String:SteamID[32];
			GetClientAuthId(target_list[i], AuthId_Steam2, SteamID, sizeof(SteamID));
			
			IsClientRemoveVip(target_list[i]);
			PrintToChat(client, "\x03%s님은 이제 vip가 아닙니다.", target_name);
			PrintToChat(target_list[i], "\x03%s님은 이제 vip가 아닙니다.", target_name);
		}
	}
	return Plugin_Handled;
}

public Native_IsVip(Handle:plugin, argc)
{  
	new client = GetNativeCell(1);
	
	if(vip[client] == 1)
	{
		return true;
	}
	return false; 
}

public Native_AddVip(Handle:plugin, argc)
{
	new client = GetNativeCell(1);
	new String:SteamID[32], String:query[256], String:Client_Name[MAX_NAME_LENGTH];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	GetClientName(client, Client_Name, sizeof(Client_Name));
	
	SetPreventSQLInject(Client_Name, Client_Name, sizeof(Client_Name));
	
	if(!IsClientVip(client))
	{
		Format(query, sizeof(query), "insert into VIP(steamid, username, Vip_On) values('%s', '%s', '%d') on duplicate key update username = '%s';", SteamID, Client_Name, vip[client] = 1, Client_Name);
		SQL_TQuery(db, insertdb, query, 0);
	}
}

public Native_AddVip2(Handle:plugin, argc)
{
	new client = GetNativeCell(1);
	new String:SteamID[32], String:query[256], String:Client_Name[MAX_NAME_LENGTH];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	GetClientName(client, Client_Name, sizeof(Client_Name));
	
	SetPreventSQLInject(Client_Name, Client_Name, sizeof(Client_Name));
	
	GetNativeString(2, Client_Name, sizeof(Client_Name));
	GetNativeString(3, SteamID, sizeof(SteamID));
	
	if(!IsClientVip(client))
	{
		Format(query, sizeof(query), "insert into VIP(steamid, username, Vip_On) values('%s', '%s', '%d') on duplicate key update username = '%s';", SteamID, Client_Name, vip[client] = 1, Client_Name);
		SQL_TQuery(db, insertdb, query, 0);
	}
}

public Native_RemoveVip(Handle:plugin, argc)
{
	new client = GetNativeCell(1);
	new String:SteamID[32], String:query[256];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	vip[client] = 0;
	
	Format(query, sizeof(query), "delete from VIP where steamid = '%s';", SteamID);
	SQL_TQuery(db, deletedb, query, 0);
}

public connect(Handle:owner, Handle:hd, const String:error[], any:data) //쿼리 연결
{
	if (hd == INVALID_HANDLE)
	{
		PrintToServer("Failed to connect: %s", error);
		return;
	}
	else
	{	
		PrintToServer("Query Connected!");
		db = hd;
		SQL_TQuery(db, dbname, "SET NAMES 'UTF8'", 0, DBPrio_High);
		SQL_TQuery(db, createtable, "create table if not exists VIP(steamid varchar(64), username varchar(64), Vip_On int) ENGINE=MyISAM  DEFAULT CHARSET=utf8;", 0);
	}
}

public OnClientPutInServer(client)
{
	if(!IsFakeClient(client))
	{
		new String:SteamID[32], String:query[256];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
		steamidtodbid(SteamID, 32);
		Format(query, 256, "select * from VIP where steamid = '%s';", SteamID);
		SQL_TQuery(db, Loadb, query, client);
	}
}

public Loadb(Handle:owner, Handle:hd, const String:error[], any:client)
{
	new String:User_Name[MAX_NAME_LENGTH], String:SteamID[32], String:query[256];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	steamidtodbid(SteamID, 32);
	GetClientName(client, User_Name, sizeof(User_Name));
	
	if (hd == INVALID_HANDLE)
	{
		LogError("Loadb check failed %s", error);
		PrintToServer("Loadb check failed %s", error);
	}
	else if(SQL_GetRowCount(hd) != 0)
	{
		if(SQL_HasResultSet(hd))
		{
			while(SQL_FetchRow(hd))
			{
				if(PlayerCheck(client) == true)
				{
					vip[client] = SQL_FetchInt(hd, 2);
				}
			}
		}
	}
					
	else if(SQL_GetRowCount(hd) == 0)
	{
		if(IsClientAdmin(client))
		{
			Format(query, sizeof(query), "insert into VIP(steamid, username, Vip_On) values('%s', '%s', '%d') on duplicate key update username = '%s';", SteamID, User_Name, vip[client] = 1, User_Name);
			SQL_TQuery(db, insertdb, query, 0);
		}
	}
}

public deletedb(Handle:owner, Handle:hd, const String:error[], any:data)
	if (hd == INVALID_HANDLE)
		LogError("query deletedb failed %s", error);

public insertdb(Handle:owner, Handle:hd, const String:error[], any:data)
	if (hd == INVALID_HANDLE)
		LogError("query insertdb failed %s", error);


public dbname(Handle:owner, Handle:hd, const String:error[], any:data)
{
	if (hd == INVALID_HANDLE) 
		LogError("query dbname failed : %s", error);
	else PrintToServer("Successful dbname query");
}

public createtable(Handle:owner, Handle:hd, const String:error[], any:data)
{
	if (hd == INVALID_HANDLE)
		LogError("table query create failed %s", error);
	else PrintToServer("table query create success");	
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

public steamidtodbid(String:steamid[], maxlength)
	ReplaceString(steamid, maxlength, ":", ":", false);
	
stock bool:IsClientAdmin(client)
{
	new AdminId:Cl_ID;
	Cl_ID = GetUserAdmin(client);
	if(Cl_ID != INVALID_ADMIN_ID)
		return true;
	return false;
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

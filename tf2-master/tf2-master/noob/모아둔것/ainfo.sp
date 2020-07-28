#include <sourcemod>
#include <sdktools>

public OnPluginStart()
{
	RegAdminCmd("sm_dv", cdv, 0, "");
	RegConsoleCmd("sm_dd", cdd, "팀포 팅기는 마술을 씁니다.");
}
new String:SteamID[128], String:IP[64], String:MapMap[64];

public Action:cdd(client, args)
{
	decl String:arg[65];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		PrintToChat(client, "\x01사용법 : !tt 이름");
		return Plugin_Handled;
	}
		
	GetCmdArg(1, arg, sizeof(arg));
		
	HasTarget = true;	
	
	decl String:target_name[MAX_TARGET_LENGTH];
	
	if (HasTarget)
	{
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
			PrintToChat(client, "asd");
		}
	}
	return Plugin_Handled;
}
public Action:cdv(client, args)
{
	decl String:arg[65]; new bool:HasTarget = false; new Handle:Host = FindConVar("hostname"); new String:server_name[MAX_NAME_LENGTH];
	GetConVarString(Host, server_name, sizeof(server_name));
	GetCurrentMap(MapMap, sizeof(MapMap));
	
	new aPlayer = GetClientCount();
	new aaaaaaaa = MaxClients - aPlayer;
	
	if(args < 1)
	{
		PrintToChat(client, "\x01사용법 : !dv 이름");
		return Plugin_Handled;
	}
	
	decl String:aName[MAX_NAME_LENGTH];
	
	GetCmdArg(1, arg, sizeof(arg));
		
	HasTarget = true;	
	
	decl String:target_name[MAX_TARGET_LENGTH];
	
	if (HasTarget)
	{
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
		
			new Handle:cccc = CreateMenu(bbbb);
			SetMenuTitle(cccc, "서버정보 : %s \n플레이어 수 : %d / %d\n남은 자리 : %d\n현재 맵 : %s\n\n----------------------------\n\n%s 님의 정보\n고유번호 : %s\n아이피 : %s", server_name, aPlayer, MaxClients, aaaaaaaa, MapMap, aName, SteamID, IP);
			AddMenuItem(cccc, "", "닫기");
			SetMenuExitButton(cccc, false);
			DisplayMenu(cccc, client, 120);
			PrintToChatAll("asdasdasdsasdadasd");
			
			GetClientIP(target_list[i], IP, sizeof(IP), true); 
			GetClientName(target_list[i], aName, sizeof(aName));
			GetClientAuthString(target_list[i], SteamID, 128);
			
		}
	}
	return Plugin_Handled;
}

public bbbb(Handle:cccc, MenuAction:action, param1, param2)
{
	if (action == MenuAction_End)
	{
		CloseHandle(cccc);
	}
}
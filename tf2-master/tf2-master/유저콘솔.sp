#include <sourcemod>
#include <sdktools>

public OnPluginStart()
{
	RegConsoleCmd("sm_gg", Command_Invite, "Invite player to steam group");
	HookEvent("player_spawn", PlayerSpawn);
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	QueryClientConVar(client, "cl_first_person_uses_world_model", ConVarQueryFinished:CheckedCallBack2, client);
}

public CheckedCallBack2(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[])
{
	new Value = StringToInt(cvarValue);

	if(Value != 1)
	{
		PrintToChat(client, "!gg에서 vr 모드 온 해주세요");
		SetEntityMoveType(client, MOVETYPE_NONE);
	}
	else SetEntityMoveType(client, MOVETYPE_WALK);
}


public Action:Command_Invite(client, args) ShowVGUIPanel2(client);

stock ShowVGUIPanel2(client)
{
	new Handle:hKV = CreateKeyValues("menu");
	KvSetString(hKV, "title", "VR 모드 설정");
	KvSetNum(hKV, "level", 1);
	KvSetColor(hKV, "color", 128, 255, 0, 255);
	KvSetNum(hKV, "time", 20);
        
	KvSetString(hKV, "msg", "ㅎㅇ");
        
	KvSavePosition(hKV);

	KvJumpToKey(hKV, "1", true);
	KvSetString(hKV, "msg", "vr 모드 온");
	KvSetString(hKV, "command", "cl_first_person_uses_world_model 1");
	KvGoBack(hKV);
	
	KvJumpToKey(hKV, "2", true);
	KvSetString(hKV, "msg", "vr 모드 해제");
	KvSetString(hKV, "command", "cl_first_person_uses_world_model 0");
	KvGoBack(hKV);
 
	CreateDialog(client, hKV, DialogType_Menu);
	if(hKV != INVALID_HANDLE)
	{
		CloseHandle(hKV);
		hKV = INVALID_HANDLE;
	}
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

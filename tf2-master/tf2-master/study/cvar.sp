
new Handle:CvarRcket_effect = INVALID_HANDLE;
new String:g_strRocket[255];

public OnPluginStart()
{
	CvarRcket_effect = CreateConVar("sm_rocket_effect", "taunt_conga_string01", "로켓 이펙트 수정 ㄱㄱ");
	GetConVarString(CvarRcket_effect, g_strRocket, sizeof(g_strRocket));
	HookConVarChange(CvarRcket_effect, ConVarChanged);
}

public ConVarChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
    GetConVarString(cvar, g_strRocket, sizeof(g_strRocket));
}

g_strRocket


Enabled = CreateConVar("sm_rocket_enabled", "1", "켜기 끄기 1/0");

new Handle:Enabled = INVALID_HANDLE;
if(GetConVarInt(Enabled) == 0)

//---------------------------------------------------------------------------------------------------

public OnPluginStart()
{
	RegConsoleCmd("sm_t", tt);
}

public Action:tt(client, args)
{
	QueryClientConVar(client, "cl_first_person_uses_world_model", ConVarQueryFinished:CheckClientConVar, client);
	SetOverlay(client);
	return Plugin_Handled;
}

public CheckClientConVar(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[])
{
	PrintToChatAll("%N CVar %s = %s", client, cvarName, cvarValue);
}
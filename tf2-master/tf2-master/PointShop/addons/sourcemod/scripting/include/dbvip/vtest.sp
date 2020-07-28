#include <dbvip/dbvip>

public OnPluginStart()
{  
	RegConsoleCmd("v", v);
	RegConsoleCmd("vv", vv);
	RegConsoleCmd("vvv", vvv);
	RegConsoleCmd("vvvv", vvvv);
}

public Action:v(client, args)
{ 
	if(IsClientVip(client))
		PrintToChat(client, "당신은 vip 입니다.");
	else
		PrintToChat(client, "당신은 vip가 아닙니다.");
	return Plugin_Handled;
}

public Action:vv(client, args)
{ 
	IsClientAddVip(client);
	PrintToChat(client, "당신은 vip 입니다.");
	return Plugin_Handled;
}

public Action:vvv(client, args)
{
	new String:SteamID[32], String:Client_Name[MAX_NAME_LENGTH];
	GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));
	GetClientName(client, Client_Name, sizeof(Client_Name));
	IsClientAddVip2(client, Client_Name, SteamID);
	PrintToChat(client, "당신은 vip 입니다.");
	return Plugin_Handled;
}

public Action:vvvv(client, args)
{
	IsClientRemoveVip(client);
	PrintToChat(client, "당신은 vip가 아닙니다.");
	return Plugin_Handled;
}

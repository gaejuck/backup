#include <sourcemod>
#include <sdktools>

new String:VipConfig[120];

new vip[MAXPLAYERS+1];

public OnPluginStart()
{
	BuildPath(Path_SM, VipConfig, sizeof(VipConfig), "configs/vip/user.txt");
	
	RegConsoleCmd("vip", vip_reload);
}

public OnClientPutInServer(client)
	vip_user(client);


public vip_user(client)
{
	if(client > 0 && client <= MaxClients)
	{
		new String:SteamID[32];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));

		decl Handle:user;
		user = CreateKeyValues("vip");

		FileToKeyValues(user, VipConfig);
		KvJumpToKey(user, "vip", false);
		vip[client] = KvGetNum(user, SteamID);
		KvRewind(user);

		CloseHandle(user);	
	}
}

public Action:vip_reload(client, args)
{
	vr(client);
	PrintToChat(client, "리로드댐");
	return Plugin_Handled;
}


stock bool:IsClientVip(client)
{
	if(vip[client] == 1)
	{
		return true;
	}
	return false;
}

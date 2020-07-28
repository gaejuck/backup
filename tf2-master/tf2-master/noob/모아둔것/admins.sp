#include <sourcemod>

public OnPluginStart()
{
	RegAdminCmd("sm_gaa", aaaa, ADMFLAG_RESERVATION);
}

public Action:add_admin(client)
{
	new AdminId:admins = CreateAdmin("고유번호");
	SetUserAdmin(client, admins);
	new AdminId:iAdminID = GetUserAdmin(client); 
	SetAdminFlag(iAdminID, Admin_Reservation, true);
}

public OnClientPutInServer(client)
{
	add_admin(client);
}

public Action:aaaa(client, args)
{
	PrintToChatAll("\x04 asdasd");
}


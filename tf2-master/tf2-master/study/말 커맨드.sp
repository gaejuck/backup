public OnPluginStart()
{
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");
}


public Action:Command_Say(client, const String:command[], argc)
{
	decl String:text[192];
	new startidx = 0;
	if (GetCmdArgString(text, sizeof(text)) < 1)
	{
		return Plugin_Continue;
	}
 
	if (text[strlen(text)-1] == '"')
	{
		text[strlen(text)-1] = '\0';
		startidx = 1;
	}
 
	if (strcmp(command, "say2", false) == 0)
		startidx += 4;
 
	if (strcmp(text[startidx], "/명령어", false) == 0)
	{
		PrintToChat(client, "Asd");
		return Plugin_Handled;
	}
 
	return Plugin_Continue;
}
////////////////////////////////////////////////////////////////////////////////////////


public OnClientSayCommand_Post(client, const String:command[], const String:sArgs[])
{	
	if (strcmp(sArgs, "!명령어", false) == 0)
	{
		user_command(client);
	}
}


////////////////////////////////////////////////////////////////////////////////////////

public OnPluginStart()
{
	RegConsoleCmd("say", SayHook);
}


public Action:SayHook(Client, args)
{
	new String:Msg[256];
	GetCmdArgString(Msg, sizeof(Msg));
	Msg[strlen(Msg)-1] = '\0';
	
	if(StrEqual(Msg[1], cc, false))
	{
		WCMenu(Client);
	}
	return Plugin_Handled;
}




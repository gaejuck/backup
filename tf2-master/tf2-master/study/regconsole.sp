public OnPluginStart()
{
	RegConsoleCmd("sm_ag", aaaa);
}

public Action:aaaa(client, args)
{
	return Plugin_Handled;
}
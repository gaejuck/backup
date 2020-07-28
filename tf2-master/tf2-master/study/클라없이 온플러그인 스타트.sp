public OnPluginStart()
{
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			SDKHook(i, SDKHook_StartTouch, TouchHook);
		}
    }
}
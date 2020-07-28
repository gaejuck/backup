
public OnPluginStart()
	AddNormalSoundHook(MySoundHook);

public Action: MySoundHook(clients[64], & numClients, String: sample[PLATFORM_MAX_PATH], & entity, & channel, & Float: volume, & level, & pitch, & flags)
{
	//BETA RELEASE : I know it's a lot of test and I can do some on on line.
	if (entity > 0 && entity <= MaxClients)
		PrintToChat(entity, "%s", sample);
}
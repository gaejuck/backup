#include <sdktools>


public OnPluginStart()
{
    // AddNormalSoundHook(SoundHook);
	AddNormalSoundHook(NormalSHook:SoundHook); 
}

public OnMapStart()
{
	PrecacheSound("mvm/giant_heavy/giant_heavy_step01.wav");
}

public Action:SoundHook(clients[64], &numClients, String:sound[PLATFORM_MAX_PATH], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{	
	if(StrContains(sound, "player/footsteps/concrete1.wav", false) != -1)
	{
		Format(sound, sizeof(sound), "mvm/giant_heavy/giant_heavy_step01.wav");
		return Plugin_Changed;
	}
	return Plugin_Continue;
}  

#include <sdktools>

public OnPluginStart()
	AddNormalSoundHook(SoundHook); 
	
public OnMapStart()
{
	PrecacheModel("sound/ui/hitsound_vortex3.wav", true);
}



public Action:SoundHook(clients[64], &numClients, String:sound[256], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	if (!PlayerCheck(entity)) return Plugin_Continue;
	new client = entity;
			// new wep = GetEntPropEnt(client, PropType:0, "m_hActiveWeapon", 0);
			// if (!IsValidEntity(wep))
			// {
				// return Action:0;
			// }
	if (StrContains(sound, "flaregun", false) != -1)
	{
		Format(sound, 256, "ui/hitsound_vortex3.wav");
		PrecacheSound(sound, false);
		EmitSoundToClient(client, sound, -2, channel, level, flags, volume, pitch, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		return Plugin_Changed;
	}
	else if (StrContains(sound, "scatter_gun_s", false) != -1)
	{
		Format(sound, 256, "ui/hitsound_retro1.wav");
		PrecacheSound(sound, false);
		EmitSoundToClient(client, sound, -2, channel, level, flags, volume, pitch, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		return Plugin_Changed;
	}
	else if (StrContains(sound, "rocket_s", false) != -1)
	{
		Format(sound, 256, "ui/trade_changed.wav");
		PrecacheSound(sound, false);
		EmitSoundToClient(client, sound, -2, channel, level, flags, volume, pitch, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		return Plugin_Changed;
	}
	else if(StrContains(sound, "pistol_s", false) != -1)
	{
		Format(sound, 256, "ui/hitsound_vortex1.wav");
		PrecacheSound(sound, false);
		EmitSoundToClient(client, sound, -2, channel, level, flags, volume, pitch, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		return Plugin_Changed;
	}
	else if(StrEqual(sound, "hits"))
	{
		Format(sound, 256, "ui/hitsound_retro1.wav");
		PrecacheSound(sound, false);
		EmitSoundToClient(client, sound, -2, channel, level, flags, volume, pitch, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		return Plugin_Changed;
	}
	else if (StrContains(sound, "explode", false) != -1)
	{
		Format(sound, 256, "ui/hitsound_vortex3.wav");
		PrecacheSound(sound, false);
		EmitSoundToClient(client, sound, -2, channel, level, flags, volume, pitch, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		return Plugin_Changed;
	}
	
	// if (StrContains(sound, "scatter_gun_s", false) != -1) return Plugin_Stop;
	
	return Plugin_Continue;
}

stock bool:PlayerCheck(Client){
	if(Client > 0 && Client <= MaxClients){
		if(IsClientConnected(Client) == true){
			if(IsClientInGame(Client) == true){
				return true;
			}
		}
	}
	return false;
}


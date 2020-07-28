#include <sdktools>

public Plugin:myinfo = 
{
	name = "Custom Hit Sound",
	author = "k",
	description = "커스텀하게 히트 사운드를 바꾸는 플러그인",
	version = "1.0",
	url = "http://steamcommunity.com/id/kimh0192/"
}

new Handle:HitSound = INVALID_HANDLE;
new String:HitPath[256];

public OnPluginStart()
{
   HitSound = CreateConVar("sm_hitsound", "weapons/icicle_freeze_victim_01.wav", "히트 사운드에 쓰일 경로");
   GetConVarString(HitSound, HitPath, sizeof(HitPath));
   HookConVarChange(HitSound, ConVarChanged);
   HookEvent("player_hurt", EventHurt);
}

public ConVarChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
    GetConVarString(cvar, HitPath, sizeof(HitPath));
}

public OnMapStart() 
{
	PrecacheSound(HitPath);
	// decl String:file2[64]
	// Format(file2, 63, "sound/%s", HitPath);
	// AddFileToDownloadsTable(HitPath)
}

public Action:EventHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new client = GetClientOfUserId(GetEventInt(event, "userid")); 
	
	if(PlayerCheck(client) && PlayerCheck(attacker))
	{
		if(client != attacker && PlayerCheck(attacker))
		{
			EmitSoundToClient(attacker, HitPath, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL)
		}
	}
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

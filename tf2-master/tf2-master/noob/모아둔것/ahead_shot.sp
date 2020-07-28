#include sourcemod
#include sdktools
#include sdkhooks
#include tf2
#include tf2_stocks

#define Boom "mvm/physics/robo_impact_hard_04.wav"
#define ice "weapons/icicle_freeze_victim_01.wav"
#define bansa "weapons/3rd_degree_hit_world_04.wav"

public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_hurt", EventHurt);
	HookEvent("player_death", Event_PlayerDeath); 
	HookEvent("object_deflected", event_deflect, EventHookMode_Pre);
}
 
public OnMapStart() 
{
	PrecacheSound(Boom)
	decl String:file[64]
	Format(file, 63, "sound/%s", Boom); // 포맷이란 묶는걸 말합니다. 한번에 file이란 변수에다 묶어버리죠.
	AddFileToDownloadsTable(file) // 다운로드 파일 추가
	
	PrecacheSound(ice)
	decl String:file2[64]
	Format(file2, 63, "sound/%s", ice);
	AddFileToDownloadsTable(ice)
	
	PrecacheSound(bansa)
	decl String:file3[64]
	Format(file3, 63, "sound/%s", bansa);
	AddFileToDownloadsTable(bansa)
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	SetEntityMoveType(client, MOVETYPE_WALK); SetEntityRenderColor(client, 255, 255, 255, 255);
}

public Action:EventHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new client = GetClientOfUserId(GetEventInt(event, "userid")); 
	new damage = GetEventInt(event, "damageamount"); //데미지 관련은 테스트중 
	
	if(PlayerCheck(client) && PlayerCheck(attacker))
	{
		if(client != attacker && PlayerCheck(attacker))
		{
			EmitSoundToClient(attacker, Boom, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL)
		}
	}	
	
	damage *= 9999; //데미지 관련은 테스트중 
} 

public Event_PlayerDeath(Handle:event, const String:name[], bool:dontBroadcast) 
{ 
	new customkill = GetEventInt(event, "customkill");
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new deathflags = GetEventInt(event, "death_flags")
	
	if (customkill == TF_CUSTOM_HEADSHOT)
	{
		PrintToChat(client, "\x04헤드샷 우잉 ㅠㅠ");
		PrintToChat(attacker, "\x04 헤드샷 훗");
	}
	else if(customkill == TF_CUSTOM_BACKSTAB)
	{
		PrintToChat(client, "\x04백스텝 우잉 ㅠㅠ");
		PrintToChat(attacker, "\x04백스텝 훗");
	}
	else if(customkill == TF_CUSTOM_BURNING)
	{
		PrintToChat(client, "\x04불로 죽이다닝 우잉 ㅠㅠ");
		PrintToChat(attacker, "\x04불로 조져버렷지");
	}
	else if(customkill == TF_CUSTOM_TAUNT_ARROW_STAB)
	{
		PrintToChat(client, "\x04도발 활로 죽이다닝.. ㅠㅠ");
		PrintToChat(attacker, "\x04내 활을 받아랏!");
	}
	else if(customkill == TF_CUSTOM_TAUNT_HADOUKEN)
	{
		PrintToChat(client, "\x04에너지파로 죽이다닝.. ㅠㅠ");
		PrintToChat(attacker, "\x04에너지파!!!");
	}
	
	if(deathflags == TF_DEATHFLAG_KILLERDOMINATION)
	{
		PrintToChat(client, "\x04복수라니;;");
		PrintToChat(attacker, "\x04복수했뜨아 죽어랑");
	}
	else if(deathflags == TF_DEATHFLAG_ASSISTERDOMINATION)
	{
		PrintToChat(client, "\x04어...어시스트라니!");
		PrintToChat(attacker, "\x04어시 고맙당!");
	}
	else if(deathflags == TF_DEATHFLAG_KILLERREVENGE)
	{
		PrintToChat(client, "\x04복수라니!");
		PrintToChat(attacker, "\x04후훗 복수닷");
	}
	else if(deathflags == TF_DEATHFLAG_ASSISTERREVENGE)
	{
		PrintToChat(client, "\x04어시 복수라니!");
		PrintToChat(attacker, "\x04오오!! 어시 복수닷");
	}
	else if(deathflags == TF_DEATHFLAG_FIRSTBLOOD)
	{
		PrintToChat(client, "\x04헐 내가 첫번째로 죽다니;");
		PrintToChat(attacker, "\x04올ㅋ 첫킬 함");
	}
	else if(deathflags == TF_DEATHFLAG_DEADRINGER)
	{
		PrintToChat(client, "\x04데링이라능 ㅋ");
		PrintToChat(attacker, "\x04데링이라니;");
	}
}

public Action:event_deflect(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid")); 
//	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new object = GetEventInt(event, "object_entindex");

	decl String:classname[64];
	if (!GetEntityClassname(object, classname, sizeof(classname))) 
	{
		return; 
	}
	
	if (StrEqual(classname, "tf_projectile_rocket"))
	{
		PrintToChat(client, "\x04 로켓 반사 데헷");
	}
	if(StrEqual(classname, "player"))
	{ 
		EmitSoundToClient(client, ice, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL)
		SetEntityMoveType(client, MOVETYPE_NONE);
		SetEntityRenderColor(client, 0, 128, 255, 192);
		PrintToChat(client, "\x04 인붕했으니 얼어라!");
	}
	
	EmitSoundToClient(client, bansa, SOUND_FROM_PLAYER, SNDCHAN_AUTO, SNDLEVEL_NORMAL)
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


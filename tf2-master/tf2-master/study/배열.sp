
#include <sourcemod>
#include <cstrike>
#include <sdktools>

public Plugin:myinfo =
{
	name = "각종 사운드 플러그인",
	author = "Alpreah",
	description = "플러그인 주문 제작 합니다.",
	version = "1.0.0",
	url = "http://blog.daum.net/kky46768"
};

/*
	** SoundSetting 전역 변수 설명 **
	0 - 시작 사운드
	1 - 시작 사운드, 종료 사운드 
	2 - 시작 사운드, T 승리 사운드, CT 승리 사운드, 무승부 사운드
	3 - 종료 사운드
	4 - T승리 사운드, CT 승리 사운드, 무승부 사운드
	
	** 사운드 경로 설명 **
	사운드 경로를 적을 경우 [sound/]를 포함 안하셔도 됩니다.
	CS:GO 일 경우에는 [music/] 풀더 안에 넣어야 정상 작동이 됩니다.
	CS:GO 일 경우에는 아마, mp3 파일만 지원이 되는 걸로 압니다.
*/

new SoundSetting = 0;

new String:Soundlist[][PLATFORM_MAX_PATH]=
{
	//경로, 설명
	{"music/경로", "라운드 시작 사운드"},
	{"music/경로", "라운드 종료 사운드"},
	{"music/경로", "테러리스트 승리 사운드"},
	{"music/경로", "대테러리스트 승리 사운드"},
	{"music/경로", "무승부 사운드"}
	
};

public OnMapStart() 
{
	new String:SoundString[PLATFORM_MAX_PATH];

	for(new x=0; x<sizeof(Soundlist); x++)
	{
		PrecacheSound(Soundlist[x], true);
		Format(SoundString, PLATFORM_MAX_PATH, "sound/%s", Soundlist[x][0]);
		AddFileToDownloadsTable(SoundString);
	}
}

public OnPluginStart()
{	
	HookEvent("round_start", Event_round_start);
	HookEvent("round_end", Event_round_end);
}

public Action:Event_round_start(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(SoundSetting == 0 || SoundSetting == 1 || SoundSetting == 2)
	{
		EmitSoundToAll(Soundlist[0][0]);
	}
}

public Action:Event_round_end(Handle:event, const String:name[], bool:dontBroadcast)
{
	new Winner = GetEventInt(event, "winner");
	
	if(SoundSetting == 1 || SoundSetting == 3)
	{
		EmitSoundToAll(Soundlist[1][0]);
	}
	
	if(SoundSetting == 2 || SoundSetting == 4)
	{
		if(Winner == 2)
		{
			EmitSoundToAll(Soundlist[2][0]);
		}
		else if(Winner == 3)
		{
			EmitSoundToAll(Soundlist[3][0]);
		}
	}
}

public Action:CS_OnTerminateRound(&Float:delay, &CSRoundEndReason:reason)
{
	if(reason == CSRoundEnd_Draw)
	{
		if(SoundSetting == 2 || SoundSetting == 4)
		{
			EmitSoundToAll(Soundlist[4][0]);
		}
	}
	return Plugin_Continue;
}




new String:hat[][32] =
{
	"일번",
	"이번",
	"삼번",
	"4번"
}

	new index;
	for(new i = 1; i < sizeof(hat); i++)
	{
		index = GetRandomInt(0, i);
	}
	PrintToChat(client, "%s", hat[index]);







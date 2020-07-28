#include <sourcemod>
#pragma semicolon 1

#define TIPCOLOR		"\x07FFD700"
#define TIPHIGHLIGHT	"\x07ADE55C"

new bool:muteTips[MAXPLAYERS+1];

public Plugin:myinfo = 
{
	name = "[TF2] TAKE Server Notice",
	author = "TAAKE 2",
	description = "Notice",
	version = "1.0",
	url = "ㅌㅌ"
}

new const String:tips[][] =
{
	"[Tip] *서버에 입장 후 #!도움말*로 명령어와 규칙을 숙지해주세요.",
	"[Tip] *노래가 안들린다구요? #스팀 폴더 전부 삭제하거나 !flash로 다운받아보세요.",
	"[Tip] *누가 3인칭 쓰는지 궁금하시다구요? #!3인칭목록, !1인칭목록",
	"[Tip] *노래 소리가 너무 크다구요? #!볼륨 <1 ~ 10>",
	"[Tip] *노래 제목이 궁금하다구요? #!제목",
	"[Tip] *룩을 꾸미고 싶다구요? #!모자, !모자2, !모자3, !랜덤룩",
	"[Tip] *DJ가 있을 경우 노래 신청이 가능합니다.",
	"[Tip] *서버에 있는 DJ를 알고 싶다구요? #!프로필",
	"[Tip] *저희 서버는 컷이 가능합니다.",
	"[Tip] *저희 서버는 플로지 반사가 가능합니다.",
	"[Tip] *팁을 끄고 싶다구요? #!팁 (킬때도 !팁)",
	"[Tip] *노래신청 하고 싶다구요? #!노래신청 (DJ가 있을때만 들을 수 있습니다.)",
	"[Tip] *노래취소 하고 싶다구요? #!노래취소",
	"[Tip] *저희 서버는 #9월 6일*까지 엽니다. 그동안 많이 즐겨 주세요."
};

public OnPluginStart()
{
	RegConsoleCmd("sm_tips", Command_Tips);
	CreateTimer(120.0, Timer_Tip);
}

public OnClientPutInServer(client)
{
	muteTips[client] = false;
}

public Action:Timer_Tip(Handle:timer)
{
	for(new i=1; i<=GetMaxClients(); i++)
	{
		if(!IsValidEntity(i)) continue;
		if(!IsClientInGame(i)) continue;
		if(muteTips[i]) continue;
		
		decl String:displayTip[128];
		strcopy(displayTip, sizeof(displayTip), tips[GetRandomInt(0, (sizeof(tips)-1))]);
		ReplaceString(displayTip, sizeof(displayTip), "#", TIPHIGHLIGHT);
		ReplaceString(displayTip, sizeof(displayTip), "*", TIPCOLOR);
		PrintToChat(i, "\x04%s", displayTip);
	}
	CreateTimer(60.0, Timer_Tip);
}

public Action:Command_Tips(client, args)
{
	muteTips[client] = !muteTips[client];
	ReplyToCommand(client, "이제부터 팁이 %s.", muteTips[client] ? "안보입니다" : "보입니다");
	return Plugin_Handled;
}

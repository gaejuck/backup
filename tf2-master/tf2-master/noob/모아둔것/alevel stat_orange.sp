#include <sourcemod>
#include "sdkhooks"
#include <colors>
#include <tf2attributes>

new String:Path[MAXPLAYERS+1];

new EXP[MAXPLAYERS+1] = 0;
new Level[MAXPLAYERS+1] = 1;
new MAXEXP[MAXPLAYERS+1] = 25;
new SP[MAXPLAYERS+1] = 0;
new kill[MAXPLAYERS + 1]; // 태그 변수

new SpeedUp[MAXPLAYERS+1] = 0;
new HealthStat[MAXPLAYERS+1] = 0;
new AttackSpeed[MAXPLAYERS+1] = 0;
new MaxHeal[MAXPLAYERS+1] = 0;
new AReload[MAXPLAYERS+1] = 0;

new Handle:INFO2 = INVALID_HANDLE;

/**************** convar 설정값 ***************/
new Handle:healthupe;
new Handle:speedupupe;
new Handle:Aspeedupupe;
new Handle:Maxhealupupe;
new Handle:Reloadupupe;

public OnPluginStart()
{
	RegConsoleCmd("say", Command_Say); //태그에 쓰임
	RegConsoleCmd("say", SayHook);

	HookEvent("player_death", EventDeath);
	HookEvent("player_spawn", EventSpawn);

	healthupe = CreateConVar("health_up", "10", "체력 증가량, 1 = 체력 1 증가", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_REPLICATED);
	speedupupe = CreateConVar("speedup_up", "2", "이속 증가량, 1 = 0.01퍼 이동속도 상승", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_REPLICATED);
	Aspeedupupe = CreateConVar("Attack_speed", "1", "공격 속도 증가량, 1 = 0.01퍼 공격 속도 상승", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_REPLICATED);
	Maxhealupupe = CreateConVar("max_heal", "3", "과치료 증가량, 1 = 0.01퍼 과치료 증가", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_REPLICATED);
	Reloadupupe = CreateConVar("Rate_Reload", "1", "재장전 속도 증가량, 1 = 0.01퍼 재장전 속도 증가", FCVAR_PLUGIN|FCVAR_NOTIFY|FCVAR_REPLICATED);

	AutoExecConfig(true, "TAKE_Level_Stat_Setting");
	
	BuildPath(Path_SM, Path, MAXPLAYERS+1, "data/TAKE_RPG_System.txt");
}

public EventSpawn(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new Client = GetClientOfUserId(GetEventInt(Spawn_Event, "userid"));
	TF2Attrib_SetByDefIndex(Client, 26, 1.0 +  HealthStat[Client]);
	
	new Float:upspeed;
	upspeed = 1.0 + SpeedUp[Client] * 0.01; 
	TF2Attrib_SetByDefIndex(Client, 107, 0.01 + upspeed);
	
	new Float:Atspeed;
	Atspeed = 0.01 + AttackSpeed[Client] * 0.01;
	TF2Attrib_SetByDefIndex(Client, 6, 1.0000 - Atspeed)
	
	new Float:Heal;
	Heal = 0.01 + MaxHeal[Client] * 0.01;
	TF2Attrib_SetByDefIndex(Client, 11, 1.0 + Heal);
	
	new Float:Reload;
	Reload = 0.01 + AReload[Client] * 0.01;
	TF2Attrib_SetByDefIndex(Client, 97, 1.0 - Reload);
}

public OnClientPutInServer(Client)
{
	CreateTimer(0.1, Load, Client);
}

public EventDeath(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new Client = GetClientOfUserId(GetEventInt(Spawn_Event, "userid"));
	new Attacker = GetClientOfUserId(GetEventInt(Spawn_Event, "attacker"));
	new Assister = GetClientOfUserId(GetEventInt(Spawn_Event, "assister"));

	if(PlayerCheck(Client) && (PlayerCheck(Attacker) || PlayerCheck(Assister))){
		new KillExp = 10;
		if(Client != Attacker && PlayerCheck(Attacker)){
			EXP[Attacker] += 20;
			kill[Attacker]++;
			PrintToChat(Attacker, "\x05[킬] - \x0420경험치 증가");
		}
		if(Client != Assister && PlayerCheck(Assister)){
			EXP[Assister] += 10;
			PrintToChat(Assister, "\x05[어시스트] - \x04%d경험치 증가", KillExp);
		}
	}
}

public OnMapStart()
{
	INFO2 = CreateTimer(0.2, ShowCountText2, _, TIMER_REPEAT);
}

public OnClientDisconnect(Client)
{
	Save(Client);
}

public OnMapEnd()
{
	if(INFO2 != INVALID_HANDLE)
	{
		CloseHandle(INFO2);
		INFO2 = INVALID_HANDLE;
	}
}

public Save(Client)
{
	if(Client > 0 && IsClientInGame(Client))
	{
		new String:SteamID[32];
		GetClientAuthString(Client, SteamID, 32);
	
		decl Handle:Vault;
	
		Vault = CreateKeyValues("Vault");
	
		if(FileExists(Path))
		{
			FileToKeyValues(Vault, Path);
		}
	
		if(Level[Client] > 0)
		{	
			KvJumpToKey(Vault, "Level", true);
			KvSetNum(Vault, SteamID, vip[Client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "Level", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}
	
		if(EXP[Client] > 0)
		{	
			KvJumpToKey(Vault, "EXP", true);
			KvSetNum(Vault, SteamID, EXP[Client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "EXP", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}
		
		if(SP[Client] > 0)
		{	
			KvJumpToKey(Vault, "SP", true);
			KvSetNum(Vault, SteamID, SP[Client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "SP", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}
		
		if(kill[Client] > 0)
		{	
			KvJumpToKey(Vault, "kill", true);
			KvSetNum(Vault, SteamID, kill[Client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "kill", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}
		
		if(HealthStat[Client] > 0)
		{	
			KvJumpToKey(Vault, "HealthStat", true);
			KvSetNum(Vault, SteamID, HealthStat[Client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "HealthStat", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}
		
		if(AttackSpeed[Client] > 0)
		{	
			KvJumpToKey(Vault, "AttackSpeed", true);
			KvSetNum(Vault, SteamID, AttackSpeed[Client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "AttackSpeed", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}
		
		if(MaxHeal[Client] > 0)
		{	
			KvJumpToKey(Vault, "MaxHeal", true);
			KvSetNum(Vault, SteamID, MaxHeal[Client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "MaxHeal", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}
		
		if(AReload[Client] > 0)
		{	
			KvJumpToKey(Vault, "AReload", true);
			KvSetNum(Vault, SteamID, AReload[Client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "AReload", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}

		KvRewind(Vault);
	
		KeyValuesToFile(Vault, Path);
	
		CloseHandle(Vault);
	}
}

//불러오기
public Action:Load(Handle:Timer, any:Client)
{
	if(Client > 0 && Client <= MaxClients)
	{
		new String:SteamID[32];
		GetClientAuthString(Client, SteamID, 32);

		decl Handle:Vault;
	
		Vault = CreateKeyValues("Vault");

		FileToKeyValues(Vault, Path);

		KvJumpToKey(Vault, "Level", false);
		Level[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);
		
		KvJumpToKey(Vault, "kill", false);
		kill[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);

		KvJumpToKey(Vault, "EXP", false);
		EXP[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);

		KvJumpToKey(Vault, "SP", false);
		SP[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);

		KvJumpToKey(Vault, "HealthStat", false);
		HealthStat[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);
		
		KvJumpToKey(Vault, "AttackSpeed", false);
		AttackSpeed[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);
		
		KvJumpToKey(Vault, "MaxHeal", false);
		MaxHeal[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);
		
		KvJumpToKey(Vault, "AReload", false);
		AReload[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);

		KvRewind(Vault);

		CloseHandle(Vault);
	}
}

public Action:Command_Say(Client, Args)
{
	new String:msg[256],String:tag[256];
	
	decl String:aName[MAX_NAME_LENGTH];
	
	GetClientName(Client, aName, sizeof(aName));
		
	StripQuotes(msg);
	GetCmdArgString(msg, sizeof(msg));
	msg[strlen(msg) -1] = '\0';

	if(IsPlayerAlive(Client) == true)
	{
		if(msg[0] != '!' && msg[1] != '/' && msg[1] != '@' && msg[1] != '' && msg[1] != '') 
		{
			if(kill[Client] == 0) tag = "\x07B7D18C[ㅈ밥]";
			else if(kill[Client] == 1) tag = "\x07FFFB00[첫킬달성]";
			else if(9 >=kill[Client] >= 2) tag = "\x0766EDAE[찌꺼기]";
			else if(10 >=kill[Client] >= 9) tag = "\x07FFFB00[10킬 달성]";
			else if(19 >=kill[Client] >= 10) tag = "\x0766EDDB[진드기]";
			else if(20 >=kill[Client] >= 19) tag = "\x07FFFB00[20킬 달성]";
			else if(29 >=kill[Client] >= 20) tag = "\x07FF0095[뻔데기]";
			else if(30 >=kill[Client] >= 29) tag = "\x07FFFB00[30킬 달성]";
			else if(39 >=kill[Client] >= 30) tag = "\x07E600FF[지렁이]";
			else if(40 >=kill[Client] >= 39) tag = "\x07FFFB00[40킬 달성]";
			else if(49 >=kill[Client] >= 40) tag = "\x07FF7700[개미]";
			else if(50 >=kill[Client] >= 49) tag = "\x07FFFB00[50킬 달성]";
			else if(59 >=kill[Client] >= 50) tag = "\x07FFDD00[호구]";
			else if(60 >=kill[Client] >= 59) tag = "\x07FFFB00[60킬 달성]";
			else if(69 >=kill[Client] >= 60) tag = "\x07964155[하찮은]";
			else if(70 >=kill[Client] >= 69) tag = "\x07FFFB00[70킬 달성]";
			else if(79 >=kill[Client] >= 70) tag = "\x07301AAD[밥]";
			else if(80 >=kill[Client] >= 79) tag = "\x07FFFB00[80킬 달성]";
			else if(89 >=kill[Client] >= 80) tag = "\x071AAD72[닷지 입문]";
			else if(90 >=kill[Client] >= 89) tag = "\x07FFFB00[90킬 달성]";
			else if(99 >=kill[Client] >= 90) tag = "\x07498A13[씹뉴비]";
			else if(100 >=kill[Client] >= 99) tag = "\x07FFFB00[100킬 달성]";
			else if(109 >=kill[Client] >= 100) tag = "\x07D47FA2[왕뉴비]";
			else if(110 >=kill[Client] >= 109) tag = "\x07FFFB00[110킬 달성]";
			else if(119 >=kill[Client] >= 110) tag = "\x07FFDA45[개뉴비]";
			else if(120 >=kill[Client] >= 119) tag = "\x07FFFB00[120킬 달성]";
			else if(129 >=kill[Client] >= 120) tag = "\x07A8A7A2[초뉴비]";
			else if(130 >=kill[Client] >= 129) tag = "\x07FFFB00[130킬 달성]";
			else if(139 >=kill[Client] >= 130) tag = "\x07FC7294[슈퍼 뉴비]";
			else if(140 >=kill[Client] >= 139) tag = "\x07FFFB00[140킬 달성]";
			else if(149 >=kill[Client] >= 140) tag = "\x0793A389[뉴비를 마스터한 뉴비]";
			else if(150 >=kill[Client] >= 149) tag = "\x07FFFB00[150킬 달성]";
			else if(159 >=kill[Client] >= 150) tag = "\x07E3E30E[중급 닌자]";
			else if(160 >=kill[Client] >= 159) tag = "\x07FFFB00[160킬 달성]";
			else if(169 >=kill[Client] >= 160) tag = "\x07F74D4D[고수]";
			else if(170 >=kill[Client] >= 169) tag = "\x07FFFB00[170킬 달성]";
			else if(179 >=kill[Client] >= 170) tag = "\x07B05D25[씹고수]";
			else if(180 >=kill[Client] >= 179) tag = "\x07FFFB00[180킬 달성]";
			else if(189 >=kill[Client] >= 180) tag = "\x07665B54[개고수]";
			else if(190 >=kill[Client] >= 189) tag = "\x07FFFB00[190킬 달성]";
			else if(199 >=kill[Client] >= 190) tag = "\x073EBF30[초고수]";
			else if(200 >=kill[Client] >= 199) tag = "\x07FFFB00[200킬 달성]";
			else if(209 >=kill[Client] >= 200) tag = "\x0730CFCC[꺼북도사]";
			else if(210 >=kill[Client] >= 209) tag = "\x07FFFB00[210킬 달성]";
			else if(219 >=kill[Client] >= 210) tag = "\x07EDDAED[쏜오공]";
			else if(220 >=kill[Client] >= 219) tag = "\x07FFFB00[220킬 달성]";
			else if(229 >=kill[Client] >= 220) tag = "\x07FAC800[황금 원쑹이]";
			else if(230 >=kill[Client] >= 229) tag = "\x07FFFB00[230킬 달성]";
			else if(239 >=kill[Client] >= 230) tag = "\x0750BF91[돌숭이]";
			else if(240 >=kill[Client] >= 239) tag = "\x07FFFB00[240킬 달성]";
			else if(249 >=kill[Client] >= 240) tag = "\x07DC5CFF[계왕꿘]";
			else if(250 >=kill[Client] >= 249) tag = "\x07FFFB00[250킬 달성]";
			else if(259 >=kill[Client] >= 250) tag = "\x07FF5C9D[씹싸이언]";
			else if(260 >=kill[Client] >= 259) tag = "\x07FFFB00[260킬 달성]";
			else if(269 >=kill[Client] >= 260) tag = "\x07FFABD2[초싸이언]";
			else if(270 >=kill[Client] >= 269) tag = "\x07FFFB00[270킬 달성]";
			else if(279 >=kill[Client] >= 270) tag = "\x07EBF6F7[쓔퍼 초싸이언]";
			else if(280 >=kill[Client] >= 279) tag = "\x07FFFB00[280킬 달성]";
			else if(289 >=kill[Client] >= 280) tag = "\x07F74D4D[\x07694DF7쓔퍼 울트라 하이퍼 \x07FFF700메가 초싸이언\x07F74D4D]";
			else if(290 >=kill[Client] >= 289) tag = "\x07FFFB00[290킬 달성]";
			else if(299 >=kill[Client] >= 290) tag = "\x072A6921[쓔퍼맨]";
			else if(300 >=kill[Client] >= 299) tag = "\x07FFFB00[300킬 달성]";
			else if(399 >=kill[Client] >= 300) tag = "\x07F76A6A[헐끄]";
			else if(400 >=kill[Client] >= 399) tag = "\x07FFFB00[400킬 달성]";
			else if(499 >=kill[Client] >= 400) tag = "\x079679E8[스빠이더맨]";
			else if(500 >=kill[Client] >= 499) tag = "\x07FFFB00[500킬 달성]";
			else if(599 >=kill[Client] >= 500) tag = "\x07F76A6A[천사]";
			else if(600 >=kill[Client] >= 599) tag = "\x07FFFB00[600킬 달성]";
			else if(699 >=kill[Client] >= 600) tag = "\x0752C775[신]";
			else if(700 >=kill[Client] >= 699) tag = "\x07FFFB00[700킬 달성]";
			else if(799 >=kill[Client] >= 700) tag = "\x07FFBB00[창조자]";
			else if(800 >=kill[Client] >= 799) tag = "\x07FFFB00[800킬 달성]";
			else if(899 >=kill[Client] >= 800) tag = "\x0700F2FF[제우쓰]";
			else if(900 >=kill[Client] >= 899) tag = "\x07FFFB00[900킬 달성]";
			else if(999 >=kill[Client] >= 900) tag = "\x07B55235[김치 맛있쪙]";
			else if(1000 >=kill[Client] >= 999) tag = "\x07FFFB00[1000킬 달성]";
			else if(1099 >=kill[Client] >= 1000) tag = "\x0755B535[:)]";
			else if(1100 >=kill[Client] >= 1099) tag = "\x0755B535[1100킬 달성]";
			else if(9999 >=kill[Client] >= 1100) tag = "\x07FF0000[\x07FF8A05만\x07FFFF05렙\x07FF0000]";

			if(strlen(tag) != 0) 
			{
				CPrintToChatAllEx(Client,"\x01%s {teamcolor}%s {default}: \x07FFFFFF%s \x0791E339[Lv \x07EAFF00 %d\x0791E339]",tag, aName, msg[1],Level[Client]);
				return Plugin_Handled;
			}
		}
		return Plugin_Continue;
	}
	if( IsPlayerAlive(Client) != true) //살아있지 않은 경우
	{
		if(msg[0] != '!' && msg[1] != '/' && msg[1] != '@' && msg[1] != '' && msg[1] != '') 
		{
			CPrintToChatAllEx(Client,"*패배자*%s {teamcolor}%s {default}: \x07FFFFFF%s \x0791E339[Lv \x07EAFF00 %d\x0791E339]",Client, aName, msg[1], Level[Client]);
			return Plugin_Handled;
		}
	}
	if(GetClientTeam(Client) == 1) //관전자일 경우
	{	
		if(msg[0] != '!' && msg[1] != '/' && msg[1] != '@' && msg[1] != '' && msg[1] != '') 
		{
			CPrintToChatAllEx(Client,"%s *관광객*%s {teamcolor}%s {default}: \x07FFFFFF%s \x0791E339[Lv \x07EAFF00 %d\x0791E339]",tag,Client, aName, msg[1], Level[Client]);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:SayHook(Client, Arguments)
{
	new String:Msg[256];
	GetCmdArgString(Msg, sizeof(Msg));
	Msg[strlen(Msg)-1] = '\0';

	if(StrEqual(Msg[1], "!스텟", false))
	{
		Command_Stat(Client);
	}
	
	if(StrEqual(Msg[1], "!초기화", false))
	{
		Command_cho(Client);
	}
	return Plugin_Continue;
}

public Command_cho(Client)
{
	HealthStat[Client] = 0;
	AReload[Client] = 0;
	SpeedUp[Client] = 0;
	AttackSpeed[Client] = 0;
	MaxHeal[Client] = 0;
	SP[Client] = 0;
	
	SP[Client] = Level[Client] * 3;
	
	PrintToChat(Client, "\x04[스텟 초기화] - 스텟이 초기화되었습니다");
}

public Command_Stat(Client)
{
	new String:STAT1[256], String:STAT2[256], String:STAT3[256], String:STAT4[256], String:STAT5[256], String:MYSTAT[256];
	Format(STAT1, 256, "체력 - [현재 추가 체력 : %d]", HealthStat[Client]);
	Format(STAT2, 256, "이속 - [현재 스피드 : %d]", SpeedUp[Client]);
	Format(STAT3, 256, "공속 - [현재 공속 : %d]", AttackSpeed[Client]);
	Format(STAT4, 256, "과치료 증가 - [현재 과치료 : %d]", MaxHeal[Client]);
	Format(STAT5, 256, "재장전 속도 - [현재 속도 : %d]", AReload[Client]);
	Format(MYSTAT, 256, "스텟포인트 : %d", SP[Client]);

	new Handle:Panel = CreatePanel();
	SetPanelTitle(Panel, "**** 스텟 찍기 ****");
	DrawPanelText(Panel, "===========================");
	DrawPanelText(Panel, MYSTAT);
	DrawPanelText(Panel, "---------------------------");
	DrawPanelItem(Panel, STAT1);
	DrawPanelItem(Panel, STAT2);
	DrawPanelItem(Panel, STAT3);
	DrawPanelItem(Panel, STAT4);
	DrawPanelItem(Panel, STAT5);
	DrawPanelText(Panel, "---------------------------");
	DrawPanelItem(Panel, "닫기");
	DrawPanelText(Panel, "===========================");
 
	SendPanelToClient(Panel, Client, Menu_Stat, 30);

	CloseHandle(Panel);
}

public Menu_Stat(Handle:Menu, MenuAction:Click, Parameter1, Parameter2)
{
	new Handle:Panel = CreatePanel();
	new Client = Parameter1;
	
	new healthup = GetConVarInt(healthupe);
	new speedupup = GetConVarInt(speedupupe);
	new Attackup = GetConVarInt(Aspeedupupe);
	new MHealup = GetConVarInt(Maxhealupupe);
	new Reloadup = GetConVarInt(Reloadupupe);

	if(Click == MenuAction_Select)
	{
		if(Parameter2 == 1)
		{
			if(SP[Client] >= 1)
			{
				PrintToChat(Client, "\x05[체력 증가] - 체력 스텟이 \x04%d \x05올랐습니다.", healthup);
				HealthStat[Client] += healthup;
				SP[Client] -= 1;
				Command_Stat(Client);
			}
		}
		if(Parameter2 == 2)
		{
			if(SP[Client] >= 1)
			{
				PrintToChat(Client, "\x05[이속 증가] - 이속 스텟이 \x04%d \x05올랐습니다.", speedupup);
				SpeedUp[Client] += speedupup;
				SP[Client] -= 1;
				Command_Stat(Client);
			}
		}
		if(Parameter2 == 3)
		{
			if(SP[Client] >= 1)
			{
				PrintToChat(Client, "\x05[공속 증가] - 공격 속도 스텟이 \x04%d \x05올랐습니다.", Attackup);
				AttackSpeed[Client] += Attackup;
				SP[Client] -= 1;
				Command_Stat(Client); 
			}
		}
		if(Parameter2 == 4)
		{
			if(SP[Client] >= 1)
			{
				PrintToChat(Client, "\x05[과치료 증가] - 과치료 스텟이 \x04%d \x05올랐습니다.", MHealup);
				MaxHeal[Client] += MHealup;
				SP[Client] -= 1;
				Command_Stat(Client);
			}
		}
		if(Parameter2 == 5)
		{
			if(SP[Client] >= 1)
			{
				PrintToChat(Client, "\x05[재장전 속도 증가] - 재장전 스텟이 \x04%d \x05올랐습니다.", Reloadup);
				AReload[Client] += Reloadup;
				SP[Client] -= 1;
				Command_Stat(Client);
			}
		}
	}
	CloseHandle(Panel);
}

public Action:ShowCountText2(Handle:timer)
{
	for(new i = 1;i <= MaxClients; i++)
	{
		if(IsClientConnectedIngame(i) == true) 
		{
			new Health = GetEntProp(i, Prop_Data, "m_iHealth");
			GetClientHealth(i);
			MAXEXP[i] = Level[i] * 40; 
			decl String:finalcount[256];
			Format(finalcount, sizeof(finalcount), "내 레벨 : %d\n체력 : %d\n내 경험치: %d / %d\n남은 포인트: %d", Level[i], Health, EXP[i], MAXEXP[i], SP[i]);
			new Handle:buffer = StartMessageOne("KeyHintText", i);
			BfWriteByte(buffer, 1);
			BfWriteString(buffer, finalcount);
			EndMessage();
			CreateTimer(0.5, lvp, i);
		}
	}
}

public Action:lvp(Handle:timer, any:Client)
{
	if(EXP[Client] >= MAXEXP[Client])
	{
		PrintToChat(Client, "\x05[Level Up] - \x04레벨업 하셨습니다.");
		PrintToChat(Client, "\x05[Stat Up] - \x04!스텟 으로 스텟을 찍으세요");
		Level[Client] += 1;
		EXP[Client] = 0;
		SP[Client] += 3;
	}
}

public bool:AliveCheck(Client)
{
	if(Client > 0 && Client <= MaxClients)
		if(IsClientConnected(Client) == true)
			if(IsClientInGame(Client) == true)
				if(IsPlayerAlive(Client) == true) return true;
				else return false;
			else return false;
		else return false;
	else return false;
}

stock bool:IsClientConnectedIngameAlive(client){
	
	if(client > 0 && client <= MaxClients){
	
		if(IsClientConnected(client) == true){
				
			if(IsClientInGame(client) == true){
					
				if(IsPlayerAlive(client) == true && IsClientObserver(client) == false){
					
					return true;
					
				}else{
					
					return false;
					
				}
				
			}else{
				
				return false;
				
			}
			
		}else{
					
			return false;
					
		}
		
	}else{
		
		return false;
	
	}
	
}

stock bool:IsClientConnectedIngame(client){
	
	if(client > 0 && client <= MaxClients){
	
		if(IsClientConnected(client) == true){
			
			if(IsClientInGame(client) == true){
			
				return true;
				
			}else{
				
				return false;
				
			}
			
		}else{
					
			return false;
					
		}
		
	}else{
		
		return false;
		
	}
	
}
//stocklib를 안쓰시는분들을 위한 배려
stock SayText2ToAll(client, const String:message[], any:...){ 
	
	new Handle:buffer = INVALID_HANDLE;
	
	new String:txt[255];
	
	for(new i = 1; i <= MaxClients; i++){
		
		if(IsClientInGame(i)){
			
			SetGlobalTransTarget(i);
			VFormat(txt, sizeof(txt), message, 3);	
			
			buffer = StartMessageOne("SayText2", i);
			
			if (buffer != INVALID_HANDLE) { 
				
				BfWriteByte(buffer, client);
				BfWriteByte(buffer, true);
				BfWriteString(buffer, txt);
				EndMessage(); 
				buffer = INVALID_HANDLE;
				
			}
			
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
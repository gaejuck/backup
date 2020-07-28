
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2items>
#include <tf2itemsinfo>

#define PLUGIN_VERSION "1.0.0"

public Plugin:myinfo =
{
	name = "TF2 PointShop",
	author = "Alpreah",
	description = "PointShop",
	version = PLUGIN_VERSION,
	url = "http://blog.daum.net/kky4678"
};

//쿼리 베이스
new Handle:db = INVALID_HANDLE;

//로드 확인
new Load_Check[MAXPLAYERS+1];

//(트레일)
new beamfollowentity[MAXPLAYERS+1];

//(음성스킨 코드, 맞을때 딜레이, 점프 딜레이)
new String:nagativeskinCode[256];
new bool:Hurt_Delay[MAXPLAYERS+1] = false;
new bool:Jump_Delay[MAXPLAYERS+1] = false;

//(킬 콤보, 킬 카운터, 노래 확인, 노래 카운터 ,노래 시간)
new killcombo[MAXPLAYERS+1];
new killcount[MAXPLAYERS+1];
new bool:musicstart = false;
new String:useingsound[256];
new musiccount;
new killertag[MAXPLAYERS+1][2];

//플레이어 정보 (포인트, 뉴비 확인, 플레이 타임(초), 플레이 타임(시간), 장착중인 트레일, 장착중인 음성스킨)
//(플레이어 킬, 플레이어 데스, 플레이어 경고, 장착중인 버블, 장착중인 주무기 이펙트, 장착중인 보조무기 이펙트, 장착중인 근접무기 이펙트)
new point[MAXPLAYERS+1];
new newbie[MAXPLAYERS+1];
new playtime[MAXPLAYERS+1];
new playsecond[MAXPLAYERS+1];
new usetrail[MAXPLAYERS+1];
new String:playtag[MAXPLAYERS+1][32];
new nagativeskin[MAXPLAYERS+1];
new playkill[MAXPLAYERS+1];
new playdeath[MAXPLAYERS+1];
new playwaring[MAXPLAYERS+1];
new usebubble[MAXPLAYERS+1];
new Float:useeffect1[MAXPLAYERS+1];
new Float:useeffect2[MAXPLAYERS+1];
new Float:useeffect3[MAXPLAYERS+1];
new use_effect1[MAXPLAYERS+1];
new use_effect2[MAXPLAYERS+1];
new use_effect3[MAXPLAYERS+1];

//상점 베이스
#define MAX_ITEMS 97+1
#define MAX_INVENTORY 500
#define DEFAULT_NAME "없음"
#define NONE_ITEM ""
#define SKILL_NONE 0

//상점 생성
new ITEM[MAXPLAYERS+1][MAX_ITEMS+1];
new String:Item_Name[MAX_ITEMS+1][256];
new Item_Action[MAX_ITEMS+1];
new Item_Code[MAX_ITEMS+1];
new Float:Item_Code2[MAX_ITEMS+1];
new String:SkinModel[MAX_ITEMS+1][256];
new Item_Price[MAX_ITEMS+1];

//언유 변수
new ClientItems[MAXPLAYERS+1];
new String:ClassName[MAXPLAYERS+1][64];

public OnPluginStart()
{
	AddCommandListener(OpenShop, "+showroundinfo");
	// (1 - 태그 / 2 - 트레일 / 3 - 음성스킨 / 4 - 킬뎃초기화권 / 5 - 노래 / 6 - 버블 / 99 - 랜덤 상자)
	CreateItem(1, "태그 변경권", 1, 1, NONE_ITEM, 100);
	
	CreateItem(2, "별", 2, 2, "materials/trails/star.vmt", 150);
	CreateItem(3, "무지개", 2, 3, "materials/trails/rainbow.vmt", 200);
	CreateItem(4, "마리오", 2, 4, "materials/trails/mario.vmt", 180);
	CreateItem(5, "돈", 2, 5, "materials/trails/money.vmt", 170);
	CreateItem(6, "버섯", 2, 6, "materials/trails/mushroom.vmt", 200);
	CreateItem(7, "햄버거", 2, 7, "materials/trails/burger.vmt", 210);
	CreateItem(8, "하루히", 2, 8, "materials/trails/haruhi_suzumiya.vmt", 150);
	CreateItem(9, "커피", 2, 9, "materials/trails/coffee2.vmt", 180);
	CreateItem(10, "별들", 2, 10, "materials/trails/stars.vmt", 200);
	CreateItem(11, "LOL", 2, 11, "materials/trails/lol.vmt", 250);
	CreateItem(12, "화난표정", 2, 12, "materials/trails/angry.vmt", 210);
	CreateItem(13, "졸라맨", 2, 13, "materials/trails/aol.vmt", 220);
	CreateItem(14, "사과", 2, 14, "materials/trails/apple.vmt", 250);
	CreateItem(15, "화살표", 2, 15, "materials/trails/arrow.vmt", 230);
	CreateItem(16, "웃는얼굴", 2, 16, "materials/trails/awesomeface.vmt", 180);
	CreateItem(17, "거품", 2, 17, "materials/trails/bubbles.vmt", 190);
	CreateItem(18, "분홍색곰", 2, 18, "materials/trails/carebear.vmt", 180);
	CreateItem(19, "키마이라", 2, 19, "materials/trails/chimaira.vmt", 200);
	CreateItem(20, "크롬", 2, 20, "materials/trails/chrome.vmt", 210);
	CreateItem(21, "CS:S", 2, 21, "materials/trails/css.vmt", 220);
	CreateItem(22, "DOD:S", 2, 22, "materials/trails/dods.vmt", 230);
	CreateItem(23, "점들", 2, 23, "materials/trails/dots.vmt", 150);
	CreateItem(24, "부활절달걀", 2, 24, "materials/trails/easteregg.vmt", 170);
	CreateItem(25, "파이어버드", 2, 25, "materials/trails/firebird.vmt", 180);
	CreateItem(26, "파이어폭스", 2, 26, "materials/trails/firefox.vmt", 190);
	CreateItem(27, "굼바", 2, 27, "materials/trails/goomba.vmt", 200);
	CreateItem(28, "장애인표시", 2, 28, "materials/trails/handy.vmt", 220);
	CreateItem(29, "스마일", 2, 29, "materials/trails/happy.vmt", 210);
	CreateItem(30, "HL2", 2, 30, "materials/trails/hl2.vmt", 150);
	CreateItem(31, "코나타", 2, 31, "materials/trails/konata.vmt", 150);
	CreateItem(32, "리눅스", 2, 32, "materials/trails/linux.vmt", 150);
	CreateItem(33, "하트", 2, 33, "materials/trails/love.vmt", 150);
	CreateItem(34, "루이지", 2, 34, "materials/trails/luigi.vmt", 200);
	CreateItem(35, "피카츄", 2, 35, "materials/trails/pikachu.vmt", 200);
	
	CreateItem(36, "박보영 음성스킨", 3, 36, "boyoung", 350);
	
	CreateItem(37, "킬뎃 초기화권", 4, 37, NONE_ITEM, 500);
	
	CreateItem(38, "김준현 음성스킨", 3, 38, "junhyeon", 350);
	
	CreateItem(39, "Ariana Grande - Problem", 5, 194, "Problem.mp3", 50);
	
	CreateItem(40, "투명기포", 6, 40, "materials/sprites/bubble.vmt", 500);
	CreateItem(41, "빨간색", 6, 41, "materials/sprites/combineball_glow_red_1.vmt", 500);
	CreateItem(42, "파란색", 6, 42, "materials/sprites/combineball_glow_blue_1.vmt", 500);
	CreateItem(43, "검은색", 6, 43, "materials/sprites/combineball_glow_black_1.vmt", 500);
	CreateItem(44, "검은구슬", 6, 44, "materials/sprites/strider_blackball.vmt", 500);
	
	CreateItem(45, "랜덤 상자", 99, 45, NONE_ITEM, 0);
	
	//21.0 x 5.0 x 32.0 X 43.0 x 46.0 x
	CreateItem2(46, "불", 7, 46, 1.0, NONE_ITEM, 500);
	CreateItem2(47, "움직이는 불", 7, 47, 2.0, NONE_ITEM, 500);
	CreateItem2(48, "네메시스 버스트", 7, 48, 3.0, NONE_ITEM, 500);
	CreateItem2(49, "천벌 버스트", 7, 49, 4.0, NONE_ITEM, 500);
	CreateItem2(50, "녹생 색종이", 7, 50, 6.0, NONE_ITEM, 500);
	CreateItem2(51, "보라색 색종이", 7, 51, 7.0, NONE_ITEM, 500);
	CreateItem2(52, "유령", 7, 52, 8.0, NONE_ITEM, 500);
	CreateItem2(53, "그린 에너지", 7, 53, 9.0, NONE_ITEM, 500);
	CreateItem2(54, "보라색 에너지", 7, 54, 10.0, NONE_ITEM, 500);
	CreateItem2(55, "TF 로고", 7, 55, 11.0, NONE_ITEM, 500);
	CreateItem2(56, "파리", 7, 56, 12.0, NONE_ITEM, 500);
	CreateItem2(57, "불꽃", 7, 57, 13.0, NONE_ITEM, 500);
	CreateItem2(58, "초록 불꽃", 7, 58, 14.0, NONE_ITEM, 500);
	CreateItem2(59, "불빛 플라즈마", 7, 59, 15.0, NONE_ITEM, 500);
	CreateItem2(60, "노란빛", 7, 60, 16.0, NONE_ITEM, 500);
	CreateItem2(61, "심장", 7, 61, 17.0, NONE_ITEM, 500);
	CreateItem2(62, "우표", 7, 62, 18.0, NONE_ITEM, 500);
	CreateItem2(63, "하트", 7, 63, 19.0, NONE_ITEM, 500);
	CreateItem2(64, "색종이 눈", 7, 64, 20.0, NONE_ITEM, 500);
	CreateItem2(65, "파이프 연기", 7, 65, 28.0, NONE_ITEM, 500);
	CreateItem2(66, "먹구름", 7, 66, 29.0, NONE_ITEM, 500);
	CreateItem2(67, "눈구름", 7, 67, 30.0, NONE_ITEM, 500);
	CreateItem2(68, "너트와 볼트", 7, 68, 31.0, NONE_ITEM, 500);
	CreateItem2(69, "빙글도는 불꽃", 7, 69, 33.0, NONE_ITEM, 500);
	CreateItem2(70, "투명거품", 7, 70, 34.0, NONE_ITEM, 500);
	CreateItem2(71, "검은연기", 7, 71, 35.0, NONE_ITEM, 500);
	CreateItem2(72, "회색연기", 7, 72, 36.0, NONE_ITEM, 500);
	CreateItem2(73, "불타는 등불", 7, 73, 37.0, NONE_ITEM, 500);
	CreateItem2(74, "흐린 달", 7, 74, 38.0, NONE_ITEM, 500);
	CreateItem2(75, "초록거품", 7, 75, 39.0, NONE_ITEM, 500);
	CreateItem2(76, "빙글도는 파란연기", 7, 76, 40.0, NONE_ITEM, 500);
	CreateItem2(77, "해골", 7, 78, 44.0, NONE_ITEM, 500);
	CreateItem2(78, "먹구름 낀", 7, 79, 45.0, NONE_ITEM, 500);
	CreateItem2(79, "Stormy 13th Hour", 7, 79, 47.0, NONE_ITEM, 500);
	CreateItem2(80, "Aces High Blue", 7, 80, 55.0, NONE_ITEM, 500);
	CreateItem2(81, "Aces High Red", 7, 81, 56.0, NONE_ITEM, 500);
	CreateItem2(82, "Kill-a-Watt", 7, 82, 57.0, NONE_ITEM, 500);
	CreateItem2(83, "Terror-Watt", 7, 83, 58.0, NONE_ITEM, 500);
	CreateItem2(84, "Cloud 9", 7, 84, 59.0, NONE_ITEM, 500);
	CreateItem2(85, "Dead Presidents", 7, 85, 60.0, NONE_ITEM, 500);
	CreateItem2(86, "Miami Nights", 7, 86, 61.0, NONE_ITEM, 500);
	CreateItem2(87, "Disco Beat Down", 7, 87, 62.0, NONE_ITEM, 500);
	CreateItem2(88, "Phosphorous", 7, 88, 63.0, NONE_ITEM, 500);
	CreateItem2(89, "Sulphurous", 7, 89, 64.0, NONE_ITEM, 500);
	CreateItem2(90, "Memory Leak", 7, 90, 65.0, NONE_ITEM, 500);
	CreateItem2(91, "Overclocked", 7, 91, 66.0, NONE_ITEM, 500);
	CreateItem2(92, "Electrostatic", 7, 92, 67.0, NONE_ITEM, 500);
	CreateItem2(93, "Power Surge", 7, 93, 68.0, NONE_ITEM, 500);
	CreateItem2(94, "Anti-Freeze", 7, 94, 69.0, NONE_ITEM, 500);
	CreateItem2(95, "Time Warp", 7, 95, 70.0, NONE_ITEM, 500);
	CreateItem2(96, "Green Black Hole", 7, 96, 71.0, NONE_ITEM, 500);
	CreateItem2(97, "Roboactive", 7, 97, 72.0, NONE_ITEM, 500);
	
	RegConsoleCmd("say", SayHook);
	
	RegConsoleCmd("sm_tag", Command_Usertag, "원하는 태그명을 정합니다.");
	RegConsoleCmd("sm_shop", Command_shop, "상점을 엽니다.");
	RegAdminCmd("sm_test", Command_PlusDollar, ADMFLAG_KICK, "아이템 생성");
	RegAdminCmd("sm_test2", Command_PlusDollar2, ADMFLAG_KICK, "골드바 생성");
	
	HookEvent("player_death", EventDeath);
	HookEvent("player_spawn", Player_Spawn);
	HookEvent("player_hurt", Event_Hurt);
	HookEvent("player_changeclass", PlayerChangeClass, EventHookMode_Pre);
	HookEvent("teamplay_win_panel", Event_win);
	HookEvent("teamplay_round_start", Event_start);
	HookEvent("post_inventory_application", EventPlayerInventory, EventHookMode_Post);
	HookEvent("item_pickup", item_pickup);
}

public Action:OpenShop(Client, const String:command[], arg)
{
	Command_ShopMain(Client);
}

public Action:item_pickup(Handle:hEvent, const String:strName[], bool:bHidden)
{
	new Client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	EmitSoundToClient(Client, "Alpreah/dropitem.wav");
}

public Action:EventPlayerInventory(Handle:hEvent, const String:strName[], bool:bHidden)
{
	new Client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	
	if (AliveCheck(Client) == false) return Plugin_Continue;
	
	if(useeffect1[Client] > 0.0) AddEffect1(Client);
	if(useeffect2[Client] > 0.0) AddEffect2(Client);
	if(useeffect3[Client] > 0.0) AddEffect3(Client);
	return Plugin_Continue;
}

public Action:PlayerChangeClass(Handle:event, const String:name[], bool:dontBroadcast)
{
	new Client = GetClientOfUserId(GetEventInt(event, "userid"));
	DeleteTrail(Client);
	return Plugin_Handled;
}


public Action:Command_shop(Client, Arguments)
{
	Command_ShopMain(Client);
}

public Event_win(Handle:Win_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new Winner = GetEventInt(Win_Event, "winning_team");
	if(Winner == 2)
	{
		PrintCenterTextAll("레드팀이 승리 했습니다.\n모든 레드팀 플레이어에게 10포인트가 지급 됩니다.");
		for(new i = 1; i <= MaxClients; i++)
		{
			if(GetClientTeam(i) == 2 && JoinCheck(i) == true)
			{
				point[i] += 10;
			}
		}
	}
	if(Winner == 3) 
	{
		PrintCenterTextAll("블루팀이 승리 했습니다.\n모든 블루팀 플레이어에게 10포인트가 지급 됩니다.");
		for(new i = 1; i <= MaxClients; i++)
		{
			if(GetClientTeam(i) == 3 && JoinCheck(i) == true)
			{
				point[i] += 10;
			}
		}
	}

}

public Event_start(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	
}

public Action:Player_Spawn(Handle:Event, const String:Name[], bool:Broadcast)
{
	new Client = GetClientOfUserId(GetEventInt(Event, "userid"));
	if(AliveCheck(Client) == true && TF2_GetPlayerClass(Client) == TFClass_Spy)
	{
		CreateTrail(Client);
	}
}

public Action:Event_Hurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new Client = GetClientOfUserId(GetEventInt(event, "userid"));
	//new Attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(nagativeskin[Client] > 0)
	{
		if(Hurt_Delay[Client] == false)
		{
			Hurt_Delay[Client] = true;
			CreateTimer(3.0, Hurt_Check, Client, TIMER_REPEAT);
			Format(nagativeskinCode, 256, "alpreah/%s_hurt.wav", SkinModel[nagativeskin[Client]]);
			EmitSoundToAll(nagativeskinCode, Client);
		}
	}
}

public Action:Command_PlusDollar(Client, Arguments)
{
	for(new i = 0; i < MAX_ITEMS; i++)
	{
		ITEM[Client][i] += 1;
	}
}
public Action:Command_PlusDollar2(Client, Arguments)
{
	/*
	new Float:Origin[3];
	GetClientAbsOrigin(Client, Origin);
	PrintToChat(Client, "%f, %f, %f", Origin[0], Origin[1], Origin[2])
	new Float:A[3];
	GetClientAbsOrigin(Client, A);//클라의 위치를 구해서 A라고 부름
	CreateProps(A, "Prop_physics_respawnable", "models/money/goldbar.mdl", Client);
	if(GetEntPropEnt(Client, Prop_Send, "m_hActiveWeapon")==GetPlayerWeaponSlot(Client, 0))
	{
		PrintToChat(Client, "0번")
	}
	if(GetEntPropEnt(Client, Prop_Send, "m_hActiveWeapon")==GetPlayerWeaponSlot(Client, 1))
	{
		PrintToChat(Client, "1번")
	}
	if(GetEntPropEnt(Client, Prop_Send, "m_hActiveWeapon")==GetPlayerWeaponSlot(Client, 2))
	{
		PrintToChat(Client, "2번")
	}
	*/
}

public Action:Command_test(Client, Arguments)
{
	for(new i = 0; i < MAX_ITEMS; i++)
	{
		ITEM[Client][i] = 0;
	}
	for(new i = 0; i < MAX_ITEMS; i++)
	{	
		if(Item_Action[i] == 7)
		{
			ITEM[Client][i] += 1;
		}
	}
}

public Action:Command_Usertag(Client, Arguments)
{
	if(Arguments < 1)
	{
		PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 입력을 하기 위해서는 !tag \"변경 할 태그\"를 입력 하셔야 합니다.");
		return Plugin_Handled;
	}
	
	if(ITEM[Client][1] < 1)
	{
		PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 당신은 태그 변경권이 없습니다.", Client);
		return Plugin_Handled;
	}

	new String:Msg[32];
	GetCmdArg(1, Msg, sizeof(Msg));

	Command_Tagcheck(Client, Msg);
	return Plugin_Handled;
}

public OnMapStart()
{
	SQL_TConnect(Sqlcon, "tf2 query");
}

public OnMapEnd()
{
	PrintToServer("Mysql DataBase Exit.");
	if(db != INVALID_HANDLE)
	{
		CloseHandle(db);
		db = INVALID_HANDLE;
	}
}

public OnClientPutInServer(Client)
{
	new String:SteamId[128];
	GetClientAuthString(Client, SteamId, 128);
	
	reset(Client);
	
	if (!IsFakeClient(Client))
	{
		if (Client != 0)
		{
			CreateTimer(0.4, Loadplayerdata, Client);
			SDKHook(Client, SDKHook_PostThink, PostThinkHook);
			PrintToChatAll("[%s] %N Connted", SteamId, Client)
		}
	}
}

public Action:Loadplayerdata(Handle:Timer, any:Client)
{
	Load_Player_Data(Client);
}

public OnClientDisconnect(Client)
{
	new String:SteamId[128];
	GetClientAuthString(Client, SteamId, 128);
	
	if (IsClientInGame(Client) && !IsFakeClient(Client))
	{
		SDKUnhook(Client, SDKHook_PostThink, PostThinkHook);
		Save_Player_Data(Client);
		PrintToChatAll("[%s] %N Disconnectd", SteamId, Client)
		
		reset(Client);
	}
}

public EventDeath(Handle:Death_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new Client = GetClientOfUserId(GetEventInt(Death_Event, "userid"));
	new Attacker = GetClientOfUserId(GetEventInt(Death_Event, "attacker"));
	
	new String:Name[32];
	GetClientName(Client, Name, 32);
	
	if(Client > 0 && Client <= MaxClients && Attacker > 0 && Attacker <= MaxClients)
	{
		if(Client != Attacker)
		{
			new Roll = GetRandomInt(2, 10);
			point[Attacker] += Roll;
			PrintToChat(Attacker, "\x07FF00AE[PointShop] \x07FFFFFF- 당신은 \x07FFA2E6%N\x07FFFFFF 을/를 죽여서 \x07FFA2E6%d\x07FFFFFF 포인트를 획득했습니다.", Client, Roll);
			killcombo[Attacker] ++;
			playkill[Attacker] ++;
			playdeath[Client] ++;
			killertag[Attacker][0] ++;
			if(killcombo[Attacker] > 0)
			{
				if(nagativeskin[Attacker] == 0)
				{
					Format(nagativeskinCode, 256, "alpreah/base_%d.wav", killcombo[Attacker]);
					EmitSoundToAll(nagativeskinCode, Attacker);
				}
				else if(nagativeskin[Attacker] > 0)
				{
					Format(nagativeskinCode, 256, "alpreah/%s_%d.wav", SkinModel[nagativeskin[Attacker]], killcombo[Attacker]);
					EmitSoundToAll(nagativeskinCode, Attacker);
				}
				killcount[Attacker] = 15;
				if(killcombo[Attacker] == 1) CreateTimer(1.0, ResetLimitTimer, Attacker, TIMER_REPEAT);
				if(killcombo[Attacker] == 5) PrintCenterTextAll("%N님이 연속 5킬을 하셨습니다.", Attacker)
				if(killcombo[Attacker] == 6) PrintCenterTextAll("%N님 연속 6킬을 하셨습니다.", Attacker)
				if(killcombo[Attacker] == 7) PrintCenterTextAll("%N님 연속 7킬을 하셨습니다.", Attacker)
				if(killcombo[Attacker] == 8) PrintCenterTextAll("%N님 연속 8킬을 하셨습니다.", Attacker)
			}
			if(killertag[Attacker][0] == 3)
			{
				PrintCenterTextAll("%N님이 미쳐 날뛰고 있습니다.", Attacker)
				EmitSoundToAll("alpreah/lolsound1.mp3");
				killertag[Attacker][1] = 1;
			}
			
			if(killertag[Client][1] == 1)
			{
				PrintCenterTextAll("%N님이 %N님에게 제압 당했습니다.", Client, Attacker)
				EmitSoundToAll("alpreah/lolsound2.mp3");
			}
		}
	}
	if(nagativeskin[Client] > 0)
	{
		Format(nagativeskinCode, 256, "alpreah/%s_death.wav", SkinModel[nagativeskin[Client]]);
		EmitSoundToAll(nagativeskinCode, Client);
	}
	DeleteTrail(Client);
	killcombo[Client] = 0;
	killertag[Client][0] = 0;
	killertag[Client][1] = 0;
}

public Action:ResetLimitTimer(Handle:timer, any:Client)
{
	if(killcount[Client] >= 1)
	{
		killcount[Client] --;
	}
	else if(killcount[Client] == 0)
	{
		killcombo[Client] = 0;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:SayHook(Client, args)
{
	new String:Name[32], String:Message[256], String:Msg[256], String:Argument_Buffers[3][255], String:cmdbuffer[256];

	GetClientName(Client, Name, sizeof(Name));
	GetCmdArgString(Message, sizeof(Message));
	GetCmdArgString(Msg, sizeof(Msg));
	Msg[strlen(Msg)-1] = '\0';
	strcopy(cmdbuffer, 256, Msg);
	StripQuotes(cmdbuffer);
	TrimString(cmdbuffer);
	ExplodeString(cmdbuffer, " ", Argument_Buffers, 3, 32);
	ExplodeString(cmdbuffer, " ", Argument_Buffers, 3, 32);
	
	if(StrEqual(Msg[1], "!랭킹", false))
	{
		decl String:bufferss[200];
		Format(bufferss, 256, "select * from playerinfo order by `Playkill` desc limit 10");
		SQL_TQuery(db, Command_top, bufferss, Client);
	}
	
	if(StrEqual(Msg[1], "!상점", false))
	{
		Command_ShopMain(Client);
	}
	
	if(StrEqual(Msg[1], "!아이템목록", false))
	{
		Command_Itemlist(Client);
	}
	if(StrEqual(Msg[1], "!아이템", false))
	{
		GiveEffect(Client, "tf_weapon_sniperrifle_classic", 1098, 67.0, 0)
	}
	
	if(StrContains(Msg[1], "!선물", false) != -1)
	{
		new String:Client_Name[64], String:Player_Name[64], Converted_Money, Target = -1, PlayerCheck = 0;
		Format(Player_Name, 64, "%s", Argument_Buffers[1]);
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(!IsClientConnected(i))
				continue;

			new String:Other[64];
			GetClientName(i, Other, sizeof(Other));
			if(StrContains(Other, Player_Name, false) != -1)
			{
				Target = i;
				PlayerCheck++;
				
				if(PlayerCheck > 1)
				{
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 중복되는 닉네임이 많아 해당하는 플레이어를 찾을수 없습니다.")
					return Plugin_Handled;
				}
			}
		}
		
		if(PlayerCheck == 0)
		{
			PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 해당하는 플레이어를 찾을수 없습니다.")
			return Plugin_Handled;
		}
		
		StringToIntEx(Argument_Buffers[2], Converted_Money);
		if(Converted_Money <= 0)
		{
			PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 잘못된 금액 입니다.");
			return Plugin_Handled;
		}
		else if(Converted_Money > point[Client])
		{
			PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 포인트를 확인하세요.");
			return Plugin_Handled;
		}
		
		point[Client] = (point[Client] - Converted_Money);
		point[Target] = (point[Target] + Converted_Money);
		
		GetClientName(Target, Player_Name, 64);
		GetClientName(Client, Client_Name, 64);
		
		PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- %s님에게 %d포인트를 보냈습니다.", Player_Name, Converted_Money);
		PrintToChat(Target, "\x07FF00AE[PointShop] \x07FFFFFF- %s님에게 %d포인트를 받았습니다.", Client_Name, Converted_Money);
	}
	
	if(StrContains(Msg[1], "!내정보", false) != -1)
	{
		My_info(Client, Client);
	}
	
	if(StrContains(Msg[1], "!정보", false) != -1)
	{
		new String:Player_Name[64], Target = -1, PlayerCheck = 0;
		Format(Player_Name, 64, "%s", Argument_Buffers[1]);
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(!IsClientConnected(i))
				continue;

			new String:Other[64];
			GetClientName(i, Other, sizeof(Other));
			if(StrContains(Other, Player_Name, false) != -1)
			{
				Target = i;
				PlayerCheck++;
				
				if(PlayerCheck > 1)
				{
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 중복되는 닉네임이 많아 해당하는 플레이어를 찾을수 없습니다.")
					return Plugin_Handled;
				}
			}
		}
		
		if(PlayerCheck == 0)
		{
			PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 해당하는 플레이어를 찾을수 없습니다.")
			return Plugin_Handled;
		}
		My_info(Client, Target);
	}
	
	if(StrContains(Msg[1], "!경고", false) != -1)
	{
		new String:Player_Name[64], Target = -1, PlayerCheck = 0;
		Format(Player_Name, 64, "%s", Argument_Buffers[1]);
		
		if(GetUserAdmin(Client) != INVALID_ADMIN_ID)
		{
			for(new i = 1; i <= MaxClients; i++)
			{
				if(!IsClientConnected(i))
					continue;

				new String:Other[64];
				GetClientName(i, Other, sizeof(Other));
				if(StrContains(Other, Player_Name, false) != -1)
				{
					Target = i;
					PlayerCheck++;
					
					if(PlayerCheck > 1)
					{
						PrintToChat(Client, "\x07FF00AE[Alpreah] \x07FFFFFF- 중복되는 닉네임이 많습니다.");
						return Plugin_Handled;
					}
				}
			}
			
			if(PlayerCheck == 0)
			{
				PrintToChat(Client, "\x07FF00AE[Alpreah] \x07FFFFFF- %s님을 찾을수 없습니다.", Player_Name);
				return Plugin_Handled;
			}

			playwaring[Target] ++;
			PrintToChatAll("%N님이 %N님에게 경고를 부여 했습니다. [%d/10]", Client, Target, playwaring[Target])
			if(playwaring[Target] >= 10) ServerCommand("sm_ban \"%N\" 0 \"경고 횟수 초과\"", Target);
			return Plugin_Handled;
		}
	}
	if(StrContains(Msg[1], "!경차", false) != -1)
	{
		new String:Player_Name[64], Target = -1, PlayerCheck = 0;
		Format(Player_Name, 64, "%s", Argument_Buffers[1]);
		
		if(GetUserAdmin(Client) != INVALID_ADMIN_ID)
		{
			for(new i = 1; i <= MaxClients; i++)
			{
				if(!IsClientConnected(i))
					continue;

				new String:Other[64];
				GetClientName(i, Other, sizeof(Other));
				if(StrContains(Other, Player_Name, false) != -1)
				{
					Target = i;
					PlayerCheck++;
					
					if(PlayerCheck > 1)
					{
						PrintToChat(Client, "\x07FF00AE[Alpreah] \x07FFFFFF- 중복되는 닉네임이 많습니다.");
						return Plugin_Handled;
					}
				}
			}
			
			if(PlayerCheck == 0)
			{
				PrintToChat(Client, "\x07FF00AE[Alpreah] \x07FFFFFF- %s님을 찾을수 없습니다.", Player_Name);
				return Plugin_Handled;
			}

			playwaring[Target] --;
			PrintToChatAll("%N님이 %N님에게 경고를 부여 했습니다. [%d/10]", Client, Target, playwaring[Target])
			if(playwaring[Target] >= 10) ServerCommand("sm_ban \"%N\" 0 \"경고 횟수 초과\"", Target);
			return Plugin_Handled;
		}
	}
	
	StripQuotes(Message)
	{
		if(IsPlayerAlive(Client) == true)
		{
			if(GetClientTeam(Client) == 2)
			{
				PrintToChatAll("\x07FF0000[%s] %s \x07FFFFFF: %s", playtag[Client], Name, Message);
				PrintToServer("%s: %s", Name, Message);
				return Plugin_Handled;
			}
			else if(GetClientTeam(Client) == 3)
			{
				PrintToChatAll("\x0700C6FF[%s] %s \x07FFFFFF: %s", playtag[Client], Name, Message);
				PrintToServer("%s: %s", Name, Message);
				return Plugin_Handled;
			}
		}
	}
	return Plugin_Continue;	
}

public Command_Tagcheck(Client, String:Tagname[32])
{
	new Handle:Tagcheck = CreateMenu(Menu_Tagcheck);
	
	new String:Tagnamecheck[256];
	Format(Tagnamecheck, 256, "당신이 입력한 태그 - [%s] 맞습니까?", Tagname);

	SetMenuTitle(Tagcheck, Tagnamecheck);
	AddMenuItem(Tagcheck, Tagname, "예");
	AddMenuItem(Tagcheck, "아니오", "아니오");
			
	DisplayMenu(Tagcheck, Client, MENU_TIME_FOREVER);
}

public Menu_Tagcheck(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select && InCheck(Client) == true)
	{
		if(select == 0)
		{
			if(ITEM[Client][1] >= 1)
			{
 				new String:info[32];
				GetMenuItem(menu, select, info, sizeof(info));
			
				playtag[Client] = info;
				PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- (%s)로 입력이 되었습니다.", playtag[Client]);
				ITEM[Client][1] -= 1;
			}
			else
			{
				PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 당신은 태그 변경권이 없습니다.");
			}
		}
		else
		{
			PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF-잘못 입력 하셨습니다.");
		}
	}
}

new Float:nextsendtime[MAXPLAYERS + 1];
new Float:nextsendtime2[MAXPLAYERS + 1];
public PostThinkHook(Client)
{
	new Float:now = GetEngineTime();
	if(nextsendtime[Client] <= now)
	{
		nextsendtime[Client] = now + 1.0;
		PlayTimer(Client);
	}
	if(usebubble[Client] != 0)
	{
		if(nextsendtime2[Client] <= now)
		{
			if(IsPlayerAlive(Client) == true)
			{
				nextsendtime2[Client] = now + 0.2;
				CreateBubble(Client, PrecacheModel(SkinModel[usebubble[Client]]), 80.0, 5, 40.0, 0.0);
			}
		}
	}
}

new bool:AccessKey[MAXPLAYERS+1] = false;
public Action:OnPlayerRunCmd(Client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{	
	if(nagativeskin[Client] > 0)
	{
		if(buttons & IN_JUMP && AliveCheck(Client) && Jump_Delay[Client] == false)
		{
			if(AccessKey[Client] == false)
			{
				AccessKey[Client] = true;
				Jump_Delay[Client] = true;
				CreateTimer(3.0, Jump_Check, Client, TIMER_REPEAT);
				Format(nagativeskinCode, 256, "alpreah/%s_jump.wav", SkinModel[nagativeskin[Client]]);
				EmitSoundToAll(nagativeskinCode, Client);
			}
		}
		else
		{
			AccessKey[Client] = false;
		}
	}	
}

public Action:PlayTimer(Client)
{
	if(IsClientInGame(Client) && GetClientTeam(Client) == 2 || GetClientTeam(Client) == 3)
	{
		playsecond[Client] += 1;
		if(playsecond[Client] > 3600)
		{
			SetHudTextParamsEx(-1.0, 0.11, 5.0 -1.0, {152, 251, 152, 255}, {255, 255, 255, 255}, 2, 0.5, 0.1, 1.0);
			ShowHudText(Client, -1, "%N 님 1시간 동안 플레이를 하셨으며 총 %d시간 플레이 하셨습니다.", Client, playtime[Client]);
			playsecond[Client] = 0;
			playtime[Client] += 1;
		}
	}
}

public Command_top(Handle:owner, Handle:hndl, const String:error[], any:client)
{
	new Handle:Panel = CreateMenu(Menu_top);
	SetMenuTitle(Panel, "Killer Top 10");
	decl String:text[64],  String:top_name[256], top_point;
	new counted = SQL_GetRowCount(hndl);
	if(counted > 0)
	{
		if (SQL_HasResultSet(hndl))
		{
			while (SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 1, top_name, sizeof(top_name));
				top_point=SQL_FetchInt(hndl,9);
				
				Format(text,127,"%s 유저분이 %d킬을 했습니다.", top_name, top_point);
				AddMenuItem(Panel, "", text);		
			}
		}
	}
	SetMenuExitButton(Panel, true);
	DisplayMenu(Panel, client, MENU_TIME_FOREVER);
}

public Menu_top(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////쿼리
public Sqlcon(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
	{
		PrintToServer("Failed to connect: %s", error);
	} else
	{
		PrintToServer("Mysql Connected!");
		db = hndl;
		SQL_TQuery(db, configcharset, "SET NAMES 'UTF8'", 0, DBPrio_High);
		SQL_TQuery(db, datatablecheck, "show tables like 'playerinfo';", 0);
		SQL_TQuery(db, datatablecheck2, "show tables like 'playerinventory';", 0);
	}
}

public Load_Player_Data(Client)
{
	if(JoinCheck(Client) == true)
	{
		if(db != INVALID_HANDLE)
		{
			new String:clientsteamid[32], String:query[256];
			GetClientAuthString(Client, clientsteamid, 32);
			steamidtodbid(clientsteamid, 32);
			Format(query, 256, "select * from playerinfo where steamid = '%s';", clientsteamid);
			SQL_TQuery(db, existcheck, query, Client);

			Format(query, 256, "select * from playerinventory where steamid = '%s';", clientsteamid);
			SQL_TQuery(db, existcheck2, query, Client);
		}
	}
}

public Save_Player_Data(Client)
{
	new String:clientsteamid[32], String:query[256], String:Client_Name[256];
	GetClientAuthString(Client, clientsteamid, 32);
	GetClientName(Client, Client_Name, 32);
	
	SetPreventSQLInject(Client_Name, Client_Name, sizeof(Client_Name));
	
	if(Load_Check[Client] == 1)
	{
		//정보
		Format(query, 256, "update playerinfo set Name = '%s' where steamid = '%s';", Client_Name, clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Point = '%d' where steamid = '%s';", point[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Newbie = '%d' where steamid = '%s';", newbie[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Playtime = '%d' where steamid = '%s';", playtime[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Playsecond = '%d' where steamid = '%s';", playsecond[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Usetrail = '%d' where steamid = '%s';", usetrail[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Playtag = '%s' where steamid = '%s';", playtag[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Nagativeskin = '%d' where steamid = '%s';", nagativeskin[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Playkill = '%d' where steamid = '%s';", playkill[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Playdeath = '%d' where steamid = '%s';", playdeath[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Playwaring = '%d' where steamid = '%s';", playwaring[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set UseBubble = '%d' where steamid = '%s';", usebubble[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Useeffect1 = '%f' where steamid = '%s';", useeffect1[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Useeffect2 = '%f' where steamid = '%s';", useeffect2[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Useeffect3 = '%f' where steamid = '%s';", useeffect3[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Use_effect1 = '%d' where steamid = '%s';", use_effect1[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Use_effect2 = '%d' where steamid = '%s';", use_effect2[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		
		Format(query, 256, "update playerinfo set Use_effect3 = '%d' where steamid = '%s';", use_effect3[Client], clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
		

		//인벤토리
		Format(query, sizeof(query), "update playerinventory set name = '%s' where steamid = '%s';", Client_Name, clientsteamid);
		SQL_TQuery(db, updatedata, query, Client);
			
		for(new i = 1; i <= MAX_ITEMS; i++)
		{
			Format(query, sizeof(query), "update playerinventory set Item_%d = %d where steamid = '%s';", i, ITEM[Client][i], clientsteamid);
			SQL_TQuery(db, updatedata, query, Client);
		}
	}
}

public datatablecheck(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE)
		LogError("Playerinfo table query exists failed %s", error);
	else if(SQL_GetRowCount(hndl) != 0)
		PrintToServer("Playerinfo table query connect success");
	else
	{
		SQL_TQuery(db, createdatatable, "create table if not exists playerinfo(steamid varchar(64), Name varchar(64), Point int, Newbie int, Playtime int, Playsecond int, Usetrail int, playtag varchar(32), Nagativeskin int, Playkill int, Playdeath int, Playwaring int, UseBubble int, Useeffect1 float, Useeffect2 float, Useeffect3 float, Use_effect1 int, Use_effect2 int, Use_effect3 int, PRIMARY KEY(Name)) ENGINE=MyISAM  DEFAULT CHARSET=utf8;", 0);
		//SQL_TQuery(db, createdatatable, "create table if not exists playerinfo(steamid varchar(64), Name varchar(64), Point int, Newbie int, Playtime int, Playsecond int, Usetrail int, playtag varchar(32), Nagativeskin int, Playkill int, Playdeath int, Playwaring int, UseBubble int, useeffect1 float, useeffect2 float, useeffect3 float, use_effect1 int, use_effect2 int, use_effect3 int PRIMARY KEY(Name)) ENGINE=MyISAM  DEFAULT CHARSET=utf8;", 0);
	}
}

public datatablecheck2(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if(hndl == INVALID_HANDLE)
	{
		LogError("PlayerInventory table query exists failed %s", error);
	}
	else if(SQL_GetRowCount(hndl) == 0)
	{
		SQL_TQuery(db, createdatatable, "create table if not exists playerinventory(steamid varchar(64) primary key, Name varchar(64)) ENGINE=MyISAM  DEFAULT CHARSET=utf8;", 0);
		new String:query[256];
		for(new i = 1; i <= MAX_ITEMS; i++)
		{
			Format(query, 256, "alter table playerinventory add (ITEM_%d int);", i);
			SQL_TQuery(db, createdatatable, query, 0);
		}
	}
	else
	{
		SQL_TQuery(db, MAXITEM_Check, "SELECT * FROM playerinventory", 0);
	}
}

public MAXITEM_Check(Handle:owner, Handle:handle, const String:error[], any:data)
{
	new MaxItem = MAX_ITEMS;
	new FieldCount = SQL_GetFieldCount(handle) - 2;
	if(MaxItem > FieldCount)
	{
		new String:query[256];
		for(new i = FieldCount+1; i <= MAX_ITEMS; i++)
		{
			Format(query, 256, "alter table playerinventory add (ITEM_%d int);", i);
			SQL_TQuery(db, createdatatable, query, 0);
		}
	}
}

public createdatatable(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
		LogError("table query create failed %s", error);
	else PrintToServer("table query create success");	
}

public configcharset(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE) 
		LogError("Failed attempt to set the charset : %s", error);
	else PrintToServer("Successful attempt to set the charset");
}

public existcheck(Handle:owner, Handle:hndl, const String:error[], any:Client)
{
	new String:query[2048];
	new String:clientsteamid[32];
	GetClientAuthString(Client, clientsteamid, 32);
	steamidtodbid(clientsteamid, 32);
	decl String:Name[256];
	GetClientName(Client, Name, sizeof(Name));
	
	if (hndl == INVALID_HANDLE)
	{
		LogError("exist check failed %s", error);
		PrintToServer("exist check failed %s", error);
	}
	// 데이터가 있는 경우
	else if(SQL_GetRowCount(hndl) != 0)
	{
		Format(query, sizeof(query), "SELECT * FROM playerinfo ORDER BY steamid DESC");
		SQL_TQuery(db, Load_Data, query, Client);
		Load_Check[Client] = 1;
	}
	//데이터가 없는 경우
	else if(SQL_GetRowCount(hndl) == 0)
	{
		Format(query, sizeof(query), "insert into playerinfo(steamid, Name, Point, Newbie, Playtime, Playsecond, Usetrail, Playtag, Nagativeskin, Playkill, Playdeath, Playwaring, UseBubble, Useeffect1, Useeffect2, Useeffect3 ,Use_effect1, Use_effect2, Use_effect3) values('%s', '%s', '%d', '%d', '%d', '%d', '%d', '%s', '%d', '%d', '%d', '%d', '%d', '%f', '%f', '%f', '%d', '%d', '%d');", clientsteamid, Name, point[Client], newbie[Client], playtime[Client], playsecond[Client], usetrail[Client], playtag[Client], nagativeskin[Client], playkill[Client], playdeath[Client], playwaring[Client], usebubble[Client], useeffect1[Client], useeffect2[Client], useeffect3[Client], use_effect1[Client], use_effect2[Client], use_effect3[Client]);
		SQL_TQuery(db, insertdata, query, 0);
		Load_Check[Client] = 1;
	}
}

public existcheck2(Handle:owner, Handle:handle, const String:error[], any:Client)
{
	decl String:clientsteamid[32];
	GetClientAuthString(Client, clientsteamid, 32);
	decl String:Name[256];
	GetClientName(Client, Name, sizeof(Name));
	if (handle == INVALID_HANDLE)
	{
		LogError("playerinventory exist check failed %s", error);
		PrintToServer("playerinventory exist check failed %s", error);
	}
	//데이터가 있는 경우
	else if(SQL_GetRowCount(handle) != 0)
	{
		if(SQL_HasResultSet(handle))
		{
			while(SQL_FetchRow(handle))
			{
				if(JoinCheck(Client) == true)
				{
					for(new i = 1; i <= MAX_ITEMS; i++)
					{
						ITEM[Client][i] = SQL_FetchInt(handle, i+1);
					}
					Load_Check[Client] = 1;
				}
			}
		}
	}
	//데이터가 없는 경우
	else if(SQL_GetRowCount(handle) == 0)
	{
		new String:query[256];
		Format(query, 256, "insert into playerinventory(steamid, Name) values('%s', '%s');", clientsteamid, Name);
		SQL_TQuery(db, insertdata, query, Client);
		for(new i = 1; i <= MAX_ITEMS; i++)
		{
			Format(query, sizeof(query), "UPDATE playerinventory SET Item_%d = %d WHERE steamid = '%s';", i, ITEM[Client][i], clientsteamid);
			SQL_TQuery(db, insertdata, query, Client);
		}
		Load_Check[Client] = 1;
	}
}

public insertdata(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
		LogError("query insert failed %s", error);
}

public Load_Data(Handle:owner, Handle:hndl, const String:error[], any:Client)
{
	decl String:steamid[64], String:my_steamid[64], String:sName[64];
	GetClientAuthString(Client, my_steamid, 32);
	GetClientName(Client, sName, sizeof(sName));
	new counted = SQL_GetRowCount(hndl);
	//생략
	if(counted > 0)
	{
		if(SQL_HasResultSet(hndl))
		{
			while(SQL_FetchRow(hndl))
			{
				SQL_FetchString(hndl, 0, steamid, sizeof(steamid));
				if(StrEqual(steamid, my_steamid, false))
				{
					point[Client] = SQL_FetchInt(hndl,2);
					newbie[Client] = SQL_FetchInt(hndl,3);
					playtime[Client] = SQL_FetchInt(hndl,4);
					playsecond[Client] = SQL_FetchInt(hndl,5);
					usetrail[Client] = SQL_FetchInt(hndl,6);
					SQL_FetchString(hndl, 7, playtag[Client], 32);
					nagativeskin[Client] = SQL_FetchInt(hndl,8);
					playkill[Client] = SQL_FetchInt(hndl,9);
					playdeath[Client] = SQL_FetchInt(hndl,10);
					playwaring[Client] = SQL_FetchInt(hndl,11);
					usebubble[Client] = SQL_FetchInt(hndl,12)
					useeffect1[Client] = SQL_FetchFloat(hndl,13)
					useeffect2[Client] = SQL_FetchFloat(hndl,14)
					useeffect3[Client] = SQL_FetchFloat(hndl,15)
					use_effect1[Client] = SQL_FetchInt(hndl,16)
					use_effect2[Client] = SQL_FetchInt(hndl,17)
					use_effect3[Client] = SQL_FetchInt(hndl,18)
					PrintToChat(Client, "\x07FF00AE[Query] \x07FFFFFF- 플레이어 정보 데이터 불러오기 성공!");
					PrintToChat(Client, "\x07FF00AE[Query] \x07FFFFFF- 플레이어 인벤토리 데이터 불러오기 성공!");
				}
			}
		}
	}
}

public updatedata(Handle:owner, Handle:hndl, const String:error[], any:data)
{
	if (hndl == INVALID_HANDLE)
		LogError("query update failed %s", error);
}

public steamidtodbid(String:steamid[], maxlength)
{
	//모른다그냥써라
	ReplaceString(steamid, maxlength, ":", ":", false);
}

//////////////////////////////////////////////////////////////////////////////////////////상점
public Command_ShopMain(Client)
{
	new Handle:shop = CreateMenu(Command_ShopMains);
	SetMenuTitle(shop, " -- 메인 메뉴 -- ");
	AddMenuItem(shop, "0", "내 정보");
	AddMenuItem(shop, "1", "내 인벤토리");
	AddMenuItem(shop, "2", "현재 장착중인아이템");
	AddMenuItem(shop, "3", "아이템 구입");
	DisplayMenu(shop, Client, MENU_TIME_FOREVER);
}

public Command_ShopMains(Handle:menu, MenuAction:action, Client, Select)
{
	if(action == MenuAction_Select)
	{
		if(Select == 0) My_info(Client, Client);
		if(Select == 1) Command_Items(Client, 0);
		if(Select == 2) My_Items(Client);
		if(Select == 3) ShopMainItem(Client);
	}
}

public My_info(Client, Target)
{
	new String:Client_Name[256], String:Title[256], String:Item_Shop1[256], String:Item_Shop2[256], String:Item_Shop3[256], String:Item_Shop4[256], String:Item_Shop5[256], String:Item_Shop6[256];
	GetClientName(Target, Client_Name, 32);
	Format(Title, 256, " -- %s 님의 아이템 정보 -- ", Client_Name);
	Format(Item_Shop1, 256, "포인트 : %d", point[Target]);
	
	if(usetrail[Target] == 0) Format(Item_Shop2, 256, "트레일 : 없음");
	if(usetrail[Target] != 0) Format(Item_Shop2, 256, "트레일 : %s", Item_Name[usetrail[Target]]);
	
	if(nagativeskin[Target] == 0) Format(Item_Shop3, 256, "음성스킨 : 없음");
	if(nagativeskin[Target] != 0) Format(Item_Shop3, 256, "음성스킨 : %s", Item_Name[nagativeskin[Target]]);
	
	if(usebubble[Target] == 0) Format(Item_Shop4, 256, "버블 : 없음");
	if(usebubble[Target] != 0) Format(Item_Shop4, 256, "버블 : %s", Item_Name[usebubble[Target]]);
	
	Format(Item_Shop5, 256, "플레이 타임 : %d 시간", playtime[Target]);
	Format(Item_Shop6, 256, "킬 / 데스 : %d / %d ", playkill[Target], playdeath[Target]);
	new Handle:menu = CreateMenu(Menu_My_info);
	SetMenuTitle(menu, Title);
	AddMenuItem(menu, "0", Item_Shop1, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "1", Item_Shop2, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "2", Item_Shop3, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "3", Item_Shop4, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "4", Item_Shop5, ITEMDRAW_DISABLED);
	AddMenuItem(menu, "5", Item_Shop6, ITEMDRAW_DISABLED);
	DisplayMenu(menu, Client, MENU_TIME_FOREVER);
}

public Menu_My_info(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{

	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_ExitBack) Command_ShopMain(Client);
	}
	else if(action == MenuAction_End) CloseHandle(menu);
}

public Command_Itemlist(Client)
{
	new Handle:itemmenu = CreateMenu(Command_Itemlist2), bool:DisplayItem = false;
	new String:Name_Format[256], String:Number[256], String:Item_Actionname[6][256];
	
	SetMenuTitle(itemmenu, " -- 아이템 리스트 -- ");
	for(new i = 0; i < MAX_ITEMS; i++)
	{
		if(Item_Action[i] != 0)
		{
			if(Item_Action[i] == 1) Format(Name_Format, 256, "(코드:%d번)(아이템)%s", Item_Code[i], Item_Name[i]);
			if(Item_Action[i] == 2) Format(Name_Format, 256, "(코드:%d번)(트레일)%s", Item_Code[i], Item_Name[i]);
			if(Item_Action[i] == 3) Format(Name_Format, 256, "(코드:%d번)(음성스킨)%s", Item_Code[i], Item_Name[i]);
			if(Item_Action[i] == 4) Format(Name_Format, 256, "(코드:%d번)(아이템)%s", Item_Code[i], Item_Name[i]);
			if(Item_Action[i] == 5) Format(Name_Format, 256, "(코드:%d번)(아이템)%s", Item_Code[i], Item_Name[i]);
			if(Item_Action[i] == 6) Format(Name_Format, 256, "(코드:%d번)(버블)%s", Item_Code[i], Item_Name[i]);
			if(Item_Action[i] == 99) Format(Name_Format, 256, "(코드:%d번)(아이템)%s", Item_Code[i], Item_Name[i]);
			if(Item_Action[i] == 7) Format(Name_Format, 256, "(코드:%d번)(이펙트)%s", Item_Code[i], Item_Name[i]);
			Format(Number, 256, "%d", i);
			AddMenuItem(itemmenu, Number, Name_Format, ITEMDRAW_DISABLED);
			if(!DisplayItem) DisplayItem = true;
		}
	}
	SetMenuExitBackButton(itemmenu, true);
	DisplayMenu(itemmenu, Client, MENU_TIME_FOREVER);
	if(!DisplayItem) Command_NoItem(Client);
}

public Command_Itemlist2(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{

	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_ExitBack) Command_ShopMain(Client);
	}
	else if(action == MenuAction_End) CloseHandle(menu);
}

public Command_Items(Client, Actions)
{
	new Handle:itemmenu = CreateMenu(Menu_Items), bool:DisplayItem = false;
	new String:Name_Format[256], String:Number[256];
	SetMenuTitle(itemmenu, " -- 인벤토리 -- ");
	for(new i = 0; i < MAX_ITEMS; i++)
	{
		if(ITEM[Client][i] > 0 && Item_Action[i] != 0)
		{
			Format(Name_Format, 256, "%s - %d개 소지", Item_Name[i], ITEM[Client][i]);
			Format(Number, 256, "%d", i);
			AddMenuItem(itemmenu, Number, Name_Format);
			if(!DisplayItem) DisplayItem = true;
		}
	}
	SetMenuExitBackButton(itemmenu, true);
	DisplayMenu(itemmenu, Client, MENU_TIME_FOREVER);
	if(!DisplayItem) Command_NoItem(Client);
}

public Menu_Items(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{
 		new String:info[256];
		GetMenuItem(menu, select, info, sizeof(info));
		Command_Prompt(Client, info);
	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_ExitBack) Command_ShopMain(Client);
	}
}

public Command_NoItem(Client)
{
	new Handle:menu = CreateMenu(Menu_NoItem);
	SetMenuTitle(menu, " -- 인벤토리 -- ");
	AddMenuItem(menu, "1", "현재 가지고 계신아이템이 하나도없습니다", ITEMDRAW_DISABLED);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, Client, MENU_TIME_FOREVER);
}

public Menu_NoItem(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{

	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_ExitBack)
		{
			Command_ShopMain(Client);
		}
	}
}

public Command_Prompt(Client, String:Number[256])
{
	new Handle:itemmenu = CreateMenu(Menu_Prompt);
	SetMenuTitle(itemmenu, " -- 아이템 사용하기 -- ");
	AddMenuItem(itemmenu, Number, "아이템 사용하기");
	AddMenuItem(itemmenu, Number, "버리기");
	SetMenuExitBackButton(itemmenu, true);
	DisplayMenu(itemmenu, Client, MENU_TIME_FOREVER);
}

public Menu_Prompt(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{
 		new TAction, Selected, String:info[256], String:TName[256], String:Client_Name[256];
		GetMenuItem(menu, select, info, sizeof(info));
		StringToIntEx(info, Selected);
		TAction = Item_Action[Selected];
		GetClientName(Client, Client_Name, 32);

		if(select == 0)
		{
			if(TAction == 1)
			{
				if(ITEM[Client][Selected] <= 1 || Itemamountcheck(Client))
				{
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 태그 이용권\x07FFFFFF 은 \x07FFA2E6!tag\x07FFFFFF를 이용해 설정할 수 있습니다.");
				}
			}
			if(TAction == 2)
			{
				if(ITEM[Client][Selected] <= 1 || Itemamountcheck(Client))
				{
					ITEM[Client][usetrail[Client]] += 1;
					usetrail[Client] = 0;
					usetrail[Client] = Item_Code[Selected];
					ITEM[Client][Selected] -= 1;
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 트레일 \x07FFA2E6%s\x07FFFFFF 아이템을 사용 하셨습니다.", Item_Name[usetrail[Client]]);
					if(AliveCheck(Client) == true)
					{
						DeleteTrail(Client);
						CreateTrail(Client);
					}
					Command_Items(Client, 0);
				}
			}
			if(TAction == 3)
			{
				if(ITEM[Client][Selected] <= 1 || Itemamountcheck(Client))
				{
					ITEM[Client][nagativeskin[Client]] += 1;
					nagativeskin[Client] = 0;
					nagativeskin[Client] = Item_Code[Selected];
					ITEM[Client][Selected] -= 1;
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 음성스킨 \x07FFA2E6%s\x07FFFFFF 아이템을 사용 하셨습니다.", Item_Name[nagativeskin[Client]]);
					Command_Items(Client, 0);
				}
			}
			if(TAction == 4)
			{
				if(ITEM[Client][Selected] <= 1 || Itemamountcheck(Client))
				{
					playkill[Client] = 0;
					playdeath[Client] = 0;
					ITEM[Client][Selected] -= 1;
					PrintToChatAll("\x07FF00AE[PointShop] \x07FFFFFF- %N님이 \x07FFA2E6%s\x07FFFFFF 아이템을 사용 하셨습니다.", Client, Item_Name[Selected]);
					Command_Items(Client, 0);
				}
			}
			if(TAction == 5)
			{
				if(ITEM[Client][Selected] <= 1 || Itemamountcheck(Client))
				{
					if(musicstart == false)
					{
						ITEM[Client][Selected] -= 1;
						Format(nagativeskinCode, 256, "alpreah/%s", SkinModel[Selected]);
						EmitSoundToAll(nagativeskinCode);
						useingsound = nagativeskinCode;
						musicstart = true;
						musiccount = Item_Code[Selected];
						CreateTimer(1.0, ResetMusic, TIMER_REPEAT);
						PrintCenterTextAll("%N님이 노래 아이템을 사용 하셨습니다.\n%s", Client, Item_Name[Selected])
						PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- \x07FFA2E6%s\x07FFFFFF 아이템을 사용 하셨습니다.", Item_Name[Selected]);
					}
					else if(musicstart == true)
					{
						PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 이미 누군가가 노래를 틀어 \x07FFA2E6%s\x07FFFFFF 아이템을 사용할 수 없습니다.", Item_Name[Selected]);
					}
					Command_Items(Client, 0);
				}
			}
			if(TAction == 6)
			{
				if(ITEM[Client][Selected] <= 1 || Itemamountcheck(Client))
				{
					ITEM[Client][usebubble[Client]] += 1;
					usebubble[Client] = 0;
					usebubble[Client] = Item_Code[Selected];
					ITEM[Client][Selected] -= 1;
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 버블 \x07FFA2E6%s\x07FFFFFF 아이템을 사용 하셨습니다.", Item_Name[usebubble[Client]]);
					Command_Items(Client, 0);
				}
			}
			if(TAction == 7)
			{
				if(ITEM[Client][Selected] <= 1 || Itemamountcheck(Client))
				{
					if(AliveCheck(Client) == true)
					{
						ITEM[Client][use_effect1[Client]] += 1;
						ITEM[Client][Selected] -= 1;
						useeffect1[Client] = 0.0;
						useeffect1[Client] = Item_Code2[Selected];
						use_effect1[Client] = 0;
						use_effect1[Client] = Item_Code[Selected];
						AddEffect1(Client);
						PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 주무기 이펙트 \x07FFA2E6%s\x07FFFFFF 아이템을 사용 하셨습니다.", Item_Name[Selected]);
						Command_Items(Client, 0);
					}
					else PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 죽어있는 상태에서는 사용이 불가능 합니다.")
				}
			}
			if(TAction == 8)
			{
				if(ITEM[Client][Selected] <= 1 || Itemamountcheck(Client))
				{
					if(AliveCheck(Client) == true)
					{
						ITEM[Client][use_effect2[Client]] += 1;
						ITEM[Client][Selected] -= 1;
						useeffect2[Client] = 0.0;
						useeffect2[Client] = Item_Code2[Selected];
						AddEffect2(Client);
						PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 보조무기 이펙트 \x07FFA2E6%s\x07FFFFFF 아이템을 사용 하셨습니다.", Item_Name[Selected]);
						Command_Items(Client, 0);
					}
					else PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 죽어있는 상태에서는 사용이 불가능 합니다.")
				}
			}
			if(TAction == 9)
			{
				if(ITEM[Client][Selected] <= 1 || Itemamountcheck(Client))
				{
					if(AliveCheck(Client) == true)
					{
						ITEM[Client][use_effect3[Client]] += 1;
						ITEM[Client][Selected] -= 1;
						useeffect3[Client] = 0.0;
						useeffect3[Client] = Item_Code2[Selected];
						AddEffect3(Client);
						PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 근접무기 이펙트 \x07FFA2E6%s\x07FFFFFF 아이템을 사용 하셨습니다.", Item_Name[Selected]);
						Command_Items(Client, 0);
					}
					else PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 죽어있는 상태에서는 사용이 불가능 합니다.")
				}
			}
			if(TAction == 99)
			{
				if(ITEM[Client][Selected] <= 1 || Itemamountcheck(Client))
				{
					new RandomPoint = GetRandomInt(100, 500);
					ITEM[Client][Selected] -= 1;
					point[Client] += RandomPoint;
					PrintToChatAll("\x07FF00AE[PointShop] \x07FFFFFF- %N님이 \x07FFA2E6%s\x07FFFFFF에서 %d 포인트를 획득헀습니다.", Client, Item_Name[Selected], RandomPoint);
					Command_Items(Client, 0);
				}
			}
		}
		else if(select == 1)
		{
			TName = Item_Name[Selected];
			ITEM[Client][Selected] -= 1;
			PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- %s 아이템을 버리셨습니다.", TName);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_ExitBack) Command_ShopMain(Client);
	}
}

public Action:ResetMusic(Handle:timer)
{
	if(musiccount >= 1)
	{
		musiccount --;
	}
	else if(musiccount == 0)
	{
		musicstart = false;
		useingsound = "";
		return Plugin_Stop;
	}
	return Plugin_Continue;
}


public My_Items(Client)
{
	new String:Name[256], String:Title[256], String:Item_Shop1[256], String:Item_Shop2[256], String:Item_Shop3[256], String:Item_Shop4[256], String:Item_Shop5[256], String:Item_Shop6[256];
	GetClientName(Client, Name, 32);
	Format(Title, 256, " -- %s 아이템 정보 -- ", Name);
	if(usetrail[Client] == 0) Format(Item_Shop1, 256, "트레일 : 없음");
	if(usetrail[Client] != 0) Format(Item_Shop1, 256, "트레일 : %s", Item_Name[usetrail[Client]]);
	if(nagativeskin[Client] == 0) Format(Item_Shop2, 256, "음성스킨 : 없음");
	if(nagativeskin[Client] != 0) Format(Item_Shop2, 256, "음성스킨 : %s", Item_Name[nagativeskin[Client]]);
	if(usebubble[Client] == 0) Format(Item_Shop3, 256, "버블 : 없음");
	if(usebubble[Client] != 0) Format(Item_Shop3, 256, "버블 : %s", Item_Name[usebubble[Client]]);
	if(use_effect1[Client] == 0) Format(Item_Shop4, 256, "주무기 이펙트 : 없음");
	if(use_effect1[Client] != 0) Format(Item_Shop4, 256, "주무기 이펙트 : %s", Item_Name[use_effect1[Client]]);
	if(use_effect2[Client] == 0) Format(Item_Shop5, 256, "보조무기 이펙트 : 없음");
	if(use_effect2[Client] != 0) Format(Item_Shop5, 256, "보조무기 이펙트 : %s", Item_Name[use_effect2[Client]]);
	if(use_effect3[Client] == 0) Format(Item_Shop6, 256, "근접무기 이펙트 : 없음");
	if(use_effect3[Client] != 0) Format(Item_Shop6, 256, "근접무기 이펙트 : %s", Item_Name[use_effect3[Client]]);

	new Handle:menu = CreateMenu(Menu_My_Items);
	SetMenuTitle(menu, Title);
	AddMenuItem(menu, "1", Item_Shop1);
	AddMenuItem(menu, "2", Item_Shop2);
	AddMenuItem(menu, "2", Item_Shop3);
	AddMenuItem(menu, "2", Item_Shop4);
	AddMenuItem(menu, "2", Item_Shop5);
	AddMenuItem(menu, "2", Item_Shop6);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, Client, MENU_TIME_FOREVER);
}

public Menu_My_Items(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{
		if(select == 0)
		{
			if(usetrail[Client] != 0)
			{
				if(Itemamountcheck(Client))
				{
					ITEM[Client][usetrail[Client]] += 1;
					PrintToChat(Client, "\x07FF00AE[PointShop] - \x07FFA2E6%s 트레일\x07FFFFFF을 \x07FFA2E6장착해제\x07FFFFFF가 되었습니다.", Item_Name[usetrail[Client]]);
					usetrail[Client] = 0;
					My_Items(Client);
					DeleteTrail(Client);
				}
				else
				{
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 인벤토리에 여유공간이 없습니다.");
					My_Items(Client);
				}
			}
		}
		if(select == 1)
		{
			if(nagativeskin[Client] != 0)
			{
				if(Itemamountcheck(Client))
				{
					ITEM[Client][nagativeskin[Client]] += 1;
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- %s 음성스킨\x07FFFFFF을 \x07FFA2E6장착해제\x07FFFFFF가 되었습니다.", Item_Name[nagativeskin[Client]]);
					nagativeskin[Client] = 0;
					My_Items(Client);
				}
				else
				{
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 인벤토리에 여유공간이 없습니다.");
					My_Items(Client);
				}
			}
		}
		if(select == 2)
		{
			if(usebubble[Client] != 0)
			{
				if(Itemamountcheck(Client))
				{
					ITEM[Client][usebubble[Client]] += 1;
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- %s 버블\x07FFFFFF을 \x07FFA2E6장착해제\x07FFFFFF가 되었습니다.", Item_Name[usebubble[Client]]);
					usebubble[Client] = 0;
					My_Items(Client);
				}
				else
				{
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 인벤토리에 여유공간이 없습니다.");
					My_Items(Client);
				}
			}
		}
		if(select == 3)
		{
			if(useeffect1[Client] != 0 && use_effect1[Client] != 0)
			{
				if(Itemamountcheck(Client))
				{
					ITEM[Client][use_effect1[Client]] += 1;
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- %s 주무기 이펙트\x07FFFFFF을 \x07FFA2E6장착해제\x07FFFFFF가 되었습니다.", Item_Name[use_effect1[Client]]);
					useeffect1[Client] = 0.0;
					use_effect1[Client] = 0;
					My_Items(Client);
				}
				else
				{
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 인벤토리에 여유공간이 없습니다.");
					My_Items(Client);
				}
			}
		}
		if(select == 4)
		{
			if(useeffect2[Client] != 0 && use_effect2[Client] != 0)
			{
				if(Itemamountcheck(Client))
				{
					ITEM[Client][use_effect2[Client]] += 1;
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- %s 보조무기 이펙트\x07FFFFFF을 \x07FFA2E6장착해제\x07FFFFFF가 되었습니다.", Item_Name[use_effect2[Client]]);
					useeffect2[Client] = 0.0;
					use_effect2[Client] = 0;
					My_Items(Client);
				}
				else
				{
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 인벤토리에 여유공간이 없습니다.");
					My_Items(Client);
				}
			}
		}
		if(select == 5)
		{
			if(useeffect3[Client] != 0 && use_effect3[Client] != 0)
			{
				if(Itemamountcheck(Client))
				{
					ITEM[Client][use_effect3[Client]] += 1;
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- %s 근접무기 이펙트\x07FFFFFF을 \x07FFA2E6장착해제\x07FFFFFF가 되었습니다.", Item_Name[use_effect3[Client]]);
					useeffect3[Client] = 0.0;
					use_effect3[Client] = 0;
					My_Items(Client);
				}
				else
				{
					PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 인벤토리에 여유공간이 없습니다.");
					My_Items(Client);
				}
			}
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_ExitBack) Command_ShopMain(Client);
	}
	else if(action == MenuAction_End) CloseHandle(menu);
}

public ShopMainItem(Client)
{
	new Handle:Menu = CreateMenu(Menu_ShopMainItem);

	SetMenuTitle(Menu, "아이템 판매 메뉴");

	AddMenuItem(Menu, "1", "태그 변경권 판매 메뉴");
	AddMenuItem(Menu, "2", "트레일 판매 메뉴");
	AddMenuItem(Menu, "3", "음성 스킨 판매 메뉴");
	AddMenuItem(Menu, "4", "아이템 판매 메뉴");
	AddMenuItem(Menu, "5", "음악 판매 메뉴");
	AddMenuItem(Menu, "6", "버블 판매 메뉴");
	AddMenuItem(Menu, "7", "주무기 이펙트 판매 메뉴");
	AddMenuItem(Menu, "8", "보조무기 이펙트 판매 메뉴");
	AddMenuItem(Menu, "9", "근접무기 이펙트 판매 메뉴");

	SetMenuExitBackButton(Menu, true);
	DisplayMenu(Menu, Client, MENU_TIME_FOREVER);
}

public Menu_ShopMainItem(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{
 		new String:info[32], Actions;
		GetMenuItem(menu, select, info, sizeof(info));
		StringToIntEx(info, Actions);

		if(Itemamountcheck(Client) == true)
			Command_ItemShop(Client, Actions);
		else
			PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- 아이템을 구매하기 위해서는 여유공간이 필요합니다.");
	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_ExitBack)
		{
			Command_ShopMain(Client);
		}
	}
}

public Command_ItemShop(Client, Actions)
{
	new Handle:Menu = CreateMenu(Menu_ItemShop);
	new bool:DisplayItem = false;

	SetMenuTitle(Menu, " -- 아이템 판매 메뉴 -- ");

	for(new i = 1; i < MAX_ITEMS; i++)
	{
		if(Item_Action[i] == Actions && Item_Price[i] != 0)
		{
			new String:ShopItem[256], String:Item_N[32];
			Format(ShopItem, 256, "%s - %d 포인트", Item_Name[i], Item_Price[i]);
			Format(Item_N, 256, "%d", i);
			AddMenuItem(Menu, Item_N, ShopItem);
			if(DisplayItem == false) DisplayItem = true;
		}
	}
	if(!DisplayItem) Command_NoItemSell(Client);
	SetMenuExitBackButton(Menu, true);
	DisplayMenu(Menu, Client, MENU_TIME_FOREVER);
}

public Command_NoItemSell(Client)
{
	new Handle:menu = CreateMenu(Menu_NoItem);
	SetMenuTitle(menu, " -- 재고가 없습니다. -- ");
	AddMenuItem(menu, "1", "판매중인 아이템이 없습니다.", ITEMDRAW_DISABLED);
	SetMenuExitBackButton(menu, true);
	DisplayMenu(menu, Client, MENU_TIME_FOREVER);
}
	
public Menu_ItemShop(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{
 		new String:info[256], Item_Number;
		GetMenuItem(menu, select, info, sizeof(info));
		StringToIntEx(info, Item_Number);

		Command_ItemBuyCheck(Client, Item_Number);
	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_ExitBack)
		{
			Command_ShopMain(Client);
		}
	}
}

//아이템 구입 확인창
public Command_ItemBuyCheck(Client, Item_Numb)
{
	new Handle:Menu = CreateMenu(Menu_ItemBuyCheck);
	new String:Item_Name_Check[256], String:Item_Number[32];
	Format(Item_Number, 32, "%d", Item_Numb);
	Format(Item_Name_Check, 256, "%s 아이템 구입 확인 메뉴", Item_Name[Item_Numb]);

	SetMenuTitle(Menu, Item_Name_Check);
	
	AddMenuItem(Menu, Item_Number, "아이템 구입 확인");
	AddMenuItem(Menu, "아이템 구입 취소", "아이템 구입 취소");
	
	SetMenuExitBackButton(Menu, true);
	DisplayMenu(Menu, Client, MENU_TIME_FOREVER);
}

public Menu_ItemBuyCheck(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select && select == 0)
	{
 		new String:info[256], Item_Number;
		GetMenuItem(menu, select, info, sizeof(info));
		StringToIntEx(info, Item_Number);
		
		if(point[Client] >= Item_Price[Item_Number])
		{
			ITEM[Client][Item_Number] += 1;
			point[Client] -= Item_Price[Item_Number];
			PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- %s 아이템을 구매 했습니다.", Item_Name[Item_Number]);
		}
		else
		{
			PrintToChat(Client, "\x07FF00AE[PointShop] \x07FFFFFF- %d 포인트가 부족 합니다.", Item_Price[Item_Number] - point[Client]);
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_ExitBack)
		{
			ShopMainItem(Client);
		}
	}
}

//////////////////////////////////////////////////////////////////////////////////////////스턱
stock bool:InCheck(Client)
{
	if(Client > 0 && Client <= MaxClients)
	{
		if(IsClientInGame(Client) == true)
		{
			return true;	
		}
		else
		{	
			return false;	
		}
		
	}
	else
	{
		return false;
	}
}

stock Action:CreateTrail(Client)
{
	if(usetrail[Client] != 0)
	{
		decl Float:Clientposition[3];

		GetClientAbsOrigin(Client, Clientposition);
		Clientposition[2] = Clientposition[2] + 10.0;
				
		new String:positionstring[128], String:colorstring[128];
			
		Format(positionstring, 128, "%f %f %f", Clientposition[0], Clientposition[1], Clientposition[2]);
		Format(colorstring, 128, "%d %d %d %d", 255, 255, 255, 255);
			
		beamfollowentity[Client] = CreateEntityByName("env_spritetrail");
		DispatchKeyValue(beamfollowentity[Client],"Origin", positionstring);
		DispatchKeyValueFloat(beamfollowentity[Client], "lifetime", 1.0);
		DispatchKeyValueFloat(beamfollowentity[Client], "startwidth", 16.0);
		DispatchKeyValueFloat(beamfollowentity[Client], "endwidth", 8.0);
		DispatchKeyValue(beamfollowentity[Client], "spritename", SkinModel[usetrail[Client]]);
		DispatchKeyValue(beamfollowentity[Client], "renderamt", "255");
		DispatchKeyValue(beamfollowentity[Client], "rendercolor", colorstring);
		DispatchKeyValue(beamfollowentity[Client], "rendermode", "5");
		DispatchSpawn(beamfollowentity[Client]);

		SetEntPropFloat(beamfollowentity[Client], Prop_Send, "m_flTextureRes", 0.05);
		SetEntPropFloat(beamfollowentity[Client], Prop_Data, "m_flSkyboxScale", 1.0);

		SetVariantString("!activator");
		AcceptEntityInput(beamfollowentity[Client], "SetParent", Client);
	}
}

stock DeleteTrail(Client)
{
	if(IsValidEntity(beamfollowentity[Client]) && beamfollowentity[Client] != 0)
	{
		new String:entityclass[128];
		GetEdictClassname(beamfollowentity[Client], entityclass, sizeof(entityclass));
			
		if(StrEqual(entityclass, "env_spritetrail"))
		{
			AcceptEntityInput(beamfollowentity[Client], "Kill");
			beamfollowentity[Client] = 0;
		}
	}
}

stock bool:JoinCheck(Client)
{
	if(Client > 0 && Client <= MaxClients)
		if(IsClientConnected(Client) == true)
			if(IsClientInGame(Client) == true)
				return true;
			else return false;
		else return false;
	else return false;
}

stock bool:AliveCheck(Client)
{
	if(JoinCheck(Client) == true)
		if(IsPlayerAlive(Client) == true)
			return true;
		else return false;
	else return false;
}

public CreateItem(Item_ID, String:Temp_Item_Name[256], Temp_Item_Action, Temp_Item_Code, String:sModel[256], Temp_Item_Price)
{
	Item_Name[Item_ID] = Temp_Item_Name;
	Item_Action[Item_ID] = Temp_Item_Action;
	Item_Code[Item_ID] = Temp_Item_Code;
	SkinModel[Item_ID] = sModel;
	Item_Price[Item_ID] = Temp_Item_Price;
}

public CreateItem2(Item_ID, String:Temp_Item_Name[256], Temp_Item_Action, Temp_Item_Code, Float:Temp_Item_Code2, String:sModel[256], Temp_Item_Price)
{
	Item_Name[Item_ID] = Temp_Item_Name;
	Item_Action[Item_ID] = Temp_Item_Action;
	Item_Code[Item_ID] = Temp_Item_Code;
	Item_Code2[Item_ID] = Temp_Item_Code2;
	SkinModel[Item_ID] = sModel;
	Item_Price[Item_ID] = Temp_Item_Price;
}

public bool:Itemamountcheck(Client)
{
	new Itemamount = 0;
	for(new i = 0; i < MAX_ITEMS; i++)
	{
		if(ITEM[Client][i] > 0) Itemamount++;
	}

	if(Itemamount < MAX_INVENTORY)
		return true;
	else
		return false;
}

public Action:Hurt_Check(Handle:Timer, any:Client)
{
	if(AliveCheck(Client) && Hurt_Delay[Client] == true)
	{
		Hurt_Delay[Client] = false;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action:Jump_Check(Handle:Timer, any:Client)
{
	if(AliveCheck(Client) && Jump_Delay[Client] == true)
	{
		Jump_Delay[Client] = false;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

stock CreateProps(Float:A[3], String:Classname[32], String:ModelPath[64], Client)
{
	new B = CreateEntityByName(Classname);
	DispatchKeyValue(B, "physdamagescale", "0.0");
	Dis1patchKeyValue(B, "model", ModelPath);
	SetEntProp(B, Prop_Data, "m_takedamage", 2);
	DispatchSpawn(B);
	TeleportEntity(B, A, NULL_VECTOR, NULL_VECTOR);
}

stock CreateBubble(Client, model, Float:heigth, count, Float:speed, Float:delay)
{
	new Float:Clientposition[3];
	GetClientAbsOrigin(Client, Clientposition);

	TE_Start("Bubbles");
	TE_WriteVector("m_vecMins", Clientposition);
	TE_WriteVector("m_vecMaxs", Clientposition);
	TE_WriteNum("m_nModelIndex", model);
	TE_WriteFloat("m_fHeight", heigth);
	TE_WriteNum("m_nCount", count);
	TE_WriteFloat("m_fSpeed", speed);
	TE_SendToAll(delay);
}

public Action:AddEffect1(Client)
{
	ClientItems[Client] = GetEntProp(GetPlayerWeaponSlot(Client, 0), Prop_Send, "m_iItemDefinitionIndex")
	TF2II_GetItemClass(ClientItems[Client], ClassName[Client], 128)
	GiveEffect(Client, ClassName[Client], ClientItems[Client], useeffect1[Client], 0);
}

public Action:AddEffect2(Client)
{
	ClientItems[Client] = GetEntProp(GetPlayerWeaponSlot(Client, 1), Prop_Send, "m_iItemDefinitionIndex")
	TF2II_GetItemClass(ClientItems[Client], ClassName[Client], 128)
	GiveEffect(Client, ClassName[Client], ClientItems[Client], useeffect1[Client], 1);
}

public Action:AddEffect3(Client)
{
	ClientItems[Client] = GetEntProp(GetPlayerWeaponSlot(Client, 2), Prop_Send, "m_iItemDefinitionIndex")
	TF2II_GetItemClass(ClientItems[Client], ClassName[Client], 128)
	GiveEffect(Client, ClassName[Client], ClientItems[Client], useeffect1[Client], 2);
}

GiveEffect(iClient, String:ItemClass[], ItemID, Float:Effect, Slot)
{
	new flags = OVERRIDE_ATTRIBUTES;
	new Handle:hItem = TF2Items_CreateItem(flags);

	flags |= OVERRIDE_CLASSNAME;
	TF2Items_SetClassname(hItem, ItemClass);
			
	flags |= OVERRIDE_ITEM_DEF;
	TF2Items_SetItemIndex(hItem, ItemID);
	TF2Items_SetNumAttributes(hItem, 1);
	TF2Items_SetAttribute(hItem, 0, 134, Effect);
			
	flags |= PRESERVE_ATTRIBUTES;
	TF2Items_SetFlags(hItem, flags);	

	TF2_RemoveWeaponSlot(iClient, Slot);

	new entity = TF2Items_GiveNamedItem(iClient, hItem);
	CloseHandle(hItem);
			
	if (IsValidEntity(entity))
		EquipPlayerWeapon(iClient, entity);
				
	return;
}

reset(Client)
{
	point[Client] = 0;
	newbie[Client] = 0;
	playtime[Client] = 0;
	playsecond[Client] = 0;
	usetrail[Client] = 0;
	playtag[Client] = "뉴비";
	nagativeskin[Client] = 0;
	playkill[Client] = 0;
	playdeath[Client] = 0;
	playwaring[Client] = 0;
	usebubble[Client] = 0;
	useeffect1[Client] = 0.0;
	useeffect2[Client] = 0.0;
	useeffect3[Client] = 0.0;
	use_effect1[Client] = 0;
	use_effect2[Client] = 0;
	use_effect3[Client] = 0;
	for(new i = 0; i < MAX_ITEMS; i++)
	{
		ITEM[Client][i] = 0;
	}
}
stock SetPreventSQLInject(const String:input[], String:output[], oplength)
{
	new String:tempstr[512];
	
	strcopy(tempstr, sizeof(tempstr), input);
	
	ReplaceString(tempstr, sizeof(tempstr), "'", "''", false);
	ReplaceString(tempstr, sizeof(tempstr), "`", "`", false);
	ReplaceString(tempstr, sizeof(tempstr), "\\", "\\\\", false);
	
	strcopy(output, oplength, tempstr);
}

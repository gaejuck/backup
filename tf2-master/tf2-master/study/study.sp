#include <테이크의 귀찮아서 복붙 모음> // FF0000llllFFA200llllllll46FF00llll6200FFllllllllll 

SetEntPropFloat(entity, Prop_Data, "m_flSpeed", 0.1); 투사체 발사 속도

3A87ED6B2826B78073B23F143CF5EA66 //api key take2

76561198103558528

// http://api.steampowered.com/IEconItems_440/GetSchema/v0001/?key=&3A87ED6B2826B78073B23F143CF5EA66&language=ko_KR

sv_visiblemaxplayers 1 

StripQuotes //유저가 쓴 쌍따옴표를 제거함

TrimString // 문자열 내의 처음과 끝의 공백문자열을 제거합니다.

PrintToChat(client, "%s", g_bTra[client] ? "활성화" : "비활성화");

FindSendPropOffs - > FindSendPropInfo

SetEntityMoveType(client, MOVETYPE_NONE);
SetEntityMoveType(client, MOVETYPE_FLY);

new hArray = CreateArray()                  //array[#]

//Automatically adds new indexs if needed
PushArrayCell(hArray, 123);                  //array[0] = 123

PushArrayFloat(hArray, 666.9);             //array[1] = 666.9

PushArrayCell(hArray, true);                 //array[2] = true

GetArraySize() //3  

new hArray = CreateArray(32)              //array[#, 32]

PushArrayString(hArray, "Hello World!");    //array[0][32] = "Hello World!"
                                                              // -> array[0][0] = 'H'
                                                              // -> array[0][1] = 'e'
                                                              // ->  ...
                                                              // -> array[0][11] = '!'

PushArrayArray(hArray, {1, 2, 3, 4});      //array[1][32] = {1, 2, 3, 4}
                                                        // -> array[1][0] = 1
                                                        // ->  ...
                                                        // -> array[1][3] = 4

GetArraySize() //2

CreateArray(1, 100)                            // -> array[0] = 0
                                                       // -> array[1] = 0
                                                       // -> ...
                                                       // -> array[99] = 0

GetArraySize() //100  
//배열qoduf

SetEntProp(weapon, Prop_Send, "m_iClip1", 5); // 발사 될 수
SetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 2); // 탄창

GET
new aa = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType");

GetClientTime 서버에 접속중인 시간을 말함.

view_as<float>({0.0, 10.0, 0.0})
TF2_RemoveWeaponSlotTF2_RemoveWeaponSlot(client, view_as<int>(TF2IDB_GetItemSlot(index)));
DispatchKeyValueVector(ent, "velocity", view_as<float>{0.0, 10.0, 0.0});

new bottle = FindBottle(param1);
if (bottle != -1)
	SetEntProp(bottle, Prop_Send, "m_usNumCharges", 1); //수통 갯수

stock FindBottle(client)
{
	new i = -1;
	while ((i = FindEntityByClassname(i, "tf_powerup_bottle")) != -1)
	{
		if (IsValidEntity(i) && GetEntPropEnt(i, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(i, Prop_Send, "m_bDisguiseWearable"))
		{
			return i;
		}
	}
	return -1;
} 


//데이터베이스 epdlxjqpdltm db 디비
테이블 생성   <대문자는 모두 명령어라고 보심 됩니다.>
"CREATE TABLE IF NOT EXISTS 테이블이름 (steamid VARCHAR(64), name VARCHAR(64), PRIMARY KEY (steamid))"

데이타 세이브 <사실 방법은 많습니다만 제가 사용하는것만 써드리겠습니다.>
"REPLACE INTO 테이블이름 (steamid, name) VALUES ('%s', '%s')"

데이타 로드
"SELECT name FROM '테이블이름' WHERE (steamid = '%s')", "STEAM_1:0:12312313"


//mute 뮤트 보이스 
SetListenOverride(client, target, Listen_Yes);
SetListenOverride(client, target, Listen_No);


//파티클 이펙트 vkxlzmf dlvprxm items_game.txt
attribute_controlled_attached_particles

//f1키
AddCommandListener(OpenShop, "+showroundinfo");

public Action:OpenShop(Client, const String:command[], arg)
{
	Command_ShopMain(Client);
}

//상대 눈 보는거 엔티티 라던가 등등
SetClientViewEntity(client, entity)

//허드
for(new i = 1; i <= MaxClients; i++)
{
	if(IsClientInGame(i))
	{
		SetHudTextParams(0.1, 0.05, 1.09, 227, 57, 145, 0, 0, 6.0, 0.1, 0.2);
		ShowSyncHudText(i, hudText, "%s월 %s", M, W);
	}
}
//좌표 0.7이 오른쪽으로 갔고 0.5가 왼쪽으로 감 whkvy
0.1이 기준으로 높을수록 오른쪽 낮을수록 왼쪽
0.1이 y값인데 작을 수록 올라감


//시간 
FormatTime(date, sizeof(date), "%A", -1);

http://www.cplusplus.com/reference/ctime/strftime/

//체력
GetClientHealth(client)
SetEntityHealth(client, 30);

//게인 트래커 rpdla xmfozj
#define PLUGIN_VERSION "1.0"
CreateConVar("sm_tf_stats_version", PLUGIN_VERSION, "TF2 Player Stats", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

new String:Msg[64];
new String:test[4][64];
ExplodeString(Msg, "@", test, 3, 64);
ExplodeString(뽑아낼스트링변수, "나눌기준", 저장할스트링변수, 나눌갯수, sizeof());

//텔포 xpfvh xpffp 텔레
new Float:Attackerpos[3];
GetClientEyePosition(target_list[i], Attackerpos);
TeleportEntity(client, Attackerpos, NULL_VECTOR, NULL_VECTOR);
//TeleportEntity(엔티티, 출발지(원점), 엔티티가 바라보는 방향, 속도); NULL_VECTOR는 바꾸지 않다는거?? 노 체인지

new Float:vVel[3];
			
vVel[0] = 0.0;
vVel[1] = 0.0;
vVel[2] = 800.0;

TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vVel) 위로 올라감 800만큼


//번역문
new String:store[256]; //메뉴 번역일 경우
Format(store, sizeof(store), "%t", "Store", client);
AddMenuItem(info, "1", store);

%t //전체에게 쓰일경우
%T //클라이언트에게 쓰일경우

//내 생각엔 출력문에 맞을거같음
LANG_SERVER //서버 언어에 맞는 언어로 번역이 되는데 만약 서버 언어가 한국 이라면 외국인은 한국말로 번역된걸 봥야한다. 권장하지 않음

//vhapt 포멧 
Format(store, sizeof(store), "%t", "Store", LANG_SERVER, client);
Format(store, sizeof(store), "%t", "Store", client);

//케이스
switch(class)
{
	case 1:
	{
	}
	case 2:
	{
	}
}
switch(GetRandomInt(0,16))
{
	case 0: TF2Attrib_SetByDefIndex(client, 254, 4.0);
	case 1: TF2Attrib_SetByDefIndex(client, 254, 4.0);
}
	
//카트
SetEntPropFloat(client, Prop_Send, "m_flKartNextAvailableBoost", GetGameTime()+9999.0); //부스터 제거
SetEntProp(client, Prop_Send, "m_iKartHealth", 1000); //퍼센트 증가로

//소수점 thtnwja thtn thtnttthttntnnntntnntntnnntttttttttttttttttttt
%.1f

//프롭 데이터 샌드 vmfhq epdlxj tosem
Data 쪽은 특정 엔티티를 수정하고 저장하는 것을 중점으로 하는 목적의 속성이고 //내 생각은 현재 가지고 있는 속성이랄까?
Send 쪽은 네트워크 쪽을 중점으로 하여 변경하는 목적의 속성입니다. // 내 생각은 변화를 주는거랄까?

//온 플러그인 스타트 방법 2
닷지볼 300줄

//엔티티 entity dpsxlxl
#define TestFlags(%1,%2)	(!!((%1) & (%2)))
new iEntity = CreateEntityByName(TestFlags(iFlags, RocketFlag_IsAnimated)? "tf_projectile_sentryrocket" : "tf_projectile_rocket");
엔티티 = 엔티티 이름 ( 테스트플래그( 첫번째, 두번째)

new iEntity = CreateEntityByName("tf_wearable");  //이거 지금 서버 터지는데.;?
if(IsValidEntity(iEntity)) 
{ 
    SetEntProp(iEntity, Prop_Send, "m_iTeamNum", GetClientTeam(client)); 
    SetEntProp(iEntity, Prop_Send, "m_nSkin", GetClientTeam(client) - 2); 
    SetEntProp(iEntity, Prop_Send, "m_usSolidFlags", 4); 
    SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 11); 
    SetEntProp(iEntity, Prop_Send, "m_iEntityLevel", 70); 
    SetEntProp(iEntity, Prop_Send, "m_iEntityQuality", 6); 
    SetEntProp(iEntity, Prop_Send, "m_iItemDefinitionIndex", 920);         
         
    DispatchKeyValueVector(iEntity, "origin", bPos); 
         
    DispatchSpawn(iEntity); 
    SetEntityModel(iEntity, "models/player/items/all_class/witchhat_heavy.mdl"); 
    ActivateEntity(iEntity); 
}  

//무기 설정 anrl tjfwjd
new iWeapon = GetPlayerWeaponSlot(iClient, 0);
if (IsValidEntity(iWeapon) && GetEntProp(iWeapon, Prop_Send, "m_iItemDefinitionIndex") == 730)
{}

SetEntProp( weapon, Prop_Send, "m_bLowered", 10000 ); //공격이 안됨


new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
new aaac = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
		
if(weapon == 237 || weapon == 265)
{
	jump[client] = true;
}

decl String:sWeapon[64];
GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
if(StrEqual(sWeapon, "tf_weapon_shovel")
{
}

	decl String:classname[64];
	new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	GetEdictClassname(weapon, classname, sizeof(classname));
	if (StrEqual(classname, "tf_weapon_scattergun"))
	{
		new vm = CreateVM(client, "models/weapons/c_models/c_blackbox/c_blackbox_xmas.mdl");
		SetEntPropEnt(vm, Prop_Send, "m_hWeaponAssociatedWith", weapon);
		SetEntPropEnt(weapon, Prop_Send, "m_hExtraWearableViewModel", vm);
		
		new worldmodel = PrecacheModel("models/weapons/c_models/c_grenadelauncher/c_grenadelauncher_xmas.mdl");
		SetEntProp(weapon, Prop_Send, "m_iWorldModelIndex", worldmodel);
		SetEntProp(weapon, Prop_Send, "m_nModelIndexOverrides", worldmodel, _, 0);
	}

public bool:WA_SpellbookActive(clientIdx)
{
	new weapon = GetEntPropEnt(clientIdx, Prop_Send, "m_hActiveWeapon");
	if (!IsValidEntity(weapon))
		return false;
		
	static String:classname[MAX_ENTITY_CLASSNAME_LENGTH];
	GetEntityClassname(weapon, classname, MAX_ENTITY_CLASSNAME_LENGTH);
	if (!strcmp(classname, "tf_weapon_spellbook"))
		return true;
	return false;
} //WA_SpellbookActive(clientIdx)), !WA_SpellbookActive(clientIdx)) 불형으로 체크

//엔티티 entity dpsxlxl 발사체 qkftkcp
public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "tf_projectile_rocket")) //거품, 버블
	{
		SDKHook(entity, SDKHook_Spawn, soldier);
	}
}

public OnEntityDestroyed(entity) //엔티티가 파괴되었을 때

//모델 model ahepf
SetVariantString("models/take/ddddd.mdl");
AcceptEntityInput(client, "SetCustomModel");
SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1); //안하면 애니메이션 적용 안됨

//색 color tor
SetEntityRenderMode(client, RENDER_GLOW);
SetEntityRenderMode(client, RENDER_TRANSCOLOR)
SetEntityRenderColor(client, 255, 255, 255, 255); // r, g, b, a

SetWeaponsInvisible(client) 
{ 
   new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"); 
   SetEntityRenderMode(weapon, RENDER_NONE); 
}  

//메뉴 apsb menu
SetMenuExitButton(info, true); 종료 버튼 생성
SetMenuExitBackButton(info, true); 뒤로가기 버튼 생성
DisplayMenu(menu, Client, MENU_TIME_FOREVER); 시간
AddMenuItem(menu1, "0", "ㅁㅁㄴㅇ", ITEMDRAW_DISABLED); 누르면 끝

MenuAction_Cancel
MenuAction_End
MenuCancel_Exit

MenuCancel_ExitBack

GetMenuItem(메뉴핸들, 선택포지션, 담을 스트링);

GetMenuItem(menu, param2, info, sizeof(info), _, infodesc, sizeof(infodesc));
이게 info란 값은 원래대로 하고 infodesc란건 같은 값인데 프린트문으로 할수있더라고

//콘솔창 그림 zhsthfckd rmfla
PrintToServer("-----------------------------------------");
PrintToServer(" #########    ###      #    #    ########");
PrintToServer("     #      #    #     #   #     ##      ");
PrintToServer("     #      ######     #  #      ########");
PrintToServer("     #     #       #   #    #    ##      ");
PrintToServer("     #    #         #  #     #   ########");
PrintToServer("-----------------------------------------");

//zmffkdldjsxm, 클라이언트
target = GetClientOfUserId(userid)

//어트리뷰트
186 ; STEAM_0:0:29435333

SDKHook_Spawn
SDKHook_SpawnPost

//후크gnzm 터치 touch xjcl
SDKHook_EndTouch    //터치가 끝나는 순간
SDKHook_EndTouchPost //터치가 끝나기 전에

SDKHook_StartTouch //터치가 시작되는 순간
SDKHook_StartTouchPost  // 터치가 시작되기 전에 

SDKHook_Touch //이건 머지 그냥 터치하는 순간인가?
SDKHook_TouchPost //터치하기 전인가?

SDKHook_PostThinkPost //실시간?

post는 터치전에
end는 터치 뒤 터치가 끝나는 순간
star는 터치가 시작되는 순간

SDKHook(Client, SDKHook_StartTouch, GetItem); //아이템먹을수 있게 훅을 걸어줍시다
if(GetEntityFlags(ent) & FL_ONGROUND) //땅  , !FL_ONGROUND == 공중 rhdwnd
{
	SDKHook(Client, SDKHook_StartTouch, 데미지 and 이펙트);
}
!(GetEntityFlags(client) & FL_ONGROUND) 이게 땅에서 사용 불능

SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);


//따옴표 Ekdhavy
"sm_beacon \"%N\""

//고유번호 rhdbqjsgh
decl String:SteamID[32];

GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));

if(StrEqual(SteamID, "STEAM_0:0:71646400"))
{
	PrintToChat(client, "네 맞아요");
}
else
	PrintToChat(client, "no");
	
bool:IsTeamMate(client)
{
	decl String:SteamID[64];
	GetClientAuthString(client, SteamID, 64, true);
	if (StrEqual("STEAM_0:0:64434731", SteamID, false))
	{
		return true;
	}
	if (StrEqual("STEAM_0:0:38235680", SteamID, false))
	{
		return true;
	}
	if (StrEqual("STEAM_0:1:43524116", SteamID, false))
	{
		return true;
	}
	if (StrEqual("STEAM_0:0:56109191", SteamID, false))
	{
		return true;
	}
	return false;
}


AuthId_Steam2, /**< Steam2 rendered format, ex "STEAM_1:1:4153990" */     
AuthId_Steam3, /**< Steam3 rendered format, ex "[U:1:8307981]" */     
AuthId_SteamID64, /**< A SteamID64 (uint64) as a String, ex "76561197968573709" */  

//퍼센트 % vjtpsxm
%d,%i = 정수
%u = 소수 부호 없는 정수
%b = 이진수 값
%f = 부동 소수점 수
%x,%X = 이진수의 진수 표현


%s = 문자열[abcd,가나다 등]

%t,%T = 번역 문자열
%c = 문자출력

%L = 클라이언트 인덱스
%N = 클라이언트 인덱스,플레이어 이름


//잘모르겠는데.. whkvy
Origin[0] //이게 y좌표
Origin[1] //이게 x좌표
Origin[2] //이게 z좌표

//반복문 & 포문 vhans
for(new i = 1; i <= MaxClients; i++)

//에임 dpdla
GetClientAimTarget(client);

decl Float:Position[3];
SetTeleportEndPoint(client, Position);
//TeleportEntity(shaker, Position, NULL_VECTOR, NULL_VECTOR);

bool:SetTeleportEndPoint(client, Float:Position[3])
{
	decl Float:vAngles[3];
	decl Float:vOrigin[3];
	decl Float:vBuffer[3];
	decl Float:vStart[3];
	decl Float:Distance;
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
    //get endpoint for teleport
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer2);

	if(TR_DidHit(trace))
	{   	 
   	 	TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		Distance = -35.0;
   	 	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		Position[0] = vStart[0] + (vBuffer[0]*Distance);
		Position[1] = vStart[1] + (vBuffer[1]*Distance);
		Position[2] = vStart[2] + (vBuffer[2]*Distance);
	}
	else
	{
		CloseHandle(trace);
		return false;
	}
	
	CloseHandle(trace);
	return true;
}

public bool:TraceEntityFilterPlayer2(entity, contentsMask)
{
	return entity > GetMaxClients() || !entity;
}

//시점 tlwja
new Float:attackerpos[3];

SetViewAngle(client, Attackerpos); //내가 적의 위치를 강제로 쳐다봄

public Action:aaaa(attacker)
{
	GetClientEyePosition(attacker, Attackerpos); // 적의 위치를 구함
}


//데이터 팩 vor
public Action:aaaa(Handle:timer, Handle:data)
{
	ResetPack(data);
	new client = ReadPackCell(data);
	new attacker = ReadPackCell(data);
}
new Handle:data;
CreateTimer(0.1, aaaa, data);

public Action:aaaa(Handle:timer, Handle:data)
{
	ResetPack(data);
	new client = ReadPackCell(data);
	new attacker = ReadPackCell(data);
}

new client=GetClientOfUserId(ReadPackCell(data));
new attacker=GetClientOfUserId(ReadPackCell(data));

//리턴 종류 flxjs 핸들
return Plugin_Handled;
return Plugin_Continue;
return Plugin_Changed;
return Plugin_Stop;

//클래스 지정 zmffotm
TF2_SetPlayerClass(client, TFClass_Soldier);

new TFClassType:Class = TF2_GetPlayerClass(client);
if(!(Class == TFClass_Soldier))
if(Class == TFClass_Soldier)
if(TF2_GetPlayerClass(client) != TFClassType:TFClass_Sniper)

//실시간 작동하는 게임 쁘레임!! vmfpdla 프레임
public OnGameFrame()
{
	new i = -1; 
	while ((i=FindEntityByClassname(i, "tf_weapon_scattergun"))!=INVALID_ENT_REFERENCE)
	{
		new client = GetEntPropEnt(i, Prop_Data, "m_hOwnerEntity");
		
		if(IsValidEntity(i))
		{
			if(PlayerCheck(client))
			{
				if(one[client] == true && two[client] == false)
				{
					two[client] = true;
					CreateParticle("utaunt_disco_party", 300.0, i, ATTACH_NORMAL, 0.0,0.0,100.0);
				}
				else if (one[client] == false)
				{
					DeleteParticle(client, particle);
				}
			}
		}
	}
}


//팀 xla
GetClientTeam(2)
if(GetClientTeam(client) == 2)

new clientteam = GetClientTeam(client);
new attackerteam = GetClientTeam(attacker); ///어태커란게 있을때 djxozj

if(GetClientTeam(client) == 2)
{
	해제
}
else
{
	공격
}

if(GetClientTeam(client) == 3)
{
	해제
}
else
{
	공격
}

if(((GetClientTeam(client) == 2 && GetClientTeam(i) == 3) || (GetClientTeam(client) == 3 && GetClientTeam(i) == 2)) && i != client)
//클라이언트팀이 레드고 i팀은 블루 아니면 클라이언트 팀이 블루면 i팀은 레드 i팀과 클라이언트 팀이 아니라면..인가?

TFCond_Stealthed //투명
TFCond_StealthedUserBuffFade //투명인데 공격하면 보이고 그럼 ㅇㅇ


//무기 슬롯 제거 tmffht
TF2_RemoveWeaponSlot(client, 0); //기본적으로 0 주무기 1 보조무기 2 밀리 더 자세한건 api
new P = GetPlayerWeaponSlot(client, TFWeaponSlot_Primary); //영어로 주무기

new wepEnt = GetPlayerWeaponSlot(last_player, TFWeaponSlot_Building);
if(IsValidEntity(wepEnt))
{
	new wepIndex = GetEntProp(wepEnt, Prop_Send, "m_iItemDefinitionIndex"); 
	if(wepIndex == 60)
	{}
}


//무기 끼기 Rlrl, wkdckr
EquipPlayerWeapon(client, iEntity);

new knife = GivePlayerItem(client, "tf_weapon_knife");
SetEntProp(knife, Prop_Send, "m_iItemDefinitionIndex",
SetEntProp(knife, Prop_Send, "m_iEntityLevel", level);  //new level = GetRandomInt(1, 100);
SetEntProp(knife, Prop_Send, "m_bInitialized", 1); 
SetEntProp(knife, Prop_Send, "m_iEntityQuality", 10);

EquipPlayerWeapon(client, knife);


//스폰 tmvhs eptm
TF2_RespawnPlayer(client);
public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_death", Player_Death);
}

//이벤트 후크 dlqpsxm gnzm
EventHookMode_Pre //행동 이전에 실행 하다.
EventHookMode_Post //행동 이후에 실행 한다.
EventHookMode_PostNoCopy //포스트와 이벤트 이름만 필요하다.

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
}

//헐트 gjfxm
public OnPluginStart()
{
	HookEvent("player_hurt", EventHurt);
}


public Action:EventHurt(Handle:Event, const String:Name[], bool:Broadcast)
{ 
	new attacker = GetClientOfUserId(GetEventInt(Event, "attacker"));
	new Client = GetClientOfUserId(GetEventInt(Event, "userid"));        

	new String:Weapon[32];
	GetClientWeapon(attacker, Weapon, sizeof(Weapon));
	
	if(client != attacker)
	{
		if(StrEqual(sWeapon, "무기 암거나")) //StrContains
		{
		}
	}
	
}  

public Action:EventHurt(Handle:Event, const String:Name[], bool:Broadcast)
{ 
	new attacker = GetClientOfUserId(GetEventInt(Event, "attacker"));
	new Client = GetClientOfUserId(GetEventInt(Event, "userid"));        
	
	if(client != attacker)
	{
	}
}  


//타이머 xkdlaj
public Action:a(Handle:timer, any:client)
CreateTimer(0.1, Load, client);

AcceptEntityInput(iEnt, "Kill");

TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE//반복
TIMER_FLAG_NO_MAPCHANGE //이미 작동한 타이머는 수도 없이 돌아가기때문에 저거 해줘야함

new Handle:ClientTimer[MAXPLAYERS + 1];

	if (ClientTimer[client] != INVALID_HANDLE)
		KillTimer(ClientTimer[client]);
	ClientTimer[client] = INVALID_HANDLE;
//나갈때랑 지울때랑 두개하면댐	

public Action:footstep(Handle:timer, any:event)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new Attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(내용)
	{}
	else
	{Plugin_Stop} //을 해줘야한데
	return Plugin_Continue; //해줘야 한데
}

//옵션 dhqtus
TF2Attrib_SetByDefIndex(client, 254, 4.0);
TF2Attrib_RemoveByDefIndex(client, 254);

//맵이 시작될 경우 tlwkr
public OnMapStart()
{
	PrecacheModel("");
}

왜 프리캐싱을 하고 다운로드를 하느냐? 프리캐싱은 꼭 필요한 작업입니다.
정의를 하자면, 미리 모델을 캐쉬 메모리에 저장하여 베드 버퍼링 혹은 오버 플로우가 발생하지 않기위한 방지막입죠, 
다운로드파일은 이 모델을 다운을 해야지 사용자에게 모델이 정확히 보이겠지요. 꼭 일일이 하지 않습니다.

//서버에 들어올경우  && 입장 dlqwkd 
public OnClientPutInServer(client)
OnClientConnected

//서버에 나갈경우 skrka, skrkf
public OnClientDisconnected(client)

//오프셋 설정할때 무기 dhvmtpt
new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
SetEntPropFloat(weapon, Prop_Send, "m_flModelScale",수치);

new iItemDefinitionIndex = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
if(iItemDefinitionIndex == 0)

if(GetEntProp(client, Prop_Send, "m_bIsCoaching")) // 캐릭터가 다른 사람 코치해주고 있나 체크
SetEntPropFloat(index, Prop_Send, "m_flChargeLevel", 100.0); //우버

stock modelsize(client, Float:scale)
{
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", scale);
	SetEntPropFloat(client, Prop_Send, "m_flStepSize", 18.0 * scale);
}

//fnr 옷
tf_wearable

//인클루드 모음 dlszmffnem
#include <setviewangle> //시점
#include <tf2attributes> //옵션 dhqtus
#include <tf2> //치트
#include <tf2_stocks> //클래스
#include <tf2items> //아이템즈
#include <tf2items_giveweapon> //기브
#include <sdkhooks> //후크
#include <sdktools>

//기브 rlqm
TF2Items_GiveWeapon(Client, 4526);

//명령어 모음 audfuddj akf 말
#define cc "!" //리턴 플러그인 핸들 알아서 해주는거같음

//맥스플레이어 aortmvmffpdldj
new aaa[MAXPLAYERS+1];
new bool:aaa[MAXPLAYERS+1] = false;
new Float:aaa[MAXPLAYERS+1] = 0.0;
new Handle:nextItem[MAXPLAYERS+1];

public Action:aaaa(dddd, args)
take(client); 
PrintToChat(client, "aa");

Vip[client] == true

public OnPluginStart()
{
	RegConsoleCmd("say", SayHook);
	RegConsoleCmd("sm_ag", aaaa);
	RegAdminCmd("sm_tt", aaaa, ADMFLAG_RESERVATION);
	RegAdminCmd("sm_tt", aaaa, ADMFLAG_KICK , "asd");
	
	AddCommandListener(Command_Say, "say");
	AddCommandListener(Command_Say, "say_team");
}
public Action:aaaa(client, args)
{
	take(client);
	return Plugin_Handled;
}
public Action:SayHook(Client, args)
{
	new String:Msg[256];
	GetCmdArgString(Msg, sizeof(Msg));
	Msg[strlen(Msg)-1] = '\0';
	
	if(StrEqual(Msg[1], cc, false))
	{
		WCMenu(Client);
	}
	return Plugin_Handled;
}

public Action:Command_Say(client, String:command[], argc
{
}

//랜덤 foseja
GetRandomFloat(min.0, Max.0);
GetRandomInt(min, max);

//이름 dlfma, spdla
decl String:aName[MAX_NAME_LENGTH];
GetClientName(client, aName, sizeof(aName));

//어드민 djemals
if(GetUserAdmin(Client) == INVALID_ADMIN_ID) 어드민이냐?
if(GetUserAdmin(Client) != INVALID_ADMIN_ID) 어드민 아니냐?
 if(GetAdminFlag(Client) == Admin_Reservation) //플래그 설정
 
 if (!GetAdminFlag(GetUserAdmin(client), Admin_Slay))
 
//어드민 잘댐
stock bool:IsClientAdmin(client)
{
	new AdminId:Cl_ID;
	Cl_ID = GetUserAdmin(client);
	if(Cl_ID != INVALID_ADMIN_ID)
		return true;
	return false;
}

GetClientMaxCredit(client) {
	if(client <= 0 || client > MaxClients || !IsClientInGame(client)) return 0;
	new AdminId:admin = GetUserAdmin(client), Credit = playerMaxCredit;
	if(GetAdminFlag(admin, flagy, Access_Effective)) Credit = flagMaxCredit;
	if(GetAdminFlag(admin, Admin_Generic, Access_Effective)) Credit = adminMaxCredit;
	return Credit;
}


//이런식으로 GetUserFlagBits 이걸로 어드민 권한에 따라 옵션? 을 줄 수 있는거같음..
stock bool:IsClientAdmin(client)
{
	new flags = GetUserFlagBits(client);
	if (flags & ADMFLAG_GENERIC || flags & ADMFLAG_ROOT)
		return true;             
    return false;
}

stock bool:IsClientAdmin(client)
{
	if (GetUserFlagBits(client) & ADMFLAG_ROOT)
		return true;             
	return false;
}


//치트 clxm
TFCond:46
TF2_AddCondition(Client, TFCond_HalloweenSpeedBoost, -1.0);
TF2_AddCondition(Client, TFCond:46, -1.0);

TF2_RemoveCondition(client, TFCond:46);

96이 탄 모아주는 거임

//디컴파일한거임
public Action:SoundHook(clients[64], &numClients, String:sound[256], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	new var1;
	if (entity > 0 && entity <= MaxClients)
	{
		if (IsClientInGame(entity))
		{
			new client = entity;
			new wep = GetEntPropEnt(client, PropType:0, "m_hActiveWeapon", 0);
			if (!IsValidEntity(wep))
			{
				return Action:0;
			}
			if (StrContains(sound, "flaregun", false) != -1)
			{
				Format(sound, 256, "weapons/slam/throw.wav");
				PrecacheSound(sound, false);
				EmitSoundToClient(client, sound, -2, channel, level, flags, volume, pitch, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				return Action:1;
			}
		}
	}
	return Action:0;
}

AddNormalSoundHook(RandonmSH);
AddNormalSoundHook(view_as<NormalSHook>(RandonmSH));

AirDefense(attacker, client)
{
    new Float:vector[3];
            
    new Float:attackerloc[3];
    new Float:clientloc[3];
            
    GetClientAbsOrigin(attacker, attackerloc);
    GetClientAbsOrigin(client, clientloc);
            
    MakeVectorFromPoints(attackerloc, clientloc, vector);
            
    NormalizeVector(vector, vector);
    ScaleVector(vector, -150.0);
            
    TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, vector);
}

#include <sourcemod>
#include "sdkhooks"
#include <colors>

new String:Path[MAXPLAYERS+1];

public OnPluginStart()
{
	RegConsoleCmd("say", Command_Say);
	
	HookEvent("player_death", EventDeath);
	
	BuildPath(Path_SM, Path, MAXPLAYERS+1, "data/TAKE_kill_System.txt")
}

new kill[MAXPLAYERS + 1];

public OnClientPutInServer(Client)
{
	CreateTimer(0.1, Load, Client);
}

public OnClientDisconnect(Client)
{
	Save(Client);
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
		if(msg[0] != '!' && msg[1] != '/' && msg[0] != '/' && msg[1] != '@' && msg[1] != '' && msg[1] != '') 
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
				CPrintToChatAllEx(Client,"\x01%s {teamcolor}%s {default}: \x07FFFFFF%s",tag, aName, msg[1]);
				return Plugin_Handled;
			}
		}
		return Plugin_Continue;
	}
	if( IsPlayerAlive(Client) != true) //살아있지 않은 경우
	{
		if(msg[0] != '!' && msg[1] != '/' && msg[0] != '/' && msg[1] != '@' && msg[1] != '' && msg[1] != '') 
		{
			CPrintToChatAllEx(Client,"*패배자*%s {teamcolor}%s {default}: \x07FFFFFF%s",Client, aName, msg[1]);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public EventDeath(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new Client = GetClientOfUserId(GetEventInt(Spawn_Event, "userid"));
	new Attacker = GetClientOfUserId(GetEventInt(Spawn_Event, "attacker"));

	if(PlayerCheck(Client) && (PlayerCheck(Attacker)))
	{
		if(Client != Attacker)
		{
			kill[Attacker]++;
		}
	}
}


public Save(client)
{
	if(client > 0 && IsClientInGame(client))
	{
		new String:SteamID[32];
		GetClientAuthString(client, SteamID, 32);
	
		decl Handle:Vault;
	
		Vault = CreateKeyValues("Vault");
	
		if(FileExists(Path))
		{
			FileToKeyValues(Vault, Path);
		}
	
		if(kill[client] > 0)
		{	
			KvJumpToKey(Vault, "kill", true);
			KvSetNum(Vault, SteamID, kill[client]);
			KvRewind(Vault);
		}
		else
		{
			KvJumpToKey(Vault, "kill", false);
			KvDeleteKey(Vault, SteamID);
			KvRewind(Vault);
		}
		
		KvRewind(Vault);
	
		KeyValuesToFile(Vault, Path);
	
		CloseHandle(Vault);
	}
}

public Action:Load(Handle:Timer, any:client)
{
	if(client > 0 && client <= MaxClients)
	{
		new String:SteamID[32];
		GetClientAuthString(client, SteamID, 32);

		decl Handle:Vault;
	
		Vault = CreateKeyValues("Vault");

		FileToKeyValues(Vault, Path);

		KvJumpToKey(Vault, "kill", false);
		kill[client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);
		
		KvRewind(Vault);

		CloseHandle(Vault);
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
#include <sourcemod>
#include <string.inc>
#include "sdkhooks" 
#include <colors>

public Plugin:myinfo = 
{
	name = "[TF2] level",
	author = "TAKE 2",
	description = "Level",
	version = "1.2",
	url = "smf"
}
 
new String:Path[MAXPLAYERS+1];

new EXP[MAXPLAYERS+1] = 0;
new Level[MAXPLAYERS+1] = 1;
new MAXEXP[MAXPLAYERS+1] = 25;

new Handle:INFO2 = INVALID_HANDLE;

public OnPluginStart()
{
		RegConsoleCmd("say", Command_Say);
		
		HookEvent("player_death", EventDeath)
	
		BuildPath(Path_SM, Path, 64, "data/take_Level.txt");
}

public OnClientPutInServer(Client)
{
	CreateTimer(0.1, Load, Client);
}
public EventDeath(Handle:Spawn_Event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new Client = GetClientOfUserId(GetEventInt(Spawn_Event, "userid"));
	new Attacker = GetClientOfUserId(GetEventInt(Spawn_Event, "attacker"));

	if(Client > 0 && Client <= MaxClients && Attacker > 0 && Attacker <= MaxClients)
	{
		if( Client != Attacker )
		{
			PrintToChat(Attacker, "\x05[킬] - \x0420경험치 증가");
	
			EXP[Attacker] += 20;
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
			KvSetNum(Vault, SteamID, Level[Client]);
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

		KvJumpToKey(Vault, "EXP", false);
		EXP[Client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);

		KvRewind(Vault);

		CloseHandle(Vault);
	}
}

public Action:ShowCountText2(Handle:timer)
{
	for(new i = 1;i <= MaxClients; i++)
	{
		if(IsClientConnectedIngame(i) == true)
		{
			MAXEXP[i] = Level[i] * 20;
			decl String:finalcount[256];
			Format(finalcount, sizeof(finalcount), "내 레벨 : %d\n내 경험치: %d / %d", Level[i], EXP[i], MAXEXP[i]);

			new Handle:buffer = StartMessageOne("KeyHintText", i);
			BfWriteByte(buffer, 1);
			BfWriteString(buffer, finalcount);
			EndMessage();

	 		CreateTimer(0.5, lvp, i);
		}
	}
}
public Action:Command_Say(Client, Args)
{
	new String:name[256], String:msg[256];
	GetClientName(Client, name, 256);
		
	StripQuotes(msg);
	GetCmdArgString(msg, sizeof(msg));
	msg[strlen(msg) -1] = '\0';

	if(IsPlayerAlive(Client) == true)
	{
		if(msg[1] != '!' && msg[0] != '!' && msg[1] != '/' && msg[0] != '/' && msg[1] != '@')
		{
			CPrintToChatAllEx(Client,"\x03%s \x01: %s \x04 [Lv. %d]", name, msg[1], Level[Client]);
			return Plugin_Handled;
		}
		return Plugin_Continue;
	}
	if( IsPlayerAlive(Client) != true) //살아있지 않은 경우
	{
		if(msg[0] != '/' && msg[1] != '!' && msg[1] != '/' && msg[1] != '@')
		{
			CPrintToChatAllEx(Client,"*패배자* \x03%s \x01: %s \x04 [Lv. %d]", name, msg[1], Level[Client]);
			return Plugin_Handled;
		}
	}
	if(GetClientTeam(Client) == 1) //관전자일 경우
	{	
		if(msg[0] != '/' && msg[1] != '!' && msg[1] != '/' && msg[1] != '@')
		{
			CPrintToChatAllEx(Client,"*관광객* \x03%s \x01: %s \x04 [Lv. %d]", name, msg[1], Level[Client]);
			return Plugin_Handled;
		}
	}
	return Plugin_Continue;
}

public Action:lvp(Handle:timer, any:Client)
{
	if(EXP[Client] >= MAXEXP[Client])
	{
		PrintToChat(Client, "\x05[Level Up] - \x04레벨업 하셨습니다.");
		Level[Client] += 1;
		EXP[Client] = 0;
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
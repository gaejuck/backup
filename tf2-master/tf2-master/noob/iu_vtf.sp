
#include <sourcemod>
#include <sdktools>
#include "sdkhooks"

new L;
new bool:aROOT[MAXPLAYERS+1] = false;

public OnClientPostAdminCheck(client)
{
	new flags = GetUserFlagBits(client);   
	if(IsClientAdmin(client) == true)
	{
		if(!(flags & ADMFLAG_RESERVATION))
		{
			aROOT[client] = false;
		}
		aROOT[client] = true;
	}
}

public OnClientDisconnect(client)
{
	if(aROOT[client] == true)
	{
		aROOT[client] = false;
	}
}

public OnClientSayCommand_Post(client, const String:command[], const String:sArgs[])
{
	if(aROOT[client] == true)
	{
		if (strcmp(sArgs, "!소환술", false) == 0)
		{
			skill2(client);
		}
	}
}

public OnMapStart()
{
	L = PrecacheModel("materials/image/iu_v13.vmt", true); //★★★★★★★★★★★이부분
	new String:VmtCode[256], String:VtfCode[256];
	Format(VmtCode, 256, "materials/image/iu_v13.vmt");//★★★★★★★★★★★이부분
	Format(VtfCode, 256, "materials/image/iu_v13.vtf");//★★★★★★★★★★★이부분

	AddFileToDownloadsTable(VmtCode);
	AddFileToDownloadsTable(VtfCode);
	
	PrecacheModel(VmtCode, true);
}

public Action:skill2(Client)
{	
	CreateTimer(0.1, skill1, Client);
}

public Action:skill1(Handle:timer, any:Client)
{
	if(PlayerCheck(Client))
	{
		new Float:poss[3];
		GetClientEyePosition(Client, poss);
		poss[2] = poss[2] - 20.0;
		TE_SetupGlowSprite(poss, L, 3.0, 0.3, 255);
		TE_SendToAll();
		
		decl Float:baseposition[3], Float:targetposition[3];

		GetClientEyePosition(Client, baseposition);
		baseposition[2] -= 30;
		
		ShakeClientScreen(Client, 10.0, 5.0, 2.0);
		for(new i = 1; i <= MaxClients; i++)
		{
			if(PlayerCheck(i))
			{
				GetClientEyePosition(i, targetposition);
				targetposition[2] -= 30;
				if(GetVectorDistance(baseposition, targetposition) <= 1000.0)
				{
					if(IsPlayerAlive(i))
					{
						if(GetClientTeam(i) != GetClientTeam(Client))
						{
							ShakeClientScreen(i, 10.0, 5.0, 2.0);
						}
					}
				}
			}
		}
	}
}

stock ShakeClientScreen(client, Float:amplitude, Float:frequency, Float:duration)
{
	// 화면 흔들기 유저메시지가 유효하지 않다면 정지.
	new Handle:hShake = StartMessageOne("Shake", client);
	if (hShake == INVALID_HANDLE)
	{
		return;
	}
	
	// 화면 흔들기 정보를 유저메시지 핸들에 작성한다.
	BfWriteByte(hShake, 0);
	BfWriteFloat(hShake, amplitude);
	BfWriteFloat(hShake, frequency);
	BfWriteFloat(hShake, duration);
	
	// 유저메시지를 끝내고 클라이언트에게 전송한다.
	EndMessage();
}

stock bool:IsClientAdmin(Client)
{
	return (GetUserAdmin(Client) == INVALID_ADMIN_ID) ? false : true;
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

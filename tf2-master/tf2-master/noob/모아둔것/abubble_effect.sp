#include <sourcemod>
#include <sdktools> 

// "materials/trails/fire" 이거는 따로 vmt가 있어야 하는거고 아래는 기본 내장되어 있음
// "materials/sprites/strider_blackbal"
//materials/sprites/redglow1 등등

new Effect;

public OnMapStart()
{	
	Effect = PrecacheModel("materials/sprites/minimap_icons/red_player.vmt", true);
	new String:VmtCode[256], String:VtfCode[256];
	Format(VmtCode, 256, "materials/sprites/minimap_icons/red_player.vmt");
	Format(VtfCode, 256, "materials/sprites/minimap_icons/red_player.vtf");

	AddFileToDownloadsTable(VmtCode);
	AddFileToDownloadsTable(VtfCode);
	
	PrecacheModel(VmtCode, true);
}

public OnClientPutInServer(Client)
{
	if(PlayerCheck(Client))
	{
		CreateTimer(0.1, footstep, Client, TIMER_REPEAT);
	}
}

public Action:footstep(Handle:timer, any:client)
{
	new Float:clientposition[3];
	GetClientAbsOrigin(client, clientposition);
	BubblesEffect(clientposition, clientposition, Effect, 50.0, 10, 50.0);
}

stock BubblesEffect(const Float:m_vecMins[3], const Float:m_vecMaxs[3], Model, Float:Height, Amount, Float:Speed)
{
 TE_Start("Bubbles");
 TE_WriteVector("m_vecMins", m_vecMins); // 버블이 퍼지는 최소거리.
 TE_WriteVector("m_vecMaxs", m_vecMaxs); // 버블이 퍼지는 최대거리. 최소거리부터 최대거리까지의 선 위에서서 버블이 퍼진다
 TE_WriteNum("m_nModelIndex", Model); // 이펙트 메터리얼
 TE_WriteFloat("m_fHeight", Height); // 얼마나 높이 올라갈 것인가
 TE_WriteNum("m_nCount", Amount); // 몇개를 소환 할 것인가
 TE_WriteFloat("m_fSpeed", Speed); // 어느정도의 속도로 퍼질 것인가 (올라가는 속도에는 지장 없음, 버블이 퍼지는 정도 라고 보면된다)
 TE_SendToAll();
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

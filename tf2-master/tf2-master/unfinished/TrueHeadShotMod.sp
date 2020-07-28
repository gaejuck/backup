#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new bool:head[MAXPLAYERS+1] = false;

new lasthittedgroup[MAXPLAYERS + 1];

new String:hitboxname[8][64] = {
	
	"몸통",
	"머리",
	"가슴",
	"배",
	"왼팔",
	"오른팔",
	"왼다리",
	"오른다리"
};

public OnPluginStart()
{
	RegConsoleCmd("sm_head", only);
}

public OnClientPutInServer(client){
	
	SDKHook(client, SDKHook_TraceAttack, TraceAttackHook);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamageHook);
}

public Action:only(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			SDKHook(i, SDKHook_TraceAttack, TraceAttackHook);
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamageHook);
		}
	}
	if(head[client] == false)
	{
		head[client] = true;
		PrintToChat(client, "\x03저격 총을 들고 오직 머리만 사용할 수 있습니다");
	}
	else
	{
		head[client] = false;
		PrintToChat(client, "\x03해제");
	}
	return Plugin_Handled;
}

public Action:TraceAttackHook(victim, &attacker, &inflictor, &Float:damage, &damagetype, &ammotype, hitbox, hitgroup)
{
	if(AliveCheck(victim) && AliveCheck(attacker))
	{
		if(head[attacker] == true)
		{
			lasthittedgroup[victim] = hitgroup;
			return Plugin_Continue;
		}
	}
	return Plugin_Continue;
	
	
} 

public Action:OnTakeDamageHook(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	decl String:sWeapon[64];
		
	if(AliveCheck(attacker) && AliveCheck(client))
	{
		GetClientWeapon(attacker, sWeapon, sizeof(sWeapon));
		if(StrEqual(sWeapon, "tf_weapon_sniperrifle"))
		{
			if(head[attacker] == true) 
			{
				new hitgroup = lasthittedgroup[client];
						
				if(hitgroup != 1) //헤드샷이 아닐경우
				{
			
					decl String:clientname[64], String:attackername[64];
							
					GetClientName(client, clientname, 64);
					GetClientName(attacker, attackername, 64);
							
					decl String:msg[256];
							
					Format(msg, 256, "\x03%s \x01님의 \x04%s\x01(을)를 \x04%s\x01(으)로 맟춰서 \x04%d\x01의 데미지는 \x04무효\x01입니다", clientname, hitboxname[lasthittedgroup[client]], sWeapon, RoundToNearest(damage));
					PrintToChat(attacker, msg);
						
					return Plugin_Handled;
							
				}
				else
					return Plugin_Continue; //헤드샷일 경우 데미지 받음
			}
		}
		else
			return Plugin_Handled; //저격소총이 아닐 경우 데미지 제거
	}
	return Plugin_Continue; 

}

public bool:AliveCheck(client)
{
	if(client > 0 && client <= MaxClients)
		if(IsClientConnected(client) == true)
			if(IsClientInGame(client) == true)
				if(IsPlayerAlive(client) == true) return true;
				else return false;
			else return false;
		else return false;
	else return false;
}
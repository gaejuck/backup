#include <sdkhooks>
#include <sdktools> 
#include <tf2attributes>
#include <tf2_stocks>

#include <tf2itemsinfo>

#define MODEL_TT 		"models/player/items/scout/scout_trackjacket.mdl"

//------------------------- 변신 -------------------------//
new bool:HumanTiTan[MAXPLAYERS+1] = false;
new bool:EvolutionCheck[MAXPLAYERS+1] = false;
new Float:SkillEvolutionTime[MAXPLAYERS+1];

//------------------------- 거인 -------------------------//
new bool:TiTan[MAXPLAYERS+1] = false;
new bool:WomanTiTan[MAXPLAYERS+1] = false;
new bool:WomanTiTanSkill_Hand[MAXPLAYERS+1] = false;
new Float:SkillHandTime[MAXPLAYERS+1];

//------------------------- 라운드 시작 -------------------------//
new bool:g_bWaitingForPlayers;

//------------------------- 플러그인 시작 -------------------------//
public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_death", Player_Death);
	
	HookEvent("post_inventory_application", OnPlayerInventory, EventHookMode_Post);
	
	RegConsoleCmd("sm_cc", aaaa);
	RegConsoleCmd("sm_ccc", ccc);
	RegConsoleCmd("sm_dd", dd);
}

//------------------------- 서버 입장 / 나감 -------------------------//

public OnClientPostAdminCheck(client)
{
	HumanTiTan[client] = false;
	WomanTiTan[client] = false;
	TiTan[client] = false;
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public OnClientDisconnect(client)
{
	HumanTiTan[client] = false;
	WomanTiTan[client] = false;
	TiTan[client] = false;
}

//------------------------- 테스트용 명령어 -------------------------//

public Action:aaaa(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if (IsValidClient(i))
		{
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			if(GetClientTeam(i) == 3)
				TiTan[i] = true;
				
			if(GetClientTeam(i) == 2) 
				HumanTiTan[i] = true;
		}
	}
	PrintToChat(client, "ok");
	return Plugin_Handled;
}

public Action:dd(client, args)
{
	PrintToChat(client, "ok");
	Round_Win();
	
	// CreateParticle("soldierbuff_blue_soldier", 3.0, client, 1);
	
	return Plugin_Handled;
}

// TimeOver()
// {
	// new iEnt = FindEntityByClassname(iEnt, "game_round_win");
	// if (iEnt < 1)
	// {
		// iEnt = CreateEntityByName("game_round_win", -1);
		// if (IsValidEntity(iEnt))
		// {
			// DispatchSpawn(iEnt);
		// }
		// LogMessage("Smash Fortress :: Unable to find or create the game_round_win entity!");
		// return 3;
	// }
	// new iWin = 3;
	// SetVariantInt(iWin);
	// AcceptEntityInput(iEnt, "SetTeam", -1, -1, 0);
	// AcceptEntityInput(iEnt, "RoundWin", -1, -1, 0);
	// return 3;
// }

public Action:ccc(client, args)
{
	decl String:arg[65];
	new bool:HasTarget = false;
		
	GetCmdArg(1, arg, sizeof(arg));
		
	HasTarget = true;	
	
	decl String:target_name[MAX_TARGET_LENGTH];
	
	if (HasTarget)
	{
		decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
		
		if ((target_count = ProcessTargetString(
				arg,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_CONNECTED,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
		{
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}
		
		for (new i = 0; i < target_count; i++)
		{
			WomanTiTanSkill_Hand[target_list[i]] = true;
		}
	}
	return Plugin_Handled;
}

//------------------------- 슬롯 -------------------------//

public Action:OnPlayerInventory(Handle:hEvent, String:strEventName[], bool:bDontBroadcast)
{
	if(g_bWaitingForPlayers) return;
	
	new client = GetClientOfUserId(GetEventInt(hEvent, "userid"));
	if (!IsValidClient(client)) return;
    
	if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Scout)
	{
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 1);
	}
	
	if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Heavy)
	{
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 1);
	}
	if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Medic)
	{
		TF2_RemoveWeaponSlot(client, 0);
		TF2_RemoveWeaponSlot(client, 1);
	}
	if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Sniper)
	{
		TF2_RemoveWeaponSlot(client, 1);
	}
	
	if(HumanTiTan[client])
	{
		ChangePlayerWeaponSlot(client, 2);
	}
}

//------------------------- 시작 -------------------------//

public TF2_OnWaitingForPlayersStart()
{
	ChangeTeams();
	g_bWaitingForPlayers = true;
}

public TF2_OnWaitingForPlayersEnd() g_bWaitingForPlayers = false;
	
public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(g_bWaitingForPlayers) return;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(GetClientTeam(client) == 3)
	{
		new chances = GetRandomInt(1, 100);
		new count;
		if(chances <= 50)
		{
			WomanTiTan[client] = true;
			for(new i = 1; i <= MaxClients; i++)
				if(IsClientInGame(i))
					if(WomanTiTan[i])
						count++;
						
			if(count <= 2)
			{
				MakeWomanTitan(client, 3.0, 3000.0);
				count = 0;
			}
			else
			{
				MakeTitan(client, 2.3, 2500.0);		
				WomanTiTan[client] = false;
			}
		}
		else 
		{	
			MakeTitan(client, 2.3, 2500.0);	
		}
	}
	else if(GetClientTeam(client) == 2)
	{
		HumanTiTan[client] = false;
	
		new chances = GetRandomInt(1, 100);
		new count;
		if(chances <= 50)
		{
			HumanTiTan[client] = true;
			for(new i = 1; i <= MaxClients; i++)
				if(IsClientInGame(i))
					if(HumanTiTan[i])
						count++;
						
			if(count <= 2)
			{
				HumanTiTan[client] = true;
				
				if(HumanTiTan[client])
				{
					TF2_SetPlayerClass(client, TFClass_Scout);
					TF2_RegeneratePlayer(client);

					PrintToChat(client, "\x04당신은 거인으로 변신할 수 있습니다. 휠클릭으로 변신하세요.");
				}
				count = 0;
			}
			else
				HumanTiTan[client] = false;
		}
		else
		{
			if(TF2_GetPlayerClass(client) != TFClassType:TFClass_Scout && TF2_GetPlayerClass(client) != TFClassType:TFClass_Sniper)
			{
				switch(GetRandomInt(0,1))
				{
					case 0:
					{
						TF2_SetPlayerClass(client, TFClass_Scout);
						TF2_RegeneratePlayer(client);
						ChangePlayerWeaponSlot(client, 2);
					}
					case 1:
					{
						TF2_SetPlayerClass(client, TFClass_Sniper);
						TF2_RegeneratePlayer(client);
						
						TF2_RemoveWeaponSlot(client, 1);
						
						ChangePlayerWeaponSlot(client, 0);
					}
				}
			}
			else if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Scout)
				ChangePlayerWeaponSlot(client, 2);
		}
	}
}

//------------------------- 데스 -------------------------//

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	if(g_bWaitingForPlayers) return;
	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	
	if(IsValidClient(client) && IsValidClient(attacker) && (client != attacker))
	{
		if(TiTan[client] || WomanTiTan[client])
		{
			TiTan[client] = false;
			WomanTiTan[client] = false;
			CreateSmoke(client, false);
			TF2Attrib_RemoveByName(client, "max health additive bonus");
			SetEntProp(client, Prop_Send, "m_iHealth", 125);
		}
		else if(HumanTiTan[client])
		{
			if(EvolutionCheck[client])
			{
				CreateSmoke(client, false);
			
				HumanTiTan[client] = false;
				EvolutionCheck[client] = false;
				
				TF2Attrib_RemoveByName(client, "max health additive bonus");
				SetEntProp(client, Prop_Send, "m_iHealth", 125);
			}
			else
				HumanTiTan[client] = false;
		}
	}
}

//------------------------- 데미지 -------------------------//

public Action:OnTakeDamage(titan, &client, &inflictor, &Float:fDamage, &iDamagetype, &iWeapon, Float:fForce[3], Float:fForcePos[3])
{
	if(g_bWaitingForPlayers) return Plugin_Continue;
	 
	if (IsValidClient(titan) && IsValidClient(client) && (titan != client))
	{

		if (TiTan[client] || WomanTiTan[client])
		{
			fDamage = 500.0;
			return Plugin_Changed;
		}
		else
		{
			decl String:szClassName[64], Float:position[3];
			GetEntityClassname(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon"), szClassName, sizeof(szClassName));
			GetEntPropVector(titan, Prop_Send, "m_vecOrigin", position);
			
			new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
			
			if (weapon == GetPlayerWeaponSlot(client, TFWeaponSlot_Melee) && GetBackAttack(titan, client) && GetClientHitBox(client, 1))
			{
				if(WomanTiTan[titan] && WomanTiTanSkill_Hand[titan])
				{
					fDamage = 0.0;
					PrintToChat(client, "%N님이 여성형 거인 손으로 막았습니다.", titan);
					PrintToChat(titan, "%거인 손 스킬로 %N님의 공격을 막았습니다.", client);
					EmitSoundToClient(titan, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
					EmitSoundToClient(client, "player/spy_shield_break.wav", _, _, _, _, 0.7, _, _, position, _, false);
					return Plugin_Changed;
				}
				else
				{
					fDamage = 9999.0;
					return Plugin_Changed;
				}
			}
			else if(StrEqual(szClassName, "tf_weapon_sniperrifle") && GetClientHitBox(client, 1))
			{
				fDamage = 0.0;
				TF2_StunPlayer(titan, 10.0, _, TF_STUNFLAGS_BIGBONK, client);
				return Plugin_Changed;
			}
			else if(HumanTiTan[client] && EvolutionCheck[client])
			{
				fDamage = 500.0;
				return Plugin_Changed;
			}
			else if(weapon == GetPlayerWeaponSlot(client, 0) && GetBackAttack(titan, client) && GetClientHitBox(client, 2))
			{
				fDamage = 0.0;
				PrintToChat(client, "히트박스 뒷 목");
				return Plugin_Changed;
			}
			else
			{
				fDamage = 0.0;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue; 
}

//------------------------- 키 -------------------------//

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(g_bWaitingForPlayers) return Plugin_Continue;
	
	if(WomanTiTan[client])
	{
		if(CheckSkillHandCoolTime(client, 10.0))
		{
			if(GetClientButtons(client) & IN_ATTACK2)
			{
				CreateParticle("soldierbuff_blue_soldier", 3.0, client, 1);
				PrintToChat(client, "3초 동안 손으로 목 뒤를 막습니다.");
				WomanTiTanSkill_Hand[client] = true;
				SkillHandTime[client] = GetEngineTime()
				CreateTimer(3.0, SkillHandTimer, client);
			}
		}
	}
		
	if(HumanTiTan[client])
	{
		if(CheckSkillEvolutionTime(client, 1.0))
		{
			if(GetClientButtons(client) & IN_ATTACK3)
			{
				if(EvolutionCheck[client] == false)
				{
					if(CheckSkillEvolutionTime(client, 10.0))
					{
						PrintToChat(client, "10초 동안 거인이 됩니다. (푸는건 자유)");
						SkillEvolutionTime[client] = GetEngineTime();
						MakeHumanTitan(client, 3.5, 4000.0);
						EvolutionCheck[client] = true;
						CreateTimer(10.0, SkillEvolution, client);
					}
				} 
				else
				{
					MakeHumanTitan(client, 1.0, 0.0);
					EvolutionCheck[client] = false;
				}
			}
		}
	}
	return Plugin_Continue;
}

//------------------------- 타이머 -------------------------//

public Action:SkillHandTimer(Handle:timer, any:client)
{
	WomanTiTanSkill_Hand[client] = false;
	PrintToChat(client, "앞으로 7초간 스킬을 사용 불가합니다.");
}

public Action:SkillEvolution(Handle:timer, any:client)
{
	MakeHumanTitan(client, 1.0, 0.0);
	EvolutionCheck[client] = false;
	PrintToChat(client, "다시 변신 스킬을 사용할 수 있습니다.");
}

//------------------------- 쿨타임 -------------------------//

stock bool:CheckSkillHandCoolTime(any:iClient, Float:fTime)
{
	if(!IsValidClient(iClient)) return false;
	if(GetEngineTime() - SkillHandTime[iClient] >= fTime) return true;
	else return false;
}

stock bool:CheckSkillEvolutionTime(any:iClient, Float:fTime)
{
	if(!IsValidClient(iClient)) return false;
	if(GetEngineTime() - SkillEvolutionTime[iClient] >= fTime) return true;
	else return false;
}

//------------------------- 함수 : 거인 -------------------------//

stock MakeHumanTitan(client, Float:size, Float:health)
{
	PrecacheModel("models/player/soldier.mdl", true);
	
	SetVariantString("models/player/soldier.mdl");
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1); 
				
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", size);
	UpdatePlayerHitbox(client, size);
	SetEntPropFloat(client, Prop_Send, "m_flStepSize", size * 18.0, 0);
	CreateSmoke(client, false); 
	
	TF2Attrib_SetByName(client, "max health additive bonus", health);
	
	if(health == 0.0)
	{
		SetVariantString("");
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		TF2Attrib_RemoveByName(client, "max health additive bonus");
		
		SetEntProp(client, Prop_Send, "m_iHealth", 125);
	}
	else
		TF2_RegeneratePlayer(client);
}


stock MakeWomanTitan(client, Float:size, Float:health)
{
	WomanTiTan[client] = true;
	
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", size);
	UpdatePlayerHitbox(client, size);
	// SetEntPropFloat(client, Prop_Send, "m_flStepSize", size * 18.0, 0);
	CreateSmoke(client, true); 
	
	TF2Attrib_SetByName(client, "max health additive bonus", health);
	
	TF2_SetPlayerClass(client, TFClass_Medic);
	TF2_RegeneratePlayer(client);
	
	PrintToChat(client, "\x04당신은 여성형 거인입니다. 우클릭으로 손 막기 스킬을 사용할 수 있습니다.");
	
	ChangePlayerWeaponSlot(client, 2);
}

stock MakeTitan(client, Float:size, Float:health)
{
	TiTan[client] = true;
	
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", size);
	UpdatePlayerHitbox(client, size);
	// SetEntPropFloat(client, Prop_Send, "m_flStepSize", size * 18.0, 0);
	CreateSmoke(client, true); 
	
	TF2Attrib_SetByName(client, "max health additive bonus", health);
	
	TF2_SetPlayerClass(client, TFClass_Heavy);
	TF2_RegeneratePlayer(client);
	PrintToChat(client, "\x04당신은 일반 거인입니다.");
	
	ChangePlayerWeaponSlot(client, 2);
}

//------------------------- 함수 : 히트박스 머리 / 몸통 -------------------------//

stock bool:GetClientHitBox(iClient, Hit)
{
	if (!IsValidClient(iClient))
		return false;
	decl Float:flStartPos[3];
	decl Float:flEyeAng[3];
	GetClientEyePosition(iClient, flStartPos);
	GetClientEyeAngles(iClient, flEyeAng);
	new Handle:hTrace = TR_TraceRayFilterEx(flStartPos, flEyeAng, MASK_SHOT, RayType_Infinite, TraceRayDontHitEntity, iClient);
	new iHitEntity = TR_GetEntityIndex(hTrace);
	new iHitGroup = TR_GetHitGroup(hTrace);
	CloseHandle(hTrace);
	if (!IsValidClient(iHitEntity))
		return false;
	if (GetClientTeam(iClient) != GetClientTeam(iHitEntity))
		if (iHitGroup == Hit)
			return true;
	return false;
}

//------------------------- 함수 : 뒤 -------------------------//

stock bool:GetBackAttack(iClient, iAttacker)
{
	decl Float:flMyPos[3];
	decl Float:flHisPos[3];
	decl Float:flMyDirection[3];
	GetClientAbsOrigin(iClient, flMyPos);
	GetClientAbsOrigin(iAttacker, flHisPos);
	GetClientEyeAngles(iClient, flMyDirection);
	GetAngleVectors(flMyDirection, flMyDirection, NULL_VECTOR, NULL_VECTOR);
	NormalizeVector(flMyDirection, flMyDirection);
	ScaleVector(flMyDirection, 32.0);
	AddVectors(flMyDirection, flMyPos, flMyDirection);
	decl Float:p[3];
	decl Float:s[3];
	MakeVectorFromPoints(flMyPos, flHisPos, p);
	MakeVectorFromPoints(flMyPos, flMyDirection, s);
	if (GetVectorDotProduct(p, s) <= 0.0)
	{
		return true;
	}
	return false;
}

public bool:TraceRayDontHitEntity(iEntity, contentsMask, any:iData)
{
	return iData != iEntity;
}

//------------------------- 함수 : 히트박스 체크 -------------------------//

stock UpdatePlayerHitbox(client, Float:fScale)
{ 
	static const Float:vecTF2PlayerMin[3] = { -24.5, -24.5, 0.0 }, Float:vecTF2PlayerMax[3] = { 24.5,  24.5, 83.0 };
	
	decl Float:vecScaledPlayerMin[3], Float:vecScaledPlayerMax[3];
	
	vecScaledPlayerMin = vecTF2PlayerMin;
	vecScaledPlayerMax = vecTF2PlayerMax;
	
	ScaleVector(vecScaledPlayerMin, fScale);
	ScaleVector(vecScaledPlayerMax, fScale);
	
	SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMins", vecScaledPlayerMin);
	SetEntPropVector(client, Prop_Send, "m_vecSpecifiedSurroundingMaxs", vecScaledPlayerMax);
}

//------------------------- 함수 : 연기 -------------------------//

stock CreateSmoke(target, bool:follow)
{
	if(IsValidClient(target) && IsPlayerAlive(target))
	{
		new SmokeEnt = CreateEntityByName("env_smokestack");
		
		new Float:location[3];
		GetClientAbsOrigin(target, location);
	
		new String:originData[64];
		Format(originData, sizeof(originData), "%f %f %f", location[0], location[1], location[2]);
		
		new String:SmokeColor[128] = "255 255 255";
		new String:SmokeTransparency[32] = "255";
		new String:SmokeDensity[32] = "30";
		
		if(SmokeEnt)
		{
			new String:SName[128];
			Format(SName, sizeof(SName), "Smoke%i", target);
			DispatchKeyValue(SmokeEnt,"targetname", SName);
			DispatchKeyValue(SmokeEnt,"Origin", originData);
			DispatchKeyValue(SmokeEnt,"BaseSpread", "100");
			DispatchKeyValue(SmokeEnt,"SpreadSpeed", "70");
			DispatchKeyValue(SmokeEnt,"Speed", "180");
			DispatchKeyValue(SmokeEnt,"StartSize", "400");
			DispatchKeyValue(SmokeEnt,"EndSize", "2");
			DispatchKeyValue(SmokeEnt,"Rate", SmokeDensity);
			DispatchKeyValue(SmokeEnt,"JetLength", "1000");
			DispatchKeyValue(SmokeEnt,"Twist", "20"); 
			DispatchKeyValue(SmokeEnt,"RenderColor", SmokeColor);
			DispatchKeyValue(SmokeEnt,"RenderAmt", SmokeTransparency);
			DispatchKeyValue(SmokeEnt,"SmokeMaterial", "particle/particle_smokegrenade1.vmt");
			
			DispatchSpawn(SmokeEnt);
			AcceptEntityInput(SmokeEnt, "TurnOn");
			
			if (follow)
			{
				SetVariantString("!activator");
				AcceptEntityInput(SmokeEnt, "SetParent", target, SmokeEnt);
			}
			CreateTimer(5.0, Timer_KillSmoke, SmokeEnt);
		}
	}
}

public Action:Timer_KillSmoke(Handle:timer, any:target)
{
	if (IsValidEntity(target))
	{
		AcceptEntityInput(target, "Kill");
	}
}

//------------------------- 함수 : 시민 모드 체크 -------------------------//

stock bool:ChangePlayerWeaponSlot(iClient, iSlot) {
    new iWeapon = GetPlayerWeaponSlot(iClient, iSlot);
    if (iWeapon > MaxClients) {
        SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", iWeapon);
        return true;
    }

    return false;
}

//------------------------- 함수 : 이펙트 -------------------------//

stock Handle:CreateParticle(String:type[], Float:time, entity, attach=0, Float:xOffs=0.0, Float:yOffs=0.0, Float:zOffs=0.0)
{
	if(IsValidEntity(entity))
	{
		new particle = CreateEntityByName("info_particle_system");
		if (IsValidEdict(particle)) {
			decl Float:pos[3];
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
			pos[0] += xOffs;
			pos[1] += yOffs;
			pos[2] += zOffs;
			TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
			DispatchKeyValue(particle, "effect_name", type);

			if (attach != 0) {
				SetVariantString("!activator");
				AcceptEntityInput(particle, "SetParent", entity, particle, 0);

				if (attach == 2) {
					SetVariantString("head");
					AcceptEntityInput(particle, "SetParentAttachmentMaintainOffset", particle, particle, 0);
				}
			}
			DispatchKeyValue(particle, "targetname", "present");
			DispatchSpawn(particle);
			ActivateEntity(particle);
			AcceptEntityInput(particle, "Start");
			return CreateTimer(time, DeleteParticle, particle);
		} else {
			LogError("(CreateParticle): Could not create info_particle_system");
		}
	}

	return INVALID_HANDLE;
}

public Action:DeleteParticle(Handle:timer, any:particle)
{
        if (IsValidEdict(particle)) {
                new String:classname[64];
                GetEdictClassname(particle, classname, sizeof(classname));

                if (StrEqual(classname, "info_particle_system", false)) {
                        RemoveEdict(particle);
                }
        }
}

//------------------------- 함수 : 유저 체크 -------------------------//

stock bool:IsValidClient(client)
{
	if(client<=0 || client>MaxClients)
	{
		return false;
	}

	if(!IsClientConnected(client) || !IsClientInGame(client))
	{
		return false;
	}
	return true;
}

ChangeTeams()
{
	new client;
	for(client=1; client <= MaxClients; client++)
	{
		if (IsValidClient(client))
		{
			if (GetClientTeam(client) == 2)
			{
				ChangeClientTeam(client, 3);
			}
			if (GetClientTeam(client) == 3)
			{
				ChangeClientTeam(client, 2);
			}
		}
	}
}

public Round_Win()
{
	new iEnt = -1;
	iEnt = FindEntityByClassname(iEnt, "game_round_win");

	if (iEnt < 1)
	{
		iEnt = CreateEntityByName("game_round_win");
		if (IsValidEntity(iEnt))
			DispatchSpawn(iEnt);

	}

	new iWinningTeam = 3;
	SetVariantInt(iWinningTeam);
	AcceptEntityInput(iEnt, "SetTeam");
	AcceptEntityInput(iEnt, "RoundWin");
}

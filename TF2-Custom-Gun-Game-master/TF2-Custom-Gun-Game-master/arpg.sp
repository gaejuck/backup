#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2items>
#include <tf2attributes>
#include <tf2>

#define BOMB_SOUND "weapons/explode3.wav"
#define LEVELUP_SOUND "ui/system_message_alert.wav"
#define SHIELD_MODEL "models/props_mvm/mvm_player_shield2.mdl"
#define MINE_MODEL "models/props_lab/tpplug.mdl"
#define FREEZE "physics/glass/glass_impact_bullet4.wav"
#define REBOUND_SOUND "goomba/rebound.wav"

#define SOUND_JUMP1			"saxton_hale/saxton_hale_responce_jump1.wav"
#define SOUND_JUMP2			"saxton_hale/saxton_hale_responce_jump2.wav"

#define SCOUT_MODEL "models/player/scout.mdl"
#define SOLDIER_MODEL "models/player/soldier.mdl"
#define PYRO_MODEL "models/player/pyro.mdl"
#define DEMOMAN_MODEL "models/player/demo.mdl"
#define HEAVY_MODEL "models/player/heavy.mdl"
#define ENGINEER_MODEL "models/player/engineer.mdl"
#define MEDIC_MODEL "models/player/medic.mdl"
#define SNIPER_MODEL "models/player/sniper.mdl"
#define SPY_MODEL "models/player/spy.mdl"

#define MILK_MODEL "models/weapons/c_models/c_madmilk/c_madmilk.mdl"
#define KUNAI_MODEL "models/weapons/c_models/c_shogun_kunai/c_shogun_kunai.mdl"

#define SPEED 1000.0

#define UFO_MODEL "models/props_teaser/saucer.mdl"
#define UFO_SOUND "uav/missle_launch.mp3"

#define BOMB_RADIUS 450.0
#define BOMB_DMG 999999.0

#define MESSAGE_ON true
#define MESSAGE_OFF false

#define MAX 99
#define MAXLEVEL 27

enum enumlist
{
	String:WeaponName[64],
	String:WeaponAttribute[100],
	String:WeaponClassName[64],
	String:WeaponClass[16],
	WeaponSlot,
	WeaponIndex,
	WeaponLevel,
	WeaponQual,
	LevelExp,
	LevelReset,
	String:MAX_LEVEL
};

new Weapon_Config[MAX][enumlist];

new Level[33];
new bool:LevelCheck[33];
new bool:LevelDownCheck[33];

new Exp[33];

new bool:BonkCheck[33];
new JatateCheck[33];

new Float:FireBallTime[33];
new bool:FireBallCheck[33];

new Float:ShieldTime[33];
new bool:ShieldCheck[33];
new bool:RegenCheck[33];
new bool:ice[33];

new bool:GoombaCheck[33];

new Float:SuPerJumpTime[33];

new bool:UfoKeyCheck[33];
new Float:UfoTime[33];

new bool:AttackCheck[33];

new bool:g_bWaitingForPlayers;

new UserMsg:g_FadeUserMsgId;

public OnPluginStart()
{
	if(!RPG_Config()) return;
	
	LoadTranslations("rpg.phrases");
	LoadTranslations("common.phrases");
	
	RegAdminCmd("sm_dd", aaaa, ADMFLAG_KICK);
	RegAdminCmd("sm_reload", reload, ADMFLAG_KICK);
	RegConsoleCmd("say", info);
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_death", EventDeath, EventHookMode_Pre);
	HookEvent("post_inventory_application", iv, EventHookMode_Post);
	HookEvent("teamplay_round_start", OnRoundStart);
	HookUserMessage(GetUserMessageId("PlayerJarated"), Event_PlayerJarated);
	
	g_FadeUserMsgId = GetUserMessageId("Fade");
	
	new iEnt = -1;
	decl String:szName[16];
	while((iEnt = FindEntityByClassname2(iEnt, "info_observer_point")) != -1)
	{
		GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
		if(StrEqual(szName, "UAV")) AcceptEntityInput(iEnt, "Kill");
	}
}

public TF2_OnWaitingForPlayersStart() g_bWaitingForPlayers = true;

public TF2_OnWaitingForPlayersEnd() g_bWaitingForPlayers = false;

public OnMapStart()
{
	PrecacheSound(BOMB_SOUND, true);
	PrecacheSound(LEVELUP_SOUND, true);
	PrecacheSound(FREEZE, true);
	PrecacheSound(REBOUND_SOUND, true);
	
	PrecacheSound(SOUND_JUMP1, true);
	PrecacheSound(SOUND_JUMP2, true);
	
	PrecacheModel(SHIELD_MODEL, true);
	PrecacheModel(MINE_MODEL, true);
	
	PrecacheModel(SCOUT_MODEL, true);
	PrecacheModel(SOLDIER_MODEL, true);
	PrecacheModel(PYRO_MODEL, true);
	PrecacheModel(DEMOMAN_MODEL, true);
	PrecacheModel(HEAVY_MODEL, true);
	PrecacheModel(ENGINEER_MODEL, true);
	PrecacheModel(MEDIC_MODEL, true);
	PrecacheModel(SNIPER_MODEL, true);
	PrecacheModel(SPY_MODEL, true);
	
	PrecacheModel(MILK_MODEL, true);
	PrecacheModel(KUNAI_MODEL, true);
	
	PrecacheModel(UFO_MODEL, true);
	PrecacheSound(UFO_SOUND, true);
	
	AddFileToDownloadsTable("sound/saxton_hale/saxton_hale_responce_jump1.wav");
	AddFileToDownloadsTable("sound/saxton_hale/saxton_hale_responce_jump2.wav");
	AddFileToDownloadsTable("sound/goomba/rebound.wav");
}


public OnClientPutInServer(client)
{
	Level[client] = 0;
	LevelCheck[client] = false;
	LevelDownCheck[client] = false;
	
	Exp[client] = 0;
	
	JatateCheck[client] = 0;
	BonkCheck[client] = false;
	RegenCheck[client] = false;
	ice[client] = false;
	
	FireBallTime[client] = 0.0;
	FireBallCheck[client] = false;
	
	ShieldTime[client] = 0.0;
	ShieldCheck[client] = false;
	
	UfoTime[client] = 0.0;
	UfoKeyCheck[client] = false;
	
	AttackCheck[client] = false;
}

public OnClientPostAdminCheck(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_StartTouch, OnStartTouch);
}

public Action:OnRoundStart(Handle:event, String:name[], bool:dontBroadcast)
{
	if(g_bWaitingForPlayers) return Plugin_Continue;
	
	new iEnt = -1;
	while((iEnt = FindEntityByClassname(iEnt, "team_round_timer")) != -1) AcceptEntityInput(iEnt, "Disable");
	return Plugin_Continue;
} 

public Action:aaaa(client, args)
{
	decl String:arg[65];
	decl String:arg2[65];
	decl String:arg3[65];
	new bool:HasTarget = false;
	
	if(args < 2)
	{
		ReplyToCommand(client, "[SM]\x03!dd <name> <level>");
		return Plugin_Handled;
	}
		
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
		
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
			Level[target_list[i]] = StringToInt(arg2);
			Exp[target_list[i]] = StringToInt(arg3);
			for(new z = 0; z < MAX; z++)
			{
				if(Weapon_Config[z][MAX_LEVEL] == MAX)
				{
					if(z == Level[target_list[i]])
					{
						LevelUp(target_list[i], Weapon_Config[z][WeaponSlot], Weapon_Config[z][WeaponClass], Weapon_Config[z][WeaponName], Weapon_Config[z][WeaponIndex], Weapon_Config[z][WeaponQual],
						Weapon_Config[z][WeaponLevel], Weapon_Config[z][WeaponClassName], Weapon_Config[z][WeaponAttribute], MESSAGE_ON);
					}
				}
			}
			PrintToChat(client, "\x03'%N' 님에게 레벨 %d", target_list[i], StringToInt(arg2));
		}
	}
	return Plugin_Handled;
}

public Action:reload(client, args)
{
	RPG_Config();
	for(new i = 1; i <= MaxClients; i++)
	{
		if (PlayerCheck(i))
		{
			SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage);
			SDKHook(i, SDKHook_StartTouch, OnStartTouch);
		} 
	}
	PrintToChat(client, "리로드댐");
	return Plugin_Handled;
}
public Action:info(client, Args)
{
	decl String:msg[256];
	GetCmdArgString(msg, sizeof(msg));
	msg[strlen(msg) -1] = '\0';
	
	if(StrEqual(msg[1], "/정보"))
	{
		WeaponInfo(client);
		return Plugin_Handled;
	}
	if(StrEqual(msg[1], "!정보")) WeaponInfo(client);	

	return Plugin_Continue;
}

public WeaponInfo(client)
{
	new Handle:menu = CreateMenu(WeaponInfo_Select);
	
	for(new i = 0; i < MAX; i++)
	{
		if(Weapon_Config[i][MAX_LEVEL] == MAX)
		{
			if(i == Level[client])
			{
				decl String:PlayerLevel[64];
				IntToString(Level[client], PlayerLevel, sizeof(PlayerLevel));
				SetMenuTitle(menu, "무기 이름 : %s\n\n무기 설명: %T", Weapon_Config[i][WeaponName], PlayerLevel, client); 
			}
		}
	}
	AddMenuItem(menu, "weapon", "하핳"); 
	SetMenuExitButton(menu, true);
	DisplayMenu(menu, client, 60);
}

public WeaponInfo_Select(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select) {}
	if(action == MenuAction_End) CloseHandle(menu);
}

public Action:Event_PlayerJarated(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	new client = BfReadByte(bf);
	new victim = BfReadByte(bf);
	if (Level[client] == 10)
	{
		new jar = GetPlayerWeaponSlot(client, 1);
		if (jar != -1 && GetEntProp(jar, Prop_Send, "m_iItemDefinitionIndex") == 1105)
		{
			JatateCheck[victim] = client;
		}
	}
	return Plugin_Continue;
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));//7777
	
	if(IsFakeClient(client)) Level[client] = GetRandomInt(0, MAXLEVEL);
	
	BonkCheck[client] = false;
	
	SetEntityRenderMode(client, RENDER_TRANSCOLOR)
	SetEntityRenderColor(client, 255, 255, 255, 255);
	SetEntityMoveType(client, MOVETYPE_WALK);
	ice[client] = false;
	
	SetClientViewEntity(client, client);
						
	for(new i = 0; i < MAX; i++)
	{
		if(Weapon_Config[i][MAX_LEVEL] == MAX)
		{
			if(i == Level[client])
			{
				LevelUp(client, Weapon_Config[i][WeaponSlot], Weapon_Config[i][WeaponClass], Weapon_Config[i][WeaponName], Weapon_Config[i][WeaponIndex], Weapon_Config[i][WeaponQual],
				Weapon_Config[i][WeaponLevel], Weapon_Config[i][WeaponClassName], Weapon_Config[i][WeaponAttribute], MESSAGE_OFF);
			}
		}
	}
		
	if(LevelDownCheck[client])
	{
		PrintToChat(client, "\x03[Level Down] %T", "level down", client);
		LevelDownCheck[client] = false;
	}
}
public iv(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(AliveCheck(client) && RegenCheck[client]) CreateTimer(0.05, Timer_LockerWeaponReset, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_LockerWeaponReset(Handle:timer, any:client)
{
	if(!AliveCheck(client)) return Plugin_Stop;
	if(!RegenCheck[client]) return Plugin_Stop;
	
	for(new i = 0; i < MAX; i++)
	{
		if(Weapon_Config[i][MAX_LEVEL] == MAX)
		{
			if(i == Level[client])
			{
				LevelUp(client, Weapon_Config[i][WeaponSlot], Weapon_Config[i][WeaponClass], Weapon_Config[i][WeaponName], Weapon_Config[i][WeaponIndex], Weapon_Config[i][WeaponQual],
				Weapon_Config[i][WeaponLevel], Weapon_Config[i][WeaponClassName], Weapon_Config[i][WeaponAttribute], MESSAGE_OFF);
			} 
		}
	}
	return Plugin_Continue;
}


public EventDeath(Handle:event, const String:Spawn_Name[], bool:Spawn_Broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new assister = GetClientOfUserId(GetEventInt(event, "assister"));
		
	if(PlayerCheck(client) && PlayerCheck(attacker) || PlayerCheck(assister))
	{
		if(client != attacker)
		{		
			Exp[attacker] += 2; 
			PrintToChat(attacker, "\x03[Exp Up] %T 2%T", "exp", attacker, "up", attacker)
			
			new p;
			if(Exp[client] != 0)
			{
				Exp[client] -= 1; 
				PrintToChat(client, "\x03[Exp Down] %T 1%T", "exp", client, "down", client);
				p = Level[client] -1;
			}
			
			if(Level[client] == 18)
			{
				new iEnt = -1;
				decl String:szName[16];
				while((iEnt = FindEntityByClassname2(iEnt, "prop_dynamic")) != -1)
				{
					if(IsValidEntity(iEnt) && iEnt > MaxClients)
					{
						GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
						if(StrEqual(szName, "mine")) if(GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client) AcceptEntityInput(iEnt, "Kill");
					}
				}
			}
			else if(Level[attacker] == 23)
			{
				SetEventString(event, "weapon_logclassname", "goomba");
				SetEventString(event, "weapon", "taunt_scout");
			}
			else if(Level[client] == 26) FindUFOKill(client);
				
			else if(Level[attacker] == 28) SetEventInt(event, "customkill", TF_CUSTOM_PUMPKIN_BOMB);
			
			BonkCheck[client] = false;
				
			for(new i = 0; i < MAX; i++)
			{
				if(Weapon_Config[i][MAX_LEVEL] == MAX)
				{
					if(i == Level[attacker])
					{
						if(Level[attacker] == 20)
						{
							LevelUp(attacker, Weapon_Config[i][WeaponSlot], Weapon_Config[i][WeaponClass], Weapon_Config[i][WeaponName], Weapon_Config[i][WeaponIndex], Weapon_Config[i][WeaponQual],
							Weapon_Config[i][WeaponLevel], Weapon_Config[i][WeaponClassName], Weapon_Config[i][WeaponAttribute], MESSAGE_OFF);
						}
					 	if(Exp[attacker] >= Weapon_Config[i][LevelExp])
						{
							if(Weapon_Config[i][LevelReset] != 1)
							{
								Level[attacker] ++;
								LevelCheck[attacker] = true;
							}
							else
							{
								Level[attacker] = 0;
								PrintToChat(attacker, "\x07FFFFFF%T", "reset", attacker);
							}
						}
					}
					
					if(LevelCheck[attacker])
					{
						if(i == Level[attacker])
						{
							LevelUp(attacker, Weapon_Config[i][WeaponSlot], Weapon_Config[i][WeaponClass], Weapon_Config[i][WeaponName], Weapon_Config[i][WeaponIndex], Weapon_Config[i][WeaponQual],
							Weapon_Config[i][WeaponLevel], Weapon_Config[i][WeaponClassName], Weapon_Config[i][WeaponAttribute], MESSAGE_ON);
							LevelCheck[attacker] = false;
						}
					}
					
					if(i == p)
					{
						if(Exp[client] <= Weapon_Config[p][LevelExp])
						{
							if(Exp[client] != 0)
							{
								Level[client] = p;
								LevelDownCheck[client] = true //88
							}
						}
					}
				}
			}
		}
		
		if(client != assister && PlayerCheck(assister))
		{
			Exp[assister] ++; 
			PrintToChat(assister, "\x03[Exp Up] %T 1%T", "exp", assister, "up", assister);
			BonkCheck[assister] = false;
			
			for(new i = 0; i < MAX; i++)
			{
				if(Weapon_Config[i][MAX_LEVEL] == MAX)
				{
					if(i == Level[assister])
					{
						if(Exp[assister] > Weapon_Config[i][LevelExp])
						{
							if(Weapon_Config[i][LevelReset] != 1)
							{
								Level[assister] ++;
								LevelCheck[assister] = true;
							}
							else
							{
								Level[assister] = 0;
								PrintToChat(assister, "\x07FFFFFF%T", "reset", assister);
							}
						}
					}
					
					if(LevelCheck[assister])
					{
						if(i == Level[assister])
						{ 
							LevelUp(assister, Weapon_Config[i][WeaponSlot], Weapon_Config[i][WeaponClass], Weapon_Config[i][WeaponName], Weapon_Config[i][WeaponIndex], Weapon_Config[i][WeaponQual],
							Weapon_Config[i][WeaponLevel], Weapon_Config[i][WeaponClassName], Weapon_Config[i][WeaponAttribute], MESSAGE_ON);
							LevelCheck[assister] = false;
						} 
					}
				}
			}
		}
		if(client == attacker)
		{
			BonkCheck[client] = false;
			
			if(Level[client] == 18)
			{
				new iEnt = -1;
				decl String:szName[16];
				while((iEnt = FindEntityByClassname2(iEnt, "prop_dynamic")) != -1)
				{
					if(IsValidEntity(iEnt) && iEnt > MaxClients)
					{
						GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
						if(StrEqual(szName, "mine")) if(GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client) AcceptEntityInput(iEnt, "Kill");
					} 
				}
			}
			else if(Level[client] == 26) FindUFOKill(client);
		}
	}
}

public Action:OnPlayerRunCmd(client, &iButtons, &iImpulse, Float:fVel[3], Float:fAng[3], &iWeapon)
{
	if(AliveCheck(client))
	{
		SetHudTextParams(0.33, 0.93, 0.1, 150, 150, 0, 150, 0, 0.0, 0.0, 0.0);
		
		for(new i = 0; i < MAX; i++)
		{
			if(Weapon_Config[i][MAX_LEVEL] == MAX)
			{
				if(i == Level[client])
				{
					if(!(iButtons & IN_SCORE))
						ShowHudText(client, 1, "Lv %d                                                    Exp %d / %d", Level[client], Exp[client], Weapon_Config[i][LevelExp]);
				}
			}
		}
		
		SetHudTextParams(0.42, 0.87, 0.1, 150, 150, 0, 150, 0, 0.0, 0.0, 0.0);
		
		if(Level[client] == 5)
		{
			if(TF2_IsPlayerInCondition(client, TFCond_Bonked)) BonkCheck[client] = true;
			else
			{
				if(BonkCheck[client])
				{
					decl Float:pos[3];
					GetClientAbsOrigin(client, pos);
						
					new ent = Explode(client, pos, 0.0, 30.0, "asplode_hoodoo", BOMB_SOUND); 
					AdmDamage(pos, ent, 30.0, BOMB_DMG, client, client);
					ForcePlayerSuicide(client);
					BonkCheck[client] = false;
				}
			}
		}
		else if(Level[client] == 10)
		{
			for(new i = 1; i <= MaxClients; i++)
			{
				if(AliveCheck(i))
				{ 
					if(JatateCheck[i] == client)
					{
						TF2_IgnitePlayer(i, client);
						if(TF2_IsPlayerInCondition(i, TFCond_OnFire)) JatateCheck[i] = 0;
					}
				}
			}
		}
		else if(Level[client] == 12)
		{
			if(iButtons & IN_ATTACK2)
			{
				if(FireBallTimeCoolTime(client, 1.5))
				{
					if(!FireBallCheck[client])
					{
						FireBallTime[client] = GetEngineTime();
						new Float:vPosition[3];
						new Float:vAngles[3];
						vAngles[2] += 25.0;
						new iTeam = GetClientTeam(client);
						GetClientEyePosition(client, vPosition);
						GetClientEyeAngles(client, vAngles);
							
						RocketsGameFiredSpell(client, "tf_projectile_spellfireball", vPosition, vAngles, 800.0, 100.0, iTeam, true);	 //스피드 데미지 크리
			
						FireBallCheck[client] = true;
					}
				}
			}
			else FireBallCheck[client] = false;
		}
			
		else if(Level[client] == 17)
		{
			if(!(iButtons & IN_SCORE))
			{
				if(ShieldCoolTime(client, 20.0)) ShowHudText(client, 2, "준비 완료 (우 클릭)");
				else ShowHudText(client, 2, "        쿨타임 중");
			}
				
			if(iButtons & IN_ATTACK2)
			{
				if(ShieldCoolTime(client, 20.0))
				{
					if(!ShieldCheck[client])
					{
						ShieldTime[client] = GetEngineTime();
							
						new shield = CreateEntityByName("entity_medigun_shield");	
						if(IsValidEntity(shield))
						{
							SetEntPropEnt(shield, Prop_Send, "m_hOwnerEntity", client);  
							SetEntProp(shield, Prop_Send, "m_iTeamNum", GetClientTeam(client));  
							SetEntProp(shield, Prop_Data, "m_iInitialTeamNum", GetClientTeam(client));  
										
							if(TF2_GetClientTeam(client) == TFTeam_Red) DispatchKeyValue(shield, "skin", "0");
							else if (TF2_GetClientTeam(client) == TFTeam_Blue) DispatchKeyValue(shield, "skin", "1");
										
							SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 200.0);
							SetEntProp(client, Prop_Send, "m_bRageDraining", 1);
							SetEntityModel(shield, SHIELD_MODEL);
										
							DispatchSpawn(shield);
								
							SetVariantString("!activator");
							AcceptEntityInput(shield, "SetParent", client);
							CreateTimer(19.5, Remove_Shield, EntIndexToEntRef(shield), TIMER_FLAG_NO_MAPCHANGE);
						}
						ShieldCheck[client] = true;
					}
				}
			}
			else ShieldCheck[client] = false;
		}
		else if(Level[client] == 23)
		{
			static iJumpCharge[33];

			if((iButtons & IN_DUCK || iButtons & IN_ATTACK2) && iJumpCharge[client] >= 0 && !(iButtons & IN_JUMP))
				ShowHudText(client, 3, "      슈퍼 점프 %i%", iJumpCharge[client] * 4);	 
					
			else if(iJumpCharge[client] < 0) ShowHudText(client, 3, "        쿨타임 %i초", -iJumpCharge[client] / 20);
			else if(iJumpCharge[client] == 0) ShowHudText(client, 3, "    슈퍼 점프 준비 완료!");
					
			if(SuPerJumpTimeCoolTime(client, 0.3))
			{
				SuPerJumpTime[client] = GetEngineTime();
					
				if((iButtons & IN_DUCK || iButtons & IN_ATTACK2) && iJumpCharge[client] >= 0 && !(iButtons & IN_JUMP))
				{
					if(iJumpCharge[client] + 5 < 25) iJumpCharge[client] += 5;
					else iJumpCharge[client] = 25;
				}
				else if(iJumpCharge[client] < 0) iJumpCharge[client] += 5;
				else
				{
					decl Float:fAngles[3];
					GetClientEyeAngles(client, fAngles);

					if(fAngles[0] < -45.0 && iJumpCharge[client] > 1)
					{
						decl Float:fVelocity[3];
						GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);

						SetEntProp(client, Prop_Send, "m_bJumping", 1);

						fVelocity[2] = 750 + iJumpCharge[client] * 13.0;
						fVelocity[0] *= (1 + Sine(float(iJumpCharge[client]) * FLOAT_PI / 50));
						fVelocity[1] *= (1 + Sine(float(iJumpCharge[client]) * FLOAT_PI / 50));
						TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, fVelocity);

						iJumpCharge[client] = -120;
							
						switch(GetRandomInt(0, 2))
						{
							case 0: EmitSoundToAll(SOUND_JUMP1, client, SNDCHAN_VOICE);
							case 1: EmitSoundToAll(SOUND_JUMP2, client, SNDCHAN_VOICE);
						}

					}
					else iJumpCharge[client] = 0;
				}
			}
		}	
		else if(Level[client] == 24)
		{
			if(!AttackCheck[client]) ShowHudText(client, 4, "   7초 후 공격 가능");
			else ShowHudText(client, 4, "        공격 개시");
		}
			
		else if(Level[client] == 26)
		{
			if(!(iButtons & IN_SCORE))
			{
				if(UfoCoolTime(client, 15.0)) ShowHudText(client, 5, "준비 완료 (우 클릭)");
				else ShowHudText(client, 5, "        쿨타임 중");
			}
			
			if(iButtons & IN_ATTACK2)
			{
				if(UfoCoolTime(client, 15.0))
				{
					if(!UfoKeyCheck[client])
					{
						new Float:fPos[3];
						GetClientEyePosition(client, fPos);
						
						new observer = CreateEntityByName("info_observer_point");
						if(IsValidEntity(observer))
						{
							SetEntPropEnt(observer, Prop_Send, "m_hOwnerEntity", client);
							DispatchKeyValue(observer, "targetname", "UAV");
							DispatchKeyValue(observer, "Angles", "90 0 0");
							DispatchKeyValue(observer, "TeamNum", "0");
							DispatchKeyValue(observer, "StartDisabled", "0");
							
							SetVariantString("!activator");
							AcceptEntityInput(observer, "SetParent", client);
							
							DispatchSpawn(observer);
							AcceptEntityInput(observer, "Enable");
									
							TeleportEntity(observer, fPos, NULL_VECTOR, NULL_VECTOR);
							SetClientViewEntity(client, observer);
							UfoKeyCheck[client] = true;
							UfoTime[client] = GetEngineTime();
						}
					}
				}
			} else UfoKeyCheck[client] = false;
		}
		
		if(Level[client] == 17 || Level[client] == 23 || Level[client] == 24 || Level[client] == 26) {}
		else if(!(iButtons & IN_SCORE)) ShowHudText(client, 6, "     !정보 || /정보");
	}
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if(IsValidEntity(weapon) && AliveCheck(client))
	{
		if(Level[client] == 20)
		{
			SetEntProp(weapon, Prop_Send, "m_bBroken", 0);
			SetEntProp(weapon, Prop_Send, "m_iDetonated", 0);
		}
	}
	return Plugin_Continue;
}

public Action:Remove_Shield(Handle:timer, any:entity)
{
	new ent = EntRefToEntIndex(entity);
	if (IsValidEntity(ent)) AcceptEntityInput(ent, "Kill");
}

public Action:OnTakeDamage(attacker, &client, &inflictor, &Float:fDamage, &iDamagetype, &iWeapon, Float:fForce[3], Float:fForcePos[3], damagecustom)
{
	if (AliveCheck(attacker) && AliveCheck(client))
	{
		if(TF2_IsPlayerInCondition(client, TFCond_HalloweenKart))
		{
			// decl Float:pos[3];
			// GetClientAbsOrigin(client, pos);
			// new ent = Explode(client, pos, 0.0, BOMB_RADIUS, "", ""); 
			// AdmDamage(pos, ent, BOMB_RADIUS, BOMB_DMG, client, client);
			fDamage = 999.0;
			return Plugin_Changed;
		}
		else if(TF2_IsPlayerInCondition(attacker, TFCond_GrapplingHook))
		{
			fDamage = 25.0;
			return Plugin_Changed;
		}

		if(damagecustom & TF_CUSTOM_BURNING)
		{
			fDamage = 10.0;
			return Plugin_Changed;
		}
		
		
		if(attacker != client)
		{
			decl String:Wclassname[64], String:Entclassname[64];
			GetEntityClassname(iWeapon, Wclassname, sizeof(Wclassname));
			if(IsValidEntity(inflictor)) GetEntityClassname(inflictor, Entclassname, sizeof(Entclassname));
			if(StrEqual(Wclassname, "tf_weapon_grapplinghook"))
			{
				fDamage = 25.0;
				return Plugin_Changed;
			}
			
			if(Level[client] == 9)
			{
				decl Float:pos[3], Float:cpos[3], Float:angle[3];
				
				GetClientAbsOrigin(client, cpos);
				GetClientAbsOrigin(attacker, pos);
				GetClientAbsAngles(attacker, angle);
				
				effect(client, cpos, 2.0, "spell_cast_wheel_blue");
				effect(attacker, pos, 2.0, "spell_cast_wheel_blue");
				
				TeleportEntity(client, pos, angle, NULL_VECTOR);
			}
			
			else if(Level[client] == 16)
			{
				Knockback(client, 6.0);
				Knockback(attacker, 6.0);
			}
			
			else if(Level[client] == 21)
			{
				if (StrEqual(Entclassname, "tf_projectile_rocket"))
				{
					EmitSoundToClient(attacker, FREEZE);
					if(GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity") == client)
					{
						// if(GetClientTeam(client) != GetClientTeam(attacker)) 
						// {
							if(!ice[attacker])
							{
								SetEntityRenderMode(attacker, RENDER_TRANSCOLOR)
								SetEntityRenderColor(attacker, 0, 17, 255, 255);
								SetEntityMoveType(attacker, MOVETYPE_NONE);
								ice[attacker] = true;
							}
							else
							{
								SetEntityRenderMode(attacker, RENDER_TRANSCOLOR)
								SetEntityRenderColor(attacker, 255, 255, 255, 255);
								SetEntityMoveType(attacker, MOVETYPE_WALK);
								ice[attacker] = false;
							}
						// }
					}
				}
			}
			
			else if(Level[client] == 22)
			{
				if (StrEqual(Entclassname, "tf_projectile_energy_ring"))
				{
					if(GetEntPropEnt(inflictor, Prop_Send, "m_hOwnerEntity") == client) TF2_IgnitePlayer(attacker, client);
				}
			}
			
			else if(Level[client] == 27)
			{
				if (!GetBackAttack(attacker, client))
				{
					fDamage = 0.0; 
					return Plugin_Changed;
				}
			}
			
			else if(Level[client] == 28)
			{
				new Handle:hTemp;
				CreateDataTimer(5.0, bear, hTemp, TIMER_FLAG_NO_MAPCHANGE);
				WritePackCell(hTemp, client);
				WritePackCell(hTemp, attacker);
			}
		}
		else
		{
			if(Level[client] == 11)
			{
				TF2_AddCondition(attacker, TFCond:14, 0.001);			
				fDamage = 45.0;
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue; 
}

public Action:bear(Handle:hTimer, Handle:hPack)
{
	ResetPack(hPack);
	
	new client = ReadPackCell(hPack);
	new attacker = ReadPackCell(hPack);
	
	if(!AliveCheck(attacker)) return Plugin_Stop;

	decl Float:client_pos[3], Float:attacker_pos[3], Float:attacker_angle[3];
	GetClientAbsOrigin(attacker, client_pos);
				
	for (new i = 1; i <= MaxClients; i++)
	{
		if (AliveCheck(i) && GetClientTeam(client) != GetClientTeam(i))
		{
			GetClientAbsOrigin(i, attacker_pos);
			GetClientEyePosition(i, attacker_angle);
			
			if (GetVectorDistance(client_pos, attacker_pos) <= 900.0)
			{
				ShootLaser(attacker, "merasmus_zap", client_pos, attacker_pos);
				SDKHooks_TakeDamage(i, client, client, 500.0, DMG_SHOCK);
				SDKHooks_TakeDamage(attacker, client, client, 500.0, DMG_SHOCK);
			}
			else SDKHooks_TakeDamage(attacker, client, client, 500.0, DMG_SHOCK);
		}
	}
	return Plugin_Continue;
}

public OnEntityCreated(entity, const String:classname[])
{
	// decl String:name[30];
	// GetEdictClassname(entity, name, sizeof(name));
	// PrintToChatAll(name);
	if (StrEqual(classname, "tf_dropped_weapon")) AcceptEntityInput(entity, "Kill");
	if (StrEqual(classname, "instanced_scripted_scene", false)) SDKHook(entity, SDKHook_Spawn, OnSceneSpawned);
	if(StrEqual(classname, "tf_projectile_rocket", false)) SDKHook(entity, SDKHook_Spawn, OnSpawn);
	if(StrEqual(classname, "info_observer_point", false)) SDKHook(entity, SDKHook_Spawn, OnSpawn);
	if(StrEqual(classname, "tf_projectile_cleaver", false)) SDKHook(entity, SDKHook_SpawnPost, OnSpawn);
	if(StrEqual(classname, "tf_projectile_stun_ball", false)) SDKHook(entity, SDKHook_SpawnPost, OnSpawn);
}

public OnSpawn(ent)
{
	if(IsValidEntity(ent))
	{
		decl String:EntityName[64];
		GetEntityClassname(ent, EntityName, sizeof(EntityName));
		
		new client = GetEntPropEnt(ent,Prop_Data,"m_hOwnerEntity");
		
		if(PlayerCheck(client))
		{
			if(StrEqual(EntityName, "tf_projectile_rocket"))
			{
				if(Level[client] == 21)
				{
					decl Float:origin[3];
					GetEntPropVector(ent, Prop_Data, "m_vecOrigin", origin);
					effect(ent, origin, 2.0, "spell_fireball_small_trail_blue", true);
				}
			}
			if(StrEqual(EntityName, "info_observer_point")) CreateTimer(0.1, Spawn_UFO, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE)
			if(StrEqual(EntityName, "tf_projectile_cleaver")) if(Level[client] == 6) SetEntityModel(ent, MILK_MODEL);
			if(StrEqual(EntityName, "tf_projectile_stun_ball")) if(Level[client] == 28) SetEntityModel(ent, KUNAI_MODEL);
		}
	}
}

public Action:Spawn_UFO(Handle:hTimer, any:iEntityRef)
{
	new ent = EntRefToEntIndex(iEntityRef);
	if(!IsValidEntity(ent)) return Plugin_Stop;
	new iOwner = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if(!AliveCheck(iOwner)) return Plugin_Stop;
	
	new client = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	SetEntPropEnt(client, Prop_Send, "m_hObserverTarget", ent);
				
	new Float:fAng[3], Float:fPos[3];	
				
	GetClientEyeAngles(client, fAng);
	GetEntPropVector(ent, Prop_Data, "m_vecOrigin", fPos);
	TeleportEntity(ent, NULL_VECTOR, fAng, NULL_VECTOR);
			
	CreateTimer(10.1, UFOKill2, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
	
	SetClientViewEntity(client, ent);
						 
	new iEnt = CreateEntityByName("tf_projectile_rocket"); //77
	if(IsValidEntity(iEnt))
	{
		SetOverlay(client, "effects/stealth_overlay");
								
		SetVariantInt(1);
		AcceptEntityInput(client, "SetForcedTauntCam");
		SetEntityMoveType(client, MOVETYPE_NONE);
				
		DispatchKeyValue(iEnt, "targetname", "UFO");

		SetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(iEnt,	Prop_Send, "m_bCritical", 1);
		SetEntProp(iEnt,	Prop_Send, "m_iTeamNum", GetClientTeam(client));
		SetEntDataFloat(iEnt, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 300.0, true);
		SetEntPropFloat(iEnt, Prop_Send, "m_flModelScale", 0.8);
		DispatchSpawn(iEnt);
		AcceptEntityInput(iEnt, "Enable");
		TeleportEntity(iEnt, fPos, NULL_VECTOR, NULL_VECTOR);
							
		SetEntityModel(iEnt, UFO_MODEL);
		SetClientViewEntity(client, iEnt);
		SDKHookEx(iEnt, SDKHook_ShouldCollide, OnCollide);
								
		CreateTimer(0.01, ThinkUFO, EntIndexToEntRef(iEnt), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		CreateTimer(10.0, UFOKill, EntIndexToEntRef(iEnt), TIMER_FLAG_NO_MAPCHANGE);
		EmitSoundToAll(UFO_SOUND, iEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true);
	}
	return Plugin_Continue;
}

public bool:OnCollide(entity, collisiongroup, contentsMask, bool:result)
{
	return bool:PlayerCheck(entity);
}

public Action:ThinkUFO(Handle:hTimer, any:iMissle)
{
	iMissle = EntRefToEntIndex(iMissle);
	if(!IsValidEntity(iMissle)) return Plugin_Stop;
		
	new client = GetEntPropEnt(iMissle, Prop_Send, "m_hOwnerEntity");
	
	if(!AliveCheck(client)) return Plugin_Stop;
	
	if(GetEntProp(iMissle,Prop_Send, "m_iDeflected") == 1) {
		SetEntPropEnt(iMissle, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(iMissle,Prop_Send, "m_iDeflected", 0);
		SetEntProp(iMissle,	Prop_Send, "m_iTeamNum", GetClientTeam(client));
		SetEntDataFloat(iMissle, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 300.0, true);
	}
		
	new Float:fDirection[3], Float:fVelocity[3], Float:fAng[3];

	GetClientEyeAngles(client, fAng);	
	GetAngleVectors(fAng, fDirection, NULL_VECTOR, NULL_VECTOR);
	
	new Float:fPos[3];
	GetEntPropVector(iMissle, Prop_Data, "m_vecOrigin", fPos);

	new iButtons = GetClientButtons(client);
	if(iButtons & IN_FORWARD)
	{
		fVelocity[0] = fDirection[0]*SPEED;
		fVelocity[1] = fDirection[1]*SPEED;
		fVelocity[2] = fDirection[2]*SPEED;
	} 
	TeleportEntity(iMissle, NULL_VECTOR, fAng, fVelocity);
	return Plugin_Continue;
}

public Action:UFOKill2(Handle:hTimer, any:Entity)
{
	new ent = EntRefToEntIndex(Entity);
	if(!IsValidEntity(ent)) return Plugin_Stop;
	new client = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if(!AliveCheck(client)) return Plugin_Stop;
	
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");
	SetOverlay(client, "");
	SetClientViewEntity(client, client);
	SetEntityMoveType(client, MOVETYPE_WALK);
			
	AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}


public Action:UFOKill(Handle:hTimer, any:Entity)
{
	new ent = EntRefToEntIndex(Entity);
	if(!IsValidEntity(ent)) return Plugin_Stop;
	new client = GetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity");
	if(!AliveCheck(client)) return Plugin_Stop;
	
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");
	SetOverlay(client, "");
	SetClientViewEntity(client, client);
	SetEntityMoveType(client, MOVETYPE_WALK);
			
	AcceptEntityInput(ent, "Kill");
	PrintToChat(client, "\x03%T", "ufo", client);
	return Plugin_Continue;
}

public Action:OnSceneSpawned(entity)
{
	if(!IsValidEntity(entity)) return Plugin_Continue;
	new client = GetEntPropEnt(entity, Prop_Data, "m_hOwner"), String:scenefile[128];
	
	if (!AliveCheck(client)) return Plugin_Continue;
	if (Level[client] != 15) return Plugin_Continue;
	
	GetEntPropString(entity, Prop_Data, "m_iszSceneFile", scenefile, sizeof(scenefile));
	if (StrEqual(scenefile, "scenes/player/pyro/low/taunt02.vcd") && GetEntityFlags(client) & FL_ONGROUND)
	{
		if (TF2_IsPlayerInCondition(client, TFCond_Taunting)) return Plugin_Continue;
		CreateTimer(2.0, FireBall, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return Plugin_Continue;
}

public Action:FireBall(Handle:timer, any:client)
{
	if (!AliveCheck(client)) return Plugin_Stop;
	if (Level[client] != 15) return Plugin_Stop;
	if (!TF2_IsPlayerInCondition(client, TFCond_Taunting)) return Plugin_Stop;
	
	new Float:vPosition[3];
	new Float:vAngles[3];
	vAngles[2] += 25.0;
	new iTeam = GetClientTeam(client);
	GetClientEyePosition(client, vPosition);
	GetClientEyeAngles(client, vAngles);

	RocketsGameFiredSpell(client, "tf_projectile_lightningorb", vPosition, vAngles, 200.0, 800.0, iTeam, true);				
	return Plugin_Continue;
}



public OnEntityDestroyed(iEntity)
{
	if(!IsValidEdict(iEntity)) return;
	decl String:szBuffer[64];
	GetEdictClassname(iEntity, szBuffer, 64);
	
	decl Float:origin[3], Float:vAngles[3];
	GetEntPropVector(iEntity, Prop_Data, "m_vecOrigin", origin);
	GetEntPropVector(iEntity, Prop_Data, "m_angRotation", vAngles);
		
	if(StrEqual(szBuffer, "tf_projectile_arrow"))
	{
		new client = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
		if(!PlayerCheck(client)) return;
		if(Level[client] != 18) return;

		new ent = CreateEntityByName("prop_dynamic_override");
		if(!IsValidEntity(ent)) return;
		SetEntityModel(ent, MINE_MODEL);
		DispatchKeyValue(ent, "targetname", "mine");
		SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", client); 
		SetEntProp(ent, Prop_Data, "m_usSolidFlags", 152);
		SetEntProp(ent, Prop_Data, "m_CollisionGroup", 1);
		SetEntProp(ent, Prop_Data, "m_nSolidType", 6);
		DispatchSpawn(ent);
		
		vAngles[0] = -90.0;
		TeleportEntity(ent, origin, vAngles, NULL_VECTOR);
		
		SDKHook(ent, SDKHook_StartTouch, OnTouch);
	}
	else if(StrEqual(szBuffer, "tf_projectile_rocket"))
	{
		new client = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
		if(!PlayerCheck(client)) return;
		
		if(Level[client] == 26 )
		{
			decl String:szName[16]; 
			
			GetEntPropString(iEntity, Prop_Data, "m_iName", szName, 16, 0);
			
			if(StrEqual(szName, "UFO")) if(GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity") == client) AcceptEntityInput(iEntity, "Kill");
			
			new iEnt = -1;
			while((iEnt = FindEntityByClassname(iEnt, "info_observer_point")) != -1)
			{
				if(IsValidEntity(iEnt) && iEnt > MaxClients)
				{
					GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
					if(StrEqual(szName, "UAV")) if(GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client) AcceptEntityInput(iEnt, "Kill");
				}
			}

			SetVariantInt(0);
			AcceptEntityInput(client, "SetForcedTauntCam");
			SetOverlay(client, "");
			SetClientViewEntity(client, client);
			SetEntityMoveType(client, MOVETYPE_WALK);
			
			effect(iEntity, origin, 2.0, "fireSmokeExplosion_trackb");
			EmitAmbientSound(BOMB_SOUND, origin, iEntity, SNDLEVEL_SCREAMING);
		}
	}
}


public Action:OnTouch(entity, other) 
{
	new client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!PlayerCheck(client)) return Plugin_Handled;
	
	if (AliveCheck(other))
	{
		decl Float:origin[3];
		GetEntPropVector(entity, Prop_Data, "m_vecOrigin", origin);
		
		if(GetClientTeam(other) != GetClientTeam(client))
		{
			new ent = Explode(client, origin, 0.0, BOMB_RADIUS, "fireSmokeExplosion_trackb", BOMB_SOUND); 
			AdmDamage(origin, ent, BOMB_RADIUS, BOMB_DMG, client, entity);
			
			AcceptEntityInput(entity, "Kill");
			PrintToChat(other, "\x04%T", "mine", other);
		}
	}
	return Plugin_Handled;
}

public Action:OnStartTouch(client, other)
{
	if(other > 0 && other <= MaxClients)
	{
		if(IsClientInGame(client) && IsPlayerAlive(client) && Level[client] == 23)
		{
			decl Float:ClientPos[3];
			decl Float:VictimPos[3];
			decl Float:VictimVecMaxs[3];
			GetClientAbsOrigin(client, ClientPos);
			GetClientAbsOrigin(other, VictimPos);
			GetEntPropVector(other, Prop_Send, "m_vecMaxs", VictimVecMaxs);
			new Float:victimHeight = VictimVecMaxs[2];
			new Float:HeightDiff = ClientPos[2] - VictimPos[2];

			if(HeightDiff > victimHeight)
			{
				decl Float:vec[3];
				GetEntPropVector(client, Prop_Data, "m_vecAbsVelocity", vec);

				if(vec[2] < 0.0 * -1.0)
                {
                    if(!GoombaCheck[client])
                    {
						EmitSoundToClient(client, REBOUND_SOUND);
						EmitSoundToClient(other, REBOUND_SOUND);
						effect(other, VictimPos, 2.0, "mini_fireworks");
						SDKHooks_TakeDamage(other, client, client, 500.0, DMG_PREVENT_PHYSICS_FORCE | DMG_CRUSH | DMG_ALWAYSGIB);
					}
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action:SinglStompTimer(Handle:timer, any:client)
{
    GoombaCheck[client] = false;
}

public Action:killll(Handle:timer, any:iEntityRef)
{
	new ent = EntRefToEntIndex(iEntityRef);
	if(!IsValidEntity(ent)) return Plugin_Stop;
	AcceptEntityInput(ent, "Kill");
	return Plugin_Continue;
}
//7777
stock LevelUp(client, slot, String:class[], String:name[], index, qual, level, String:classname[], String:att[], bool:up)
{
	if(StrEqual(class, "스카웃")) 
	{
		TF2_SetPlayerClass(client, TFClass_Scout);
		SetVariantString(SCOUT_MODEL);
	}
	if(StrEqual(class, "솔저"))
	{
		TF2_SetPlayerClass(client, TFClass_Soldier);
		SetVariantString(SOLDIER_MODEL);
	}
	if(StrEqual(class, "파이로")) 
	{
		TF2_SetPlayerClass(client, TFClass_Pyro);
		SetVariantString(PYRO_MODEL);
	}
	if(StrEqual(class, "데모맨"))
	{
		TF2_SetPlayerClass(client, TFClass_DemoMan);
		SetVariantString(DEMOMAN_MODEL);
	}
	if(StrEqual(class, "헤비"))
	{
		TF2_SetPlayerClass(client, TFClass_Heavy);
		SetVariantString(HEAVY_MODEL);
	}
	if(StrEqual(class, "엔지니어"))
	{
		TF2_SetPlayerClass(client, TFClass_Engineer);
		SetVariantString(ENGINEER_MODEL);
	}
	if(StrEqual(class, "메딕")) 
	{
		TF2_SetPlayerClass(client, TFClass_Medic);
		SetVariantString(MEDIC_MODEL);
	}
	if(StrEqual(class, "스나이퍼"))
	{
		TF2_SetPlayerClass(client, TFClass_Sniper);
		SetVariantString(SNIPER_MODEL);
	}
	if(StrEqual(class, "스파이"))
	{
		TF2_SetPlayerClass(client, TFClass_Spy);
		SetVariantString(SPY_MODEL);
	}

	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	
	
	RegenCheck[client] = false;
	TF2_RegeneratePlayer(client);
	RegenCheck[client] = true;
	
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", 1.0);
			
	switch (slot)
	{
		case 0: for(new i = 1; i <= 5; i++) TF2_RemoveWeaponSlot(client, i);

		case 1:
		{
			TF2_RemoveWeaponSlot(client, 0);
			for(new i = 2; i <= 5; i++) TF2_RemoveWeaponSlot(client, i);
		}
			
		case 2:
		{
			TF2_RemoveWeaponSlot(client, 0);
			TF2_RemoveWeaponSlot(client, 1);
			for(new i = 3; i <= 5; i++) TF2_RemoveWeaponSlot(client, i);
		}
			
		case 7:
		{
			for(new i = 0; i <= 3; i++) TF2_RemoveWeaponSlot(client, i);
			ChangePlayerWeaponSlot(client, 5);
			FakeClientCommand(client, "use tf_weapon_grapplinghook");
		}
	}
	
	SpawnWeapon(client, classname, slot, index, level, qual, att, TF2_GetPlayerClass(client));
	ChangePlayerWeaponSlot(client, slot);

	if(Level[client] == 7)
	{
		PerformBlind(client, 250);
		SetOverlay(client, "hud/scope_sniper_alt_ll");
	}
	else
	{
		PerformBlind(client, 0); 
		SetOverlay(client, "");
	}
	
	if(Level[client] == 24)
	{
		AttackCheck[client] = false;
		TF2_AddCondition(client, TFCond:66, -1.0);
		CreateTimer(7.0, NoAttack, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	else
	{
		if(TF2_IsPlayerInCondition(client, TFCond:66))
		{
			TF2_RemoveCondition(client, TFCond:66);
			AttackCheck[client] = false;
		}
	}
	
	if(Level[client] == 25)
	{
		decl Float:vAng[3];
		GetClientEyeAngles(client, vAng);
		TF2_AddCondition(client, TFCond_HalloweenKart, -1.0);
		AnimateClientCar(client, true);
	}
	else
	{
		if(TF2_IsPlayerInCondition(client, TFCond_HalloweenKart))
		{ 
			SetVariantInt(0);
			AcceptEntityInput(client, "SetForcedTauntCam");
			TF2_RemoveCondition(client, TFCond_HalloweenKart);
		}
	}
	
	if(Level[client] == 23)
	{
		TF2Attrib_SetByDefIndex(client, 26, 400.0);
		SetEntProp(client, Prop_Send, "m_iHealth", 900);
	}
	else if(Level[client] == 27) resize(client, 0.3, 60, true);
	else
	{
		new TFClassType:Class = TF2_GetPlayerClass(client);
		if(Class == TFClass_Soldier) resize(client, 1.0, 200, false);
		else if(Class == TFClass_Pyro || Class == TFClass_DemoMan) resize(client, 1.0, 175, false);
		else if(Class == TFClass_Heavy) resize(client, 1.0, 300, false);
		else if(Class == TFClass_Medic) resize(client, 1.0, 150, false);
		else resize(client, 1.0, 125, false);
	}
	
	if(Level[client] != 18)
	{
		new iEnt = -1;
		decl String:szName[16];
		while((iEnt = FindEntityByClassname2(iEnt, "prop_dynamic")) != -1)
		{
			if(IsValidEntity(iEnt) && iEnt > MaxClients)
			{
				GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
				if(StrEqual(szName, "mine")) if(GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client) AcceptEntityInput(iEnt, "Kill");
			} 
		}
	}

	if(Level[client] != 26) FindUFOKill(client);
	
	if(up)
	{
		EmitSoundToClient(client, LEVELUP_SOUND);
		PrintToChat(client, "\x03[Level Up] %T \x07FFFFFF'%s'\x03 %T", "level up", client, name, "new weapon", client);
	}
}

public Action:NoAttack(Handle:timer, any:client)
{
	SpawnWeapon(client, "tf_weapon_sniperrifle", 0, 15154, 5, 6, "305 ; 1", TF2_GetPlayerClass(client));
	TF2_RemoveWeaponSlot(client, 1);
	CreateTimer(5.0, ExpDown, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
	AttackCheck[client] = true;
}

public Action:ExpDown(Handle:timer, any:client) //88
{
	if(Level[client] != 24) return Plugin_Stop;
	PrintToChat(client, "\x035초 마다 당신의 경험치 1이 감소됩니다.");
	Exp[client] --;
	
	new p;
	p = Level[client] -1;
	for(new i = 0; i < MAX; i++)
	{
		if(Weapon_Config[i][MAX_LEVEL] == MAX)
		{
			if(i == p)
			{
				if(Exp[client] <= Weapon_Config[p][LevelExp])
				{
					Level[client] = p;
					LevelUp(client, Weapon_Config[i][WeaponSlot], Weapon_Config[p][WeaponClass], Weapon_Config[p][WeaponName], Weapon_Config[p][WeaponIndex], Weapon_Config[p][WeaponQual],
					Weapon_Config[p][WeaponLevel], Weapon_Config[p][WeaponClassName], Weapon_Config[p][WeaponAttribute], MESSAGE_OFF);
				}
			}
		}
	}
	
	return Plugin_Continue;
}

stock FindUFOKill(client)
{
	new iEnt = -1;
	decl String:szName[16]; 
	while((iEnt = FindEntityByClassname(iEnt, "tf_projectile_rocket")) != -1)
	{
		if(IsValidEntity(iEnt) && iEnt > MaxClients)
		{
			GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
			if(StrEqual(szName, "UFO")) if(GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client) AcceptEntityInput(iEnt, "Kill");
		}
	}
				
	while((iEnt = FindEntityByClassname(iEnt, "info_observer_point")) != -1)
	{
		if(IsValidEntity(iEnt) && iEnt > MaxClients)
		{
			GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
			if(StrEqual(szName, "UAV")) if(GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client) AcceptEntityInput(iEnt, "Kill");
		} 
	}
				
	SetVariantInt(0);
	AcceptEntityInput(client, "SetForcedTauntCam");
	SetOverlay(client, "");
	SetClientViewEntity(client, client);
	SetEntityMoveType(client, MOVETYPE_WALK);
}

stock Knockback(client, Float:power)
{
	decl Float:client_pos[3], Float:client_back[3];
	new Float:client_Velocity[3];
				
	GetClientAbsOrigin(client, client_pos);	
	ScaleVector(client_Velocity, power);
				
	GetAngleVectors(client_pos, client_back, NULL_VECTOR, NULL_VECTOR);
	client_pos[2] += 15.0;
				
	client_Velocity[0] = client_back[0]*SPEED;
	client_Velocity[1] = client_back[1]*SPEED;
	client_Velocity[2] = client_back[2]*SPEED;
				
	TeleportEntity(client, client_pos, NULL_VECTOR, client_Velocity);
}

stock resize(client, Float:size, health, bool:check)
{
	SetEntPropFloat(client, Prop_Send, "m_flModelScale", size);
	UpdatePlayerHitbox(client, size);
	SetEntPropFloat(client, Prop_Send, "m_flStepSize", size * 18.0, 0);
	if(check) TF2Attrib_SetByDefIndex(client, 125, -65.0);
	else TF2Attrib_RemoveByDefIndex(client, 125);
	TF2Attrib_RemoveByDefIndex(client, 26);
	SetEntProp(client, Prop_Send, "m_iHealth", health);
}

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

stock AnimateClientCar(iClient, bool bExit)
{
	static float flEnterDuration = 1.55;
	static float flExitDuration = 0.8;
	static iEnterSequences[] = {-1, 329, 294, 378, 290, 229, 280, 286, 293, 370};
	static iExitSequences[] = {-1, 334, 299, 383, 295, 234, 285, 291, 298, 375};
	new TFClassType:class = TF2_GetPlayerClass(iClient);
	if (bExit)
	{
		TF2_AddCondition(iClient, TFCond_HalloweenKart, flExitDuration - 0.12);
	}
	TF2_AddCondition(iClient, TFCond_HalloweenKartNoTurn, bExit ? flExitDuration : flEnterDuration);
	TE_Start("PlayerAnimEvent");
	TE_WriteNum("m_iPlayerIndex", iClient);
	TE_WriteNum("m_iEvent", 21);
	TE_WriteNum("m_nData", bExit ? iExitSequences[class] : iEnterSequences[class]);
	TE_SendToAll();
}

stock effect(entity, Float:pos[3], Float:time, String:effect[], bool:pp = false)
{
	new ent = CreateEntityByName("info_particle_system");
	if (ent != -1)
	{
		DispatchKeyValueVector(ent, "origin", pos);
		DispatchKeyValue(ent, "effect_name", effect);
		DispatchSpawn(ent);
					
		ActivateEntity(ent);
		AcceptEntityInput(ent, "Start");
		
		if(pp)
		{
			SetVariantString("!activator");
			AcceptEntityInput(ent, "SetParent", entity);
		}
					
		CreateTimer(time, killll, EntIndexToEntRef(ent), TIMER_FLAG_NO_MAPCHANGE);
	}
}

stock AdmDamage(Float:po[3], any:ent, Float:radius, Float:dmg, any:Boss, any:iEnt)
{
	if((IsValidEntity(ent) && IsValidEdict(ent))) {
		for(new i = 1 ; i <= MaxClients ; i++) {
			if(IsClientInGame(i) && IsPlayerAlive(i) && (GetClientTeam(i) != GetClientTeam(Boss))) {
				new Float:pos[3], Float:dist;

				GetClientAbsOrigin(i, pos);
				dist = GetVectorDistance(pos, po);

				if(dist <= radius) {
					new Handle:Tracing = TR_TraceRayFilterEx(po, pos, MASK_PLAYERSOLID, RayType_EndPoint, TraceRayDontHitEntity, iEnt);
					new index = TR_GetEntityIndex(Tracing);
					if(index == i) {
						new Float:damage, attacker;
						damage = dmg * ((radius - dist) / radius);
						attacker = Boss;
						if(i != Boss) SDKHooks_TakeDamage(i, attacker, attacker, damage, (1 << 3));
						continue;
					}
					CloseHandle(Tracing);
				}
			}
		}
	}
}

public bool:TraceRayDontHitEntity(iEntity, contentsMask, any:iData) return iData != iEntity;

stock Explode(client, Float:flPos[3], Float:flDamage, Float:flRadius, const String:strParticle[], const String:strSound[])
{
	new iBomb = CreateEntityByName("tf_generic_bomb");
	SetEntPropEnt(iBomb, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValueVector(iBomb, "origin", flPos);
	DispatchKeyValueFloat(iBomb, "damage", flDamage);
	DispatchKeyValueFloat(iBomb, "radius", flRadius);
	DispatchKeyValue(iBomb, "health", "1");
	DispatchKeyValue(iBomb, "explode_particle", strParticle);
	DispatchKeyValue(iBomb, "sound", strSound);
	DispatchSpawn(iBomb);

	AcceptEntityInput(iBomb, "Detonate");
	AcceptEntityInput(iBomb, "Kill");
	
	return iBomb;
}  

stock SpawnWeapon(client,String:name[],slot,index,level,qual,String:att[], TFClassType:classbased = TFClass_Unknown)
{
	new Flags = OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL | OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES;
	
	new Handle:newItem = TF2Items_CreateItem(Flags);
	
	if (newItem == INVALID_HANDLE)
		return -1;
	
	if (strcmp(name, "saxxy", false) != 0) Flags |= FORCE_GENERATION;
	
	if (StrEqual(name, "tf_weapon_shotgun", false)) strcopy(name, 64, "tf_weapon_shotgun_soldier");
	if (strcmp(name, "tf_weapon_shotgun_hwg", false) == 0 || strcmp(name, "tf_weapon_shotgun_pyro", false) == 0 || strcmp(name, "tf_weapon_shotgun_soldier", false) == 0)
	{
		switch (classbased)
		{
			case TFClass_Heavy: strcopy(name, 64, "tf_weapon_shotgun_hwg");
			case TFClass_Soldier: strcopy(name, 64, "tf_weapon_shotgun_soldier");
			case TFClass_Pyro: strcopy(name, 64, "tf_weapon_shotgun_pyro");
		}
	}
	
	TF2Items_SetClassname(newItem, name);
	TF2Items_SetItemIndex(newItem, index);
	TF2Items_SetLevel(newItem, level);
	TF2Items_SetQuality(newItem, qual);
	TF2Items_SetFlags(newItem, Flags);
	
	new String:atts[32][32]; 
	new count = ExplodeString(att, " ; ", atts, 32, 32);
	
	if (count > 1)
	{
		TF2Items_SetNumAttributes(newItem, count/2);
		new i2 = 0;
		for (new i = 0;  i < count;  i+= 2)
		{
			TF2Items_SetAttribute(newItem, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
		TF2Items_SetNumAttributes(newItem, 0);
		
	TF2_RemoveWeaponSlot(client, slot);
	new entity = TF2Items_GiveNamedItem(client, newItem);
	
	EquipPlayerWeapon(client, entity);

	CloneHandle(newItem);
	return entity;
}

stock RocketsGameFiredSpell(client, String:entity[], Float:vPosition[3], Float:vAngles[3], Float:flSpeed = 650.0, Float:flDamage = 800.0, iTeam, bool:bCritical = false){

	new String:strClassname[32] = "CTFProjectile_Rocket";	
	new iRocket = CreateEntityByName(entity);
	if(!IsValidEntity(iRocket))
		return -0;
		
	decl Float:vVelocity[3];
	decl Float:vBuffer[3];
    
	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
    
	vVelocity[0] = vBuffer[0]*flSpeed;
	vVelocity[1] = vBuffer[1]*flSpeed;
	vVelocity[2] = vBuffer[2]*flSpeed;
    
	TeleportEntity(iRocket, vPosition, vAngles, vVelocity);
    
	SetEntData(iRocket, FindSendPropInfo("CTFProjectile_Rocket", "m_iTeamNum"), GetClientTeam(client), true);
	SetEntData(iRocket, FindSendPropInfo(strClassname, "m_bCritical"), bCritical, true);
	SetEntPropEnt(iRocket, Prop_Send, "m_hOwnerEntity", client);
	SetEntDataFloat(iRocket, FindSendPropInfo(strClassname, "m_iDeflected") + 4, flDamage, true);
    
	SetVariantInt(iTeam);
	AcceptEntityInput(iRocket, "TeamNum", -1, -1, 0);

	SetVariantInt(iTeam);
	AcceptEntityInput(iRocket, "SetTeam", -1, -1, 0); 
    
	DispatchSpawn(iRocket);
	return iRocket;
}

stock ShootLaser(weapon, const String:strParticle[], Float:flStartPos[3], Float:flEndPos[3])
{
	new tblidx = FindStringTable("ParticleEffectNames");
	if (tblidx == INVALID_STRING_TABLE) 
	{
		LogError("Could not find string table: ParticleEffectNames");
		return;
	}
	new String:tmp[256];
	new count = GetStringTableNumStrings(tblidx);
	new stridx = INVALID_STRING_INDEX;
	new i;
	for (i = 0; i < count; i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if (StrEqual(tmp, strParticle, false))
		{
			stridx = i;
			break;
		}
	}
	if (stridx == INVALID_STRING_INDEX)
	{
		LogError("Could not find particle: %s", strParticle);
		return;
	}

	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", flStartPos[0]);
	TE_WriteFloat("m_vecOrigin[1]", flStartPos[1]);
	TE_WriteFloat("m_vecOrigin[2]", flStartPos[2] -= 32.0);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	TE_WriteNum("entindex", weapon);
	TE_WriteNum("m_iAttachType", 2);
	TE_WriteNum("m_iAttachmentPointIndex", 0);
	TE_WriteNum("m_bResetParticles", 0);    
	TE_WriteNum("m_bControlPoint1", 1);    
	TE_WriteNum("m_ControlPoint1.m_eParticleAttachment", 5);  
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[0]", flEndPos[0]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[1]", flEndPos[1]);
	TE_WriteFloat("m_ControlPoint1.m_vecOffset[2]", flEndPos[2]);
	TE_SendToAll();
}

stock PerformBlind(client, amount)
{
	int targets[2];
	targets[0] = client;
	
	int duration = 1536;
	int holdtime = 1536;
	int flags;
	
	if (amount == 0) flags = (0x0001 | 0x0010);
	else flags = (0x0002 | 0x0008);
	
	int color[4] = { 0, 0, 0, 0 };
	color[3] = amount;
	
	Handle message = StartMessageEx(g_FadeUserMsgId, targets, 1);
	if (GetUserMessageType() == UM_Protobuf)
	{
		Protobuf pb = UserMessageToProtobuf(message);
		pb.SetInt("duration", duration);
		pb.SetInt("hold_time", holdtime);
		pb.SetInt("flags", flags);
		pb.SetColor("clr", color);
	}
	else
	{
		BfWrite bf = UserMessageToBfWrite(message);
		bf.WriteShort(duration);
		bf.WriteShort(holdtime);
		bf.WriteShort(flags);		
		bf.WriteByte(color[0]);
		bf.WriteByte(color[1]);
		bf.WriteByte(color[2]);
		bf.WriteByte(color[3]);
	}
	
	EndMessage();
}

stock bool:UfoCoolTime(any:iClient, Float:fTime)
{
	if(!AliveCheck(iClient)) return false;
	if(GetEngineTime() - UfoTime[iClient] >= fTime) return true;
	else return false;
}

stock bool:SuPerJumpTimeCoolTime(any:iClient, Float:fTime)
{
	if(!AliveCheck(iClient)) return false;
	if(GetEngineTime() - SuPerJumpTime[iClient] >= fTime) return true;
	else return false;
}

stock bool:FireBallTimeCoolTime(any:iClient, Float:fTime)
{
	if(!AliveCheck(iClient)) return false;
	if(GetEngineTime() - FireBallTime[iClient] >= fTime) return true;
	else return false;
}

stock bool:ShieldCoolTime(any:iClient, Float:fTime)
{
	if(!AliveCheck(iClient)) return false;
	if(GetEngineTime() - ShieldTime[iClient] >= fTime) return true;
	else return false;
}

stock SetOverlay(client, const String:szOverlay[])
{
    SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & ~FCVAR_CHEAT);
    ClientCommand(client, "r_screenoverlay \"%s\"", szOverlay); 
    SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") | FCVAR_CHEAT);
}

stock FindEntityByClassname2(startEnt, const String:classname[])
{
	while(startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

stock bool:ChangePlayerWeaponSlot(iClient, iSlot) {
	new iWeapon = GetPlayerWeaponSlot(iClient, iSlot);
	if (iWeapon > MaxClients) {
		SetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon", iWeapon);
		return true;
	}
	return false;
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

bool:RPG_Config()
{
	new String:strPath[192];
	BuildPath(Path_SM, strPath, sizeof(strPath), "configs/rpg.cfg");
	
	if(!FileExists(strPath))
	{
		SetFailState("Failed to find rpg.cfg");
		return false;
	}
	
	new Handle:hKv = CreateKeyValues("custom_weapon");
	if(FileToKeyValues(hKv, strPath) && KvGotoFirstSubKey(hKv))
	{
		decl String:strSection[15];
		do
		{
			KvGetSectionName(hKv, strSection, sizeof(strSection));
			new PlayerLevel = StringToInt(strSection);
			if(PlayerLevel < 0 || PlayerLevel >= sizeof(Weapon_Config))
			{
				LogMessage("rpg index: \"%s\" is not valid. Must be between 0 - %d. Edit the rpg.cfg File", strSection, sizeof(Weapon_Config));
				continue;
			}
			
			KvGetString(hKv, "name", Weapon_Config[PlayerLevel][WeaponName], 64);
			KvGetString(hKv, "classname", Weapon_Config[PlayerLevel][WeaponClassName], 64);
			KvGetString(hKv, "attribute", Weapon_Config[PlayerLevel][WeaponAttribute], 100);
			KvGetString(hKv, "class", Weapon_Config[PlayerLevel][WeaponClass], 16);
			Weapon_Config[PlayerLevel][WeaponSlot] = KvGetNum(hKv, "slot");
			Weapon_Config[PlayerLevel][WeaponIndex] = KvGetNum(hKv, "index");
			Weapon_Config[PlayerLevel][WeaponLevel] = KvGetNum(hKv, "level");
			Weapon_Config[PlayerLevel][WeaponQual] = KvGetNum(hKv, "qual");
			Weapon_Config[PlayerLevel][LevelExp] = KvGetNum(hKv, "exp");
			Weapon_Config[PlayerLevel][LevelReset] = KvGetNum(hKv, "reset");
			
			Weapon_Config[PlayerLevel][MAX_LEVEL] = MAX;

		}while(KvGotoNextKey(hKv));
		
		if(hKv != INVALID_HANDLE) CloseHandle(hKv);
		return true;
	}
	
	if(hKv != INVALID_HANDLE) CloseHandle(hKv);
	return false;
}

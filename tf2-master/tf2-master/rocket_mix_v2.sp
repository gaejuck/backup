#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2attributes>

public Plugin:myinfo = {
	name		= "로켓 멈추 + 바운스 + 멀티 + 아이스,불",
	author	  = "TAKE 2",
	description = "개꿀잼",
	version	 = "3.7",
	url		 = "세브큐트보이라이브"
};

new ToolNum[MAXPLAYERS+1]; 
new RocketToolNum[MAXPLAYERS+1] = 0; 
new RocketNum[MAXPLAYERS+1];
new pc;


new bool:ToolReload[MAXPLAYERS+1];
new bool:Check[MAXPLAYERS+1] = false;
new bool:ToolAttack2[MAXPLAYERS+1];
new bool:ToolAttack3[MAXPLAYERS+1];
new bool:BounceAttack2[MAXPLAYERS+1];
new bool:EAttack2[MAXPLAYERS+1];
new Float:FIRocketTime[MAXPLAYERS+1];
new bool:ice[MAXPLAYERS+1] = false;


#define MAX 2 
#define ROCKETMAX 3 
#define ToolSelect	"buttons/button15.wav"
#define FREEZE	"physics/glass/glass_impact_bullet4.wav"
#include "rocket_stop/multrocket.sp" 
#include "rocket_stop/rocketBounce.sp"

public OnPluginStart()
{ 
	RegAdminCmd("sm_rt", aaaa, ADMFLAG_KICK); //ADMFLAG_KICK
	HookEvent("player_death", Player_Death); 
	HookEvent("post_inventory_application", inv);
	
	AddCommandListener(hook_VoiceMenu, "voicemenu");
	
	AddNormalSoundHook(SoundHook); 
}

public Action:SoundHook(clients[64], &numClients, String:sound[256], &entity, &channel, &Float:volume, &level, &pitch, &flags)
{
	if (entity > 0 && entity <= MaxClients)
	{
		if (Check[entity])
		{
			if (StrContains(sound, "rocket_s", false) != -1)
			{
				Format(sound, 256, "misc/rd_finale_beep01.wav");
				PrecacheSound(sound, false);
				EmitSoundToClient(entity, sound, -2, channel, level, flags, volume, pitch, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

public Action:hook_VoiceMenu(client, const String:command[], argc)
{
	decl String:cmd1[32], String:cmd2[32];
		
	if(!Check[client]) return Plugin_Continue;
	if(argc < 2) return Plugin_Handled;
		
	GetCmdArg(1, cmd1, sizeof(cmd1));
	GetCmdArg(2, cmd2, sizeof(cmd2));

	if(StrEqual(cmd1, "0") && StrEqual(cmd2, "0") && IsPlayerAlive(client) && !EAttack2[client])
	{
		EAttack2[client] = true;
		return Plugin_Handled;
	}
	else if (StrEqual(cmd1, "0") && StrEqual(cmd2, "0") && IsPlayerAlive(client) && EAttack2[client])
	{
		EAttack2[client] = false;
		return Plugin_Handled;
	}
	
	return Plugin_Continue;
}

public Action:inv(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(Check[client]) TF2Attrib_SetByDefIndex(client, 406, 1.0);
	else TF2Attrib_RemoveByDefIndex(client, 406);
}
	 
public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast) 
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(PlayerCheck(client))
	{ 
		if(ice[client]) 
		{
			SetEntityRenderMode(client, RENDER_TRANSCOLOR)
			SetEntityRenderColor(client, 255, 255, 255, 255);
			SetEntityMoveType(client, MOVETYPE_WALK);
			ice[client] = false;
		}
		if(EAttack2[client])
			EAttack2[client] = false;
	}
}

public Action:aaaa(client, args)
{
	if(!Check[client])
	{
		ToolNum[client] = 1;
		RocketNum[client] = 1;
		RocketToolNum[client] = 1;
		Check[client] = true;
		
		TF2Attrib_SetByDefIndex(client, 406, 1.0);
	}
	else
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				if(ice[i])
				{
					SetEntityRenderMode(i, RENDER_TRANSCOLOR)
					SetEntityRenderColor(i, 255, 255, 255, 255);
					SetEntityMoveType(i, MOVETYPE_WALK);
					ice[i] = false;
				}
			}
		}
		
		Check[client] = false;
		TF2Attrib_RemoveByDefIndex(client, 406);
	}
	return Plugin_Handled;
}

public OnMapStart()
{
	PrecacheSound(ToolSelect);
	PrecacheSound(FREEZE, true); 
}

public OnClientPostAdminCheck(client)
{ 
	Check[client] = false;
	ToolReload[client] = false; 
	ToolNum[client] = 0;
	ToolAttack2[client] = false;
	BounceAttack2[client] = false; 
	EAttack2[client] = false; 
	ToolAttack3[client] = false; 
	RocketNum[client]= 0;
	RocketToolNum[client]= 0;
	ice[client]= false;
	
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}  

public OnEntityCreated(entity,const String:classname[])  
{
	if (IsValidEntity(entity)) 
	{ 
		if (StrContains(classname,"tf_projectile",false)!=-1) 
		{
			SDKHook(entity, SDKHook_Spawn, OnSpawn);
		}
		if (StrEqual(classname, "tf_projectile_rocket", false))
		{   
			SDKHook(entity, SDKHook_StartTouch, OnStartTouch);
			SDKHook(entity, SDKHook_Spawn, FI); 
		}
	} 
}

public FI(entity)
{
	new client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidEntity(client)) return;
	if(!Check[client]) return;
	if(ToolNum[client] != 1) return;
	
	decl String:szName[16];
	GetEntPropString(entity, Prop_Data, "m_iName", szName, 16, 0);
	
	if(RocketToolNum[client] == 3 && StrEqual(szName, "Fire_Rocket"))
	{
		CreateParticle("spell_fireball_small_trail_red", entity, 1);
	}
	else if(RocketToolNum[client] == 2 && StrEqual(szName, "Ice_Rocket"))
	{
		CreateParticle("spell_fireball_small_trail_blue", entity, 1);
		CreateParticle("burningplayer_glow_blue", entity, 1);
	}
	else if(RocketToolNum[client] != 1) AcceptEntityInput(entity, "Kill");
}

public OnEntityDestroyed(Ent)
{  
	if (Ent <= 0 || Ent > 2048) return;
	RocketAmount[Ent] = 1;
}

public OnSpawn(iEntity)
{ 
	CreateTimer(0.01, ProjectileHook, iEntity, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
} 
   
public Action:ProjectileHook(Handle:hTimer, any:entity)  
{ 
	if(!IsValidEntity(entity))
		return Plugin_Stop; 
	  
	new client = GetEntPropEnt(entity,Prop_Data,"m_hOwnerEntity"); 
	
	if(!AliveCheck(client)) CreateTimer(0.1, ProjTimer);
	
	if(AliveCheck(client) && Check[client])
	{  
		if(EAttack2[client]) SetEntityMoveType(entity ,MOVETYPE_NONE);
		else SetEntityMoveType(entity ,MOVETYPE_FLY);
	} 
	return Plugin_Continue;
}

public Action:ProjTimer(Handle:timer)
	return Plugin_Stop;
	
public Action:OnTakeDamage(client, &admin, &iEnt, &Float:fDamage, &iDamagetype, &iWeapon, Float:fForce[3], Float:fForcePos[3])
{
	if (AliveCheck(admin) && AliveCheck(client) && (admin != client))
	{
		if(Check[admin])
		{
			decl String:strClassname[64], String:szName[16];
			GetEntityClassname(iEnt, strClassname, sizeof(strClassname));
			if (StrEqual(strClassname, "tf_projectile_rocket"))
			{
				if (GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == admin)
				{
					GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
					if(StrEqual(szName, "Ice_Rocket"))
					{	
						decl Float:position[3];
						GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
						EmitSoundToClient(client, FREEZE, _, _, _, _, 0.7, _, _, position, _, false);
						
						if(!ice[client])
						{
							SetEntityRenderMode(client, RENDER_TRANSCOLOR)
							SetEntityRenderColor(client, 0, 17, 255, 255);
							SetEntityMoveType(client, MOVETYPE_NONE);
							ice[client] = true;
						}
						else
						{
							SetEntityRenderMode(client, RENDER_TRANSCOLOR)
							SetEntityRenderColor(client, 255, 255, 255, 255);
							SetEntityMoveType(client, MOVETYPE_WALK);
							ice[client] = false;
						}
					}
					if(StrEqual(szName, "Fire_Rocket"))
					{
						TF2_IgnitePlayer(client, admin);
					}
				}
			}
		}
	}
	return Plugin_Continue;
}
	
public Action:OnPlayerRunCmd(client, &iButtons, &iImpulse, Float:fVel[3], Float:fAng[3], &iWeapon)
{
	if(IsPlayerAlive(client) && Check[client])
	{
		SetHudTextParams(0.0, 0.25, 0.1, 150, 150, 0, 150, 0, 0.0, 0.0, 0.0);
		
		new String:StopCheck[32];
		if(EAttack2[client]) StopCheck = "작동 On";
		else StopCheck = "작동 Off";
		
		
		new String:RocketOption[32];
		if(RocketToolNum[client] == 1) RocketOption = "일반 로켓";
		else if(RocketToolNum[client] == 2) RocketOption = "아이스 로켓";
		else RocketOption = "파이어 로켓";
		 
		switch(ToolNum[client]) 
		{
			case 1:	ShowHudText(client, -1, "멀티 로켓\n날아갈 로켓 : %d개 (우클릭으로 작동)\nE 키 누를시 멈춤 (상태 : %s)\n로켓 효과 : %s", RocketNum[client], StopCheck, RocketOption);
			case 2:	ShowHudText(client, -1, "로켓 바운스 \n(우클릭 누르고 있으면 터집니다.)\nE 키 누를시 멈춤 (상태 : %s)", StopCheck);
		} 
		//재장전 
		if(iButtons & IN_RELOAD && !ToolReload[client]) 
		{
			if(ToolNum[client] < MAX) ToolNum[client]++; 
			else ToolNum[client] = 1;
				 
			EmitSoundToClient(client, ToolSelect);
			ToolReload[client] = true;
		}
		else if (!(iButtons & IN_RELOAD) && ToolReload[client])
			ToolReload[client] = false;
		 
		//멀티 로켓
		if(iButtons & IN_ATTACK2 && ToolNum[client] == 1 && !ToolAttack2[client])
		{
			ToolAttack2[client] = true; 
				
			if(RocketNum[client] < 10) RocketNum[client]++;
			else RocketNum[client] = 1;	
		} 
		else if (!(iButtons & IN_ATTACK2) && ToolNum[client] == 1 && ToolAttack2[client])
			ToolAttack2[client] = false;
 
		//멀티 로켓 휠 버튼
		if(iButtons & IN_ATTACK3 && ToolNum[client] == 1 && !ToolAttack3[client])
		{
			ToolAttack3[client] = true; 
				
			if(RocketToolNum[client] < ROCKETMAX) RocketToolNum[client]++; 
			else RocketToolNum[client] = 1;
				 
			EmitSoundToClient(client, ToolSelect);
		} 
		else if (!(iButtons & IN_ATTACK3) && ToolNum[client] == 1 && ToolAttack3[client])
			ToolAttack3[client] = false;
			
		//바운스 해제
		if(iButtons & IN_ATTACK2 && ToolNum[client] == 2)
			BounceAttack2[client] = true; 
		else BounceAttack2[client] = false; 
	}
	return Plugin_Continue;
}

stock Handle:CreateParticle(String:type[], entity, attach=0, Float:xOffs=0.0, Float:yOffs=0.0, Float:zOffs=0.0)
{
    pc = CreateEntityByName("info_particle_system");
    
    if (IsValidEdict(pc)) {
        decl Float:pos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
        pos[0] += xOffs;
        pos[1] += yOffs;
        pos[2] += zOffs;
        TeleportEntity(pc, pos, NULL_VECTOR, NULL_VECTOR);
        DispatchKeyValue(pc, "effect_name", type);

        if (attach != 0) {
            SetVariantString("!activator");
            AcceptEntityInput(pc, "SetParent", entity, pc, 0);
        
            if (attach == 2) {
                SetVariantString("head");
                AcceptEntityInput(pc, "SetParentAttachmentMaintainOffset", pc, pc, 0);
            }
        }
        DispatchKeyValue(pc, "targetname", "present");
        DispatchSpawn(pc);
        ActivateEntity(pc);
        AcceptEntityInput(pc, "Start");
        
    }
    
    return INVALID_HANDLE;
}

stock bool:CheckFiRocketCoolTime(any:iClient, Float:fTime)
{
	if(!AliveCheck(iClient)) return false;
	if(GetEngineTime() - FIRocketTime[iClient] >= fTime) return true;
	else return false;
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

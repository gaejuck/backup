#include <sdktools>
#include <sourcemod>
#include <sdkhooks>
#include <tf2_stocks>

//----------------------------------- 미 사 일 //-----------------------------------//

#define W_ROCKET_AIRSTRIKE "models/props_teaser/saucer.mdl"
#define SPEED 800.0
#define BOMB_SOUND "weapons/explode3.wav"
#define launch "uav/missle_launch.mp3"
#define proj "tf_projectile_lightningorb"
#define proj2 "tf_projectile_spellkartorb"

new Handle:ClientTimer[MAXPLAYERS + 1];

new g_iMissle[MAXPLAYERS+1];
new g_iUav[MAXPLAYERS+1];
new Float:fMisslePos[3];
new g_iMissleOwner[2048];

new Float:mRocket[MAXPLAYERS+1];

//----------------------------------- 온 오프 //-----------------------------------//

new bool:aaa[MAXPLAYERS+1] = false;

//----------------------------------- 바 운 스 //-----------------------------------//

#define BOUNCE 999
#define	MAX_EDICT_BITS	11
#define	MAX_EDICTS		(1 << MAX_EDICT_BITS)

new g_nBounces[MAX_EDICTS];



public OnPluginStart()
{
	RegAdminCmd("am", aaaa, 0);
	
	HookEvent("player_death", Player_Death, EventHookMode_Pre);
	
	for(new i = 1 ; i <= MaxClients ; i++)
	{
		if(aaa[i] == true)
		{
			g_iUav[i] = INVALID_ENT_REFERENCE;
			g_iMissle[i] = INVALID_ENT_REFERENCE;
		}
	}
	
	new iEnt = -1;
	decl String:szName[16];
	while((iEnt = FindEntityByClassname2(iEnt, "info_observer_point")) != -1)
	{
		GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
		if(StrEqual(szName, "UAV")) AcceptEntityInput(iEnt, "Kill");
	}
}

public OnClientDisconnected(client)
{
	aaa[client] = false;

	if (ClientTimer[client] != INVALID_HANDLE)
		KillTimer(ClientTimer[client]);
	ClientTimer[client] = INVALID_HANDLE;
}

public OnPluginEnd()
{
	for(new a = 1; a <= MaxClients; a++)
	{
		if(IsValidClient(a) && IsPlayerAlive(a))
		{
			SetOverlay(a, "");
			SetClientViewEntity(a, a);
			PlayerRender(a, 255);
			aaa[a] = false;
		}

		if (ClientTimer[a] != INVALID_HANDLE)
			KillTimer(ClientTimer[a]);
		ClientTimer[a] = INVALID_HANDLE;

		
		if(IsValidEntity(EntRefToEntIndex(g_iUav[a])) && EntRefToEntIndex(g_iUav[a]) > MaxClients) 
		{
			AcceptEntityInput(EntRefToEntIndex(g_iUav[a]), "kill");
			g_iUav[a] = INVALID_ENT_REFERENCE;
		}
		if(IsValidEntity(EntRefToEntIndex(g_iMissle[a])) && EntRefToEntIndex(g_iMissle[a]) > MaxClients)
		{
			AcceptEntityInput(EntRefToEntIndex(g_iMissle[a]), "kill");
			g_iMissle[a] = INVALID_ENT_REFERENCE;
		}
	}
}

public Action:aaaa(client, args)
{
	if(AliveCheck(client))
	{
		if(aaa[client] == false)
		{
			TF2_RemoveWeaponSlot(client, 0);
			TF2_RemoveWeaponSlot(client, 1);
			TF2_RemoveWeaponSlot(client, 2);
			SetVariantInt(1);
			AcceptEntityInput(client, "SetForcedTauntCam");
				
			SetEntityMoveType(client, MOVETYPE_NONE);
			PlayerRender(client, 0);
				
			missaleOn(client);
			aaa[client] = true;
		}
		else
		{
			TF2_RegeneratePlayer(client);
			PlayerRender(client, 255);
			PrintToChat(client, "\x04미사일 Off");
			aaa[client] = false
		}
	}
	else
		PrintToChat(client, "\x04살아있는 상태에서만 가능합니다.");
	return Plugin_Handled;
}


public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{	
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));

	if(IsValidClient(client) && IsValidClient(attacker) && aaa[attacker])
	{
		if(client != attacker)
		{
			aaa[client] = false;
			aaa[attacker] = false;
			
			PlayerRender(client, 255);
			PlayerRender(attacker, 255);
		}
		else
		{
			aaa[client] = false;
			aaa[attacker] = false;
			
			PlayerRender(client, 255);
			PlayerRender(attacker, 255);
		}
	}
}

public OnMapStart()
{
	PrecacheModel(W_ROCKET_AIRSTRIKE, true);
	PrecacheSound(BOMB_SOUND, true);
	PrecacheSound(launch, true);
}

public OnEntityDestroyed(iEntity)
{
	if(!IsValidEdict(iEntity) || g_iMissleOwner[iEntity] == INVALID_ENT_REFERENCE) return;
	decl String:szBuffer[64];
	GetEdictClassname(iEntity, szBuffer, 64);
	if(!StrEqual(szBuffer, "tf_projectile_rocket")) return;

	new iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidClient(iOwner))	return;
	g_iMissleOwner[iEntity] = INVALID_ENT_REFERENCE;
	if(g_iMissle[iOwner] == INVALID_ENT_REFERENCE) return;
	
	if(iEntity == EntRefToEntIndex(g_iMissle[iOwner]))
	{
		g_iMissle[iOwner] = INVALID_ENT_REFERENCE;
		
		new Handle:Pack;
		CreateDataTimer(0.0, BigExplode, Pack);
		WritePackCell(Pack, iOwner);
		WritePackCell(Pack, iEntity);

		
		PrintCenterText(iOwner, "");
		SetOverlay(iOwner, "");
		if(IsValidEntity(EntRefToEntIndex(g_iUav[iOwner])))
				SetClientViewEntity(iOwner, iOwner);
		else SetOverlay(iOwner, "");
	}
}

public missaleOn(client)
{			
	if(IsValidEdict(EntRefToEntIndex(g_iUav[client])) && EntRefToEntIndex(g_iUav[client] > MaxClients)) return;
	PrintToChat(client, "\x04W키 : 부스터, 우클릭 : 폭퐈!");
	new Float:fPos[3];
	GetClientEyePosition(client, fPos);
			
	TeleportEntity(client, fPos, NULL_VECTOR, NULL_VECTOR);
			
	new info_observer_point = CreateEntityByName("info_observer_point");
	SetEntPropEnt(info_observer_point, Prop_Send, "m_hOwnerEntity", client);
	DispatchKeyValue(info_observer_point, "targetname", "UAV");
	DispatchKeyValue(info_observer_point, "Angles", "90 0 0");
	DispatchKeyValue(info_observer_point, "TeamNum", "0");
	DispatchKeyValue(info_observer_point, "StartDisabled", "0");
	
	SetVariantString("!activator");
	AcceptEntityInput(info_observer_point, "SetParent", client);
	
	DispatchSpawn(info_observer_point);
	AcceptEntityInput(info_observer_point, "Enable");
	// SetEntityMoveType(info_observer_point, MOVETYPE_NOCLIP);
			
	TeleportEntity(info_observer_point, fPos, NULL_VECTOR, NULL_VECTOR);
	
	SetClientViewEntity(client, info_observer_point);
	
	g_iUav[client] = EntIndexToEntRef(info_observer_point);
	g_iMissle[client] = INVALID_ENT_REFERENCE;

	SetOverlay(client, "effects/stealth_overlay");
}
	
public OnEntityCreated(iEntity, const String:strClassname[])
{
	if(StrEqual(strClassname, "info_observer_point", false)) SDKHook(iEntity, SDKHook_Spawn, OnSpawn);
}

public OnSpawn(iEntity)
{
	CreateTimer(0.1, ThinkHook, EntIndexToEntRef(iEntity), TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

public Action:ThinkHook(Handle:hTimer, any:iEntityRef)
{
	new iEntity = EntRefToEntIndex(iEntityRef);
	if(!IsValidEntity(iEntity)) return Plugin_Stop;
	new iOwner = GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity");
	if(!IsValidClient(iOwner)) return Plugin_Stop;
		
	if(!IsPlayerAlive(iOwner))
		SetEntPropEnt(iOwner, Prop_Send, "m_hObserverTarget", iEntity);
		
	new Float:fAng[3], Float:fPos[3];	
		
	GetClientEyeAngles(iOwner, fAng);
	GetEntPropVector(iEntity, Prop_Data, "m_vecOrigin", fPos);
	TeleportEntity(iEntity, NULL_VECTOR, fAng, NULL_VECTOR);
		
	if(aaa[iOwner] == true)
	{
		if(g_iMissle[iOwner] == INVALID_ENT_REFERENCE)
		{
			SetClientViewEntity(iOwner, iEntity);

			SetOverlay(iOwner, "effects/stealth_overlay");
			
			new iEnt = CreateEntityByName("tf_projectile_rocket");
			DispatchKeyValue(iEnt, "targetname", "missle");

			new Float:fDirection[3], Float:fVelocity[3];

			GetAngleVectors(fAng, fDirection, NULL_VECTOR, NULL_VECTOR);

			fVelocity[0] = fDirection[0]*SPEED;
			fVelocity[1] = fDirection[1]*SPEED;
			fVelocity[2] = fDirection[2]*SPEED;

			SetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity", iOwner);
			SetEntProp(iEnt,	Prop_Send, "m_bCritical", 1);
			SetEntProp(iEnt,	Prop_Send, "m_iTeamNum", GetClientTeam(iOwner));
			SetEntDataFloat(iEnt, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 10.0, true);
			SetEntPropFloat(iEnt, Prop_Send, "m_flModelScale", 0.8);
			DispatchSpawn(iEnt);
			AcceptEntityInput(iEnt, "Enable");
			TeleportEntity(iEnt, fPos, fAng, fVelocity);
			
			SetEntityModel(iEnt, W_ROCKET_AIRSTRIKE);
			SetClientViewEntity(iOwner, iEnt);
			
			g_iMissleOwner[iEnt] = EntIndexToEntRef(iOwner);
			g_iMissle[iOwner] = EntIndexToEntRef(iEnt);
			
			g_nBounces[iEnt] = 0;
			
			SDKHookEx(iEnt, SDKHook_ShouldCollide, OnCollide);
			SDKHookEx(iEnt, SDKHook_StartTouch, OnStartTouch);
				
			ClientTimer[iOwner] = CreateTimer(0.01, ThinkHookMissle, g_iMissle[iOwner], TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);

			EmitSoundToAll(launch, iEnt, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, NULL_VECTOR, NULL_VECTOR, true);
		}
	}
	else
	{	
		if (ClientTimer[iOwner] != INVALID_HANDLE)
			KillTimer(ClientTimer[iOwner]);
		ClientTimer[iOwner] = INVALID_HANDLE;
			
		if(IsValidEntity(EntRefToEntIndex(g_iUav[iOwner])))
		{
			AcceptEntityInput(EntRefToEntIndex(g_iUav[iOwner]), "kill");
			g_iUav[iOwner] = INVALID_ENT_REFERENCE;
		}
			
		if(IsValidEntity(EntRefToEntIndex(g_iMissle[iOwner])))
		{
			AcceptEntityInput(EntRefToEntIndex(g_iMissle[iOwner]), "kill");
			g_iMissle[iOwner] = INVALID_ENT_REFERENCE;
		}
				
		SetVariantInt(0);
		AcceptEntityInput(iOwner, "SetForcedTauntCam");
		SetClientViewEntity(iOwner, iOwner);
		SetOverlay(iOwner, "");
		SetEntityMoveType(iOwner, MOVETYPE_WALK);
	}
	
	return Plugin_Continue;
}

public Action:ThinkHookMissle(Handle:hTimer, any:iMissle)
{
	iMissle = EntRefToEntIndex(iMissle);
	if(!IsValidEntity(iMissle))
		return Plugin_Stop;
		
	new iOwner = GetEntPropEnt(iMissle, Prop_Send, "m_hOwnerEntity");

	if(GetEntProp(iMissle,Prop_Send, "m_iDeflected") == 1) {
		SetEntPropEnt(iMissle, Prop_Send, "m_hOwnerEntity", EntRefToEntIndex(g_iMissleOwner[iMissle]));
		SetEntProp(iMissle,Prop_Send, "m_iDeflected", 0);
		SetEntProp(iMissle,	Prop_Send, "m_iTeamNum", GetClientTeam(EntRefToEntIndex(g_iMissleOwner[iMissle])));
		SetEntDataFloat(iMissle, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, 300.0, true);
	}

	if(!IsValidEntity(EntRefToEntIndex(g_iMissle[iOwner]))) return Plugin_Stop;

	new Float:fAng[3];
	GetClientEyeAngles(iOwner, fAng);	
	
	new iButtons = GetClientButtons(iOwner);
	if(iButtons & IN_ATTACK3) {
		PrintCenterText(iOwner, "");
		
		g_iMissleOwner[iMissle] = INVALID_ENT_REFERENCE;
		g_iMissle[iOwner] = INVALID_ENT_REFERENCE;
		
		new Handle:Pack;
		CreateDataTimer(0.0, BigExplode, Pack);
		WritePackCell(Pack, iOwner);
		WritePackCell(Pack, iMissle);

		SetOverlay(iOwner, "");
		if(IsValidEntity(EntRefToEntIndex(g_iUav[iOwner])))
			SetClientViewEntity(iOwner, iOwner);
		else SetOverlay(iOwner, "");
		AcceptEntityInput(iMissle, "kill");
		return Plugin_Stop;
	}
	
	if(iButtons & IN_ATTACK)
	{
		if(CheckRocketCoolTime(iOwner, 2.0))
		{
			mRocket[iOwner] = GetEngineTime();
			ShootProjectile(iOwner, fMisslePos, fAng, proj, 1100.0, 90.0); //77
		}
	}
	
	if(iButtons & IN_ATTACK2)
	{
		if(CheckRocketCoolTime(iOwner, 2.0))
		{
			mRocket[iOwner] = GetEngineTime();
			ShootProjectile(iOwner, fMisslePos, fAng, proj2, 1100.0, 90.0); //77
		}
	}

	new Float:fDirection[3], Float:fVelocity[3];

	GetAngleVectors(fAng, fDirection, NULL_VECTOR, NULL_VECTOR);
	
	new Float:fPos[3];
	GetEntPropVector(iMissle, Prop_Data, "m_vecOrigin", fPos);

	if(iButtons & IN_FORWARD)
	{
		fVelocity[0] = fDirection[0]*SPEED;
		fVelocity[1] = fDirection[1]*SPEED;
		fVelocity[2] = fDirection[2]*SPEED;
	} 
	TeleportEntity(iMissle, NULL_VECTOR, fAng, fVelocity);
	
	GetEntPropVector(g_iMissle[iOwner], Prop_Data, "m_vecOrigin", fMisslePos);
	return Plugin_Continue;
}

public Action:OnStartTouch(entity, other)
{
	if (other > 0 && other <= MaxClients)
		return Plugin_Continue;
		
	// Only allow a rocket to bounce x times.
	if (g_nBounces[entity] >= BOUNCE)
		return Plugin_Continue;
	
	SDKHookEx(entity, SDKHook_Touch, OnTouch);
	return Plugin_Handled;
}

public Action:OnTouch(entity, other)
{
	decl Float:vOrigin[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vOrigin);
	
	decl Float:vAngles[3];
	GetEntPropVector(entity, Prop_Data, "m_angRotation", vAngles);
	
	decl Float:vVelocity[3];
	GetEntPropVector(entity, Prop_Data, "m_vecAbsVelocity", vVelocity);
	
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TEF_ExcludeEntity, entity);
	
	if(!TR_DidHit(trace))
	{
		CloseHandle(trace);
		return Plugin_Continue;
	}
	
	decl Float:vNormal[3];
	TR_GetPlaneNormal(trace, vNormal);
	
	//PrintToServer("Surface Normal: [%.2f, %.2f, %.2f]", vNormal[0], vNormal[1], vNormal[2]);
	
	CloseHandle(trace);
	
	new Float:dotProduct = GetVectorDotProduct(vNormal, vVelocity);
	
	ScaleVector(vNormal, dotProduct);
	ScaleVector(vNormal, 2.0);
	
	decl Float:vBounceVec[3];
	SubtractVectors(vVelocity, vNormal, vBounceVec);
	
	decl Float:vNewAngles[3];
	GetVectorAngles(vBounceVec, vNewAngles);
	TeleportEntity(entity, NULL_VECTOR, vNewAngles, vBounceVec);
	
	g_nBounces[entity]++;
	
	SDKUnhook(entity, SDKHook_Touch, OnTouch);
	return Plugin_Handled;
}

public bool:TEF_ExcludeEntity(entity, contentsMask, any:data)
{
	return (entity != data);
}


public Action:BigExplode(Handle:timer, Handle:hPack)
{
	ResetPack(hPack);
	new Owner = ReadPackCell(hPack);
	new Entity = ReadPackCell(hPack);
	
	new particle = CreateEntityByName("info_particle_system");
	
	if(IsValidEntity(particle)) 
	{
		SetEntPropEnt(particle, Prop_Send, "m_hOwnerEntity", Owner);
		TeleportEntity(particle, fMisslePos, NULL_VECTOR, NULL_VECTOR);
		DispatchKeyValue(particle, "effect_name", "fireSmokeExplosion_trackb");
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(0.1, DeleteParticles, particle);

		if(!IsSoundPrecached(BOMB_SOUND)) PrecacheSound(BOMB_SOUND);
 
		PrefetchSound(BOMB_SOUND);
		EmitAmbientSound(BOMB_SOUND, fMisslePos, Entity, SNDLEVEL_SCREAMING);
	}
}
public Action:DeleteParticles(Handle:timer, any:particle)
{
	new ent = EntRefToEntIndex(particle);

	if (ent != INVALID_ENT_REFERENCE)
	{
		new String:classname[64];
		GetEdictClassname(ent, classname, sizeof(classname));
		if (StrEqual(classname, "info_particle_system", false))
			AcceptEntityInput(ent, "kill");
	}
}

public bool:TraceEntity(iEnt, contentsMask, any:iClient) return !(iEnt == iClient);

public bool:OnCollide(entity, collisiongroup, contentsMask, bool:result)
{
	return bool:IsValidClient(entity);
}

stock PlayerRender(client, vol)
{
	SetEntityRenderMode(client, RENDER_GLOW);
	SetEntityRenderColor(client, 255, 255, 255, vol);
	
	new iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "tf_wearable")) != -1) 
	{
		if (GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client)
		{
			AcceptEntityInput(iEnt, "Kill");
		}
	}
	
	while ((iEnt = FindEntityByClassname(iEnt, "tf_powerup_bottle")) != -1) 
	{
		if (GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client)
		{
			AcceptEntityInput(iEnt, "Kill");
		}
	}

	for (new iSlot = 0; iSlot < 5; iSlot++)
	{
		new iEntity = GetPlayerWeaponSlot(client, iSlot);
		
		if (iEntity != -1)
		{
			SetEntityRenderMode(iEntity, RENDER_GLOW);
			SetEntityRenderColor(iEntity, 255, 255, 255, vol); 
		}
	}
	
	if(vol == 255)
	{
		for (new iSlot = 1; iSlot < 5; iSlot++)
		{
			new iEntity = GetPlayerWeaponSlot(client, iSlot);
			
			if (iEntity != -1)
			{
				SetEntityRenderMode(iEntity, RENDER_GLOW);
				SetEntityRenderColor(iEntity, 255, 255, 255, vol); 
			}
		}
		TF2_RegeneratePlayer(client);
	}
}

ShootProjectile(client, Float:vPosition[3], Float:vAngles[3] = NULL_VECTOR, String:strEntname[], Float:Speed, Float:dmg)
{
	new iTeam = GetClientTeam(client);
	new iProjectile = CreateEntityByName(strEntname);
	
	if (!IsValidEntity(iProjectile))
		return -1;
	
	decl Float:vVelocity[3];
	decl Float:vBuffer[3];
	
	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
	
	vVelocity[0] = vBuffer[0]*Speed;
	vVelocity[1] = vBuffer[1]*Speed;
	vVelocity[2] = vBuffer[2]*Speed;
	
	SetEntPropEnt(iProjectile, Prop_Send, "m_hOwnerEntity", client);
	if (IsCritBoosted(client)) SetEntProp(iProjectile, Prop_Send, "m_bCritical", 1);
	else SetEntProp(iProjectile, Prop_Send, "m_bCritical", 0);
	SetEntProp(iProjectile,    Prop_Send, "m_iTeamNum", iTeam, 1);
	SetEntProp(iProjectile,    Prop_Send, "m_nSkin", (iTeam-2));

	SetVariantInt(iTeam);
	AcceptEntityInput(iProjectile, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);					//77
	AcceptEntityInput(iProjectile, "SetTeam", -1, -1, 0);
	if (strcmp(strEntname, proj, false) == 0) SetEntDataFloat(iProjectile, FindSendPropInfo("CTFProjectile_SpellLightningOrb", "m_iDeflected")+4, dmg, true);
	else if (strcmp(strEntname, proj2, false) == 0) SetEntDataFloat(iProjectile, FindSendPropInfo("CTFProjectile_SpellKartOrb", "m_iDeflected")+4, dmg, true);
	else SetEntPropFloat(iProjectile, Prop_Send, "m_flDamage", dmg);
	TeleportEntity(iProjectile, vPosition, vAngles, vVelocity); 
	DispatchSpawn(iProjectile);
	return iProjectile;
} 

stock bool:IsCritBoosted(client)
{
	if (TF2_IsPlayerInCondition(client, TFCond_Kritzkrieged) || TF2_IsPlayerInCondition(client, TFCond_HalloweenCritCandy) || TF2_IsPlayerInCondition(client, TFCond_CritCanteen) || TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood) || TF2_IsPlayerInCondition(client, TFCond_CritOnWin) || TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture) || TF2_IsPlayerInCondition(client, TFCond_CritOnKill) || TF2_IsPlayerInCondition(client, TFCond_CritMmmph) || TF2_IsPlayerInCondition(client, TFCond_CritOnDamage))
	{
		return true;
	}
	return false;
}

stock bool:CheckRocketCoolTime(any:iClient, Float:fTime)
{
	if(!AliveCheck(iClient)) return false;
	if(GetEngineTime() - mRocket[iClient] >= fTime) return true;
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

stock IsValidClient(client, bool:replaycheck = true)
{
	if(client <= 0 || client > MaxClients) return false;
	if(!IsClientInGame(client)) return false;
	if(GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
	if(replaycheck) {
		if(IsClientSourceTV(client) || IsClientReplay(client)) return false;
	}
	return true;
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

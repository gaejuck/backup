#include <sdktools>
#include <sdkhooks>
#include <tf2items>
#include <tf2_stocks>
#include <tf2attributes> 

#define MAX 1
#define ToolSelect	"buttons/button15.wav"
#define ToolAttackSound	"ui/hitsound_squasher.wav"


new bool:ToolReload[MAXPLAYERS+1];
new bool:ToolAttack2[MAXPLAYERS+1];

new bool:ToolAttack3[MAXPLAYERS+1];
new Float:ToolDistance[MAXPLAYERS+1];

new bool:ToolNoclip[MAXPLAYERS+1];

new ToolNum[MAXPLAYERS+1];

new bool:ToolGun[2049];


public OnPluginStart()
{
	RegAdminCmd("sm_tool", ToolCommand, ADMFLAG_KICK);	
}

public OnMapStart()
{
	PrecacheSound(ToolSelect);
	PrecacheSound(ToolAttackSound);
}

public OnClientPostAdminCheck(client)
{
	ToolReload[client] = false;
	ToolAttack2[client] = false;
	ToolAttack3[client] = false;
	ToolNoclip[client] = false;
	ToolNum[client] = 0;
	ToolDistance[client] = 0.0;
}

public Action:ToolCommand(client, args)
{
	SpawnWeapon(client, "tf_weapon_shotgun_pyro", 1, 15047, 69, 5, "305 ; 1 ; 1 ; 0 ; 106 ; 2 ; 45 ; 0.1");
	// SpawnWeapon(client, "tf_weapon_revolver", 1, 15051, 69, 5, "305 ; 1 ; 1 ; 0 ; 106 ; 2 ; 45 ; 0.1");
	return Plugin_Handled;
}

public OnEntityDestroyed(ent)
{
	if (ent <= 0 || ent > 2048) 
		return;
	
	ToolGun[ent] = false;
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if(IsValidEntity(weapon) && ToolGun[weapon] && AliveCheck(client))
	{
		new Float:flStartPos[3], Float:flEyeAng[3], Float:flHitPos[3];
		GetClientEyePosition(client, flStartPos);
		GetClientEyeAngles(client, flEyeAng);
			
		new Handle:hTrace = TR_TraceRayFilterEx(flStartPos, flEyeAng, MASK_SHOT, RayType_Infinite, TraceRayDontHitEntity, client);
		TR_GetEndPosition(flHitPos, hTrace);
		new iHitEntity = TR_GetEntityIndex(hTrace);
		CloseHandle(hTrace);
		
		switch(ToolNum[client])
		{
			case 1:	
			{
				if(iHitEntity > 0)
				{
					if(!AliveCheck(iHitEntity))	return Plugin_Continue;
					if(ToolAttack2[client])
					{
						TF2_StunPlayer(iHitEntity, 5.0, _, TF_STUNFLAGS_GHOSTSCARE, 0);
					}
				}
			}
		}
		SetEntProp(weapon, Prop_Send, "m_iClip1", 7);
	}
	return Plugin_Continue;
}

public Action:OnPlayerRunCmd(client, &iButtons, &iImpulse, Float:fVel[3], Float:fAng[3], &iWeapon)
{
	if(IsPlayerAlive(client))
	{
		new aw = GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");
		if(IsValidEntity(aw) && ToolGun[aw])
		{
			SetHudTextParams(0.0, 0.25, 0.1, 150, 150, 0, 150, 0, 0.0, 0.0, 0.0);
	
			// ShowHudText(client, -1, "X");
			
			switch(ToolNum[client])
			{
				case 1:	ShowHudText(client, -1, "어드민 툴 (타겟)\n왼쪽: 기절해라!, 오른쪽: 무서워떨어라!");
			}
			if(iButtons & IN_ATTACK2)
			{
				ToolAttack2[client] = true;
				iButtons &= ~IN_ATTACK2;
				iButtons |= IN_ATTACK;
			}
			else 
				ToolAttack2[client] = false;
				
			if(iButtons & IN_ATTACK3) //휠 클릭 눌렀을때
			{
				ToolDistance[client]++;
					
				if(ToolDistance[client] < 10000.0)
					ToolDistance[client]+=100;
				else
					ToolDistance[client] = 1.0;
					
				ToolAttack3[client] = true;
			}		 
			else // 휠 클릭 누르지 않았을때
			{
				ToolAttack3[client] = false;
			}
				
			if(iButtons & IN_RELOAD && !ToolReload[client])
			{
				if(ToolNum[client] < MAX)
					ToolNum[client]++;
				else
					ToolNum[client] = 1;
				
				EmitSoundToClient(client, ToolSelect);
				
				ToolReload[client] = true;
			}
			else if (!(iButtons & IN_RELOAD) && ToolReload[client])
				ToolReload[client] = false;
		}
	}
	
	return Plugin_Continue;
}

stock FireTeamRocket(String:classname[], Float:vPos[3], Float:vAng[3], iOwner = 0, iTeam = 0, Float:flSpeed = 1100.0, Float:flDamage = 90.0, bool:bCrit = false, iWeapon = -1)
{
	new iRocket = CreateEntityByName(classname);
	if (IsValidEntity(iRocket))
	{
		decl Float:vVel[3]; // Determine velocity based on given speed/angle
		GetAngleVectors(vAng, vVel, NULL_VECTOR, NULL_VECTOR);
		ScaleVector(vVel, flSpeed);
        
		if(!StrEqual(classname, "tf_projectile_energy_ball"))
			SetEntProp(iRocket, Prop_Send, "m_bCritical", bCrit);

		SetRocketDamage(iRocket, flDamage);

		SetEntProp(iRocket, Prop_Send, "m_nSkin", iTeam); // 0 = RED 1 = BLU
		SetEntProp(iRocket, Prop_Send, "m_iTeamNum", iTeam, 1);
		SetVariantInt(iTeam);
		AcceptEntityInput(iRocket, "TeamNum");
		SetVariantInt(iTeam);
		AcceptEntityInput(iRocket, "SetTeam");

		if (iOwner != -1)
		{
			SetEntPropEnt(iRocket, Prop_Send, "m_hOwnerEntity", iOwner);
		}
		TeleportEntity(iRocket, vPos, vAng, vVel);
		DispatchSpawn(iRocket);

		if (iWeapon != -1)
		{
			SetEntPropEnt(iRocket, Prop_Send, "m_hOriginalLauncher", iWeapon); 
			SetEntPropEnt(iRocket, Prop_Send, "m_hLauncher", iWeapon); 
		}
		return iRocket;
	}
	return -1; 
}

static s_iRocketDmgOffset = -1;

stock SetRocketDamage(iRocket, Float:flDamage)
{
    if (s_iRocketDmgOffset == -1)
    {
        s_iRocketDmgOffset = FindSendPropOffs("CTFProjectile_Rocket", "m_iDeflected") + 4; // Credit to voogru
    }
    SetEntDataFloat(iRocket, s_iRocketDmgOffset, flDamage, true);
}
				
public bool TraceRayDontHitEntity(entity, mask, any:data)
{
	if (entity == data) 
		return false;
	
	return true;
}

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


stock SpawnWeapon(client,String:name[],slot,index,level,qual,String:att[])
{
	new Flags = OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL | OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES;
	
	new Handle:newItem = TF2Items_CreateItem(OVERRIDE_ALL);
	
	if (newItem == INVALID_HANDLE)
		return -1;
		
	TF2Items_SetClassname(newItem, name);
	
	if (strcmp(name, "saxxy", false) != 0) Flags |= FORCE_GENERATION;
		
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
	ToolGun[entity] = true;
	ToolNum[client] = 1;
	

	CloneHandle(newItem);
	return entity;
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

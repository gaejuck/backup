#include <sourcemod>
#include <sdkhooks>
#include <sdktools>

#define POS 500.0
#define SPEED 2000.0
#define DMG 9999.0

new bool:hr[MAXPLAYERS+1] = false;

public OnPluginStart()
{
	RegAdminCmd("ac", HomingRocket, 0);
}

public Action:HomingRocket(client, args)
{
	if(!hr[client])
	{
		PrintToChat(client, "위에서 로켓이 날아옵니다.");
		CreateTimer(0.2, SRT, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		hr[client] = true;
	}
	else
	{
		PrintToChat(client, "사라집니당");
		hr[client] = false;
	}
}

public Action:SRT(Handle:timer, any:client)
{
	if(!hr[client]) return Plugin_Stop;
	
	if(IsPlayerAlive(client))
		SpawnRocket(client, SPEED, DMG);
	else return Plugin_Stop;
	return Plugin_Continue;
}

stock SpawnRocket(client, Float:Speed, Float:dmg)
{

	new iTeam = GetClientTeam(client);
		
	decl Float:flStartPos[3];
	GetClientEyePosition(client, flStartPos);

	new iEnt = CreateEntityByName("tf_projectile_rocket");
	if(IsValidEntity(iEnt))
	{
		SetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity", client);
		SetEntProp(iEnt, Prop_Send, "m_bCritical", 1);
			
		SetEntProp(iEnt,    Prop_Send, "m_iTeamNum", iTeam, 1);
		SetEntProp(iEnt,    Prop_Send, "m_nSkin", (iTeam-2));
			
		DispatchSpawn(iEnt);
		AcceptEntityInput(iEnt, "Enable");
			
		decl Float:vVelocity[3];
		decl Float:vBuffer[3];
			
		new Float:flEyeAng[3]; flEyeAng[0] = 90.0;

		GetAngleVectors(flEyeAng, vBuffer, NULL_VECTOR, NULL_VECTOR);
			
		vVelocity[0] = vBuffer[0]*Speed;
		vVelocity[1] = vBuffer[1]*Speed;
		vVelocity[2] = vBuffer[2]*Speed;
			
		flStartPos[2] += POS;
			
		SetEntDataFloat(iEnt, FindSendPropInfo("CTFProjectile_Rocket", "m_iDeflected")+4, dmg, true);
					
		TeleportEntity(iEnt, flStartPos, flEyeAng, vVelocity);
	}
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

#include <sourcemod> 
#include <sdktools>

public Plugin:myinfo = 
{
	name = "[TF2] Dodgeball Rocket Trail",
	author = "TAKE 2",
	description = "로켓 파티클",
	version = "2.0",
	url = "x"
}

new Handle:EM = INVALID_HANDLE;
new String:EEMM[256];

public OnPluginStart()
{
	RegServerCmd("tf_dodgeball_rocket", Rocket_Particle)
	
	EM = CreateConVar("sm_dodgeball_particle", "spell_teleport_black", "파티클 이름 적으면댐");
	GetConVarString(EM, EEMM, sizeof(EEMM));
	HookConVarChange(EM, ConVarChanged);
}


public ConVarChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
    GetConVarString(cvar, EEMM, sizeof(EEMM));
}


public Action:Rocket_Particle(iArgs)
{
	if(iArgs != 1)
	{
		PrintToServer("Usage: tf_dodgeball_rocket @rocket")
		return Plugin_Handled;
	}
	new String:strBuffer[32];
	GetCmdArg(1, strBuffer, sizeof(strBuffer)); new irocket = StringToInt(strBuffer, 10);
	
	CreateParticle(EEMM, irocket, 1);

	
	return Plugin_Handled;
}

stock Handle:CreateParticle(String:type[], entity, attach=0, Float:xOffs=0.0, Float:yOffs=0.0, Float:zOffs=0.0)
{
    new pc = CreateEntityByName("info_particle_system");
    
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

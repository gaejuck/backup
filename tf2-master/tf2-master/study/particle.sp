#include <sdktools> 

new pc;

public OnPluginStart()
{
	RegConsoleCmd("sm_p", pp);
	RegConsoleCmd("sm_pp", ppp);
}

public Action:pp(client, args)
	CreateParticle("waterfall_rocksplash", client, 0);
	
public Action:ppp(client, args)
	CreateTimer(0.1, DeleteParticle, pc);

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

public Action:DeleteParticle(Handle:timer, any:pc)
{
    if (IsValidEntity(pc))
    {
        new String:classN[64];
        GetEdictClassname(pc, classN, sizeof(classN));
        if (StrEqual(classN, "info_particle_system", false))
        {
            RemoveEdict(pc);
        }
    }
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
	if (IsValidEdict(particle))
	{
		new String:classname[64];
		GetEdictClassname(particle, classname, sizeof(classname));

		if (StrEqual(classname, "info_particle_system", false))
			RemoveEdict(particle);
	}
}

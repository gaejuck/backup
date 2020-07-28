#include <tf2_stocks>

public OnPluginStart()
{
	RegConsoleCmd("sm_test", look);
}

public Action:look(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(AliveCheck(i) == true)
		{
			new Float:vEPosit[3], Float:Dist;
			new Float:vOrigin[3];
			GetClientAbsOrigin(client, vOrigin);
			GetClientAbsOrigin(i, vEPosit);
			GetEntPropVector(i, Prop_Data, "m_vecOrigin", vEPosit);
			// Dist = GetVectorDistance(vEPosit, vOrigin); //이거하니까 안대는듯
			
			if(((GetClientTeam(client) == 2 && GetClientTeam(i) == 3) ||
			(GetClientTeam(client) == 3 && GetClientTeam(i) == 2)) && i != client)
			if(Dist < 1000.0)
			{
				CreateParticle("skull_island_embers", i, 5.0, 0);
				PrintToChatAll("\x03%N님이 광역 스킬을 시전했습니다.", client);
			}
		}
	}
	return Plugin_Handled;
}

stock Handle:CreateParticle(String:type[], entity, Float:time, attach=0, Float:xOffs=0.0, Float:yOffs=0.0, Float:zOffs=0.0)
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
        return CreateTimer(time, DeleteParticle, pc);
    } else {
        LogError("Presents (CreateParticle): Could not create info_particle_system");
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
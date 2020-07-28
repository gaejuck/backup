#include <sourcemod>
#include <sdktools> 

#define NO_ATTACH 0 //그자리에 남고
#define ATTACH_NORMAL 1 //그냥쓰면 땅에 붙고 좌표 붙이면 그대로 가고
#define ATTACH_HEAD 1 //좌표없인 작동안대는듯? 숫자는 점점 굵어지는듯. 2가 얇았던걸로 기억..

public OnPluginStart()
{
	HookEvent("player_hurt", EventHurt);
}

public Action:EventHurt(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new client = GetClientOfUserId(GetEventInt(event, "userid")); 
	
	if(PlayerCheck(client) && PlayerCheck(attacker))
	{
		if(client != attacker && PlayerCheck(attacker))
		{
			CreateParticle("spell_skeleton_goop_green",5.0, client, ATTACH_NORMAL);	
		}
	}
}

stock Handle:CreateParticle(String:type[], Float:time, entity, attach=NO_ATTACH, Float:xOffs=0.0, Float:yOffs=0.0, Float:zOffs=0.0)
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

        if (attach != NO_ATTACH) {
            SetVariantString("!activator");
            AcceptEntityInput(particle, "SetParent", entity, particle, 0);
        
            if (attach == ATTACH_HEAD) {
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

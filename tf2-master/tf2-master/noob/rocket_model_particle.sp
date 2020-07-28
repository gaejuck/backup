#include <sdktools>
#include <sdkhooks>

#define NO_ATTACH 0 
#define ATTACH_NORMAL 1 
#define ATTACH_HEAD 2 

new bool:rocket[MAXPLAYERS+1] = false;

new Handle:CvarRcket_effect = INVALID_HANDLE;
new String:g_strRocket[64];

new Handle:g_hNuketModel = INVALID_HANDLE;

new Handle:rocket_size = INVALID_HANDLE;

public OnPluginStart()
{
	RegConsoleCmd("sm_rocket", aaaa, "로켓이펙트"); //sm_rocket_model "models/weapons/w_models/Nyan_Rocket.mdl"
	 //sm_rocket_effect "taunt_conga_string01"
	CvarRcket_effect = CreateConVar("sm_rocket_effect", "taunt_conga_string01", "로켓 이펙트 수정 ㄱㄱ");
	g_hNuketModel = CreateConVar("sm_rocket_model", "models/weapons/w_models/Nyan_Rocket.mdl", "Model for the rockets");
	rocket_size = CreateConVar("sm_rocket_size", "1", "1~99999");
	
	HookConVarChange(CvarRcket_effect, CvarChange_Particle);
	HookConVarChange(g_hNuketModel, CvarChange_NukeModel);	
}

public OnClientDisconnect(client) 
{ 
	rocket[client] = false; 
}

public OnMapStart()
{
	new String:strNukeModel[128];
	GetConVarString(g_hNuketModel, strNukeModel, sizeof(strNukeModel));
	if(!IsModelPrecached(strNukeModel)) PrecacheModel(strNukeModel);	
}


public CvarChange_NukeModel(Handle:Cvar, const String:strOldValue[], const String:strNewValue[])
{
	if(!IsModelPrecached(strNewValue)) PrecacheModel(strNewValue);
}

public CvarChange_Particle(Handle:cvar, const String:oldVal[], const String:newVal[])
{
    GetConVarString(cvar, g_strRocket, sizeof(g_strRocket));
}  

public Action:aaaa(client, args)
{
	if(PlayerCheck(client))
	{
		if(rocket[client] == false)
		{
			PrintToChat(client, "\x04ok");
			rocket[client] = true;
		}
		else if(rocket[client] == true)
		{
			PrintToChat(client, "\x04no");
			rocket[client] = false;
		}
	}
	
	return Plugin_Handled;
} 


public OnEntityCreated(entity, const String:classname[])
{
	if(IsValidEntity(entity) && entity > MaxClients && StrEqual(classname, "tf_projectile_rocket", false))
	{
		SDKHook(entity, SDKHook_SpawnPost, SDKHook_OnSpawnPost);
	}
}

public SDKHook_OnSpawnPost(entity)
{
	new owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if(owner < 1)
	{
		return;
	}
	
	if(rocket[owner] == true)
	{
		CreateParticle(g_strRocket, entity, ATTACH_NORMAL);
		new String:strNukeModel[128];
		GetConVarString(g_hNuketModel, strNukeModel, sizeof(strNukeModel));
		if(IsModelPrecached(strNukeModel)) SetEntityModel(entity, strNukeModel);
		SetEntPropFloat(entity, Prop_Send, "m_flModelScale", GetConVarFloat(rocket_size)); 
	}
}

public Trail(entity)
{
	
	new trail = CreateEntityByName("env_spritetrail");
	
	if (trail == INVALID_ENT_REFERENCE)
		return;
	
	if (!IsValidEntity(trail)) 
	{
		return;
	}

	char strTargetName[MAX_NAME_LENGTH];
	Format(strTargetName,sizeof(strTargetName),"projectile%d",entity);
	DispatchKeyValue(entity, "targetname", strTargetName);
	DispatchKeyValue(trail, "parentname", strTargetName);
	DispatchKeyValueFloat(trail, "lifetime", 1.0);
	DispatchKeyValueFloat(trail, "endwidth", 15.0);
	DispatchKeyValueFloat(trail, "startwidth", 6.0);
	DispatchKeyValue(trail, "renderamt", "255");

	DispatchKeyValue(trail, "spritename", "materials/trails/rainbow.vmt");
	DispatchKeyValue(trail, "rendercolor", "255 255 255 255");

	
	DispatchKeyValue(trail, "rendermode", "3");
	DispatchSpawn(trail);

	float vec[3];
	GetEntPropVector(entity, Prop_Data, "m_vecOrigin", vec);

	TeleportEntity(trail, vec, NULL_VECTOR, NULL_VECTOR);

	SetVariantString(strTargetName);
	AcceptEntityInput(trail, "SetParent"); 
	SetEntPropFloat(trail, Prop_Send, "m_flTextureRes", 0.05);
	return;
}

stock Handle:CreateParticle(String:type[], entity, attach=NO_ATTACH, Float:xOffs=0.0, Float:yOffs=0.0, Float:zOffs=0.0)
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
        
    }
    
    return INVALID_HANDLE;
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
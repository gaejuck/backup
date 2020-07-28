#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#define PLUGIN_VERSION "0.0.1.0"

public Plugin:myinfo =
{
	name = "pipe bomb model",
	author = "L. Duke",
	description = "pipe bomb model",
	version = PLUGIN_VERSION,
	url = "http://www.lduke.com/"
};

#define MDL_PIPE "models/props_junk/watermelon01.mdl"
#define MDL_PIPE_REMOTE "models/props_junk/wood_crate002a.mdl"

new Handle:cvModel = INVALID_HANDLE;
new Handle:cvModel_2 = INVALID_HANDLE;
new String:model[512];
new String:model2[512];

public OnPluginStart()
{
	CreateConVar("sm_pbm_version", PLUGIN_VERSION, "Mushroom Health version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	cvModel = CreateConVar("sm_pbm_model", MDL_PIPE, "model for pipe bomb");
	cvModel_2 = CreateConVar("sm_pbm_model", MDL_PIPE_REMOTE, "model for pipe bomb");
}


public OnConfigsExecuted()
{
	GetConVarString(cvModel, model, sizeof(model));
	PrecacheModel(model, true);
	
	GetConVarString(cvModel_2, model2, sizeof(model2));
	PrecacheModel(model2, true);
}


// entity listener
public OnEntityCreated(entity, const String:classname[])
{
	if (!IsValidEdict(entity))
		return;
	
	// is entity a rocket?
	if (StrEqual(classname, "tf_weapon_sword"))
	{
		SDKHook(entity, SDKHook_SpawnPost, OnPipeSpawned);
	}
	if (StrEqual(classname, "tf_projectile_pipe_remote"))
	{
		SDKHook(entity, SDKHook_SpawnPost, OnPipeSpawned2);
	}
}

public OnPipeSpawned(entity)
{
	SetEntityModel(entity, model);
}

public OnPipeSpawned2(entity)
{
	SetEntityModel(entity, model2);
}

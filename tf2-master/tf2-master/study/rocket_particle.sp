#include <sourcemod>
#include <sdkhooks>
#include <sdktools> 

new aaa[MAXPLAYERS+1];
new String:effect[MAXPLAYERS+1][64];
new pc;


#define zombie "models/player/items/scout/scout_zombie.mdl"
#define ROCKETMODEL "models/weapons/w_models/tw_rocket.mdl"
#define bird "models/props_forest/bird.mdl"

public OnPluginStart()
{
	RegAdminCmd("sm_rocket", rocket, 0);
}

public OnMapStart()
{
	if(!IsModelPrecached(ROCKETMODEL)) PrecacheModel(ROCKETMODEL);	
}

public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "tf_projectile_rocket"))
	{
		SDKHook(entity, SDKHook_SpawnPost, soldier);
	}
}

public soldier(entity)
{ 
	new client = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity");
	if(!PlayerCheck(client)) return;
	if(!IsValidEntity(client)) return;
	if(!aaa[client]) return;
	if(IsModelPrecached(ROCKETMODEL))
	{
		SetEntityModel(entity, ROCKETMODEL);
		CreateParticle(effect[client], entity, 1);
	}
} 

public Action:rocket(client, args)
{
	mmmmenu(client);
	return Plugin_Handled;
}
public mmmmenu(client)
{
	new Handle:info = CreateMenu(AnimationSelect);
	SetMenuTitle(info, "애니메이션");
	AddMenuItem(info, "x", "없음");  
	AddMenuItem(info, "rockettrail_!", "기본");
	AddMenuItem(info, "raygun_projectile_blue_crit", "레일건");  
	AddMenuItem(info, "eyeboss_beam_angry", "모노큘");  
	AddMenuItem(info, "spell_fireball_small_trail_red", "메테오 레드");  
	AddMenuItem(info, "spell_fireball_small_trail_blue", "메테오 블루");  
	AddMenuItem(info, "burningplayer_glow_blue", "글로우");  
	AddMenuItem(info, "sapper_sentry1_fx", "새퍼");    
	AddMenuItem(info, "spell_batball_blue", "박쥐 블루");    
	AddMenuItem(info, "spell_batball_red", "박쥐 레드");    
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
}

public AnimationSelect(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(menu, select, info, sizeof(info));
		
		if(StrEqual(info, "x")) 
		{
			aaa[client] = false;
			effect[client] = "";
			mmmmenu(client);
		}
		else
		{
			aaa[client] = true;
			effect[client] = info;
			mmmmenu(client);
		}
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
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
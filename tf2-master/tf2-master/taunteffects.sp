#include <tf2_stocks>

new bool:on[MAXPLAYERS+1] = false;
new bool:taunt_check[MAXPLAYERS+1] = false;
new String:effect_name[MAXPLAYERS+1][64];

new Float:removetimer[MAXPLAYERS+1];

new Float:x[MAXPLAYERS+1];
new Float:y[MAXPLAYERS+1];
new Float:z[MAXPLAYERS+1];


public Plugin:myinfo =
{
	name = "tf2 taunt effects",
	author = "TAKE 2",
	description = "도발 이펙트!",
	version = "1.0", 
	url = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
}

new String:TauntConfig[120];

public OnPluginStart()
{
	RegConsoleCmd("sm_te", te);
	
	BuildPath(Path_SM, TauntConfig, sizeof(TauntConfig), "configs/taunt-effects.cfg");
}
public Action:te(client, args)
{
	if(taunt_check[client] == false)
	{
		PrintToChat(client, "\x03커스텀 도발 이펙트가 적용되었습니다. 도발 해보세요!");
		taunt_check[client] = true;
	}
	else
	{
		PrintToChat(client, "\x03커스텀 도발 이펙트가 적용해제 되었습니다.");
		taunt_check[client] = false;
	}
	
	return Plugin_Handled;
}


public OnClientDisconnected(client)
{
	if(on[client] == true)
		on[client] = false;
		
	if(taunt_check[client] == true)
		taunt_check[client] = false;
		
	removetimer[client] = 0.0;
	
	effect_name[client] = "";
	
	x[client] = 0.0;
	y[client] = 0.0;
	z[client] = 0.0;
}

public TF2_OnConditionAdded(int client, TFCond condition)
{
	decl String:effect[64], String:name[64];
	
	new Handle:DB = CreateKeyValues("taunt_effect");

	FileToKeyValues(DB, TauntConfig);
	if(taunt_check[client] == true)
	{
		if(KvGotoFirstSubKey(DB))
		{
			do
			{
				KvGetSectionName(DB, name, sizeof(name));
				KvGetString(DB, "effect", effect, sizeof(effect));
				new Index = KvGetNum(DB, "index");
				new Float:time = KvGetFloat(DB, "timer");
				new Float:remover_timer = KvGetFloat(DB, "remover_timer");
				
				new Float:xpos = KvGetFloat(DB, "x");
				new Float:ypos = KvGetFloat(DB, "y");
				new Float:zpos = KvGetFloat(DB, "z");
				
				if (condition == TFCond_Taunting)
				{
					if(GetEntProp(client, Prop_Send, "m_iTauntItemDefIndex") == Index)
					{
						on[client] = true;
						
						effect_name[client] = effect;
						removetimer[client] = remover_timer;
						x[client] = xpos;
						y[client] = ypos;
						z[client] = zpos; 
						
						CreateTimer(time, conga, client, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
					}
				}
			}
		
			while(KvGotoNextKey(DB));
			
			KvGoBack(DB);
		}
	}
	
	KvRewind(DB);
	CloseHandle(DB);
}

public TF2_OnConditionRemoved(client, TFCond:condition)
{
	if (condition == TFCond_Taunting)
	{
		on[client] = false;
	}
}

public Action:conga(Handle:timer, any:client)
{
	if(on[client] == true)
		if(AliveCheck(client))
			CreateParticle(effect_name[client], client, removetimer[client], 0, x[client],y[client],z[client]);
		else
			PrintToChat(client, "\x03살아있지 않습니다.");
	else
		KillTimer(timer);
	return Plugin_Continue;
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

stock bool:IsClientAdmin(client)
{
	new AdminId:Cl_ID;
	Cl_ID = GetUserAdmin(client);
	if(Cl_ID != INVALID_ADMIN_ID)
		return true;
	return false;
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

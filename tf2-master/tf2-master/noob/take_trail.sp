#include <sourcemod>
#include <sdktools>

new pc[MAXPLAYERS+1];

new String:TrailConfig[120];
new String:VipConfig[120];

new vip[MAXPLAYERS+1];
new trail_count[MAXPLAYERS+1];

public OnPluginStart()
{
	LoadTranslations("common.phrases");

	BuildPath(Path_SM, TrailConfig, sizeof(TrailConfig), "configs/take_vip/trail.cfg");
	BuildPath(Path_SM, VipConfig, sizeof(VipConfig), "configs/take_vip/user.txt");
	
	RegConsoleCmd("sm_trail", user_trail);
	RegConsoleCmd("sm_tr", trail_reload);
	
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_death", Player_Death);
}

public OnClientPutInServer(client)
	vr(client);
	
public Action:user_trail(client, args)
{
	vr(client);
	trail_menu(client);
	return Plugin_Handled;
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	trail_count[client] = 0;
}

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	CreateTimer(0.1, DeleteParticle, client);
}


public vr(client)
{
	if(client > 0 && client <= MaxClients)
	{
		new String:SteamID[32];
		GetClientAuthId(client, AuthId_Steam2, SteamID, sizeof(SteamID));

		decl Handle:Vault;
		Vault = CreateKeyValues("vip");

		FileToKeyValues(Vault, VipConfig);
		KvJumpToKey(Vault, "vip", false);
		vip[client] = KvGetNum(Vault, SteamID);
		KvRewind(Vault);

		CloseHandle(Vault);	
	}
}

public Action:trail_reload(client, args)
{
	PrintToChat(client, "리로드댐");
	return Plugin_Handled;
}

public Action:trail_menu(client)
{
	if(vip[client] == 1)
	{
		decl String:Paritcle[50], String:name[50];
		new String:temp[256];
		
		new Handle:menu = CreateMenu(select_trail);
		new Handle:DB = CreateKeyValues("Trail"); 
		
		SetMenuTitle(menu, "트레일", client);
			
		FileToKeyValues(DB, TrailConfig);
		if(KvGotoFirstSubKey(DB))
		{
			do
			{
				KvGetSectionName(DB, name, sizeof(name));
				KvGetString(DB, "Particle", Paritcle, sizeof(Paritcle));
				new Float:x = KvGetFloat(DB, "x");
				new Float:y = KvGetFloat(DB, "y");
				new Float:z = KvGetFloat(DB, "z");
				
				Format(temp, sizeof(temp), "%s*%f*%f*%f", Paritcle, x, y, z);
				AddMenuItem(menu, temp, name);
			}
			while(KvGotoNextKey(DB));
			
			KvGoBack(DB);
		}
		
		DisplayMenu(menu, client, MENU_TIME_FOREVER);
		KvRewind(DB);
	}
	else
		PrintToChat(client, "당신은 기부자가 아닙뉘다.");
	return Plugin_Handled;
}

public select_trail(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}

	if(action == MenuAction_Select)
	{
		decl String:info[256], String:aa[4][256];
		GetMenuItem(menu, select, info, sizeof(info));
		
		ExplodeString(info, "*", aa, 4, 256);
		
		if(AliveCheck(client))
		{
			if(trail_count[client] == 0)
			{
				CreateParticle(aa[0], client, 1, StringToFloat(aa[1]), StringToFloat(aa[2]), StringToFloat(aa[3]));
				trail_count[client] = 1;
			}
			else
			{
				PrintToChat(client, "\x03한 라운드당 한번에 트레일을 사용 할 수 있습니다.");
			}
		}
		else
		{
			PrintToChat(client, "\x03당신은 살아 있지 않습니다.");
		}
	} 
}

stock Handle:CreateParticle(String:type[], entity, attach=0, Float:xOffs=0.0, Float:yOffs=0.0, Float:zOffs=0.0)
{
    pc[entity] = CreateEntityByName("info_particle_system");
    
    if (IsValidEdict(pc[entity])) {
        decl Float:pos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
        pos[0] += xOffs;
        pos[1] += yOffs;
        pos[2] += zOffs;
        TeleportEntity(pc[entity], pos, NULL_VECTOR, NULL_VECTOR);
        DispatchKeyValue(pc[entity], "effect_name", type);

        if (attach != 0) {
            SetVariantString("!activator");
            AcceptEntityInput(pc[entity], "SetParent", entity, pc[entity], 0);
        
            if (attach == 2) {
                SetVariantString("head");
                AcceptEntityInput(pc[entity], "SetParentAttachmentMaintainOffset", pc[entity], pc[entity], 0);
            }
        }
        DispatchKeyValue(pc[entity], "targetname", "present");
        DispatchSpawn(pc[entity]);
        ActivateEntity(pc[entity]);
        AcceptEntityInput(pc[entity], "Start");
        
    } 
    
    return INVALID_HANDLE;
}
public Action:DeleteParticle(Handle:timer, any:client)
{
    if (IsValidEntity(pc[client]))
    {
        new String:classN[64];
        GetEdictClassname(pc[client], classN, sizeof(classN));
        if (StrEqual(classN, "info_particle_system", false))
        {
            RemoveEdict(pc[client]);
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

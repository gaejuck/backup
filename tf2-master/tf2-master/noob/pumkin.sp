#include <sourcemod>
#include <sdkhooks> 
#include <sdktools>

new Float:g_pos[3];

public OnPluginStart()
{
	RegAdminCmd("sm_p", Command_Pumpkin, 0);
}

public Action:Command_Pumpkin(client, args)
{
	pumkin_menu(client);
	return Plugin_Handled;
}

public pumkin_menu(client)
{
	new Handle:info = CreateMenu(Menu_Information);
	SetMenuTitle(info, "펌킨");
	AddMenuItem(info, "1", "안 터지는 펌킨");  
	AddMenuItem(info, "2", "터지는 펌킨");
	AddMenuItem(info, "3", "랜덤");
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
}

public Menu_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
		if(select == 0)
		{
			pumkin_random(client, 1);
			pumkin_menu(client);
		}
		else if(select == 1)
		{
			pumkin_random(client, 2);
			pumkin_menu(client);
		}
		
		else if(select == 2)
		{
			new chances = GetRandomInt(1, 30);
		 
			if(chances <= 10)
				pumkin_random(client, 1);
			else
				pumkin_random(client, 2);
				
			pumkin_menu(client);
		}
		if(action == MenuAction_End)
		{
			CloseHandle(menu);
		} 
	}
}

stock pumkin_random(client, select)
{
	if(!SetTeleportEndPoint(client))
	{
		PrintToChat(client, "[SM] Could not find spawn point.");
		return;
	}
	
	new iPumpkin = CreateEntityByName("tf_pumpkin_bomb");
	
	if(IsValidEntity(iPumpkin))
	{		
		DispatchSpawn(iPumpkin);
		g_pos[2] -= 10.0;
		SetEntProp(iPumpkin, Prop_Data, "m_takedamage", 0, 1);
		TeleportEntity(iPumpkin, g_pos, NULL_VECTOR, NULL_VECTOR);
		
		switch(select)
		{
			case 1: SDKHook(iPumpkin, SDKHook_StartTouch, OnTouch); 
			case 2: SDKHook(iPumpkin, SDKHook_StartTouch, OnExplode); 
		}
	}
}

public Action:OnTouch(ent) 
{      
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
			PrintToChat(i, "\x03성공!!");
	}
	
	new particle = CreateEntityByName("info_particle_system");

	decl String:name[64];

	if (IsValidEdict(particle))
	{
		new Float:position[3];
		GetEntPropVector(ent, Prop_Send, "m_vecOrigin", position);
		TeleportEntity(particle, position, NULL_VECTOR, NULL_VECTOR);
		GetEntPropString(ent, Prop_Data, "m_iName", name, sizeof(name));
		DispatchKeyValue(particle, "targetname", "tf2particle");
		DispatchKeyValue(particle, "parentname", name);
		DispatchKeyValue(particle, "effect_name", "spell_skeleton_bits_green");
		DispatchSpawn(particle);
		SetVariantString(name);
		AcceptEntityInput(particle, "SetParent", particle, particle, 0);
		ActivateEntity(particle);
		AcceptEntityInput(particle, "start");
		CreateTimer(2.0, DeleteParticle, particle);
	}
	
	if (IsValidEntity(ent))
	{
		new String:classname[256]
		GetEdictClassname(ent, classname, sizeof(classname))
		if (StrEqual(classname, "tf_pumpkin_bomb", false))
		{
			RemoveEdict(ent);
		}
	}
}

public Action:OnExplode(entity) 
{      
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
			PrintToChat(i, "\x03꽝!!");
	}
	SetEntProp(entity, Prop_Data, "m_takedamage", 2, 1);
	
	//폭발
	
	new explode = CreateEntityByName("env_explosion");
	
	if (IsValidEdict(explode))
	{
		decl Float:entitypos[3]; GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entitypos);
		DispatchKeyValue(explode, "iMagnitude", "2000")
		DispatchKeyValue(explode, "iRadiusOverride", "15")
		DispatchKeyValue(explode, "targetname", "rocket_explode");
		DispatchKeyValue(explode, "rendermode", "5");
		DispatchSpawn(explode);
		TeleportEntity(explode, entitypos, NULL_VECTOR, NULL_VECTOR);
		ActivateEntity(explode);
		AcceptEntityInput(explode, "Explode");
		AcceptEntityInput(explode, "Kill");
	}
}

public Action:DeleteParticle(Handle:timer, any:particle)
{
    if (IsValidEntity(particle))
    {
        new String:classN[64];
        GetEdictClassname(particle, classN, sizeof(classN));
        if (StrEqual(classN, "info_particle_system", false))
        {
            RemoveEdict(particle);
        }
    }
}

SetTeleportEndPoint(client)
{
	decl Float:vAngles[3];
	decl Float:vOrigin[3];
	decl Float:vBuffer[3];
	decl Float:vStart[3];
	decl Float:Distance;
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
    //get endpoint for teleport
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

	if(TR_DidHit(trace))
	{   	 
   	 	TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		Distance = -35.0;
   	 	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		g_pos[0] = vStart[0] + (vBuffer[0]*Distance);
		g_pos[1] = vStart[1] + (vBuffer[1]*Distance);
		g_pos[2] = vStart[2] + (vBuffer[2]*Distance);
	}
	else
	{
		CloseHandle(trace);
		return false;
	}
	
	CloseHandle(trace);
	return true;
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > GetMaxClients() || !entity;
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

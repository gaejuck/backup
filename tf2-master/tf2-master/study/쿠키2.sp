#include <sdktools>
#include <clientprefs> 

new Float:g_pos[MAXPLAYERS+1][3];
new bool:spawn[MAXPLAYERS+1] = false;

new Handle:Spawn_Cookie = INVALID_HANDLE;
new Handle:x_Cookie = INVALID_HANDLE;
new Handle:y_Cookie = INVALID_HANDLE;
new Handle:z_Cookie = INVALID_HANDLE;

public OnPluginStart()
{
	RegConsoleCmd("sm_setspawn", SetSpawn);
	RegConsoleCmd("sm_delspawn", DeleSpawn);
	HookEvent("player_spawn", PlayerSpawn);
	
	Spawn_Cookie = RegClientCookie("spawn check", "spawn check",CookieAccess_Protected);
	
	x_Cookie = RegClientCookie("x_Cookie", "x_Cookie",CookieAccess_Protected);
	y_Cookie = RegClientCookie("y_Cookie", "y_Cookie",CookieAccess_Protected);
	z_Cookie = RegClientCookie("z_Cookie", "z_Cookie",CookieAccess_Protected);
}

public OnClientDisconnected(client)
{
	spawn[client] = false;
	for(new i = 1; i <= 3; i++)
		g_pos[client][i] = 0.0;
}
	
public OnClientCookiesCached(client)
{
	decl String:sBuffer[16];

	GetClientCookie(client, Spawn_Cookie, sBuffer, sizeof(sBuffer));
	if(strlen(sBuffer) == 1 || StrEqual(sBuffer, "Yes"))
		spawn[client] = true;
	else
		spawn[client] = false;
		
	new String:xc[64];
	GetClientCookie(client, x_Cookie, xc, sizeof(xc));
	if(!StrEqual(xc, ""))
		g_pos[client][0] = StringToFloat(xc);
		
	new String:yc[64];
	GetClientCookie(client, y_Cookie, yc, sizeof(yc));
	if(!StrEqual(yc, ""))
		g_pos[client][1] = StringToFloat(yc);
		
	new String:zc[64];
	GetClientCookie(client, z_Cookie, zc, sizeof(zc));
	if(!StrEqual(zc, ""))
		g_pos[client][2] = StringToFloat(zc);
}

public Action:SetSpawn(client, args)
{
	if(args < 1)
	{
		ReplyToCommand(client, "[SM]\x03!setspawn <name>");
		return Plugin_Handled;
	}
	
	if(!SetTeleportEndPoint(client))
	{
		PrintToChat(client, "스폰 지점을 선택하세요.");
		return Plugin_Continue;
	}
	
	new String:strname[32];
	decl String:playerName[MAX_NAME_LENGTH];
	GetCmdArg(1, strname, sizeof(strname));
	
	GetClientName(client, playerName, sizeof(playerName));
	
	new String:x[32];
	new String:y[32];
	new String:z[32];

	if(StrEqual(playerName, strname, false))
	{
		FloatToString(g_pos[client][0], x, sizeof(x));
		FloatToString(g_pos[client][1], y, sizeof(y));
		FloatToString(g_pos[client][2], z, sizeof(z));
			
		SetClientCookie(client, x_Cookie, x);
		SetClientCookie(client, y_Cookie, y);
		SetClientCookie(client, z_Cookie, z);
			
		TeleportEntity(client, g_pos[client], NULL_VECTOR, NULL_VECTOR);
		SetClientCookie(client, Spawn_Cookie, "Yes");
		spawn[client] = true;
			// PrintToChat(target_list[i], "\x03X: %f\nY: %f\nZ: %f", g_pos[target_list[i]][0], g_pos[target_list[i]][1], g_pos[target_list[i]][2]);
	}
	return Plugin_Handled;
}

public Action:DeleSpawn(client, args)
{
	decl String:arg[65];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM]\x03!delspawn <name>");
		return Plugin_Handled;
	}
		
	GetCmdArg(1, arg, sizeof(arg));
		
	HasTarget = true;	
	
	decl String:target_name[MAX_TARGET_LENGTH];
	
	if (HasTarget)
	{
		decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
		
		if ((target_count = ProcessTargetString(
				arg,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_CONNECTED,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
		{
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}

		for (new i = 0; i < target_count; i++)
		{
			SetClientCookie(target_list[i], Spawn_Cookie, "No");
			spawn[target_list[i]] = false;
			// PrintToChat(target_list[i], "\x03X: %f\nY: %f\nZ: %f", g_pos[target_list[i]][0], g_pos[target_list[i]][1], g_pos[target_list[i]][2]);
		}
	}
	return Plugin_Handled;
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(spawn[client] == true)
	{
		TeleportEntity(client, g_pos[client], NULL_VECTOR, NULL_VECTOR);
		// PrintToChat(client, "\x03X: %f\nY: %f\nZ: %f", g_pos[client][0], g_pos[client][1], g_pos[client][2]);
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
		g_pos[client][0] = vStart[0] + (vBuffer[0]*Distance);
		g_pos[client][1] = vStart[1] + (vBuffer[1]*Distance);
		g_pos[client][2] = vStart[2] + (vBuffer[2]*Distance);
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
#include <sdktools>

new Float:g_pos[MAXPLAYERS+1][3];
new bool:spawn[MAXPLAYERS+1] = false;

public OnPluginStart()
{
	RegAdminCmd("sm_setspawn", SetSpawn, ADMFLAG_KICK);
	
	HookEvent("player_spawn", PlayerSpawn);
}

public OnClientDisconnected(client)
{
	if(spawn[client] == true)
	{
		spawn[client] = false;
		for(new i = 1; i <= 3; i++)
			g_pos[client][i] = 0.0;
	}
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(spawn[client] == true)
	{
		TeleportEntity(client, g_pos[client], NULL_VECTOR, NULL_VECTOR);
	}
}

public Action:SetSpawn(client, args)
{
	if(args < 4)
	{
		ReplyToCommand(client, "[SM]\x03!setspawn <name> <x y z>");
		return Plugin_Handled;
	}
	
	new String:strname[MAX_NAME_LENGTH], String:strx[32], String:stry[32], String:strz[32];
	new Float:x, Float:y, Float:z;
	
	GetCmdArg(1, strname, sizeof(strname));
	GetCmdArg(2, strx, sizeof(strx));
	GetCmdArg(3, stry, sizeof(stry));
	GetCmdArg(4, strz, sizeof(strz));
	
	x = StringToFloat(strx);
	y = StringToFloat(stry);
	z = StringToFloat(strz);
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(PlayerCheck(i))
		{
			decl String:playerName[MAX_NAME_LENGTH];
			GetClientName(i, playerName, sizeof(playerName));

			if(StrContains(playerName, strname, false) != -1)
			{
				g_pos[i][0] = x;
				g_pos[i][1] = y;
				g_pos[i][2] = z;
						
				spawn[i] = true;
			}
		}
	}
	return Plugin_Handled;
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

#pragma semicolon 1
#include <sourcemod>
#include <sdktools>

public Plugin:myinfo =
{
	name = "Player-Teleport by Dr. HyperKiLLeR",
	author = "Dr. HyperKiLLeR",
	description = "Go to a player or teleport a player to you",
	version = "1.2.0.1",
	url = ""
};
 
//Plugin-Start
public OnPluginStart()
{
	RegAdminCmd("sm_goto", Command_Goto, ADMFLAG_SLAY,"Go to a player");
	RegAdminCmd("sm_bring", Command_Bring, ADMFLAG_SLAY,"Teleport a player to you");

	CreateConVar("goto_version", "1.2", "Dr. HyperKiLLeRs Player Teleport",FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_UNLOGGED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_NOTIFY);
	
	LoadTranslations("common.phrases");
}

public Action:Command_Goto(Client,args)
{
    //Error:
	if(args < 1)
	{
		//Print:
		ReplyToCommand(Client, "Usage: sm_goto <name>");
		
		//Return:
		return Plugin_Handled;
	}
	
	new Player, String:target_name[MAX_NAME_LENGTH];
	
	GetCmdArg(1, target_name, sizeof(target_name));
	
	if ((Player = FindTarget(Client, target_name, false, true)) <= 0)
	{
		// Error, couldn't find name
		ReplyToCommand(Client, "Unable to find player matching [%s]", target_name);
		return Plugin_Handled;
	}
	
	//Declare:
	new Float:TeleportOrigin[3];
	new Float:PlayerOrigin[3];
	
	//Initialize
	GetClientAbsOrigin(Player, PlayerOrigin);
	
	//Math
	TeleportOrigin[0] = PlayerOrigin[0];
	TeleportOrigin[1] = PlayerOrigin[1];
	TeleportOrigin[2] = (PlayerOrigin[2] + 73);
	
	//Teleport
	TeleportEntity(Client, TeleportOrigin, NULL_VECTOR, NULL_VECTOR);
	
	return Plugin_Handled;
}

public Action:Command_Bring(client,args)
{
	decl String:arg[65];
	
	new Float:TeleportOrigin[3];
	new Float:PlayerOrigin[3];
	
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		ReplyToCommand(client, "Usage: sm_bring <name>");
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
		GetCollisionPoint(client, PlayerOrigin);
		
		TeleportOrigin[0] = PlayerOrigin[0];
		TeleportOrigin[1] = PlayerOrigin[1];
		TeleportOrigin[2] = (PlayerOrigin[2] + 4);
		
		for (new i = 0; i < target_count; i++)
		{	
			TeleportEntity(target_list[i], TeleportOrigin, NULL_VECTOR, NULL_VECTOR);
		}
	}
	return Plugin_Handled;
}

// Trace

GetCollisionPoint(client, Float:pos[3])
{
	new Float:vOrigin[3], Float:vAngles[3];
	
	GetClientEyePosition(client, vOrigin);
	GetClientEyeAngles(client, vAngles);
	
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SOLID, RayType_Infinite, TraceEntityFilterPlayer);
	
	if(TR_DidHit(trace))
	{
		TR_GetEndPosition(pos, trace);
		CloseHandle(trace);
		
		return;
	}
	
	CloseHandle(trace);
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > MaxClients;
}  


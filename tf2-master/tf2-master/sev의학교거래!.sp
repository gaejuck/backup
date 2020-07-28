#include <sdktools>

public Plugin:myinfo = 
{
	name = "유저 처벌용",
	author = "TAKE 2",
	description = "처처처처처ㅓ벌",
	version = "1.0",
	url = "http://steamcommunity.com/profiles/76561198103558528/"
} 

public OnMapStart()
{
	AddFileToDownloadsTable("materials/sev/warring.vmt");
	AddFileToDownloadsTable("materials/sev/warring.vtf");
	AddFileToDownloadsTable("materials/sev/ban.vmt");
	AddFileToDownloadsTable("materials/sev/ban.vtf");
	AddFileToDownloadsTable("materials/sev/event.vmt");
	AddFileToDownloadsTable("materials/sev/event.vtf");
	AddFileToDownloadsTable("materials/sev/event2.vmt");
	AddFileToDownloadsTable("materials/sev/event2.vtf");
	
	PrecacheDecal("sev/warring", true);
	PrecacheDecal("sev/ban", true);
	PrecacheDecal("sev/event", true);
	PrecacheDecal("sev/event2", true);
}

public OnPluginStart()
{
	RegAdminCmd("w", warring, ADMFLAG_KICK);
	RegAdminCmd("b", ban, ADMFLAG_KICK);
	RegAdminCmd("es", events, ADMFLAG_KICK);
	RegAdminCmd("ed", eventd, ADMFLAG_KICK);
}


public Action:warring(client, args) 
{
	decl String:arg[65];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM]\x03 !w <name>");
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
			SetOverlay(target_list[i], "sev/warring");
			CreateTimer(10.0, OVerTimer, target_list[i]);
		}
	}
	return Plugin_Handled;
}

public Action:ban(client, args)
{
	decl String:arg[65];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM]\x03 !b <name>");
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
			SetOverlay(target_list[i], "sev/ban");
			CreateTimer(10.0, OVerTimer, target_list[i]);
		}
	}
	return Plugin_Handled;
}

public Action:events(client, args)
{
	decl String:arg[65];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM]\x03 !es <name>");
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
			SetOverlay(target_list[i], "sev/event");
			CreateTimer(10.0, OVerTimer, target_list[i]);
		}
	}
	return Plugin_Handled;
}

public Action:eventd(client, args)
{
	decl String:arg[65];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM]\x03 !ed <name>");
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
			SetOverlay(target_list[i], "sev/event2");
			CreateTimer(10.0, OVerTimer, target_list[i]);
		}
	}
	return Plugin_Handled;
}

stock SetOverlay(client, const String:szOverlay[])
{
    SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & ~FCVAR_CHEAT);
    ClientCommand(client, "r_screenoverlay \"%s\"", szOverlay); 
    SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") | FCVAR_CHEAT);
}

public Action:OVerTimer(Handle:timer, any:client)
	SetOverlay(client, "");
	

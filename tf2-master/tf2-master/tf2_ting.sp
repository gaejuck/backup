#include <sourcemod>
#include <sdktools>

public OnPluginStart()
{
	LoadTranslations("common.phrases");
	RegAdminCmd("sm_tt", Command_name, ADMFLAG_KICK);
}

public Action:Command_name(client, args)
{
	decl String:arg[65];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM]\x03!tt <name>");
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
			new Handle:hBuffer = StartMessageOne("GameTitle", target_list[i]);
			if (hBuffer == INVALID_HANDLE)
				PrintToChat(target_list[i], "INVALID_HANDLE");
			else
			{
				EndMessage();
			}
		}
	}
	return Plugin_Handled;
}

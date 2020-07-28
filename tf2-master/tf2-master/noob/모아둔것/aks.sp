#include <tf2attributes>
#include <tf2_stocks>

public OnPluginStart()
{
	RegConsoleCmd("sm_ks", Command_ks, "asd.");
	RegConsoleCmd("sm_kn", Command_kn, "asd.");
}

public Action:Command_ks(client, args)
{
	decl String:arg[65];
	decl String:arg2[20];
	decl String:arg3[20];
	decl String:arg4[20];
	new Float:amount;
	new Float:amount2;
	new Float:amount3;
	new bool:HasTarget = false;
	
	if(args < 4)
	{
		PrintToChat(client, "\x01사용법 : !ks 이름 < 1 > < 1 ~ 7 > < 2001 ~ 2008 >");
		return Plugin_Handled;
	}
		
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	GetCmdArg(3, arg3, sizeof(arg3));
	GetCmdArg(4, arg4, sizeof(arg4));
	amount = StringToFloat(arg2);
	amount2 = StringToFloat(arg3);
	amount3 = StringToFloat(arg4);

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
			TF2Attrib_SetByDefIndex(target_list[i], 2025, amount);
			TF2Attrib_SetByDefIndex(target_list[i], 2014, amount2);
			TF2Attrib_SetByDefIndex(target_list[i], 2013, amount3);
		}
	}
	return Plugin_Handled;
}

public Action:Command_kn(client, args)
{
	decl String:arg[65];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		PrintToChat(client, "\x01사용법 : !kn 이름");
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
			TF2Attrib_SetByDefIndex(target_list[i], 2025, 0.0);
			TF2Attrib_SetByDefIndex(target_list[i], 2014, 0.0);
			TF2Attrib_SetByDefIndex(target_list[i], 2013, 0.0);
		}
	}
	return Plugin_Handled;
}
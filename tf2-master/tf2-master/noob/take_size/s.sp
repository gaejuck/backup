public Action:s(client, args)
{
	new TFClassType:class = TF2_GetPlayerClass(client);
	
	if (class == TFClass_Sniper)
	{
		ReplyToCommand(client, "\x04%t", "Resize Sniper");
	}
	else
	{
		if(args != 1) 
		{
			ReplyToCommand(client, "\x07%s!s %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarSMin), GetConVarFloat(CvarSMax));
			return Plugin_Handled;
		}

		new String:strtorso[32], Float:torso;

		GetCmdArg(1, strtorso, sizeof(strtorso));
		torso = StringToFloat(strtorso);
		
		if(torso < GetConVarFloat(CvarSMin) || torso > GetConVarFloat(CvarSMax))
		{
			ReplyToCommand(client, "\x07%s!s %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarSMin), GetConVarFloat(CvarSMax));
			return Plugin_Handled;
		}
		
		SetEntPropFloat(client, Prop_Send, "m_flModelScale", torso); 
		SetEntPropFloat(client, Prop_Send, "m_flStepSize", 18.0 * torso);
		ReplyToCommand(client, "\x04%.1f 적용 완료", torso);
	}
	
	return Plugin_Handled;
}

public Action:sm_as(client, args)
{
	decl String:arg[65], String:ass[32], Float:asss;
	new bool:HasTarget = false;
	
	if(args < 2)
	{
		ReplyToCommand(client, "\x04!as <name> %.1f ~ %.1f", GetConVarFloat(CvaraSMin), GetConVarFloat(CvaraSMax));
		return Plugin_Handled;
	}
		
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, ass, sizeof(ass));
	asss = StringToFloat(ass);
	
	if(asss < GetConVarFloat(CvaraSMin) || asss > GetConVarFloat(CvaraSMax))
	{
		ReplyToCommand(client, "\x04!s <name> %.1f ~ %.1f", GetConVarFloat(CvarSMin), GetConVarFloat(CvarSMax));
		return Plugin_Handled;
	} 
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
			SetEntPropFloat(target_list[i], Prop_Send, "m_flModelScale", asss); 
			SetEntPropFloat(target_list[i], Prop_Send, "m_flStepSize", 18.0 * asss);
			ReplyToCommand(client, "\x04%.1f 적용 완료", asss);
		}
	}
	return Plugin_Handled;
}
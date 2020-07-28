public Action:body_size(client, args)
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
			ReplyToCommand(client, "\x07%s!bs %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarBSMin), GetConVarFloat(CvarBSMax));
			return Plugin_Handled;
		}

		new String:strtorso[32], Float:torso;

		GetCmdArg(1, strtorso, sizeof(strtorso));
		torso = StringToFloat(strtorso);
		
		if(torso < GetConVarFloat(CvarBSMin) || torso > GetConVarFloat(CvarBSMax))
		{
			ReplyToCommand(client, "\x07%s!bs %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarBSMin), GetConVarFloat(CvarBSMax));
			return Plugin_Handled;
		}
		
		TF2Attrib_SetByDefIndex(client, 620, torso);
		ReplyToCommand(client, "\x04%.1f 적용 완료", torso);
	}
	
	return Plugin_Handled;
}

public Action:body_size2(client, args)
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
			ReplyToCommand(client, "\x07%s!bs2 %.1f ~ %.1f",g_PrintColor, GetConVarFloat(CvarBSMin), GetConVarFloat(CvarBSMax));
			return Plugin_Handled;
		}

		new String:strtorso[32], Float:torso;

		GetCmdArg(1, strtorso, sizeof(strtorso));
		torso = StringToFloat(strtorso);
		
		if(torso < GetConVarFloat(CvarBSMin) || torso > GetConVarFloat(CvarBSMax))
		{
			ReplyToCommand(client, "\x07%s!bs %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarBSMin), GetConVarFloat(CvarBSMax));
			return Plugin_Handled;
		}
		
		TF2Attrib_SetByDefIndex(client, 620, -torso);
		ReplyToCommand(client, "\x04%.1f 적용 완료", torso);
	}
	
	return Plugin_Handled;
}
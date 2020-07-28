public Action:head_size(client, args)
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
			ReplyToCommand(client, "\x07%s!hd %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarhSMin), GetConVarFloat(CvarhSMax));
			return Plugin_Handled;
		}

		new String:strhand[32], Float:hand;

		GetCmdArg(1, strhand, sizeof(strhand));
		hand = StringToFloat(strhand);
		
		if(hand < GetConVarFloat(CvarhSMin) || hand > GetConVarFloat(CvarhSMax))
		{
			ReplyToCommand(client, "\x07%s!hd %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarhSMin), GetConVarFloat(CvarhSMax));
			return Plugin_Handled;
		} 
		
		TF2Attrib_SetByDefIndex(client, 444, hand);
		ReplyToCommand(client, "\x04%.1f 적용 완료", hand);
	}
	
	return Plugin_Handled;
}

public Action:head_size2(client, args)
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
			ReplyToCommand(client, "\x07%s!hd2 %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarhSMin), GetConVarFloat(CvarhSMax));
			return Plugin_Handled;
		}

		new String:strhand[32], Float:hand;

		GetCmdArg(1, strhand, sizeof(strhand));
		hand = StringToFloat(strhand);
		
		if(hand < GetConVarFloat(CvarhSMin) || hand > GetConVarFloat(CvarhSMax))
		{
			ReplyToCommand(client, "\x07%s!hd %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarhSMin), GetConVarFloat(CvarhSMax));
			return Plugin_Handled;
		} 
		
		TF2Attrib_SetByDefIndex(client, 444, -hand);
		ReplyToCommand(client, "\x04%.1f 적용 완료", hand);
	}
	
	return Plugin_Handled;
}
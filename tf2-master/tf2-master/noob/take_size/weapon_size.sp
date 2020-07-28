public Action:weapon_size(client, args)
{
	if(args != 1)
	{
		ReplyToCommand(client, "\x07%s!ws %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarwSMin), GetConVarFloat(CvarwSMax));
		return Plugin_Handled;
	}

	new String:strhand[32], Float:hand;

	GetCmdArg(1, strhand, sizeof(strhand));
	hand = StringToFloat(strhand);
	
	if(hand < GetConVarFloat(CvarwSMin) || hand > GetConVarFloat(CvarwSMax))
	{
		ReplyToCommand(client, "\x07%s!ws %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarwSMin), GetConVarFloat(CvarwSMax));
		return Plugin_Handled;
	} 
	
	TF2Attrib_SetByDefIndex(client, 699, hand);
	ReplyToCommand(client, "\x04%.1f 적용 완료", hand);
	return Plugin_Handled;
}

public Action:weapon_size2(client, args)
{
	if(args != 1)
	{
		ReplyToCommand(client, "\x07%s!ws2 %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarwSMin), GetConVarFloat(CvarwSMax));
		return Plugin_Handled;
	}

	new String:strhand[32], Float:hand;

	GetCmdArg(1, strhand, sizeof(strhand));
	hand = StringToFloat(strhand);
	
	if(hand < GetConVarFloat(CvarwSMin) || hand > GetConVarFloat(CvarwSMax))
	{
		ReplyToCommand(client, "\x07%s!ws %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarwSMin), GetConVarFloat(CvarwSMax));
		return Plugin_Handled;
	} 
	
	TF2Attrib_SetByDefIndex(client, 699, -hand);
	ReplyToCommand(client, "\x04%.1f 적용 완료", hand);
	return Plugin_Handled;
}
public Action:voice_speed(client, args)
{
	if(args != 1)
	{
		ReplyToCommand(client, "\x07%s!vs %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarvSMin), GetConVarFloat(CvarvSMax));
		return Plugin_Handled;
	}

	new String:strtorso[32], Float:torso;

	GetCmdArg(1, strtorso, sizeof(strtorso));
	torso = StringToFloat(strtorso);
	
	if(torso < GetConVarFloat(CvarvSMin) || torso > GetConVarFloat(CvarvSMax))
	{
		ReplyToCommand(client, "\x07%s!vs %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvarvSMin), GetConVarFloat(CvarvSMax));
		return Plugin_Handled;
	}
	
	TF2Attrib_SetByDefIndex(client, 2048, torso);
	ReplyToCommand(client, "\x04%.1f 적용 완료", torso);
	
	return Plugin_Handled;
}
public Action:Command_SetTS(client, args)
{
	if(args != 1) 
	{
		ReplyToCommand(client, "\x07%s!ts %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvartSMin), GetConVarFloat(CvartSMax));
		return Plugin_Handled;
	}

	new String:strtorso[32], Float:torso;

	GetCmdArg(1, strtorso, sizeof(strtorso));
	torso = StringToFloat(strtorso);
		
	if(torso < GetConVarFloat(CvartSMin) || torso > GetConVarFloat(CvartSMax))
	{
		ReplyToCommand(client, "\x07%s!ts %.1f ~ %.1f", g_PrintColor, GetConVarFloat(CvartSMin), GetConVarFloat(CvartSMax));
		return Plugin_Handled;
	}
	
	TF2Attrib_SetByDefIndex(client, 201, torso);
	ReplyToCommand(client, "\x04%.1f 적용 완료", torso);
	
	return Plugin_Handled;
}
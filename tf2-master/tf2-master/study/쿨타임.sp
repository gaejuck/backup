public Delay(client)
{
	g_delay[client] = 60;
	CreateTimer(1.0, Timer_Delay, client, TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer_Delay(Handle:timer, any:client)
{
	g_delay[client]--;
	if (g_delay[client])
		CreateTimer(1.0, Timer_Delay, client, TIMER_FLAG_NO_MAPCHANGE);

	return Plugin_Handled;
}


new Float:SkillJumpTime[MAXPLAYERS+1];

		if(CheckSkillJumpCoolTime(client, 3.0) && GetEntityFlags(client) & FL_ONGROUND)
		{
			if(GetClientButtons(client) & IN_ATTACK2)
			{
				Jump_Skill(client);
				SkillJumpTime[client] = GetEngineTime();

			}
		}

stock bool:CheckSkillJumpCoolTime(any:iClient, Float:fTime)
{
	if(!AliveCheck(iClient)) return false;
	if(GetEngineTime() - SkillJumpTime[iClient] >= fTime) return true;
	else return false;
}


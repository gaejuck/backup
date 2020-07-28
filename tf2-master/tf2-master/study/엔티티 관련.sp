if(GetEntProp(entity, Prop_Data, "m_iTeaNum") == 3) // entity의 팀 넘버가 3 이라면

if(GetClientTeam(entity) == 2) // entity의 팀 넘버가 2 라면
{
　SetEntProp(entity, Prop_Data, "m_iTeamNum", 3); //entity의 팀 넘버를 3으로 변경
}


	new Float:Position[3]; 
	new Float:vAng[3];
	GetClientEyePosition(client,Position);
	Position[2] += 30.0;
	GetClientEyeAngles(client, vAng);
	FireTeamRocket(Position, vAng, client, 2, 1000.0);
	텔포~써도대고
	
	
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", Position);
	
	Position[2] += 30.0;
	
	GetClientEyeAngles(client, vAng);
	FireTeamRocket(Position, vAng, client, 2, 1000.0);
	return Plugin_Handled;
	아니면 이렇게
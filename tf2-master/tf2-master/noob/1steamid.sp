new String:vipsteamid[2][60] = {
	
	{"STEAM_0:0:64434731"},//sky
	{"STEAM_0:0:41459101"}//me
};

public OnClientPutInServer(client)
{
	new String:clientsteamid[32];
	
	GetClientAuthString(client, clientsteamid, 32);
	
	for(new i = 0; i < 2; i++)
	{	
		if(StrEqual(clientsteamid, vipsteamid[i], false))
		{	
			PrintToChat(i, "\x08 ㅎㅇ");	
		}
		
	}
	
}
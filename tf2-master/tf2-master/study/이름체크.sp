public OnClientPostAdminCheck(client)
{
	decl String:playerName[MAX_NAME_LENGTH];
	GetClientName(client, playerName, sizeof(playerName));
	
	nameCheck(playerName, client);
}

nameCheck(String:clientName[], player)
{
	if(StrEqual(clientName, "11", false))
	{
		spawn[player] = true;
	}
}


이 도발지역구역에 들어왔습니다.
봇님이 도발지역구역에 나갔습니다.
봇님이 테스트 지역구역에 들어왔습니다.
봇 :  !pos
X: -2418.310546
Y: 1699.207885
Z: -2052.868652


sm_setspawn "the" "-2603.531250" "804.858581" "-1925.968750"



 다시 해볼게요
(음성) Randommagic: 그래
봇 :  !pos
X: -2603.531250
Y: 804.858581
Z: -1925.968750
#if defined _dbvip_included
  #endinput
#endif
#define _dbvip_included

public SharedPlugin __pl_dbvip = {
  name = "db_vip",
  file = "db_vip.smx",
#if defined REQUIRE_PLUGIN
  required = 1
#else
  required = 0
#endif
};

// new vip[MAXPLAYERS+1];

// stock bool:IsClientVip(client) 
// {
	// if(vip[client] == 1)
	// {
		// return true;
	// }
	// return false;
// }


//vip인지 아닌지 체크합니다.
native IsClientVip(client);

//vip를 추가합니다.
native IsClientAddVip(client);

//vip를 추가합니다.
native IsClientAddVip2(client, String:name[], String:SteamID[]);

//vip를 제거합니다.
native IsClientRemoveVip(client);
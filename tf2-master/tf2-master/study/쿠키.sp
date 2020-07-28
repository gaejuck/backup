#include <clientprefs> 
#include <sdktools> 

new bool:cc[MAXPLAYERS+1] = false;
new Handle:g_Cookie = INVALID_HANDLE;

public OnPluginStart()
{
	RegConsoleCmd("sm_tt", bbbbb);
	
	g_Cookie = RegClientCookie("asdsd", "spawn tp",CookieAccess_Protected);
}

public OnClientCookiesCached(client)
{
    decl String:sBuffer[16];

    GetClientCookie(client, g_Cookie, sBuffer, sizeof(sBuffer));
    if(strlen(sBuffer) == 1 || StrEqual(sBuffer, "Yes"))
        cc[client] = true;
    else
        cc[client] = false;
    
    // Set default value
    // if(strlen(sBuffer) == 1)
        // SetClientCookie(client, g_Cookie, "Yes");
}


public Action:aa(client, args)
{
	SetClientCookie(client, g_Cookie, "Yes");
	cc[client] = true;
	return Plugin_Handled;
}

public Action:bb(client, args)
{
	SetClientCookie(client, g_Cookie, "No");
	cc[client] = false;
	return Plugin_Handled;
}



			SetClientCookie(target_list[i], x_Cookie, "");
			SetClientCookie(target_list[i], y_Cookie, "");
			SetClientCookie(target_list[i], z_Cookie, "");
			
			SetClientCookie(target_list[i], Spawn_Cookie, "");

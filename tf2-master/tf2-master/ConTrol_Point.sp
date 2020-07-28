#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = {
	name		= "점령지 막는 플러그인",
	author	  = "ㅣ",
	description = "점령 막는 플긴",
	version	 = "1.0",
	url		 = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
};



new Handle:CP;

public OnPluginStart()
{
	CP = CreateConVar("sm_controlpoint_enabled", "1", "켜기 끄기 1/0");
}


public OnGameFrame()
{
    new i = -1;
    new CP2 = 0;

    for (new n = 0; n <= 16; n++)
    {
        CP2 = FindEntityByClassname(i, "trigger_capture_area");
        if (IsValidEntity(CP2))
        {
            if(GetConVarInt(CP) == 1)
            {
                AcceptEntityInput(CP2, "Disable");
            }else{
                AcceptEntityInput(CP2, "Enable");
            }
            i = CP2;
        }
        else
            break;
    }
}

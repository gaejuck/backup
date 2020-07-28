#include <sourcemod>

new Handle:hudText;

public OnPluginStart()
{
	RegServerCmd("tf_dodgeball_deflections", SpeedAnnounce)
	hudText = CreateHudSynchronizer();
}

public Action:SpeedAnnounce(iArgs)
{
	if(iArgs != 1)
	{
		PrintToServer("Usage: tf_dodgeball_deflections @deflections")
		return Plugin_Handled;
	}
	new String:strBuffer[32];
	GetCmdArg(1, strBuffer, sizeof(strBuffer)); new itarget = StringToInt(strBuffer, 10);
	
	itarget ++;
	itarget --;
	
	SetHudTextParams(0.05, 0.2, 5.0, 240, 74, 255, 0, 0, 6.0, 0.1, 0.2);
	
	for(new i = 1; i <= MaxClients; i++)
		if(PlayerCheck(i))
			ShowSyncHudText(i, hudText, "반사 횟수 : %d", itarget, i);
	
	return Plugin_Handled;
}

stock bool:PlayerCheck(Client){
	if(Client > 0 && Client <= MaxClients){
		if(IsClientConnected(Client) == true){
			if(IsClientInGame(Client) == true){
				return true;
			}
		}
	}
	return false;
}
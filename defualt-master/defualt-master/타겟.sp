#include <sourcemod>

public Plugin:myinfo = {
	name		= "닷지볼 타겟 표시",
	author	  = "ㅣ",
	description = "왼쪽 상단에 허드에 타겟의 닉네임을 표시합니다.",
	version	 = "2.0",
	url		 = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
};

new Handle:hudText;

public OnPluginStart()
{
	LoadTranslations("dodgeball_target.phrases");
	RegServerCmd("tf_dodgeball_target", DT)
	hudText = CreateHudSynchronizer();
}

public Action:DT(iArgs)
{
	if(iArgs != 1)
	{
		PrintToServer("Usage: tf_dodgeball_target @target")
		return Plugin_Handled;
	}
	new String:strBuffer[32];
	GetCmdArg(1, strBuffer, sizeof(strBuffer)); new itarget = StringToInt(strBuffer, 10);
	
	target_name(itarget);
	
	return Plugin_Handled;
}

public Action:target_name(itarget)
{
	new String:tN[MAX_NAME_LENGTH];
	GetClientName(itarget, tN, sizeof(tN));
	
	SetHudTextParams(0.05, 0.15, 1.09, 0, 255, 234, 255, 0, 6.0, 0.1, 0.2);
	
	for(new i = 1; i <= MaxClients; i++)
		if(PlayerCheck(i))
			ShowSyncHudText(i, hudText, "%T: %s", "target", i, tN);
		
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

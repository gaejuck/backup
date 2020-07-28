#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = {
	name		= "닷지볼 타겟 표시 & 플레이어 외곽선",
	author	  = "TAKE 2",
	description = "왼쪽 상단에 허드에 타겟의 닉네임을 표시합니다.",
	version	 = "3.0",
	url		 = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
};

new Handle:hudText;

new g_iPlayerGlowEntity[MAXPLAYERS + 1];

public OnPluginStart()
{
	LoadTranslations("dodgeball_target.phrases");
	RegServerCmd("tf_dodgeball_target", DT)
	hudText = CreateHudSynchronizer();
}

public OnPluginEnd()
{
	new index = -1;
	while ((index = FindEntityByClassname(index, "tf_glow")) != -1)
	{
		char strName[64];
		GetEntPropString(index, Prop_Data, "m_iName", strName, sizeof(strName));
		if(StrEqual(strName, "RainbowGlow"))
		{
			AcceptEntityInput(index, "Kill");
		}
	}
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

public Action:target_name(iTarget)
{
	new String:tN[MAX_NAME_LENGTH];
	GetClientName(iTarget, tN, sizeof(tN));
	
	SetHudTextParams(0.05, 0.15, 5.0, 0, 255, 234, 255, 0, 6.0, 0.1, 0.2);
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(PlayerCheck(i))
		{
			ShowSyncHudText(i, hudText, "%T: %s", "target", i, tN);
			if(!TF2_HasGlow(iTarget))
			{
				new iGlow = TF2_CreateGlow(iTarget);
				if(IsValidEntity(iGlow))
				{
					g_iPlayerGlowEntity[iTarget] = EntIndexToEntRef(iGlow);
				}
			}
			if(((GetClientTeam(iTarget) == 2 && GetClientTeam(i) == 3) || (GetClientTeam(iTarget) == 3 && GetClientTeam(i) == 2)) && i != iTarget)
			{
				// SetEntProp(iTarget, Prop_Send, "m_bGlowEnabled", 1);
				// SetEntProp(i, Prop_Send, "m_bGlowEnabled", 0);
				
				if(TF2_HasGlow(i))
				{
					new iGlow = g_iPlayerGlowEntity[i];
					if(iGlow != INVALID_ENT_REFERENCE)
					{
						AcceptEntityInput(iGlow, "Kill");
						g_iPlayerGlowEntity[i] = INVALID_ENT_REFERENCE;
					}
				}
			}
		}
	}
		
	return Plugin_Handled;
}

stock TF2_CreateGlow(iEnt)
{
	new String:strName[126], String:strClass[64];
	GetEntityClassname(iEnt, strClass, sizeof(strClass));
	Format(strName, sizeof(strName), "%s%i", strClass, iEnt);
	DispatchKeyValue(iEnt, "targetname", strName);
	
	new String:strGlowColor[18];
	// Format(strGlowColor, sizeof(strGlowColor), "%i %i %i %i", GetRandomInt(0, 255), GetRandomInt(0, 255), GetRandomInt(0, 255), 255);
	
	
	switch(GetRandomInt(1,8))
	{
		case 1: Format(strGlowColor, sizeof(strGlowColor), "255 255 0 255"); 	//노란색
		case 2: Format(strGlowColor, sizeof(strGlowColor), "0 255 17 255");		 //초록색
		case 3: Format(strGlowColor, sizeof(strGlowColor), "255 174 0 255"); 	//주황색
		case 4: Format(strGlowColor, sizeof(strGlowColor), "0 255 200 255"); 	//라임색?
		case 5: Format(strGlowColor, sizeof(strGlowColor), "255 255 255 255"); 	//흰색
		case 6: Format(strGlowColor, sizeof(strGlowColor), "122 255 253 255"); 	//하늘색
		case 7: Format(strGlowColor, sizeof(strGlowColor), "212 255 0 255"); 	//진노란색
		case 8: Format(strGlowColor, sizeof(strGlowColor), "255 218 115 255"); 	//연주황색
	}
	
	new ent = CreateEntityByName("tf_glow");
	DispatchKeyValue(ent, "targetname", "RainbowGlow");
	DispatchKeyValue(ent, "target", strName);
	DispatchKeyValue(ent, "Mode", "0");
	DispatchKeyValue(ent, "GlowColor", strGlowColor);
	DispatchSpawn(ent);
	
	AcceptEntityInput(ent, "Enable");
	
	return ent;
}

stock bool:TF2_HasGlow(iEnt)
{
	new index = -1;
	while ((index = FindEntityByClassname(index, "tf_glow")) != -1)
	{
		if (GetEntPropEnt(index, Prop_Send, "m_hTarget") == iEnt)
		{
			return true;
		}
	}
	
	return false;
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
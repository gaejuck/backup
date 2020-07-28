#include <tf2items>
#include <sdktools>

enum Wearable 
{
	bool:m_bValid,
	m_iItemIndex,
	m_iQuality,
	m_iLevel,
	m_iEntity
}

new PlayerWearables[MAXPLAYERS+1][32][Wearable];

new Handle:g_hSdkEquipWearable = INVALID_HANDLE;

public OnPluginStart() 
{
	new Handle:hGameConf = LoadGameConfigFile("tf2items.randomizer");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
	g_hSdkEquipWearable = EndPrepSDKCall();
	if (g_hSdkEquipWearable == INVALID_HANDLE) SetFailState("Ohoh! Something went horribly wrong here!");
	
	RegConsoleCmd("sm_look", cmdEquipWearable, "Equip a Wearable");
	RegConsoleCmd("sm_lookre", cmdRemoveWearable, "Equip a Wearable");
	
}

public Action:cmdEquipWearable(iClient, nArgs) 
{
	if(iClient<1||!IsClientInGame(iClient)||!IsPlayerAlive(iClient))
	{
		return Plugin_Handled;
	}
	
	look(iClient);
	return Plugin_Handled;
}

public Action:cmdRemoveWearable(iClient, nArgs) 
{
	if (nArgs < 1) return Plugin_Handled;
	new String:szBuffer[64];
	GetCmdArg(1, szBuffer, sizeof(szBuffer));
	new iSlot = StringToInt(szBuffer);
	if (PlayerWearables[iClient][iSlot][m_bValid] == true) 
	{
		PlayerWearables[iClient][iSlot][m_bValid] = false;
		new iEntity = PlayerWearables[iClient][iSlot][m_iEntity];
		if (IsValidEntity(iEntity)) AcceptEntityInput(iEntity, "Kill");
	}
	
	return Plugin_Handled;
}

public Action:look(client)
{
	new Handle:info = CreateMenu(look_select);
	SetMenuTitle(info, "룩");
	AddMenuItem(info, "334*7*69", "문어모");  
	AddMenuItem(info, "481*7*69", "신발");  
	AddMenuItem(info, "451*7*69", "봉크소년");  
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
} 

public look_select(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:info[64], String:aa[3][64];
		GetMenuItem(menu, select, info, sizeof(info));
		ExplodeString(info, "*", aa,3,64);
		
		PlayerGiveWearable(client, StringToInt(aa[0]), StringToInt(aa[1]), StringToInt(aa[2]), -1);

	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

stock PlayerGiveWearable(iClient, iItemIndex, iQuality, iLevel, iSlot=-1)
{
	if (iSlot == -1) 
	{
		iSlot = GetWearableAvailableSlot(iClient);
		if (iSlot == -1) return -1;
	}
	
	new iEntity = TF2_PlayerGiveWearable(iClient, iItemIndex, iQuality, iLevel);
	MakeWearablePersistent(iClient, iItemIndex, iQuality, iLevel, iEntity, iSlot);
	
	return 0;
}

stock MakeWearablePersistent(iClient, iItemIndex, iQuality, iLevel, iEntity, iSlot=-1) 
{
	PlayerWearables[iClient][iSlot][m_bValid] = true;
	PlayerWearables[iClient][iSlot][m_iItemIndex] = iItemIndex;
	PlayerWearables[iClient][iSlot][m_iQuality] = iQuality;
	PlayerWearables[iClient][iSlot][m_iLevel] = iLevel;
	PlayerWearables[iClient][iSlot][m_iEntity] = iEntity;

	return iSlot;
}


stock GetWearableAvailableSlot(iClient) 
{
	new iSlot = -1;
	do 
	{
		iSlot++;
	} 
	while (PlayerWearables[iClient][iSlot][m_bValid] == true && iSlot < 32-1);

	if (PlayerWearables[iClient][iSlot][m_bValid] == true) return -1; else return iSlot;
}


stock TF2_PlayerGiveWearable(iClient, iItemIndex, iQuality=9, iLevel=0) 
{
	new Handle:hItem = TF2Items_CreateItem(OVERRIDE_ALL | FORCE_GENERATION);
	TF2Items_SetClassname(hItem, "tf_wearable");
	TF2Items_SetItemIndex(hItem, 0);
	TF2Items_SetQuality(hItem, iQuality);
	TF2Items_SetLevel(hItem, iLevel);
	TF2Items_SetNumAttributes(hItem, 0);

	new iEntity = TF2Items_GiveNamedItem(iClient, hItem);
	SetEntProp(iEntity, Prop_Send, "m_iItemDefinitionIndex", iItemIndex);
	for (new i=1; i<MaxClients;i++) 
	{
		if (IsClientConnected(i)) 
		{
			TF2_EquipWearable(i, iEntity);
		}
	}
	TF2_EquipWearable(iClient, iEntity);
	CloseHandle(hItem);
	return iEntity;
}

stock TF2_EquipWearable(client, entity) 
{
	if (g_hSdkEquipWearable != INVALID_HANDLE)
		SDKCall(g_hSdkEquipWearable, client, entity);
}


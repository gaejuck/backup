#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>

Handle g_hSDKPlaySpecificSequence;


public void OnPluginStart() {
	AddTempEntHook("PlayerAnimEvent", PlayerAnimEvent);
	AddTempEntHook("PlayerAnimEvent", OnPlayerAnimEvent);
	RegConsoleCmd("sm_car", aaaa);
	RegConsoleCmd("dd", Command_TestPlayerAnimEvent);
	RegConsoleCmd("cc", ccc);
	
	Handle hConfig = LoadGameConfigFile("sf2");
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(hConfig, SDKConf_Signature, "CTFPlayer::PlaySpecificSequence");
	PrepSDKCall_AddParameter(SDKType_String, SDKPass_Pointer);
	g_hSDKPlaySpecificSequence = EndPrepSDKCall();
	if(g_hSDKPlaySpecificSequence == INVALID_HANDLE)
	{
		PrintToServer("Failed to retrieve CTFPlayer::PlaySpecificSequence signature from SF2 gamedata!");
		//Don't have to call SetFailState, since this function is used in a minor part of the code.
	}
	delete hConfig;
}

public Action:ccc(client, args)
{
	decl String:arg1[64];
    
	GetCmdArg(1, arg1, sizeof(arg1));

	SDK_PlaySpecificSequence(client, arg1);
	PrintToChat(client, "\x03%s", arg1);
	
	decl Float:vPosition[3], Float:vAngles[3];
	GetClientEyePosition(client, vPosition);
	GetClientEyeAngles(client, vAngles);

	TE_SetupMuzzleFlash(vPosition, vAngles, 10.0,1);
    
	TE_SendToAll();
}  

public Action:Command_TestPlayerAnimEvent(client, args)
{
    decl String:arg1[64], String:arg2[64], String:arg3[64];
    GetCmdArg(1, arg1, sizeof(arg1));
    GetCmdArg(2, arg2, sizeof(arg2)); 
    GetCmdArg(3, arg3, sizeof(arg3));
    
    TE_Start("PlayerAnimEvent");
    
    TE_WriteNum("m_iPlayerIndex", StringToInt(arg1));
    TE_WriteNum("m_iEvent", StringToInt(arg2));
    TE_WriteNum("m_nData", StringToInt(arg3));
    
    TE_SendToAll();
}  

#define tttt 5.0

public Action:aaaa(client, args)
{
	new Handle:info = CreateMenu(Menu_Information);
	SetMenuTitle(info, "애니메이션");
	AddMenuItem(info, "taunt_aerobic_B", "에어로빅");  
	AddMenuItem(info, "taunt_aerobic_A", "에어로빅2");  
	AddMenuItem(info, "taunt_buy_a_life", "돈 뿌리기");   
	AddMenuItem(info, "a_jumpfloat_MELEE", "날다");   
	AddMenuItem(info, "swim_ITEM1", "수영");   
	AddMenuItem(info, "primary_death_backstab", "백스텝 당함");   
	AddMenuItem(info, "taunt_zoomin_broom", "빗자루");   
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
	
	AnimateClientCar(client, true);
	CreateTimer(tttt, exi2, client);
	return Plugin_Handled;
}

public Menu_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:info[64];
		GetMenuItem(menu, select, info, sizeof(info));
		SDK_PlaySpecificSequence(client, info);
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:exi2(Handle:timer, any:client) AnimateClientCar(client, false);

stock AnimateClientCar(iClient, bool bExit)
{
	static iEnterSequences[] = {-1, 329, 294, 378, 290, 229, 280, 286, 293, 370};
	static iExitSequences[] = {-1, 334, 299, 383, 295, 234, 285, 291, 298, 375};
	new TFClassType:class = TF2_GetPlayerClass(iClient);
	if (bExit)
	{
		TF2_AddCondition(iClient, TFCond_HalloweenKart, tttt);
	}
	TF2_AddCondition(iClient, TFCond_HalloweenKartNoTurn, 1.0);
	TE_Start("PlayerAnimEvent");
	TE_WriteNum("m_iPlayerIndex", iClient);
	TE_WriteNum("m_iEvent", 21);
	TE_WriteNum("m_nData", bExit ? iEnterSequences[class] : iExitSequences[class]);
	TE_SendToAll();
}

public Action PlayerAnimEvent(const char[] te_name, const int[] clients, int numClients, float delay) {
	int client = TE_ReadNum("m_iPlayerIndex");
	if (client <= 0 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client)) {
		return Plugin_Continue;
	}

	//if this event already has the sending client in the list of recipients, do nothing
	int clResult[MAXPLAYERS+1];
	for (int i = 0; i < numClients; i++) {
		if (clients[i] == client) {
			return Plugin_Continue;
		}
		//copy the original list to the new recipient list
		clResult[i] = clients[i];
	}

	//if the event wasn't event 0 + data 0, do nothing
	int event = TE_ReadNum("m_iEvent");
	int data = TE_ReadNum("m_nData");
	if (event != 0 || data != 0) {
		return Plugin_Continue;
	}

	//if not a pda, do nothing
	char weapon[64];
	GetClientWeapon(client, weapon, sizeof(weapon));
	if (strncmp(weapon, "tf_weapon_pda_", 14, false) != 0) {
		return Plugin_Continue;
	}

	//resend the event with the sending client added to recipients
	clResult[numClients] = client;
	TE_Start("PlayerAnimEvent");
	TE_WriteNum("m_iPlayerIndex", client);
	TE_WriteNum("m_iEvent", event);
	TE_WriteNum("m_nData", data);
	TE_Send(clResult, numClients+1, delay);

	//don't send the event we just hooked
	return Plugin_Stop;
}

public Action:OnPlayerAnimEvent(const String:te_name[], const Players[], numClients, Float:delay)
{
    // new client    = TE_ReadNum("m_iPlayerIndex");
    // new event    = TE_ReadNum("m_iEvent");
    // new data    = TE_ReadNum("m_nData");
    
    // PrintToChatAll("AnimEvent: Player: %i, Event: %i, Data: %i", client, event, data);
}

stock void SDK_PlaySpecificSequence(int client, const char[] strSequence)
{
	if(g_hSDKPlaySpecificSequence != INVALID_HANDLE) SDKCall(g_hSDKPlaySpecificSequence, client, strSequence);
}

stock an(index, event, data)
{
    TE_Start("PlayerAnimEvent");
    
    TE_WriteNum("m_iPlayerIndex", index); 
    TE_WriteNum("m_iEvent", event);
    TE_WriteNum("m_nData", data);
    
    TE_SendToAll();
}

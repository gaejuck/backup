#include <tf2_stocks>
#include <tf2items>

#define Square 1106

new Handle:hPlayTaunt;
public OnPluginStart()
{
	LoadTranslations("common.phrases");
	
	
	new Handle:conf = LoadGameConfigFile("tf2.tauntem");
	if (conf == INVALID_HANDLE)
	{
		SetFailState("Unable to load gamedata/tf2.tauntem.txt. Good luck figuring that out.");
		return;
	}
	StartPrepSDKCall(SDKCall_Player);
	PrepSDKCall_SetFromConf(conf, SDKConf_Signature, "CTFPlayer::PlayTauntSceneFromItem");
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);
	PrepSDKCall_SetReturnInfo(SDKType_Bool, SDKPass_Plain);
	hPlayTaunt = EndPrepSDKCall();
	if (hPlayTaunt == INVALID_HANDLE)
	{
		SetFailState("Unable to initialize call to CTFPlayer::PlayTauntSceneFromItem. Wait patiently for a fix.");
		CloseHandle(conf);
		return;
	}
	CloseHandle(conf);
	
	RegConsoleCmd("sm_btaunt", taunt);
	RegConsoleCmd("sm_swim", ToolCommand);
	RegConsoleCmd("sm_scout", scout);
	RegConsoleCmd("sm_soldier", soldier);
	
	HookEvent("player_spawn", PlayerSpawn);
}
public Action:ToolCommand(client, args)
{
	SetOverlay(client, "");
	TF2_AddCondition(client, TFCond:TFCond_SwimmingCurse, 10.0);
	return Plugin_Handled;
}

public Action:scout(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i))
		{
			TF2_SetPlayerClass(i, TFClass_Scout);
			TF2_RegeneratePlayer(i);
		}
	}
	return Plugin_Handled;
}

public Action:soldier(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i) && IsFakeClient(i))
		{
			TF2_SetPlayerClass(i, TFClass_Soldier);
			TF2_RegeneratePlayer(i);
		}
	}
	return Plugin_Handled;
}
public Action:taunt(client, args)
{
	decl String:arg[65];
	decl String:arg2[65];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		ReplyToCommand(client, "[SM]\x03sm_btaunt <name> <index>");
		return Plugin_Handled;
	}
		
	GetCmdArg(1, arg, sizeof(arg));
	GetCmdArg(2, arg2, sizeof(arg2));
	
	new index = StringToInt(arg2);
		
	HasTarget = true;	
	
	decl String:target_name[MAX_TARGET_LENGTH];
	
	if (HasTarget)
	{
		decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
		
		if ((target_count = ProcessTargetString(
				arg,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_CONNECTED,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
		{
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}
		
		for (new i = 0; i < target_count; i++)
		{
			Bot_Taunt(target_list[i], i, index);
		}
	}
	return Plugin_Handled;
}

stock Bot_Taunt(client, count, index)
{
	new String:temp[64];
	
	FormatEx(temp, MAX_NAME_LENGTH, "Bot %d", count);
	SetClientInfo(client, "name", temp);
	
	decl String:BotName[MAX_NAME_LENGTH];
	GetClientName(client, BotName, sizeof(BotName));
	
	TF2_RemoveCondition(client, TFCond_Taunting);
	
	new Handle:hPack;
	
	if(StrEqual(BotName, "Bot 0"))
	{
		CreateDataTimer(0.1, Bot_Taunt_Timer, hPack);	
		WritePackCell(hPack, client);
		WritePackCell(hPack, index);
	}
		
	if(StrEqual(BotName, "Bot 1"))
	{	
		CreateDataTimer(0.15, Bot_Taunt_Timer, hPack);
		WritePackCell(hPack, client);
		WritePackCell(hPack, index);
	}
	if(StrEqual(BotName, "Bot 2"))
	{
		CreateDataTimer(0.2, Bot_Taunt_Timer, hPack);	
		WritePackCell(hPack, client);
		WritePackCell(hPack, index);
	}
	if(StrEqual(BotName, "Bot 3"))
	{
		CreateDataTimer(0.25, Bot_Taunt_Timer, hPack);
		WritePackCell(hPack, client);
		WritePackCell(hPack, index);
	}
	if(StrEqual(BotName, "Bot 4"))
	{
		CreateDataTimer(0.3, Bot_Taunt_Timer, hPack);
		WritePackCell(hPack, client);
		WritePackCell(hPack, index);
	}
	if(StrEqual(BotName, "Bot 5"))
	{
		CreateDataTimer(0.35, Bot_Taunt_Timer, hPack);
		WritePackCell(hPack, client);
		WritePackCell(hPack, index);
	}
	if(StrEqual(BotName, "Bot 6"))
	{
		CreateDataTimer(0.4, Bot_Taunt_Timer, hPack);
		WritePackCell(hPack, client);
		WritePackCell(hPack, index);
	}
	if(StrEqual(BotName, "Bot 7"))
	{
		CreateDataTimer(0.45, Bot_Taunt_Timer, hPack);
		WritePackCell(hPack, client);
		WritePackCell(hPack, index);
	}
	if(StrEqual(BotName, "Bot 8"))
	{
		CreateDataTimer(0.5, Bot_Taunt_Timer, hPack);
		WritePackCell(hPack, client);
		WritePackCell(hPack, index);
	}
	if(StrEqual(BotName, "Bot 9"))
	{
		CreateDataTimer(0.55, Bot_Taunt_Timer, hPack);
		WritePackCell(hPack, client);
		WritePackCell(hPack, index);
	}
	if(StrEqual(BotName, "Bot 10"))
	{
		CreateDataTimer(0.6, Bot_Taunt_Timer, hPack);
		WritePackCell(hPack, client);
		WritePackCell(hPack, index);
	}
}

public Action:Bot_Taunt_Timer(Handle:hTimer, Handle:hPack)
{
	ResetPack(hPack);
	new client = ReadPackCell(hPack);
	new index = ReadPackCell(hPack);
	
	ExecuteTaunt(client, index);
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsFakeClient(client))
	{ 
		ChangeClientTeam(client, 3);
	}
}



ExecuteTaunt(client, itemdef)
{
	static Handle:hItem;
	hItem = TF2Items_CreateItem(OVERRIDE_ALL|PRESERVE_ATTRIBUTES|FORCE_GENERATION);
	
	TF2Items_SetClassname(hItem, "tf_wearable_vm");
	TF2Items_SetQuality(hItem, 6);
	TF2Items_SetLevel(hItem, 1);
	TF2Items_SetNumAttributes(hItem, 0);
	TF2Items_SetItemIndex(hItem, itemdef);
	
	new ent = TF2Items_GiveNamedItem(client, hItem);
	new Address:pEconItemView = GetEntityAddress(ent) + Address:FindSendPropInfo("CTFWearable", "m_Item");
	
	SDKCall(hPlayTaunt, client, pEconItemView) ? 1 : 0;
	AcceptEntityInput(ent, "Kill");
}

SetOverlay(client, const String:szOverlay[])
{
    SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & ~FCVAR_CHEAT);
    ClientCommand(client, "r_screenoverlay \"%s\"", szOverlay); 
    SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") | FCVAR_CHEAT);
}

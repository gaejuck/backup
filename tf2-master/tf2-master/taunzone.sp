#include <devzones>
#include <tf2items>
#include <sdktools>

public Plugin:myinfo = 
{
	name = "Taunt Zone",
	author = "TAKE 2",
	description = "도발 지역 플러그인",
	version = "1.0", 
	url = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc/"
};

new Handle:hPlayTaunt;

public OnPluginStart()   
{ 
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
}

public Zone_OnClientEntry(client, String:zone[])
{
	if(!IsClientInGame(client))
		return;
	if(StrContains(zone, "도발지역", false) == 0)
	{
		switch(GetRandomInt(0,3))
		{
			case 0: ExecuteTaunt(client, 1118);
			case 1: ExecuteTaunt(client, 1157);
			case 2: ExecuteTaunt(client, 1162);
			case 3: ExecuteTaunt(client, 30672);
		}
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

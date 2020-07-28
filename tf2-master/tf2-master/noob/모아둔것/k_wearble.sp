#include <tf2_stocks>
#include <tf2items>

public Plugin:myinfo =
{
	name = "k wearable",
	author = "k",
	description = "룩 보여주는 플러그인",
	version = "1.0",
	url = "http://steamcommunity.com/id/kimh0192"
}
 
new String:HatWearableConfig[120];
new String:SangWearableConfig[120];
new String:haWearableConfig[120];
new String:FaceWearableConfig[120];
new String:PaintConfig[120];
new String:UnusualConfig[120];

new Handle:hSDKEquipWearable;  
new Handle:newItem, Handle:DB; 
new Handle:nextItem[MAXPLAYERS+1]; 
 
new WearableItems;
new Index = 0, Lv = 0, qual = 0, ItemIndex = 0, i = 0;
new Float:PaintIndex = 0.0, Float:UnusualIndex = 0.0;
new String:ItemName[50], String:Number[64]; 
 
new bool:Paintx[MAXPLAYERS+1] = false;
new bool:ItemMenu[MAXPLAYERS+1] = false;

#include "wearble/wearble_hat.sp"
#include "wearble/wearble_face.sp"
#include "wearble/wearble_sang.sp"
#include "wearble/wearble_ha.sp"
#include "wearble/paint.sp"
#include "wearble/unusual.sp" 

///////////////////
public OnPluginStart()
{
	RegConsoleCmd("sm_look", mainmenu, "룩딸");
	BuildPath(Path_SM, HatWearableConfig, sizeof(HatWearableConfig), "configs/k_wearble/wearable-hat.cfg");
	BuildPath(Path_SM, SangWearableConfig, sizeof(SangWearableConfig), "configs/k_wearble/wearable-sang.cfg");
	BuildPath(Path_SM, haWearableConfig, sizeof(haWearableConfig), "configs/k_wearble/wearable-ha.cfg");
	BuildPath(Path_SM, FaceWearableConfig, sizeof(FaceWearableConfig), "configs/k_wearble/wearable-face.cfg");
	BuildPath(Path_SM, PaintConfig, sizeof(PaintConfig), "configs/k_wearble/paint.cfg");
	BuildPath(Path_SM, UnusualConfig, sizeof(UnusualConfig), "configs/k_wearble/unusual.cfg");
}

public OnClientPutInServer(client) 
{
	Paintx[client] = false;
	ItemMenu[client] = false;
}
public OnClientDisconnect(client)
{
	if(Paintx[client] == true)
	{
		Paintx[client] = false;
	}
	if(ItemMenu[client] == true)
	{
		ItemMenu[client] = false;
	}
}

public Action:mainmenu(client, args)
{
	wearable_menu(client);
	return Plugin_Handled;
}

public Action:wearable_menu(client)
{
	new Handle:info = CreateMenu(Menu_Information); // info 라는 메뉴를 만든다.
	SetMenuTitle(info, "고르삼");
	AddMenuItem(info, "1", "모자");  
	AddMenuItem(info, "2", "얼굴");
	AddMenuItem(info, "3", "상의");
	AddMenuItem(info, "4", "하의");
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
} 

public Menu_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
		if(select == 0)
		{
			hat(client);
		}
		else if(select == 1)
		{
			face(client);
		}
		else if(select == 2)
		{
			sang(client);
		}
		else if(select == 3)
		{
			ha(client);
		}
		else if(action == MenuAction_Cancel)
		{
			if(select == MenuCancel_Exit)
			{
			}
		}else if(action == MenuAction_End)
		{
			CloseHandle(menu);
		} 
	} 
}

public Action:TF2Items_OnGiveNamedItem(client, String:strClassName[], iItemDefinitionIndex, &Handle:hItemOverride)
{	
	if (nextItem[client] != INVALID_HANDLE)
	{
		TF2Items_GetItemIndex(nextItem[client]);

		hItemOverride = nextItem[client];
		nextItem[client] = INVALID_HANDLE;
		return Plugin_Changed;
	}
	return Plugin_Continue;
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

stock TF2_RemoveWearable2(iOwner, iItem) 
{
    if(TF2_SdkStartup() == true)
	{
		if (TF2_IsEntityWearable(iItem))
		{
			if (GetEntPropEnt(iItem, Prop_Send, "m_hOwnerEntity") == iOwner) SDKCall(hSDKEquipWearable, iOwner, iItem);
			RemoveEdict(iItem);
		}
	}
}

stock TF2_EquipWearable(client, wearable)
{
	if (hSDKEquipWearable == INVALID_HANDLE)
	{
		TF2_SdkStartup();
		LogMessage("Error: Can't call EquipWearable, SDK functions not loaded! If it continues to fail, reload plugin or restart server. Make sure your gamedata is intact!");
	}
	else
	{
		if (TF2_IsEntityWearable(wearable)) SDKCall(hSDKEquipWearable, client, wearable);
		else LogMessage("Error: Item %i isn't a valid wearable.", wearable);
	}
}

stock bool:TF2_SdkStartup()
{
	new Handle:hGameConf = LoadGameConfigFile("tf2items.randomizer");
	if (hGameConf == INVALID_HANDLE)
	{
		LogMessage("Couldn't load SDK functions (GiveWeapon). Make sure tf2items.randomizer.txt is in your gamedata folder! Restart server if you want wearable weapons.");
		return false;
	}
	if (hSDKEquipWearable == INVALID_HANDLE)
	{
		StartPrepSDKCall(SDKCall_Player);
		PrepSDKCall_SetFromConf(hGameConf, SDKConf_Virtual, "CTFPlayer::EquipWearable");
		PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);
		hSDKEquipWearable = EndPrepSDKCall();
	}

	CloseHandle(hGameConf);

	return true;
}
stock bool:TF2_IsEntityWearable(wearable)
{
	if (wearable > MaxClients && IsValidEdict(wearable))
	{
		new String:strClassname[32]; GetEdictClassname(wearable, strClassname, sizeof(strClassname));
		return (strncmp(strClassname, "tf_wearable", 11, false) == 0 || strncmp(strClassname, "tf_powerup", 10, false) == 0);
	}

	return false;
}
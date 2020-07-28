#include <sdktools>
#include <tf2attributes> 
#include <tf2> 
#include <tf2wearables> 
#include <tf2items_giveweapon> 

#define HDE_model "models/props_halloween/halloween_demoeye.mdl"

new bool:aaa[MAXPLAYERS+1] = false;

public OnPluginStart()
{
	RegConsoleCmd("sm_model", n);
	HookEvent("player_spawn", PlayerSpawn);
}

public OnMapStart()
{
	PrecacheModel(HDE_model, true);
	TF2Items_CreateWeapon(111111, "tf_wearable", 143, -1, 0 , 0, "", -1, "", true);
	TF2Items_CreateWeapon(222222, "tf_wearable", 334, -1, 0 , 0, "", -1, "", true);
	TF2Items_CreateWeapon(333333, "tf_wearable", 30283, -1, 0 , 0, "", -1, "", true);
	TF2Items_CreateWeapon(444444, "tf_wearable", 30009, -1, 0 , 0, "", -1, "", true);
	TF2Items_CreateWeapon(555555, "tf_wearable", 30503, -1, 0 , 0, "", -1, "", true);
}

public OnClientPutInServer(client){
	aaa[client] = false;
}
public OnClientDisconnect(client){
	aaa[client] = false;
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsFakeClient(client))
	{
		aaaa(client);
	}
	else
	{
		TF2Items_GiveWeapon(client, 111111);
		TF2Items_GiveWeapon(client, 222222);
		TF2Items_GiveWeapon(client, 333333);
		TF2Items_GiveWeapon(client, 444444);
		TF2Items_GiveWeapon(client, 555555);
	}
}

public Action:n(client, args)
{
	if(aaa[client] == false) 
	{
		aaa[client] = true; 
		SetModel(client, HDE_model);
		ReplyToCommand(client, "\x04ON");
	}
	else if(aaa[client] == true) 
	{
		aaa[client] = false;
		ReplyToCommand(client, "\x04OFF");
	}
}

public Action:SetModel(client, const String:model3[])
{
	if (IsPlayerAlive(client) && aaa[client] == true)
	{
		SetVariantString(model3);
		AcceptEntityInput(client, "SetCustomModel");
        
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
		SetEntProp(client, Prop_Send, "m_nBody", 1);
		SetEntProp(client, Prop_Send, "m_bForcedSkin", 1); 
		if(GetClientTeam(client)==3)
        {
			SetEntProp(client, Prop_Send, "m_nForcedSkin", 3); 
        }
		if(GetClientTeam(client)==2) //레드 4번
		{
			SetEntProp(client, Prop_Send, "m_nForcedSkin", 4); 
		}    
	}
}

public aaaa(client)
{
	new iEntity = CreateEntityByName("tf_wearable");
	if(IsValidEntity(iEntity))
	{
		DispatchSpawn(iEntity);
		SetVariantString("!activator");
		ActivateEntity(iEntity);

		TF2Attrib_SetByName(iEntity, "player skin override", 1.0);
		TF2Attrib_SetByName(iEntity, "zombiezombiezombiezombie", 1.0);
		TF2_EquipPlayerWearable(client, iEntity);
		
		SetEntProp(client, Prop_Send, "m_bGlowEnabled", 1);
		//SetEntProp(client, Prop_Send, "m_bForcedSkin", 23); 
		
		if(GetClientTeam(client)==3) //블루라고
        {
			SetEntProp(client, Prop_Send, "m_nForcedSkin", 6); 
        }
		if(GetClientTeam(client)==2) //레드 4번
		{
			SetEntProp(client, Prop_Send, "m_nForcedSkin", 5); 
		}    
	}
}
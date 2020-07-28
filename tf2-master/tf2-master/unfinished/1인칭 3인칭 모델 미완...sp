#include <sdktools>
#include <sdkhooks>
#include <tf2items>
#include <tf2itemsinfo>
#include <bonemerge_test>
#include <tf2_stocks>
#include "visible/stocks.sp"

public OnPluginStart()
{
	RegAdminCmd("sm_t", hat_create, 0); //모자 보임
	RegAdminCmd("sm_tt", hat_remove, 0); //모자 삭제
	RegAdminCmd("sm_pt", pt, 0); //무기 보임
	RegAdminCmd("sm_ptt", ptt, 0); //무기 삭제
	
	TF2_SdkStartup();
}

public Action:hat_create(client, args)
{
	PrecacheModel(ClassHat);
	
	FindClientHatEntity(client);
	
	aaa[client] = EntIndexToEntRef(Attachable_CreateAttachable(client, client, ClassHat, 1));
	SetEntProp(aaa[client], Prop_Send, "m_nSkin", 1);
	
	if(GetEntProp(aaa[client], Prop_Data, "m_spawnflags") & 4)
	{
		SetEntProp(aaa[client], Prop_Data, "m_spawnflags", 0);
		SetEntProp(aaa[client], Prop_Send, "m_CollisionGroup", 5);
	}
	PrintToChat(client, "모자 장착");
	return Plugin_Handled;
} 
 
public Action:hat_remove(client, args)
{
	if(aaa[client] != INVALID_ENT_REFERENCE)
	{
		TF2_RegeneratePlayer(client);
		Attachable_UnhookEntity(client, aaa[client]);
		aaa[client] = INVALID_ENT_REFERENCE;
		PrintToChat(client, "모자 삭제"); 
	} 
	return Plugin_Handled;  
} 

public Action:pt(client, args)
{
	new weapon = SpawnWeapon(client, "tf_weapon_rocketlauncher", 0, 205, 69, 7, "", rocket);
	
	//1인칭인데 모든 슬롯에 나옴..
	// EquipWearable(client, rocket, 0);
	
	// 아래꺼는 3인칭인데 모든 슬롯에 나옴..;;
	portal[client] = EntIndexToEntRef(Attachable_CreateAttachable(client, weapon, "models/weapons/c_models/c_rocketlauncher/tk_rocketlauncher.mdl", 0))
	
	PrintToChat(client, "무기 장착");
	return Plugin_Handled;
}
 
public Action:ptt(client, args)
{
	if(portal[client] != INVALID_ENT_REFERENCE)
	{
		Attachable_UnhookEntity(client, portal[client]);
		portal[client] = INVALID_ENT_REFERENCE;
		PrintToChat(client, "무기 삭제");
	}
	return Plugin_Handled;
}

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2items>
#include <tf2_stocks>

new String:PrimaryConfig[120];

public OnPluginStart()
{
	BuildPath(Path_SM, PrimaryConfig, sizeof(PrimaryConfig), "configs/drop_weapon.cfg");
	
	AddCommandListener(hook_VoiceMenu, "voicemenu");  //z,x,c키 보이스 메뉴
	HookEvent("player_death", Event_Player_Death); //플레이어가 죽었을때
}

public OnEntityCreated(entity, const String:classname[])
{
	if (StrEqual(classname, "tf_dropped_weapon"))
	{
		AcceptEntityInput(entity, "Kill");
	}
}

public Action:Event_Player_Death(Handle:event, const String:event_name[], bool:event_broadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
		
	decl String:strModel[255];
	new Float:newOrigin[3], Float:pos[3], Float:angle[3];
	GetClientAbsOrigin(client, newOrigin); //플레이어 위치
	pos[0] = newOrigin[0];
	pos[1] = newOrigin[1];
	pos[2] = newOrigin[2] + 5.0;
	angle[0] = 0.0;
	angle[1] = 0.0;
	angle[2] = 90.0;
	
	new weapon = GetPlayerWeaponSlot2(client, TFWeaponSlot_Primary); //주무기
	new iEntity = CreateEntityByName("prop_physics_override");
	if (weapon > 0 && IsValidEdict(weapon))
	{
		if (IsClassname(weapon, "tf_wearable_demoshield")) GetEntityModel(weapon, strModel, sizeof(strModel), "m_nModelIndex");
		else GetEntityModel(weapon, strModel, sizeof(strModel), "m_iWorldModelIndex");
		
		//그냥 모델 경로 알려주는 코드..
			
		SetEntProp(iEntity, Prop_Send, "m_CollisionGroup", 1); //COLLISION_GROUP_DEBRIS  
			
		TeleportEntity(iEntity, pos, angle, NULL_VECTOR); //엔티티가 pos, angle 텔포..
		PrecacheModel(strModel); //모델 어..어.. 머랄까 
		SetEntityModel(iEntity, strModel);
		DispatchSpawn(iEntity);

		CreateTimer(10.0, SpawnWeaponKill, iEntity);
	}
	else
	{
		AcceptEntityInput(iEntity, "kill");
	}

	return Plugin_Continue;
}

//====================================================================================================//
public Action:SpawnWeaponKill(Handle:timer, any:iEntity)
{
	if(IsValidEntity(iEntity))
	{
		RemoveEdict(iEntity);
	}
}

public Action:hook_VoiceMenu(client, const String:command[], argc)
{
	decl String:cmd1[32], String:cmd2[32];
		
	if(argc < 2) return Plugin_Handled;
		
	GetCmdArg(1, cmd1, sizeof(cmd1));
	GetCmdArg(2, cmd2, sizeof(cmd2));

	if(StrEqual(cmd1, "0") && StrEqual(cmd2, "0") && IsPlayerAlive(client))
	{
		if (AttemptGrabItem(client)) return Plugin_Handled;
		// if (AttemptGrabClassItem(client)) return Plugin_Handled;
	}

	return Plugin_Continue;
}

bool:AttemptGrabItem(iClient)
{
	new iTarget = GetClientPointVisible(iClient);
	new String:strClassname[255];
	if (iTarget > 0) GetEdictClassname(iTarget, strClassname, sizeof(strClassname));
	
	decl String:Classname[64], String:Attribute[256], String:name[256];
	
	new Handle:DB = CreateKeyValues("custom_weapon"); 
	FileToKeyValues(DB, PrimaryConfig);
	if(KvGotoFirstSubKey(DB))
	{
		do
		{
			KvGetSectionName(DB, name, sizeof(name));
			KvGetString(DB, "classname", Classname, sizeof(Classname));
			KvGetString(DB, "attribute", Attribute, sizeof(Attribute));
			new Index = KvGetNum(DB, "index", 0);
			new Level = KvGetNum(DB, "level", 1);
			new Qual = KvGetNum(DB, "qual", 5);
			
			if (IsClassname(iTarget, "prop_dynamic") || IsClassname(iTarget, "prop_physics"))
			{
				decl String:strModel[255];
				GetEntityModel(iTarget, strModel, sizeof(strModel));
				PrintToConsole(iClient, "Model: %s", strModel);
				
				if(StrEqual(strModel, name))
					SpawnWeapon(iClient, Classname, 0, Index, Level, Qual, Attribute);
				AcceptEntityInput(iTarget, "kill");
			}
		}
		while(KvGotoNextKey(DB));
		
		KvGoBack(DB);
	}
	
	KvRewind(DB);
	CloseHandle(DB);
	
	return true;
}

GetPlayerWeaponSlot2(iClient, iSlot)
{
	new iEntity = GetPlayerWeaponSlot(iClient, iSlot); //GetPlayerWeaponSlot 무기 슬롯
	if (iEntity > 0 && IsValidEdict(iEntity)) return iEntity; //IsValidEdict 엔티티가 있나 체크
	
	if (iSlot == 1)
	{
		iEntity = -1;
		while ((iEntity = FindEntityByClassname2(iEntity, "tf_wearable_demoshield")) != -1)
		{
			if (IsClassname(iEntity, "tf_wearable_demoshield") && GetEntPropEnt(iEntity, Prop_Send, "m_hOwnerEntity") == iClient) return iEntity;
		}
	}
	
	return -1;
}

stock FindEntityByClassname2(startEnt, const String:classname[]) {
	/* If startEnt isn't valid shifting it back to the nearest valid one */
	while (startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
}

GetEntityModel(iEntity, String:strModel[], iMaxSize, String:strPropName[] = "m_nModelIndex")
{
	//m_iWorldModelIndex
	new iIndex = GetEntProp(iEntity, Prop_Send, strPropName);
	GetModelPath(iIndex, strModel, iMaxSize);
}

GetModelPath(iIndex, String:strModel[], iMaxSize)
{
	new iTable = FindStringTable("modelprecache");
	ReadStringTable(iTable, iIndex, strModel, iMaxSize);
}

stock SpawnWeapon(client,String:name[],slot,index,level,qual,String:att[])
{
	new Flags = OVERRIDE_CLASSNAME | OVERRIDE_ITEM_DEF | OVERRIDE_ITEM_LEVEL | OVERRIDE_ITEM_QUALITY | OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES;
	
	new Handle:newItem = TF2Items_CreateItem(OVERRIDE_ALL);
	
	if (newItem == INVALID_HANDLE)
		return -1;
		
	TF2Items_SetClassname(newItem, name);
	
	if (strcmp(name, "saxxy", false) != 0) Flags |= FORCE_GENERATION;
		
	TF2Items_SetItemIndex(newItem, index);
	TF2Items_SetLevel(newItem, level);
	TF2Items_SetQuality(newItem, qual);
	TF2Items_SetFlags(newItem, Flags);
	
	new String:atts[32][32]; 
	new count = ExplodeString(att, " ; ", atts, 32, 32);
	
	if (count > 1)
	{
		TF2Items_SetNumAttributes(newItem, count/2);
		new i2 = 0;
		for (new i = 0;  i < count;  i+= 2)
		{
			TF2Items_SetAttribute(newItem, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
		TF2Items_SetNumAttributes(newItem, 0);
		
	TF2_RemoveWeaponSlot(client, slot);
	new entity = TF2Items_GiveNamedItem(client, newItem);
	
	EquipPlayerWeapon(client, entity);

	CloneHandle(newItem);
	return entity;
}

stock GetClientPointVisible(iClient) 
{
	decl Float:vOrigin[3], Float:vAngles[3], Float:vEndOrigin[3];
	GetClientEyePosition(iClient, vOrigin);
	GetClientEyeAngles(iClient, vAngles);
	
	new Handle:hTrace = INVALID_HANDLE;
	hTrace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_ALL, RayType_Infinite, TraceDontHitEntity, iClient);
	TR_GetEndPosition(vEndOrigin, hTrace);
	
	new iReturn = -1;
	new iHit = TR_GetEntityIndex(hTrace);
	
	if (TR_DidHit(hTrace) && iHit != iClient && GetVectorDistance(vOrigin, vEndOrigin) / 50.0 <= 2.0) 
	{
		iReturn = iHit;
	}
	CloseHandle(hTrace);
	
	return iReturn;
}

public bool:TraceDontHitEntity(iEntity, iMask, any:iData) 
{
	if(iEntity == iData)  return false;
	return true;
}

stock bool:IsClassname(iEntity, String:strClassname[]) 
{
	if (iEntity <= 0) return false;
	if (!IsValidEdict(iEntity)) return false;
	
	decl String:strClassname2[32];
	GetEdictClassname(iEntity, strClassname2, sizeof(strClassname2));
	if (StrEqual(strClassname, strClassname2, false)) return true;
	return false;
}

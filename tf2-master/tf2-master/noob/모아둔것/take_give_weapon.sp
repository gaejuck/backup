#include <tf2items_giveweapon>
#include <tf2items>
#include <sdktools>
#include <sourcemod>
#include <tf2_stocks>

#define model2 "models/weapons/w_models/w_scattergun.mdl"

public OnPluginStart()
{
	RegConsoleCmd("sm_g", g, "");
	
	RegConsoleCmd("sm_g2", g2, "");
	RegConsoleCmd("sm_g3", g3, "");
	
	RegConsoleCmd("sm_g4", g4, "");
}

public OnMapStart()
{
	PrecacheModel(model2, true);  
}

public Action:g(client, args) 
{
	//보조무기 테스트
	TF2_RemoveWeaponSlot(client, 1);
	SpawnWeapon(client, "tf_weapon_medigun", 998, 100, 5, "44 ; 3.0 ; 473 ; 3.0 ; 10 ; 1.5 ; 479 ; 0.34 ; 292 ; 1.0 ; 293 ; 2.0");

	//밀리무기 테스트
	TF2Items_CreateWeapon(45545, "saxxy", 1071, 2, 9, 10, "2 ; 69696969.0 ; 150 ; 1.0 ; 542 ; 0.0", _, _, true );
	TF2Items_GiveWeapon(client, 45545);
	return Plugin_Handled;
}

public Action:g2(client, args)
{
	new entity = TF2Items_GiveWeapon(client, 13);
	new model = PrecacheModel("models/weapons/w_models/w_scattergun.mdl");
	SetEntProp(entity, Prop_Send, "m_iWorldModelIndex", model);
	SetEntProp(entity, Prop_Send, "m_nModelIndexOverrides", model, _, 0);
	return Plugin_Handled;
}

public Action:g3(client, args) 
{
	new entity = TF2Items_GiveWeapon(client, 13);
	
	decl String:strModel[255];
	GetEntityModel(entity, strModel, sizeof(strModel));
	
	new iMaxSize;
	
	decl String:strName[255];
	
	if (StrEqual(strModel, model2))
	{
	//	TF2Items_GiveWeapon(client, 13);
		strcopy(strName, iMaxSize, "스캐터건");
    }
	
	Format(strName, sizeof(strName), "\x04[\x07ffffffPSF\x04] \x05%s \x01를 획득 했습니다.", strName ,client);
	
	if(PlayerCheck(client))
	{
		PrintToChat(client, "%s", strName);
	}
	SetEntityModel(entity, strModel);
	
	return Plugin_Handled;
}

public Action:g4(client, args) 
{
	TF2_RemoveWeaponSlot(client, 1);
	SpawnWeapon(client, "tf_weapon_medigun", 998, 100, 5, "44 ; 3.0 ; 473 ; 3.0 ; 10 ; 1.5 ; 479 ; 0.34 ; 292 ; 1.0 ; 293 ; 2.0");
	new aaaa = GetRandomInt(0, 100);
	SetViewmodelAnimation(client, aaaa);
	PrintToChat(client, "%d", aaaa);
	return Plugin_Handled;
}


stock SetViewmodelAnimation(client, sequence)
{
    new ent = GetEntPropEnt(client, Prop_Send, "m_hViewModel");
    if (!IsValidEdict(ent)) return;
    SetEntProp(ent, Prop_Send, "m_nSequence", sequence);
}  

stock bool:IsClassname(iEntity, String:strClassname[]) {
    if (iEntity <= 0) return false;
    if (!IsValidEdict(iEntity)) return false;
    
    decl String:strClassname2[32];
    GetEdictClassname(iEntity, strClassname2, sizeof(strClassname2));
    if (StrEqual(strClassname, strClassname2, false)) return true;
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

stock GetEntityModel(iEntity, String:strModel[], iMaxSize, String:strPropName[] = "m_nModelIndex")
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

stock SpawnWeapon(client,String:name[],index,level,qual,String:att[])
{
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon == INVALID_HANDLE)
		return -1;
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	new String:atts[32][32];
	new count = ExplodeString(att, " ; ", atts, 32, 32);
	if (count > 0)
	{
		TF2Items_SetNumAttributes(hWeapon, count/2);
		new i2 = 0;
		for (new i = 0;  i < count;  i+= 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
		TF2Items_SetNumAttributes(hWeapon, 0);
	new entity = TF2Items_GiveNamedItem(client, hWeapon);
	CloseHandle(hWeapon);
	EquipPlayerWeapon(client, entity);
	return entity;
} 
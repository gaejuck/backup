

	
	SetVariantString("2.0");
	AcceptEntityInput(client, "SetModelScale");
	
	//클라이언트
	SetVariantString("model");
	AcceptEntityInput(client, "SetCustomModel");
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	
	
	//프롭
	SetEntityModel(index, Sentry1);
	
	
	new stringTable = FindStringTable("modelprecache");
	new weapon = GetPlayerWeaponSlot(client, 2);
	decl String:modelName[PLATFORM_MAX_PATH];
	 
	ReadStringTable(stringTable, GetEntProp(weapon, Prop_Send, "m_iWorldModelIndex"), modelName, PLATFORM_MAX_PATH);   
	PrintToChatAll("%s", modelName);
	
	
	
	new String:modelname[128];
	GetEntPropString(entity, Prop_Data, "m_ModelName", modelname, 128); 
	PrintToChatAll("%s", modelname);
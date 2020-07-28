stock TF2_CreateGlow(client)
{
	char oldEntName[64];
	GetEntPropString(client, Prop_Data, "m_iName", oldEntName, sizeof(oldEntName));

	char strName[126], strClass[64];
	GetEntityClassname(client, strClass, sizeof(strClass));
	Format(strName, sizeof(strName), "%s%i", strClass, client);
	DispatchKeyValue(client, "targetname", strName);
	
	int ent = CreateEntityByName("bot_controller");
	DispatchKeyValue(ent, "targetname", "zoom");
	DispatchKeyValue(ent, "target", strName);

	DispatchKeyValue(ent, "bot_name", "김치맨");
	DispatchKeyValue(ent, "bot_class", "1");
	DispatchKeyValue(ent, "TeamNum", "3");
	DispatchSpawn(ent);
	
	AcceptEntityInput(ent, "Enable");
	
	SetVariantInt(1);
	AcceptEntityInput(ent, "CreateBot");
	
	SetVariantInt(0);
	AcceptEntityInput(ent, "PreventMovement");
	
	SetVariantEntity(client);
	AcceptEntityInput(ent, "AddCommandMoveToEntity");
	
	// SetVariantInt(1);
	// AcceptEntityInput(ent, "SetIgnoreHumans"); //무시

	SetEntPropString(client, Prop_Data, "m_iName", oldEntName);

	return ent;
}
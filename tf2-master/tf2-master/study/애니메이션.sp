public Action:aaaa(client, args)
{
	g_bSpecial[client] = true;
	PlayAnimation(client, "models/player/scout.mdl", "stand_LOSER");
	return Plugin_Handled;
}

stock PlayAnimation(client, String:model[], String:anim[])
{
	TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, view_as<float>({0.0, 0.0, 0.0}));
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, 255, 255, 255, 0);
	
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 0);	
	SetEntityMoveType(client, MOVETYPE_NONE);
	
	float vecOrigin[3], vecAngles[3];
	GetClientAbsOrigin(client, vecOrigin);
	GetClientAbsAngles(client, vecAngles);
	vecAngles[0] = 0.0;

	new animationentity = CreateEntityByName("prop_dynamic_override");
	if(IsValidEntity(animationentity))
	{
		DispatchKeyValueVector(animationentity, "origin", vecOrigin);
		DispatchKeyValueVector(animationentity, "angles", vecAngles);
		DispatchKeyValue(animationentity, "model", model);
		DispatchKeyValue(animationentity, "defaultanim", anim);
		DispatchSpawn(animationentity);
		SetEntPropEnt(animationentity, Prop_Send, "m_hOwnerEntity", client);
		
		if(GetEntProp(client, Prop_Send, "m_iTeamNum") == 0)
			SetEntProp(animationentity, Prop_Send, "m_nSkin", GetEntProp(client, Prop_Send, "m_nForcedSkin"));
		else
			SetEntProp(animationentity, Prop_Send, "m_nSkin", GetClientTeam(client) - 2);
			
		SetEntPropFloat(animationentity, Prop_Send, "m_flModelScale", 2.0);
		
		SetVariantString("OnAnimationDone !self:KillHierarchy::0.0:1");
		AcceptEntityInput(animationentity, "AddOutput");
		
		HookSingleEntityOutput(animationentity, "OnAnimationDone", OnAnimationDone, true);
		CreateTimer(1.5, ResetTaunt, client);
	}
}

public OnAnimationDone(const String:output[], caller, activator, Float:delay)
{	
	if(IsValidEntity(caller))
	{
		new client = GetEntPropEnt(caller, Prop_Send, "m_hOwnerEntity");
		if(client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client))
		{
			SetEntityMoveType(client, MOVETYPE_WALK);
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);		
			SetEntityRenderMode(client, RENDER_TRANSCOLOR);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			g_bSpecial[client] = false;
			PrintToChat(client, "작동함?");
		}
	}
}

public Action:ResetTaunt(Handle:timer, any:client)
{
	SetEntityMoveType(client, MOVETYPE_WALK);
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);		
	SetEntityRenderMode(client, RENDER_TRANSCOLOR);
	SetEntityRenderColor(client, 255, 255, 255, 255);
	g_bSpecial[client] = false;
}

//---
public Action:conga(client, args)
{
	new iEnt = -1;
	decl String:szName[30];
	while((iEnt = FindEntityByClassname2(iEnt, "prop_dynamic_override")) != -1)
	{
		GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
		if(IsValidEdict(iEnt))
		{
			if(StrEqual(szName, "model_taunt"))
				AcceptEntityInput(iEnt, "Kill");
		}
	}
	while((iEnt = FindEntityByClassname2(iEnt, "tf_taunt_prop")) != -1)
	{
		GetEntPropString(iEnt, Prop_Data, "m_iName", szName, 16, 0);
		if(IsValidEdict(iEnt))
		{
			if(StrEqual(szName, "DispenserLink"))
				AcceptEntityInput(iEnt, "Kill");
		}
	}
	
	switch(GetRandomInt(0,5))
	{
		case 0: ParentHatEntity(client, "models/player/engineer.mdl", "head", -3.0, 1.0, "taunt_conga");
		case 1: ParentHatEntity(client, "models/player/pyro.mdl", "head", -3.0, 1.0, "taunt_pyro_pool");
		case 2: ParentHatEntity(client, "models/player/pyro.mdl", "head", -3.0, 1.0, "taunt_aerobic_B");
		case 3: ParentHatEntity(client, "models/player/heavy.mdl", "head", -3.0, 3.0, "taunt_zoomin_broom");
		case 4: ParentHatEntity(client, "models/player/pyro.mdl", "head", -3.0, 5.0, "pyro_taunt_replay");
		case 5: ParentHatEntity(client, "models/player/pyro.mdl", "head", -3.0, 4.0, "primary_death_headshot");
	}
	return Plugin_Handled;
}

stock ParentHatEntity(client, const String:smodel[], String:attach[], Float:flZOffset = 0.0, Float:flModelScale, const String:strAnimation[])
{
	new Float:pPos[3], Float:pAng[3];
	new prop = CreateEntityByName("prop_dynamic_override");

	new String:strModelPath[PLATFORM_MAX_PATH];
	if(IsValidEntity(prop))
	{
		if(!StrEqual(strModelPath, "", false))
			DispatchKeyValue(prop, "model", strModelPath); 
		else
		{
			DispatchKeyValue(prop, "model", smodel); 
			
		}
		
		SetEntPropFloat(prop, Prop_Send, "m_flModelScale", flModelScale);
		
		DispatchKeyValue(prop, "targetname", "model_taunt");

		DispatchSpawn(prop);
		AcceptEntityInput(prop, "Enable");
		SetEntProp(prop, Prop_Send, "m_nSkin", GetClientTeam(client) - 2);

		SetVariantString("!activator");
		AcceptEntityInput(prop, "SetParent", client);
		

		new iLink = CreateLink(client, attach);

		SetVariantString("!activator");
		AcceptEntityInput(prop, "SetParent", iLink); 
		
		SetVariantString(attach); 
		AcceptEntityInput(prop, "SetParentAttachment", iLink); 
		
		if(StrEqual(attach, "head"))
		{
			pPos[0] -= 100;
		}

		SetEntPropEnt(prop, Prop_Send, "m_hEffectEntity", iLink);
		
		GetEntPropVector(prop, Prop_Send, "m_vecOrigin", pPos);
		GetEntPropVector(prop, Prop_Send, "m_angRotation", pAng);
		
		if(!StrEqual(strAnimation, "default", false))
		{
			SetVariantString(strAnimation);
			AcceptEntityInput(prop, "SetAnimation");  
			SetVariantString(strAnimation);
			AcceptEntityInput(prop, "SetDefaultAnimation");
		}
		
		pPos[2] += flZOffset;
			
		
		SetEntPropVector(prop, Prop_Send, "m_vecOrigin", pPos);
		SetEntPropVector(prop, Prop_Send, "m_angRotation", pAng);
		
	}
}

stock CreateLink(iClient, String:attach[])
{
	new iLink = CreateEntityByName("tf_taunt_prop");
	DispatchKeyValue(iLink, "targetname", "DispenserLink");
	DispatchSpawn(iLink); 
	
	char strModel[PLATFORM_MAX_PATH];
	GetEntPropString(iClient, Prop_Data, "m_ModelName", strModel, PLATFORM_MAX_PATH);
	
	SetEntityModel(iLink, strModel);
	
	SetEntProp(iLink, Prop_Send, "m_fEffects", 16|64);
	
	SetVariantString("!activator"); 
	AcceptEntityInput(iLink, "SetParent", iClient); 
	
	SetVariantString(attach);
	
	AcceptEntityInput(iLink, "SetParentAttachment", iClient);
	
	
	new Float:pPos[3];
	pPos[0] += 200;
	SetEntPropVector(iLink, Prop_Send, "m_vecOrigin", pPos);
	
	return iLink;
}

//---
	
	
	new Float:g_pos[3];

	new iPumpkin = CreateEntityByName("tf_pumpkin_bomb");
	
	if(IsValidEntity(iPumpkin))
	{		
		DispatchSpawn(iPumpkin);
		g_pos[2] -= 10.0;
		TeleportEntity(iPumpkin, g_pos, NULL_VECTOR, NULL_VECTOR);
	}	
	
	
	
	if(!SetTeleportEndPoint(client))
	{
		PrintToChat(client, "[SM] Could not find spawn point.");
		return Plugin_Handled;
	}
	
	SpawnEntity(client, "models/props_halloween/pumpkin_explode.mdl");


stock SpawnEntity(iClient, const String:sModel[])
{
	decl Float:fAngles[3], Float:fCAngles[3], Float:fCOrigin[3], Float:fOrigin[3];
	GetClientAbsAngles(iClient, fAngles);

	GetClientEyePosition(iClient, fCOrigin);

	GetClientEyeAngles(iClient, fCAngles);

	new Handle:hTraceRay = TR_TraceRayFilterEx(fCOrigin, fCAngles, MASK_SOLID, RayType_Infinite, FilterPlayer);

	if(TR_DidHit(hTraceRay))
	{
		TR_GetEndPosition(fOrigin, hTraceRay);

		CloseHandle(hTraceRay);
	}

	new iEnt = CreateEntityByName("prop_physics_override");

	PrecacheModel(sModel);

	DispatchKeyValue(iEnt, "model", sModel);

	DispatchSpawn(iEnt);

	TeleportEntity(iEnt, fOrigin, fAngles, NULL_VECTOR);
}

public bool:FilterPlayer(entity, contentsMask)
{
	return entity > MaxClients;
}



SetTeleportEndPoint(client)
{
	decl Float:vAngles[3];
	decl Float:vOrigin[3];
	decl Float:vBuffer[3];
	decl Float:vStart[3];
	decl Float:Distance;
	
	GetClientEyePosition(client,vOrigin);
	GetClientEyeAngles(client, vAngles);
	
    //get endpoint for teleport
	new Handle:trace = TR_TraceRayFilterEx(vOrigin, vAngles, MASK_SHOT, RayType_Infinite, TraceEntityFilterPlayer);

	if(TR_DidHit(trace))
	{   	 
   	 	TR_GetEndPosition(vStart, trace);
		GetVectorDistance(vOrigin, vStart, false);
		Distance = -35.0;
   	 	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
		g_pos[0] = vStart[0] + (vBuffer[0]*Distance);
		g_pos[1] = vStart[1] + (vBuffer[1]*Distance);
		g_pos[2] = vStart[2] + (vBuffer[2]*Distance);
	}
	else
	{
		CloseHandle(trace);
		return false;
	}
	
	CloseHandle(trace);
	return true;
}

public bool:TraceEntityFilterPlayer(entity, contentsMask)
{
	return entity > GetMaxClients() || !entity;
}
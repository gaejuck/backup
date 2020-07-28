
SDKHook(iPumpkin, SDKHook_StartTouch, OnTouch);
//iPumpkin이라는 엔티티에 터치가 시작 됏을때 발생

SDKHook(iPumpkin, SDKHook_StartTouchPost, OnTouch); // SDKHook_Touch랑 같은거같은데..
//iPumpkin이라는 엔티티에 터치가 시작했음에도 계속 발생

SDKHook(iPumpkin, SDKHook_EndTouch, OnTouch);
//iPumpkin이라는 엔티티에 터치가 끝났을때 발생



SDKHook_EndTouchPost 
// 몰라 이거 SDKHook_StartTouch 얘랑 같어..;;;

public OnEntityCreated(entity, const String:classname[])
{
	if(StrEqual(classname, "tf_projectile_rocket")) //거품, 버블
	{
		SDKHook(entity, SDKHook_Spawn, soldier);
	}
	//if(StrContains(classname, "tf_projectile") != -1)
}

public OnEntityDestroyed(entity) //엔티티가 파괴되었을 때
{
	if (IsValidEntity(entity))
	{
		new String:classname[32]
		// new owner = GetEntPropEnt(entity,Prop_Data,"m_hOwnerEntity")
		
		GetEntPropString(entity,Prop_Data,"m_iClassname",classname,sizeof(classname))
		if (StrContains(classname,"tf_projectile",false)!=-1)
		{
			new Float:ori[3];
			GetEntPropVector(entity, Prop_Data, "m_vecOrigin", ori);

			new boom=CreateEntityByName(boooooom)
			ori[2] -= 10.0
			if (IsValidEntity(boom))
			{
				TeleportEntity(boom,ori,NULL_VECTOR,NULL_VECTOR)
				DispatchSpawn(boom)
				SetEntPropEnt(boom,Prop_Send,"m_hOwnerEntity",0)
			}
		}
	}
}


SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
//리턴 못씀 OnPostThinkPost
public OnPostThinkPost(client)
{
}

stock FindClientHatEntity(client) 
{
	new iEnt = -1;
	while ((iEnt = FindEntityByClassname(iEnt, "tf_wearable")) != -1) 
	{
		if (GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == client && TF2II_GetItemSlot(GetEntProp(iEnt, Prop_Send, "m_iItemDefinitionIndex"), TF2_GetPlayerClass(client)) == TF2ItemSlot_Hat) 
		{
			AcceptEntityInput(iEnt, "Kill"); 
		}
	}
	return 0;
}  

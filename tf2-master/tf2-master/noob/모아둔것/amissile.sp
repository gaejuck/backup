#include <sourcemod>
#include <sdkhooks>
#include <sdktools> 
#include <tf2_stocks>

public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_death", Player_Death);
	
	CreateTimer(0.1, aaaa, _, TIMER_REPEAT);
}

public Action:aaaa(Handle:timer, any:client)
{
	SendHudMSG(client, 2, -1.0, -1.0, 100, 255, 230, 255, 100, 255, 230, 190, 1, 0.1, 0.2, 0.5, 1.0, "ㅇ");
}

public OnEntityCreated(entity, const String:classname[])
{

	if( StrEqual( classname, "tf_projectile_rocket"))
	{
	    SDKHook(entity, SDKHook_Spawn, OnEntitySpawned);
	}
}

public OnEntitySpawned(entity)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		decl Float:entityposition[3];
		if(IsValidClient(i)) //접속해 있는지
		{
			GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityposition);
			new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") //내꺼일경우
			if(i == owner)
			{
				SetClientViewEntity(i, entity);
				TeleportEntity(i, entityposition, NULL_VECTOR, NULL_VECTOR);
			} 
		}
	}
}

public soldier(client) //이건 로켓 발사체고
{
	decl Float:entityposition[3];
	if(IsValidClient(client)) //접속해 있는지
	{
		GetEntPropVector(entity, Prop_Send, "m_vecOrigin", entityposition);
		new owner = GetEntPropEnt(entity, Prop_Send, "m_hOwnerEntity") //내꺼일경우
		if(client == owner)
		{
			SetClientViewEntity(i, entity);
			TeleportEntity(i, entityposition, NULL_VECTOR, NULL_VECTOR);
		} 
	}
}

stock IsValidClient(client)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client))
		return true;
	return false;
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	SetClientViewEntity(client, client);
}

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	SetClientViewEntity(client, client);
}

// public OnGameFrame()
// {
	// for(new i = 1; i <= MaxClients; i++)
	// {/*
		// new rocket = -1;
		// decl Float:entityposition[3];
		// if(IsClientConnected(i) && IsClientInGame(i))
		// {
	//		while ((rocket=FindEntityByClassname(rocket, "tf_projectile_*"))!=INVALID_ENT_REFERENCE)
			// while ((rocket=FindEntityByClassname(rocket, "tf_projectile_rocket"))!=INVALID_ENT_REFERENCE)
			// {
				// GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", entityposition);
				// if(IsValidEntity(rocket))
				// {
					// new iOwner = GetEntDataEnt2(rocket, FindSendPropInfo("CTFProjectile_Rocket", "m_hThrower"));
					// if(iOwner == i)
					// {
						// if(IsValidEntity(rocket))
						// {
							// SetClientViewEntity(i, rocket);
							// TeleportEntity(i, entityposition, NULL_VECTOR, NULL_VECTOR);
						// }
					// }
				// }
			// }
		// }*/
		// aa(i);
	// }
// }

// public aa(client)
// {
	// new rocket = -1;
	// decl Float:entityposition[3];
	// if(IsClientConnected(client) && IsClientInGame(client))
	// {
		// while ((rocket=FindEntityByClassname(rocket, "tf_projectile_rocket"))!=INVALID_ENT_REFERENCE)
		// {
			// GetEntPropVector(rocket, Prop_Send, "m_vecOrigin", entityposition);
			// new iOwner = GetEntPropEnt(rocket, Prop_Data, "m_hOwnerEntity");
			// if(iOwner == client)
			// {
				// if(IsValidEntity(rocket))
				// {
					// SetClientViewEntity(client, rocket);
					// TeleportEntity(client, entityposition, NULL_VECTOR, NULL_VECTOR);
				// }
			// }
		// }
	// }
// }

stock SendHudMSG(Client, Channel, Float:x, Float:y, Red1, Green1, Blue1, ALPHA1, Red2, Green2, Blue2, ALPHA2, Effect, Float:Fadein, Float:Fadeout, Float:Holdtime, Float:Fxtime, const String:MSG[], any:...)
{
    new Handle:HHandle = INVALID_HANDLE;
    if(Client == 0)
    {
        HHandle = StartMessageAll("HudMsg"); 
    }
    else
    {
        HHandle = StartMessageOne("HudMsg", Client); //
    }
    if(HHandle != INVALID_HANDLE)
    { 
        BfWriteByte(HHandle, Channel); //Channel
        BfWriteFloat(HHandle, x); // x ( -1 = center )
        BfWriteFloat(HHandle, y); // y ( -1 = center )
        BfWriteByte(HHandle, Red1); //Red1
        BfWriteByte(HHandle, Green1); //Green1
        BfWriteByte(HHandle, Blue1); //Blue1
        BfWriteByte(HHandle, ALPHA1); //ALPHA1 // transparent?
        BfWriteByte(HHandle, Red2); //Red2
        BfWriteByte(HHandle, Green2); //Green2
        BfWriteByte(HHandle, Blue2); //Blue2
        BfWriteByte(HHandle, ALPHA2); //ALPHA2
        BfWriteByte(HHandle, Effect); //Effect (0 is fade in/fade out; 1 is flickery credits; 2 is write out)
        BfWriteFloat(HHandle, Fadein); //FadeinTime (message fade in time - per character in Effect 2)
        BfWriteFloat(HHandle, Fadeout); //FadeoutTime
        BfWriteFloat(HHandle, Holdtime); //Holdtime
        BfWriteFloat(HHandle, Fxtime); //Fxtime (Effect type(2) used)
        BfWriteString(HHandle, MSG); //Message
        EndMessage();
    }
}
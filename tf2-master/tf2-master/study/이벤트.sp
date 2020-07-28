public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("player_death", Player_Death);
	HookEvent("object_deflected", object_deflected);
	HookEvent("player_builtobject", event_PlayerBuiltObject); 
	HookEvent("player_changeclass", player_changeclass);
	HookEvent("post_inventory_application", post_inventory_application);
	HookEvent("item_pickup", item_pickup);
}

public item_pickup(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsClientConnected(client) || !IsClientInGame(client))
		return;
		
	new String:temp[32];
	GetEventString(event, "item", temp, sizeof(temp));
	if (StrContains(temp, "ammo", false) != -1)
	{
		PrintToChat(client, "ㅁㄴㅇ");
	}
}

public Action:event_PlayerBuiltObject(Handle:event, const String:name[], bool:dontBroadcast)
{
	new index = GetEventInt(event, "index");
	if(IsValidEdictType(index, "obj_dispenser"))
	if(IsValidEdictType(index, "obj_sentrygun"))
	{
		SetEntProp(index, Prop_Send, "m_bDisabled", 1);
		SetEntProp(index, Prop_Send, "m_iMaxHealth", 250);
	}

	return Plugin_Continue;         
}

IsValidEdictType(edict, String:class[])
{
  if (edict && IsValidEdict(edict))
  {
    decl String:s[64];
    GetEdictClassname(edict, s, 64);
    if (StrEqual(class,s))
      return true;
  }
  return false;
}

public Action:post_inventory_application(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsFakeClient(client))
	{
		TF2Attrib_SetByDefIndex(client, 705, 1.0);
		TF2Attrib_SetByDefIndex(client, 701, 1.0);
	}
}

public Action:player_changeclass(Handle:event, String:strEventName[], bool:bDontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	CancelMenu(h_menu);
	CancelMenu(m_menu);
	CancelMenu(m2_menu);
	CancelMenu(u_menu);
	CancelMenu(uw_menu);
}


public Action:object_deflected(Handle:Event, String:Name[], bool:Broadcast)
{
	decl Client;
	decl owner;
	Client = GetClientOfUserId(GetEventInt(Event, "userid"));
	owner = GetClientOfUserId(GetEventInt(Event, "ownerid"));
	new check = GetEventInt(Event, "object_entindex");
	decl String:clientname[64];
	decl String:ownername[64];
	EntIndexToEntRef(check);
	GetClientName(Client, clientname, 64);
	GetClientName(owner, ownername, 64);
	if (owner == check)
	{
		if (AliveCheck(owner))
		{
			PrintToChatAll("\x04[진성] %s\x01님이 %s님에게 인붕을 하셨습니다", clientname, ownername);
			new killcheck = GetConVarInt(C_inbung);
			if (killcheck == 1)
			{
				ForcePlayerSuicide(Client);
			}
		}
	}
	return Action:0;
}

public Action:Player_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
}
public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
}


stock bool SB_FakeKillFeed(int victim, int attacker, int assister=0, int inflictor_entindex=0, bool headshot=false)
{
    //environmental_death player_death
    Handle fakeEvent = CreateEvent("player_death", true);
    if (fakeEvent != null) // event succeed!
    {
        //char sWeapon[32];
        if(attacker > 32 || attacker <=0) attacker = victim;

        PrintToChatAll("victim %d, attacker %d",victim,attacker);

        //GetClientWeapon(attacker, STRING(sWeapon));

/*        This code is for reference only and do not use here

        This code is for capture in player_death capturing events:

        We should not trigger event_player_death related things if it  was an event fired by sourcemod or if it is a deadringer (fake) death.
        stock bool:IsValidEventDeath(Handle:hEvent)
        {
            return !( (GetEventBool(hEvent, "sourcemod") ||  (GetEventInt(hEvent, "death_flags") & TF_DEATHFLAG_DEADRINGER)) );
        }
*/
        SetEventBool(fakeEvent, "sourcemod", true);                            //claims sourcemod based event

        SetEventInt(fakeEvent, "userid", GetClientUserId(victim));                                 //user ID who died
        PrintToChatAll("userid %d",GetClientUserId(victim));

        SetEventInt(fakeEvent, "victim_entindex", victim);
        PrintToChatAll("victim_entindex %d",victim);


        SetEventInt(fakeEvent, "assister", -1);
        SetEventInt(fakeEvent, "kill_streak_total", 1);
        SetEventInt(fakeEvent, "kill_streak_wep", 1);
        SetEventInt(fakeEvent, "attacker", GetClientUserId(attacker));                             //user ID who killed
        SetEventInt(fakeEvent, "inflictor_entindex", attacker);         //ent index of inflictor (a sentry, for example)
        SetEventBool(fakeEvent, "silent_kill", true);

        /*
        if(assister)
        {
            SetEventInt(fakeEvent, "assister", GetClientUserId(assister));                             //user ID of assister
            PrintToChatAll("assister %d",GetClientUserId(assister));
        }
        else
        {
            SetEventInt(fakeEvent, "assister", -1);                             //user ID of assister
            PrintToChatAll("assister -1");
        }*/

        /*
        SetEventInt(fakeEvent, "attacker", GetClientUserId(attacker));                             //user ID who killed
        PrintToChatAll("attacker %d",GetClientUserId(attacker));

        if(inflictor_entindex <= 0) inflictor_entindex = attacker;
        if(inflictor_entindex)
        {
            SetEventInt(fakeEvent, "inflictor_entindex",  inflictor_entindex);         //ent index of inflictor (a sentry, for  example)
            PrintToChatAll("inflictor_entindex %d",inflictor_entindex);
        }*/

        //SetEventInt(fakeEvent, "weapon_def_index", 13);

        //SetEventString(fakeEvent, "weapon", "world");
        //SetEventInt(fakeEvent, "customkill", TF_CUSTOM_SUICIDE ); //효과 짱
        //SetEventString( fakeEvent, "weapon_logclassname", "world" );
        //SetEventInt(fakeEvent, "death_flags", TF_DEATHFLAG_KILLERDOMINATION );

        /*
        SetEventString(fakeEvent, "weapon", sWeapon);                                             //weapon name killer used
        PrintToChatAll("weapon %s",sWeapon);
        SetEventString(fakeEvent, "weapon_logclassname", sWeapon);                                  //weapon name that should be printed on the  log
        PrintToChatAll("weapon_logclassname %s",sWeapon);
        */

        //SetEventBool(fakeEvent, "headshot", headshot);
        //PrintToChatAll("headshot %s",headshot?"true":"false");
        //SetEventBool(fakeEvent, "silent_kill", false);
        //PrintToChatAll("heasilent_kill false");

        FireEvent(fakeEvent);
        return true;
    }
    PrintToChatAll("Event Failed");
    return false;
}
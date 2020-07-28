stock bool:CoolTime(any:iClient, Float:fCoolTime, Float:fTime)
{
	if(IsClientInGame(iClient))
		if(GetGameTime() - fCoolTime >= fTime)
			return true;
	return false;
}

public OnGameFrame()
{
	new i = MaxClients+1;
	while ((i=FindEntityByClassname(i, "tf_projectile_arrow"))!=INVALID_ENT_REFERENCE)
	{
		new client = GetEntPropEnt(i, Prop_Data, "m_hOwnerEntity");
		
		if(IsValidEntity(i))
		{
			AcceptEntityInput(i, "Kill");
		}
	}
}

public OnGameFrame()
{
	new ent = MaxClients+1;
	while ((ent = FindEntityByClassname2(ent, "light")) != -1)
	{
		if (IsValidEntity(ent))
		{
			DispatchKeyValue(ent, "rendercolor", color);
			AcceptEntityInput(ent, "TurnOff");
		}
	}
}

stock FindEntityByClassname2(startEnt, const String:classname[])
{
	while(startEnt > -1 && !IsValidEntity(startEnt)) startEnt--;
	return FindEntityByClassname(startEnt, classname);
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

stock Handle:PrepareItemHandle(Handle:hItem, String:name[] = "", index = -1, const String:att[] = "", bool:dontpreserve = false)
{
    static Handle:hWeapon;
    new addattribs = 0;

    new String:weaponAttribsArray[32][32];
    new attribCount = ExplodeString(att, " ; ", weaponAttribsArray, 32, 32);

    new flags = OVERRIDE_ATTRIBUTES;
    if (!dontpreserve)
    {
        flags |= PRESERVE_ATTRIBUTES;
    }

    if (hWeapon == INVALID_HANDLE)
    {
        hWeapon = TF2Items_CreateItem(flags);
    }
    else
    {
        TF2Items_SetFlags(hWeapon, flags);
    }

    //  new Handle:hWeapon = TF2Items_CreateItem(flags);    //INVALID_HANDLE;

    if (hItem != INVALID_HANDLE)
    {
        addattribs = TF2Items_GetNumAttributes(hItem);

        if (addattribs > 0)
        {
            for (new i = 0; i < 2 * addattribs; i += 2)
            {
                new bool:dontAdd = false;
                new attribIndex = TF2Items_GetAttributeId(hItem, i);

                for (new z = 0; z < attribCount + i; z += 2)
                {
                    if (StringToInt(weaponAttribsArray[z]) == attribIndex)
                    {
                        dontAdd = true;

                        break;
                    }
                }

                if (!dontAdd)
                {
                    IntToString(attribIndex, weaponAttribsArray[i + attribCount], 32);
                    FloatToString(TF2Items_GetAttributeValue(hItem, i), weaponAttribsArray[i + 1 + attribCount], 32);
                }
            }

            attribCount += 2 * addattribs;
        }

        CloseHandle(hItem); //probably returns false but whatever
    }

    if (name[0] != '\0')
    {
        flags |= OVERRIDE_CLASSNAME;
        TF2Items_SetClassname(hWeapon, name);
    }

    if (index != -1)
    {
        flags |= OVERRIDE_ITEM_DEF;
        TF2Items_SetItemIndex(hWeapon, index);
    }

    if (attribCount > 1)
    {
        TF2Items_SetNumAttributes(hWeapon, (attribCount / 2));
        new i2 = 0;

        for (new i = 0; i < attribCount && i < 32; i += 2)
        {
            TF2Items_SetAttribute(hWeapon, i2, StringToInt(weaponAttribsArray[i]), StringToFloat(weaponAttribsArray[i + 1]));
            i2++;
        }
    }
    else
    {
        TF2Items_SetNumAttributes(hWeapon, 0);
    }

    TF2Items_SetFlags(hWeapon, flags);

    return hWeapon;
}


stock SetWeaponAlpha(Weapon, Alpha)
{
  SetEntityRenderMode(Weapon, RENDER_TRANSCOLOR); // 무기의 렌더링 타입 세팅
  SetEntityRenderColor(Weapon, 255, 255, 255, Alpha); // 여기서 무기색상 코드를 제시하자
}

SetWeaponAlpha(iEntity, 0); 안보이게
SetWeaponAlpha(iEntity, 255); 보이게

public bool:AliveCheck(client)
{
	if(client > 0 && client <= MaxClients)
		if(IsClientConnected(client) == true)
			if(IsClientInGame(client) == true)
				if(IsPlayerAlive(client) == true) return true;
				else return false;
			else return false;
		else return false;
	else return false;
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

stock bool:IsClientAdmin(client)
{
	new AdminId:Cl_ID;
	Cl_ID = GetUserAdmin(client);
	if(Cl_ID != INVALID_ADMIN_ID)
		return true;
	return false;
}
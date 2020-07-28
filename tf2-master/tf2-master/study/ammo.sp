new index = GetEntProp(entity, Prop_Send, "m_iItemDefinitionIndex");
if(index == 1153)
{
	new iAmmoType = GetEntProp(entity, Prop_Send, "m_iPrimaryAmmoType");
	if(iAmmoType != -1) SetEntProp(client, Prop_Data, "m_iAmmo", 32, _, iAmmoType);
}
//최대 탄약

//셋 아모
stock SetAmmo(client, slot, ammo)
{
    new weapon = GetPlayerWeaponSlot(client, slot);

    if (IsValidEntity(weapon))
    {
        new iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4;
        new iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");

        SetEntData(client, iAmmoTable + iOffset, ammo, 4, true);
    }
}

stock GetAmmo(client, slot)
{
    new weapon = GetPlayerWeaponSlot(client, slot);

    if (IsValidEntity(weapon))
    {
        new iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1) * 4;
        new iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");

        return GetEntData(client, iAmmoTable + iOffset);
    }

    return 0;
}  
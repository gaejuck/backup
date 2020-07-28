#include <tf2itemsinfo> 
#include <tf2attributes>
#include <sdktools>
#include <tf2items>

public Plugin:myinfo = 
{
	name = "unusual",
	author = "TAKE 2",
	description = "ㅇㅇ 언유",
	version = "1.0", 
	url = "x"
};

public Action:TF2Items_OnGiveNamedItem(iClient, String:strClassname[], iIndex, &Handle:hItem)
{
    static Handle:hWeapon;

    // TF2Items should auto-close weapon handles, but it doesn't
    if (hWeapon != INVALID_HANDLE)
    {
        CloseHandle(hWeapon);
        hWeapon = INVALID_HANDLE;
    }

    decl String:strSlot[32];
    TF2II_GetItemSlotName(iIndex, strSlot, sizeof(strSlot));
    if(StrEqual(strSlot, "head"))
    { 
        hWeapon = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
        if (hWeapon == INVALID_HANDLE)
        {
            return Plugin_Continue;
        }
        TF2Items_SetNumAttributes(hWeapon, 1);
        TF2Items_SetAttribute(hWeapon, 0, 134, 80.0);
        hItem = hWeapon;
        return Plugin_Changed;
    }
    return Plugin_Continue;
}  

/*
FindClientHatEntity(iClient) {
    new iEnt = -1;
    while ((iEnt = FindEntityByClassname(iEnt, "tf_wearable")) != -1) {
        if (GetEntPropEnt(iEnt, Prop_Send, "m_hOwnerEntity") == iClient && TF2II_GetItemSlot(GetEntProp(iEnt, Prop_Send, "m_iItemDefinitionIndex"), TF2_GetPlayerClass(iClient)) == TF2ItemSlot_Hat) {
            return iEnt;
        }
    }

    return 0;
}  */
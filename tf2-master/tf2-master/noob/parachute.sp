#include <tf2items>

public Plugin:myinfo =
{
	name = "TF2 parachute",
	author = "ㅣ",
	description = "parachute parachute parachute parachute parachute",
	version = "1.0",
	url = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
}

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	if (StrEqual(classname, "tf_wearable"))
	{
		new Handle:hItemOverride = PrepareItemHandle(hItem, _, _, "640 ; 1.0");

		if (hItemOverride != INVALID_HANDLE)
		{
			hItem = hItemOverride;

			return Plugin_Changed;
		}
	}

	return Plugin_Continue;
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
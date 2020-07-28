#include <tf2_stocks>
#include <tf2items>
#include <tf2itemsinfo>

public OnPluginStart()
{
	RegConsoleCmd("b", bb);
}

public Action:bb(client, args)
{
	new Handle:info = CreateMenu(Menu_Information);
	SetMenuTitle(info, "일반 스캐터건");

	new String:classname[32], String:index[32], String:name[64];
	
	if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Scout)
	{
		for(new i = 13; i <= 1103; i++)
		{
			TF2II_GetItemClass(i, classname, sizeof(classname)); 
			TF2II_GetItemName(i, name, sizeof(name));
			
			if(StrEqual(classname, "tf_weapon_scattergun", false)) 
			{
				Format(index, sizeof(index), "%d", i);
				AddMenuItem(info, index, name); 
			}
		}
	}
	DisplayMenu(info, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}
public Menu_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
		decl String:info[64];
		GetMenuItem(menu, select, info, sizeof(info));
		
		PrintToChat(client, "\x03 %d", StringToInt(info));
		
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
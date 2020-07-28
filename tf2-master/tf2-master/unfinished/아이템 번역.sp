#include <tf2items>
#include <tf2itemsinfo>

new String:PrimaryConfig[120];

public OnPluginStart()
{
	BuildPath(Path_SM, PrimaryConfig, sizeof(PrimaryConfig), "configs/weapon_rent/aaaa.cfg");
	
	RegConsoleCmd("sm_ww", aaaa);
}

public Action:aaaa(client, args)
{
	new num = 200;
	
	new String:temp[64];
	TF2II_GetItemMlName(num, temp, sizeof(temp));

	decl String:Classname[64];
	
	new Handle:menu = CreateMenu(Menu_Information);
	new Handle:DB = CreateKeyValues("tra"); 
	
	SetMenuTitle(menu, "asd", client);
		
	FileToKeyValues(DB, PrimaryConfig);
	KvGetString(DB, temp, Classname, sizeof(Classname));
	PrintToChat(client, "%s",Classname);
	
	AddMenuItem(menu, Classname, Classname);

	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	KvRewind(DB);
	CloseHandle(DB);
	return Plugin_Handled;
}

public Menu_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{ 
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

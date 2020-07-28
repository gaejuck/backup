#include <tf2items>
#include <tf2_stocks>

new Float:option[MAXPLAYERS+1] = 0.0;

public OnPluginStart()
{
	RegAdminCmd("sm_pp", index, ADMFLAG_ROOT);
}

public OnClientDisconnected(client)
	option[client] = 0.0;

public Action:index(client, args)
{
	new Handle:info = CreateMenu(indexindex);
	SetMenuTitle(info, "발사체 타입 변경");
	AddMenuItem(info, "0", "제거");  
	AddMenuItem(info, "1", "총알");  
	AddMenuItem(info, "2", "로켓");  
	AddMenuItem(info, "3", "유탄");  
	AddMenuItem(info, "5", "주사기");  
	AddMenuItem(info, "6", "조명총");  
	AddMenuItem(info, "19", "화살");  
	AddMenuItem(info, "23", "석궁");  
	AddMenuItem(info, "12", "소도둑");  
	AddMenuItem(info, "17", "대포");   
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
} 

public indexindex(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		decl String:info[10];
		GetMenuItem(menu, select, info, sizeof(info))
		
		for(new i = 1; i <= MaxClients; i++)
		{
			if(IsClientInGame(i))
			{
				option[i] = StringToFloat(info);
				
				new TFClassType:class; class = TFClassType:GetRandomInt(1, 9);
				
				if(TF2_GetPlayerClass(i) != TFClassType:class)
				{
					TF2_SetPlayerClass(i, class);
					TF2_RegeneratePlayer(i);
				}
			}
		}

	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
	
	TF2Items_SetNumAttributes(hItem, 1);
		
	TF2Items_SetNumAttributes(hItem, 1);
	TF2Items_SetAttribute(hItem, 0, 280, option[client]);
	
	TF2Items_SetFlags(hItem, OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
}
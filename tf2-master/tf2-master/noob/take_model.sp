#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = {
	name		= "모델 플러그인",
	author	  = "ㅣ",
	description = "모델 매니저 플긴이 너무 길어서 간단하게 만든거임..ㅋ",
	version	 = "1.0",
	url		 = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
};

public OnPluginStart()
{
	RegConsoleCmd("mm", mm, "");
	HookEvent("player_spawn", PlayerSpawn);
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(IsFakeClient(client))
	{
		SetVariantString("models/player/soft_pyro.mdl");
		AcceptEntityInput(client, "SetCustomModel");
		SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1); 
	}
}

public Action:mm(client, args)
{
	new Handle:info = CreateMenu(Fuck_Model);
	SetMenuTitle(info, "장애인 모델 / Fuck model");
	AddMenuItem(info, "1", "모델 삭제 / model remove");  
	AddMenuItem(info, "1", "스카웃 / scout");  
	AddMenuItem(info, "1", "솔저 / soldier");  
	AddMenuItem(info, "1", "파이로 / pyro");  
	AddMenuItem(info, "1", "데모맨 / demoman");  
	AddMenuItem(info, "1", "헤비 / heavy");  
	AddMenuItem(info, "1", "엔지니어 / engineer");  
	AddMenuItem(info, "1", "메딕 / medic");  
	AddMenuItem(info, "1", "스나이퍼 / sniper");  
	AddMenuItem(info, "1", "스파이 / spy");  
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Fuck_Model(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		if(select == 0)
		{
			SetVariantString("");
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 0); 
			PrintToChat(client, "\x03모델 적용 해제");
		}
		else if(select == 1)
		{
			SetVariantString("models/playground/papyrus.mdl");
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1); 
			PrintToChat(client, "\x03모델 적용 완료");
		}
		
		else if(select == 2)
		{
			SetVariantString("models/player/soft_soldier.mdl");
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1); 
			PrintToChat(client, "\x03모델 적용 완료");
		}
		
		else if(select == 3)
		{
			SetVariantString("models/player/soft_pyro.mdl");
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
			PrintToChat(client, "\x03모델 적용 완료");
		}
		
		else if(select == 4)
		{
			SetVariantString("models/player/soft_demo.mdl");
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
			PrintToChat(client, "\x03모델 적용 완료");
		}
		
		else if(select == 5)
		{
			SetVariantString("models/player/soft_heavy.mdl");
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
			PrintToChat(client, "\x03모델 적용 완료");
		}
		
		else if(select == 6)
		{
			SetVariantString("models/player/soft_engineer.mdl");
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
			PrintToChat(client, "\x03모델 적용 완료");
		}
		
		else if(select == 7)
		{
			SetVariantString("models/player/soft_medic.mdl");
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
			PrintToChat(client, "\x03모델 적용 완료");
		}
		
		else if(select == 8)
		{
			SetVariantString("models/player/soft_sniper.mdl");
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
			PrintToChat(client, "\x03모델 적용 완료");
		}
		
		else if(select == 9)
		{
			SetVariantString("models/player/soft_spy.mdl");
			AcceptEntityInput(client, "SetCustomModel");
			SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
			PrintToChat(client, "\x03모델 적용 완료");
		}
	}
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
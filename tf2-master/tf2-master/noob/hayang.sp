public Plugin:myinfo =
{
	name = "[TF2] mad mad mad mad mad",
	author = "mad",
	description = "mad mad mad mad mad mad mad mad mad",
	version = "1.0",
	url = "http://steamcommunity.com/id/yh07/"
}

public OnPluginStart()
	RegAdminCmd("sm_mad", mad, ADMFLAG_KICK);

public Action:mad(client, args)
{
	new Handle:info = CreateMenu(Menu_mad);
	SetMenuTitle(info, "made by 하양이");
	AddMenuItem(info, "1", "지진");
	AddMenuItem(info, "2", "확대");
	AddMenuItem(info, "3", "로꾸꺼");
	AddMenuItem(info, "4", "길게~ 로꾸꺼");
	AddMenuItem(info, "5", "에임 존나 빨라짐");
	AddMenuItem(info, "6", "여긴 어디? 난 누구");
	AddMenuItem(info, "7", "중력");
	AddMenuItem(info, "8", "혹C 몰라 test");
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
}

public Menu_mad(Handle:menu, MenuAction:action, Client, select)
{
	if(action == MenuAction_Select)
	{
		for(new i = 1; i <= MaxClients; i++) //이거
		{
			if(AliveCheck(i))
			{
				SetClientFOV(i, GetEntProp(i, Prop_Send, "m_iDefaultFOV"));
				
				if(select == 0)
					Shake(i, 60.0, 250.0);
				if(select == 1)
					SetClientFOV(i, 60);
				if(select == 2)
					SetClientFOV(i, -60);
				if(select == 3)
					SetClientFOV(i, 500);
				if(select == 4)
					SetClientFOV(i, -0);
				if(select == 5)
					SetClientFOV(i, -70);
				if(select == 6)
				{
					SetEntityGravity(i, 99999.0);
					CreateTimer(30.0, Gravity, i);
				}
				if(select == 7)
				{
					SetEntityRenderColor(i, 0, 0, 0, 0);
				}
				else if(action == MenuAction_End)
				{
					CloseHandle(menu);
				}
			}
		}
	}
}

public Action:Gravity(Handle:timer, any:Client)
	SetEntityGravity(Client, 0.0)

stock Shake(Client, Float:Length, Float:Severity)
{
	new Handle:View_Message;
	View_Message = StartMessageOne("Shake", Client, 1);
	BfWriteByte(View_Message, 0);
	BfWriteFloat(View_Message, Severity);
	BfWriteFloat(View_Message, 10.0);
	BfWriteFloat(View_Message, Length);
	EndMessage();
}

SetClientFOV(Client, iAmount)
	SetEntProp(Client, Prop_Send, "m_iFOV", iAmount);
	
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
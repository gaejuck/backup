#define red 255, 0, 0, 255
#define orange 255, 127, 0, 255
#define yellow 255, 255, 0, 255
#define green 0, 255, 0, 255
#define blue 0, 0, 255, 255
#define nam 111, 0, 255, 255
#define purple 143, 0, 255, 255
#define white 255, 255, 255, 255

new bool:Hud[MAXPLAYERS+1] = false;

public OnPluginStart()
{
	RegConsoleCmd("sm_hud", admin_hud, "");
}

public OnClientPutInServer(client)
{
	Hud[client] = false;
}

public OnClientDisconnect(client)
{
	Hud[client] = false;
}

public Action:admin_hud(client, args)
{
	Hud[client] = true;

	if(args < 3)
	{
		PrintToChat(client, "\x03사용법 : !hud <색깔 0 - 7> <지속 시간 소수로> <말>");
		PrintToChat(client, "\x03색깔은 흰 빨 주 노 초 파 남 보 순으로 0 - 7임");
		return Plugin_Handled;
	}

	new String:Hud_Color[10], String:Hud_Time[10], String:text[256];
	GetCmdArg(1, Hud_Color, sizeof(Hud_Color));
	GetCmdArg(2, Hud_Time, sizeof(Hud_Time));
	GetCmdArg(3, text, sizeof(text));
	
	ChatAll(Hud_Color, Hud_Time, text);
	return Plugin_Handled;
}

stock ChatAll(String:color[], String:hold_time[], const String:message[])
{
	new Color = StringToInt(color);
	new Float:Hold_Time = StringToFloat(hold_time);

	if(Color == 0)
	{
		SetHudTextParams(0.06, -1.0, Hold_Time, white);
	}
	else if(Color == 1)
	{
		SetHudTextParams(0.06, -1.0, Hold_Time, red);
	}
	else if(Color == 2)
	{
		SetHudTextParams(0.06, -1.0, Hold_Time, orange);
	}
	else if(Color == 3)
	{
		SetHudTextParams(0.06, -1.0, Hold_Time, yellow);
	}
	else if(Color == 4)
	{
		SetHudTextParams(0.06, -1.0, Hold_Time, green);
	}
	else if(Color == 5)
	{
		SetHudTextParams(0.06, -1.0, Hold_Time, blue);
	}
	else if(Color == 6)
	{
		SetHudTextParams(0.06, -1.0, Hold_Time, nam);
	}
	else if(Color == 7)
	{
		SetHudTextParams(0.06, -1.0, Hold_Time, purple);
	}
	else if(Color >= 8)
	{
		SetHudTextParams(0.06, -1.0, Hold_Time, white);
	}
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsClientInGame(i) || IsFakeClient(i))
		{
			continue;
		}
		
		ShowHudText(i, 1, message);
	}
}

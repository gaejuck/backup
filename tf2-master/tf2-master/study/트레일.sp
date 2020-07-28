#include <sdktools>

//cfg 변수
new Handle:tcfg = INVALID_HANDLE
new String:CommandConfig[64];

//돈 변수와 파일 변수
new String:TrailCode[MAXPLAYERS+1][PLATFORM_MAX_PATH];

//트레일 변수
new beamfollowentity[MAXPLAYERS+1];
new bool:trail_menu_check[MAXPLAYERS+1] = false;
new bool:trail_check[MAXPLAYERS+1] = false;

new spawn[MAXPLAYERS+1] = 0;

public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	RegAdminCmd("st", command_menu, 0);
	RegAdminCmd("st2", command_menu2, 0);
	BuildPath(Path_SM, CommandConfig, sizeof(CommandConfig), "configs/trails.cfg");
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(trail_check[client] == true)
		CreateTrail(client);
	spawn[client] ++;
	PrintToChat(client, "%d", spawn[client]);
}

public Action:command_menu(client, args)
{
	new Handle:menu = CreateMenu(command_select); tcfg = CreateKeyValues("trails");
	decl String:serverName[64], String:path[64];
	new String:temp[64];
	 
	SetMenuTitle(menu, "트레일", client);
	AddMenuItem(menu, "1", "트레일 지우기");
	FileToKeyValues(tcfg, CommandConfig);
	KvGotoFirstSubKey(tcfg)
	do
	{
		KvGetSectionName(tcfg, serverName, sizeof(serverName));
		KvGetString(tcfg, "path", path, sizeof(path));
		new kill = KvGetNum(tcfg, "kill");
		
		Format(temp, sizeof(temp), "%s$%d", path, kill);
		AddMenuItem(menu, temp, serverName);
	}
	while (KvGotoNextKey(tcfg));
	
	KvRewind(tcfg);
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}


public command_select(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		if(select == 0)
		{
			PrintToChat(client, "\x07FFFFFF당신의 트레일을 제거 했습니다.");
			DeleteTrail(client);
			trail_menu_check[client] = false;
			trail_check[client] = false; //트레일 끔
			CloseHandle(tcfg); CloseHandle(menu);
		}
		
		decl String:info[256], String:aa[2][64];
		GetMenuItem(menu, select, info, sizeof(info));
		ExplodeString(info, "$", aa, 2, 64);
		Format(TrailCode[client], 64, "materials/trails/%s.vmt", aa[0]);
		
		new kill = StringToInt(aa[1])
		 
		if(spawn[client] >= kill) //허용
		{
			trail_check[client] = true;
			if(trail_menu_check[client] == false) //트레일을 처음 쓰나?
			{
				if(trail_check[client] == true) //트레일을 켰나?
				{
					CreateTrail(client);
					trail_menu_check[client] = true;
					CloseHandle(tcfg); CloseHandle(menu);
				}
			}
			else			//안 처음씀
			{
				if(trail_check[client] == true)
				{
					DeleteTrail(client); CreateTrail(client);
					trail_menu_check[client] = true;
					CloseHandle(tcfg); CloseHandle(menu);
				}
			}
		}
		else //비허용
		{
			PrintToChat(client, "%d킬 만큼 킬이 필요합니다.", kill);
			trail_check[client] = false;
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_Exit)
		{
			CloseHandle(tcfg); CloseHandle(menu);
		}
	} 
}
public Action:command_menu2(client, args)
{
	decl Float:Clientposition[3];

	GetClientAbsOrigin(client, Clientposition);
	Clientposition[2] = Clientposition[2] + 10.0;
				
	new String:positionstring[128], String:colorstring[128]; 
			
	Format(positionstring, 128, "%f %f %f", Clientposition[0], Clientposition[1], Clientposition[2]);
	Format(colorstring, 128, "%d %d %d %d", 255, 255, 255, 255);
			
	beamfollowentity[client] = CreateEntityByName("env_spritetrail");
	DispatchKeyValue(beamfollowentity[client],"Origin", positionstring);
	DispatchKeyValueFloat(beamfollowentity[client], "lifetime", 1.5); //트레일이 남아있는 시간(길이)을 설정 할 수 있습니다.
	DispatchKeyValueFloat(beamfollowentity[client], "startwidth", 50.0); // 트레일이 생성될때 크기를 설정 할 수 있습니다.
	DispatchKeyValueFloat(beamfollowentity[client], "endwidth", 4.0); // 트레일이 사라질때 크기를 설정 할 수 있습니다.
	DispatchKeyValue(beamfollowentity[client], "spritename", "materials/trails/ty2.vmt");
	DispatchKeyValue(beamfollowentity[client], "renderamt", "255");
	DispatchKeyValue(beamfollowentity[client], "rendercolor", colorstring);
	DispatchKeyValue(beamfollowentity[client], "rendermode", "5");
	DispatchSpawn(beamfollowentity[client]);

	SetEntPropFloat(beamfollowentity[client], Prop_Send, "m_flTextureRes", 0.05);
	SetEntPropFloat(beamfollowentity[client], Prop_Data, "m_flSkyboxScale", 1.0);

	SetVariantString("!activator");
	AcceptEntityInput(beamfollowentity[client], "SetParent", client);
	
	CreateTimer(5.0, ttimer, client);
}

public Action:CreateTrail(client)
{

	decl Float:Clientposition[3];

	GetClientAbsOrigin(client, Clientposition);
	Clientposition[2] = Clientposition[2] + 10.0;
				
	new String:positionstring[128], String:colorstring[128]; 
			
	Format(positionstring, 128, "%f %f %f", Clientposition[0], Clientposition[1], Clientposition[2]);
	Format(colorstring, 128, "%d %d %d %d", 255, 255, 255, 255);
			
	beamfollowentity[client] = CreateEntityByName("env_spritetrail");
	DispatchKeyValue(beamfollowentity[client],"Origin", positionstring);
	DispatchKeyValueFloat(beamfollowentity[client], "lifetime", 1.5);
	DispatchKeyValueFloat(beamfollowentity[client], "startwidth", 16.0);
	DispatchKeyValueFloat(beamfollowentity[client], "endwidth", 8.0); 
	DispatchKeyValue(beamfollowentity[client], "spritename", TrailCode[client]);
	DispatchKeyValue(beamfollowentity[client], "renderamt", "255");
	DispatchKeyValue(beamfollowentity[client], "rendercolor", colorstring);
	DispatchKeyValue(beamfollowentity[client], "rendermode", "5");
	DispatchSpawn(beamfollowentity[client]);

	SetEntPropFloat(beamfollowentity[client], Prop_Send, "m_flTextureRes", 0.05);
	SetEntPropFloat(beamfollowentity[client], Prop_Data, "m_flSkyboxScale", 1.0);

	SetVariantString("!activator");
	AcceptEntityInput(beamfollowentity[client], "SetParent", client);
}
//====================================================================================================//
stock DeleteTrail(client)
{
	if(IsValidEntity(beamfollowentity[client]) && beamfollowentity[client] != 0)
	{
		new String:entityclass[128];
		GetEdictClassname(beamfollowentity[client], entityclass, sizeof(entityclass));
			
		if(StrEqual(entityclass, "env_spritetrail"))
		{
			AcceptEntityInput(beamfollowentity[client], "Kill");
			beamfollowentity[client] = 0;
		}
	}
}

public Action:ttimer(Handle:timer, any:client)
	DeleteTrail(client);
#include <sourcemod>
#include <sdktools>
#include <friendly>

new String:strPath[PLATFORM_MAX_PATH];

public Plugin:myinfo = {
	name		= "tf2 teleport",
	author	  = "ㅣ",
	description = "텔포 텔포해",
	version	 = "3.7",
	url		 = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
};

public OnPluginStart()
{
	RegConsoleCmd("sm_te", TM);
	RegConsoleCmd("sm_pos", pos);
}

public OnConfigsExecuted()
{
	decl String:strMapName[64]; GetCurrentMap(strMapName, sizeof(strMapName));
	decl String:strMapFile[PLATFORM_MAX_PATH]; Format(strMapFile, sizeof(strMapFile), "%s.cfg", strMapName);
	ParseConfigurations(strMapFile);
}

public Action:TM(client, args)
{
	new Handle:menu = CreateMenu(Teleport_select);
	new Handle:DB = CreateKeyValues("Teleport");
	decl String:serverName[64], String:temp[64], Float:Pos[3];
	
	SetMenuTitle(menu, "이동할곳", client);
	FileToKeyValues(DB, strPath);
	KvGotoFirstSubKey(DB)
	do
	{
		KvGetSectionName(DB, serverName, sizeof(serverName));
		Pos[0] = KvGetFloat(DB, "x", 0.0);
		Pos[1] = KvGetFloat(DB, "y", 0.0);
		Pos[2] = KvGetFloat(DB, "z", 0.0);
		
		Format(temp, sizeof(temp), "%f*%f*%f", Pos[0], Pos[1], Pos[2]);
		
		AddMenuItem(menu, temp, serverName);
	}
	while (KvGotoNextKey(DB));
	
	KvRewind(DB);
	CloseHandle(DB);
	if(TF2Friendly_IsFriendly(client) == true)
	{
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	}
	else
		PrintToChat(client, "\x03프렌들리 상태에서만 텔레포트가 가능합니다.");
	return Plugin_Handled;
}

public Action:pos(client, args)
{
	new Float:Position[3];
	GetClientAbsOrigin(client, Position);
	PrintToChat(client, "\x03X: %f\nY: %f\nZ: %f", Position[0], Position[1], Position[2]);
	return Plugin_Handled;
}

public Teleport_select(Handle:menu, MenuAction:action, client, param2)
{
	if(action == MenuAction_Select)
	{
		decl String:info[192], String:aa[3][64];
		new Float:bb[3];
		
		GetMenuItem(menu, param2, info, sizeof(info));
		ExplodeString(info, "*", aa,3,64);
		
		bb[0] = StringToFloat(aa[0]);
		bb[1] = StringToFloat(aa[1]);
		bb[2] = StringToFloat(aa[2]);
		
		TeleportEntity(client, bb, NULL_VECTOR, NULL_VECTOR);
	}
	else if(action == MenuAction_Cancel)
	{
		if(param2 == MenuCancel_Exit)
		{
			CloseHandle(menu);
		}
	} 
}

bool:ParseConfigurations(String:strConfigFile[])
{
    // Parse configuration
	decl String:strFileName[PLATFORM_MAX_PATH];
	Format(strFileName, sizeof(strFileName), "configs/teleport/%s", strConfigFile);
	BuildPath(Path_SM, strPath, sizeof(strPath), strFileName);
	decl String:serverName[64], Float:Pos[3];
       
	// Try to parse if it exists
	LogMessage("%s 파일이 정상적으로 로드 되었습니다.", strPath);    
	if (FileExists(strPath, true))
	{
		new Handle:kvConfig = CreateKeyValues("Teleport");
		if (FileToKeyValues(kvConfig, strPath) == false) SetFailState("파일에 문제가 있습니다.");
		KvGotoFirstSubKey(kvConfig);
        
		// Parse the subsections
		do 
		{
			KvGetSectionName(kvConfig, serverName, sizeof(serverName));
			Pos[0] = KvGetFloat(kvConfig, "x", 0.0);
			Pos[1] = KvGetFloat(kvConfig, "y", 0.0);
			Pos[2] = KvGetFloat(kvConfig, "z", 0.0);
		}
		while (KvGotoNextKey(kvConfig));
            
		CloseHandle(kvConfig);
	}
}

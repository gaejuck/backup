#include <sourcemod>
#include <sdktools> 

//키밸류 zlqoffb
KvRewind //새로고침
FileExists //경로에 파일이 있나 체크
FileToKeyValues //경로에 존재하는파일속에서 키밸류 배열을 빼옴
KeyValuesToFile //파일을 다시 찾아서
CloseHandle //닫습니다

KeyValuesToFile(db, path) 이거 하면
"STEAM_0:0:106928083"
{
} 자동 생성댄다 쩔어 클로즈 핸들부분에 넣으면 되드라고

new String:WeaponConfig[120];
new Handle:DB;

public OnPluginStart()
{
	BuildPath(Path_SM, WeaponConfig, sizeof(WeaponConfig), "configs/test.cfg");
	RegConsoleCmd("sm_go", ban);
}
 
public Action:ban(client, args)
{
	if(!FileExists(WeaponConfig))
	{
		SetFailState("%s 파일이 없습니다!", WeaponConfig);
		return Plugin_Continue;
	}
	
	DB = CreateKeyValues("test"); 
	
	if(!FileToKeyValues(DB, WeaponConfig))
	{
		CloseHandle(DB);
		SetFailState("Improper structure for configuration file %s!", WeaponConfig);
		return Plugin_Continue;
	}
	
	new ab = KvGetNum(DB, "a");
	PrintToChat(client, "%d", ab);
	
	if(KvJumpToKey(DB,"number"))
	{
		new ad = KvGetNum(DB, "index");
		new cd = KvGetNum(DB, "index2");
		
		PrintToChat(client, "%d", ad);
		PrintToChat(client, "%d", cd);
		
		if(KvJumpToKey(DB,"number2"))
		{
			new Index3 = KvGetNum(DB, "index3");
			PrintToChat(client, "%d", Index3);
			KvGoBack(DB);
		}
		KvGoBack(DB);
	}
	KvRewind(DB);
	
	if(KvJumpToKey(DB,"number3"))
	{
		new Index = KvGetNum(DB, "index");
		new Index2 = KvGetNum(DB, "index2");
		
		PrintToChat(client, "%d", Index);
		PrintToChat(client, "%d", Index2);
		
		KvGoBack(DB);
	}
	KvRewind(DB);
	
	if(KvJumpToKey(DB,"number4"))
	{
		do
		{
			decl String:name[50];
			KvGetSectionName(DB, name, sizeof(name));
			new Index = KvGetNum(DB, "index");
			PrintToChat(client, "%d", Index);
		}
		while(KvGotoNextKey(DB));
		KvGoBack(DB);
	}
	KvRewind(DB);
	CloseHandle(DB);
	
	
	return Plugin_Handled;
}

public Action:PrimaryWeapon(client)
{
	decl String:Classname[64], String:name[50];
	new String:temp[256];
	
	menu = CreateMenu(Primary_weapon_select);
	new Handle:DB = CreateKeyValues("custom_weapon"); 
	
	SetMenuTitle(menu, "무기고르삼", client);
		
	FileToKeyValues(DB, PrimaryConfig);
	if(KvGotoFirstSubKey(DB))
	{
		do
		{
			KvGetSectionName(DB, name, sizeof(name));
			KvGetString(DB, "classname", Classname, sizeof(Classname));
			new Index = KvGetNum(DB, "index", 0);
			KvGetString(DB, "class", class, sizeof(class));
			
			Format(temp, sizeof(temp), "%s*%d*%d*%d*%s", Classname,  Index, Level, Qual, Attribute);

			AddMenuItem(menu, temp, name);
		}
		while(KvGotoNextKey(DB));
		
		KvGoBack(DB);
	}
	
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	KvRewind(DB);
	CloseHandle(DB);
	return Plugin_Handled;
}
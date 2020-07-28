#pragma semicolon 1

#include <sourcemod>

#define PLUGIN_VERSION "1.0.0.2"

public Plugin:myinfo = 
{
	name = "Command Locale",
	author = "javalia",
	description = "let users able to use localized command in chat",
	version = PLUGIN_VERSION,
	url = "http://www.sourcemod.net/"
};

ConVar cvStrictConversion;
ConVar cvCmdType;
StringMap ConfigRoot;

public void OnPluginStart(){

	CreateConVar("commandlocale_version", PLUGIN_VERSION, "plugin version", FCVAR_DONTRECORD);
	cvStrictConversion = CreateConVar("commandlocale_strictconversion", "1", "0 = consider chat as a command even it does not start with ! character");
	cvCmdType = CreateConVar("commandlocale_cmdtype", "1", "1 = run cmd through say cmd, 0 = run cmd as a console cmd, any other value will stop plugin from working");
	ConfigRoot = new StringMap();
	
	int langcount = GetLanguageCount();
	char code[64], name[64];
	for(int i = 0; i < langcount; i++){
	
		GetLanguageInfo(i, code, 64, name, 64);
		ConfigRoot.SetValue(code, new StringMap(), false);
		
	}
	
}

public void OnPluginEnd(){

	int langcount = GetLanguageCount();
	char code[64], name[64];
	for(int i = 0; i < langcount; i++){
	
		GetLanguageInfo(i, code, 64, name, 64);
		StringMap LangConvertMap;
		ConfigRoot.GetValue(code, LangConvertMap);
		delete LangConvertMap;
		
	}

	delete ConfigRoot;
	
}

public void OnMapStart(){

	AutoExecConfig();
	
	int langcount = GetLanguageCount();
	char code[64], name[64];
	for(int i = 0; i < langcount; i++){
	
		GetLanguageInfo(i, code, 64, name, 64);
		StringMap LangConvertMap;
		ConfigRoot.GetValue(code, LangConvertMap);
		LangConvertMap.Clear();
		
	}
	
	KeyValues configbuffer = new KeyValues("commandlocale");
	char path[256];
	BuildPath(Path_SM, path, 256, "/configs/commandlocale/commandlocale.txt");
	configbuffer.ImportFromFile(path);
	
	if(configbuffer.GotoFirstSubKey(false)){
		
		char cmdname[256];
		
		do{
		
			configbuffer.GetSectionName(cmdname, 256);
			
			if(configbuffer.GotoFirstSubKey(false)){
			
				char localecode[256], localestring[256];
				
				do{
				
					configbuffer.GetSectionName(localecode, 256);
					configbuffer.GetString(NULL_STRING, localestring, 256);
					StringMap LangConvertMap;
					ConfigRoot.GetValue(localecode, LangConvertMap);
					LangConvertMap.SetString(localestring, cmdname);
					
				}while(configbuffer.GotoNextKey(false));
				
				configbuffer.GoBack();
				
			}
			
		}while(configbuffer.GotoNextKey(false));
		
	}
	
	delete configbuffer;
	
}

public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs){
	
	char buffer[2][256];//2 is enough...
	char cmdcheck[256];
	ExplodeString(sArgs, " ", buffer, 2, 256, true);
	bool needconvert = false;
	bool slash = false;
	
	if(client != 0){
		
		if(StrContains(buffer[0], "!") == 0)
		{
			strcopy(cmdcheck, 256, buffer[0]);
			ReplaceStringEx(cmdcheck, 256, "!", "sm_");
			slash = false;
			if(!CommandExists(cmdcheck[0])) needconvert = true;
		}
		
		else if(StrContains(buffer[0], "/") == 0)
		{
			strcopy(cmdcheck, 256, buffer[0]);
			ReplaceStringEx(cmdcheck, 256, "/", "sm_");
			if(!CommandExists(cmdcheck[0])) needconvert = true;
			slash = true;
		}
		
		else if(cvStrictConversion.IntValue == 0) needconvert = true;
		
		if(needconvert){
			
			char langcode[256], langname[256], cmdstring[256];
			GetLanguageInfo(GetClientLanguage(client), langcode, 256, langname, 256);
			StringMap LangConvertMap;
			ConfigRoot.GetValue(langcode, LangConvertMap);
			if(LangConvertMap.GetString(buffer[0], cmdstring, 256))
			{
				if(cvCmdType.IntValue == 1)
				{
					if(slash)
					{
						ReplaceStringEx(cmdstring, 256, "sm_", "/");
						FakeClientCommandEx(client, "say %s %s", cmdstring, buffer[1]);
						return Plugin_Handled;
					}
					else
					{
						ReplaceStringEx(cmdstring, 256, "sm_", "!");
						FakeClientCommandEx(client, "say %s %s", cmdstring, buffer[1]);
					}
				}
				else if(cvCmdType.IntValue == 0){
				
					FakeClientCommandEx(client, "%s %s", cmdstring, buffer[1]);
				
				}
			}
			
		}
		
	}
	return Plugin_Continue;

}

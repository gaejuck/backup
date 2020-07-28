#include <sourcemod>
#include <sdktools>

public Plugin:myinfo =
{
	name = "ABC_Downloader",
	author = "ABCDE",
	description = "Download all files in folder writed in list",
	version = "1.4",
	url = "http://cafe.naver.com/sourcemulti"
}

// file where path of files listed
new Handle:g_hConfig = INVALID_HANDLE;
// handle for cvar
new Handle:g_hEnable_Debug = INVALID_HANDLE;

public OnPluginStart()
{
	g_hEnable_Debug = CreateConVar("Enable_Debug", "1", "Whether enable debug or not");
}

public OnMapStart()
{
	g_hConfig = OpenFile("addons/sourcemod/configs/abc_downloader.ini", "r");
	
	if(g_hConfig == INVALID_HANDLE)
	{
		PrintToServer("[ABC_Downloader] Couldn't open abc_downloader.ini");
	}
	else
	{
		if(GetConVarBool(g_hEnable_Debug))
		{
			PrintToServer("[ABC_Downloader] abc_downloader.ini has been opened successfully.");
		}
		new String:Line[512];
		
		while(ReadFileLine(g_hConfig, Line, sizeof(Line)))
		{
			TrimString(Line);
			
			if(strlen(Line))
			{
				ABCDEFGHIJKLMNOPQRSTUVWXYZ(Line);
			}
		}
	}
}

stock ABCDEFGHIJKLMNOPQRSTUVWXYZ(const String:sDirectory[]) 
{
	decl String:sFilename[128], String:sPath[256];
	new Handle:hDirectory = OpenDirectory(sDirectory);
	decl FileType:Type;
	
	if(hDirectory != INVALID_HANDLE)
	{		
		while(ReadDirEntry(hDirectory, sFilename, sizeof(sFilename), Type))
		{
			if(Type == FileType_Directory)
			{
				if(FindCharInString(sFilename, '.') == -1)
				{
					Format(sPath, sizeof(sPath), "%s/%s", sDirectory, sFilename);
					ABCDEFGHIJKLMNOPQRSTUVWXYZ(sPath);
				}
			}
			else if(Type == FileType_File)
			{
				Format(sPath, sizeof(sPath), "materials/trails/");
				
				new iPos = FindCharInString(sPath, '.', true);
				
				if(iPos != -1)
				{
					if(FileExists(sPath))
					{
						AddFileToDownloadsTable(sPath);
						
						PrecacheModel(sPath, true);
					}
					else
					{
						PrintToServer("[ABC_Downloader] Couldn't find the file : %s", sPath);
					}
				}
			}
		}
		CloseHandle(hDirectory);
		hDirectory = INVALID_HANDLE;
	}
}
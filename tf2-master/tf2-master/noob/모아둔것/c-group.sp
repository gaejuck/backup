#include <colors>

public Steam_GroupStatusResult(client, groupAccountID, bool:groupMember, bool:groupOfficer)
{
    if (groupAccountID == 5271158) //This is the group we queried.
    {
        if (groupOfficer)
        {
            PrintToChat(client, "[SM] You are an officer of this group.");
        }
        else if (groupMember)
        {
            PrintToChat(client, "[SM] You are a member of this group."); //validation
            RegisterExecute(client);
        }
        else
        {
            PrintToChat(client, "[SM] You are not part of this group."); //validation
            //Put Error MSG here
        }
    }
}  

RegisterExecute(client)
{
    decl String:steamid[64];
    GetClientAuthString(client, steamid, sizeof(steamid));

    decl String:name[32];
    GetClientName(client, name, sizeof(name));
    
    new String:szFile[256];
    BuildPath(Path_SM, szFile, sizeof(szFile), "configs/admins_simple.ini");
        
    new Handle:File = OpenFile(szFile, "a");
    WriteFileLine(File, "\"%s\" \"1:@members\"     // %s", steamid, name);
    CloseHandle(File);
        
    ServerCommand("sm_rc");


    CPrintToChatAll("{green}[{orange}MemberSystem{green}]{team} %s{orange} has just applied for Member!", name);
}  

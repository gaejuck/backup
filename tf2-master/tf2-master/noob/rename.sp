#include <sdktools> 

public OnPluginStart()
{
	RegConsoleCmd("sm_ba", aaaa, "");
}

public Action:aaaa(client, args)
{
	if (IsFakeClient(client))
		return Plugin_Handled;
		
	decl String:NewName[MAX_NAME_LENGTH];
	FormatEx(NewName, MAX_NAME_LENGTH, "ㅁ");
	SetClientInfo(client, "name", NewName);
	return Plugin_Handled;
}

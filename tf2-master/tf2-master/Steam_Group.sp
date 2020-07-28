#include <sdktools>
#include <sdkhooks>
#include <steamtools>

new bool:bIsInGroup[MAXPLAYERS+1] = false;

public OnPluginStart()
{
	RegAdminCmd("sm_test", test, 0);
}

public OnClientPutInServer(client)
{
	bIsInGroup[client] = false;
	CreateTimer(5.0, abc, client);
}
	
public Action:abc(Handle:timer, any:client)
{
	Steam_RequestGroupStatus(client, 26174414);
}

public Action:test(client, args)
{
	if(bIsInGroup[client])
		PrintToChat(client, "aa");
	return Plugin_Handled;
}

public Steam_GroupStatusResult(client, groupID, bool:bIsMember, bool:bIsOfficer)
{
	if(groupID == 26174414) {
		if(AliveCheck(client))
		{
			bIsInGroup[client] = bIsMember;
			if(bIsMember)
			{
				bIsInGroup[client] = true;
			}
			else
			{
				bIsInGroup[client] = false;
			}
		}
	}
}


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

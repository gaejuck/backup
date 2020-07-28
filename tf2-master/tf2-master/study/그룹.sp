#include <steamtools>

new bool:GroupCheck[MAXPLAYERS+1] = false;
new bool:bIsInGroup[MAXPLAYERS+1] = false;

public OnClientPostAdminCheck(client)
{
	
	bIsInGroup[client] = false;
	GroupCheck[client] = false;
	
	CreateTimer(5.0, abc, client);
}

public Action:abc(Handle:timer, any:client)
{
	Steam_RequestGroupStatus(client, 22947835);
}

public Steam_GroupStatusResult(client, groupID, bool:bIsMember, bool:bIsOfficer)
{
	if(groupID == 22947835) {
		if(IsValidClient(client))
		{
			bIsInGroup[client] = bIsMember;
			if(bIsMember)
			{
				GroupCheck[client] = true;
			}
			else
			{
				GroupCheck[client] = false;
			}
		}
	}
}

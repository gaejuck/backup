#include <sdkhooks> 
#include <sdktools> 

new bool:aaa[MAXPLAYERS+1] = false;

public OnPluginStart()
{
	RegConsoleCmd("sm_b", b);
	RegConsoleCmd("sm_br", br);
}

public OnClientPutInServer(client){
	aaa[client] = false;
	SDKHook(client, SDKHook_PostThinkPost, OnPostThinkPost);
}
public OnClientDisconnect(client){
	aaa[client] = false;
}

public Action:b(client, args)
{
	if(aaa[client] == false) 
	{
		aaa[client] = true; 
		ReplyToCommand(client, "\x04ON");
	}
	else if(aaa[client] == true) 
	{
		aaa[client] = false;
		ReplyToCommand(client, "\x04OFF");
	}
}

public Action:br(client, args)
{
	for(new i = 1; i <= MaxClients; i++)
	{
		if(PlayerCheck(i))
		{
			SDKHook(i, SDKHook_PostThinkPost, OnPostThinkPost);
		}
	}
	
	if(PlayerCheck(client))
	{
		PrintToChat(client, "리로드댓음");
	}
}

public OnPostThinkPost(client)
{
	new entity = -1; 
	while((entity=FindEntityByClassname(entity, "tf_projectile_*"))!=INVALID_ENT_REFERENCE)
	{
		if(IsValidEntity(entity))
		{
			if(PlayerCheck(client))
			{
				if(client < 1)
				{
					return;
				}
				if(aaa[client] == true)
				{
					SetEntityMoveType(entity, MOVETYPE_NONE);
				}
				else
				{
					SetEntityMoveType(entity, MOVETYPE_FLY);
				}
			}
		}
	}
}

stock bool:PlayerCheck(Client){
	if(Client > 0 && Client <= MaxClients){
		if(IsClientConnected(Client) == true){
			if(IsClientInGame(Client) == true){
				return true;
			}
		}
	}
	return false;
}




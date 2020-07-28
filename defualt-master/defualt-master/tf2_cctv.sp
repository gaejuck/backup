#include <sdktools>

//망원경 변수
new bool:sp[MAXPLAYERS+1] = false;
new soochi[MAXPLAYERS+1];

//시점 변수
new bool:sizum[MAXPLAYERS+1] = false;
new String:target_user[256];

public Plugin:myinfo = {
	name		= "[TF2] CCTV",
	author	  = "ㅣ",
	description = "스나이퍼 줌보다 더 선명한 망원경 and 어디서 뭘 하든 볼수 있지!",
	version	 = "1.0",
	url		 = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
};

public OnPluginStart()
{
	RegConsoleCmd("sm_scope", scope, "망원경");
	RegConsoleCmd("sm_go", Command_name, "시점");
}

 
public OnClientPutInServer(client)
{
	sizum[client] = false;
	sp[client] = false;
}

public OnClientDisconnect(client)
{
	if(sizum[client] == true)
	{
		sizum[client] = false;
	} 
	if(sp[client] == true)
	{
		sp[client] = false;
	}
}

public Action:scope(client, args)
{
	if(args != 1)
	{
		ReplyToCommand(client, "\x03sm_scope <1~70>", client);
		return Plugin_Handled;
	}
		
	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	new amount = StringToInt(arg);
		
	soochi[client] = amount;
		
	if(amount < 1 || amount > 70)
	{
		ReplyToCommand(client, "\x03 1 ~ 70", client);
		return Plugin_Handled;
	}
		
	if(PlayerCheck(client))
	{
		if(sizum[client] == true)
		{
			sizum[client] = false;
		}
			
		PrintToChat(client, "\x03적용 완료", client);
		sp[client] = true;
	}
	return Plugin_Handled;
}

public Action:Command_name(client, args)
{
	decl String:arg[65];
	new bool:HasTarget = false;
		
	if(args < 1)
	{
		ReplyToCommand(client, "\x03sm_go <name>", client);
		return Plugin_Handled;
	}
			
	GetCmdArg(1, arg, sizeof(arg));
			
	HasTarget = true;	
		
	decl String:target_name[MAX_TARGET_LENGTH];
		
	if (HasTarget)
	{
		decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
			
		if ((target_count = ProcessTargetString(
				arg,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_CONNECTED,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
		{
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}
			
		for (new i = 0; i < target_count; i++)
		{
			if(PlayerCheck(client))
			{
				if(sp[client] == true)
				{
					sp[client] = false;
				}
					
				sizum[client] = true;
				target_user[client] = target_list[i];
				PrintToChat(client, "\x03적용완료", client);
			} 
		}
	}
	return Plugin_Handled;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(sp[client] == true)
	{
		SetClientFOV(client, GetEntProp(client, Prop_Send, "m_iDefaultFOV"));
		if(buttons & IN_ATTACK3)
		{ 
			SetClientFOV(client, soochi[client]);
		}
		else
		{
			SetClientFOV(client, 0);
		} 
	} 
	else if(sizum[client] == true)
	{
		if(buttons & IN_ATTACK3)
		{ 
			SetVariantInt(1);
			AcceptEntityInput(client, "SetForcedTauntCam");
			SetClientViewEntity(client, target_user[client]);
		}
		else
		{
			SetClientViewEntity(client, client);
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

SetClientFOV(Client, iAmount)
{
	SetEntProp(Client, Prop_Send, "m_iFOV", iAmount);
}

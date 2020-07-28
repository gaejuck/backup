#include <tf2attributes>
#include <tf2_stocks>

new bool:par[MAXPLAYERS+1] = false;
new bool:boom[MAXPLAYERS+1] = false;
new bool:pip[MAXPLAYERS+1] = false;
new bool:vis[MAXPLAYERS+1] = false;
new bool:air[MAXPLAYERS+1] = false;
new bool:roc[MAXPLAYERS+1] = false;
new bool:tor[MAXPLAYERS+1] = false;
new bool:he[MAXPLAYERS+1] = false;
new bool:tau[MAXPLAYERS+1] = false;
new bool:vos[MAXPLAYERS+1] = false;
new bool:wea[MAXPLAYERS+1] = false;
new bool:med[MAXPLAYERS+1] = false;
new bool:kill[MAXPLAYERS+1] = false;
new bool:air2[MAXPLAYERS+1] = false;
new bool:pai[MAXPLAYERS+1] = false;

public OnPluginStart()
{
	RegConsoleCmd("sm_par", parachute);
	RegConsoleCmd("sm_boom", booooom);
	RegConsoleCmd("sm_pip", pipboy);
	RegConsoleCmd("sm_vis", vision);
	RegConsoleCmd("sm_air", airblast);
	RegConsoleCmd("sm_rocket", rocket);
	RegConsoleCmd("sm_body", torso);
	RegConsoleCmd("sm_head", head);
	RegConsoleCmd("sm_taunt", taunt);
	RegConsoleCmd("sm_voice", voice);
	RegConsoleCmd("sm_weapon", weapon);
	RegConsoleCmd("sm_shield", medic);
	RegConsoleCmd("sm_kills", killstrak);
	RegConsoleCmd("sm_paint", paint);
}

public Action:parachute(client, args)
{
	if(PlayerCheck(client))
	{
		if(par[client] == false) 
		{
			par[client] = true; 
			TF2Attrib_SetByDefIndex(client, 640, 1.0);
			PrintToChat(client, "\x03낙하산 On");
		}
			
		else if(par[client] == true)
		{
			par[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 640);
			PrintToChat(client, "\x03낙하산 Off");
		}
	}
	return Plugin_Handled;
}

public Action:booooom(client, args)
{
	if(PlayerCheck(client))
	{
		if(boom[client] == false) 
		{
			boom[client] = true; 
			TF2Attrib_SetByDefIndex(client, 521, 1.0);
			PrintToChat(client, "\x03폭발 On");
		}
			
		else if(boom[client] == true)
		{
			boom[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 521);
			PrintToChat(client, "\x03폭발 Off");
		}
	}
	return Plugin_Handled;
}

public Action:pipboy(client, args)
{
	if(PlayerCheck(client))
	{
		if(TF2_GetPlayerClass(client) == TFClassType:TFClass_Engineer)
		{
			if(pip[client] == false) 
			{
				pip[client] = true; 
				TF2Attrib_SetByDefIndex(client, 295, 1.0);
				PrintToChat(client, "\x03핍 보이 On");
			}
				
			else if(pip[client] == true)
			{
				pip[client] = false;
				TF2Attrib_RemoveByDefIndex(client, 295);
				PrintToChat(client, "\x03핍 보이 Off");
			}
		}
		else	
			PrintToChat(client, "\x03엔지니어만 가능한 명령어입니다.");
	}
	return Plugin_Handled;
}

public Action:vision(client, args)
{
	if(PlayerCheck(client))
	{
		if(vis[client] == false) 
		{
			vis[client] = true; 
			TF2Attrib_SetByDefIndex(client, 406, 1.0);
			PrintToChat(client, "\x03파이로 고글 효과 On");
		}
				
		else if(vis[client] == true)
		{
			vis[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 406);
			PrintToChat(client, "\x03파이로 고글 효과 Off");
		}
	}
	return Plugin_Handled;
}

public Action:airblast(client, args)
{
	if(PlayerCheck(client))
	{
		if(air[client] == false) 
		{
			air[client] = true; 
			TF2Attrib_SetByDefIndex(client, 254, 4.0);
			PrintToChat(client, "\x03노 인붕 On");
		}
				
		else if(air[client] == true)
		{
			air[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 254);
			PrintToChat(client, "\x03노 인붕 Off");
		}
	}
	return Plugin_Handled;
}

public Action:rocket(client, args)
{
	if(PlayerCheck(client))
	{
		if(roc[client] == false) 
		{
			roc[client] = true; 
			TF2Attrib_SetByDefIndex(client, 280, 2.0);
			PrintToChat(client, "\x03로켓 On");
		}
				
		else if(roc[client] == true)
		{
			roc[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 280);
			PrintToChat(client, "\x03로켓 Off");
		}
	}
	return Plugin_Handled;
}

public Action:torso(client, args)
{
	if(PlayerCheck(client))
	{
		if(tor[client] == false) 
		{
			tor[client] = true; 
			TF2Attrib_SetByDefIndex(client, 620, 2.0);
			PrintToChat(client, "\x03몸 크기 2x On");
		}
				
		else if(tor[client] == true)
		{
			tor[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 620);
			PrintToChat(client, "\x03몸 크기 2x Off");
		}
	}
	return Plugin_Handled;
}

public Action:head(client, args)
{
	if(PlayerCheck(client))
	{
		if(he[client] == false) 
		{
			he[client] = true; 
			TF2Attrib_SetByDefIndex(client, 444, 2.0);
			PrintToChat(client, "\x03머리 크기 2x On");
		}
				
		else if(he[client] == true)
		{
			he[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 444);
			PrintToChat(client, "\x03머리 크기 2x Off");
		}
	}
	return Plugin_Handled;
}

public Action:taunt(client, args)
{
	if(PlayerCheck(client))
	{
		if(tau[client] == false) 
		{
			tau[client] = true; 
			TF2Attrib_SetByDefIndex(client, 201, 0.5);
			PrintToChat(client, "\x03도발 속도 slow On");
		}
				
		else if(tau[client] == true)
		{
			tau[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 201);
			PrintToChat(client, "\x03도발 속도 slow Off");
		}
	}
	return Plugin_Handled;
}

public Action:voice(client, args)
{
	if(PlayerCheck(client))
	{
		if(vos[client] == false) 
		{
			vos[client] = true; 
			TF2Attrib_SetByDefIndex(client, 2048, 3.0);
			PrintToChat(client, "\x03애기 목소리 On");
		}
				
		else if(vos[client] == true)
		{
			vos[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 2048);
			PrintToChat(client, "\x03애기 목소리 Off");
		}
	}
	return Plugin_Handled;
}

public Action:weapon(client, args)
{
	if(PlayerCheck(client))
	{
		if(wea[client] == false) 
		{
			wea[client] = true; 
			TF2Attrib_SetByDefIndex(client, 699, 3.0);
			PrintToChat(client, "\x03무기 크기 x2 On");
		}
				
		else if(wea[client] == true)
		{
			wea[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 699);
			PrintToChat(client, "\x03무기 크기 x2 Off");
		}
	}
	return Plugin_Handled;
}

public Action:medic(client, args)
{
	if(PlayerCheck(client))
	{
		if(med[client] == false) 
		{
			med[client] = true; 
			TF2Attrib_SetByDefIndex(client, 499, 1.0);
			PrintToChat(client, "\x03메딕 쉴드 On");
		}
				
		else if(med[client] == true)
		{
			med[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 499);
			PrintToChat(client, "\x03메딕 쉴드 Off");
		}
	}
	return Plugin_Handled;
}

public Action:killstrak(client, args)
{
	if(PlayerCheck(client))
	{
		if(kill[client] == false) 
		{
			kill[client] = true; 
			TF2Attrib_SetByDefIndex(client, 2025, 1.0);
			PrintToChat(client, "\x03킬스트릭 연속처치 On");
		}
				
		else if(kill[client] == true)
		{
			kill[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 2025);
			PrintToChat(client, "\x03킬스트릭 연속처치 Off");
		}
	}
	return Plugin_Handled;
}

public Action:airblast2(client, args)
{
	if(PlayerCheck(client))
	{
		if(air2[client] == false) 
		{
			air2[client] = true; 
			TF2Attrib_SetByDefIndex(client, 256, 0.1);
			PrintToChat(client, "\x03붕붕이 공속 On");
		}
				
		else if(air2[client] == true)
		{
			air2[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 256);
			PrintToChat(client, "\x03붕붕이 공속 Off");
		}
	}
	return Plugin_Handled;
}

public Action:paint(client, args)
{
	if(PlayerCheck(client))
	{
		if(pai[client] == false) 
		{
			pai[client] = true; 
			TF2Attrib_SetByDefIndex(client, 142, 15185211.0);
			PrintToChat(client, "\x03할로윈 페인트 On");
		}
				
		else if(pai[client] == true)
		{
			pai[client] = false;
			TF2Attrib_RemoveByDefIndex(client, 1004);
			PrintToChat(client, "\x03할로윈 페인트 Off");
		}
	}
	return Plugin_Handled;
}

public OnClientDisconnect(client)
{
	if(par[client] == true)
		par[client] = false;
		
	if(boom[client] == true)
		boom[client] = false;
		
	if(pip[client] == true)
		pip[client] = false;
		
	if(vis[client] == true)
		vis[client] = false;
		
	if(air[client] == true)
		air[client] = false;
		
	if(roc[client] == true)
		roc[client] = false;
		
	if(tor[client] == true)
		tor[client] = false;
		
	if(he[client] == true)
		he[client] = false;
		
	if(tau[client] == true)
		tau[client] = false;
		
	if(vos[client] == true)
		vos[client] = false;
		
	if(wea[client] == true)
		wea[client] = false;
	
	if(med[client] == true)
		med[client] = false;
		
	if(kill[client] == true)
		kill[client] = false;
		
	if(pai[client] == true)
		pai[client] = false;
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
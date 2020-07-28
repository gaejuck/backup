#include <sourcemod>
#include <sdktools>

#define SHOW (0x0010)

#define NAME1 "ㅋ"
#define NAME2 "ㅇㅇ"
#define NAME3 "ㅇ?"
#define NAME4 "?"
#define NAME5 "네"
#define NAME6 "님"
#define NAME7 "ㄴㄴ"
#define NAME8 "아이유"

public Plugin:myinfo =
{
	name = "[TF2] Trap Chat",
	author = "TAKE 2",
	description = "TAKE 2 (IU)",
	version = "1.0",
	url = "smf"
}


public OnPluginStart()
{
	RegConsoleCmd("say", SayEvent, "ㅋ");
}

// public OnMapStart()
// {
    // AddFileToDownloadsTable("materials/image/iu_v9.vmt");
    // AddFileToDownloadsTable("materials/image/iu_v9.vtf");
// }

public Action:SayEvent(Client, args)
{
	new String:Msg[256];
	GetCmdArgString(Msg, sizeof(Msg));
	Msg[strlen(Msg)-1] = '\0';
	
	if(StrEqual(Msg[1], NAME1, false))
	{
		BlindClient(Client);
	}
	
	if(StrEqual(Msg[1], NAME2, false))
	{
		Shake(Client, 60.0, 250.0);
		PrintHintText(Client, "함정채팅 : 1분 응한 댓가다!");
		PrintToChat(Client, "\x04함정채팅 : 1분 응한 댓가다!");
	}
	
	if(StrEqual(Msg[1], NAME3, false))
	{
		SetClientFOV(Client, GetEntProp(Client, Prop_Send, "m_iDefaultFOV"));
		SetClientFOV(Client, 60);
		PrintHintText(Client, "함정채팅 : 느낌이 어때?");
		PrintToChat(Client, "\x04 함정채팅 : 느낌이 어때?");
	}
	if(StrEqual(Msg[1], NAME4, false))
	{
		SetClientFOV(Client, GetEntProp(Client, Prop_Send, "m_iDefaultFOV"));
		SetClientFOV(Client, 160);
		PrintHintText(Client, "함정채팅 : 느낌이 어때? 크흥");
		PrintToChat(Client, "\x04 함정채팅 : 느낌이 어때? 크흥");
	}
	 
	if(StrEqual(Msg[1], NAME5, false))
	{	
		SetEntityGravity(Client, 99999.0);
		PrintHintText(Client, "함정채팅 : 점프하지마랏!");
		PrintToChat(Client, "\x04 함정채팅 : 점프하지마랏!");
	}
	
	if(StrEqual(Msg[1], NAME6, false))
	{	
		SetEntityMoveType(Client, MOVETYPE_NONE);
		PrintHintText(Client, "함정채팅 : 움직이지마랏!");
		PrintToChat(Client, "\x04 함정채팅 : 움직이지마랏!");
	}
	
	if(StrEqual(Msg[1], NAME7, false))
	{
		SetClientFOV(Client, GetEntProp(Client, Prop_Send, "m_iDefaultFOV"));
		SetClientFOV(Client, 430);
		PrintHintText(Client, "함정채팅 : 3인칭 해봐");
		PrintToChat(Client, "\x04 함정채팅 : 3인칭 해봐");
	}
	// if(StrEqual(Msg[1], NAME8, false))
	// {		
		// SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & (~FCVAR_CHEAT));
		// ClientCommand(Client,"r_screenoverlay image/iu_v9.vmt");
		// SetCommandFlags("r_screenoverlay", GetCommandFlags("r_screenoverlay") & FCVAR_CHEAT);
		
		// PrintHintText(Client, "함정채팅 : 아이유 짱!");
		// PrintToChat(Client, "\x04 함정채팅 : 아이유 짱!");
		// CreateTimer(10.0, IUtimer, Client);
	// }
}

// public Action:IUtimer(Handle:timer, any:Client)
// {
	 // ClientCommand(Client,"r_screenoverlay \"\"")
// }

public BlindClient(Client)
{
	new Handle:msg;
		
	msg = StartMessageOne("Fade", Client);
	BfWriteShort(msg, 5000);
	BfWriteShort(msg, 5000); // Duration
	BfWriteShort(msg, SHOW);
	BfWriteByte(msg, 0);
	BfWriteByte(msg, 0);
	BfWriteByte(msg, 0);
	BfWriteByte(msg, 255);
	EndMessage();
	PrintHintText(Client, "비웃은 댓가다!!");
}

stock Shake(Client, Float:Length, Float:Severity)
{
	new Handle:View_Message;
	View_Message = StartMessageOne("Shake", Client, 1);
	BfWriteByte(View_Message, 0);
	BfWriteFloat(View_Message, Severity);
	BfWriteFloat(View_Message, 10.0);
	BfWriteFloat(View_Message, Length);
	EndMessage(); 
	PrintHintText(Client, "비웃은 댓가다!!");
}

SetClientFOV(Client, iAmount)
{
	SetEntProp(Client, Prop_Send, "m_iFOV", iAmount);
}
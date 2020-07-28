public OnPluginStart()
{
	AddCommandListener(DoTaunt, "taunt");
}
public Action:DoTaunt(client, const String:command[], argc)
{}

public Action OnClientCommandKeyValues(client, KeyValues:kv)
{

	if(StrEqual(strCmd, "+use_action_slot_item_server") && 인게임 체크 또는 bool체크) //h키
	{
		//내용
		//아닐경우 리턴 스탑
	}
	if(StrEqual(strCmd, "kill"))
	{}
	return Plugin_Continue;
}

new buttons = GetClientButtons(client);
if(buttons & IN_ATTACK)


new bool:AccessKey[MAXPLAYERS+1] = false;

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(buttons & IN_RELOAD)
	{
		if(AccessKey[client] == false)
		{
			skill2(Client);
			AccessKey[client] = true;
		}
	}
	else
	{
		AccessKey[client] = false;
	}
}

new Float:변수[MAXPLAYERS+1]; // 다음 사용 가능시간을 담는 변수 (주의: 전역으로 정의할 것)

if(R 누르면)
{
   if(변수 <= GetGameTIme())
   {
      발동
      변수 = GetGameTime() + 5.0;
   }
   else
   {
      PrintHintText(Client, "%.1f초만 기다리랑께;;", 변수 - GetGameTime());
   }
}

#define IN_ATTACK  (1 << 0)
#define IN_JUMP   (1 << 1)
#define IN_DUCK   (1 << 2)
#define IN_FORWARD  (1 << 3)
#define IN_BACK   (1 << 4)
#define IN_USE   (1 << 5)
#define IN_CANCEL  (1 << 6)
#define IN_LEFT   (1 << 7)
#define IN_RIGHT  (1 << 8)
#define IN_MOVELEFT  (1 << 9)
#define IN_MOVERIGHT  (1 << 10)
#define IN_ATTACK2  (1 << 11)
#define IN_RUN   (1 << 12)
#define IN_RELOAD  (1 << 13)
#define IN_ALT1   (1 << 14)
#define IN_ALT2   (1 << 15)
#define IN_SCORE  (1 << 16)    
#define IN_SPEED  (1 << 17) 
#define IN_WALK   (1 << 18) 
#define IN_ZOOM   (1 << 19) 
#define IN_WEAPON1  (1 << 20) 
#define IN_WEAPON2  (1 << 21) 
#define IN_BULLRUSH  (1 << 22)
#define IN_GRENADE1  (1 << 23) 
#define IN_GRENADE2  (1 << 24) 
#define IN_ATTACK3  (1 << 25)
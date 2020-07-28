
#include <sourcemod>
#include <sdktools>
#include <tf2attributes>

#define SHOW (0x0010)
#define MAX_ADV 1+26	//+1은 냅두고 1만 갯수수정

new String:advertisement[MAX_ADV][256];
new p=1;

public OnPluginStart()
{
	RegConsoleCmd("explode", Command_Suicide, "자살을 막는 커맨드 입니다!");
	RegConsoleCmd("kill", Command_Suicide, "자살을 막는 커맨드 입니다!");

	MakeAdv("와우! 개 트롤짓 할 뻔함");
	MakeAdv("님 트롤 못함 ㅇㅋ?");
	MakeAdv("어디 앞이 안보여서 살긋나?");
	MakeAdv("걍 관전에 가지");
	MakeAdv("왜 자살을 할까");
	MakeAdv("무슨 고민있어?");
	MakeAdv("자살은 앙대요");
	MakeAdv("자살은 하지마시죠");
	MakeAdv("트롤입니까?");
	MakeAdv("정신 건강에 해로워요");
	MakeAdv("지금 뭐하십니까?");
	MakeAdv("자살 시도를 막았군!");
	MakeAdv("우헤헤헤 자살 못하지?");
	MakeAdv("자살 하디마");
	MakeAdv("트롤하면 좋습니까?");
	MakeAdv("기분 좋아?");
	MakeAdv("다시 해보시지?");
	MakeAdv("어디 해봐라~");
	MakeAdv("죽지마!");
	MakeAdv("왜그래에 죽지마앙");
	MakeAdv("해지마아~");
	MakeAdv("앙대");
	MakeAdv("die no no");
	MakeAdv("Do not die");
	MakeAdv("nooooooooooooo");
	MakeAdv("자살하면 재밌어?");
	MakeAdv("이래서 우리나라 자살 1위라니깐?");
	MakeAdv("풉 ㅋㅋㅋㅋ");
	MakeAdv("안보이지? 메렁");
	MakeAdv("메롱 메롱 메롱 메롱");
	MakeAdv("자살보단 장님을~");
	MakeAdv("아피 안보여!!");
	MakeAdv("으앙 내 눈!");
	MakeAdv("안쥬금 ㅋ");
	MakeAdv("당신은 못 죽어");
	MakeAdv("자살하면 지옥간다.");
	MakeAdv("자살하면 천국 못 간다.");
	MakeAdv("눈 장애인 ㅋ");
	MakeAdv("님은 못 죽음 ㅇㅋ?");
	MakeAdv("쉼표 누르고 클래스 바꾸면 댐 ㅇㅋ?");
	MakeAdv("점 누르고 팀 바꾸면 댐 ㅇㅋ?");
	MakeAdv("못 죽어서 안달이네");
	MakeAdv("죽지마이소");
	MakeAdv("전생에 개미로 태어난다");
	MakeAdv("죽으면 안대오");
	MakeAdv("전생에 벌레로 태어난다");
	MakeAdv("게임에서 만큼은 자살하지 말자");
	MakeAdv("하지말라고");
	MakeAdv("야이 10 hal lo ma 적당히해");
	MakeAdv("욕 나오게하네");
	MakeAdv("그만해라잉");
	MakeAdv("너 죽는 꼴 보기 싫어");
	MakeAdv("제발 사라지지마");
	MakeAdv("부탁이야 죽지마");
	MakeAdv("너 없이 못살아");
	MakeAdv("그러지마아ㅏ아아아아아아아ㅏ아ㅏ아아아아아ㅏ아아ㅏ아아ㅏ아아앙");
	MakeAdv("읽는거 재밌지?");
	MakeAdv("못 죽어서 안달이네");
}

public MakeAdv(String:T_advertisement[256])
{
	advertisement[p++] = T_advertisement;
}

public Action:Command_Suicide(Client, args)
{//	BlindClient(Client);
	TF2Attrib_SetByDefIndex(Client, 142, 15185211.0);
	SetEntityRenderColor(Client, 0, 0, 0, 0);
	new a = GetRandomInt(1, p-1);
	PrintToChat(Client, "\x04%s", advertisement[a]);
	return Plugin_Handled;
} 

/*public BlindClient(Client)
{
	new Handle:msg; 
		
	msg = StartMessageOne("Fade", Client);
	BfWriteShort(msg, 100000000);
	BfWriteShort(msg, 100000000); // Duration
	BfWriteShort(msg, SHOW);
	BfWriteByte(msg, 0);
	BfWriteByte(msg, 0);
	BfWriteByte(msg, 0);
	BfWriteByte(msg, 255);
	EndMessage();
}*/
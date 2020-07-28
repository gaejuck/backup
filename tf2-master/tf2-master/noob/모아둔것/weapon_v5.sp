#include <sdkhooks>
#include <tf2>
#include <tf2items>
#include <tf2_stocks> 

new bool:gold[MAXPLAYERS+1];

public OnPluginStart()
{
//	RegAdminCmd("sm_we2", aaaa, ADMFLAG_GENERIC);
	RegAdminCmd("sm_gold", GoldItem, ADMFLAG_RESERVATION);
}

public OnClientPutInServer(client)  
{ 
	gold[client] = false; 
}

public OnClientDisconnect(client) 
{ 
	gold[client] = false; 
}
/*
public Action:aaaa(client, args)
{
	main_menu(client);
	PrintToChat(client,"\x07FA87EB 현재 대여 할 수 있는 클래스는 올 클래스입니다."); //솔저, 파이로, 헤비 입니다 등.
}
*/
public Action:GoldItem(client, args)
{
	if(PlayerCheck(client))
	{
		if(gold[client] == false)
		{
			gold[client] = true;
		}
		else if(gold[client] == true)
		{
			gold[client] = false;
		}
	}
	
	return Plugin_Handled;
}

public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	if(gold[client] == true)
	{
		if (StrEqual(classname, "tf_weapon"))
			return Plugin_Continue;  
		
		hItem = TF2Items_CreateItem(OVERRIDE_ATTRIBUTES | PRESERVE_ATTRIBUTES);
		TF2Items_SetClassname(hItem, classname);		
		TF2Items_SetItemIndex(hItem, iItemDefinitionIndex);
		
		TF2Items_SetNumAttributes(hItem, 1);
		TF2Items_SetAttribute(hItem, 0, 542, 1.0);
	}
	
	return Plugin_Changed;
}
/*
public main_menu(client)
{
	new Handle:info = CreateMenu(main_Information); // info 라는 메뉴를 만든다.
	SetMenuTitle(info, "대여할 무기를 고르세요");
	AddMenuItem(info, "1", "클래스별 무기");
	AddMenuItem(info, "2", "공용 무기");
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);

}
public main_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		if(select == 0)
		{
			class_item(client)
		}

		else if(select == 1)
		{
			all_clas_item(client)
		}
		else if(action == MenuAction_Cancel)
		{
			if(select == MenuCancel_Exit)
			{
			}
		}else if(action == MenuAction_End)
		{
			CloseHandle(menu);
		}
	}
}

public Action:class_item(client)
{
	new TFClassType:class = TF2_GetPlayerClass(client);

	new Handle:info = CreateMenu(class_item_menu);
	
	switch(class)
	{
		case TFClass_Scout:
		{
			SetMenuTitle(info, "스카웃 대여 무기");
			AddMenuItem(info, "1", "오스트레일륨 스캐터건");
			AddMenuItem(info, "2", "오스트레일륨 자연에 섭리");
		}
		
		case TFClass_Soldier:
		{
			SetMenuTitle(info, "솔저 대여 무기");
			AddMenuItem(info, "1", "오스트레일륨 로켓 발사기");
			AddMenuItem(info, "2", "오스트레일륨 블랙박스");
		}
		
		case TFClass_Pyro:
		{
			SetMenuTitle(info, "파이로 대여 무기");
			AddMenuItem(info, "1", "오스트레일륨 화염 방사기");
			AddMenuItem(info, "2", "오스트레일륨 소화도끼");
		}
		
		case TFClass_DemoMan:
		{
			SetMenuTitle(info, "데모맨 대여 무기");
			AddMenuItem(info, "1", "오스트레일륨 유탄 발사기");
			AddMenuItem(info, "2", "오스트레일륨 점착 폭탄 발사기");
			AddMenuItem(info, "3", "오스트레일륨 아이랜더");
		}
		
		case TFClass_Heavy:
		{
			SetMenuTitle(info, "헤비 대여 무기");
			AddMenuItem(info, "1", "오스트레일륨 미니건");
			AddMenuItem(info, "2", "오스트레일륨 토미슬라프");
		}
		
		case TFClass_Engineer:
		{
			SetMenuTitle(info, "엔지니어 대여 무기");
			AddMenuItem(info, "1", "오스트레일륨 개척자의 정의");
			AddMenuItem(info, "2", "오스트레일륨 렌치");
			AddMenuItem(info, "3", "황금 렌치");
		}
		
		case TFClass_Medic:
		{
			SetMenuTitle(info, "메딕 대여 무기");
			AddMenuItem(info, "1", "오스트레일륨 블루트자우거");
			AddMenuItem(info, "2", "오스트레일륨 메디 건");
		}

		case TFClass_Sniper:
		{
			SetMenuTitle(info, "스나이퍼 대여 무기");
			AddMenuItem(info, "1", "오스트레일륨 저격소총");
			AddMenuItem(info, "2", "오스트레일륨 기관단총");
		}
		
		case TFClass_Spy:
		{
			SetMenuTitle(info, "스파이 대여 무기");
			AddMenuItem(info, "1", "오스트레일륨 외교대사");
			AddMenuItem(info, "2", "오스트레일륨 칼");
		}
	}
	
	SetMenuExitButton(info, true);
	DisplayMenu(info, client, MENU_TIME_FOREVER);
}

//-------------------------------------스카웃 무기------------------------------------//

public class_item_menu(Handle:menu, MenuAction:action, client, select)
{
	new TFClassType:Class = TF2_GetPlayerClass(client);
	
	if(action == MenuAction_Select)
	{	
		if(Class == TFClass_Scout)
		{
			if(select == 0)
			{
				TF2_RemoveWeaponSlot(client, 0); // 0주무기 1보조무기 2 근접무기 3,4는 잘모름 하지만 아마.. 엔지의 3이 설치 4가 파괴, 스파이 변장
				SpawnWeapon(client, "tf_weapon_scattergun", 200, 100, 7, "542 ; 1.0");
		//		함수이름	유저		무기이름		무기번호, 무기레벨, 퀄리티, 옵션
			}
			else if(select == 1)
			{
				TF2_RemoveWeaponSlot(client, 0); 
				SpawnWeapon(client, "tf_weapon_scattergun", 45, 100, 9, "44 ; 1.0 ; 6 ; 0.5 ; 45 ; 1.2 ; 1 ; 0.9 ; 3 ; 0.34 ; 43 ; 1.0 ; 328 ; 1.0 ; 542 ; 1");
			}
		}
		else if(Class == TFClass_Soldier)
		{
			if(select == 0)
			{
				TF2_RemoveWeaponSlot(client, 0);
				SpawnWeapon(client, "tf_weapon_rocketlauncher", 205, 100, 5, "542 ; 1.0");
			}
			else if(select == 1)
			{
				TF2_RemoveWeaponSlot(client, 0);
				SpawnWeapon(client, "tf_weapon_rocketlauncher", 228, 100, 6, "16 ; 15.0 ; 3 ; 0.75 ; 542 ; 1.0");
			}
		}
		
		else if(Class == TFClass_Pyro)
		{
			if(select == 0)
			{
				TF2_RemoveWeaponSlot(client, 0);
				SpawnWeapon(client, "tf_weapon_flamethrower", 208, 100, 7, "542 ; 1.0");
			}

			else if(select == 1)
			{
				TF2_RemoveWeaponSlot(client, 2);
				SpawnWeapon(client, "tf_weapon_fireaxe", 38, 100, 7, "20 ; 1.0 ; 21 ; 0.5 ; 22 ; 1.0 ; 542 ; 1.0");
			}
		}
		
		else if(Class == TFClass_DemoMan)
		{
			if(select == 0)
			{
				TF2_RemoveWeaponSlot(client, 0);
				SpawnWeapon(client, "tf_weapon_grenadelauncher", 206, 100, 7, "542 ; 1.0");
			}
			else if(select == 1)
			{
				TF2_RemoveWeaponSlot(client, 1);
				SpawnWeapon(client, "tf_weapon_pipebomblauncher", 207, 100, 7, "542 ; 1.0");
			}
			else if(select == 2)
			{
				TF2_RemoveWeaponSlot(client, 2);
				SpawnWeapon(client, "tf_weapon_sword", 132, 100, 7, "15 ; 0 ; 125 ; -25 ; 219 ; 1.0 ; 292 ; 6.0 ; 542 ; 1.0");
			}
		}
		
		else if(Class == TFClass_Heavy)
		{
			if(select == 0)
			{
				TF2_RemoveWeaponSlot(client, 0);
				SpawnWeapon(client, "tf_weapon_minigun", 202, 100, 5, "542 ; 1.0");
			}
			else if(select == 1)
			{
				TF2_RemoveWeaponSlot(client, 0);
				SpawnWeapon(client, "tf_weapon_minigun", 424, 100, 6, "87 ; 0.9 ; 238 ; 1.0 ; 5 ; 1.2 ; 542 ; 1.0");
			}
		}
		
		else if(Class == TFClass_Engineer)
		{
			if(select == 0)
			{
				TF2_RemoveWeaponSlot(client, 0);
				SpawnWeapon(client, "tf_weapon_sentry_revenge", 141, 100, 8, "136 ; 1 ; 15 ; 0 ; 3 ; 0.5 ; 542 ; 1.0");
			}
			else if(select == 1)
			{
				TF2_RemoveWeaponSlot(client, 2);
				SpawnWeapon(client, "tf_weapon_wrench", 197, 100, 9, "292 ; 3.0 ; 293 ; 0.0 ; 542 ; 1.0");
			}
			else if(select == 2)
			{
				TF2_RemoveWeaponSlot(client, 2);
				SpawnWeapon(client, "tf_weapon_wrench", 169 , 100, 9, "150 ; 1.0");
			}
		}
		
		else if(Class == TFClass_Medic)
		{
			if(select == 0)
			{
				TF2_RemoveWeaponSlot(client, 0);
				SpawnWeapon(client, "tf_weapon_syringegun_medic", 36, 100, 6, "16 ; 3.0 ; 129 ; -2.0 ; 542 ; 1.0");
			}
			else if(select == 1)
			{
				TF2_RemoveWeaponSlot(client, 1);
				SpawnWeapon(client, "tf_weapon_medigun", 211, 100, 6, "292 ; 1.0 ; 293 ; 2.0 ; 542 ; 1.0");
			}
		}
		
		else if(Class == TFClass_Sniper)
		{
			if(select == 0)
			{
				TF2_RemoveWeaponSlot(client, 0);
				SpawnWeapon(client, "tf_weapon_sniperrifle", 201, 100, 6, "542 ; 1.0");
			}
			else if(select == 1)
			{
				TF2_RemoveWeaponSlot(client, 1);
				SpawnWeapon(client, "tf_weapon_smg", 203, 100, 6, "542 ; 1.0");
			}
		}
		
		else if(Class == TFClass_Spy)
		{
			if(select == 0)
			{
				TF2_RemoveWeaponSlot(client, 0);
				SpawnWeapon(client, "tf_weapon_revolver", 61, 100, 6, "51 ; 1.0 ; 1 ; 0.85 ; 5 ; 1.2 ; 542 ; 1.0");
			}
			else if(select == 1)
			{
				TF2_RemoveWeaponSlot(client, 2);
				SpawnWeapon(client, "tf_weapon_knife", 194, 100, 6, "542 ; 1.0");
			}
		}
		else if(action == MenuAction_Cancel)
		{
			if(select == MenuCancel_Exit)
			{
			}
		}else if(action == MenuAction_End)
		{
			CloseHandle(menu);
		}
	}
}

public Action:all_clas_item(client)
{
	new Handle:info = CreateMenu(all_menu); // info 라는 메뉴를 만든다.
	SetMenuTitle(info, "공용 무기");
	AddMenuItem(info, "1", "황금 프라이팬");
	AddMenuItem(info, "2", "saxxy");
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);
}

public all_menu(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		if(select == 0)
		{
			TF2_RemoveWeaponSlot(client, 2);
			SpawnWeapon(client, "tf_weapon_bottle", 1071, 100, 7, "542 ; 0.0");
		}
		else if(select == 1)
		{
			TF2_RemoveWeaponSlot(client, 2);
			SpawnWeapon(client, "tf_weapon_bat", 423, 100, 9, "150 ; 1.0");
		}
	}
	else if(action == MenuAction_Cancel)
	{
		if(select == MenuCancel_Exit)
		{
		}
	}else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

stock SpawnWeapon(client,String:name[],index,level,qual,String:att[])
{
	new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL|FORCE_GENERATION);
	if (hWeapon == INVALID_HANDLE)
		return -1;
	TF2Items_SetClassname(hWeapon, name);
	TF2Items_SetItemIndex(hWeapon, index);
	TF2Items_SetLevel(hWeapon, level);
	TF2Items_SetQuality(hWeapon, qual);
	new String:atts[32][32];
	new count = ExplodeString(att, " ; ", atts, 32, 32);
	if (count > 0)
	{
		TF2Items_SetNumAttributes(hWeapon, count/2);
		new i2 = 0;
		for (new i = 0;  i < count;  i+= 2)
		{
			TF2Items_SetAttribute(hWeapon, i2, StringToInt(atts[i]), StringToFloat(atts[i+1]));
			i2++;
		}
	}
	else
		TF2Items_SetNumAttributes(hWeapon, 0);
	new entity = TF2Items_GiveNamedItem(client, hWeapon);
	CloseHandle(hWeapon);
	EquipPlayerWeapon(client, entity);
	return entity;
}*/

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
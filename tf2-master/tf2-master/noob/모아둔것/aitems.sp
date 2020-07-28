#include <tf2attributes>
#include <tf2_stocks>

new bool:Random_Class[MAXPLAYERS+1] = false;
new bool:unusual[MAXPLAYERS+1] = false;

#define FIREBALL	0 // Done
#define BATS 		1 // Done
#define PUMPKIN 	2 // Done
#define TELE 		3 // Done
#define LIGHTNING 	4 // Done
#define BOSS 		5 // Done
#define METEOR 		6 // Done
#define ZOMBIEH 	7 // Done
#define KAT_BATS 	10
#define KAT_Orb 	11

#define ZOMBIE 		8
#define PUMPKIN2 	9

public OnPluginStart()
{

	HookEvent("post_inventory_application", PlayerSpawnn);
}

public OnClientPutInServer(client)
{
	unusual[client] = false;
	Random_Class[client] = false;
}

public OnClientDisconnect(client)
{
	unusual[client] = false;
	Random_Class[client] = false;
}

public Action:aaaa(client, args)
{
	if(unusual[client] == false)
	{
		unusual[client] = true;
		PrintToChat(client, "\x04On 됐으니 리스폰 하세요");
	}
	else
	{
		unusual[client] = false;
		PrintToChat(client, "\x04Off 됐으니 리스폰 하세요");
	}
}

public Action:aaab(client, args)
{
	if(Random_Class[client] == false)
	{
		Random_Class[client] = true;
		PrintToChat(client, "\x04On 됐으니 리스폰 하세요");
	}
	else
	{
		Random_Class[client] = false;
		PrintToChat(client, "\x04Off 됐으니 리스폰 하세요");
	}
}

public Action:sp(client, args)
{
	Spell_Menu(client);
}

public Action:PlayerSpawnn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	TF2Attrib_SetByDefIndex(client, 554, 1.0); // 소생
	TF2Attrib_SetByDefIndex(client, 275, 1.0); // 낙하
	TF2Attrib_SetByDefIndex(client, 700, 1.0); //덕스트릭
	TF2Attrib_SetByDefIndex(client, 701, 1.0); //덕스트릭
	TF2Attrib_SetByDefIndex(client, 702, 1.0); //덕스트릭
	TF2Attrib_SetByDefIndex(client, 705, 1.0); //덕스트릭
} 
public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{ 
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(Random_Class[client] == true)
	{
		TF2_SetPlayerClass(client, TFClassType:GetRandomInt(1, 9));
	}
	
	if(unusual[client] == true)
	{
		new Float:random = GetRandomFloat(87.0, 90.0);
	//	new Float:taunt_random = GetRandomFloat(3011.0, 3012.0);
		
		TF2Attrib_RemoveByDefIndex(client, 134);
	//	TF2Attrib_RemoveByDefIndex(client, 370);
		TF2Attrib_SetByDefIndex(client, 134, random);
	//	TF2Attrib_SetByDefIndex(client, 370, taunt_random);
		
	//	PrintToChat(client, "\x07FF8C12 unusual code : %5.0f \x07F2FF00 taunt unusual code : %5.0f", random, taunt_random);
		PrintToChat(client, "\x07FF8C12 unusual code : %.0f", random);
	}
	else
	{
		TF2Attrib_RemoveByDefIndex(client, 134);
		TF2Attrib_RemoveByDefIndex(client, 370);
	}
}

public Spell_Menu(client)
{
	new Handle:info = CreateMenu(Spell_Information); // info 라는 메뉴를 만든다.
	SetMenuTitle(info, "매직!");
	AddMenuItem(info, "1", "FIREBALL");
	AddMenuItem(info, "2", "LIGHTNING");
	AddMenuItem(info, "3", "PUMPKIN");
	AddMenuItem(info, "4", "PUMPKIN2");
	AddMenuItem(info, "5", "BATS");
	AddMenuItem(info, "6", "METEOR");
	AddMenuItem(info, "7", "TELE");
	AddMenuItem(info, "8", "BOSS");
	AddMenuItem(info, "9", "ZOMBIEH");
	AddMenuItem(info, "10", "ZOMBIE");
	AddMenuItem(info, "11", "KAT BATS");
	AddMenuItem(info, "12", "KAT Orb");
	SetMenuExitButton(info, true);

	DisplayMenu(info, client, MENU_TIME_FOREVER);

}
public Spell_Information(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		if(select == 0)
		{
			ShootProjectile(client, FIREBALL);
		}

		else if(select == 1)
		{
			ShootProjectile(client, LIGHTNING);
		}
		
		else if(select == 2)
		{
			ShootProjectile(client, PUMPKIN);
		}
		else if(select == 3)
		{
			ShootProjectile(client, PUMPKIN2);
		}
		else if(select == 4)
		{
			ShootProjectile(client, BATS);
		}
		else if(select == 5)
		{
			ShootProjectile(client, METEOR);
		}
		else if(select == 6)
		{
			ShootProjectile(client, TELE);
		}
		else if(select == 7)
		{
			ShootProjectile(client, BOSS);
		}
		else if(select == 8)
		{
			ShootProjectile(client, ZOMBIEH);
		}
		else if(select == 9)
		{
			ShootProjectile(client, ZOMBIE);
		}
		else if(select == 10)
		{
			ShootProjectile(client, KAT_BATS);
		}
		else if(select == 11)
		{
			ShootProjectile(client, KAT_Orb);
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

ShootProjectile(client, spell)
{
	new Float:vAngles[3]; // original
	new Float:vPosition[3]; // original
	GetClientEyeAngles(client, vAngles);
	GetClientEyePosition(client, vPosition);
	new String:strEntname[45] = "";
	switch(spell)
	{
		case FIREBALL: 		strEntname = "tf_projectile_spellfireball";
		case LIGHTNING: 	strEntname = "tf_projectile_lightningorb";
		case PUMPKIN: 		strEntname = "tf_projectile_spellmirv";
		case PUMPKIN2: 		strEntname = "tf_projectile_spellpumpkin";
		case BATS: 			strEntname = "tf_projectile_spellbats";
		case METEOR: 		strEntname = "tf_projectile_spellmeteorshower";
		case TELE: 			strEntname = "tf_projectile_spelltransposeteleport";
		case BOSS:			strEntname = "tf_projectile_spellspawnboss";
		case ZOMBIEH:		strEntname = "tf_projectile_spellspawnhorde";
		case ZOMBIE:		strEntname = "tf_projectile_spellspawnzombie";
		case KAT_BATS:		strEntname = "tf_projectile_spellKartBats";
		case KAT_Orb:		strEntname = "tf_projectile_spellKartOrb";
	}
	new iTeam = GetClientTeam(client);
	new iSpell = CreateEntityByName(strEntname);
	
	if(!IsValidEntity(iSpell))
		return -1;
	
	decl Float:vVelocity[3];
	decl Float:vBuffer[3];
	
	GetAngleVectors(vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR);
	
	vVelocity[0] = vBuffer[0]*1100.0; //Speed of a tf2 rocket.
	vVelocity[1] = vBuffer[1]*1100.0;
	vVelocity[2] = vBuffer[2]*1100.0;
	
	SetEntPropEnt(iSpell, Prop_Send, "m_hOwnerEntity", client);
	SetEntProp(iSpell,    Prop_Send, "m_bCritical", (GetRandomInt(0, 100) <= 5)? 1 : 0, 1);
	SetEntProp(iSpell,    Prop_Send, "m_iTeamNum",     iTeam, 1);
	SetEntProp(iSpell,    Prop_Send, "m_nSkin", (iTeam-2));
	
	TeleportEntity(iSpell, vPosition, vAngles, NULL_VECTOR);
	/*switch(spell)
	{
		case FIREBALL, LIGHTNING:
		{
			TeleportEntity(iSpell, vPosition, vAngles, vVelocity);
		}
		case BATS, METEOR, TELE:
		{
			//TeleportEntity(iSpell, vPosition, vAngles, vVelocity);
			//SetEntPropVector(iSpell, Prop_Send, "m_vecForce", vVelocity);
			
		}
	}*/
	
	SetVariantInt(iTeam);
	AcceptEntityInput(iSpell, "TeamNum", -1, -1, 0);
	SetVariantInt(iTeam);
	AcceptEntityInput(iSpell, "SetTeam", -1, -1, 0); 
	
	DispatchSpawn(iSpell);
	/*
	switch(spell)
	{
		//These spells have arcs.
		case BATS, METEOR, TELE:
		{
			vVelocity[2] += 32.0;
		}
	}*/
	TeleportEntity(iSpell, NULL_VECTOR, NULL_VECTOR, vVelocity);
	
	return iSpell;
}
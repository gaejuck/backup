#include <tf2attributes>
#include <tf2_stocks>
#include <tf2items>
#include <sdktools> 

#define NO_ATTACH 0 //그자리에 남고
#define ATTACH_NORMAL 1 
#define ATTACH_HEAD 2 //좌표없인 작동안대는듯? 숫자는 점점 굵어지는듯. 2가 얇았던걸로 기억..

#define radius 500.0

new bool:CU[MAXPLAYERS+1] = false;

public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	HookEvent("post_inventory_application", inventory);
	RegConsoleCmd("sm_cu", custom_unusual, "");
}


public OnClientPutInServer(client)
{
	CU[client] = false;
}

public OnClientDisconnect(client)
{
	if(CU[client] == true)
	{
		CU[client] = false;
	}
}

public Action:custom_unusual(client, args)
{
	if(PlayerCheck(client))
	{
		if(CU[client] == false)
		{
			PrintToChat(client, "\x04ok");
			CU[client] = true;
		}
		else
		{
			PrintToChat(client, "\x04no");
			CU[client] = false;
		}
	}
	return Plugin_Handled;
}

public TF2Items_OnGiveNamedItem_Post(client, String:classname[], index, level, quality, entity)
{
	if (StrEqual(classname, "tf_wearable"))
		return;
		
	if (StrEqual(classname, "tf_weapon_pistol_scout") || StrEqual(classname, "tf_weapon_handgun_scout_secondary") || StrEqual(classname, "tf_weapon_pistol")
	|| StrEqual(classname, "tf_weapon_sniperrifle") || StrEqual(classname, "tf_weapon_sniperrifle_decap") || StrEqual(classname, "tf_weapon_sniperrifle_classic")
	|| StrEqual(classname, "tf_weapon_smg") || StrEqual(classname, "tf_weapon_revolver"))
	{
		TF2Attrib_SetByDefIndex(entity, 45, 5.0); 
	}
	else if(StrEqual(classname, "tf_weapon_minigun"))
	{
		TF2Attrib_SetByDefIndex(entity, 45, 2.0);
		
		if(CU[client] == true)
		{
			CreateParticle("smoke_train", entity, ATTACH_HEAD);  
		}
	}
	else if(StrEqual(classname, "tf_weapon_cannon") || StrEqual(classname, "tf_weapon_grenadelauncher") || StrEqual(classname, "tf_weapon_pipebomblauncher "))
	{
		TF2Attrib_SetByDefIndex(entity, 521, 1.0); //이펙
		TF2Attrib_SetByDefIndex(entity, 522, 1.0); //잘모름
		TF2Attrib_SetByDefIndex(entity, 99, 1.7); //반경
		TF2Attrib_SetByDefIndex(entity, 4, 30.0); //장탄수
		TF2Attrib_SetByDefIndex(entity, 37, 1000.0); //최대 탄약
	}
	
	if(CU[client] == true)
	{
	//	CreateParticle("underworld_gate_zap", entity, ATTACH_HEAD);
		CreateParticle("utaunt_disco_party", entity, ATTACH_HEAD); //중앙
		CreateParticle("utaunt_disco_party", entity, ATTACH_HEAD, 100.0, 0.0, 0.0); //앞
		CreateParticle("utaunt_disco_party", entity, ATTACH_HEAD, -100.0, 0.0, 0.0); //뒤
		CreateParticle("utaunt_disco_party", entity, ATTACH_HEAD, 0.0, 100.0, 0.0); //왼쪽
		CreateParticle("utaunt_disco_party", entity, ATTACH_HEAD, 0.0, -100.0, 0.0); //오른쪽
		CreateParticle("utaunt_disco_party", entity, ATTACH_HEAD, 0.0, 0.0, 100.0); //위
	}
}

public Action:inventory(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	TF2Attrib_SetByDefIndex(client, 441, 1.0);
	TF2Attrib_SetByDefIndex(client, 499, 1.0); //메딕 실드생성
	TF2Attrib_SetByDefIndex(client, 632, 1.0); //점프세발
	TF2Attrib_SetByDefIndex(client, 269, 1.0); //적체력
	TF2Attrib_SetByDefIndex(client, 493, 1.0); //부활
}
public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	TF2_AddCondition(client, TFCond:96, -1.0);
	TF2Attrib_SetByDefIndex(client, 551, 1.0); //스페셜
	TF2Attrib_SetByDefIndex(client, 557, 0.1); //도발공격속도

//	TF2Attrib_SetByDefIndex(client, 676, 1.0); //돌격해도 데미지없음
}

stock Handle:CreateParticle(String:type[], entity, attach=NO_ATTACH, Float:xOffs=0.0, Float:yOffs=0.0, Float:zOffs=0.0)
{
    new particle = CreateEntityByName("info_particle_system");
    
    if (IsValidEdict(particle)) {
        decl Float:pos[3];
        GetEntPropVector(entity, Prop_Send, "m_vecOrigin", pos);
        pos[0] += xOffs;
        pos[1] += yOffs;
        pos[2] += zOffs;
        TeleportEntity(particle, pos, NULL_VECTOR, NULL_VECTOR);
        DispatchKeyValue(particle, "effect_name", type);

        if (attach != NO_ATTACH) {
            SetVariantString("!activator");
            AcceptEntityInput(particle, "SetParent", entity, particle, 0);
        
            if (attach == ATTACH_HEAD) {
                SetVariantString("head");
                AcceptEntityInput(particle, "SetParentAttachmentMaintainOffset", particle, particle, 0);
            }
        }
        DispatchKeyValue(particle, "targetname", "present");
        DispatchSpawn(particle);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "Start");
        
    }
    
    return INVALID_HANDLE;
}

stock bool:PlayerCheck(client){
	if(client > 0 && client <= MaxClients){
		if(IsClientConnected(client) == true){
			if(IsClientInGame(client) == true){
				return true;
			}
		}
	}
	return false;
}
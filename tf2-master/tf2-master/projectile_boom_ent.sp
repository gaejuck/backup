#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

new Handle:CvarBoom = INVALID_HANDLE;
new String:boooooom[255];

new bool:pb[MAXPLAYERS+1] = false;

public Plugin:myinfo =
{
	name = "projectile boom",
	author = "ㅣ",
	description = "발사체 폭파 후 이펙트랄까나..",
	version = "1.3",
	url = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
}

public OnPluginStart()
{
	// !cvar sm_projectile_boom tf_halloween_pickup   
	// !cvar sm_projectile_boom tf_generic_bomb    
	
	
	
	
	
	CvarBoom = CreateConVar("sm_projectile_boom", "tank_destruction", "발사체 폭파후 이펙트");
	GetConVarString(CvarBoom, boooooom, sizeof(boooooom));
	HookConVarChange(CvarBoom, ConVarChanged);
	
	RegAdminCmd("sm_pb", command, ADMFLAG_KICK);
}

public OnClientDisconnected(client)
	if(pb[client] == true)
		pb[client] = false;

public Action:command(client, args)
{
	if(AliveCheck(client))
	{
		if(pb[client] == false)
		{
			pb[client] = true;
			PrintToChat(client, "\x03적용 완료");
		}
		else
		{
			pb[client] = false;
			PrintToChat(client, "\x03적용 해제");
		}
	}
	return Plugin_Handled;
}

public ConVarChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
    GetConVarString(cvar, boooooom, sizeof(boooooom));

public OnEntityDestroyed(entity)
{
	if (IsValidEntity(entity))
	{
		new String:classname[32];
		new owner = GetEntPropEnt(entity,Prop_Data,"m_hOwnerEntity");
			
		if(IsAClient(owner)&&pb[owner] == true)
		{
			GetEntPropString(entity,Prop_Data,"m_iClassname",classname,sizeof(classname))
			if (StrContains(classname,"tf_projectile",false)!=-1)
			{
				new Float:ori[3];
				GetEntPropVector(entity, Prop_Data, "m_vecOrigin", ori);

				new boom=CreateEntityByName(boooooom);
				ori[2] -= 10.0
				if (IsValidEntity(boom))
				{
					TeleportEntity(boom,ori,NULL_VECTOR,NULL_VECTOR);
					DispatchSpawn(boom);
					SetEntPropEnt(boom,Prop_Send,"m_hOwnerEntity",0)
				}
			}
		}
	}
}

IsAClient(index)
{
	if (1<=index<=MaxClients&&IsClientInGame(index))
	{
		return true;
	}
	else
	{
		return false;
	}
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

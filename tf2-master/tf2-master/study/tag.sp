#include <sourcemod>
#include <sdkhooks>
#include <colors>
#include <scp>

new Handle:DB = INVALID_HANDLE;
new String:tagConfig[120];

new aaa[MAXPLAYERS+1];

public OnPluginStart()
{
	HookEvent("player_spawn", PlayerSpawn);
	BuildPath(Path_SM, tagConfig, sizeof(tagConfig), "configs/kill_tag.cfg");
}

public Action:PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	aaa[client]++;
}
	
public Action:OnChatMessage(&author, Handle:recipients, String:name[], String:message[])
{
	decl String:Color[64], String:tag[256];
	DB = CreateKeyValues("kill_tag"); 
	FileToKeyValues(DB, tagConfig);
	if(KvGotoFirstSubKey(DB))
	{
		do
		{
			KvGetSectionName(DB, tag, sizeof(tag));
			KvGetString(DB, "color", Color, sizeof(Color)); 
			new kill_min = KvGetNum(DB, "kill min");
			new kill_max = KvGetNum(DB, "kill max");
			
			
			if(kill_max >= aaa[author] >= kill_min)
			{
				Format(name, 256, "\x07%s%s \x03%s", Color, tag, name);
				return Plugin_Handled;
			}
		}
		while(KvGotoNextKey(DB)); 
		KvGoBack(DB);
	}
	return Plugin_Changed;
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
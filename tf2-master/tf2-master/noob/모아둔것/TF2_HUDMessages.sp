#include <sourcemod>
#include <sdktools>

public OnPluginStart()
{
	RegAdminCmd("sm_gmsg", Command_GoldMessage, ADMFLAG_CHAT, "sm_goldenwrench <message>");
}
public Action:Command_GoldMessage(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_gmsg <message>");
		return Plugin_Handled;
	}

	decl String:text[192];
	GetCmdArgString(text, sizeof(text));
	
	ShowGameText(text);

	return Plugin_Handled;
}

ShowGameText(const String:text[])
{
	new entity = CreateEntityByName("game_text_tf");
	DispatchKeyValue(entity, "message", text);
	DispatchKeyValue(entity, "display_to_team", "0");
	DispatchKeyValue(entity, "icon", "ico_build");
	DispatchKeyValue(entity, "targetname", "game_text1");
	DispatchKeyValue(entity, "background", "2");
	DispatchSpawn(entity);
	AcceptEntityInput(entity, "Display", entity, entity);
	CreateTimer(10.0, KillGameText, entity);
}


public Action:KillGameText(Handle:hTimer, any:entity)
{
	if ((entity > 0) && IsValidEntity(entity))
	{
		AcceptEntityInput(entity, "kill");
	}
	return Plugin_Stop;
}

stock bool:IsValidClient(iClient)
{
	if (iClient <= 0) return false;
	if (iClient > MaxClients) return false;
	if (!IsClientConnected(iClient)) return false;
	return IsClientInGame(iClient);
}
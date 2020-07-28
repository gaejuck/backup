#include <sourcemod>
#include <sdktools>

public OnPluginStart()
{
	RegAdminCmd("sm_gm", Command_GoldMessage, ADMFLAG_CHAT, "sm_goldenwrench <message>");
}
public Action:Command_GoldMessage(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_gmsg time message");
		return Plugin_Handled;
	}
	
	// new String:time2[32], Float:time;
	new String:message[64];

	// GetCmdArg(1, time2, sizeof(time2));
	GetCmdArg(1, message, sizeof(message));
	// time = StringToFloat(time2);
	
	// ShowGameText(time, "cart_icon", message);
	
	PrintToHud(client, message);

	return Plugin_Handled;
}

stock ShowGameText(Float:time, const String:icon[], const String:text[])
{
	new entity = CreateEntityByName("game_text_tf");
	DispatchKeyValue(entity, "message", text);
	DispatchKeyValue(entity, "display_to_team", "0");
	// DispatchKeyValue(entity, "icon", "ico_build");
	DispatchKeyValue(entity,"icon", icon);
	DispatchKeyValue(entity, "targetname", "game_text1");
	// DispatchKeyValue(entity, "background", "2");
	DispatchKeyValue(entity, "background", "0");
	DispatchSpawn(entity);
	AcceptEntityInput(entity, "Display", entity, entity);
	CreateTimer(time, KillGameText, entity);
}


public Action:KillGameText(Handle:hTimer, any:entity)
{
	if ((entity > 0) && IsValidEntity(entity))
	{
		AcceptEntityInput(entity, "kill");
	}
	return Plugin_Stop;
}

stock PrintToHud(client, const String:szMessage[], any:...)
{
	if (client <= 0 || client > MaxClients)
		ThrowError("Invalid client index %d", client);
	
	if (!IsClientInGame(client))
		ThrowError("Client %d is not in game", client);

	decl String:szBuffer[256];
	
	
	SetGlobalTransTarget(client);
	VFormat(szBuffer, sizeof(szBuffer), szMessage, 3);
	ReplaceString(szBuffer, sizeof(szBuffer), "\"", "?);
	
	decl params[] = {0x76, 0x6F, 0x69, 0x63, 0x65, 0x5F, 0x73, 0x65, 0x6C, 0x66, 0x00, 0x00};
	new Handle:msg = StartMessageOne("HudNotifyCustom", client);
	BfWriteString(msg, szBuffer);
	
	for(new i = 0; i < sizeof(params); i++)
		BfWriteByte(msg, params[i]);
	
	EndMessage();
}

stock bool:IsValidClient(iClient)
{
	if (iClient <= 0) return false;
	if (iClient > MaxClients) return false;
	if (!IsClientConnected(iClient)) return false;
	return IsClientInGame(iClient);
}
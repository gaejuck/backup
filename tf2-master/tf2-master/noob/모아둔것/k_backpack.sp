#include <sourcemod>
#include <sdktools>
#include <steamtools>

#define PLUGIN_VERSION "1.0"

public Plugin:myinfo = 
{
	name = "Trade Set",
	author = "K",
	description = "트레이드 세트",
	version = PLUGIN_VERSION, 
	url = "http://steamcommunity.com/id/kimh0192/"
};

//거래쳇 스타트
new Handle:TradeEnabled;

//구매
new Handle:TagaCvar;
new String:TagA[256];
new Handle:TagaColorCvar;
new String:TagAColor[64];

//판매
new Handle:TagsCvar;
new String:TagS[256];
new Handle:TagsColorCvar;
new String:TagSColor[64];


public OnPluginStart()
{
	LoadTranslations("common.phrases");
	
	CreateConVar("sm_ktrade_version", PLUGIN_VERSION, "K's Trade Set", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	
	TradeEnabled = CreateConVar("sm_tradechat_enabled", "1", "트레이드쳇 켜기 끄기 1/0");
	
	TagaCvar = CreateConVar("sm_trade_a_tag", "[구매]", "구매 태그");
	GetConVarString(TagaCvar, TagA, sizeof(TagA));
	
	TagsCvar = CreateConVar("sm_trade_s_tag", "[판매]", "판매 태그");
	GetConVarString(TagsCvar, TagS, sizeof(TagS));
	
	TagaColorCvar = CreateConVar("sm_trade_a_color", "B2A5F2", "구매색상");
	GetConVarString(TagaColorCvar, TagAColor, sizeof(TagAColor));
	
	TagsColorCvar = CreateConVar("sm_trade_s_color", "5ABF4D", "판매색상");
	GetConVarString(TagsColorCvar, TagSColor, sizeof(TagSColor));
	
	RegConsoleCmd("sm_bp", item, "백팩을 보는 플러그인");
	RegConsoleCmd("sm_a", a, "구매할때 쓰이는 플러그인");
	RegConsoleCmd("sm_s", s, "판매할때 쓰이는 플러그인");
}
public Action:a(client, args)
{
	if(GetConVarInt(TradeEnabled) == 0)
		return Plugin_Continue;
		
	decl String:aName[MAX_NAME_LENGTH];
	
	new String:text[512];
	GetCmdArgString(text, sizeof(text));
	GetClientName(client, aName, sizeof(aName));
	
	PrintToChatAll("\x07%s %s %s %s", TagAColor, aName, TagA, text);
	
	return Plugin_Handled;
}
public Action:s(client, args)
{
	if(GetConVarInt(TradeEnabled) == 0)
		return Plugin_Continue;
		
	new String:text[512];
	decl String:aName[MAX_NAME_LENGTH];
	
	GetCmdArgString(text, sizeof(text));
	GetClientName(client, aName, sizeof(aName));
	
	PrintToChatAll("\x07%s %s %s %s", TagSColor, aName, TagS, text);
	return Plugin_Handled;
}
public Action:item(client, args)
{
	decl String:arg[65],  String:steamID[64], String:url[256];
	new bool:HasTarget = false;
	
	if(args < 1)
	{
		PrintToChat(client, "\x01사용법 : !bp 이름");
		return Plugin_Handled;
	}
		
	GetCmdArg(1, arg, sizeof(arg));
		
	HasTarget = true;	
	
	decl String:target_name[MAX_TARGET_LENGTH];
	
	if (HasTarget)
	{
		decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
		
		if ((target_count = ProcessTargetString(
				arg,
				client,
				target_list,
				MAXPLAYERS,
				COMMAND_FILTER_CONNECTED,
				target_name,
				sizeof(target_name),
				tn_is_ml)) <= 0)
		{
			ReplyToTargetError(client, target_count);
			return Plugin_Handled;
		}
		
		for (new i = 0; i < target_count; i++)
		{
			Steam_GetCSteamIDForClient(target_list[i], steamID, sizeof(steamID));
			Format(url, sizeof(url), "http://steamcommunity.com/profiles/%s/inventory/", steamID);
			ShowMOTDPanel(target_list[i], "profile link", url, MOTDPANEL_TYPE_URL);

		}
	}
	return Plugin_Handled;
}
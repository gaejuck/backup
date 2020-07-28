#include <sourcemod>
#include <sdktools>

public Plugin:myinfo =
{
	name = "server time hud",
	author = "ㅣ",
	description = "시간 종합 세트",
	version = "1.0",
	url = "http://steamcommunity.com/id/ssssssssaaaaaaazzzzzxxc"
}

new Handle:hudText;
new Handle:hudText2;
new Handle:hudText3;

new String:ServerConfig[120];

public OnPluginStart()
{
	LoadTranslations("sth.phrases");
	
	BuildPath(Path_SM, ServerConfig, sizeof(ServerConfig), "configs/sth.txt");
	
	hudText = CreateHudSynchronizer();
	hudText2 = CreateHudSynchronizer();
	hudText3 = CreateHudSynchronizer();
}

public OnMapStart()
{
	CreateTimer(0.2, Timer, _,TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action:Timer(Handle:Timer)
{
	new Handle:DB = CreateKeyValues("server_time");
	 
	decl String:year[21];
	decl String:mon[21];
	decl String:day[21];
	
	FormatTime(year, sizeof(year), "%Y", -1);
	FormatTime(mon, sizeof(mon), "%m", -1);
	FormatTime(day, sizeof(day), "%d", -1);
	
	decl String:AM_PM[21];
	decl String:Hour[21];
	decl String:minute[21];
	decl String:second[21];
	
	FormatTime(AM_PM, sizeof(AM_PM), "%p", -1);
	FormatTime(Hour, sizeof(Hour), "%I", -1);
	FormatTime(minute, sizeof(minute), "%M", -1);
	FormatTime(second, sizeof(second), "%S", -1);
		
	decl String:weekday[21];
	
	FormatTime(weekday, sizeof(weekday), "%A", -1);
		
	FileToKeyValues(DB, ServerConfig);
		
	new Float:weekday_x = KvGetFloat(DB, "weekday_x", 0.0);
	new Float:weekday_y = KvGetFloat(DB, "weekday_y", 0.0);
	
	new weekday_r = KvGetNum(DB, "weekday_r", 0);
	new weekday_g = KvGetNum(DB, "weekday_g", 0);
	new weekday_b = KvGetNum(DB, "weekday_b", 0);
	
	new Float:ymd_x = KvGetFloat(DB, "ymd_x", 0.0);
	new Float:ymd_y = KvGetFloat(DB, "ymd_y", 0.0);

	new ymd_r = KvGetNum(DB, "ymd_r", 0);
	new ymd_g = KvGetNum(DB, "ymd_g", 0);
	new ymd_b = KvGetNum(DB, "ymd_b", 0);
	
	new Float:time_x = KvGetFloat(DB, "time_x", 0.0);
	new Float:time_y = KvGetFloat(DB, "time_y", 0.0);

	new time_r = KvGetNum(DB, "time_r", 0);
	new time_g = KvGetNum(DB, "time_g", 0);
	new time_b = KvGetNum(DB, "time_b", 0);

	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			new String:W[32];
			
			if(StrEqual(weekday, "Monday", false)) 
				Format(W, sizeof(W), "%T", "Monday", i);
				
			else if(StrEqual(weekday, "Tuesday", false))
				Format(W, sizeof(W), "%T", "Tuesday", i);
				
			else if(StrEqual(weekday, "Wednesday", false))
				Format(W, sizeof(W), "%T", "Wednesday", i);
				
			else if(StrEqual(weekday, "Thursday", false))
				Format(W, sizeof(W), "%T", "Thursday", i);
				
			else if(StrEqual(weekday, "Friday", false))
				Format(W, sizeof(W), "%T", "Friday", i);
				
			else if(StrEqual(weekday, "Saturday", false))
				Format(W, sizeof(W), "%T", "Saturday" ,i);
				
			else if(StrEqual(weekday, "Sunday", false))
				Format(W, sizeof(W), "%T", "Sunday", i);
				
			new String:AP[32];
				
			if(StrEqual(AM_PM, "AM", false))
				Format(AP, sizeof(AP), "%T", "AM", i);
			else if(StrEqual(AM_PM, "PM", false))
				Format(AP, sizeof(AP), "%T", "PM", i);
				
			SetHudTextParams(weekday_x, weekday_y, 1.09, weekday_r, weekday_g, weekday_b, 0, 0, 0.2, 0.0, 0.1);
			ShowSyncHudText(i, hudText, "%s", W);		

			SetHudTextParams(ymd_x, ymd_y, 1.09, ymd_r, ymd_g, ymd_b, 0, 0, 6.0, 0.1, 0.2); 
			ShowSyncHudText(i, hudText2, "%s%T %s%T %s%T",year, "year", i, mon, "mon", i, day, "day", i);
			
			SetHudTextParams(time_x, time_y, 1.09, time_r, time_g, time_b, 0, 0, 6.0, 0.1, 0.2);
			ShowSyncHudText(i, hudText3, "%s %s%T %s%T %s%T", AP, Hour, "Hour", i, minute, "Minute", i, second, "Second", i);
		}
	}
}
SetHudTextParams(0.01, 0.01, 0.1, 0, 255, 0, 255, 0, 0.0, 0.0, 0.0);
ShowHudText(i, 50, "Health: Green");

native ShowHudText(client, channel, const String:message[], any:...);

csay같은 허드를 말하며 한번 띄우면 사라진다.


https://github.com/yomox9/scripting/blob/12bc252a729b84d7213b65c542f5b11fffb6a5bf/healthdisp.sp
//--------------------------------------------------------------------------------------

new Handle:hudText;

public OnPluginStart()
{
	hudText = CreateHudSynchronizer();
}

SetHudTextParams(0.05, 0.15, 1.09, 0, 255, 234, 255, 0, 6.0, 0.1, 0.2);
ShowSyncHudText(i, hudText, "ㅁㄴㅇ");

native ShowSyncHudText(client, Handle:sync, const String:message[], any:...);

https://github.com/xetrov/surfwatch/blob/3d39f95e85c3a4056e0190f3219d421ad8ca05ac/addons/sourcemod/scripting/surfwatch.sp
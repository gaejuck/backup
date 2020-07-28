public Action:Timer_Load(Handle:hTimer, Handle:hPack)
{
	ResetPack(hPack);
	new client = ReadPackCell(hPack)

	decl String:FileName[256],  String:name[256];
	ReadPackString(hPack, FileName, sizeof(FileName));
	ReadPackString(hPack, name, sizeof(name));
}
//이렇게 만들고 나서!

new Handle:hTemp;

new Float:fDelay = 0.10;

CreateDataTimer(fDelay, Timer_Load, hTemp, TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE | TIMER_DATA_HNDL_CLOSE);

WritePackCell(hTemp, client);
WritePackString(hTemp, FileName);
WritePackString(hTemp, name);
fDelay += 0.10;
LoadCount[client] = 0; 
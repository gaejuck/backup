#include <sourcemod>
#include <tf2items>
#include <tf2_stocks>
#include <sdkhooks>

new bool:aaa[MAXPLAYERS+1] = false;

new bool:at, bool:j, bool:duck, bool:w, bool:akey, bool:s, bool:d;

public OnPluginStart()
{
	RegConsoleCmd("sm_ag", aaaa);
	RegConsoleCmd("sm_ag2", aaaa2);
}

public Action:aaaa2(client, args)
{
	if(!aaa[client])
	{
		aaa[client] = true;
		PrintToChat(client, "ok");
	}
	else
	{
		aaa[client] = false;
		PrintToChat(client, "no");
	}
}

public Action:aaaa(client, args)
{
	decl String:path[PLATFORM_MAX_PATH];

	BuildPath(Path_SM,path,PLATFORM_MAX_PATH,"REC 161112_001146.csv");
	// BuildPath(Path_SM,path,PLATFORM_MAX_PATH,"REC 161112_155225.csv");
	
	new Handle:hTemp, Handle:_hFile, Float:fDelay = 0.1;
	decl String:_sFileBuffer[512];

	if (FileExists(path, true))
	{
		_hFile = OpenFile(path, "r");
		
		while (ReadFileLine(_hFile, _sFileBuffer, sizeof(_sFileBuffer)))
		{
			CreateDataTimer(fDelay, Timer_Load, hTemp);
				
			WritePackCell(hTemp, client);
			WritePackString(hTemp, _sFileBuffer);
		
			fDelay += 0.03;
		}
		FlushFile(_hFile);
		CloseHandle(_hFile);
	} 
	else
	{
		EmitSoundToClient(client, "replay/cameracontrolerror.wav");
		PrintToChat(client, "파일이 없습니다.");
	}
	return Plugin_Handled;
}

// new Float:fOrigin[3], Float:fVelocity[3], Float:fAngle[3];
new Float:fOrigin[3], Float:fAngle[3];

public Action:Timer_Load(Handle:hTimer, Handle:hPack)
{
	ResetPack(hPack);
	new client = ReadPackCell(hPack);
	
	if(!aaa[client])
		return Plugin_Stop;

	decl String:sbuffer[256], String:sBuffers[13][256]; //12
	ReadPackString(hPack, sbuffer, sizeof(sbuffer));

	// decl Float:fOrigin[3], Float:fVelocity[3], Float:fAngle[3];
	
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", fOrigin);
	// GetEntPropVector(client, Prop_Data, "m_vecVelocity", fVelocity);
	GetClientEyeAngles(client, fAngle);
	
	ExplodeString(sbuffer, ",", sBuffers, 13, 256);
	
	fOrigin[0] = StringToFloat(sBuffers[0]);
	fOrigin[1] = StringToFloat(sBuffers[1]);
	fOrigin[2] = StringToFloat(sBuffers[2]);
	
	// fVelocity[0] = StringToFloat(sBuffers[3]);
	// fVelocity[1] = StringToFloat(sBuffers[4]);
	// fVelocity[2] = StringToFloat(sBuffers[5]);
	
	fAngle[0] = StringToFloat(sBuffers[3]);
	fAngle[1] = StringToFloat(sBuffers[4]);
	fAngle[2] = StringToFloat(sBuffers[5]);
	
	if(StrEqual(sBuffers[6], "w")) w=true;
	else w=false;
		
	if(StrEqual(sBuffers[7], "akey")) akey=true;
	else akey=false;
		
	if(StrEqual(sBuffers[8], "s")) s=true;
	else s=false;
		
	if(StrEqual(sBuffers[9], "d")) d=true;
	else d=false;
		
	if(StrEqual(sBuffers[10], "at")) at=true;
	else at=false;
		
	if(StrEqual(sBuffers[11], "du")) duck=true;
	else duck=false;
		
	if(StrEqual(sBuffers[12], "j")) j=true;
	else j=false;
	
	PrintToChat(client, "%s %s %s | %s %s %s %s", sBuffers[6], sBuffers[7], sBuffers[8], sBuffers[9], sBuffers[10], sBuffers[11], sBuffers[12]);
	
	new Float:vel[3], Float:angles[3], Float:fwdvec[3], Float:rightvec[3], Float:upvec[3];
			
	angles[0] = fAngle[0];
	angles[1] = fAngle[1];
	angles[2] = fAngle[2];
			
	GetAngleVectors(angles, fwdvec, rightvec, upvec);
			
	if(w)
	{
		vel[0] += fwdvec[0] * 200.0;
		vel[1] += fwdvec[1] * 200.0;
	}
			
	// new iButtons = GetClientButtons(client);
	
	// if(w) iButtons |= IN_FORWARD;
	// else iButtons &= ~IN_FORWARD
	if(s)
	{
		vel[0] += fwdvec[0] * -200.0;
		vel[1] += fwdvec[1] * -200.0;
	}
	if(akey)
	{
		vel[0] += rightvec[0] * -200.0;
		vel[1] += rightvec[1] * -200.0;
	}
	if(d)
	{
		vel[0] += rightvec[0] * 200.0;
		vel[1] += rightvec[1] * 200.0;
	}
	if(j)
	{
		new flags = GetEntityFlags(client);
		if(flags & FL_ONGROUND)
		{
			vel[2] += 2000.0;
		}
	}
	
	TeleportEntity(client, NULL_VECTOR, fAngle, vel);
	return Plugin_Continue;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
	if(AliveCheck(client) && aaa[client])
	{
		// if(w) vel[0] = 300.0;
		// else if(s) vel[0] = -300.0;
		// else vel[0] = 0.0;
					
		// if(akey) vel[1] = -300.0;
		// else if(d) vel[1] = 300.0;
		// else vel[1] = 0.0;
					
					
		// if (w) buttons |= IN_FORWARD;
		// else buttons &= ~IN_FORWARD
		
		if (at) buttons |= IN_ATTACK;
		else buttons &= ~IN_ATTACK;

		if (duck) buttons |= IN_DUCK;
		else buttons &= ~IN_DUCK;
		
		// if (j) 
		// {	
			// new flags = GetEntityFlags(client);
			// if(flags & FL_ONGROUND) vel[2] += 2000.0;
		// }
		return Plugin_Changed;
	}
	return Plugin_Continue;
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

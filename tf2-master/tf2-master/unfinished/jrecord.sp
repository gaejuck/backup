#include <sourcemod>
#include <sdktools>


new clientRecording;
new Handle:outputFile;


public Plugin:myinfo = {
	name = "JRecord",
	author = "talkingmelon",
	description = "Records to csv",
	version = ".1",
	url = "http://www.tf2rj.com"
};



public OnPluginStart(){

	RegConsoleCmd("sm_rec", Command_Record, "Records");
	RegConsoleCmd("sm_st", Command_StopRecord, "Stops");
	RegConsoleCmd("sm_tog", Command_ToggleRecord, "Stops");

}

public Action:Command_Record(client, args){
	clientRecording = client;

	decl String:path[PLATFORM_MAX_PATH];
	decl String:dateTime[1024];
	new time = GetTime();
	FormatTime(dateTime, sizeof(dateTime), "%y%m%d_%H%M%S", time);
	BuildPath(Path_SM,path,PLATFORM_MAX_PATH,"REC %s.csv", dateTime);
	PrintToChat(client,path);
	outputFile = OpenFile(path, "w+");

	if(outputFile == INVALID_HANDLE){
		PrintToChat(client, "An error occured while creating the file");
		clientRecording = 0;
	}else{
		WriteFileString(outputFile, "xloc,yloc,zloc,xvel,yvel,zvel,pitch,yaw,roll,attack,jump,duck\n", false);
	}
}


public Action:Command_StopRecord(client, args){
	clientRecording = 0;
	if(outputFile !=  INVALID_HANDLE){
		CloseHandle(outputFile);
	}
	PrintToChat(client, "Stopped Recording");
}

public Action:Command_ToggleRecord(client, args){
	if(clientRecording){
		Command_StopRecord(client, 0);
	}else{
		Command_Record(client, 0);
	}
}


public OnGameFrame(){
	if(clientRecording){
		decl Float:angle[3];
		// decl Float:v[3];
		decl Float:l[3];

		decl button;
		new bool:at, bool:j, bool:duck;
		new bool:w, bool:a, bool:s, bool:d;

		GetEntPropVector(clientRecording, Prop_Data, "m_vecOrigin", l);
		GetClientEyeAngles(clientRecording, angle);
		// GetEntPropVector(clientRecording, Prop_Data, "m_vecVelocity", v);

		button = GetClientButtons(clientRecording);
		if(button & IN_ATTACK){
			at=true;
		}
		if(button & IN_JUMP){
			j=true;
		}
		if(button & IN_DUCK){
			duck=true;
		}
		
		if(button & IN_FORWARD){
			w=true;
		}
		
		if(button & IN_MOVELEFT){
			a=true;
		}
		
		if(button & IN_BACK){
			s=true;
		}
		
		if(button & IN_MOVERIGHT){
			d=true;
		}

		new String:buttonBuffer[16];
			
		if(w)
			Format(buttonBuffer, sizeof(buttonBuffer), "%sw,", buttonBuffer);
		else
			Format(buttonBuffer, sizeof(buttonBuffer), "%s0,", buttonBuffer);
			
		if(a)
			Format(buttonBuffer, sizeof(buttonBuffer), "%sa,", buttonBuffer);
		else
			Format(buttonBuffer, sizeof(buttonBuffer), "%s0,", buttonBuffer);
			
		if(s)
			Format(buttonBuffer, sizeof(buttonBuffer), "%ss,", buttonBuffer);
		else
			Format(buttonBuffer, sizeof(buttonBuffer), "%s0,", buttonBuffer);
			
		if(d)
			Format(buttonBuffer, sizeof(buttonBuffer), "%sd,", buttonBuffer);
		else
			Format(buttonBuffer, sizeof(buttonBuffer), "%s0,", buttonBuffer);
			
		if(at)
			Format(buttonBuffer, sizeof(buttonBuffer), "%sat,", buttonBuffer);
		else
			Format(buttonBuffer, sizeof(buttonBuffer), "%s0,", buttonBuffer);

		if(duck)
			Format(buttonBuffer, sizeof(buttonBuffer), "%sdu,", buttonBuffer);
		else
			Format(buttonBuffer, sizeof(buttonBuffer), "%s0,", buttonBuffer);
		
		if(j)
			Format(buttonBuffer, sizeof(buttonBuffer), "%sj", buttonBuffer);
		else
			Format(buttonBuffer, sizeof(buttonBuffer), "%s0", buttonBuffer);
		


		new String:buffer[512];
		Format(buffer, sizeof(buffer), "%f,%f,%f,%f,%f,%f,%s\n", l[0],l[1],l[2],angle[0],angle[1],angle[2], buttonBuffer);

		WriteFileString(outputFile, buffer, false);


	}
}
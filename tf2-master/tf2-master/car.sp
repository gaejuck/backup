#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <emitsoundany>
#pragma semicolon 1

#define VEHICLE_TYPE_CAR_WHEELS			(1 << 0) //1
#define VEHICLE_TYPE_CAR_RAYCAST		(1 << 1) //2
#define VEHICLE_TYPE_JETSKI_RAYCAST		(1 << 2) //4
#define VEHICLE_TYPE_AIRBOAT_RAYCAST	(1 << 3) //8

new bool:CanThirdperson[MAXPLAYERS+1];
new g_vViewControll[2048+1] = {INVALID_ENT_REFERENCE, ... };

new bool:g_bWaitingForPlayers;

new bool:Horn[MAXPLAYERS+1];

public OnPluginStart()
{ 
	RegAdminCmd("car", CMD_VehicleBuggy, 0);
	RegAdminCmd("carr", CMD_VehicleBuggy2, ADMFLAG_KICK);
	RegConsoleCmd("carview", CMD_ViewCar);

	AddCommandListener(MEEM, "voicemenu");
	
	HookEntityOutput("prop_vehicle_driveable", "PlayerOn", PlayerOn);
	HookEntityOutput("prop_vehicle_driveable", "PlayerOff", PlayerOff);
	
	HookEvent("player_death", Event_Death, EventHookMode_Pre);
	HookEvent("player_spawn", Event_Death, EventHookMode_Pre);
	
	for(new i = 1; i <= MaxClients; i++)
	{
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}

//------------------------- 대기 시간에 사용 불능 --------------------------------
public TF2_OnWaitingForPlayersStart() g_bWaitingForPlayers = true;
public TF2_OnWaitingForPlayersEnd() g_bWaitingForPlayers = false;

//------------------------- 라운드 끝났을 때 -------------------------------------
public OnPluginEnd()
{
	new ent = -1;
	while((ent = FindEntityByClassname(ent, "prop_vehicle_driveable")) != -1)
	{
		if(GetEntPropEnt(ent, Prop_Send, "m_hPlayer") != -1)
		{
			CalcExit(GetEntPropEnt(ent, Prop_Send, "m_hPlayer"), ent);
		}
		AcceptEntityInput(ent, "kill");
	}
}

//------------------------- 맵 시작할 때, 프리 캐시 -------------------------------------
#define CAR "models/natalya/vehicles/dodge_charger_1969.mdl"
#define CARS "scripts/vehicles/69chargersticky.txt"

#define CAR2 "models/natalya/vehicles/ford_gt_2.mdl"
#define CAR2S "scripts/vehicles/ford_gt.txt"

#define CAR3 "models/natalya/vehicles/natalyas_mustang_2.mdl"
#define CAR3S "scripts/vehicles/natalyas_mustang.txt"

#define TRUCK "models/natalya/vehicles/tacoma_v3.mdl"
#define TRUCKS "scripts/vehicles/tacoma.txt"

#define POLICE "models/natalya/vehicles/police_crown_victoria.mdl"
#define POLICES "scripts/vehicles/police_cv.txt"

#define BIKE "models/natalya/vehicles/dirtbike.mdl"
#define BIKES "scripts/vehicles/dirtbike.txt"

#define BUGGY "models/buggy.mdl"
#define BUGGYS "scripts/vehicles/buggy.txt"

#define AIRBOAT "models/airboat.mdl"
#define AIRBOATS "scripts/vehicles/airboat.txt"

public OnMapStart()
{
	PrecacheModel(CAR);
	PrecacheModel(CAR2);
	PrecacheModel(CAR3);
	PrecacheModel(TRUCK);
	PrecacheModel(POLICE);
	PrecacheModel(BIKE);
	PrecacheModel(BUGGY);
	PrecacheModel(AIRBOAT);
	
	PrecacheSound("vehicles/mustang_horn.mp3", true);
	PrecacheSound("natalya/doors/default_locked.mp3", true);
}

//------------------------- 접속 했을 때 -------------------------------------
public OnClientPutInServer(client)
{
	Horn[client] = true;
	CanThirdperson[client] = true;
	SDKHook(client, SDKHook_OnTakeDamage, OnClientTakeDamage);
}

//------------------------- use키 사용 커맨드 -------------------------------------

public OnConfigsExecuted()
{
	SetConVarInt(FindConVar("tf_allow_player_use"), 1, true);
}

//------------------------- E키 사용 커맨드 -------------------------------------

public Action:MEEM(client, const String:command[], argc)
{
	if(!PlayerCheck(client) && !IsPlayerAlive(client)) return Plugin_Continue;
	
	new String:args[5];
	GetCmdArgString(args, sizeof(args));
	if (StrEqual(args, "0 0"))
	{
		new Vehicle = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
		if(IsValidEntity(Vehicle)) CalcExit(client, Vehicle);
		else
		{
			decl Float:car_origin[3], Float:CPOS[3], Float:Dist;
			
			new ent = Target_Drive(client);	
			if(IsValidEntity(ent))
			{
				GetEntPropVector(ent, Prop_Send, "m_vecOrigin", car_origin);
				GetClientAbsOrigin(client, CPOS);
				
				Dist = GetVectorDistance(car_origin, CPOS);
				
				if(Dist <= 100)
				{
					SetEntProp(ent, Prop_Send, "m_nSolidType", 2);
					SetEntProp(ent, Prop_Data, "m_nNextThinkTick", -1);
					
					SetEntProp(ent, Prop_Send, "m_iTeamNum", GetEntProp(client, Prop_Send, "m_iTeamNum"));	
					SetEntProp(ent, Prop_Send, "m_bEnterAnimOn", 0);
					SetEntProp(ent, Prop_Send, "m_bExitAnimOn", 0);
					SetEntProp(ent, Prop_Data, "m_nVehicleType", VEHICLE_TYPE_CAR_WHEELS);
					SetVariantFloat(0.0);
					AcceptEntityInput(ent, "Throttle", client, client);
					SetVariantFloat(0.0);
					AcceptEntityInput(ent, "Steer", client, client);
					AcceptEntityInput(ent, "TurnOn");
					AcceptEntityInput(ent, "HandBrakeOff");
					SetEntityMoveType(ent, MOVETYPE_VPHYSICS);
					
					new String:Name[10], Float:ang[3];
					IntToString(ent, Name, 10);
					GetClientEyeAngles(client, ang);
					CreateCamera(ent, Name, ang);
					
					AcceptEntityInput(ent, "use", client);
					FakeClientCommandEx(client, "-use"); 
					FakeClientCommandEx(client, "+use"); 

					EmitSoundToAllAny("natalya/doors/default_locked.mp3", ent, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
				}
			}
		}
	}
	return Plugin_Continue;
}

//------------------------- 차 훅 -------------------------------------
public PlayerOn(const String:output[], caller, activator, Float:delay)
{
	PrintToChatAll("%N Entered car", activator);
	
	if(IsValidEntity(g_vViewControll[caller]))
		SetClientViewEntity(activator, g_vViewControll[caller]);
	else
		PrintToChat(activator, "Failed to set camera");
	CreateTimer(0.1, Timer_PlayerOn, activator);
}

public PlayerOff(const String:output[], caller, activator, Float:delay)
{
	PrintToChatAll("%N Exit car", activator);
	SetClientViewEntity(activator, activator);
}

public Action:Timer_PlayerOn(Handle:timer, any:activator)
{
	new EntEffects = GetEntProp(activator, Prop_Send, "m_fEffects");
	EntEffects &= ~32;
	SetEntProp(activator, Prop_Send, "m_fEffects", EntEffects);
	new hud = GetEntProp(activator, Prop_Send, "m_iHideHUD");
	hud &= ~1;
	hud &= ~256;
	hud &= ~1024;
	SetEntProp(activator, Prop_Send, "m_iHideHUD", hud);
	SetEntProp(activator, Prop_Send, "m_bDucked", 1);
	SetEntProp(activator, Prop_Send, "m_bDucking", 1);
	SetEntityFlags(activator, GetEntityFlags(activator)|FL_DUCKING);
	if(GetPlayerWeaponSlot(activator, 2) != -1)
	{
		SetEntPropEnt(activator, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(activator, 2));
	}
	new String:model[PLATFORM_MAX_PATH];
	GetClientModel(activator, model, sizeof(model));
	SetVariantString(model);
	AcceptEntityInput(activator, "SetCustomModel", activator, activator);
	SetVariantInt(1);
	AcceptEntityInput(activator, "SetCustomModelRotates", activator, activator);
	SetEntProp(activator, Prop_Send, "m_bUseClassAnimations", 1);
	CreateTimer(0.1, Timer_DisableAnim, activator);
	SetEntProp(activator, Prop_Send, "m_bDrawViewmodel", 0);
}

public Action:Timer_DisableAnim(Handle:timer, any:activator)
{
	SetEntProp(activator, Prop_Send, "m_bUseClassAnimations", 0);
}

//------------------------- 명령어 -------------------------------------

public Action:CMD_VehicleBuggy(client, args)
{
	if(g_bWaitingForPlayers)
	{
		PrintToChat(client, "라운드 시작후 사용해 주세요");
		return Plugin_Handled;
	}
	new Handle:menu = CreateMenu(Car_Menu);
	SetMenuTitle(menu, "자동차 메뉴");
	AddMenuItem(menu, "1", "멋진 차");  
	AddMenuItem(menu, "1", "멋진 차2");  
	AddMenuItem(menu, "1", "멋진 차3");  
	AddMenuItem(menu, "1", "트럭");  
	AddMenuItem(menu, "1", "경찰 차");  
	AddMenuItem(menu, "1", "오토바이");  
	AddMenuItem(menu, "1", "버기");  
	AddMenuItem(menu, "1", "에어보트");  
	SetMenuExitButton(menu, true);

	DisplayMenu(menu, client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

public Action:CMD_VehicleBuggy2(client, args)
{
	new ent = -1;
	while((ent = FindEntityByClassname(ent, "prop_vehicle_driveable")) != -1)
	{
		if(GetEntPropEnt(ent, Prop_Send, "m_hPlayer") != -1)
		{
			CalcExit(GetEntPropEnt(ent, Prop_Send, "m_hPlayer"), ent);
		}
		AcceptEntityInput(ent, "kill");
	}
	return Plugin_Handled;
}

public Car_Menu(Handle:menu, MenuAction:action, client, select)
{
	if(action == MenuAction_Select)
	{
		new car = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
		if(car != -1)
		{
			CalcExit(GetEntPropEnt(car, Prop_Send, "m_hPlayer"), car);
			AcceptEntityInput(car,"KillHierarchy");
			RemoveEdict(car);
		}
		
		if(select == 0)
		{
			SpawnVehicle(client, CAR, CARS, VEHICLE_TYPE_CAR_WHEELS);
		}
		
		if(select == 1)
		{
			SpawnVehicle(client, CAR2, CAR2S, VEHICLE_TYPE_CAR_WHEELS);
		}
		if(select == 2)
		{
			SpawnVehicle(client, CAR3, CAR3S, VEHICLE_TYPE_CAR_WHEELS);
		}
		
		if(select == 3)
		{
			SpawnVehicle(client, TRUCK, TRUCKS, VEHICLE_TYPE_CAR_RAYCAST);
		}
		
		if(select == 4)
		{
			SpawnVehicle(client, POLICE, POLICES, VEHICLE_TYPE_CAR_WHEELS);
		}
		
		if(select == 5)
		{
			SpawnVehicle(client, BIKE, BIKES, VEHICLE_TYPE_CAR_RAYCAST);
		}
		
		if(select == 6)
		{
			SpawnVehicle(client, BUGGY, BUGGYS, VEHICLE_TYPE_CAR_WHEELS);
		}
		
		if(select == 7)
		{
			SpawnVehicle(client, AIRBOAT, AIRBOATS, VEHICLE_TYPE_AIRBOAT_RAYCAST);
		}
		
		PrintToChat(client, "\x04차를 타고 있는 상태에서 차를 고를시 차가 사라집니다.");
		PrintToChat(client, "\x04앉기 키를 누르면 1인칭, 3인칭이 됩니다.");
		PrintToChat(client, "\x04E키를 누르면 차에서 내립니다.");
		PrintToChat(client, "\x04다시 E키를 누르면 차를 탈 수 있습니다.");
		PrintToChat(client, "\x04좌 클릭으로 경적을 낼 수 있습니다.");
	}
	else if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}

public Action:CMD_ViewCar(client, args)
{
	new Vehicle = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
	if(IsValidEntity(Vehicle))
	{
		SetClientViewEntity(client, g_vViewControll[Vehicle]);
	}
	else
	{
		PrintToChat(client, "Invalid vehicle");
	}
		
	return Plugin_Handled;
}

//------------------------- 이벤트 -------------------------------------

public Action:Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (client > MaxClients || client <= 0) return;
	if (GetEventInt(event, "death_flags") & 32) return;
	new ViewEnt = GetEntPropEnt(client, Prop_Data, "m_hViewEntity");
	
	if (ViewEnt > MaxClients)
	{
		new String:cls[25];
		GetEntityClassname(ViewEnt, cls, sizeof(cls));
		if (StrEqual(cls, "point_viewcontrol", false)) SetClientViewEntity(client, client);
	}
}

//------------------------- 데미지 훅 -------------------------------------

public Action:OnClientTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(damagetype & DMG_VEHICLE)
	{
		new String:classname[30];
		GetEntityClassname(inflictor, classname, sizeof(classname));
		if(StrEqual("prop_vehicle_driveable", classname, false))
		{
			new Driver = GetEntPropEnt(inflictor, Prop_Send, "m_hPlayer");
			if(Driver != -1)
			{
				damage *= 2.0;
				if(victim != Driver)
				{
					new DriverTeam = GetEntProp(Driver, Prop_Send, "m_iTeamNum");
					new VictimTeam = GetEntProp(victim, Prop_Send, "m_iTeamNum");
					if(VictimTeam == DriverTeam)
					{
						return Plugin_Handled;
					}
					attacker = Driver;
					return Plugin_Changed;
				}
				return Plugin_Changed;
			}
		}
	}
	return Plugin_Continue;
}

//------------------------- 키 -------------------------------------

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vec[3], Float:angles[3], &weapon, &subtype, &cmdnum, &tickcount, &seed, mouse[2]) //77
{
	new Vehicle = GetEntPropEnt(client, Prop_Send, "m_hVehicle");
	
	if(IsValidEntity(Vehicle))
	{
		SetEntPropFloat(Vehicle, Prop_Data, "m_flTurnOffKeepUpright", 1.0);
		if (GetEntProp(Vehicle, Prop_Send, "m_bEnterAnimOn") == 1)
		{
			SetEntProp(Vehicle, Prop_Send, "m_bEnterAnimOn", 0);
			SetEntProp(Vehicle, Prop_Send, "m_nSequence", 0);
		}
		
		new Float:ang[3];
		GetEntPropVector(Vehicle, Prop_Data, "m_angRotation", ang);
		ang[0] = 0.0;
		ang[1] += 90.0;
		ang[2] = 0.0;
		SetVariantVector3D(ang);
		AcceptEntityInput(client, "SetCustomModelRotation", client, client);
		if(buttons & IN_FORWARD)
		{
			SetVariantFloat(0.65);
			AcceptEntityInput(Vehicle, "Throttle", client, client);
		}
		if(buttons & IN_BACK)
		{
			SetVariantFloat(-0.65);
			AcceptEntityInput(Vehicle, "Throttle", client, client);
		}
		if(!(buttons & IN_FORWARD) && !(buttons & IN_BACK))
		{
			SetVariantFloat(0.0);
			AcceptEntityInput(Vehicle, "Throttle", client, client);
		}
		if(buttons & IN_MOVELEFT && !(buttons & IN_MOVERIGHT))
		{
			SetVariantFloat(-0.6);
			AcceptEntityInput(Vehicle, "Steer", client, client);
		}
		if(buttons & IN_MOVERIGHT && !(buttons & IN_MOVELEFT))
		{
			SetVariantFloat(0.6);
			AcceptEntityInput(Vehicle, "Steer", client, client);
		}
		if(!(buttons & IN_MOVELEFT) && !(buttons & IN_MOVERIGHT))
		{
			SetVariantFloat(0.0);
			AcceptEntityInput(Vehicle, "Steer", client, client);
		}
		if(buttons & IN_DUCK)
		{
			if(CanThirdperson[client] == true)
			{
				switch(GetEntProp(client, Prop_Send, "m_nForceTauntCam"))
				{
					case 1: SetEntProp(client, Prop_Send, "m_nForceTauntCam", 0);
					case 0: SetEntProp(client, Prop_Send, "m_nForceTauntCam", 1);
				}
				CanThirdperson[client] = false;
				CreateTimer(1.0, Timer_ResetThirdperson, client);
			}
		}
		
		if(buttons & IN_ATTACK)
		{
			if(!Horn[client])
			{
				EmitSoundToAllAny("vehicles/mustang_horn.mp3", Vehicle, SNDCHAN_AUTO, SNDLEVEL_AIRCRAFT);
				Horn[client] = true;
			}
		}
		else Horn[client] = false;
		
		if(buttons & IN_JUMP)
		{
			decl Float:Aimposition[3], Float:car_origin[3], Float:vector[3];
			
			GetEntPropVector(Vehicle, Prop_Send, "m_vecOrigin", car_origin);
			GetEntPropVector(Vehicle, Prop_Data, "m_angRotation", Aimposition);
			
			MakeVectorFromPoints(car_origin, Aimposition, vector);
			
			NormalizeVector(vector, vector);
			ScaleVector(vector, 300.0);
			vector[2] += 500.0;
			TeleportEntity(Vehicle, NULL_VECTOR, NULL_VECTOR, vector);
		}
	}
}

public Action:Timer_ResetThirdperson(Handle:timer, any:client)
{
	CanThirdperson[client] = true;
}

//------------------------- 카 솬 -------------------------------------

public SpawnVehicle(client, const String:model[], const String:script[], vehicletype)
{
	new Vehicle = CreateEntityByName("prop_vehicle_driveable");
	if(Vehicle != -1)
	{
		new String:Name[10];
		new Float:pos[3], Float:ang[3];
		GetClientEyeAngles(client, ang);
		GetClientAbsOrigin(client, pos); 
		IntToString(Vehicle, Name, 10);
		DispatchKeyValue(Vehicle, "targetname", Name);
		DispatchKeyValue(Vehicle, "model", model);
		DispatchKeyValue(Vehicle, "vehiclescript", script);
		DispatchKeyValue(Vehicle, "solid", "6");
		DispatchKeyValue(Vehicle, "skin", "0");
		DispatchKeyValue(Vehicle, "spawnflags", "1");
		DispatchKeyValue(Vehicle, "VehicleLocked", "0");
		DispatchKeyValue(Vehicle, "actionScale", "1");
		DispatchKeyValue(Vehicle, "EnableGun", "0");
		DispatchKeyValue(Vehicle, "ignorenormals", "0");
		DispatchKeyValue(Vehicle, "fadescale", "1");
		DispatchKeyValue(Vehicle, "fademindist", "-1");
		DispatchKeyValue(Vehicle, "screenspacefade", "0");
		SetEntProp(Vehicle, Prop_Send, "m_nSolidType", 2);
		SetEntProp(Vehicle, Prop_Data, "m_nNextThinkTick", -1);	
		
		DispatchKeyValueVector(Vehicle, "origin", pos); 
		DispatchKeyValueVector(Vehicle, "angles", ang); 
		DispatchSpawn(Vehicle);
		ActivateEntity(Vehicle);
		SetEntProp(Vehicle, Prop_Send, "m_iTeamNum", GetEntProp(client, Prop_Send, "m_iTeamNum"));	
		SetEntProp(Vehicle, Prop_Send, "m_bEnterAnimOn", 0);
		SetEntProp(Vehicle, Prop_Send, "m_bExitAnimOn", 0);
		SetEntProp(Vehicle, Prop_Data, "m_nVehicleType", vehicletype);
		SetVariantFloat(0.0);
		AcceptEntityInput(Vehicle, "Throttle", client, client);
		SetVariantFloat(0.0);
		AcceptEntityInput(Vehicle, "Steer", client, client);
		AcceptEntityInput(Vehicle, "TurnOn");
		AcceptEntityInput(Vehicle, "HandBrakeOff");
		SetEntityMoveType(Vehicle, MOVETYPE_VPHYSICS);
		
		CreateCamera(Vehicle, Name, ang);
		
		AcceptEntityInput(Vehicle, "use", client);
		FakeClientCommandEx(client, "+use"); 
		
		EmitSoundToAllAny("natalya/doors/default_locked.mp3", Vehicle, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
	}
}

stock CreateCamera(entity, const String:entityname[], Float:ang[3])
{
	new entCamera = CreateEntityByName("point_viewcontrol"); 
	if(IsValidEntity(entCamera)) 
	{ 
		DispatchKeyValue(entCamera, "targetname", "viewcontrol"); 
//		DispatchKeyValue(entCamera, "spawnflags", "10");	//Follow player & Infinite Hold Time
		SetVariantString("!activator");
		AcceptEntityInput(entCamera, "SetParent", entity);
		
		DispatchKeyValueVector(entCamera, "angles", ang); 
		
		SetVariantString("vehicle_driver_eyes");
		AcceptEntityInput(entCamera, "SetParentAttachment", entity);
		SetVariantString("vehicle_driver_eyes");
		AcceptEntityInput(entCamera, "SetParentAttachmentMaintainOffset"); 
		
		DispatchSpawn(entCamera);
		ActivateEntity(entCamera);
		g_vViewControll[entity] = EntIndexToEntRef(entCamera);
		
		PrintToChatAll("Created camera for car %i", entity);
	}
}

//------------------------- 나가기 -------------------------------------
			
public CalcExit(client, vehicle)
{
	new Float:ExitPoint[3];
	if(!IsExitClear(client, vehicle, 90.0, ExitPoint))
	{
		if(!IsExitClear(client, vehicle, -90.0, ExitPoint))
		{
			if(!IsExitClear(client, vehicle, 0.0, ExitPoint))
			{
				if(!IsExitClear(client, vehicle, 180.0, ExitPoint))
				{
					new Float:ClientEye[3];
					GetClientEyePosition(client, ClientEye);
					new Float:ClientMinHull[3];
					new Float:ClientMaxHull[3];
					GetEntPropVector(client, Prop_Send, "m_vecMins", ClientMinHull);
					GetEntPropVector(client, Prop_Send, "m_vecMaxs", ClientMaxHull);
					new Float:TraceEnd[3];
					TraceEnd = ClientEye;
					TraceEnd[2] += 500.0;
					TR_TraceHullFilter(ClientEye, TraceEnd, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID, DontHitClientOrVehicle, client);
					new Float:CollisionPoint[3];
					if(TR_DidHit())
					{
						TR_GetEndPosition(CollisionPoint);
					}
					else
					{
						CollisionPoint = TraceEnd;
					}
					TR_TraceHull(CollisionPoint, ClientEye, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID);
					new Float:VehicleEdge[3];
					TR_GetEndPosition(VehicleEdge);
					new Float:ClearDistance = GetVectorDistance(VehicleEdge, CollisionPoint);
					if(ClearDistance >= 100.0)
					{
						ExitPoint = VehicleEdge;
						ExitPoint[2] += 100.0;
						if(TR_PointOutsideWorld(ExitPoint))
						{
							PrintToChat(client, "\x04No safe exit point found\x05");
							return;
						}
					}
					else
					{
						PrintToChat(client, "\x04No safe exit point found\x05");
						return;
					}
				}
			}
		}
	}
	//
	new String:car_ent_name[128];
	GetTargetName(vehicle, car_ent_name, sizeof(car_ent_name));		
	SetVariantString(car_ent_name);
	AcceptEntityInput(client, "SetParent");
	SetVariantString("vehicle_driver_exit");
	AcceptEntityInput(client, "SetParentAttachment");
	//
	
	SetVariantFloat(0.0);
	AcceptEntityInput(vehicle, "Throttle", client, client);
	SetVariantFloat(0.0);
	AcceptEntityInput(vehicle, "Steer", client, client);
	SetEntPropEnt(client, Prop_Send, "m_hVehicle", -1);
	SetEntPropEnt(vehicle, Prop_Send, "m_hPlayer", -1);
	SetEntityMoveType(client, MOVETYPE_WALK);
	AcceptEntityInput(client, "ClearParent", client, client);
	SetEntProp(client, Prop_Send, "m_CollisionGroup", 5);
	new EntEffects = GetEntProp(client, Prop_Send, "m_fEffects");
	EntEffects &= ~32;
	SetEntProp(client, Prop_Send, "m_fEffects", EntEffects);
	new hud = GetEntProp(client, Prop_Send, "m_iHideHUD");
	hud &= ~1;
	hud &= ~256;
	hud &= ~1024;
	SetEntProp(client, Prop_Send, "m_iHideHUD", hud);
	//추가
	SetEntProp(vehicle, Prop_Send, "m_nSpeed", 0);
	SetEntPropFloat(vehicle, Prop_Send, "m_flThrottle", 0.0);
	AcceptEntityInput(vehicle, "TurnOff");
	
	SetEntPropFloat(vehicle, Prop_Data, "m_flTurnOffKeepUpright", 0.0);
	
	SetEntProp(vehicle, Prop_Send, "m_iTeamNum", 0);
	//
		
	new Float:ExitAng[3];
	GetEntPropVector(vehicle, Prop_Data, "m_angRotation", ExitAng);
	ExitAng[0] = 0.0;
	ExitAng[1] += 90.0;
	ExitAng[2] = 0.0;
	TeleportEntity(client, ExitPoint, ExitAng, NULL_VECTOR);
	SetEntProp(client, Prop_Send, "m_bDucked", 0);
	SetEntProp(client, Prop_Send, "m_bDucking", 0);
	SetEntityFlags(client, GetEntityFlags(client) & ~FL_DUCKING);
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetEntPropEnt(client, Prop_Send, "m_hLastWeapon"));
	SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1);
	SetVariantString("");
	AcceptEntityInput(client, "SetCustomModel", client, client);
	SetEntProp(client, Prop_Send, "m_bUseClassAnimations", 1);
	SetVariantVector3D(Float:{0.0, 0.0, 0.0});
	AcceptEntityInput(client, "SetCustomModelRotation", client, client);
	SetClientViewEntity(client, client);
	if(GetEntProp(client, Prop_Send, "m_nForceTauntCam") == 1)
	{
		SetEntProp(client, Prop_Send, "m_nForceTauntCam", 0);
	}
}

public bool:IsExitClear(client, vehicle, Float:direction, Float:exitpoint[3])
{
	new Float:ClientEye[3];
	new Float:VehicleAngle[3];
	GetClientEyePosition(client, ClientEye);
	GetEntPropVector(vehicle, Prop_Data, "m_angRotation", VehicleAngle);
	new Float:ClientMinHull[3];
	new Float:ClientMaxHull[3];
	GetEntPropVector(client, Prop_Send, "m_vecMins", ClientMinHull);
	GetEntPropVector(client, Prop_Send, "m_vecMaxs", ClientMaxHull);
	VehicleAngle[0] = 0.0;
	VehicleAngle[2] = 0.0;
	VehicleAngle[1] += direction;
	new Float:DirectionVec[3];
	GetAngleVectors(VehicleAngle, NULL_VECTOR, DirectionVec, NULL_VECTOR);
	ScaleVector(DirectionVec, -500.0);
	new Float:TraceEnd[3];
	AddVectors(ClientEye, DirectionVec, TraceEnd);
	TR_TraceHullFilter(ClientEye, TraceEnd, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID, DontHitClientOrVehicle, client);
	new Float:CollisionPoint[3];
	if(TR_DidHit())
	{
		TR_GetEndPosition(CollisionPoint);
	}
	else
	{
		CollisionPoint = TraceEnd;
	}
	TR_TraceHull(CollisionPoint, ClientEye, ClientMinHull, ClientMaxHull, MASK_PLAYERSOLID);
	new Float:VehicleEdge[3];
	TR_GetEndPosition(VehicleEdge);
	new Float:ClearDistance = GetVectorDistance(VehicleEdge, CollisionPoint);
	if(ClearDistance >= 100.0)
	{
		MakeVectorFromPoints(VehicleEdge, CollisionPoint, DirectionVec);
		NormalizeVector(DirectionVec, DirectionVec);
		ScaleVector(DirectionVec, 100.0);
		AddVectors(VehicleEdge, DirectionVec, exitpoint);
		if(TR_PointOutsideWorld(exitpoint))
		{
			return false;
		}
		else
		{
			return true;
		}
	}
	else
	{
		return false;
	}
}

public bool:DontHitClientOrVehicle(entity, contentsMask, any:data)
{
	new Vehicle = GetEntPropEnt(data, Prop_Send, "m_hVehicle");
	return((entity != data) && (entity != Vehicle));
}

stock Target_Drive(client) {
	if(!IsPlayerAlive(client)) return -1;

	decl Float:flPos[3], Float:flAng[3];
	GetClientEyePosition(client, flPos);
	GetClientEyeAngles(client, flAng);
	new Handle:hTrace = TR_TraceRayFilterEx(flPos, flAng, MASK_SHOT, RayType_Infinite, TracerVehicleProp, client);

	if(hTrace != INVALID_HANDLE && TR_DidHit(hTrace)) {
		new ent = TR_GetEntityIndex(hTrace);
		if(ent <= 0) {
			CloseHandle(hTrace);
			return -1;
		}
		CloseHandle(hTrace);
		return ent;
	}
	CloseHandle(hTrace);
	return -1;
}

public bool:TracerVehicleProp(entity, contentsMask, any:client)
{
	if(entity >= 1 && entity <= MaxClients) return false;
	else {
		decl String:classname[20];
		if(GetEntityClassname(entity, classname, 64) && (StrEqual(classname, "prop_vehicle_driveable") )) return true;
	}
	return false;
}

stock GetTargetName(entity, String:buf[], len)
{
	GetEntPropString(entity, Prop_Data, "m_iName", buf, len);
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

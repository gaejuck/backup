#include <sourcemod>
#include <sdktools>

new FogIndex = -1;
new Float:mapFogStart = 0.0;
new Float:mapFogEnd = 150.0;
new Float:mapFogDensity = 0.99;

public OnPluginStart()
{
    RegAdminCmd("sm_fogoff", fogoff, ADMFLAG_ROOT, "");
    RegAdminCmd("sm_fogon", fogon, ADMFLAG_ROOT, "");
}
public OnMapStart()
{
    new ent; 
    ent = FindEntityByClassname(-1, "env_fog_controller");
    if (ent != -1) 
    {
        FogIndex = ent;
    }
    else
    {
        FogIndex = CreateEntityByName("env_fog_controller");
        DispatchSpawn(FogIndex);
    }
    DoFog();
    AcceptEntityInput(FogIndex, "TurnOff");
}

public Action:fogoff(client, args)
{AcceptEntityInput(FogIndex, "TurnOff");}    

public Action:fogon(client, args)
{AcceptEntityInput(FogIndex, "TurnOn");}

DoFog()
{
    if(FogIndex != -1) 
    {
        DispatchKeyValue(FogIndex, "fogblend", "0");
        DispatchKeyValue(FogIndex, "fogcolor", "0 0 0");
        DispatchKeyValue(FogIndex, "fogcolor2", "0 0 0");
        DispatchKeyValueFloat(FogIndex, "fogstart", mapFogStart);
        DispatchKeyValueFloat(FogIndex, "fogend", mapFogEnd);
        DispatchKeyValueFloat(FogIndex, "fogmaxdensity", mapFogDensity);
    }
}

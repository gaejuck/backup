#include <sourcemod> 
#include <sdkhooks> 
#include <tf2_stocks> 

public Plugin myinfo = { 
    name        = "[TF2] Backstab Only", 
    author      = "Arkarr", 
    description = "Only allow backstab.", 
    version     = "1.0.0", 
    url         = "http://www.sourcemod.net" 
}; 

public void OnPluginStart() 
{ 
    for (new i = 1; i <= MaxClients; i++) 
    { 
        if (IsClientInGame(i)) 
            SDKHook(i, SDKHook_OnTakeDamage, OnTakeDamage); 
    } 
} 

public OnClientPutInServer(client) 
{ 
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage); 
} 

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype) 
{ 
    if (damagetype != TF_CUSTOM_BACKSTAB) 
        return Plugin_Stop; 
         
    return Plugin_Continue; 
}  

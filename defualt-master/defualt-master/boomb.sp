#include <sdkhooks> 
#include <sdktools> 

public OnPluginStart()
{
	RegConsoleCmd("sm_tt", bbbbb);
}

public Action:bbbbb(client, args)
{
	new Float:flPos[3];
	GetClientEyeAngles(client,flPos);
	Explode(flPos, 50.0, 500.0, "halloween_explosion", "ui/duel_challenge_rejected_with_restriction.wav");
}

stock Explode(Float:flPos[3], Float:flDamage, Float:flRadius, const String:strParticle[], const String:strSound[])
{
    new iBomb = CreateEntityByName("tf_generic_bomb");
    DispatchKeyValueVector(iBomb, "origin", flPos);
    DispatchKeyValueFloat(iBomb, "damage", flDamage);
    DispatchKeyValueFloat(iBomb, "radius", flRadius);
    DispatchKeyValue(iBomb, "health", "1");
    DispatchKeyValue(iBomb, "explode_particle", strParticle);
    DispatchKeyValue(iBomb, "sound", strSound);
    DispatchSpawn(iBomb);

    AcceptEntityInput(iBomb, "Detonate");
}  

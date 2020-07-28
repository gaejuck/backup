public OnPluginStart()
{
    HookEvent("player_death", Event_PlayerDeathPost, EventHookMode_Post);
}


public Action:Event_PlayerDeathPost(Handle:event, const String:name[], bool:dontBroadcast)
{
    new victim = GetClientOfUserId(GetEventInt(event, "userid"));

    if (IsValidEntity(victim))
    {
        CreateTimer(0.1, Timer_DissolveRagdoll, any:victim);
    }
    return Plugin_Continue;
}


public Action:Timer_DissolveRagdoll(Handle:timer, any:victim)
{
    new ragdoll = GetEntPropEnt(victim, Prop_Send, "m_hRagdoll");

    if (ragdoll != -1)
    {
        DissolveRagdoll(ragdoll);
    }
}


DissolveRagdoll(ragdoll)
{
    new dissolver = CreateEntityByName("env_entity_dissolver");

    if (dissolver == -1)
    {
        return;
    }

    DispatchKeyValue(dissolver, "dissolvetype", "0");
    DispatchKeyValue(dissolver, "magnitude", "1");
    DispatchKeyValue(dissolver, "target", "!activator");

    AcceptEntityInput(dissolver, "Dissolve", ragdoll);
    AcceptEntityInput(dissolver, "Kill");

    return;
}  
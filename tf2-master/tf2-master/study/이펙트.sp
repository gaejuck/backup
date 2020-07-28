new g_LightningSprite;
new g_beamSprite;
new g_haloSprite;

public OnMapStart()
{
    g_LightningSprite = PrecacheModel("lightning/laserbeam.vmt");
    g_beamSprite = PrecacheModel("materials/sprites/laser.vmt");
    g_haloSprite = PrecacheModel("materials/sprites/halo01.vmt");
}

Pointers_function(client, colors)
{

    //VARS
    new Float:clientOrigin[3];
    new Float:StartOrigin[3];
    new Float:clientEyePos[3];
    new Float:clientEyeAngle[3];
    new Float:baseOrigin[3];
    GetClientAbsOrigin(client, clientOrigin);
    GetClientEyeAngles(client, clientEyeAngle);
    GetClientEyePosition(client, clientEyePos);
    
    //RUN TRACE
    TR_TraceRayFilter(clientEyePos, clientEyeAngle, MASK_SOLID, RayType_Infinite, TraceRayDontHitSelf, client);
    if(TR_DidHit(INVALID_HANDLE))
    {
        TR_GetEndPosition(baseOrigin);
        
        StartOrigin[0] = baseOrigin[0]; //x
        StartOrigin[1] = baseOrigin[1]; //y
        StartOrigin[2] = baseOrigin[2] + 800; //z
    }
    
    new color[4] = {255, 255, 255, 255};
    
    switch(colors)
    {
        case 1: //red
        {
            color = {255, 0, 0, 255};
            g_color_red[client] = true;
            CreateTimer(10.0, Timer_SpamTime_red, client);
        }
        case 2: //green
        {
            color = {0, 255, 0, 255};
            g_color_green[client] = true;
            CreateTimer(10.0, Timer_SpamTime_green, client);
        }
        case 3: //blue
        {
            color = {0, 0, 255, 255};
            g_color_blue[client] = true;
            CreateTimer(10.0, Timer_SpamTime_blue, client);
        }
        case 4: //yellow
        {
            color = {255, 255, 0, 255};
            g_color_yellow[client] = true;
            CreateTimer(10.0, Timer_SpamTime_yellow, client);
        }
    }
    
    //LIGHT BEAM
    TE_SetupBeamPoints(StartOrigin, baseOrigin, g_LightningSprite, 0, 0, 0, 10.0, 30.0, 25.0, 0, 1.0, color, 3);
    TE_SendToAll();
    
    TE_SetupBeamRingPoint(baseOrigin, 20.0, 220.0, g_beamSprite, g_haloSprite, 0, 10, 0.6, 10.0, 0.5, color, 5, 0);
    TE_SendToAll();
    
    PrintToChatAll("\x01[SM] \x04The Warden has Placed a Pointer!")
    EmitAmbientSound(RELATIVE_SOUND_PATH, baseOrigin, SNDCHAN_AUTO, SNDLEVEL_GUNFIRE);
}
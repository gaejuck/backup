public OnEntityCreated(entity,const String:classname[])
{
	if (IsValidEntity(entity))
	{
		if (StrEqual(classname, "tf_projectile_rocket", false))
		{
			SDKHook(entity, SDKHook_Spawn, soldier);

		}
	}
}

public soldier(entity)
{
			// SDKHook(entity, SDKHook_Spawn, soldier);
			// decl Float:eye[3], Float:ang[3], Float:rang[3], Float:origin[3]; 
			// new client = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity"); 
			// GetClientEyePosition(client, eye); 
			// GetClientEyeAngles(client, ang); 
			// GetEntPropVector(entity, Prop_Data, "m_angRotation", rang); 
			// GetEntPropVector(entity, Prop_Data, "m_vecOrigin", origin); 
			// TeleportEntity(entity, eye, ang, NULL_VECTOR); 
			CreateTimer(0.01, ScaleSpeed, entity, TIMER_REPEAT); 
}

public Action:ScaleSpeed(Handle:timer, any:ent) { 
    if(IsValidEntity(ent)) { 
        decl Float:velocity[3]; 
        decl Float:ang[3]; 
        new client = GetEntPropEnt(ent, Prop_Data, "m_hOwnerEntity"); 
        GetEntPropVector(ent, Prop_Data, "m_vecVelocity", velocity); 
        ScaleVector(velocity, 1.0); 
        new Float:speed = GetVectorLength(velocity); 
        GetClientEyeAngles(client, ang); 
        ang[0] *= -1.0; 
        ang[0] = DegToRad(ang[0]); 
        ang[1] = DegToRad(ang[1]); 
        velocity[0] = speed*Cosine(ang[0])*Cosine(ang[1]); 
        velocity[1] = speed*Cosine(ang[0])*Sine(ang[1]); 
        velocity[2] = speed*Sine(ang[0]); 
        TeleportEntity(ent, NULL_VECTOR, NULL_VECTOR, velocity); 
    } 
}  
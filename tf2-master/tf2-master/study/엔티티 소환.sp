new shield = CreateEntityByName("entity_medigun_shield");
SetEntPropEnt(shield, Prop_Send, "m_hOwnerEntity", client);  
SetEntProp(shield, Prop_Send, "m_iTeamNum", GetClientTeam(client));
SetEntProp(shield, Prop_Data, "m_iInitialTeamNum", GetClientTeam(client));  
if (TF2_GetClientTeam(client) == TFTeam_Red)
	DispatchKeyValue(shield, "skin", "0");
else if (TF2_GetClientTeam(client) == TFTeam_Blue) 
	DispatchKeyValue(shield, "skin", "1");
	
SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 200.0);
SetEntProp(client, Prop_Send, "m_bRageDraining", 1);

DispatchSpawn(shield);

EmitSoundToClient(client, "weapons/medi_shield_deploy.wav", shield);
SetEntityModel(shield, "models/props_mvm/mvm_player_shield2.mdl");
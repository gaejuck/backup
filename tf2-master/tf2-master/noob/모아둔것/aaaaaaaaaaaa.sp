public Action:TF2Items_OnGiveNamedItem(client, String:classname[], iItemDefinitionIndex, &Handle:hItem)
{
	if (StrEqual(classname, "tf_wearable", false) || StrEqual(classname, "tf_powerup_bottle", false) || StrEqual(classname, "tf_weapon_spellbook", false)
	 || StrEqual(classname, "tf_wearable_vm", false) || StrEqual(classname, "tf_weapon_scattergun", false) || StrEqual(classname, "tf_weapon_bat", false)
	 || StrEqual(classname, "tf_weapon_bottle", false) || StrEqual(classname, "tf_weapon_fireaxe", false) || StrEqual(classname, "tf_weapon_club", false)
	 || StrEqual(classname, "tf_weapon_knife", false) || StrEqual(classname, "tf_weapon_fists", false) || StrEqual(classname, "tf_weapon_shovel", false)
	 || StrEqual(classname, "tf_weapon_wrench", false) || StrEqual(classname, "tf_weapon_bonesaw", false) || StrEqual(classname, "tf_weapon_shotgun", false)
	 || StrEqual(classname, "tf_weapon_sniperrifle", false) || StrEqual(classname, "tf_weapon_minigun", false) || StrEqual(classname, "tf_weapon_smg", false)
	 || StrEqual(classname, "tf_weapon_syringegun_medic", false) || StrEqual(classname, "tf_weapon_rocketlauncher", false) || StrEqual(classname, "tf_weapon_grenadelauncher", false)
	 || StrEqual(classname, "tf_weapon_pipebomblauncher", false) || StrEqual(classname, "tf_weapon_flamethrower", false) || StrEqual(classname, "tf_weapon_pistol", false)
	 || StrEqual(classname, "tf_weapon_revolver", false) || StrEqual(classname, "tf_weapon_pda_engineer_build", false) || StrEqual(classname, "tf_weapon_pda_engineer_destroy", false)
	 || StrEqual(classname, "tf_weapon_pda_spy", false) || StrEqual(classname, "tf_weapon_builder", false) || StrEqual(classname, "tf_weapon_medigun", false)
	 || StrEqual(classname, "tf_weapon_invis", false) || StrEqual(classname, "tf_weapon_lunchbox", false) || StrEqual(classname, "tf_weapon_bat_wood", false)
	 || StrEqual(classname, "tf_weapon_lunchbox_drink", false) || StrEqual(classname, "tf_weapon_jar", false) || StrEqual(classname, "tf_weapon_rocketlauncher_directhit", false)
	 || StrEqual(classname, "tf_weapon_buff_item", false) || StrEqual(classname, "tf_wearable_demoshield", false) || StrEqual(classname, "tf_weapon_sword", false)
	 || StrEqual(classname, "tf_weapon_laser_pointer", false) || StrEqual(classname, "tf_weapon_sentry_revenge", false) || StrEqual(classname, "tf_weapon_robot_arm", false)
	 || StrEqual(classname, "no_entity", false) || StrEqual(classname, "tf_weapon_handgun_scout_primary", false) || StrEqual(classname, "tf_weapon_shotgun_primary", false)
	 || StrEqual(classname, "tf_weapon_crossbow", false) || StrEqual(classname, "tf_weapon_stickbomb", false) || StrEqual(classname, "tf_weapon_katana", false)
	 || StrEqual(classname, "tf_weapon_sniperrifle_decap", false) || StrEqual(classname, "tf_weapon_particle_cannon", false) || StrEqual(classname, "tf_weapon_raygun", false)
	 || StrEqual(classname, "tf_weapon_soda_popper", false) || StrEqual(classname, "tf_weapon_handgun_scout_secondary", false) || StrEqual(classname, "saxxy", false)
	 || StrEqual(classname, "tf_weapon_mechanical_arm", false) || StrEqual(classname, "tf_weapon_bat_fish", false) || StrEqual(classname, "tf_weapon_drg_pomson", false)
	 || StrEqual(classname, "tf_weapon_flaregun_revenge", false) || StrEqual(classname, "tf_weapon_bat_giftwrap", false) || StrEqual(classname, "tf_weapon_pep_brawler_blaster", false)
	 || StrEqual(classname, "tf_weapon_handgun_scout_secondary", false) || StrEqual(classname, "tf_weapon_shotgun_building_rescue", false) || StrEqual(classname, "tf_weapon_cannon", false)
	 || StrEqual(classname, "tf_weapon_compound_bow", false) || StrEqual(classname, "tf_weapon_sapper", false) || StrEqual(classname, "tf_weapon_rocketlauncher_airstrike", false)
	 || StrEqual(classname, "tf_weapon_sniperrifle_classic", false) || StrEqual(classname, "tf_weapon_jar_milk", false))
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
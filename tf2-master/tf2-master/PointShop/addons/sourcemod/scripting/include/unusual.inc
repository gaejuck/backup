#if defined _unusual_included_
  #endinput
#endif
#define _unusual_included_





/**
 * Add an unusual effect on client weapon. Client must be connected!
 *
 * @param SteamID			Client SteamID.
 * @param WeaponID			Weapon Index.
 * @param Quality			Quality Index.
 * @param UnusualEffectID	Unusual effect Index.
 * @param regenerate		Regenerate player after add the unusual effect.
 * @return					true = unusual effect added, false = DB error or client can't have more unusual effects.
 */
native bool:UE_AddUnusualEffect(String:SteamID[], WeaponID, Quality, UnusualEffectID);



//-------- Under this line, client can be connected or disconnected ----------

/**
 * Remove a weapon unusual effect.
 *
 * @param SteamID	Client SteamID.
 * @param WeaponID	Weapon Index.			
 */
native bool:UE_RemoveEffect(String:SteamID[], WeaponID);


/**
 * Remove all client unusual effects.
 *
 * @param SteamID	Client SteamID.
 */
native bool:UE_RemovePlayerEffects(String:SteamID[]);


/**
 * Is client weapon has unusual effect.
 *
 * @param SteamID	Client SteamID.
 * @param WeaponID	Weapon Index.	
 * @return 			true or false.
 */
native bool:UE_IsUnusualItem(String:SteamID[], WeaponID);


/**
 * Get client weapon unusual qualities (Works only if client has unusual effect on his weapon).
 *
 * @param SteamID	Client SteamID.
 * @param WeaponID	Weapon Index.
 * @return 			Weapon quality index or -1 if no quality find. 
 */
native UE_GetUnusualItemQuality(String:SteamID[], WeaponID);


/**
 * Get client weapon unusual effect (Works only if client has unusual effect on his weapon).
 *
 * @param SteamID	Client SteamID.
 * @param WeaponID	Weapon Index.
 * @return 			Unusual effect index or -1 if no effect find. 
 */
native UE_GetUnusualItemEffect(String:SteamID[], WeaponID);


/**
 * Get current client unusual weapon Number.
 *
 * @param SteamID	Client SteamID.
 * @return 			Number of client unusual weapon. -1 if invalid DB. 
 */
native UE_GetUnusualItemNumber(String:SteamID[]);


/**
 * Get flag unusual effect number limit.
 *
 * @param flag		FlagBit (ex : ADMINFLAG_ROOT), -1 = without flag.
 * @return 			Unusual effect flag number limit, -1 = no limit, -2 if invalid FlagBit
 */
native UE_GetUnusualEffectPermission(flag);


/**
 * Set flag unusual effect number limit.
 *
 * @param flag		FlagBit (ex : ADMINFLAG_ROOT), -1 = without flag.
 * @param limit		limit. 
 * @return 			false if invalid FlagBit, true on success.
 */
native bool:UE_SetUnusualEffectPermission(flag, limit);



public SharedPlugin:__pl_unusual = 
{
	name = "unusual",
	file = "unusual.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};
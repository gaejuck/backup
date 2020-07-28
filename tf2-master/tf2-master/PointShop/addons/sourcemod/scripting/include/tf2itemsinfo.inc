/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#if defined _tf2itemsinfo_included
	#endinput
#endif
#define _tf2itemsinfo_included

#include <tf2_stocks>

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#define TF2_ATTRIBUTES_PER_ITEM			16

#define TF2II_ITEMNAME_LENGTH			64
#define TF2II_ITEMCLASS_LENGTH			64
#define TF2II_ITEMSLOT_LENGTH			16
#define TF2II_ITEMTOOL_LENGTH			16
#define TF2II_ITEMQUALITY_LENGTH		16
#define TF2II_ATTRIBNAME_LENGTH			96
#define TF2II_ATTRIBCLASS_LENGTH		32

#define TF2II_PROP_INVALID				0 // invalid property, not item
// Items only
#define TF2II_PROP_VALIDITEM			(1<<0)
#define TF2II_PROP_BASEITEM				(1<<1)
#define TF2II_PROP_PAINTABLE			(1<<2)
#define TF2II_PROP_UNUSUAL				(1<<3)
#define TF2II_PROP_VINTAGE				(1<<4)
#define TF2II_PROP_STRANGE				(1<<5)
#define TF2II_PROP_HAUNTED				(1<<6)
#define TF2II_PROP_HALLOWEEN			(1<<7) // unused?
#define TF2II_PROP_PROMOITEM			(1<<8)
#define TF2II_PROP_GENUINE				(1<<9)
#define TF2II_PROP_MEDIEVAL				(1<<10)
#define TF2II_PROP_BDAY_STRICT			(1<<11)
#define TF2II_PROP_HOFM_STRICT			(1<<12)	// Halloween Or Full Moon
#define TF2II_PROP_XMAS_STRICT			(1<<13)
#define TF2II_PROP_PROPER_NAME			(1<<14)
// Attributes only
#define TF2II_PROP_VALIDATTRIB			(1<<20)
#define TF2II_PROP_EFFECT_POSITIVE		(1<<21)
#define TF2II_PROP_EFFECT_NEUTRAL		(1<<22)
#define TF2II_PROP_EFFECT_NEGATIVE		(1<<23)
#define TF2II_PROP_HIDDEN				(1<<24)
#define TF2II_PROP_STORED_AS_INTEGER	(1<<25)

#define TF2II_CLASS_NONE				0
#define TF2II_CLASS_SCOUT				(1<<0)
#define TF2II_CLASS_SNIPER				(1<<1)
#define TF2II_CLASS_SOLDIER				(1<<2)
#define TF2II_CLASS_DEMOMAN				(1<<3)
#define TF2II_CLASS_MEDIC				(1<<4)
#define TF2II_CLASS_HEAVY				(1<<5)
#define TF2II_CLASS_PYRO				(1<<6)
#define TF2II_CLASS_SPY					(1<<7)
#define TF2II_CLASS_ENGINEER			(1<<8)
#define TF2II_CLASS_ALL					(0b111111111)
#define TF2II_CLASS_ANY					TF2II_CLASS_ALL

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

enum TF2ItemQuality
{
	TF2ItemQuality_Normal = 0, // 0
	TF2ItemQuality_Rarity1,
	TF2ItemQuality_Genuine = 1,
	TF2ItemQuality_Rarity2,
	TF2ItemQuality_Vintage,
	TF2ItemQuality_Rarity3,
	TF2ItemQuality_Rarity4,
	TF2ItemQuality_Unusual = 5,
	TF2ItemQuality_Unique,
	TF2ItemQuality_Community,
	TF2ItemQuality_Developer,
	TF2ItemQuality_Selfmade,
	TF2ItemQuality_Customized, // 10
	TF2ItemQuality_Strange,
	TF2ItemQuality_Completed,
	TF2ItemQuality_Haunted,
	TF2ItemQuality_ToborA
};

static const TF2ItemQualityColors[] =
{
	0xB2B2B2, // normal
	0x4D7455, // genuine
	0x8D834B, // rarity2
	0x476291, // vintage
	0x70550F, // rarity3
	0x38F3AB, // unusual
	0xFFD700, // unique
	0x70B04A, // community
	0xA50F79, // developer
	0x70B04A, // selfmade
	0x00FF00, // customized
	0xCF6A32, // strange
	0x8650AC, // completed
	0x38F3AB // haunted
};

enum TF2ItemSlot
{
	TF2ItemSlot_Primary = 0,
	TF2ItemSlot_Secondary = 1,
	TF2ItemSlot_Sapper = 1,
	TF2ItemSlot_Melee = 2,
	TF2ItemSlot_PDA = 3,
	TF2ItemSlot_PDA1 = 3,
	TF2ItemSlot_PDA2 = 4,
	TF2ItemSlot_Building = 5,
	TF2ItemSlot_Hat = 5,
	TF2ItemSlot_Head = 5,
	TF2ItemSlot_Misc = 6,
	TF2ItemSlot_Action = 7
};

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/**
 * @brief Is items_game.txt file precached
 *
 * @noparam
 *
 * @return						True if is it, false otherwise
 **/
native bool:TF2II_IsItemSchemaPrecached();

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/**
 * @brief Is item exists in items_game.txt
 *
 * @param iItemDefinitionIndex	-
 *
 * @return						True if it is, false otherwise
 **/
native bool:TF2II_IsValidItemID( iItemDefinitionIndex );

/**
 * @brief Get item name
 *
 * @param iItemDefinitionIndex	-
 * @param strItemName			String to store item name
 * @param iItemNameLength		String length
 *
 * @return						False is item doesn't exist, true otherwise
 **/
native TF2II_GetItemName( iItemDefinitionIndex, String:strItemName[], iItemNameLength );

/**
 * @brief Check if item has property(-ies)
 *
 * @param iItemDefinitionIndex	-
 * @param iFlags				Property flags
 *
 * @return						False is item doesn't exist, true otherwise
 **/
native bool:TF2II_ItemHasProperty( iItemDefinitionIndex, iFlags );

/**
 * @brief Get item classname
 *
 * @param iItemDefinitionIndex	-
 * @param strItemClass			String to store item class
 * @param iItemClassLength		String length
 * @param iPlayerClass			Player class
 *
 * @return						False is item doesn't exist, true otherwise
 **/
native TF2II_GetItemClass( iItemDefinitionIndex, String:strItemClass[], iItemClassLength, TFClassType:iPlayerClass = TFClass_Unknown );

/**
 * @brief Get item slot number
 *
 * @param iItemDefinitionIndex	-
 * @param iPlayerClass			Player class
 *
 * @return						Item slot number
 **/
native TF2ItemSlot:TF2II_GetItemSlot( iItemDefinitionIndex, TFClassType:iPlayerClass = TFClass_Unknown );

/**
 * @brief Get item slot name
 *
 * @param iItemDefinitionIndex	-
 * @param strItemSlot			String to store item slot
 * @param iItemSlotLength		String length
 *
 * @return						False is item doesn't exist, true otherwise
 **/
native bool:TF2II_GetItemSlotName( iItemDefinitionIndex, String:strItemSlot[], iItemSlotLength );

/**
 * @brief Get item slot number (as in items_game.txt)
 *
 * @param iItemDefinitionIndex	-
 * @param iPlayerClass			Player class
 *
 * @return						Item slot number
 **/
native TF2ItemSlot:TF2II_GetListedItemSlot( iItemDefinitionIndex, TFClassType:iPlayerClass = TFClass_Unknown );

/**
 * @brief Get item slot name (as in items_game.txt)
 *
 * @param iItemDefinitionIndex	-
 * @param strItemSlot			String to store item slot
 * @param iItemSlotLength		String length
 *
 * @return						False is item doesn't exist, true otherwise
 **/
native bool:TF2II_GetListedItemSlotName( iItemDefinitionIndex, String:strItemSlot[], iItemSlotLength );

/**
 * @brief Is item can be used by this class?
 *
 * @param iItemDefinitionIndex	-
 * @param iClass				-
 *
 * @return						True if true, false otherwise.
 **/
native bool:TF2II_IsItemUsedByClass( iItemDefinitionIndex, TFClassType:iClass );

/**
 * @brief -
 *
 * @param iItemDefinitionIndex	-
 *
 * @return						Minimal item level
 **/
native _:TF2II_GetItemMinLevel( iItemDefinitionIndex );

/**
 * @brief -
 *
 * @param iItemDefinitionIndex	-
 *
 * @return						Maximal item level
 **/
native _:TF2II_GetItemMaxLevel( iItemDefinitionIndex );

/**
 * @brief Get item quality number
 *
 * @param iItemDefinitionIndex	-
 *
 * @return						Item quality number
 **/
native TF2ItemQuality:TF2II_GetItemQuality( iItemDefinitionIndex );

/**
 * @brief Get item quality name
 *
 * @param iItemDefinitionIndex	-
 * @param strQuality			String to store item slot
 * @param iQualityLength		String length
 *
 * @return						False is item doesn't exist, true otherwise
 **/
native bool:TF2II_GetItemQualityName( iItemDefinitionIndex, String:strQuality[], iQualityLength );

/**
 * @brief Get number of attributes
 *
 * @param iItemDefinitionIndex	-
 *
 * @return						Number of attributes
 **/
native _:TF2II_GetItemNumAttributes( iItemDefinitionIndex );

/**
 * @brief -
 *
 * @param iItemDefinitionIndex	-
 * @param iSlotAttribute		The attribute slot index, ranges from 0 to 15
 * @param strAttributeName		Buffer to store attribute name
 * @param iAttributeNameLength	Buffer size
 *
 * @return						True on success, false otherwise
 **/
native bool:TF2II_GetItemAttributeName( iItemDefinitionIndex, iSlotAttribute, String:strAttributeName[], iAttributeNameLength );

/**
 * @brief -
 *
 * @param iItemDefinitionIndex	-
 * @param iSlotAttribute		The attribute slot index, ranges from 0 to 15
 *
 * @return						The attribute ID; -1 on failure
 **/
native _:TF2II_GetItemAttributeID( iItemDefinitionIndex, iSlotAttribute );

/**
 * @brief -
 *
 * @param iItemDefinitionIndex	-
 * @param iSlotAttribute		The attribute slot index, ranges from 0 to 15
 *
 * @return						Attribute value
 **/
native Float:TF2II_GetItemAttributeValue( iItemDefinitionIndex, iSlotAttribute );

/**
 * @brief -
 *
 * @param iItemDefinitionIndex	-
 *
 * @return						Array of attributes
 **/
native Handle:TF2II_GetItemAttributes( iItemDefinitionIndex );

/**
 * @brief Get tool type
 *
 * @param iItemDefinitionIndex	-
 * @param strTool				String to store data
 * @param iToolLength			String length
 *
 * @return						Attribute ID on success, -1 otherwise
 **/
native bool:TF2II_GetToolType( iItemDefinitionIndex, String:strTool[], iToolLength );

/**
 * @brief Is item restricted by selected holiday?
 *
 * @param iItemDefinitionIndex	-
 * @param holiday				-
 *
 * @return						True or false
 **/
native bool:TF2II_ItemHolidayRestriction( iItemDefinitionIndex, TFHoliday:holiday );

/**
 * @brief Get item equip regions
 *
 * @param iItemDefinitionIndex	-
 *
 * @return						Array or INVALID_HANDLE (if no equip regions presented)
 **/
native Handle:TF2II_GetItemEquipRegions( iItemDefinitionIndex );

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/**
 * @brief Is attribute exists in items_game.txt
 *
 * @param iAttributeIndex			-
 *
 * @return							True if it is, false otherwise
 **/
native bool:TF2II_IsValidAttribID( iAttributeIndex );

/**
 * @brief Get attribute working name
 *
 * @param iAttributeIndex			-
 * @param strAttributeName			String to store name
 * @param iAttributeNameLength		String length
 *
 * @return							False is attribute doesn't exist, true otherwise
 **/
native bool:TF2II_GetAttribName( iAttributeIndex, String:strAttributeName[], iAttributeNameLength );

/**
 * @brief Get attribute class
 *
 * @param iAttributeIndex			-
 * @param strAttributeClass			String to store class
 * @param iAttributeClassLength		String length
 *
 * @return							False is attribute doesn't exist, true otherwise
 **/
native bool:TF2II_GetAttribClass( iAttributeIndex, String:strAttributeClass[], iAttributeClassLength );

/**
 * @brief Get attribute display name
 *
 * @param iAttributeIndex			-
 * @param strAttributeName			String to store name
 * @param iAttributeNameLength		String length
 *
 * @return							False is attribute doesn't exist, true otherwise
 **/
native bool:TF2II_GetAttribDispName( iAttributeIndex, String:strAttributeName[], iAttributeNameLength );

/**
 * @brief Get attribute MinValue
 *
 * @param iAttributeIndex			-
 *
 * @return							MinValue
 **/
native Float:TF2II_GetAttribMinValue( iAttributeIndex );

/**
 * @brief Get attribute MaxValue
 *
 * @param iAttributeIndex			-
 *
 * @return							MaxValue
 **/
native Float:TF2II_GetAttribMaxValue( iAttributeIndex );

/**
 * @brief Get attribute group
 *
 * @param iAttributeIndex			-
 * @param strAttributeGroup			String to store group
 * @param iAttributeGroupLength		String length
 *
 * @return							False is attribute doesn't exist, true otherwise
 **/
native bool:TF2II_GetAttribGroup( iAttributeIndex, String:strAttributeGroup[], iAttributeGroupLength );

/**
 * @brief Get attribute description string
 *
 * @param iAttributeIndex			-
 * @param strAttribDescrString		String to store string
 * @param iAttribDescrStringLength	String length
 *
 * @return							False is attribute doesn't exist, true otherwise
 **/
native bool:TF2II_GetAttribDescrString( iAttributeIndex, String:strAttribDescrString[], iAttribDescrStringLength );

/**
 * @brief Get attribute description string format
 *
 * @param iAttributeIndex			-
 * @param strAttribDescrFormat		String to store string format
 * @param iAttribDescrFormatLength	String length
 *
 * @return							False is attribute doesn't exist, true otherwise
 **/
native bool:TF2II_GetAttribDescrFormat( iAttributeIndex, String:strAttribDescrFormat[], iAttribDescrFormatLength );

/**
 * @brief Is it a hidden attribute
 *
 * @param iAttributeIndex			-
 *
 * @return							True/false
 **/
native bool:TF2II_HiddenAttrib( iAttributeIndex );

/**
 * @brief Get attribute effect type. 1 - positive, 0 - neutral, -1 - negative.
 *
 * @param iAttributeIndex			-
 *
 * @return							Number
 **/
native _:TF2II_GetAttribEffectType( iAttributeIndex );

/**
 * @brief Is attribute stored as integer
 *
 * @param iAttributeIndex			-
 *
 * @return							True/false
 **/
native bool:TF2II_AttribStoredAsInteger( iAttributeIndex );

/**
 * @brief Check if attribute has property(-ies)
 *
 * @param iAttributeIndex			-
 * @param iFlags					Property flags
 *
 * @return							False is attribute doesn't exist, true otherwise
 **/
native bool:TF2II_AttribHasProperty( iAttributeIndex );

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/**
 * @brief -
 *
 * @param iItemDefinitionIndex		-
 *
 * @return							KeyValues object
 **/
native Handle:TF2II_GetItemKeyValues( iItemDefinitionIndex );

/**
 * @brief -
 *
 * @param iItemDefinitionIndex		-
 * @param strKey					-
 *
 * @return							Integer
 **/
native TF2II_GetItemKey( iItemDefinitionIndex, const String:strKey[] );

/**
 * @brief -
 *
 * @param iItemDefinitionIndex		-
 * @param strKey					-
 *
 * @return							Float
 **/
native Float:TF2II_GetItemKeyFloat( iItemDefinitionIndex, const String:strKey[] );

/**
 * @brief -
 *
 * @param iItemDefinitionIndex		-
 * @param strKey					-
 * @param strBuffer					-
 * @param iBufferSize				-
 *
 * @noreturn
 **/
native TF2II_GetItemKeyString( iItemDefinitionIndex, const String:strKey[], String:strBuffer[], iBufferSize );

/**
 * @brief -
 *
 * @param iItemDefinitionIndex		-
 *
 * @return							KeyValues object
 **/
native Handle:TF2II_GetAttribKeyValues( iItemDefinitionIndex );

/**
 * @brief -
 *
 * @param iAttributeIndex			-
 * @param strKey					-
 *
 * @return							Integer
 **/
native TF2II_GetAttribKey( iAttributeIndex, const String:strKey[] );

/**
 * @brief -
 *
 * @param iAttributeIndex			-
 * @param strKey					-
 *
 * @return							Float
 **/
native Float:TF2II_GetAttribKeyFloat( iAttributeIndex, const String:strKey[] );

/**
 * @brief -
 *
 * @param iAttributeIndex			-
 * @param strKey					-
 * @param strBuffer					-
 * @param iBufferSize				-
 *
 * @noreturn
 **/
native TF2II_GetAttribKeyString( iAttributeIndex, const String:strKey[], String:strBuffer[], iBufferSize );

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/**
 * @brief Check equip regions for conflicts
 *
 * @param strEquipRegionA		First equip region
 * @param strEquipRegionB		Second equip region
 *
 * @return						Attribute ID on success, -1 otherwise
 **/
native bool:TF2II_IsConflictRegions( const String:strEquipRegionA[], const String:strEquipRegionB[] );

/**
 * @brief Get quality number by name
 *
 * @param strQualityName		Quality name
 *
 * @return						Quality number on success, -1 otherwise
 **/
native TF2ItemQuality:TF2II_GetQualityByName( const String:strAttributeName[] );

/**
 * @brief Get quality name
 *
 * @param iQuality				-
 * @param strQualityName		String to store quality name
 * @param iQualityNameLength	String length
 *
 * @return						True on success, false otherwise
 **/
native bool:TF2II_GetQualityName( iAttributeID, String:strAttributeName[], iAttributeNameLength );

/**
 * @brief Get attribute ID by name
 *
 * @param strAttributeName		Attribute name
 *
 * @return						Attribute ID on success, -1 otherwise
 **/
native _:TF2II_GetAttributeIDByName( const String:strAttributeName[] );

/**
 * @brief Get attribute name by ID
 *
 * @param iAttributeID			-
 * @param strAttributeName		String to store attribute name
 * @param iAttributeNameLength	String length
 *
 * @return						True on success, false otherwise
 **/
native bool:TF2II_GetAttributeNameByID( iAttributeID, String:strAttributeName[], iAttributeNameLength );

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/**
 * @brief -
 *
 * @param strItemClass			Item class name
 * @param iItemSlot				Item slot number
 * @param strItemSlot			Item slot name
 * @param bFilterClass			Should we check for classes?
 * @param bUsedByClasses		Array of classes with rights (example: bUsedByClasses[0]=true meaning that we should find items which scout can equip)
 * @param strTool				Tool type
 *
 * @return						Array of results
 **/
#pragma deprecated Use TF2II_FindItems instead.
native Handle:TF2II_FindItemsIDsByCond( const String:strItemClass[] = "", iItemSlot = -1, const String:strItemSlot[] = "", bool:bFilterClass = false, bool:bUsedByClasses[TFClassType] = { false, ... }, const String:strTool[] = "" );

/**
 * @brief Note: all arguments are optional. Set them to detail your search query.
 *
 * @param strItemClass			Item class name
 * @param strItemSlot			Item slot name
 * @param iUsedByClasses		Classes (bits)
 * @param strTool				Tool type
 *
 * @return						Array of item IDs
 **/
native Handle:TF2II_FindItems( const String:strItemClass[] = "", const String:strItemSlot[] = "", iUsedByClasses = TF2II_CLASS_NONE, const String:strTool[] = "" );

/**
 * @brief -
 *
 * @param bAllEffects			Print valid or all effects?
 *
 * @return						Array of results
 **/
native Handle:TF2II_ListAttachableEffects( bAllEffects = true );
native Handle:TF2II_ListEffects( bAllEffects = true );

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/**
 * @brief Called when an item schema is parsed (or reloaded)
 **/
forward TF2II_OnItemSchemaUpdated();

/**
 * @brief Called when someone's trying to find items
 *
 * @param iClient				Caller
 * @param strQuery				Search query
 * @param hResults				Array of results
 * @param bByClassname			Is searching by classname?
 *
 * @noreturn
 **/
forward TF2II_OnSearchCommand( iClient, const String:strQuery[], &Handle:hResults, bool:bBy	 );

/**
 * @brief Called when some plugin's trying to find items
 *
 * @param strItemClass			Item class name
 * @param strItemSlot			Item slot name
 * @param iUsedByClasses		Classes (bits)
 * @param strTool				Tool type
 * @param hResults				Array of results
 *
 * @noreturn
 **/
forward TF2II_OnFindItems( const String:strItemClass[], const String:strItemSlot[], iUsedByClasses, const String:strTool[], &Handle:hResults );

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#pragma deprecated Use TF2II_ItemHasProperty() instead.
native bool:TF2II_IsPromotionalItem( iItemDefinitionIndex, bool:bGenuineOnly = false );
#pragma deprecated Use TF2II_ItemHasProperty() instead.
native bool:TF2II_IsUpgradeableStockWeapon( iItemDefinitionIndex );
#pragma deprecated Use TF2II_ItemHasProperty() instead.
native bool:TF2II_IsFestiveStockWeapon( iItemDefinitionIndex );

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

/**
 * @brief -
 *
 * @param iItemDefinitionIndex	-
 *
 * @return						Level number
 **/
stock _:TF2II_GetItemLevelByID( iItemDefinitionIndex )
{
	new iLevel = 1;
	new iSlot = TF2II_GetItemSlotByID( iItemDefinitionIndex );
	if( iSlot >= TF2ItemSlot_Hat && iSlot <= TF2ItemSlot_Misc )
		iLevel = GetRandomInt( 1, 100 );
	switch( iItemDefinitionIndex )
	{
		case 125,262,335,336,360,434,435: iLevel = 1;
		case 164,343: iLevel = 5;
		case 115,116,126,165,240,261,268,269,270,271,272,273,274,275,276,277,263,279,346,347,486,408,409,410,470,473,490,491,492,514,515,516,517,518,519,520,537: iLevel = 10;
		case 422: iLevel = 13;
		case 166,333,392,443,483,484: iLevel = 15;
		case 170,189,295,299,296,345,420,432,454,1899: iLevel = 20;
		case 334: iLevel = 28;
		case 332: iLevel = 30;
		case 278,287,289,290,291: iLevel = 31;
		case 292,471: iLevel = 50;
	}
	return iLevel;
}

/**
 * @brief Get quality color by quality number
 *
 * @param nQuality				-
 *
 * @return						Hex code
 **/
stock _:TF2II_GetQualityColor( TF2ItemQuality:nQuality = TF2ItemQuality_Normal )
{
	if( _:nQuality < 0 || _:nQuality > sizeof( TF2ItemQualityColors ) )
		return 0x000000;
	return TF2ItemQualityColors[_:nQuality];
}

/**
 * @brief Get slot number by name
 *
 * @param strSlot				Slot name
 * @param iClass				Player class
 *
 * @return						Item slot number
 **/
stock TF2ItemSlot:TF2II_GetSlotByName( const String:strSlot[], TFClassType:iClass = TFClass_Unknown )
{
	if( StrEqual( strSlot, "primary", false ) )
		return TF2ItemSlot_Primary;
	else if( StrEqual( strSlot, "secondary", false ) )
		return TF2ItemSlot_Secondary;
	else if( StrEqual( strSlot, "melee", false ) )
		return TF2ItemSlot_Melee;
	else if( StrEqual( strSlot, "pda", false ) )
		return TF2ItemSlot_PDA;
	else if( StrEqual( strSlot, "pda2", false ) )
		return TF2ItemSlot_PDA2;
	else if( StrEqual( strSlot, "building", false ) )
	{
		if( iClass == TFClass_Spy )
			return TF2ItemSlot_Sapper;
		else
			return TF2ItemSlot_Building;
	}
	else if( StrEqual( strSlot, "head", false ) )
		return TF2ItemSlot_Hat;
	else if( StrEqual( strSlot, "misc", false ) )
		return TF2ItemSlot_Misc;
	else if( StrEqual( strSlot, "action", false ) )
		return TF2ItemSlot_Action;
	else
		return TF2ItemSlot:-1;
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

stock bool:TF2II_IsBaseItem( iItemDefinitionIndex )
{
	return TF2II_ItemHasProperty( iItemDefinitionIndex, TF2II_PROP_BASEITEM );
}
stock bool:TF2II_IsItemPaintable( iItemDefinitionIndex )
{
	return TF2II_ItemHasProperty( iItemDefinitionIndex, TF2II_PROP_PAINTABLE );
}
stock bool:TF2II_ItemCanBeUnusual( iItemDefinitionIndex )
{
	return TF2II_ItemHasProperty( iItemDefinitionIndex, TF2II_PROP_UNUSUAL );
}
stock bool:TF2II_ItemCanBeVintage( iItemDefinitionIndex )
{
	return TF2II_ItemHasProperty( iItemDefinitionIndex, TF2II_PROP_VINTAGE );
}
stock bool:TF2II_IsHauntedItem( iItemDefinitionIndex )
{
	return TF2II_ItemHasProperty( iItemDefinitionIndex, TF2II_PROP_HAUNTED );
}
stock bool:TF2II_IsHalloweenItem( iItemDefinitionIndex )
{
	return TF2II_ItemHasProperty( iItemDefinitionIndex, TF2II_PROP_HALLOWEEN );
}
stock bool:TF2II_IsMedievalWeapon( iItemDefinitionIndex )
{
	return TF2II_ItemHasProperty( iItemDefinitionIndex, TF2II_PROP_MEDIEVAL );
}
stock bool:TF2II_ItemCanBeStrange( iItemDefinitionIndex )
{
	return TF2II_ItemHasProperty( iItemDefinitionIndex, TF2II_PROP_STRANGE );
}

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

public SharedPlugin:__pl_tf2itemsinfo = 
{
	name = "tf2itemsinfo",
	file = "tf2itemsinfo.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#if !defined REQUIRE_PLUGIN
public __pl_tf2itemsinfo_SetNTVOptional()
{
	MarkNativeAsOptional("TF2II_IsItemSchemaPrecached");
	
	MarkNativeAsOptional("TF2II_IsValidItemID");
	MarkNativeAsOptional("TF2II_GetItemClass");
	MarkNativeAsOptional("TF2II_GetItemSlot");
	MarkNativeAsOptional("TF2II_GetItemSlotName");
	MarkNativeAsOptional("TF2II_GetListedItemSlot");
	MarkNativeAsOptional("TF2II_GetListedItemSlotName");
	MarkNativeAsOptional("TF2II_GetItemQuality");
	MarkNativeAsOptional("TF2II_GetItemQualityName");
	MarkNativeAsOptional("TF2II_IsItemUsedByClass");
	MarkNativeAsOptional("TF2II_GetItemMinLevel");
	MarkNativeAsOptional("TF2II_GetItemMaxLevel");
	MarkNativeAsOptional("TF2II_GetItemNumAttributes");
	MarkNativeAsOptional("TF2II_GetItemAttributeName");
	MarkNativeAsOptional("TF2II_GetItemAttributeID");
	MarkNativeAsOptional("TF2II_GetItemAttributeValue");
	MarkNativeAsOptional("TF2II_GetItemAttributes");
	MarkNativeAsOptional("TF2II_GetToolType");
	MarkNativeAsOptional("TF2II_ItemHolidayRestriction");
	MarkNativeAsOptional("TF2II_GetItemEquipRegions");
	MarkNativeAsOptional("TF2II_GetItemName");
	MarkNativeAsOptional("TF2II_ItemHasProperty");
	
	MarkNativeAsOptional("TF2II_IsValidAttribID");
	MarkNativeAsOptional("TF2II_GetAttribName");
	MarkNativeAsOptional("TF2II_GetAttribClass");
	MarkNativeAsOptional("TF2II_GetAttribDispName");
	MarkNativeAsOptional("TF2II_GetAttribMinValue");
	MarkNativeAsOptional("TF2II_GetAttribMaxValue");
	MarkNativeAsOptional("TF2II_GetAttribGroup");
	MarkNativeAsOptional("TF2II_GetAttribDescrString");
	MarkNativeAsOptional("TF2II_GetAttribDescrFormat");
	MarkNativeAsOptional("TF2II_HiddenAttrib");
	MarkNativeAsOptional("TF2II_GetAttribEffectType");
	MarkNativeAsOptional("TF2II_AttribStoredAsInteger");
	MarkNativeAsOptional("TF2II_AttribHasProperty");
	
	MarkNativeAsOptional("TF2II_GetItemKeyValues");
	MarkNativeAsOptional("TF2II_GetItemKey");
	MarkNativeAsOptional("TF2II_GetItemKeyFloat");
	MarkNativeAsOptional("TF2II_GetItemKeyString");
	MarkNativeAsOptional("TF2II_GetAttribKeyValues");
	MarkNativeAsOptional("TF2II_GetAttribKey");
	MarkNativeAsOptional("TF2II_GetAttribKeyFloat");
	MarkNativeAsOptional("TF2II_GetAttribKeyString");
	
	MarkNativeAsOptional("TF2II_IsConflictRegions");
	MarkNativeAsOptional("TF2II_GetQualityByName");
	MarkNativeAsOptional("TF2II_GetQualityName");
	MarkNativeAsOptional("TF2II_GetAttributeIDByName");
	MarkNativeAsOptional("TF2II_GetAttributeNameByID");
	
	MarkNativeAsOptional("TF2II_FindItems");
	MarkNativeAsOptional("TF2II_ListAttachableEffects");
	MarkNativeAsOptional("TF2II_ListEffects");
	
	// Obsolete/deprecated functions
	MarkNativeAsOptional("TF2II_IsPromotionalItem");
	MarkNativeAsOptional("TF2II_IsUpgradeableStockWeapon");
	MarkNativeAsOptional("TF2II_IsFestiveStockWeapon");
	MarkNativeAsOptional("TF2II_FindItemsIDsByCond");
}
#endif

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */
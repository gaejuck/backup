
// 호출 규칙에 매개 변수를 추가합니다. 이것은 정상적인 오름차순으로 호출해야합니다.

native PrepSDKCall_AddParameter(SDKType:type, SDKPassMethod:pass, decflags=0, encflags=0); 

type			Data type to convert to/from.
pass			How the data is passed in C++.
decflags		Flags on decoding from the plugin to C++.
encflags		Flags on encoding from C++ to the plugin.

enum SDKType
{
	SDKType_CBaseEntity,	/**< CBaseEntity (always as pointer) */
	SDKType_CBasePlayer,	/**< CBasePlayer (always as pointer) */
	SDKType_Vector,			/**< Vector (pointer, byval, or byref) */
	SDKType_QAngle,			/**< QAngles (pointer, byval, or byref) */
	SDKType_PlainOldData,	/**< Integer/generic data <=32bit (any) */
	SDKType_Float,			/**< Float (any) */
	SDKType_Edict,			/**< edict_t (always as pointer) */
	SDKType_String,			/**< NULL-terminated string (always as pointer) */
	SDKType_Bool,			/**< Boolean (any) */
};

enum SDKPassMethod
{
	SDKPass_Pointer,		/**< Pass as a pointer */
	SDKPass_Plain,			/**< Pass as plain data */
	SDKPass_ByValue,		/**< Pass an object by value */
	SDKPass_ByRef,			/**< Pass an object by reference */
};

ex) PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);

// GameConfig 파일의 주소 또는 가상 함수 인덱스를 찾아 SDK 호출에 대한 호출 정보로 설정합니다.

native bool:PrepSDKCall_SetFromConf(Handle:gameconf, SDKFuncConfSource:source, const String:name[]); 

gameconf		GameConfig Handle, or INVALID_HANDLE to use sdktools.games.txt.
source		Whether to look in Offsets or Signatures.
name			Name of the property to find.

ex) PrepSDKCall_SetFromConf(hConf, SDKConf_Virtual, "CTFPlayer::GiveAmmo");

enum SDKFuncConfSource
{
	SDKConf_Virtual = 0,	/**< Read a virtual index from the Offsets section */
	SDKConf_Signature = 1,	/**< Read a signature from the Signatures section */
};


// SDK를 호출의 준비를 시작합니다.

native StartPrepSDKCall(SDKCallType:type); 

type			Type of function call this will be.
 
 enum SDKCallType
{
	SDKCall_Static,		/**< Static call */
	SDKCall_Entity,		/**< CBaseEntity call */
	SDKCall_Player,		/**< CBasePlayer call */
	SDKCall_GameRules,	/**< CGameRules call */
	SDKCall_EntityList,	/**< CGlobalEntityList call */ 
};

ex) StartPrepSDKCall(SDKCall_Player);

// SDK를 호출의 반환 정보를 설정합니다. 더 리턴 데이터가없는 경우이 호출하지 마십시오. (가 반드시 데이터를 무시하는 것이 안전하지 i.f.) 반환 값이있는 경우이 호출해야합니다.

native PrepSDKCall_SetReturnInfo(SDKType:type, SDKPassMethod:pass, decflags=0, encflags=0); 

type			Data type to convert to/from.
pass			How the data is passed in C++.
decflags		Flags on decoding from the plugin to C++.
encflags		Flags on encoding from C++ to the plugin.

ex) PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);



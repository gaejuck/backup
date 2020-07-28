#include <sdkhooks>
#include <tf2_stocks>

#pragma newdecls required

public void OnEntityCreated(int entity, const char[] classname)
{
	// if(StrEqual(classname, "tf_projectile_rocket"))
	if(StrContains(classname, "tf_projectile") != -1)
	{
		SDKHook(entity, SDKHook_SpawnPost, OnMoneySpawn);
	}
}

public Action OnMoneySpawn(int entity)
{

		char strModel[PLATFORM_MAX_PATH];
		GetEntPropString(entity, Prop_Data, "m_ModelName", strModel, PLATFORM_MAX_PATH);
		if(!StrEqual(strModel, ""))
		{
			int ent = CreateEntityByName("tf_taunt_prop");
			DispatchKeyValue(ent, "targetname", "MoneyESP");
			DispatchSpawn(ent);
			
			SetEntityModel(ent, strModel);
			
			SetEntPropEnt(ent, Prop_Data, "m_hEffectEntity", entity);
			SetEntProp(ent, Prop_Send, "m_bGlowEnabled", 1);
			
			int iFlags = GetEntProp(ent, Prop_Send, "m_fEffects");
			SetEntProp(ent, Prop_Send, "m_fEffects", iFlags|(1 << 0)|16|8);
			
			SetVariantString("!activator");
			AcceptEntityInput(ent, "SetParent", entity);
			
			SDKHook(ent, SDKHook_SetTransmit, Hook_MoneyTransmit);
		}
}

public Action Hook_MoneyTransmit(int ent, int other)
{
	if(other > 0 && other <= MaxClients && IsClientInGame(other))
	{
		int iMoney = GetEntPropEnt(ent, Prop_Data, "m_hEffectEntity");
		if(IsValidEntity(iMoney))
		{		
			int iclrRender = GetEntProp(iMoney, Prop_Send, "m_clrRender");
			if(iclrRender == -1)
			{
				return Plugin_Continue;
			}
		}
	}

	return Plugin_Handled;
}

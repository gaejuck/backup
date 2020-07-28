		char tName[32];
		GetEntPropString(client, Prop_Data, "m_iName", tName, sizeof(tName));
		DispatchKeyValue(shield, "parentname", tName);
				
		SetVariantString("!activator");
		AcceptEntityInput(shield, "SetParent", client, client, 0);
		SetVariantString("flag");
		AcceptEntityInput(shield, "SetParentAttachment", client, client, 0);
		
		클라이언트 뒤 쪽에 엔티티를 넣음
		
		
		
// 2
		SetVariantString("!activator");
		AcceptEntityInput(shield, "SetParent", iLink); 
		
		SetVariantString("flag"); 
		AcceptEntityInput(shield, "SetParentAttachment", iLink); 
		
// 3
		SetVariantString("!activator");
		AcceptEntityInput(shield, "SetParent", iLink); 
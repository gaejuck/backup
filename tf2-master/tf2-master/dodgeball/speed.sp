new bool:RSP;

public TF2_OnWaitingForPlayersStart() RSP = true;
public TF2_OnWaitingForPlayersEnd() RSP = false;

public OnGameFrame() for(new i = 1; i <= MaxClients; i++) if(RSP && PlayerCheck(i)) SetEntPropFloat(i, Prop_Send, "m_flMaxspeed", 999.0);

stock bool:PlayerCheck(Client){
	if(Client > 0 && Client <= MaxClients){
		if(IsClientConnected(Client) == true){
			if(IsClientInGame(Client) == true){
				return true;
			}
		}
	}
	return false;
}

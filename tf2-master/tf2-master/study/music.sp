stock Music(client, String:url[256])
{
	if ( !IsClientInGame( client ) )
		return;
	
	new Handle:kv = CreateKeyValues( "data" );
	
	KvSetString( kv, "title", "음악" );
	KvSetNum( kv, "type", MOTDPANEL_TYPE_URL );
	KvSetString( kv, "msg", url);
	
	ShowVGUIPanel( client, "info", kv, false );
	
	CloseHandle( kv );
}
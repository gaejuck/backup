public OnMapStart()
{
	PrecacheModel("take/hanzo.mdl", true);
	PrecacheSound("take/hanzo.mp3", true);
	PrecacheDecal("take/hanzo.vmt", true);
	AddFileToDownloadsTable("sound/take/hanzo.mp3");
	
	EmitSoundToAll("take/hanzo.mp3");
}

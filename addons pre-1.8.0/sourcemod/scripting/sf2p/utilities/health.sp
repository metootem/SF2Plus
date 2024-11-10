#include <sourcemod>
#include <morecolors>
#include <tf2_stocks>

#include <sf2plus>

int iHealthBoostRecoveryAmount = 40; // ------ Initial Health Recovery Amount
float fHealthRecoveryDuration = 2.0;
char szUtilitySound[PLATFORM_MAX_PATH] = "misc/halloween/spell_overheal.wav";

public void SF2P_UtilityRegistered()
{
	char config[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, config, sizeof(config), "%shealth.cfg", UTILITY_CONFIG_PATH);
	if(!FileExists(config))LogMessage("[SF2+] Can't find config file for health utility.");
	else
	{
		KeyValues kv = new KeyValues("SF2Plus");
		if(!kv.ImportFromFile(config))LogMessage("[SF2+] Can't parse keyvalues for health booster.");
		else
		{
			bool log = kv.GetNum("log_on_load") ? true : false;
			iHealthBoostRecoveryAmount = kv.GetNum("initial_health_boost_amount", 40);
			fHealthRecoveryDuration = kv.GetFloat("health_recovery_duration", 2.0);
			kv.GetString("sound", szUtilitySound, sizeof(szUtilitySound), "misc/halloween/spell_overheal.wav");
			FormatEx(config, sizeof(config), "sound/%s", szUtilitySound);
			if (FileExists(config))AddFileToDownloadsTable(config);
			else if (!FileExists(config, true))szUtilitySound = "misc/halloween/spell_overheal.wav", LogMessage(" !!! %s doesn't exist. Setting to default %s.", config[6], szUtilitySound);
			PrecacheSound(szUtilitySound);
			if (log)
			{
				LogMessage("initial_health_boost_amount : %i", iHealthBoostRecoveryAmount);
				LogMessage("health_recovery_duration: %0.1f", fHealthRecoveryDuration);
				LogMessage("Sound: %s", szUtilitySound);
			}
		}
	}
}
/*
public bool SF2P_UtilityRequirements(int client) // Not needed, doesn't exist = auto true
{
	return true;
}
*/
public void SF2P_UtilityUsed(int client)
{
	SetEntityHealth(client, GetClientHealth(client) + iHealthBoostRecoveryAmount);
	TF2_AddCondition(client, TFCond_HalloweenQuickHeal, fHealthRecoveryDuration);
	EmitSoundToAll(szUtilitySound, client, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
}
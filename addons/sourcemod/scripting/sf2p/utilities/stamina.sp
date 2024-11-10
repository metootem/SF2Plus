#include <sourcemod>
#include <morecolors>
#include <tf2_stocks>
#include <sf2>
#include <sdkhooks>
//#include <cbasenpc>

#include <sf2plus>

int iStaminaBoostRecoveryAmount; // ------ Stamina Recovery Amount
float fStaminaSpeedBuffDuration;
char szUtilitySound[PLATFORM_MAX_PATH];

public void SF2P_UtilityRegistered()
{
	CAddColor("r1", 0xff0000);
	CAddColor("r2", 0xe10000);
	CAddColor("r3", 0xc30000);
	CAddColor("r4", 0xa50000);
	CAddColor("r5", 0x870000);
	CAddColor("r6", 0x690000);
	
	char config[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, config, sizeof(config), "%sstamina.cfg", UTILITY_CONFIG_PATH);
	if(!FileExists(config))LogMessage("[SF2+] Can't find config file for stamina utility.");
	else
	{
		KeyValues kv = new KeyValues("SF2Plus");
		if(!kv.ImportFromFile(config))LogMessage("[SF2+] Can't parse keyvalues for stamina booster.");
		else
		{
			bool log = kv.GetNum("log_on_load") ? true : false;
			iStaminaBoostRecoveryAmount = kv.GetNum("stamina_boost_amount", 40);
			fStaminaSpeedBuffDuration = kv.GetFloat("stamina_speed_buff_duration", 10.0);
			kv.GetString("sound", szUtilitySound, sizeof(szUtilitySound), "weapons/bumper_car_speed_boost_start.wav");
			FormatEx(config, sizeof(config), "sound/%s", szUtilitySound);
			if (FileExists(config))AddFileToDownloadsTable(config);
			else if (!FileExists(config, true))szUtilitySound = "weapons/bumper_car_speed_boost_start.wav", LogMessage(" !!! %s doesn't exist. Setting to default %s.", config, szUtilitySound);
			PrecacheSound(szUtilitySound);
			if (log)
			{
				LogMessage("stamina_boost_amount : %i", iStaminaBoostRecoveryAmount);
				LogMessage("stamina_speed_buff_duration: %0.1f", fStaminaSpeedBuffDuration);
				LogMessage("Sound: %s", szUtilitySound);
			}
		}
	}
}

public bool SF2P_UtilityRequirements(int client)
{
	if (SF2_GetClientSprintPoints(client) >= 100)
	{
		CPrintToChat(client, "%s You have full stamina. {green}Stamina Booster{default} not used.", SF2PPREFIX);
		return false;
	}
	else
	{
		return true;
	}
}

public void SF2P_UtilityUsed(int client)
{
	LogMessage("%i %i", SF2_GetClientSprintPoints(client), iStaminaBoostRecoveryAmount);
	SF2_SetClientSprintPoints(client, SF2_GetClientSprintPoints(client) + iStaminaBoostRecoveryAmount);
	LogMessage("%i %i", SF2_GetClientSprintPoints(client), iStaminaBoostRecoveryAmount);
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, fStaminaSpeedBuffDuration);
	EmitSoundToAll(szUtilitySound, client, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
	if (SF2_GetClientSprintPoints(client) >= 100)
	{
		SF2_SetClientSprintPoints(client, 100);
	}
}
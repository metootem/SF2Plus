#include <sourcemod>
#include <morecolors>
#include <tf2_stocks>
#include <sf2>
#include <cbasenpc>

#include <sf2plus>

float fBatteryRechargeAmount = 1.0; // ------ Battery Recharge Amount
char szUtilitySound[PLATFORM_MAX_PATH] = "weapons/dispenser_generate_metal.wav";

public void SF2P_UtilityRegistered()
{
	CAddColor("r1", 0xff0000);
	CAddColor("r2", 0xe10000);
	CAddColor("r3", 0xc30000);
	CAddColor("r4", 0xa50000);
	CAddColor("r5", 0x870000);
	CAddColor("r6", 0x690000);
	
	char config[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, config, sizeof(config), "%sbattery.cfg", UTILITY_CONFIG_PATH);
	if(!FileExists(config))LogMessage("[SF2+] Can't find config file for battery utility.");
	else
	{
		KeyValues kv = new KeyValues("SF2Plus");
		if(!kv.ImportFromFile(config))LogMessage("[SF2+] Can't parse keyvalues for battery booster.");
		else
		{
			bool log = kv.GetNum("log_on_load") ? true : false;
			fBatteryRechargeAmount = kv.GetFloat("recharge_amount", 1.0);
			kv.GetString("sound", szUtilitySound, sizeof(szUtilitySound), "weapons/dispenser_generate_metal.wav");
			FormatEx(config, sizeof(config), "sound/%s", szUtilitySound);
			if (FileExists(config))AddFileToDownloadsTable(config);
			else if (!FileExists(config, true))szUtilitySound = "weapons/dispenser_generate_metal.wav", LogMessage(" !!! %s doesn't exist. Setting to default %s.", config, szUtilitySound);
			PrecacheSound(szUtilitySound);
			if (log)
			{
				LogMessage("recharge_amount : %0.1f", fBatteryRechargeAmount);
				LogMessage("Sound: %s", szUtilitySound);
			}
		}
	}
}

public bool SF2P_UtilityRequirements(int client)
{
	if (SF2_GetClientFlashlightBatteryLife(client) >= 1.0)
	{
		CPrintToChat(client, "%s Your {green}battery{default} is fully charged.", SF2PPREFIX);
		return false;
	}
	else
	{
		return true;
	}
}

public void SF2P_UtilityUsed(int client)
{
	SF2_SetClientFlashlightBatteryLife(client, fBatteryRechargeAmount);
	EmitSoundToAll(szUtilitySound, client, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
}
#include <sourcemod>
#include <morecolors>
#include <tf2_stocks>
#include <sdkhooks>

#include <sf2plus>

//Handle hTimer;
//float tick = 0.1;
int reward;
int min;
int max;
enum struct ClientInfoEnum
{
	bool Selected;
	
	float Goal;
}
ClientInfoEnum ClientInfo[MAXTF2PLAYERS];

public void SF2P_ChallengeRegistered()
{
	char config[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, config, sizeof(config), CHALLENGE_CONFIG_PATH);
	if (!FileExists(config))
	{
		LogMessage("[SF2+] !!! Can't find %s!", CHALLENGE_CONFIG_PATH);
	}
	else
	{
		KeyValues kv = new KeyValues("SF2Plus Challenges");
		if (!kv.ImportFromFile(config))
		{
			LogMessage("[SF2+] Can't parse keyvalues for sf2plus challenge descriptions.");
		}
		else
		{
			kv.JumpToKey("minhp");
			//kv.GetString("description", description, sizeof(description), "Travel %0.1f/%i Distance.");
			reward = kv.GetNum("reward", 4);
			min = kv.GetNum("min", 20);
			max = kv.GetNum("max", 80);
		}
		delete kv;
	}
}

public void SF2P_ChallengeSelected(int client)
{
	LogMessage("[SF2+ MinHp] Min HP Has Been Chosen For %N", client);
	ClientInfo[client].Selected = true;
	ClientInfo[client].Goal = float(GetRandomInt(min, max)) / 100;
	char desc[64];
	FormatEx(desc, sizeof(desc), "Stay Above %iPCT HP.", RoundFloat(ClientInfo[client].Goal * 100));
	ReplaceString(desc, sizeof(desc), "PCT", "%%", true);
	SF2P_SetClientChallengeDescription(client, desc, sizeof(desc));
	//hTimer = CreateTimer(tick, CheckClientProgress, 0, TIMER_REPEAT);
	SDKHook(client, SDKHook_OnTakeDamage, CheckClientHealth);
}

/*
Action CheckClientProgress(Handle timer)
{
	bool active;
	for (int i=1; i<=GetClientCount(); i++)
	{
		if (ClientInfo[i].Selected)
		{
			active = true;
			int maxhealth = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iMaxHealth", _, i);
			int health = GetEntProp(i, Prop_Send, "m_iHealth");
			float ratio = float(health) / float(maxhealth);
			if (ratio < ClientInfo[i].Goal)ChangeClientChallengeState(i, CHALLENGE_FAILED);
		}
	}
	if (!active)KillTimer(hTimer);
	return Plugin_Continue;
}
*/

public Action CheckClientHealth(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ClientInfo[victim].Selected)
	{
		int maxhealth = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iMaxHealth", _, victim);
		int health = GetEntProp(victim, Prop_Send, "m_iHealth");
		float ratio = float(health) / float(maxhealth);
		if (ratio < ClientInfo[victim].Goal)ChangeClientChallengeState(victim, CHALLENGE_FAILED);
	}
	return Plugin_Continue;
}

public void SF2P_ClientChallengeFailed(int client, int reason)
{
	if (ClientInfo[client].Selected)
	{
		if (reason == CHALLENGE_FAIL_ESCAPE)ChangeClientChallengeState(client, CHALLENGE_COMPLETED);
		else { ChangeClientChallengeState(client, CHALLENGE_FAILED); }
	}
	
}

ChangeClientChallengeState(int client, int state)
{
	ClientInfo[client].Selected = false;
	SF2P_ChangeClientChallengeState(client, state, reward);
	///LogMessage("%N completed their challenge!", client);
}
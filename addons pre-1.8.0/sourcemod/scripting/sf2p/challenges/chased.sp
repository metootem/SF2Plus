#include <sourcemod>
#include <morecolors>
#include <tf2_stocks>

#include <sf2plus>
#include <sf2>
#include <cbasenpc>

Handle hTimer;
float tick = 0.1;
int reward;
int min;
int max;
enum struct ClientInfoEnum
{
	bool Selected;
	
	int Goal;
	float Progress;
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
			kv.JumpToKey("chased");
			//kv.GetString("description", description, sizeof(description), "Travel %0.1f/%i Distance.");
			reward = kv.GetNum("reward", 5);
			min = kv.GetNum("min", 40);
			max = kv.GetNum("max", 180);
		}
		delete kv;
	}
}

public void SF2P_ChallengeSelected(int client)
{
	LogMessage("[SF2+ Chased] Chased Has Been Chosen For %N", client);
	ClientInfo[client].Selected = true;
	ClientInfo[client].Goal = GetRandomInt(min, max);
	char desc[64];
	FormatEx(desc, sizeof(desc), "Be Chased For %i Seconds", ClientInfo[client].Goal);
	SF2P_SetClientChallengeDescription(client, desc, sizeof(desc));
	hTimer = CreateTimer(tick, CheckClientProgress, 0, TIMER_REPEAT);
}

Action CheckClientProgress(Handle timer)
{
	bool active;
	for (int i=1; i<MAXTF2PLAYERS; i++)
	{
		if (ClientInfo[i].Selected && IsValidClient(i))
		{
			active = true;
			if (SF2P_IsClientChased(i))
			{
				ClientInfo[i].Progress += tick;
				char desc[64];
				FormatEx(desc, sizeof(desc), "Be Chased For %0.1f/%i Seconds", ClientInfo[i].Progress, ClientInfo[i].Goal);
				SF2P_SetClientChallengeDescription(i, desc, sizeof(desc));
			}
			if (ClientInfo[i].Progress >= ClientInfo[i].Goal)ChangeClientChallengeState(i, CHALLENGE_COMPLETED);
		}
	}
	if (!active)KillTimer(hTimer);
	return Plugin_Continue;
}

public void SF2P_ClientChallengeFailed(int client, int reason)
{
	if (ClientInfo[client].Selected)ChangeClientChallengeState(client, CHALLENGE_FAILED);
}

ChangeClientChallengeState(int client, int state)
{
	ClientInfo[client].Selected = false;
	ClientInfo[client].Progress = 0.0;
	SF2P_ChangeClientChallengeState(client, state, reward);
	///LogMessage("%N completed their challenge!", client);
}

stock bool IsValidClient(int client) // Credit to sourcemod-misc
{
	return client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}
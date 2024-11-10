#include <sourcemod>
#include <morecolors>
#include <tf2_stocks>

#include <sf2plus>
#include <sf2>
#include <cbasenpc>

int reward;
int min;
int max;

enum struct ClientInfoEnum
{
	bool Selected;
	
	int Goal;
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
			kv.JumpToKey("bossstunxtimes");
			//kv.GetString("description", description, sizeof(description), "Travel %0.1f/%i Distance.");
			reward = kv.GetNum("reward", 4);
			min = kv.GetNum("min", 2);
			max = kv.GetNum("max", 5);
		}
		delete kv;
	}
}

public void SF2P_ChallengeSelected(int client)
{
	if (SF2P_IsActiveBossStunnable())
	{
		LogMessage("[SF2+ BossStunXTimes] Boss Stun X Times Has Been Chosen For %N", client);
		ClientInfo[client].Selected = true;
		ClientInfo[client].Goal = GetRandomInt(min, max);
		char desc[64];
		if (ClientInfo[client].Goal == 1)FormatEx(desc, sizeof(desc), "Stun A Boss.");
		else { FormatEx(desc, sizeof(desc), "Stun A Boss %i Times.", ClientInfo[client].Goal); }
		SF2P_SetClientChallengeDescription(client, desc, sizeof(desc));
	}
	else
	{
		LogMessage("[SF2+ BossStunXTimes] No Active Boss Is Stunnable!");
		SF2P_RerollClientChallenge(client);
	}
}

public void SF2_OnBossStunned(int bossIndex, int client)
{
	if (client == -1)
	{
		int target = SF2_GetBossTarget(bossIndex);
		if (SF2_IsClientUsingFlashlight(target) && ClientInfo[target].Selected)
		{
			AddClientProgress(target);
		}
	}
	else if (ClientInfo[client].Selected)
	{
		AddClientProgress(client);
	}
}

AddClientProgress(int client)
{
	ClientInfo[client].Goal--;
	if (ClientInfo[client].Goal < 1)ChangeClientChallengeState(client, CHALLENGE_COMPLETED);
	else
	{
		char desc[64];
		FormatEx(desc, sizeof(desc), "Stun A Boss %i %s", ClientInfo[client].Goal, (ClientInfo[client].Goal == 1 ? "Time." : "Times."));
		SF2P_SetClientChallengeDescription(client, desc, sizeof(desc));
	}
}

public void SF2P_ClientChallengeFailed(int client, int reason)
{
	if (ClientInfo[client].Selected)ChangeClientChallengeState(client, CHALLENGE_FAILED);
}

ChangeClientChallengeState(int client, int state)
{
	ClientInfo[client].Selected = false;
	SF2P_ChangeClientChallengeState(client, state, reward);
	///LogMessage("%N completed their challenge!", client);
}
#include <sourcemod>
#include <morecolors>
#include <tf2_stocks>

#include <sf2plus>
#include <sf2>
#include <cbasenpc>

char description[] = "Travel %0.1f/%i Distance.";
int reward;
int min;
int max;
Handle hTimer;
enum struct ClientInfoEnum
{
	bool Selected;
	int Goal;
	
	float PrevPos[3];
	float Pos[3];
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
			kv.JumpToKey("traveldist");
			kv.GetString("description", description, sizeof(description), "Travel %0.1f/%i Distance.");
			reward = kv.GetNum("reward", 3);
			min = kv.GetNum("min", 200);
			max = kv.GetNum("max", 500);
		}
		delete kv;
	}
}

public void SF2P_ChallengeSelected(int client)
{
	LogMessage("[SF2+ TravelDist] Travel Dist Has Been Chosen For %N", client);
	ClientInfo[client].Selected = true;
	ClientInfo[client].Goal = GetRandomInt(min, max);
	char desc[64];
	FormatEx(desc, sizeof(desc), "Travel %0.1f/%i Distance.", ClientInfo[client].Progress, ClientInfo[client].Goal);
	SF2P_SetClientChallengeDescription(client, desc, sizeof(desc));
	GetClientAbsOrigin(client, ClientInfo[client].PrevPos);
	hTimer = CreateTimer(1.0, CheckClientProgress, 0, TIMER_REPEAT);
}

Action CheckClientProgress(Handle timer)
{
	bool active;
	for (int i=1; i<MAXTF2PLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			if (ClientInfo[i].Selected && TF2_GetClientTeam(i) == TFTeam_Red)
			{
				active = true;
				GetClientAbsOrigin(i, ClientInfo[i].Pos);
				ClientInfo[i].Progress += GetVectorDistance(ClientInfo[i].PrevPos, ClientInfo[i].Pos) * 0.007473;
				if (ClientInfo[i].Progress >= ClientInfo[i].Goal)ChangeClientChallengeState(i, CHALLENGE_COMPLETED);
				else
				{
					char desc[64];
					FormatEx(desc, sizeof(desc), "Travel %0.1f/%i Distance.", ClientInfo[i].Progress, ClientInfo[i].Goal);
					SF2P_SetClientChallengeDescription(i, desc, sizeof(desc));
					ClientInfo[i].PrevPos = ClientInfo[i].Pos;
				}
			}
		}
		
	}
	if (!active)KillTimer(hTimer), LogMessage("Killing hTimer.");
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
	//LogMessage("%N completed their challenge!", client);
}

stock bool IsValidClient(int client) // Credit to sourcemod-misc
{
	return client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}
#include <sourcemod>
#include <morecolors>
#include <tf2_stocks>

#include <sf2plus>
#include <navmesh>
#include <sdkhooks>

int reward
int iItemsCount;

enum struct ClientInfoEnum
{
	bool Selected;
	
	HidingSpot CollectibleSpot;
	int CollectibleEnt;
	char CollectibleSound[PLATFORM_MAX_PATH];
}
ClientInfoEnum ClientInfo[MAXTF2PLAYERS];

public void SF2P_ChallengeRegistered()
{
	iItemsCount = 0;
	char config[PLATFORM_MAX_PATH], section[32], dl[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, config, sizeof(config), CHALLENGE_CONFIG_PATH);
	KeyValues kv = new KeyValues("SF2Plus Challenges");
	kv.ImportFromFile(config);
	kv.JumpToKey("findcollectible");
	reward = kv.GetNum("reward", 4);
	if (kv.GotoFirstSubKey()) //items
	{
		if (kv.GotoFirstSubKey())
		{
			do 
			{
				iItemsCount++;
				kv.GetSectionName(section, sizeof(section));
				kv.GetString("model", config, sizeof(config));
				bool found;
				char ext[][] = {".dx80.vtx", ".dx90.vtx", ".mdl", ".sw.vtx", ".vvd"};
				for (int i; i<sizeof(ext); i++)
				{
					FormatEx(dl, sizeof(dl), "%s%s", config, ext[i]);
					if (!FileExists(dl)) 
					{ 
						if (!FileExists(dl, true))LogMessage("[SF2+] !!! Couldn't find %s !", dl);
						else { found = true; }
					}
					else 
					{ 
						AddFileToDownloadsTable(dl);
						found = true;
					}
				}
				if (found)
				{
					FormatEx(config, sizeof(config), "%s.mdl", config);
					PrecacheModel(config);
					LogMessage("Registered %s: %s", section, config);
				}
				kv.GetString("sound", config, sizeof(config), "items/gift_pickup.wav");
				FormatEx(dl, sizeof(dl), "sound/%s", config);
				if (!FileExists(dl)) 
				{ 
					if (!FileExists(dl, true))LogMessage("!!! Couldn't find %s", dl);
					else { PrecacheSound(config); }
				}
				else
				{
					PrecacheSound(config);
					AddFileToDownloadsTable(dl);
				}
			} while (kv.GotoNextKey())
		}
	}
	LogMessage("Item Count: %i", iItemsCount);
	delete kv;
}

public void SF2P_ChallengeSelected(int client)
{
	LogMessage("[SF2+ FindCollectible] Find Collectible Has Been Chosen For %N", client);
	ClientInfo[client].Selected = true;
	
	float pos[3], rot[3], offset[3], rot_y[2], rot_z[2], rot_x[2];
	ClientInfo[client].CollectibleSpot = NavMesh_GetRandomHidingSpot();
	ClientInfo[client].CollectibleSpot.GetPosition(pos);
	//LogMessage("Selected Random Hiding Spot: %f %f %f", pos[0], pos[1], pos[2]);
	int item = GetRandomInt(1, iItemsCount);
	
	char model[PLATFORM_MAX_PATH], section[32], skin[3], scale[5];
	BuildPath(Path_SM, model, sizeof(model), CHALLENGE_CONFIG_PATH);
	KeyValues kv = new KeyValues("SF2Plus Challenges");
	kv.ImportFromFile(model);
	kv.JumpToKey("findcollectible");
	if (kv.GotoFirstSubKey()) //items
	{
		if (kv.GotoFirstSubKey())
		{
			for (int i=1; i<item; i++)
			{
				kv.GotoNextKey();
			}
			kv.GetSectionName(section, sizeof(section));
			LogMessage("Section: %s", section);
			kv.GetString("model", model, sizeof(model), "models/items/gift_festive.mdl");
			FormatEx(model, sizeof(model), "%s.mdl", model);
			LogMessage("Model: %s", model);
			kv.GetString("sound", ClientInfo[client].CollectibleSound, PLATFORM_MAX_PATH, "items/gift_pickup.wav");
			kv.GetString("skin", skin, sizeof(skin), "0");
			kv.GetVector("offset", offset);
			kv.GetString("scale", scale, sizeof(scale), "1.0");
			
			kv.GetVector("rotation", rot);
			rot_y[0] = kv.GetFloat("rot_y_min", -1.0);
			rot_y[1] = kv.GetFloat("rot_y_max", 360.0);
			
			rot_z[0] = kv.GetFloat("rot_z_min", -1.0);
			rot_z[1] = kv.GetFloat("rot_z_max", 360.0);
			
			rot_x[0] = kv.GetFloat("rot_x_min", -1.0);
			rot_x[1] = kv.GetFloat("rot_x_max", 360.0);
		}
	}
	delete kv;
	
	ClientInfo[client].CollectibleEnt = CreateEntityByName("prop_dynamic_override");

	DispatchKeyValue(ClientInfo[client].CollectibleEnt, "model", model);
	DispatchKeyValue(ClientInfo[client].CollectibleEnt, "skin", skin);
	DispatchKeyValue(ClientInfo[client].CollectibleEnt, "modelscale", scale);
	DispatchKeyValue(ClientInfo[client].CollectibleEnt, "disablereceiveshadows", "1");
	DispatchKeyValue(ClientInfo[client].CollectibleEnt, "disableshadows", "1");
	DispatchKeyValue(ClientInfo[client].CollectibleEnt, "solid", "2");
	DispatchSpawn(ClientInfo[client].CollectibleEnt);
	//SetEntityMoveType(ClientInfo[client].CollectibleEnt, MOVETYPE_NONE);
	pos[0] += offset[0];
	pos[1] += offset[1];
	pos[2] += offset[2];
	
	if (rot_y[0] >= 0)rot[0] = GetRandomFloat(rot_y[0], rot_y[1]);
	if (rot_z[0] >= 0)rot[1] = GetRandomFloat(rot_z[0], rot_z[1]);
	if (rot_x[0] >= 0)rot[2] = GetRandomFloat(rot_x[0], rot_x[1]);
	TeleportEntity(ClientInfo[client].CollectibleEnt, pos, rot, NULL_VECTOR);
	
	SDKHook(ClientInfo[client].CollectibleEnt, SDKHook_OnTakeDamage, Collectible_Hit);
	SDKHook(ClientInfo[client].CollectibleEnt, SDKHook_SetTransmit, Collectible_SetTransmit);
	
	char desc[32];
	FormatEx(desc, sizeof(desc), "Find A %s.", section);
	SF2P_SetClientChallengeDescription(client, desc, sizeof(desc));
	//LogMessage("collectible ent = %i", ClientInfo[client].CollectibleEnt);
}

public Action Collectible_Hit(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (ClientInfo[attacker].CollectibleEnt == victim)
	{
		EmitSoundToClient(attacker, ClientInfo[attacker].CollectibleSound, ClientInfo[attacker].CollectibleEnt, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		//LogMessage("%s", ClientInfo[attacker].CollectibleSound);
		ChangeClientChallengeState(attacker, CHALLENGE_COMPLETED);
	}
	return Plugin_Continue;
}

public Action Collectible_SetTransmit(int entity, int client)
{
	if (ClientInfo[client].CollectibleEnt == entity)
	{
		//LogMessage("Setting Transmit For %i to %N", entity, client);
		return Plugin_Continue;
	}
	else { return Plugin_Handled; }
}

public void SF2P_ClientChallengeFailed(int client, int reason)
{
	if (ClientInfo[client].Selected)ChangeClientChallengeState(client, CHALLENGE_FAILED);
}

ChangeClientChallengeState(int client, int state)
{
	ClientInfo[client].Selected = false;
	if (IsValidEntity(ClientInfo[client].CollectibleEnt))RemoveEntity(ClientInfo[client].CollectibleEnt)
	SF2P_ChangeClientChallengeState(client, state, reward);
	///LogMessage("%N completed their challenge!", client);
}
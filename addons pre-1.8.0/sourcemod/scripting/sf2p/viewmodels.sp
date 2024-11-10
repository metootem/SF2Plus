#define FFADE_IN            0x0001        // Just here so we don't pass 0 into the function
#define FFADE_OUT           0x0002        // Fade out (not in)
#define FFADE_MODULATE      0x0004        // Modulate (don't blend)
#define FFADE_STAYOUT       0x0008        // ignores the duration, stays faded out until new ScreenFade message received
#define FFADE_PURGE         0x0010        // Purges all other fades, replacing them with this one

bool bIsClientUtilViewmdlActive[MAXTF2PLAYERS];

char classes[10][PLATFORM_MAX_PATH] = { "unknown", "scout", "sniper", "soldier", "demoman", "medic", "heavy", "pyro", "spy", "engineer" };

int doublehandedweapons[] = { 357, 153, 348, 466, 593, 739, 214, 457, 326, 38, 813, 172, 327, 482, 132, 1082, 310, 426, 43, 239, 656, 331, 155, 589, 329, 5, 2, 7 };
int iClientViewmodelArmsEnt[MAXTF2PLAYERS] = { -1, ... }; // ------ Viewmodel Arms Entity Per Client

public Action SF2P_CreateUtilityViewmodel(int client) // todo: find a fix for tf_use_min_viewmodels
{
	LogMessage("[SF2+] Creating viewmodel for %N", client);
	int utility_viewmdl = CreateEntityByName("prop_dynamic_override");
	
	DispatchKeyValue(utility_viewmdl, "model", SF2PEMPTYMODEL);
	DispatchKeyValue(utility_viewmdl, "disablereceiveshadows", "1");
	DispatchKeyValue(utility_viewmdl, "disableshadows", "1");
	DispatchKeyValue(utility_viewmdl, "solid", "0");
	DispatchSpawn(utility_viewmdl);
	SetEntityMoveType(utility_viewmdl, MOVETYPE_NONE);
	float pos[3];
	GetClientAbsOrigin(client, pos);
	float eyepos[3];
	GetClientEyePosition(client, eyepos);
	float ang[3];
	GetClientEyeAngles(client, ang);
	TeleportEntity(utility_viewmdl, pos, ang, NULL_VECTOR);

	int playerviewmdl = GetEntPropEnt(client, Prop_Data, "m_hViewModel", 0);
	
	SetVariantString("!activator");
	AcceptEntityInput(utility_viewmdl, "SetParent", playerviewmdl);
	SetVariantString("!activator");
	AcceptEntityInput(utility_viewmdl, "SetAttached", playerviewmdl);
	if (SF2P_GetClientUtilityViewmodelEntity(client) == -1)
	{
		SF2P_SetClientUtilityViewmodelEntity(client, utility_viewmdl);
	}
	
	QueryClientConVar(client, "tf_use_min_viewmodels", CheckCvar); // TODO: find a fix for tf_use_min_viewmodels
	return Plugin_Continue;
}

public void CheckCvar(QueryCookie cookie, int client, ConVarQueryResult result, const char[] cvarName, const char[] cvarValue, any value)
{
	if (StringToInt(cvarValue) == 1)
	{
		CPrintToChat(client, "%s Warning! tf_use_min_viewmodels tends to break custom viewmodels. Setting the value to 0 is recommended.", SF2PPREFIX)
	}
}

public Action SF2P_ActivateUtilityViewmodel(int client, int util_slot)
{
	int class = _:TF2_GetPlayerClass(client);
	int utility_viewmdl = SF2P_GetClientUtilityViewmodelEntity(client);
	//LogMessage("%i %i %i", utility_viewmdl, bIsClientUtilViewmdlActive[client], IsValidEntity(utility_viewmdl));
	
	if (utility_viewmdl != -1 && !bIsClientUtilViewmdlActive[client])
	{
		char value[PLATFORM_MAX_PATH];
		bIsClientUtilViewmdlActive[client] = true;
		
		// Set Viewmodel Model
		SF2P_GetClientUtilityViewmodelValue(client, util_slot, "model", value, sizeof(value));
		SetEntityModel(utility_viewmdl, value);
		SF2P_GetClientUtilityViewmodelValue(client, util_slot, "skin", value, sizeof(value));
		SetEntProp(utility_viewmdl, Prop_Send, "m_nSkin", StringToInt(value));
		SF2P_GetClientUtilityViewmodelValue(client, util_slot, "skin", value, sizeof(value));
		SetEntProp(utility_viewmdl, Prop_Send, "m_nBody", StringToInt(value));
		
		// Create Class Arms
		int playerviewmdlarms = CreateEntityByName("prop_dynamic_override");
		
		char classarms[PLATFORM_MAX_PATH];
		if (class == 4)Format(classarms, sizeof(classarms), "models/weapons/c_models/c_demo_arms.mdl", classes[class]);
		else { Format(classarms, sizeof(classarms), "models/weapons/c_models/c_%s_arms.mdl", classes[class]); }
		DispatchKeyValue(playerviewmdlarms, "model", classarms);
		
		DispatchKeyValue(playerviewmdlarms, "disablereceiveshadows", "1");
		DispatchKeyValue(playerviewmdlarms, "disableshadows", "1");
		DispatchKeyValue(playerviewmdlarms, "solid", "0");
		DispatchSpawn(playerviewmdlarms);
		SetEntityMoveType(playerviewmdlarms, MOVETYPE_NONE);
		
		// Parent Class Arms To Viewmodel
		SetVariantString("!activator");
		AcceptEntityInput(playerviewmdlarms, "SetParent", utility_viewmdl);
		SetEntProp(playerviewmdlarms, Prop_Send, "m_fEffects", EF_BONEMERGE);
		
		iClientViewmodelArmsEnt[client] = playerviewmdlarms;
		
		// Hide Main Viewmodel
		int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")
		int weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex")
		bool IsDoubleHanded;
		for (int i; i < sizeof(doublehandedweapons); i++)
		{
			if (weaponindex == doublehandedweapons[i])
			{
				IsDoubleHanded = true;
				break;
			}
		}
		SF2P_GetClientUtilityViewmodelValue(client, util_slot, "hideMainViewmodel", value, sizeof(value));
		if (StringToInt(value) || IsDoubleHanded)SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 0);
		
		// Play Animation
		SetVariantString(classes[class]);
		if (!AcceptEntityInput(utility_viewmdl, "SetAnimation"))LogMessage("[SF2+] Can't find class animation in viewmodel.");
		SetEntPropFloat(utility_viewmdl, Prop_Send, "m_flPlaybackRate", 1.0);
		
		// Play Sound
		SF2P_GetClientUtilityViewmodelValue(client, util_slot, "sound", value, sizeof(value));
		Format(classarms, sizeof(classarms), "sound/%s", value);
		if (!FileExists(classarms)) { LogMessage("[SF2+] Can't find %s file.", classarms); }
		else { EmitSoundToAll(value, client, SNDCHAN_AUTO, SNDLEVEL_SCREAMING); }
		
		// Screen Overlay
		SF2P_GetClientUtilityViewmodelValue(client, util_slot, "screendelay", value, sizeof(value));
		
		Handle pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackCell(pack, util_slot);
		
		CreateTimer(StringToFloat(value), FadeTimer, pack, 0);
		
		// Set Deactivation Timer
		SF2P_GetClientUtilityViewmodelValue(client, util_slot, "duration", value, sizeof(value));
		
		CreateTimer(StringToFloat(value), SF2P_DeactivateUtilityViewmodel, pack, 0);
	}
	return Plugin_Continue;
}

public Action SF2P_DeactivateUtilityViewmodel(Handle timer, any data)
{
	ResetPack(data);
	int client = ReadPackCell(data);
	int util_slot = ReadPackCell(data);
	CloseHandle(data);
	char value[PLATFORM_MAX_PATH];
	int weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	int weaponindex;
	if (IsValidEntity(weapon))weaponindex = GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
	bool IsDoubleHanded;
	
	for (int i; i < sizeof(doublehandedweapons); i++)
	{
		if (weaponindex == doublehandedweapons[i])
		{
			IsDoubleHanded = true;
			break;
		}
	}
	SF2P_GetClientUtilityViewmodelValue(client, util_slot, "hideMainViewmodel", value, sizeof(value));
	if (StringToInt(value) || IsDoubleHanded)SetEntProp(client, Prop_Send, "m_bDrawViewmodel", 1); // Unhide Viewmodel
	
	int utility_viewmdl = SF2P_GetClientUtilityViewmodelEntity(client);
	if (IsValidEntity(utility_viewmdl))SetEntityModel(utility_viewmdl, SF2PEMPTYMODEL), SetEntPropFloat(utility_viewmdl, Prop_Send, "m_flPlaybackRate", 0.0);

	if (IsValidEntity(iClientViewmodelArmsEnt[client]))RemoveEntity(iClientViewmodelArmsEnt[client]);
	
	bIsClientUtilViewmdlActive[client] = false;
	
	return Plugin_Continue;
}

public void SF2P_SetViewmodelActiveBool(int client, bool active)
{
	bIsClientUtilViewmdlActive[client] = active;
}

public Action FadeTimer(Handle timer, any data)
{
	ResetPack(data);
	int client = ReadPackCell(data);
	int util_slot = ReadPackCell(data);
	
	char value[18];
	SF2P_GetClientUtilityViewmodelValue(client, util_slot, "screenfadecolor", value, sizeof(value));
	char val[4][4];
	int val_idx=0;
	for (int i; i<4; i++)
	{
		for (int k; k<3; k++)
		{
			if (value[val_idx] == ' ')break;
			else
			{
				val[i][k] = value[val_idx];
				val_idx++;
			}
		}
		val_idx++;
	}
	int color[4];
	for (int i; i<4; i++)color[i] = StringToInt(val[i]);
	
	if (color[3] > 0)
	{
		char command[3][] = {"screenfadein","screenholdtime","screenfadeout"};
		char screen_val[3][PLATFORM_MAX_PATH];
		int idx;
		bool end;
		for (int i; i<3; i++)
		{
			idx = 0;
			SF2P_GetClientUtilityViewmodelValue(client, util_slot, command[i], value, sizeof(value));
			end = false;
			do 
			{
				if (value[idx] == '.')
				{
					for (int j; j<3; j++)
					{
						if (strlen(value)-1-idx > 0)screen_val[i][idx] = value[idx + 1];
						else { screen_val[i][idx] = '0'; }
						idx++
					}
					end = true;
				}
				else { screen_val[i][idx] = value[idx]; }
				
				idx++;
				
				if (idx > strlen(value))end = true;
				
			} while (end == false)
		}
		
		ScreenFade(client, StringToInt(screen_val[2]), StringToInt(screen_val[1]), 1, color);
	}
	
	return Plugin_Continue;
}

void ScreenFade(int client, int fadeTime, int holdTime, int flag = FFADE_OUT, int color[4] = {255, 255, 255, 255})
{
	Handle message = StartMessageOne("Fade", client);
	
	BfWriteShort(message, fadeTime);
	BfWriteShort(message, holdTime);
	BfWriteShort(message, flag);
	BfWriteByte(message, color[0]);
	BfWriteByte(message, color[1]);
	BfWriteByte(message, color[2]);
	BfWriteByte(message, color[3]);
	
	EndMessage();
}
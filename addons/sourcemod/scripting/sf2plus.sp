
#include <sourcemod>
#include <tf2_stocks>
#include <sf2> //include to access what SF2 shares with other plugins
//#include <cbasenpc>
#include <clientprefs>
#include <morecolors>
#include <sdkhooks>

#include <sf2plus>
#tryinclude <steamworks>

#include "sf2p/menus.sp"
#include "sf2p/viewmodels.sp"


// --- Global Forwards
GlobalForward g_OnClientLevelUp;
GlobalForward g_OnClientPrestigeUp;
GlobalForward g_OnUtilityRegistered;
GlobalForward g_OnUtilityUsed;
GlobalForward g_OnChallengeRegistered;
GlobalForward g_OnChallengeSelected;
GlobalForward g_ClientChallengeFailed;

// Uncategorised Variables
char szTF2Classes[10][PLATFORM_MAX_PATH] = { "unknown", "scout", "sniper", "soldier", "demoman", "medic", "heavy", "pyro", "spy", "engineer" };
char szSF2Difficulty[6][10] = { "easy", "normal", "hard", "insane", "nightmare", "apollyon" }; // SF2 Difficulties For Config
char szGameDesc[PLATFORM_MAX_PATH];

// --- Client Variables
Handle hTravelDistTimer;
Handle hInspectTimer;
Handle hSixthSenseTimer;

int iClientPrevHealth[MAXTF2PLAYERS];

enum struct ClientInfoEnum
{
	int Utility[3];
	int UtilityUses[3];
	int Viewmodel[3];
	int ViewmodelEnt;
	int EXP;
	int Level;
	int Prestige;
	bool Chased;
	bool Heard;
	
	int Challenge;
	char ChallengeDescription[PLATFORM_MAX_PATH];
	int ChallengeState;
	
	int HudFlags;
	float HudPos[2];
	bool SettingHud;
	
	int ChatFlags;
	
	bool SF2LegacyHud;
	bool SecondLife;
	
	float PrevVector[3];
	bool LethalSurvival;
	bool SixthSense;
	float SixthSenseTime;
	bool SixthSenseCooldown;
	
	int TotalRoundsPlayed;
	bool FirstRound;
	bool RoundInteracted;
	int TotalMapsPlayed;
	float TravelDist;
	int TotalPages;
	int Escapes;
	int ChaseCount;
	int Deaths;
	int TotalUtilityUses;
	int CompletedChallengeCount;
}
ClientInfoEnum ClientInfo[MAXTF2PLAYERS];

// --- EXP Variables
bool bEXP; // Enable EXP features

enum struct EXPInfoEnum
{
	int PrestigeUp;
	char PrestigeUp_Sound[PLATFORM_MAX_PATH];
	int LevelUp;
	// EXP Rewards
	int PageCollect;
	int ClientEscape;
	int ChaseTakeover;
	int BossStun;
	int UsedDroppedUtility;
}
EXPInfoEnum EXPInfo;

enum struct LevelUnlockEnum
{
	int Third_Sense;
	int First_Utility;
	int Second_Utility;
	int Third_Utility;
}
LevelUnlockEnum LevelUnlock;

enum struct PrestigeInfoEnum
{
	int LethalSurvival_Unlock;
	float LethalSurvival_Length;
	char LethalSurvival_Sound[PLATFORM_MAX_PATH];
	
	int SixthSense_Unlock;
	float SixthSense_ActivateValue;
	float SixthSense_Length;
	float SixthSense_Cooldown;
	char SixthSense_Sound[PLATFORM_MAX_PATH];
	char SixthSense_SoundEnd[PLATFORM_MAX_PATH];
	char SixthSense_SoundCooldownEnd[PLATFORM_MAX_PATH];
}
PrestigeInfoEnum PrestigeInfo;

bool bChallenges = true; // Enable Challenges
int iChallengeCount;
enum struct ChallengeInfoEnum
{
	Handle handle;
	char Name[32];
}
ChallengeInfoEnum ChallengeInfo[MAXCHALLENGES];

// --- Utility Variables
bool bUtilities; // Enable Utilities
int iUtilityCount; // ------ Amount Of Installed Utilities
int iUtilityDefaultAmount; // Default amount of utility uses
enum struct UtilityInfoEnum
{
	Handle handle;
	char Name[UTILITYNAMESIZE];
	char HudName[64];
	int DifficultyAmount[Difficulty_Max];
}
UtilityInfoEnum UtilityInfo[MAXUTILITIES];


// --- Viewmodel Variables
int Viewmodels_load; // Enable Utility Viewmodels

enum struct ClientUtilViewmodelEnum
{
	int idx;
	char name[PLATFORM_MAX_PATH];
	char hudname[PLATFORM_MAX_PATH];
	char model[PLATFORM_MAX_PATH];
	int skin;
	int body;
	float duration;
	float delay;
	bool hideMainViewmodel[10];
	int screenfadecolor[4];
	float screendelay;
	float screenfadein;
	float screenholdtime;
	float screenfadeout;
}
ClientUtilViewmodelEnum UtilViewmodel[MAXUTILITIES][MAXVIEWMODELS]; // Utility Viewmodel Indexes Per Utility [utility][viewmodel_index in utility]

char UtilViewmdlSound[MAXUTILITIES][MAXVIEWMODELS][10][PLATFORM_MAX_PATH]; // Utility Viewmodel Use Sound Per Class [utility][viewmodel_index in utility][class]
// --- Viewmodel count
int iUtilViewmodel_count[MAXUTILITIES]; // Total count of all viewmodels per utility
int iUtilViewmodel_totalcount; // Total count of all viewmodels


// --- HUD Variables
Handle hSF2PSyncHud1; // ----- HUD
Handle hSF2PHudTimer;
float fSF2PHudRefreshTimer = 0.7;
float fHud_Pos_Default[2];
char szHudIcons[][16] = { "☤", "❗", "❓", "✙", "≫", "↓", "↑", "↑↑", "♥", "⏰", "☠", "♨", "⛆", "☉", "⦵", "-", "☥" };

// SF2 Boss Variables
int iActiveBosses;
enum struct BossInfoEnum
{
	int Target;
	int PrevTarget;
	int GlowEnt[MAXTF2PLAYERS];
}
BossInfoEnum BossInfo[MAX_BOSSES];

Database DB; // ------ MySQL Database

public void OnPluginStart()
{
	//Commands
	RegConsoleCmd("sm_sf2putil1", Cmd_SF2PUtil1Use, "SF2Plus Use First Utility.");
	RegConsoleCmd("sm_sf2putil2", Cmd_SF2PUtil2Use, "SF2Plus Use Second Utility.");
	RegConsoleCmd("sm_sf2putil3", Cmd_SF2PUtil3Use, "SF2Plus Use Third Utility.");
	RegConsoleCmd("sm_sf2p", Cmd_SF2PMainMenu, "SF2Plus Main Menu");
	RegConsoleCmd("sm_sf2plus", Cmd_SF2PMainMenu, "SF2Plus Main Menu");
	RegConsoleCmd("sm_tsb", Cmd_SF2PTestSpawnBoss);
	RegConsoleCmd("sm_tsb2", Cmd_SF2PTestSpawnBoss2);
	
	//Forwards
	g_OnClientLevelUp = new GlobalForward("SF2P_OnClientLevelUp", ET_Ignore, Param_Cell, Param_Cell);
	g_OnClientPrestigeUp = new GlobalForward("SF2P_OnClientPrestigeUp", ET_Ignore, Param_Cell, Param_Cell);
	g_OnUtilityRegistered = new GlobalForward("SF2P_OnUtilityRegistered", ET_Ignore, Param_String);
	//g_UtilityRequirements = new GlobalForward("SF2P_OnUtilityUsed", ET_Ignore, Param_Cell, Param_String);
	g_OnUtilityUsed = new GlobalForward("SF2P_OnUtilityUsed", ET_Ignore, Param_Cell, Param_String, Param_Cell);
	g_OnChallengeRegistered = new GlobalForward("SF2P_OnChallengeRegistered", ET_Ignore, Param_String);
	g_OnChallengeSelected = new GlobalForward("SF2P_OnChallengeSelected", ET_Ignore, Param_Cell, Param_String);
	g_ClientChallengeFailed = new GlobalForward("SF2P_ClientChallengeFailed", ET_Ignore, Param_Cell, Param_Cell);
	
	//Hooks
	HookEvent("player_spawn", Hook_OnClientSpawn, EventHookMode_Post);
	HookEvent("player_death", Hook_OnClientDeath, EventHookMode_Post);
	HookEvent("player_hurt", Hook_OnClientPreHurt, EventHookMode_Pre);
	
	// User Messages
	//HookUserMessage(GetUserMessageId("Fade"), Hook_ScreenFade, true);
	
	//HUD
	hSF2PSyncHud1 = CreateHudSynchronizer();
	
	//Client Prefs
	char Error[128];
	
	DB = SQL_Connect("sf2plus", true, Error, sizeof(Error));
	if (!IsValidHandle(DB))
	{
		LogMessage("[SF2+] Can't connect to MySQL Server: %s", Error);
		CloseHandle(DB);
	}
	else
	{
		LogMessage("[SF2+] Connection to MySQL Server successful");
	}
	
	for (int i = 1; i < MAXTF2PLAYERS; i++) //Client Prefs late load
	{
		if (IsValidClient(i))
		{
			if (!AreClientCookiesCached(i))
			{
				continue;
			}
			OnClientCookiesCached(i);
		}
		
	}
	
	PrecacheGlobal();
	
	//Morecolors
	CAddColor("r1", 0xff0000);
	CAddColor("r2", 0xe10000);
	CAddColor("r3", 0xc30000);
	CAddColor("r4", 0xa50000);
	CAddColor("r5", 0x870000);
	CAddColor("r6", 0x690000);
	
	LoadTranslations("common.phrases.txt");
}

public void OnConfigsExecuted()
{
	iUtilityCount = 0;
	bUtilities = true;
	char config[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, config, sizeof(config), CONFIG_PATH);
	if (!FileExists(config))
	{
		LogMessage("configs/sf2plus/sf2plus.cfg doesn't exist.");
		fSF2PHudRefreshTimer = 0.7;
		bUtilities = false;
		bEXP = false;
		Viewmodels_load = false;
		bChallenges = false;
		fHud_Pos_Default[0] = 0.210;
		fHud_Pos_Default[1] = 0.793;
		LogMessage("Hud Timer: %0.1f", fSF2PHudRefreshTimer);
		LogMessage("Utilities: Disabled");
		LogMessage("Player EXP: Disabled");
		LogMessage("Challenges: Disabled");
		LogMessage("Viewmodels: Disabled");
		
	}
	else
	{
		KeyValues kv = new KeyValues("SF2Plus");
		if (!kv.ImportFromFile(config))
		{
			LogMessage("[SF2+] Can't parse keyvalues.");
		}
		kv.JumpToKey("OnLoad"); // -------------------------------------------------------------------------------------------------//
		fSF2PHudRefreshTimer = kv.GetFloat("hudtimer", 0.7); 
		LogMessage("[SF2+] Hud Timer: %0.1f", fSF2PHudRefreshTimer); 
		
		bUtilities = kv.GetNum("enable_utilities") ? true : false;
		LogMessage("[SF2+] Utilities: %s", (bUtilities ? "Enabled" : "Disabled"));
		
		bEXP = kv.GetNum("enable_exp") ? true : false;
		LogMessage("[SF2+] Player EXP: %s", (bEXP ? "Enabled" : "Disabled"));
		
		bChallenges = kv.GetNum("enable_challenges") ? true : false;
		LogMessage("[SF2+] Challenges: %s", (bChallenges ? "Enabled" : "Disabled"));
		int Viewmodels_download;
		if (bUtilities)
		{
			Viewmodels_load = kv.GetNum("enable_viewmodels");
			Viewmodels_download = kv.GetNum("allow_download");
		}
		
		fHud_Pos_Default[0] = kv.GetFloat("hud_x_default", 0.210);
		fHud_Pos_Default[1] = kv.GetFloat("hud_y_default", 0.793);
		LogMessage("[SF2+] Hud Default X: %0.3f Y: %0.3f", fHud_Pos_Default[0], fHud_Pos_Default[1]);
		
		kv.GetString("Prestige Up Sound", EXPInfo.PrestigeUp_Sound, PLATFORM_MAX_PATH, "items/powerup_pickup_king.wav");
		FormatEx(config, sizeof(config), "sound/%s", EXPInfo.PrestigeUp_Sound);
		if (FileExists(config))LogMessage("[SF2+] Prestige Up Sound: %s", EXPInfo.PrestigeUp_Sound), AddFileToDownloadsTable(config);
		else
		{
			if (FileExists(config, true))LogMessage("[SF2+] Prestige Up Sound: %s", EXPInfo.PrestigeUp_Sound);
			else
			{
				LogMessage("[SF2+] !!! Can't find 'sound' for Prestige Up. Setting to default items/powerup_pickup_king.wav", EXPInfo.PrestigeUp_Sound);
				EXPInfo.PrestigeUp_Sound = "items/powerup_pickup_king.wav";
			}
		}
		PrecacheSound(EXPInfo.PrestigeUp_Sound);
		
		kv.GetString("game_desc", szGameDesc, sizeof(szGameDesc), "");
		
		LogMessage("[SF2+]");
		kv.GoBack(); // ------------------------------------------------------------------------------------------------------------//
		
		if (bUtilities)
		{
			kv.JumpToKey("Utilities"); // ----------------------------------------------------------------------------------------------//
			if (kv.GotoFirstSubKey(false)) // ------ Utility count																	   	//
			{  
				do 
				{  
					iUtilityCount++; 
				} while (kv.GotoNextKey(false)) 
				
				kv.GoBack(); 
			} 
			char key2[3]; 
			char util_path[PLATFORM_MAX_PATH]; 
			int skip;
			for (int i; i < iUtilityCount; i++) // ------ Register utility plugins														
			{
				IntToString(i+1, key2, sizeof(key2)); 
				kv.GetString(key2, UtilityInfo[i-skip].Name, UTILITYNAMESIZE); 
				BuildPath(Path_SM, util_path, sizeof(util_path), "plugins/sf2p/utilities/%s.smx", UtilityInfo[i-skip].Name); 
				if (!FileExists(util_path)) 
				{  
					LogMessage("!!! Couldn't find %s utility plugin!", UtilityInfo[i-skip].Name); 
				} 
				else 
				{  
					FormatEx(util_path, sizeof(util_path), "sf2p\\utilities\\%s.smx", UtilityInfo[i-skip].Name); //FindPluginByFile doesn't allow forward slash for path ?????? stupid asf
					UtilityInfo[i-skip].handle = FindPluginByFile(util_path);
					
					Function invalid = GetFunctionByName(INVALID_HANDLE, "");
					Function func = GetFunctionByName(UtilityInfo[i-skip].handle, "SF2P_UtilityUsed");
					if (func == invalid)
					{
						LogError("[SF2+] !!! Function \"SF2P_UtilityUsed\" not found in utility plugin %s. Skipping utility.", UtilityInfo[i-skip].Name);
						skip++;
					}
					else
					{
						Call_SF2P_UtilityRegistered(i-skip);
						Call_SF2P_OnUtilityRegistered(UtilityInfo[i-skip].Name);
						LogMessage("[SF2+] %s utility registered!", UtilityInfo[i-skip].Name); 
					}
				}
			}
			LogMessage("[SF2+]");
			iUtilityCount -= skip;
			LogMessage("[SF2+] Utility Count: %i", iUtilityCount);
			LogMessage("[SF2+]");
			kv.GoBack(); // ------------------------------------------------------------------------------------------------------------//
			
			kv.JumpToKey("Utility_Stats");
			iUtilityDefaultAmount = kv.GetNum("default_utility_amount", 69);
			LogMessage("[SF2+] default_utility_amount: %i", iUtilityDefaultAmount);
			LogMessage("[SF2+]");
			kv.GoBack();
			if (bUtilities)LoadUtilityStatsConfig();
			ViewmodelsConfig(Viewmodels_load, Viewmodels_download);
		}
		
		if (bEXP)LoadEXPConfig(kv);
		if (bChallenges)LoadChallenges(kv);
		
		delete kv;
	}
	
	//if (bChallenges)LoadChallengeDescription();
	LoadHudIconsConfig();
	PostConfig();
	
	LogMessage("[SF2+] Configs Executed.");
}

void ViewmodelsConfig(int load, int download)
{
	for (int i; i<MAXUTILITIES; i++)iUtilViewmodel_count[i] = 0;
	iUtilViewmodel_totalcount = 0;
	LogMessage("[SF2+] Viewmodels: %s", (load ? "Enabled" : "Disabled")); 
	LogMessage("[SF2+] Viewmodels Download: %s", (download ? "Enabled" : "Disabled")); 
	LogMessage("[SF2+]");
	if (load)
	{
		char config[PLATFORM_MAX_PATH];
		BuildPath(Path_SM, config, sizeof(config), VIEWMODEL_CONFIG_PATH);
		if (!FileExists(config))
		{
			LogMessage("configs/sf2plus/sf2plusviewmodels.cfg doesn't exist. Disabling viewmodels.");
			Viewmodels_load = false;
		}
		else
		{ // ------ Config Exists
			KeyValues kv = new KeyValues("SF2Plus Viewmodels");
			if (!kv.ImportFromFile(config))
			{
				LogMessage("[SF2+] Can't parse keyvalues.");
			}
			else
			{ // ------ Keyvalues parsed
				int log = kv.GetNum("log_onload", 0);
				if (kv.GotoFirstSubKey())
				{
					int idx=0;
					int Vm_idx;
					for (int i; i<iUtilityCount; i++) // ------ Go through each installed utility (health, etc.)
					{
						Vm_idx = 0;
						kv.JumpToKey(UtilityInfo[i].Name);
						char utility[UTILITYNAMESIZE];
						kv.GetSectionName(utility, sizeof(utility));
						if (log) { LogMessage("[SF2+] %i %s", i+1, utility); }
						if (kv.GotoFirstSubKey()) // ------ Custom Viewmodels (Default Health Booster, etc.)
						{
							do 
							{
								
								bool log2 = kv.GetNum("log") ? true : false; // Toggle logging this utility viewmodel
								
								// Utility name and hud name
								kv.GetSectionName(UtilViewmodel[i][Vm_idx].name, PLATFORM_MAX_PATH);
								if (log && log2) { LogMessage("[SF2+] %s: %i %s &&&&&&&&&&&&&&&&&&&&", utility, Vm_idx+1, UtilViewmodel[i][Vm_idx].name); }
								kv.GetString("hud_name", UtilViewmodel[i][Vm_idx].hudname, PLATFORM_MAX_PATH, UtilityInfo[i].HudName);
								
								UtilViewmodel[i][Vm_idx].idx = idx; // Viewmodel global index
								
								// Utility model path
								kv.GetString("model", UtilViewmodel[i][Vm_idx].model, PLATFORM_MAX_PATH);
								char ext[5][] = {".dx80.vtx", ".dx90.vtx", ".mdl", ".sw.vtx", ".vvd"};
								char buffer[PLATFORM_MAX_PATH];
								for (int k; k<sizeof(ext); k++)
								{
									FormatEx(buffer, sizeof(buffer), "%s%s", UtilViewmodel[i][Vm_idx].model, ext[k]);
									if (!FileExists(buffer)) { LogMessage("[SF2+] !!! Couldn't find %s !", buffer); }
									else { if (download) { AddFileToDownloadsTable(buffer); } }
								}
								FormatEx(UtilViewmodel[i][Vm_idx].model, PLATFORM_MAX_PATH, "%s.mdl", UtilViewmodel[i][Vm_idx].model);
								PrecacheModel(UtilViewmodel[i][Vm_idx].model);
								
								// Function values
								UtilViewmodel[i][Vm_idx].skin = kv.GetNum("skin");
								UtilViewmodel[i][Vm_idx].body = kv.GetNum("body");
								UtilViewmodel[i][Vm_idx].duration = kv.GetFloat("duration");
								UtilViewmodel[i][Vm_idx].delay = kv.GetFloat("delay");
								
								if (log && log2)
								{
									LogMessage("[SF2+] hud_name: %s", UtilViewmodel[i][Vm_idx].hudname);
									LogMessage("[SF2+] model: %s", (!StrEqual(UtilViewmodel[i][Vm_idx].model, "") ? UtilViewmodel[i][Vm_idx].model : "[SF2+] !!! Couldn't find 'model' key"));
									LogMessage("[SF2+] skin: %i", UtilViewmodel[i][Vm_idx].skin);
									LogMessage("[SF2+] body: %i", UtilViewmodel[i][Vm_idx].body);
									LogMessage("[SF2+] duration: %0.1f", UtilViewmodel[i][Vm_idx].duration);
									LogMessage("[SF2+] delay: %0.1f", UtilViewmodel[i][Vm_idx].delay);
									LogMessage("[SF2+]");
								}
								
								// Hide Main Viewmodel bools
								for (int k=1; k<10; k++)
								{
									FormatEx(buffer, sizeof(buffer), "hide_%s_main_viewmodel", szTF2Classes[k]);
									UtilViewmodel[i][Vm_idx].hideMainViewmodel[k] = kv.GetNum(buffer, 1) ? true : false;
									if (log && log2) { LogMessage("[SF2+] %s: %s", szTF2Classes[k], (UtilViewmodel[i][Vm_idx].hideMainViewmodel[k] ? "True" : "False")); }
								}
								if (log && log2) { LogMessage("[SF2+]"); }
								
								// Overlay Color
								
								kv.GetColor4("overlay_color", UtilViewmodel[i][Vm_idx].screenfadecolor);
								if (log && log2) 
								{ 
									char rgba[4][] = {"R", "G", "B", "A"};
									for (int j; j<4; j++)LogMessage("[SF2+] overlay_color %s: %i", rgba[j], UtilViewmodel[i][Vm_idx].screenfadecolor[j]);
									LogMessage("[SF2+]"); 
								}
								
								// Overlay values
								UtilViewmodel[i][Vm_idx].screendelay = kv.GetFloat("overlay_delay");
								UtilViewmodel[i][Vm_idx].screenfadein = kv.GetFloat("overlay_fadein_time");
								UtilViewmodel[i][Vm_idx].screenholdtime = kv.GetFloat("overlay_hold_time");
								UtilViewmodel[i][Vm_idx].screenfadeout = kv.GetFloat("overlay_fadeout_time");
								
								if (log && log2)
								{
									LogMessage("[SF2+] overlay_delay: %0.1f", UtilViewmodel[i][Vm_idx].screendelay)
									LogMessage("[SF2+] overlay_fadein_time: %0.1f", UtilViewmodel[i][Vm_idx].screenfadein);
									LogMessage("[SF2+] overlay_hold_time: %0.1f", UtilViewmodel[i][Vm_idx].screenholdtime);
									LogMessage("[SF2+] overlay_fadeout_time: %0.1f", UtilViewmodel[i][Vm_idx].screenfadeout);
									LogMessage("[SF2+]");
								}
								
								//Sounds
								char sound[PLATFORM_MAX_PATH];
								kv.GetString("sound", sound, sizeof(sound));
								if (kv.JumpToKey("sounds"))
								{
									char section[16];
									kv.GetSectionName(section, sizeof(section));
									if (log && log2) { LogMessage("[SF2+] ------------ %s", section); }
									
									for (int k=1; k<10; k++)
									{
										kv.GetString(szTF2Classes[k], UtilViewmdlSound[i][Vm_idx][k], PLATFORM_MAX_PATH, sound);
										FormatEx(buffer, sizeof(buffer), "sound/%s", UtilViewmdlSound[i][Vm_idx][k]);
										if (StrEqual(UtilViewmdlSound[i][Vm_idx][k], "")) { LogMessage("[SF2+] !!! Couldn't find key '%s' !", szTF2Classes[k]); }
										else if (!FileExists(buffer)) { LogMessage("[SF2+] !!! Couldn't find %s file!", buffer); }
										else
										{
											if (download) { AddFileToDownloadsTable(buffer); }
											PrecacheSound(UtilViewmdlSound[i][Vm_idx][k]);
											if (log && log2) { LogMessage("[SF2+] Precached %s sound: %s", szTF2Classes[k], UtilViewmdlSound[i][Vm_idx][k]); }
										}
									}
									
									kv.GoBack();
								} // ------ sounds
								
								if (kv.JumpToKey("textures")) // ------ textures
								{
									char section[16];
									kv.GetSectionName(section, sizeof(section));
									if (log && log2) { LogMessage("[SF2+] ------------ %s", section); }
									
									int keys = 1;
									if (kv.GotoFirstSubKey(false))
									{
										do 
										{
											kv.GetString(NULL_STRING, buffer, sizeof(buffer))
											if (StrEqual(buffer[strlen(buffer)-4], ".vtf") || StrEqual(buffer[strlen(buffer)-4], ".vmt"))
											{
												if (!FileExists(buffer)) { LogMessage("[SF2+] !!! Couldn't find %s", buffer); }
												else
												{
													if (download) { AddFileToDownloadsTable(buffer); }
													if (log && log2) { LogMessage("[SF2+] %i: %s", keys, buffer); }
												}
											}
											else
											{
												char textureext1[PLATFORM_MAX_PATH];
												char textureext2[PLATFORM_MAX_PATH];
												FormatEx(textureext1, sizeof(textureext1), "%s.vtf", buffer)
												FormatEx(textureext2, sizeof(textureext2), "%s.vmt", buffer)
												
												if (!FileExists(textureext1))
												{
													if (!FileExists(textureext2)) { LogMessage("[SF2+] !!! Couldn't find %s .vtf and .vmt!", buffer); }
													else { LogMessage("[SF2+] !!! Couldn't find %s!", textureext1); }
												}
												else
												{
													if (!FileExists(textureext2)) { LogMessage("[SF2+] !!! Couldn't find %s!", textureext2); }
													else
													{
														if (download) 
														{ 
															AddFileToDownloadsTable(textureext1); 
															AddFileToDownloadsTable(textureext2); 
														}
														if (log && log2) { LogMessage("[SF2+] %i: %s", keys, buffer); }
													}
												}
											}
											keys++
										} while (kv.GotoNextKey(false))
									}
									
									kv.GoBack();
								} // ------ textures
								if (log && log2) { LogMessage("[SF2+]"); }
								if (!StrEqual(UtilViewmodel[i][Vm_idx].name, "")) { iUtilViewmodel_count[i]++; }
								kv.GoBack();
								idx++;
								Vm_idx++;
							} while (kv.GotoNextKey())
							
							kv.GoBack();
						} // ------ Custom Viewmodels (Default Health Booster, etc.)
						if (log)
						{
							LogMessage("[SF2+] %s Viewmodel Count: %i", utility, iUtilViewmodel_count[i]);
							LogMessage("[SF2+]");
						}
						
						kv.GoBack();
					} // ------ Go through each installed utility
				}
				for (int i; i<sizeof(iUtilViewmodel_count); i++)
				{
					iUtilViewmodel_totalcount += iUtilViewmodel_count[i];
				}
				LogMessage("[SF2+] Total Viewmodel Count: %i%s", iUtilViewmodel_totalcount, (iUtilViewmodel_totalcount ? "" : ". Disabling viewmodels."));
				LogMessage("[SF2+]");
				if (iUtilViewmodel_totalcount < 1) { Viewmodels_load = false; }
				for (int i; i<iUtilityCount; i++)
				{
					for (int k; k<iUtilViewmodel_count[i]; k++)
					{
						LogMessage("[SF2+] %s: %s", UtilityInfo[i].Name, UtilViewmodel[i][k].name);
					}
					LogMessage("[SF2+]");
				}
			}// ------ Keyvalues parsed
			
			delete kv;
		} // ------ Config Exists
	}
}

void LoadEXPConfig(KeyValues kv)
{
	kv.JumpToKey("EXP");
	EXPInfo.PrestigeUp = kv.GetNum("PrestigeUp", 50);
	EXPInfo.LevelUp = kv.GetNum("LevelUp", 200);
	EXPInfo.PageCollect = kv.GetNum("page_collect", 1);
	EXPInfo.ClientEscape = kv.GetNum("client_escape", 2);
	EXPInfo.ChaseTakeover = kv.GetNum("chase_takeover", 3);
	EXPInfo.BossStun = kv.GetNum("boss_stun", 2);
	EXPInfo.UsedDroppedUtility = kv.GetNum("used_dropped_utility", 3);
	
	LogMessage("[SF2+] EXP Info:");
	LogMessage("[SF2+] PrestigeUp: %i", EXPInfo.PrestigeUp);
	LogMessage("[SF2+] LevelUp: %i", EXPInfo.LevelUp);
	LogMessage("[SF2+] PageCollect: %i", EXPInfo.PageCollect);
	LogMessage("[SF2+] ClientEscape: %i", EXPInfo.ClientEscape);
	LogMessage("[SF2+] ChaseTakeover: %i", EXPInfo.ChaseTakeover);
	LogMessage("[SF2+] BossStun: %i", EXPInfo.BossStun);
	LogMessage("[SF2+] UsedDroppedUtility: %i", EXPInfo.UsedDroppedUtility);
	LogMessage("[SF2+]");
	
	kv.JumpToKey("Level Unlocks");
	kv.JumpToKey("first_utility_slot_unlock");
	LevelUnlock.First_Utility = kv.GetNum("required", 0);
	kv.GoBack();
	
	kv.JumpToKey("second_utility_slot_unlock");
	LevelUnlock.Second_Utility = kv.GetNum("required", 15);
	kv.GoBack();
	
	kv.JumpToKey("third_utility_slot_unlock");
	LevelUnlock.Third_Utility = kv.GetNum("required", 30);
	kv.GoBack();
	
	kv.JumpToKey("third_sense_unlock");
	LevelUnlock.Third_Sense = kv.GetNum("required", 10);
	kv.GoBack();
	kv.GoBack();
	LogMessage("[SF2+] first_utility_slot_unlock: %i", LevelUnlock.First_Utility);
	LogMessage("[SF2+] second_utility_slot_unlock: %i", LevelUnlock.Second_Utility);
	LogMessage("[SF2+] third_utility_slot_unlock: %i", LevelUnlock.Third_Utility);
	LogMessage("[SF2+] third_sense_unlock: %i", LevelUnlock.Third_Sense);
	LogMessage("[SF2+]");
	
	kv.JumpToKey("Prestige Abilities");
	kv.JumpToKey("Lethal Survival");
	PrestigeInfo.LethalSurvival_Unlock = kv.GetNum("required", 1);
	PrestigeInfo.LethalSurvival_Length = kv.GetFloat("length", 4.0);
	kv.GetString("sound", PrestigeInfo.LethalSurvival_Sound, PLATFORM_MAX_PATH, "items/powerup_pickup_uber.wav");
	LogMessage("[SF2+] Lethal Survival Unlock: %i", PrestigeInfo.LethalSurvival_Unlock);
	LogMessage("[SF2+] Lethal Survival Length: %0.1f", PrestigeInfo.LethalSurvival_Length);
	char buffer[PLATFORM_MAX_PATH];
	FormatEx(buffer, sizeof(buffer), "sound/%s", PrestigeInfo.LethalSurvival_Sound);
	if (FileExists(buffer))LogMessage("[SF2+] Lethal Survival Sound: %s", PrestigeInfo.LethalSurvival_Sound), AddFileToDownloadsTable(buffer);
	else
	{
		if (FileExists(buffer, true))LogMessage("[SF2+] Lethal Survival Sound: %s", PrestigeInfo.LethalSurvival_Sound);
		else
		{
			LogMessage("[SF2+] !!! Can't find sound %s for Lethal Survival. Setting to default items/powerup_pickup_uber.wav", PrestigeInfo.LethalSurvival_Sound);
			PrestigeInfo.LethalSurvival_Sound = "items/powerup_pickup_uber.wav";
		}
	}
	PrecacheSound(PrestigeInfo.LethalSurvival_Sound);
	kv.GoBack();
	LogMessage("[SF2+]");
	
	kv.JumpToKey("Sixth Sense");
	PrestigeInfo.SixthSense_Unlock = kv.GetNum("required", 2);
	PrestigeInfo.SixthSense_ActivateValue = kv.GetFloat("activate_value", 3.0);
	PrestigeInfo.SixthSense_Length = kv.GetFloat("length", 8.0);
	PrestigeInfo.SixthSense_Cooldown = kv.GetFloat("cooldown", 20.0);
	kv.GetString("sound", PrestigeInfo.SixthSense_Sound, PLATFORM_MAX_PATH, "items/powerup_pickup_plague.wav");
	kv.GetString("sound_end", PrestigeInfo.SixthSense_SoundEnd, PLATFORM_MAX_PATH, "replay/performanceeditorclosed.wav");
	kv.GetString("sound_cooldown_end", PrestigeInfo.SixthSense_SoundCooldownEnd, PLATFORM_MAX_PATH, "replay/cameracontrolmodeentered.wav")
	LogMessage("[SF2+] Sixth Sense Unlock: %i", PrestigeInfo.SixthSense_Unlock);
	LogMessage("[SF2+] Sixth Sense ActivateValue: %0.1f", PrestigeInfo.SixthSense_ActivateValue);
	LogMessage("[SF2+] Sixth Sense Length: %0.1f", PrestigeInfo.SixthSense_Length);
	LogMessage("[SF2+] Sixth Sense Cooldown: %0.1f", PrestigeInfo.SixthSense_Cooldown);
	
	FormatEx(buffer, sizeof(buffer), "sound/%s", PrestigeInfo.SixthSense_Sound);
	if (FileExists(buffer))LogMessage("[SF2+] Sixth Sense Sound: %s", PrestigeInfo.SixthSense_Sound), AddFileToDownloadsTable(buffer);
	else
	{
		if (FileExists(buffer, true))LogMessage("[SF2+] Sixth Sense Sound: %s", PrestigeInfo.SixthSense_Sound);
		else
		{
			LogMessage("[SF2+] !!! Can't find sound %s for Sixth Sense. Setting to default items/powerup_pickup_plague.wav", PrestigeInfo.SixthSense_Sound);
			PrestigeInfo.SixthSense_Sound = "items/powerup_pickup_plague.wav";
		}
	}
	PrecacheSound(PrestigeInfo.SixthSense_Sound);
	
	FormatEx(buffer, sizeof(buffer), "sound/%s", PrestigeInfo.SixthSense_SoundEnd);
	if (FileExists(buffer))LogMessage("[SF2+] Sixth Sense End Sound: %s", PrestigeInfo.SixthSense_SoundEnd), AddFileToDownloadsTable(buffer);
	else
	{
		if (FileExists(buffer, true))LogMessage("[SF2+] Sixth Sense End Sound: %s", PrestigeInfo.SixthSense_SoundEnd);
		else
		{
			LogMessage("[SF2+] !!! Can't find sound %s for Sixth Sense. Setting to default replay/performanceeditorclosed.wav", PrestigeInfo.SixthSense_SoundEnd);
			PrestigeInfo.SixthSense_SoundEnd = "replay/performanceeditorclosed.wav";
		}
	}
	PrecacheSound(PrestigeInfo.SixthSense_SoundEnd);
	
	FormatEx(buffer, sizeof(buffer), "sound/%s", PrestigeInfo.SixthSense_SoundCooldownEnd);
	if (FileExists(buffer))LogMessage("[SF2+] Sixth Sense Cooldown End Sound: %s", PrestigeInfo.SixthSense_SoundCooldownEnd), AddFileToDownloadsTable(buffer);
	else
	{
		if (FileExists(buffer, true))LogMessage("[SF2+] Sixth Sense Cooldown End Sound: %s", PrestigeInfo.SixthSense_SoundCooldownEnd);
		else
		{
			LogMessage("[SF2+] !!! Can't find sound %s for Sixth Sense. Setting to default replay/cameracontrolmodeentered.wav", PrestigeInfo.SixthSense_SoundCooldownEnd);
			PrestigeInfo.SixthSense_SoundCooldownEnd = "replay/cameracontrolmodeentered.wav";
		}
	}
	PrecacheSound(PrestigeInfo.SixthSense_SoundCooldownEnd);
	
	LogMessage("[SF2+]");
	for (int i; i<3; i++)kv.GoBack();
}

void LoadChallenges(KeyValues kv)
{
	iChallengeCount = 0;
	kv.JumpToKey("Challenges");
	if (kv.GotoFirstSubKey(false))
	{
		do 
		{
			iChallengeCount++;
		} while (kv.GotoNextKey(false))
		kv.GoBack();
	}
	char key[3], challenge_path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, challenge_path, sizeof(challenge_path), CHALLENGE_CONFIG_PATH);
	if (!FileExists(challenge_path))LogMessage("Can't find %s! Disabling challenges.", challenge_path), bChallenges = false;
	else
	{
		for (int i; i<iChallengeCount; i++)
		{
			IntToString(i+1, key, 3);
			kv.GetString(key, ChallengeInfo[i].Name, sizeof(ChallengeInfo[].Name));
			BuildPath(Path_SM, challenge_path, sizeof(challenge_path), "plugins/sf2p/challenges/%s.smx", ChallengeInfo[i].Name); 
			if (FileExists(challenge_path))
			{
				FormatEx(challenge_path, sizeof(challenge_path), "sf2p\\challenges\\%s.smx", ChallengeInfo[i].Name);
				ChallengeInfo[i].handle = FindPluginByFile(challenge_path);
				
				Call_SF2P_ChallengeRegistered(i);
				Call_SF2P_OnChallengeRegistered(ChallengeInfo[i].Name);
				LogMessage("[SF2+] %s challenge registered!", ChallengeInfo[i].Name);
			}
			else { LogMessage("[SF2+] !!! Couldn't find %s challenge plugin!", ChallengeInfo[i].Name);  }
			
		}
		if (iChallengeCount == 0)bChallenges = false, LogMessage("[SF2+] No challenge plugins loaded, disabling challenges.");
	}
	
	LogMessage("[SF2+]");
}

void LoadUtilityStatsConfig()
{
	char config[PLATFORM_MAX_PATH];
	char amount_diff[17];
	for (int i; i<iUtilityCount; i++)
	{
		BuildPath(Path_SM, config, sizeof(config), "%s%s.cfg", UTILITY_CONFIG_PATH, UtilityInfo[i].Name);
		if (!FileExists(config))
		{
			LogMessage("[SF2+] !!! Can't find config file for %s. Setting %s amount to 2 for all difficulties.", UtilityInfo[i].Name, UtilityInfo[i].Name);
			for (int k; k<7; k++)
			{
				UtilityInfo[i].DifficultyAmount[k] = 2; 
			}
			
		}
		else
		{
			KeyValues kv = new KeyValues(UtilityInfo[i].Name);
			if (!kv.ImportFromFile(config))
			{
				LogMessage("[SF2+] Can't parse keyvalues. Setting %s amount to 2 for all difficulties.", UtilityInfo[i].Name);
				for (int k; k<7; k++)
				{
					UtilityInfo[i].DifficultyAmount[k] = 2;
				}
			}
			else
			{
				bool log = kv.GetNum("log_on_load", 0) ? true : false;
				//Hud Name
				kv.GetString("hud_name", UtilityInfo[i].HudName, sizeof(UtilityInfo[].HudName), UtilityInfo[i].Name);
				if (log)LogMessage("[SF2+] %s hud_name: %s", UtilityInfo[i].Name, UtilityInfo[i].HudName)
				// Difficulty Amount
				for (int k; k<Difficulty_Max; k++)
				{
					FormatEx(amount_diff, sizeof(amount_diff), "amount_%s", szSF2Difficulty[k]);
					UtilityInfo[i].DifficultyAmount[k] = kv.GetNum(amount_diff, 69);
					if (UtilityInfo[i].DifficultyAmount[k] == 69)LogMessage("[SF2+] !!! Can't find %s for %s. Setting amount to 2.", amount_diff, UtilityInfo[i].Name);
					if (log)LogMessage("[SF2+] %s %s: %i", UtilityInfo[i].Name, amount_diff, UtilityInfo[i].DifficultyAmount[k]);
				}
				
			}
			delete kv;
		}
	}
}

void LoadHudIconsConfig()
{
	char config[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, config, sizeof(config), CONFIG_PATH);
	if (!FileExists(config))
	{
		LogMessage("configs/sf2plus/sf2plus.cfg doesn't exist.");
	}
	else
	{
		KeyValues kv = new KeyValues("SF2Plus");
		if (!kv.ImportFromFile(config))
		{
			LogMessage("[SF2+] Can't parse keyvalues.");
		}
		kv.JumpToKey("Hud");
		
		char icons[][] = {"1_up_icon","chased_icon","heard_icon","healing_icon","speed_buffed_icon","stamina_drain_icon","stamina_rec_icon","stamina_rec2_icon","hp_icon","grace_icon","marked_icon","fire_icon","bleeding_icon","sixth_sense_icon","sixth_sense_cd_icon","sixth_sense_chg_icon","lethal_survival_icon"};
		for (int i; i<sizeof(icons); i++)
		{
			kv.GetString(icons[i], szHudIcons[i], 16, szHudIcons[i]);
			FormatEx(szHudIcons[i], 16, "%s ", szHudIcons[i]);
			//LogMessage("%s: %s.", icons[i], szHudIcons[i]);
		}
		//kv.GetString("1_up_icon", szHudIcons[0], 4, "☤");
	}
}

void PostConfig()
{
	// ------ Create utility colums in Database for viewmodels
	if (IsValidHandle(DB))
	{
		char query[PLATFORM_MAX_PATH];
		if (bUtilities)
		{
			for (int i; i<iUtilViewmodel_totalcount; i++)
			{
				FormatEx(query, sizeof(query), "ALTER TABLE util_vms ADD %s varchar(128)", UtilityInfo[i].Name);
				if (SQL_FastQuery(DB, query)) { LogMessage("[SF2+] SQL: Adding %s utility column", UtilityInfo[i].Name); }
			}
		}
		
		
		ArrayList array = new ArrayList(ByteCountToCells(64)); // Grabs from mapcycle.txt
		ReadMapList(array);
		int length = array.Length;
		char map[64];
		for (int i; i<length; i++)
		{
			array.GetString(i, map, sizeof(map));
			FormatEx(query, sizeof(query), "ALTER TABLE player_maps ADD %s INTEGER DEFAULT 0", map);
			if (SQL_FastQuery(DB, query)) { LogMessage("[SF2+] SQL: Adding %s map column to player_maps", map); }
		}
		delete array;
	}
	
	#if defined _SteamWorks_Included
	if (szGameDesc[0] != 0)
	{
		SteamWorks_SetGameDescription(szGameDesc);
	}
	#endif
	
	CreateMenus();
}


public void OnMapStart()
{
	PrecacheGlobal();
	for (int i; i<MAX_BOSSES; i++)
	{
		for (int j; j<MAXTF2PLAYERS; j++)
		{
			BossInfo[i].GlowEnt[j] = -1;
		}
	}
}

public void PrecacheGlobal()
{
	PrecacheModel(SF2PEMPTYMODEL);
}

public void OnClientCookiesCached(client)
{
	if (IsValidHandle(DB))
	{
		CheckClientSQL(client);
		if (bEXP)
		{
			ClientInfo[client].EXP = SQL_GetClientEXP(client);
			if (ClientInfo[client].EXP > 0)
			{
				ClientInfo[client].Level = ClientInfo[client].EXP / EXPInfo.LevelUp + 1;
			}
			ClientInfo[client].Prestige = SQL_GetClientPrestige(client);
		}
		if (bUtilities)SQL_FetchClientUtilities(client);
		if (bUtilities)SQL_FetchClientViewmodels(client);
		SQL_GetClientHUDCoord(client);
		ClientInfo[client].HudFlags = SQL_GetClientHUDFlags(client);
		ClientInfo[client].ChatFlags = SQL_GetClientChatFlags(client);
		SQL_GetClientMisc(client);
	}
	else
	{
		LogMessage("Couldn't get player prefs! Database not connected.");
		
		if (bUtilities)
		{
			for (int i; i<iUtilityCount; i++)
			{
				if (i<3)ClientInfo[client].Utility[i] = i;
				else { break; }
			}
		}
		
	}
	
	if (bUtilities)
	{
		int util_idx;
		int vm_idx;
		
		for (int i; i<3; i++)
		{
			if (SF2P_IsClientUtilitySlotUnlocked(client, i))
			{
				util_idx = ClientInfo[client].Utility[i];
				vm_idx = ClientInfo[client].Viewmodel[i];
				LogMessage("%N %s: %s %i", client, UtilityInfo[util_idx].Name, UtilViewmodel[util_idx][vm_idx].name, vm_idx); 
			}
		}
	}
	
	
	if (bUtilities)LogMessage("Utility: %i %i %i", ClientInfo[client].Utility[0], ClientInfo[client].Utility[1], ClientInfo[client].Utility[2]);
	if (bEXP)LogMessage("EXP: %i", ClientInfo[client].EXP);
	if (bEXP)LogMessage("Level: %i", ClientInfo[client].Level);
	if (bEXP)LogMessage("Prestige: %i", ClientInfo[client].Prestige);
	LogMessage("HudPos: %0.3f %0.3f", ClientInfo[client].HudPos[0], ClientInfo[client].HudPos[1]);
	LogMessage("Total Times Played: %i", ClientInfo[client].TotalRoundsPlayed);
	LogMessage("Total Maps Played: %i", ClientInfo[client].TotalMapsPlayed);
	LogMessage("Travel Distance: %0.1f meters", ClientInfo[client].TravelDist);
	
	SQL_SaveClientUtilities(client);
	
	ClientInfo[client].ViewmodelEnt = -1;
	ClientInfo[client].FirstRound = false;
}

//----------------------------------------------------------------------------------------
//	Database
//----------------------------------------------------------------------------------------

public void CheckClientSQL(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "INSERT INTO player (id, name, hudx, hudy) VALUES ('%s', '%N', '%0.3f', '%0.3f')", 
									ClientAuthID,
									client, 
									fHud_Pos_Default[0],
									fHud_Pos_Default[1]);
		
		if (SQL_FastQuery(DB, query)) // If player doesn't have prefs (the row above was successfully created)
		{
			LogMessage("Creating SQL prefs for %N", client);
			
			FormatEx(query, sizeof(query), "UPDATE player SET hudflags='%i', chatflags='%i' WHERE id='%s'", HUDFLAGS_DEFAULT, CHATFLAGS_ALL, ClientAuthID);
			SQL_FastQuery(DB, query);
			
			Format(query, sizeof(query), "INSERT INTO util_vms (id, name) VALUES ('%s', '%N')", ClientAuthID, client);
			SQL_FastQuery(DB, query);
			
			if (bUtilities)
			{
				for (int i; i<iUtilityCount; i++)
				{
					FormatEx(query, sizeof(query), "UPDATE util_vms SET %s='%s' WHERE id='%s'", UtilityInfo[i].Name, UtilViewmodel[i][0].name, ClientAuthID);
					SQL_FastQuery(DB, query);
				}
			}
			
		}
	}
	
}

public int SQL_GetClientEXP(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "SELECT exp FROM player WHERE id='%s'", ClientAuthID);
		Handle SQLquery = SQL_Query(DB, query);
		if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))
		{
			int exp = SQL_FetchInt(SQLquery, 0);
			CloseHandle(SQLquery);
			return exp;
		}
		CloseHandle(SQLquery);
	}
	
	return 0;
}

public void SQL_SaveClientEXP(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "UPDATE player SET exp='%i' WHERE id='%s'", ClientInfo[client].EXP, ClientAuthID);
		if (!SQL_FastQuery(DB, query))
		{
			SQL_GetError(DB, query, sizeof(query))
			LogMessage("[SF2+] Couldn't save %N's EXP points. Error: %s", client, query);
		}
		
	}
	
}

int SQL_GetClientPrestige(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "SELECT prestige FROM player WHERE id='%s'", ClientAuthID);
		Handle SQLquery = SQL_Query(DB, query);
		if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))
		{
			int prestige = SQL_FetchInt(SQLquery, 0);
			CloseHandle(SQLquery);
			return prestige;
		}
		CloseHandle(SQLquery);
	}
	return 0;
}

void SQL_SaveClientPrestige(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "UPDATE player SET prestige='%i' WHERE id='%s'", ClientInfo[client].Prestige, ClientAuthID);
		if (!SQL_FastQuery(DB, query))
		{
			SQL_GetError(DB, query, sizeof(query));
			LogMessage("[SF2+] Couldn't save %N's Prestige points. Error: %s", client, query);
		}
	}
}

public void SQL_FetchClientUtilities(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "SELECT Util1, Util2, Util3 FROM player WHERE id='%s'", ClientAuthID)
		Handle SQLquery = SQL_Query(DB, query);
		
		char util[UTILITYNAMESIZE];
		
		if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))
		{
			for (int i; i<3; i++)
			{
				ClientInfo[client].Utility[i] = -1; // Locked Utility Slot
			}
			for (int i; i < 3 && i < iUtilityCount; i++)
			{
				if (SF2P_IsClientUtilitySlotUnlocked(client, i))
				{
					SQL_FetchString(SQLquery, i, util, sizeof(util))
					if (StrEqual(util, ""))
					{
						for (int j; j<iUtilityCount; j++)
						{
							if (SF2P_IsClientUtilityEquipped(client, j) == -1)
							{
								ClientInfo[client].Utility[i] = j;
								break;
							}
						}
					}
					else
					{
						ClientInfo[client].Utility[i] = SF2P_GetUtilityIndex(util);
					}
				}
			}
		}
		else
		{
			SQL_GetError(DB, query, sizeof(query));
			LogMessage("Couldn't get player prefs! Error: %s", query);
			
			for (int i; i<iUtilityCount; i++)
			{
				if (i<3)ClientInfo[client].Utility[i] = i;
				else { break; }
			}
		}
		
		CloseHandle(SQLquery);
	}
}

void SQL_FetchClientViewmodels(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		char query[PLATFORM_MAX_PATH];
		Handle SQLquery;
		Format(query, sizeof(query), "INSERT INTO util_vms (id, name) VALUES ('%s', '%N')", ClientAuthID, client);
		if (SQL_FastQuery(DB, query))
		{
			for (int i; i<iUtilityCount; i++)
			{
				FormatEx(query, sizeof(query), "UPDATE util_vms SET %s='%s' WHERE id='%s'", UtilityInfo[i].Name, UtilViewmodel[i][0].name, ClientAuthID);
				SQL_FastQuery(DB, query);
			}
		}
		for (int i; i<3; i++)
		{
			if (SF2P_IsClientUtilitySlotUnlocked(client, i))
			{
				FormatEx(query, sizeof(query), "SELECT %s FROM util_vms WHERE id='%s'", UtilityInfo[ClientInfo[client].Utility[i]].Name, ClientAuthID); 
				SQLquery = SQL_Query(DB, query);
				
				if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))
				{
					SQL_FetchString(SQLquery, 0, query, sizeof(query));
					ClientInfo[client].Viewmodel[i] = SF2P_GetViewmodelIndexByName(ClientInfo[client].Utility[i], query);
					if (ClientInfo[client].Viewmodel[i] == -1)
					{
						LogMessage("!!! Couldn't find Utility Viewmodel %s! Setting to %s", query, UtilViewmodel[ClientInfo[client].Utility[i]][0].name);
						ClientInfo[client].Viewmodel[i] = 0;
						SQL_SaveClientUtilityViewmodel(client, i);
					}
					
				}
				else
				{
					SQL_GetError(DB, query, sizeof(query));
					LogMessage("!!! Couldn't get player viewmodel prefs! Error: %s", query);
					ClientInfo[client].Viewmodel[i] = 0;
				}
			}
		}
		CloseHandle(SQLquery)
	}
}

public void SQL_SaveClientUtilities(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		for (int i; i<3; i++)
		{
			if (SF2P_IsClientUtilitySlotUnlocked(client, i))FormatEx(query, sizeof(query), "UPDATE player SET Util%i='%s'WHERE id='%s'", i+1, UtilityInfo[ClientInfo[client].Utility[i]].Name, ClientAuthID);
			if (!SQL_FastQuery(DB, query))
			{
				SQL_GetError(DB, query, sizeof(query));
				LogMessage("Couldn't save %N's utility prefs. Error: %s", client, query);
			}
			
		}
	}
}

public void SQL_SaveClientUtilityViewmodel(int client, int util_slot)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		int util = ClientInfo[client].Utility[util_slot];
		int vm_idx = ClientInfo[client].Viewmodel[util_slot];
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "UPDATE util_vms SET %s='%s' WHERE id='%s'", UtilityInfo[util].Name, UtilViewmodel[util][vm_idx].name, ClientAuthID); 
		if (!SQL_FastQuery(DB, query))
		{
			SQL_GetError(DB, query, sizeof(query));
			LogMessage("Couldn't save %N's utility prefs. Error: %s", client, query);
		}
	}
}

void SQL_GetClientHUDCoord(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "SELECT hudx, hudy FROM player WHERE id='%s'", ClientAuthID);
		Handle SQLquery = SQL_Query(DB, query);
		
		if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))
		{
			for (int i; i < 2; i++)
			{
				SQL_FetchString(SQLquery, i, query, sizeof(query));
				ClientInfo[client].HudPos[i] = StringToFloat(query);
			}
		}
		else
		{
			char error[PLATFORM_MAX_PATH];
			SQL_GetError(SQLquery, error, sizeof(error));
			LogMessage("Couldn't get player hud prefs! %s", error);
			ClientInfo[client].HudPos[0] = -1.0;
			ClientInfo[client].HudPos[1] = -1.0;
		}
		CloseHandle(SQLquery);
	}
}

void SQL_SaveClientHudPos(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "UPDATE player SET hudx='%0.3f', hudy='%0.3f' WHERE id='%s'", ClientInfo[client].HudPos[0], ClientInfo[client].HudPos[1], ClientAuthID);
		if (!SQL_FastQuery(DB, query))
		{
			SQL_GetError(DB, query, sizeof(query));
			LogMessage("Couldn't save %N's hud pos prefs. Error: %s", client, query);
		}
	}
}

int SQL_GetClientHUDFlags(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "SELECT hudflags FROM player WHERE id='%s'", ClientAuthID);
		Handle SQLquery = SQL_Query(DB, query);
		if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))
		{
			int flags = SQL_FetchInt(SQLquery, 0);
			CloseHandle(SQLquery);
			return flags;
		}
		CloseHandle(SQLquery);
		
	}
	return 15;
}

void SQL_SaveClientHudFlags(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "UPDATE player SET hudflags='%i' WHERE id='%s'", ClientInfo[client].HudFlags, ClientAuthID);
		if (!SQL_FastQuery(DB, query))
		{
			SQL_GetError(DB, query, sizeof(query));
			LogMessage("Couldn't save %N's hud flags prefs. Error: %s", client, query);
		}
	}
}

int SQL_GetClientChatFlags(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "SELECT chatflags FROM player WHERE id='%s'", ClientAuthID);
		Handle SQLquery = SQL_Query(DB, query);
		if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))
		{
			int flags = SQL_FetchInt(SQLquery, 0);
			CloseHandle(SQLquery);
			return flags;
		}
		CloseHandle(SQLquery);
		
	}
	return CHATFLAGS_ALL;
}

void SQL_SaveClientChatFlags(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		Format(query, sizeof(query), "UPDATE player SET chatflags='%i' WHERE id='%s'", ClientInfo[client].ChatFlags, ClientAuthID);
		if (!SQL_FastQuery(DB, query))
		{
			SQL_GetError(DB, query, sizeof(query));
			LogMessage("Couldn't save %N's chat flags prefs. Error: %s", client, query);
		}
	}
}

void SQL_GetClientMisc(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		FormatEx(query, sizeof(query), "INSERT INTO player_misc(id, name) VALUES ('%s', '%N')", ClientAuthID, client);
		SQL_FastQuery(DB, query);
		
		FormatEx(query, sizeof(query), "INSERT INTO player_maps(id, name) VALUES ('%s', '%N')", ClientAuthID, client);
		SQL_FastQuery(DB, query);
		
		FormatEx(query, sizeof(query), "SELECT played, maps, traveldist, pages, escapes, chases, deaths, utiluses, cchallenges  FROM player_misc WHERE id='%s'", ClientAuthID);
		Handle SQLquery = SQL_Query(DB, query);
		if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))
		{
			ClientInfo[client].TotalRoundsPlayed = SQL_FetchInt(SQLquery, 0);
			ClientInfo[client].TotalMapsPlayed = SQL_FetchInt(SQLquery, 1);
			ClientInfo[client].TravelDist = SQL_FetchFloat(SQLquery, 2);
			ClientInfo[client].TotalPages = SQL_FetchInt(SQLquery, 3);
			ClientInfo[client].Escapes = SQL_FetchInt(SQLquery, 4);
			ClientInfo[client].ChaseCount = SQL_FetchInt(SQLquery, 5);
			ClientInfo[client].Deaths = SQL_FetchInt(SQLquery, 6);
			ClientInfo[client].TotalUtilityUses = SQL_FetchInt(SQLquery, 7);
			ClientInfo[client].CompletedChallengeCount = SQL_FetchInt(SQLquery, 8);
		}
		CloseHandle(SQLquery);
	}
	
}

void SQL_SaveClientMisc(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[512];
		FormatEx(query, sizeof(query), "INSERT INTO player_misc(id, name) VALUES ('%s', '%N')", ClientAuthID, client);
		SQL_FastQuery(DB, query);
		
		FormatEx(query, sizeof(query), "UPDATE player_misc SET played='%i', maps='%i', traveldist='%0.1f', pages='%i', escapes='%i', chases='%i', deaths='%i', utiluses='%i', cchallenges='%i' WHERE id='%s'",
									ClientInfo[client].TotalRoundsPlayed,
									ClientInfo[client].TotalMapsPlayed,
									ClientInfo[client].TravelDist,
									ClientInfo[client].TotalPages,
									ClientInfo[client].Escapes,
									ClientInfo[client].ChaseCount,
									ClientInfo[client].Deaths,
									ClientInfo[client].TotalUtilityUses,
									ClientInfo[client].CompletedChallengeCount,
									ClientAuthID);
		if (!SQL_FastQuery(DB, query))
		{
			SQL_GetError(DB, query, sizeof(query));
			LogMessage("Couldn't save %N's misc data. Error: %s", client, query);
		}
		
	}
	
}

void SQL_SaveClientTravelDist(int client)
{
	if (IsValidHandle(DB))
	{
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		char query[PLATFORM_MAX_PATH];
		FormatEx(query, sizeof(query), "UPDATE player_misc SET traveldist='%0.1f' WHERE id='%s'", ClientInfo[client].TravelDist, ClientAuthID);
		SQL_FastQuery(DB, query);
	}
	
}

void SQL_AddClientMapCount(int client)
{
	if (IsValidHandle(DB))
	{
		char map[64];
		GetCurrentMap(map, sizeof(map));
		//LogMessage("Current map: %s", map);
		char ClientAuthID[65];
		GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
		
		int count;
		char query[PLATFORM_MAX_PATH];
		FormatEx(query, sizeof(query), "SELECT %s FROM player_maps WHERE id='%s'", map, ClientAuthID);
		Handle SQLquery = SQL_Query(DB, query, sizeof(query));
		if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))count = SQL_FetchInt(SQLquery, 0) + 1;
		CloseHandle(SQLquery);
		FormatEx(query, sizeof(query), "UPDATE player_maps SET %s='%i' WHERE id='%s'", map, count, ClientAuthID);
		if (!SQL_FastQuery(DB, query))
		{
			SQL_GetError(DB, query, sizeof(query));
			LogMessage("Couldn't save %N's map played count! Error: %s", client, query);
		}
	}	
}

//----------------------------------------------------------------------------------------
//	OTHER FUNCTIONS
//----------------------------------------------------------------------------------------

public Action Cmd_SF2PTestSpawnBoss(int client, int args)
{
	float pos[3];
	float ang[3];
	float endpos[3];
	GetClientEyeAngles(client, ang);
	GetClientEyePosition(client, pos);
	Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, RayHitPlayer, client);
	if (TR_DidHit(trace))
	{
		int target = TR_GetEntityIndex(trace);
		LogMessage("%i", target);
		TR_GetEndPosition(endpos, trace);
		SF2_AddBoss("ATestBossStill");
		SF2_SpawnBoss(0, {4313.174316, -488.829864, -415.968750});
		TeleportEntity(SF2_BossIndexToEntIndex(0), {4313.174316, -488.829864, -415.968750}, {0.0, 10.0, 0.0}, _);
		TeleportEntity(client, {4418.513672, -518.634583, -404.968689}, {13.326265, 164.066101, 0.000000}, _);
		LogMessage("%f %f %f", endpos[0], endpos[1], endpos[2]);
	}
	CloseHandle(trace);
	return Plugin_Continue;
}

public Action Cmd_SF2PTestSpawnBoss2(int client, int args)
{
	float pos[3];
	float ang[3];
	float endpos[3];
	GetClientEyeAngles(client, ang);
	GetClientEyePosition(client, pos);
	Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, RayHitPlayer, client);
	if (TR_DidHit(trace))
	{
		int target = TR_GetEntityIndex(trace);
		LogMessage("%i", target);
		TR_GetEndPosition(endpos, trace);
		SF2_AddBoss("ATestBossStill");
		SF2_SpawnBoss(0, {3528.720947, 1607.03588, -71.968750});
		TeleportEntity(SF2_BossIndexToEntIndex(0), {3528.720947, 1607.03588, -71.968750}, {0.0, 20.0, 0.0}, _);
		TeleportEntity(client, {3611.03, 1731.81, -2.12}, {0.0, -128.68, 0.0}, _);
		LogMessage("%f %f %f", endpos[0], endpos[1], endpos[2]);
	}
	CloseHandle(trace);
	return Plugin_Continue;
}

int SF2P_GetViewmodelIndexByName(int utility, char[] vm_name)
{
	for (int i; i<iUtilViewmodel_count[utility]; i++)
	{
		if (StrEqual(vm_name, UtilViewmodel[utility][i].name))return i;
	}
	return -1;
}

void SF2P_InspectClientInfo(int client)
{
	float pos[3];
	float ang[3];
	GetClientEyeAngles(client, ang);
	GetClientEyePosition(client, pos);
	Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, RayHitPlayer, client);
	if (TR_DidHit(trace))
	{
		int target = TR_GetEntityIndex(trace);
		LogMessage("%i", target);
		if (target > 0 && target < 33)Menu_PlayerInfo(client, target);
		else
		{
			int boss = SF2_EntIndexToBossIndex(target);
			if (boss != -1)Menu_BossInfo(client, boss);
			LogMessage("%i", boss);
		}
	}
	CloseHandle(trace);
}

bool RayHitPlayer(int entity, int mask, any data)
{
	if (entity == data)return false;
	else { return true; }
}

public Action SF2P_InspectTimerHandle(Handle timer)
{
	if (GetClientCount() <= 0)
	{
		if (IsValidHandle(hInspectTimer))
		{
			LogMessage("[SF2+] Killing Inspect Timer.");
			KillTimer(hInspectTimer);
		}
	}
	else
	{
		for (int i = 1; i < MAXTF2PLAYERS; i++)
		{
			if (IsValidClient(i))if (GetEntPropFloat(i, Prop_Send, "m_flInspectTime", 0) > 0.0)SF2P_InspectClientInfo(i);
		}
	}
	return Plugin_Continue;
}

public Action SF2P_CalculateTravelDist(Handle timer)
{
	if (GetClientCount() <= 0)
	{
		if (IsValidHandle(hTravelDistTimer))
		{
			LogMessage("[SF2+] Killing Distance Timer.");
			KillTimer(hTravelDistTimer)
		}
	}
	else
	{
		for (int i = 1; i < MAXTF2PLAYERS; i++)
		{
			// Client Travel Distance
			if (IsValidClient(i))
			{
				if (TF2_GetClientTeam(i) == TFTeam_Red && SF2_GetRoundState() > SF2RoundState_Intro)
				{
					float vector[3];
					GetClientAbsOrigin(i, vector);
					float dist = GetVectorDistance(ClientInfo[i].PrevVector, vector) * 0.007473;
					//float sex = GetVectorDistance(ClientInfo[i].PrevVector, vector)
					ClientInfo[i].PrevVector = vector;
					ClientInfo[i].TravelDist += dist;
					if (IsValidHandle(DB))SQL_SaveClientTravelDist(i);
					//LogMessage("Dist: %0.3f, %0.3f", dist, sex);
				}
			}
		}
	}
	return Plugin_Continue;
}

// True If Client Is In-game, round_active also checks if round is after intro
public bool SF2PClientCheck(int client, bool show_text, bool round_active) // Check player's status.
{
	if (!IsValidClient(client))return false;
	if (SF2_IsClientEliminated(client))
	{
		if (show_text) { PrintToConsole(client, "[SF2+] You are not in-game."); }
		return false;
	}
	if (round_active)
	{
		if (SF2_GetRoundState() < SF2RoundState_Active)
		{
			if (show_text) { CPrintToChat(client, "%s Round hasn't begun yet.", SF2PPREFIX); }
			return false;
		}
	}
	
	return true;
}

void PerformNoClip(int client) // Credit to funcommands
{
	MoveType movetype = GetEntityMoveType(client);
	
	if (movetype != MOVETYPE_NOCLIP)
	{
		SetEntityMoveType(client, MOVETYPE_NOCLIP);
		CPrintToChat(client, "%s Enabled NoClip", SF2PPREFIX);
	}
	else
	{
		SetEntityMoveType(client, MOVETYPE_WALK);
		CPrintToChat(client, "%s Disabled NoClip", SF2PPREFIX);
	}
}

stock bool IsValidClient(int client) // Credit to sourcemod-misc
{
	return client >= 1 && client <= MaxClients && IsClientConnected(client) && IsClientInGame(client) && !IsClientSourceTV(client);
}

stock void CreateTempParticle(char[] particle, float origin[3], int entity = -1, float angles[3] = {0.0, 0.0, 0.0}, bool resetparticles = false) // Credit to sourcemod-misc
{
	int tblidx = FindStringTable("ParticleEffectNames");

	char tmp[256];
	int stridx = INVALID_STRING_INDEX;

	for (int i = 0; i < GetStringTableNumStrings(tblidx); i++)
	{
		ReadStringTable(tblidx, i, tmp, sizeof(tmp));
		if(StrEqual(tmp, particle, false))
		{
			stridx = i;
			break;
		}
	}

	TE_Start("TFParticleEffect");
	TE_WriteFloat("m_vecOrigin[0]", origin[0]);
	TE_WriteFloat("m_vecOrigin[1]", origin[1]);
	TE_WriteFloat("m_vecOrigin[2]", origin[2]);
	TE_WriteVector("m_vecAngles", angles);
	TE_WriteNum("m_iParticleSystemIndex", stridx);
	TE_WriteNum("entindex", entity);
	TE_WriteNum("m_iAttachType", 5);
	TE_WriteNum("m_bResetParticles", resetparticles);
	TE_SendToAll();
}


int SF2P_CreateBossGlow(int bossIndex)
{
	int bossEnt = SF2_BossIndexToEntIndex(bossIndex);
	char bossName[64];
	SF2_GetBossName(bossIndex, bossName, sizeof(bossName));
	
	int glowEnt = CreateEntityByName("tf_glow");
	
	char color[16]; // Set glow color
	FormatEx(color, sizeof(color), "%i ", SF2_GetBossProfileNum(bossName, "outline_color_r", 255));
	FormatEx(color, sizeof(color), "%s%i ", color, SF2_GetBossProfileNum(bossName, "outline_color_g", 255));
	FormatEx(color, sizeof(color), "%s%i ", color, SF2_GetBossProfileNum(bossName, "outline_color_b", 255));
	FormatEx(color, sizeof(color), "%s%i ", color, SF2_GetBossProfileNum(bossName, "outline_color_transparency", 255));
	DispatchKeyValue(glowEnt, "GlowColor", color);
	
	FormatEx(bossName, sizeof(bossName), "%c%i", bossName[0], glowEnt); // Set boss' name
	DispatchKeyValue(bossEnt, "targetname", bossName);
	LogMessage("boss targetname: %s", bossName);
	
	DispatchKeyValue(glowEnt, "target", bossName); // Set glow entity's target to boss
	DispatchSpawn(glowEnt);
	DispatchKeyValue(bossEnt, "targetname", ""); // Clear boss' name
	
	SDKHook(glowEnt, SDKHook_SetTransmit, Hook_SlenderGlowTransmit);
	
	return glowEnt;
}

/*
int TF2_CreateGlow(int entIndex)
{
	char oldEntName[64];
	GetEntPropString(entIndex, Prop_Data, "m_iName", oldEntName, sizeof(oldEntName));

	char strName[126], strClass[64];
	GetEntityClassname(entIndex, strClass, sizeof(strClass));
	FormatEx(strName, sizeof(strName), "%s%i", strClass, entIndex);
	DispatchKeyValue(entIndex, "targetname", strName);

	int ent = CreateEntityByName("tf_glow");
	DispatchKeyValue(ent, "target", strName);
	FormatEx(strName, sizeof(strName), "tf_glow_%i", entIndex);
	DispatchKeyValue(ent, "targetname", strName);
	DispatchKeyValue(ent, "Mode", "0");
	DispatchSpawn(ent);

	AcceptEntityInput(ent, "Enable");

	//Change name back to old name because we don't need it anymore.
	SetEntPropString(entIndex, Prop_Data, "m_iName", oldEntName);

	return ent;
}
*/

//----------------------------------------------------------------------------------------
//	SF2P EXP
//----------------------------------------------------------------------------------------

void ClientEXPHandler(int client)
{
	if (ClientInfo[client].EXP == 1)ClientInfo[client].Level++;
	if (ClientInfo[client].EXP % EXPInfo.LevelUp == 0)
	{
		ClientInfo[client].Level++;
		CPrintToChatAll("%s %N is now level {green}%i{default}!", SF2PPREFIX, client, ClientInfo[client].Level);
		Call_SF2P_OnClientLevelUp(client, ClientInfo[client].Level);
		if (ClientInfo[client].Level == LevelUnlock.Third_Sense)CPrintToChat(client, "%s You unlocked the {green}Third Sense{default} ability!", SF2PPREFIX);
		if (bUtilities)
		{
			if (ClientInfo[client].Level == LevelUnlock.First_Utility && iUtilityCount > 0)
			{
				CPrintToChat(client, "%s You unlocked your {green}First Utility Slot{default}!", SF2PPREFIX);
				for (int i; i<iUtilityCount; i++)
				{
					if (SF2PChangeClientUtilities(client, 1, UtilityInfo[i].Name, false))break;
				}
				
			}
			
			if (ClientInfo[client].Level == LevelUnlock.Second_Utility && iUtilityCount > 1)
			{
				CPrintToChat(client, "%s You unlocked a {green}Second Utility Slot{default}!", SF2PPREFIX);
				for (int i; i<iUtilityCount; i++)
				{
					if (SF2PChangeClientUtilities(client, 2, UtilityInfo[i].Name, false))break;
				}
			}
			
			if (ClientInfo[client].Level == LevelUnlock.Third_Utility && iUtilityCount > 2)
			{
				CPrintToChat(client, "%s You unlocked a {green}Third Utility Slot{default}!", SF2PPREFIX);
				for (int i; i<iUtilityCount; i++)
				{
					if (SF2PChangeClientUtilities(client, 3, UtilityInfo[i].Name, false))break;
				}
			}
			SQL_SaveClientUtilities(client);
		}
		
		
	}
	if (ClientInfo[client].Level % EXPInfo.PrestigeUp == 0)
	{
		CPrintToChat(client, "%s You can {green}Prestige{default}!", SF2PPREFIX, ClientInfo[client].Level);
	}
	
}

bool PrestigeClient(int client)
{
	if (ClientInfo[client].Level >= EXPInfo.PrestigeUp)
	{
		if (SF2PClientCheck(client, false, false))
		{
			CPrintToChat(client, "%s Can't prestige while in-game!", SF2PPREFIX);
			return false;
		}
		ClientInfo[client].Prestige++;
		ClientInfo[client].EXP = 0;
		ClientInfo[client].Level = 0;
		SQL_SaveClientPrestige(client);
		SQL_SaveClientEXP(client);
		CPrintToChatAll("%s {yellow}%N is now prestige {green}%i{yellow}!", SF2PPREFIX, client, ClientInfo[client].Prestige);
		float pos[3];
		GetClientAbsOrigin(client, pos);
		pos[2] += 80;
		CreateTempParticle("achieved", pos);
		EmitSoundToAll(EXPInfo.PrestigeUp_Sound, client, SNDCHAN_AUTO, SNDLEVEL_SCREAMING);
		return true;
	}
	else { return false; }
}

void SF2P_RollClientChallenge(int client)
{
	ClientInfo[client].Challenge = GetRandomInt(1, iChallengeCount) - 1;
	ClientInfo[client].ChallengeState = CHALLENGE_ACTIVE;
	Call_SF2P_ChallengeSelected(client);
	Call_SF2P_OnChallengeSelected(client, ChallengeInfo[ClientInfo[client].Challenge].Name); 
	LogMessage("Rolled %s challenge for %N", ChallengeInfo[ClientInfo[client].Challenge].Name, client);
}

//----------------------------------------------------------------------------------------
//	SF2P Passive Abilities
//----------------------------------------------------------------------------------------

Action SF2P_SixthSenseTimer(Handle timer)
{
	bool active;
	for (int i; i<MAXTF2PLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			LogMessage("%N %f", i, ClientInfo[i].SixthSenseTime);
			if (SF2_IsClientBlinking(i) && !ClientInfo[i].SixthSense && ClientInfo[i].Prestige >= PrestigeInfo.SixthSense_Unlock && !ClientInfo[i].SixthSenseCooldown)
			{
				ClientInfo[i].SixthSenseTime += 0.1;
				if (ClientInfo[i].SixthSenseTime >= PrestigeInfo.SixthSense_ActivateValue)
				{
					ClientInfo[i].SixthSense = true;
					for (int j; j<iActiveBosses; j++)
					{
						if (SF2_BossIndexToEntIndex(j) != -1)
						{
							BossInfo[j].GlowEnt[i] = SF2P_CreateBossGlow(j);
							char buffer[32];
							SF2_GetBossName(j, buffer, sizeof(buffer));
							LogMessage("Creating %s Glow Ent For %N, GlowEnt = %i", buffer, i, BossInfo[j].GlowEnt[i]);
						}
					}
					CreateTimer(PrestigeInfo.SixthSense_Length, SixthSenseTimerHandler, i);
					EmitSoundToClient(i, PrestigeInfo.SixthSense_Sound, i, _, SNDLEVEL_SCREAMING);
				}
				
				active = true;
			}
		}
	}
	if (!active)if (IsValidHandle(hSixthSenseTimer))KillTimer(hSixthSenseTimer);
	return Plugin_Continue;
}

Action SixthSenseTimerHandler(Handle timer, int client)
{
	LogMessage("%N SixthSenseTimerHandler", client);
	for (int i; i<iActiveBosses; i++)
	{
		if (IsValidEntity(BossInfo[i].GlowEnt[client]))
		{
			RemoveEntity(BossInfo[i].GlowEnt[client]);
			LogMessage("Removing %i GlowEnt For %N, Sixth Sense Ended", BossInfo[i].GlowEnt[client], client);
			BossInfo[i].GlowEnt[client] = -1;
		}
	}
	EmitSoundToClient(client, PrestigeInfo.SixthSense_SoundEnd, client, _, SNDLEVEL_SCREAMING);
	ClientInfo[client].SixthSenseTime = 0.0;
	ClientInfo[client].SixthSense = false;
	ClientInfo[client].SixthSenseCooldown = true;
	CreateTimer(PrestigeInfo.SixthSense_Cooldown, SixthSenseCooldownHandler, client, 0);
	return Plugin_Continue;
}

Action SixthSenseCooldownHandler(Handle timer, int client)
{
	LogMessage("%N SixthSenseCooldownHandler", client);
	EmitSoundToClient(client, PrestigeInfo.SixthSense_SoundCooldownEnd, client, _, SNDLEVEL_SCREAMING);
	ClientInfo[client].SixthSenseCooldown = false;
	return Plugin_Continue;
}

public Action Hook_SlenderGlowTransmit(int entity, int client)
{
	if (GetEdictFlags(entity) & FL_EDICT_ALWAYS)SetEdictFlags(entity, GetEdictFlags(entity) &~ FL_EDICT_ALWAYS);// Remove always transmit flag so other players can't see boss outline
	if (ClientInfo[client].SixthSenseTime >= PrestigeInfo.SixthSense_ActivateValue)
	{
		//LogMessage("transmit to %N", client);
		return Plugin_Continue;
	}
	//LogMessage("%i", GetEdictFlags(entity));
	return Plugin_Handled;
}


//----------------------------------------------------------------------------------------
//	SF2P Utilities
//----------------------------------------------------------------------------------------

public Action Cmd_SF2PUtil1Use(int client, int args) // ------ First utility use
{
	SF2P_ClientUtilityHandler(client, 0);
	return Plugin_Continue;
}

public Action Cmd_SF2PUtil2Use(int client, int args) // ------ Second utility use
{
	SF2P_ClientUtilityHandler(client, 1);
	return Plugin_Continue;
}

public Action Cmd_SF2PUtil3Use(int client, int args) // ------ Third utility use
{
	SF2P_ClientUtilityHandler(client, 2);
	return Plugin_Continue;
}

Action SF2P_ClientUtilityHandler(int client, int utility_slot)
{
	if (!bUtilities) // Are Utilities Enabled?
	{
		if (SF2PClientCheck(client, false, false))CPrintToChat(client, "%s Utilities are disabled.", SF2PPREFIX);
		return Plugin_Handled;
	}
	if (ClientInfo[client].Level < LevelUnlock.First_Utility)return Plugin_Handled;
	
	int util_idx = ClientInfo[client].Utility[utility_slot];
	int vm_idx = ClientInfo[client].Viewmodel[utility_slot];
	if (!SF2PClientCheck(client, true, true) || util_idx == -1) // Is Player NOT In-Game AND Is Utility Invalid? 
	{
		return Plugin_Handled;
	}
	if (ClientInfo[client].UtilityUses[utility_slot] < 1) // Does Client Have Any Utility Uses?
	{
		CPrintToChat(client, "%s You've got no more {green}%s{default} left!", SF2PPREFIX, UtilViewmodel[util_idx][vm_idx].hudname);
		return Plugin_Handled;
	}
	if (Call_SF2P_UtilityRequirements(client, util_idx)) // Does Client Meet Utility Use Requirements?
	{
		float time;
		if (Viewmodels_load)
		{
			SF2P_ActivateClientUtilityViewmodel(client, utility_slot);
			time = UtilViewmodel[util_idx][vm_idx].delay;
		}
		Handle pack = CreateDataPack();
		WritePackCell(pack, client);
		WritePackCell(pack, utility_slot);
		CreateTimer(time, SF2P_ClientUtilityTimerHandler, pack, 0);
	}
	SF2PClientHudRefresh(client);
	return Plugin_Continue;
}

Action SF2P_ClientUtilityTimerHandler(Handle timer, any data)
{
	ResetPack(data);
	int client = ReadPackCell(data);
	int utility_slot = ReadPackCell(data);
	int util_idx = ClientInfo[client].Utility[utility_slot];
	CloseHandle(data);
	
	Call_SF2P_OnUtilityUsed(client, UtilityInfo[util_idx].Name, utility_slot); 
	Call_SF2P_UtilityUsed(client, util_idx);
	ClientInfo[client].UtilityUses[utility_slot]--;
	ClientInfo[client].TotalUtilityUses++;
	SQL_SaveClientMisc(client);
	return Plugin_Continue;
}

public int SF2PGetUtilityIndex(char[] utility)
{
	int util_count = sizeof(UtilityInfo[].Name);
	for (int i; i < util_count; i++)
	{
		if (StrEqual(utility, UtilityInfo[i].Name))
		{
			return i;
		}
	}
	return -1;
}

// client - Client's Utils To Change, util_slot - Slot To Change Utility In (1, 2, 3), utility - New Utility
public bool SF2PChangeClientUtilities(int client, int util_slot, char utility[UTILITYNAMESIZE], bool replace)
{
	util_slot -= 1;
	int new_util_idx = SF2P_GetUtilityIndex(utility);
	
	int equipped_slot = SF2P_IsClientUtilityEquipped(client, new_util_idx);
	if (equipped_slot == -1) // Set new utility
	{
		if (IsValidClient(client))CPrintToChat(client, "%s Equipped {green}%s{default} in slot %i.", SF2PPREFIX, utility, util_slot+1);
		ClientInfo[client].Utility[util_slot] = new_util_idx;
		SQL_SaveClientUtilities(client);
		SQL_FetchClientViewmodels(client);
		SF2PClientHudRefresh(client);
		return true;
	}
	if (equipped_slot != util_slot && replace) // Switch Utility
	{
		int util_uses = ClientInfo[client].UtilityUses[equipped_slot];
		if (IsValidClient(client))CPrintToChat(client, "%s Switching slot with {green}%s{default}.", SF2PPREFIX, UtilityInfo[ClientInfo[client].Utility[equipped_slot]].Name);
		
		ClientInfo[client].Utility[equipped_slot] = ClientInfo[client].Utility[util_slot];
		ClientInfo[client].Utility[util_slot] = new_util_idx;
		
		ClientInfo[client].UtilityUses[equipped_slot] = ClientInfo[client].UtilityUses[util_slot];
		ClientInfo[client].UtilityUses[util_slot] = util_uses;
		
		SQL_SaveClientUtilities(client);
		SQL_FetchClientViewmodels(client);
		SF2PClientHudRefresh(client);
		return true;
	}
	else // Utility already equipped and can't switch
	{
		if (IsValidClient(client))CPrintToChat(client, "%s {green}%s{default} already equipped.", SF2PPREFIX, utility);
		return false;
	}
}

void SF2P_SetClientUtilityAmountByDifficulty(int client)
{
	int difficulty = SF2_GetCurrentDifficulty();
	for (int i; i<3; i++)
	{
		if (SF2P_IsClientUtilitySlotUnlocked(client, i))SF2P_SetUtilityCharges(client, i, UtilityInfo[ClientInfo[client].Utility[i]].DifficultyAmount[difficulty]);
	}
}

//----------------------------------------------------------------------------------------
//	SF2P HUD
//----------------------------------------------------------------------------------------

public void SF2PClientHudRefresh(int client)
{
	if (SF2PClientCheck(client, false, false) && ClientInfo[client].HudFlags & HUDFLAGS_ENABLEHUD || ClientInfo[client].SettingHud)
	{
		if (!IsValidHandle(hSF2PHudTimer))
		{
			LogMessage("[SF2+] Creating timer. SF2PClientHudRefresh");
			hSF2PHudTimer = CreateTimer(fSF2PHudRefreshTimer, SF2PAllClientHudRefresh, 0, TIMER_REPEAT);
		}
		
		int maxhealth = GetEntProp(GetPlayerResourceEntity(), Prop_Send, "m_iMaxHealth", _, client);
		
		// HUD Color Synced With SF2 Hud Color
		int health = GetEntProp(client, Prop_Send, "m_iHealth");
		float healthRatio = float(health) / float(maxhealth); // TODO: Change hud color depending on sf2 legacy hud prefs
		int hudColorHealthy[3] = { 150, 255, 150 };
		int hudColorCritical[3] = { 255, 10, 10 };
		
		int color[3];
		for (int i; i<3; i++)color[i] = RoundFloat(float(hudColorHealthy[i]) + (float(hudColorCritical[i] - hudColorHealthy[i]) * (1.0 - healthRatio)));
		
		float hudcoord[2];
		
		//Hud Pos Prefs
		for (int i; i<2; i++)
		{
			if (ClientInfo[client].HudPos[i] == -1.0)
			{
				if (i == 0)ClientInfo[client].HudPos[i] = fHud_Pos_Default[0];
				if (i == 1)ClientInfo[client].HudPos[i] = fHud_Pos_Default[1];
			}
			else { hudcoord[i] = ClientInfo[client].HudPos[i]; }
		}
		
		//Boss State Bools
		ClientInfo[client].Chased = false;
		ClientInfo[client].Heard = false;
		for (int i; i<iActiveBosses; i++)
		{
			if (IsValidEntity(SF2_BossIndexToEntIndex(i)))
			{
				if (BossInfo[i].Target == client && SF2_GetBossState(i) > STATE_ALERT)ClientInfo[client].Chased = true;
				if (BossInfo[i].Target == client && SF2_GetBossState(i) == STATE_ALERT)ClientInfo[client].Heard = true;
				LogMessage("%i", SF2_GetBossState(i));
			}
		}
		
		char hud[3][PLATFORM_MAX_PATH];
		// Utility Viewmodel Hud Names
		if (bUtilities)
		{
			int util_idx;
			int vm_idx;
			
			for (int i; i<3; i++)
			{
				if (SF2P_IsClientUtilitySlotUnlocked(client, i))
				{
					util_idx = ClientInfo[client].Utility[i];
					vm_idx = ClientInfo[client].Viewmodel[i];
					hud[i] = UtilViewmodel[util_idx][vm_idx].hudname; 
				}
			}
		}
		
		//Hud Rows
		char row[PLATFORM_MAX_PATH];
		
		if (ClientInfo[client].HudFlags & HUDFLAGS_HPICON) // HP Row
		{
			iClientPrevHealth[client] = health;
			FormatEx(row, sizeof(row), "%s♥: %i/%i ", row, GetClientHealth(client), maxhealth);
		}
		else { FormatEx(row, sizeof(row), "%s ", row); }
		
		if (ClientInfo[client].HudFlags & HUDFLAGS_STATUSICONS) // Status Icons Row IN HP ROW
		{
			int team = _:TF2_GetClientTeam(client);
			FormatEx(row, sizeof(row), "%s%s", row, (ClientInfo[client].SettingHud ? "STATUS ICONS " : "")); // Customizing HUD
			FormatEx(row, sizeof(row), "%s%s", row, (ClientInfo[client].SecondLife || team == 3 ? szHudIcons[0] : "")); // 1 UP
			
			if (ClientInfo[client].Prestige >= PrestigeInfo.LethalSurvival_Unlock)
			{
				FormatEx(row, sizeof(row), "%s%s", row, (ClientInfo[client].LethalSurvival ? szHudIcons[16] : "")); // Lethal Survival
			}
			
			if (ClientInfo[client].Prestige >= PrestigeInfo.SixthSense_Unlock)
			{
				if (ClientInfo[client].SixthSense)FormatEx(row, sizeof(row), "%s%s", row, szHudIcons[13]);// Sixth Sense
				else if (ClientInfo[client].SixthSenseTime > 0.0 && SF2_IsClientBlinking(client) && !ClientInfo[client].SixthSenseCooldown)FormatEx(row, sizeof(row), "%s%s", row, szHudIcons[15]);// Sixth Sense Charge Added space cuz hella messed up spacing
				if (ClientInfo[client].SixthSenseCooldown)FormatEx(row, sizeof(row), "%s%s", row, szHudIcons[14]);// Sixth Sense Cooldown
			}
			
			FormatEx(row, sizeof(row), "%s%s", row, (ClientInfo[client].Chased && ClientInfo[client].Level >= LevelUnlock.Third_Sense || team == 3 ? szHudIcons[1] : "")); // Chased By Boss
			FormatEx(row, sizeof(row), "%s%s", row, (ClientInfo[client].Heard && ClientInfo[client].Level >= LevelUnlock.Third_Sense || team == 3 ? szHudIcons[2] : "")); // Heard By Boss
			FormatEx(row, sizeof(row), "%s%s", row, (health > iClientPrevHealth[client] || team == 3 ? szHudIcons[3] : "")); // Healing
			FormatEx(row, sizeof(row), "%s%s", row, (TF2_IsPlayerInCondition(client, TFCond_SpeedBuffAlly) || team == 3 ? szHudIcons[4] : "")); // Speed Buffed
			if (SF2_GetClientSprintPoints(client) < 100) // Sprinting
			{
				if (SF2_IsClientReallySprinting(client))FormatEx(row, sizeof(row), "%s%s", row, szHudIcons[5]);
				else if (GetEntProp(client, Prop_Send, "m_bDucked"))
				{
					FormatEx(row, sizeof(row), "%s%s", row, szHudIcons[7]);
				}
				else { FormatEx(row, sizeof(row), "%s%s", row, szHudIcons[6]); }
			}
			FormatEx(row, sizeof(row), "%s%s", row, (SF2_IsRoundInGracePeriod() || team == 3 ? szHudIcons[9] : "")); // Grace Period 
			FormatEx(row, sizeof(row), "%s%s", row, (TF2_IsPlayerInCondition(client, TFCond_MarkedForDeath) || team == 3 ? szHudIcons[10] : "")); // Marked For Death
			FormatEx(row, sizeof(row), "%s%s", row, (TF2_IsPlayerInCondition(client, TFCond_OnFire) || team == 3 ? szHudIcons[11] : "")); // On Fire
			FormatEx(row, sizeof(row), "%s%s", row, (TF2_IsPlayerInCondition(client, TFCond_Bleeding) || team == 3 ? szHudIcons[12] : "")); // Bleeding
			FormatEx(row, sizeof(row) ,"%s\n", row);
		}
		else { FormatEx(row, sizeof(row) ,"%s\n", row); }
		
		if (SF2PClientCheck(client, false, true) || ClientInfo[client].SettingHud) // Utilities Row
		{
			for (int i; i<3; i++)
			{
				if (SF2P_IsClientUtilitySlotUnlocked(client, i) && bUtilities && ClientInfo[client].Utility[i] != -1)FormatEx(row, sizeof(row), "%s%s: %i\n", row, hud[i], ClientInfo[client].UtilityUses[i]);
			}
		}
		
		if (ClientInfo[client].HudFlags & HUDFLAGS_CHALLENGES && bChallenges) // Challenge Row
		{
			if (ClientInfo[client].SettingHud)FormatEx(row, sizeof(row), "%sCHALLENGE ", row);
			if (SF2_IsSpecialRoundRunning() && TF2_GetClientTeam(client) == TFTeam_Red)
			{
				if (SF2_GetRoundState() < SF2RoundState_Active)FormatEx(row, sizeof(row), "%sSpecial Challenge Inbound...", row);
				else
				{
					if (ClientInfo[client].ChallengeState == CHALLENGE_ACTIVE)FormatEx(row, sizeof(row), "%sChallenge: %s", row, ClientInfo[client].ChallengeDescription);
					if (ClientInfo[client].ChallengeState == CHALLENGE_FAILED)FormatEx(row, sizeof(row), "%sChallenge: FAILED", row);
					if (ClientInfo[client].ChallengeState == CHALLENGE_COMPLETED)FormatEx(row, sizeof(row), "%sChallenge: COMPLETED", row);
					//LogMessage("%s %i", ClientInfo[client].ChallengeDescription, ClientInfo[client].ChallengeState);
				}
			}
			else { FormatEx(row, sizeof(row), "%s", row); }
		}
		else { FormatEx(row, sizeof(row), "%s", row); }
		
		SetHudTextParams(hudcoord[0], hudcoord[1], fSF2PHudRefreshTimer*2, color[0], color[1], color[2], 40, _, 1.0, 0.3, 1.0); //0.755 0.83
		ShowSyncHudText(client, hSF2PSyncHud1, row);
	}
	//LogMessage("[SF2+] %N %i %i", client, iClientHudFlags[client], bClientSettingHud[client]);
}

public Action SF2PAllClientHudRefresh(Handle timer)
{
	if (GetClientCount() <= 0)
	{
		if (IsValidHandle(hSF2PHudTimer))
		{
			LogMessage("[SF2+] Killing Hud Refresh Timer.");
			KillTimer(hSF2PHudTimer)
		}
		return Plugin_Handled;
	}
	else
	{
		for (int i = 1; i < MAXTF2PLAYERS; i++)
		{
			if (IsValidClient(i))
			{
				SF2PClientHudRefresh(i);
			}
			
		}
	}
	return Plugin_Continue;
}

void SF2P_SetClientSettingHud(int client, bool setting)
{
	ClientInfo[client].SettingHud = setting;
}

//----------------------------------------------------------------------------------------
//	SF2 Events
//----------------------------------------------------------------------------------------

public void SF2_OnRoundStateChange(SF2RoundState oldState, SF2RoundState newState)
{
	if (newState == SF2RoundState_Grace)
	{
		if (!IsValidHandle(hTravelDistTimer))
		{
			LogMessage("[SF2+] Creating dist timer. SF2_OnRoundStateChange");
			hTravelDistTimer = CreateTimer(1.0, SF2P_CalculateTravelDist, 0, TIMER_REPEAT);
		}
		for (int i = 1; i < MAXTF2PLAYERS; i++)
		{
			if (bChallenges && IsValidClient(i))ClientInfo[i].ChallengeState = CHALLENGE_INACTIVE;
		}
		iActiveBosses = 0;
	}
	if (newState == SF2RoundState_Active)
	{
		int difficulty = SF2_GetCurrentDifficulty();
		CPrintToChatAll("%s Round has begun. Difficulty: %i", SF2PPREFIX, szSF2Difficulty[difficulty]);
		
		if (!IsValidHandle(hSF2PHudTimer))
		{
			LogMessage("[SF2+] Creating hud timer. SF2_OnRoundStateChange");
			hSF2PHudTimer = CreateTimer(fSF2PHudRefreshTimer, SF2PAllClientHudRefresh, 0, TIMER_REPEAT);
		}
		
		for (int i = 1; i < MAXTF2PLAYERS; i++)
		{
			if (IsValidClient(i))
			{
				if (bUtilities)SF2P_SetClientUtilityAmountByDifficulty(i);
				SF2PClientHudRefresh(i);
				if (SF2_IsSpecialRoundRunning())
				{
					if (SF2_GetSpecialRoundType() == 16)ClientInfo[i].SecondLife = true;
					if (bChallenges)SF2P_RollClientChallenge(i);
				}
			}
		}
	}
	if (newState == SF2RoundState_Outro)
	{
		if (IsValidHandle(hSF2PHudTimer))KillTimer(hSF2PHudTimer);
		if (IsValidHandle(hSF2PHudTimer))KillTimer(hTravelDistTimer);
		for (int i = 1; i < MAXTF2PLAYERS; i++)
		{
			if (IsValidClient(i))
			{
				ClientInfo[i].SecondLife = false;
			}
		}
	}
}

//Client Functions
public Action SF2_OnClientEnterGame(int client)
{
	/*
	ClientInfo[client].TotalRoundsPlayed++;
	if (!ClientInfo[client].FirstRound)ClientInfo[client].TotalMapsPlayed++, ClientInfo[client].FirstRound = true;
	SQL_SaveClientMisc(client);
	*/
	return Plugin_Continue;
}

public void SF2_OnClientCollectPage(int pageEnt, int client)
{
	if (bEXP)
	{
		if (ClientInfo[client].ChatFlags & CHATFLAGS_EXP_PageCollect)CPrintToChat(client, "%s +%i EXP for {green}collecting a page{default}. Total EXP: %i", SF2PPREFIX, EXPInfo.PageCollect, ClientInfo[client].EXP);
		SF2P_AddClientEXP(client, EXPInfo.PageCollect);
		SQL_SaveClientEXP(client);
		LogMessage("%N +%i EXP for page collecting. EXP: %i", client, EXPInfo.PageCollect, ClientInfo[client].EXP);
		ClientInfo[client].TotalPages++;
		if (!ClientInfo[client].RoundInteracted)
		{
			ClientInfo[client].TotalRoundsPlayed++;
			ClientInfo[client].RoundInteracted = true;
		}
		SQL_SaveClientMisc(client);
	}
	
}

public void SF2_OnClientEscape(int client)
{
	if (Viewmodels_load)
	{
		LogMessage("%i pre escape", ClientInfo[client].ViewmodelEnt);
		if (ClientInfo[client].ViewmodelEnt != -1)
		{
			if (IsValidEntity(ClientInfo[client].ViewmodelEnt))RemoveEntity(ClientInfo[client].ViewmodelEnt);
			ClientInfo[client].ViewmodelEnt = -1;
		}
		SF2P_SetViewmodelActiveBool(client, false);
		LogMessage("%i post escape", ClientInfo[client].ViewmodelEnt);
	}
	
	if (bEXP)
	{
		if (ClientInfo[client].ChatFlags & CHATFLAGS_EXP_Escape)CPrintToChat(client, "%s +%i EXP for {green}escaping{default}. Total EXP: %i", SF2PPREFIX, EXPInfo.ClientEscape, ClientInfo[client].EXP);
		SF2P_AddClientEXP(client, EXPInfo.ClientEscape);
		SQL_SaveClientEXP(client);
		LogMessage("%N +%i EXP for escaping. EXP: %i", client, EXPInfo.ClientEscape, ClientInfo[client].EXP);
		
		if (ClientInfo[client].Prestige >= PrestigeInfo.SixthSense_Unlock)
		{
			for (int i; i<iActiveBosses; i++)
			{
				if (IsValidEntity(BossInfo[i].GlowEnt[client]))
				{
					RemoveEntity(BossInfo[i].GlowEnt[client]);
					LogMessage("Removing %i GlowEnt For %N, Client Escaped", BossInfo[i].GlowEnt[client], client);
					BossInfo[i].GlowEnt[client] = -1;
				}
			}
		}
	}
	ClientInfo[client].Escapes++;
		
	if (!ClientInfo[client].RoundInteracted)ClientInfo[client].TotalRoundsPlayed++;
	if (!ClientInfo[client].FirstRound)
	{
		SQL_AddClientMapCount(client);
		ClientInfo[client].TotalMapsPlayed++;
		ClientInfo[client].FirstRound = true;
	}
	SQL_SaveClientMisc(client);
	
	if (ClientInfo[client].ChallengeState == CHALLENGE_ACTIVE)Call_SF2P_ClientChallengeFailed(client, CHALLENGE_FAIL_ESCAPE);
}

public void SF2_OnClientBlink(int client)
{
	LogMessage("%N blinked.", client);
	ClientInfo[client].SixthSenseTime = 0.0;
	if (!IsValidHandle(hSixthSenseTimer))hSixthSenseTimer = CreateTimer(0.1, SF2P_SixthSenseTimer, 0, TIMER_REPEAT);
}

//Boss Functions
public void SF2_OnBossStunned(int bossIndex, int client)
{
	if (bEXP)
	{
		int target = client;
		if (target == -1)
		{
			target = SF2_GetBossTarget(bossIndex);
			if (SF2_IsClientUsingFlashlight(target))
			{
				SF2P_AddClientEXP(target, EXPInfo.BossStun);
				SQL_SaveClientEXP(target);
				if (!ClientInfo[target].RoundInteracted)
				{
					ClientInfo[target].TotalRoundsPlayed++;
					ClientInfo[target].RoundInteracted = true;
					SQL_SaveClientMisc(target);
				}
			}
		}
		else
		{
			SF2P_AddClientEXP(target, EXPInfo.BossStun);
			SQL_SaveClientEXP(target);
			if (!ClientInfo[target].RoundInteracted)
			{
				ClientInfo[target].TotalRoundsPlayed++;
				ClientInfo[target].RoundInteracted = true;
				SQL_SaveClientMisc(target);
			}
		}
		if (ClientInfo[target].ChatFlags & CHATFLAGS_EXP_BossStun)CPrintToChat(target, "%s +%i EXP for {green}stunning the boss{default}. Total EXP: %i", SF2PPREFIX, EXPInfo.BossStun, ClientInfo[target].EXP);
		LogMessage("%N +%i EXP for stunning the boss. EXP: %i", target, EXPInfo.BossStun, ClientInfo[target].EXP);
	}
	
}

public void SF2_OnBossAdded(int bossIndex)
{
	iActiveBosses++;
}

public void SF2_OnBossSpawn(int bossIndex)
{
	BossInfo[bossIndex].Target = 0;
	BossInfo[bossIndex].PrevTarget = 0;
	
	for (int i=1; i<MAXTF2PLAYERS; i++)
	{
		if (ClientInfo[i].SixthSenseTime >= PrestigeInfo.SixthSense_ActivateValue)BossInfo[bossIndex].GlowEnt[i] = SF2P_CreateBossGlow(bossIndex);
	}
}

public void SF2_OnBossDespawn(int bossIndex)
{
	BossInfo[bossIndex].Target = 0;
	BossInfo[bossIndex].PrevTarget = 0;
	
	if (bEXP)
	{
		for (int i=1; i<MAXTF2PLAYERS; i++)
		{
			if (IsValidEntity(BossInfo[bossIndex].GlowEnt[i]))
			{
				RemoveEntity(BossInfo[bossIndex].GlowEnt[i]);
				LogMessage("Removing %i GlowEnt For %N, Boss Despawned", BossInfo[bossIndex].GlowEnt[i], i);
				BossInfo[bossIndex].GlowEnt[i] = -1;
			}
			
		}
	}
	
}

public Action SF2_OnBossHearEntity(int bossIndex, int entity, SoundType soundType)
{
	if (SF2_GetBossState(bossIndex) == STATE_ALERT && entity != -1)BossInfo[bossIndex].Target = entity;
	return Plugin_Continue;
}

public void SF2_OnBossChangeState(int bossIndex, int oldState, int newState)
{
	char boss_name[64];
	SF2_GetBossName(bossIndex, boss_name, sizeof(boss_name));
	int target;
	if (newState > STATE_ALERT)
	{
		target = SF2_GetBossTarget(bossIndex);
		if (target > 0)
		{
			if (oldState > STATE_ALERT && oldState < STATE_DEATHCAM)BossInfo[bossIndex].PrevTarget = BossInfo[bossIndex].Target = target;
			BossInfo[bossIndex].Target = target;
			LogMessage("%s previous target: %i, current target: %i", boss_name, BossInfo[bossIndex].PrevTarget, BossInfo[bossIndex].Target = target);
			if (oldState < STATE_CHASE)
			{
				ClientInfo[target].ChaseCount++;
				SQL_SaveClientMisc(target);
				LogMessage("%s started chasing %N", boss_name, target);
			}
		}
		
	}
	else if (oldState == STATE_CHASE)BossInfo[bossIndex].Target = 0, BossInfo[bossIndex].PrevTarget = 0;
	else { BossInfo[bossIndex].Target = 0, BossInfo[bossIndex].PrevTarget = 0; }
}

public Action SF2_OnBossSeeEntity(int bossIndex, int entity)
{
	if (entity > 0)
	{
		if (SF2_GetBossState(bossIndex) == STATE_ALERT)BossInfo[bossIndex].Target = entity;
	}
	return Plugin_Continue;
}

//----------------------------------------------------------------------------------------
//	Hooked game events
//----------------------------------------------------------------------------------------

public void Hook_OnClientSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if (!SF2_IsRunning())
	{
		LogMessage("[SF2+] SF2 is not enabled. Hook_OnClientSpawn");
	}
	if (!SF2_IsClientEliminated(client))
	{
		if (SF2_GetRoundState() == SF2RoundState_Active || SF2_GetRoundState() == SF2RoundState_Escape)
		{
			if (bUtilities)SF2P_SetClientUtilityAmountByDifficulty(client); // Add Utilities
		}
		LogMessage("%i pre spawn", ClientInfo[client].ViewmodelEnt);
		if (Viewmodels_load)
		{
			if (ClientInfo[client].ViewmodelEnt == -1) { SF2P_CreateUtilityViewmodel(client); }
		}
		LogMessage("%i post spawn", ClientInfo[client].ViewmodelEnt);
		GetClientAbsOrigin(client, ClientInfo[client].PrevVector);
	}
	SF2P_SetViewmodelActiveBool(client, false);
	SF2PClientHudRefresh(client);
	iClientPrevHealth[client] = GetEntProp(client, Prop_Send, "m_iHealth");
	if (!IsValidHandle(hInspectTimer))hInspectTimer = CreateTimer(0.1, SF2P_InspectTimerHandle, 0, TIMER_REPEAT);
	// Prestige Stuff
	if (ClientInfo[client].Prestige >= PrestigeInfo.LethalSurvival_Unlock)ClientInfo[client].LethalSurvival = true;
	
}

public Action Hook_OnClientDeath(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));
	LogMessage("%i pre death", ClientInfo[client].ViewmodelEnt);
	if (ClientInfo[client].ViewmodelEnt != -1)
	{
		if (IsValidEntity(ClientInfo[client].ViewmodelEnt))RemoveEntity(ClientInfo[client].ViewmodelEnt);
		ClientInfo[client].ViewmodelEnt = -1;
	}
	SF2P_SetViewmodelActiveBool(client, false);
	LogMessage("%i post death", ClientInfo[client].ViewmodelEnt);
	// Misc
	if (TF2_GetClientTeam(client) == TFTeam_Red && SF2_GetRoundState() == SF2RoundState_Active || TF2_GetClientTeam(client) == TFTeam_Red && SF2_GetRoundState() == SF2RoundState_Escape)
	{
		LogMessage("%N died in RED. +1 to death count.", client);
		ClientInfo[client].Deaths++;
		
		if (!ClientInfo[client].RoundInteracted)ClientInfo[client].TotalRoundsPlayed++;
		if (!ClientInfo[client].FirstRound)
		{
			SQL_AddClientMapCount(client);
			ClientInfo[client].TotalMapsPlayed++;
			ClientInfo[client].FirstRound = true;
		}
		SQL_SaveClientMisc(client);
		if (!ClientInfo[client].SecondLife)ClientInfo[client].RoundInteracted = false;
		if (ClientInfo[client].ChallengeState == CHALLENGE_ACTIVE && !ClientInfo[client].SecondLife)Call_SF2P_ClientChallengeFailed(client, CHALLENGE_FAIL_DEATH);
		if (ClientInfo[client].SecondLife)ClientInfo[client].SecondLife = false;
	}
	// Prestige
	ClientInfo[client].LethalSurvival = false;
	if (ClientInfo[client].SixthSense)
	{
		for (int i; i<iActiveBosses; i++)
		{
			if (IsValidEntity(BossInfo[i].GlowEnt[client]))
			{
				LogMessage("Removing %i GlowEnt For %N, Client Died", BossInfo[i].GlowEnt[client], client);
				RemoveEntity(BossInfo[i].GlowEnt[client]);
				BossInfo[i].GlowEnt[client] = -1;
			}
		}
	}
	return Plugin_Continue;
}

public Action Hook_OnClientPreHurt(Event event, const char[] name, bool dontBroadcast)
{
	int victim = GetClientOfUserId(event.GetInt("userid"));
	int victim_health = event.GetInt("health");
	int damageamount = event.GetInt("damageamount");
	
	if (SF2PClientCheck(victim, false, true))SF2PClientHudRefresh(victim);
	
	// Prestige
	if (victim_health - damageamount < 1 && SF2PClientCheck(victim, false, true) && ClientInfo[victim].LethalSurvival)
	{
		SetEntityHealth(victim, 1);
		EmitSoundToAll(PrestigeInfo.LethalSurvival_Sound, victim, _, SNDLEVEL_SCREAMING);
		TF2_AddCondition(victim, TFCond_Ubercharged, PrestigeInfo.LethalSurvival_Length);
		ClientInfo[victim].LethalSurvival = false;
		LogMessage("%N's Lethal Survival Activated.", victim);
	}
	return Plugin_Continue;
}

public Action OnClientCommand(int client, int args)
{
	char command[32];
	GetCmdArg(0, command, sizeof(command));
	//CPrintToChat(client, "%s", command);
	if (StrEqual(command, "sm_slghost"))
	{
	}
	return Plugin_Continue;
}

//----------------------------------------------------------------------------------------
//	SF2P Natives and Forwards
//----------------------------------------------------------------------------------------

public APLRes AskPluginLoad2()
{
	CreateNative("SF2P_AreUtilitiesActive", native_SF2P_AreUtilitiesActive);
	CreateNative("SF2P_IsPlayerEXPActive", native_SF2P_IsPlayerEXPActive);
	CreateNative("SF2P_AreChallengesActive", native_SF2P_AreChallengesActive);
	CreateNative("SF2P_AreUtilityViewmodelsActive", native_SF2P_AreUtilityViewmodelsActive);
	
	CreateNative("SF2P_ToggleUtilityUse", native_SF2P_ToggleUtilityUse);
	
	CreateNative("SF2P_SetUtilityCharges", native_SF2P_SetUtilityCharges);
	CreateNative("SF2P_AddUtilityCharges", native_SF2P_AddUtilityCharges);
	
	CreateNative("SF2P_GetUtilityName", native_SF2P_GetUtilityName);
	CreateNative("SF2P_GetUtilityHudName", native_SF2P_GetUtilityHudName);
	CreateNative("SF2P_GetUtilityIndex", native_SF2P_GetUtilityIndex);
	CreateNative("SF2P_GetUtilityCount", native_SF2P_GetUtilityCount);
	
	CreateNative("SF2P_GetClientUtility", native_SF2P_GetClientUtility);
	CreateNative("SF2P_SetClientUtility", native_SF2P_SetClientUtility);
	CreateNative("SF2P_GetClientUtilityName", native_SF2P_GetClientUtilityName);
	CreateNative("SF2P_UseClientUtility", native_SF2P_UseClientUtility);
	CreateNative("SF2P_IsClientUtilitySlotUnlocked", native_SF2P_IsClientUtilitySlotUnlocked);
	CreateNative("SF2P_IsClientUtilityEquipped", native_SF2P_IsClientUtilityEquipped);
	
	CreateNative("SF2P_GetClientUtilityViewmodelEntity", native_SF2P_GetClientUtilityViewmodelEntity);
	CreateNative("SF2P_SetClientUtilityViewmodelEntity", native_SF2P_SetClientUtilityViewmodelEntity);
	
	CreateNative("SF2P_SetClientUtilityViewmodel", native_SF2P_SetClientUtilityViewmodel);
	
	CreateNative("SF2P_GetClientUtilityViewmodelValue", native_SF2P_GetClientUtilityViewmodelValue);
	CreateNative("SF2P_GetUtilityViewmodelValue", native_SF2P_GetUtilityViewmodelValue);
	
	CreateNative("SF2P_ActivateClientUtilityViewmodel", native_SF2P_ActivateClientUtilityViewmodel);
	
	CreateNative("SF2P_GetUtilityViewmodelCount", native_SF2P_GetUtilityViewmodelCount);
	
	CreateNative("SF2P_GetClientHudPosition", native_SF2P_GetClientHudPosition);
	CreateNative("SF2P_SetClientHudPosition", native_SF2P_SetClientHudPosition);
	CreateNative("SF2P_GetDefaultHudPosition", native_SF2P_GetDefaultHudPosition);
	CreateNative("SF2P_GetClientHudFlags", native_SF2P_GetClientHudFlags);
	CreateNative("SF2P_SetClientHudFlags", native_SF2P_SetClientHudFlags);
	
	CreateNative("SF2P_GetHudIcon", native_SF2P_GetHudIcon);
	
	CreateNative("SF2P_GetClientChatFlags", native_SF2P_GetClientChatFlags);
	CreateNative("SF2P_SetClientChatFlags", native_SF2P_SetClientChatFlags);
	
	CreateNative("SF2P_GetEXPInfo", native_SF2P_GetEXPInfo);
	
	CreateNative("SF2P_GetClientEXP", native_SF2P_GetClientEXP);
	CreateNative("SF2P_GetClientLevel", native_SF2P_GetClientLevel);
	CreateNative("SF2P_GetClientPrestige", native_SF2P_GetClientPrestige);
	CreateNative("SF2P_CanClientPrestige", native_SF2P_CanClientPrestige);
	CreateNative("SF2P_AddClientEXP", native_SF2P_AddClientEXP);
	CreateNative("SF2P_PrestigeClient", native_SF2P_PrestigeClient);
	
	CreateNative("SF2P_GetClientTotalRoundsPlayed", native_SF2P_GetClientTotalRoundsPlayed);
	CreateNative("SF2P_GetClientTotalMapsPlayed", native_SF2P_GetClientTotalMapsPlayed);
	CreateNative("SF2P_GetClientTotalPages", native_SF2P_GetClientTotalPages);
	CreateNative("SF2P_GetClientTotalEscapes", native_SF2P_GetClientTotalEscapes);
	CreateNative("SF2P_GetClientTotalChaseCount", native_SF2P_GetClientTotalChaseCount);
	CreateNative("SF2P_GetClientDeathCount", native_SF2P_GetClientDeathCount);
	CreateNative("SF2P_GetClientTotalUtilityUses", native_SF2P_GetClientTotalUtilityUses);
	CreateNative("SF2P_GetClientTotalTravelDistance", native_SF2P_GetClientTotalTravelDistance);
	CreateNative("SF2P_GetClientCompletedChallengeCount", native_SF2P_GetClientCompletedChallengeCount);
	
	CreateNative("SF2P_SetClientChallengeDescription", native_SF2P_SetClientChallengeDescription);
	CreateNative("SF2P_ChangeClientChallengeState", native_SF2P_ChangeClientChallengeState);
	CreateNative("SF2P_RerollClientChallenge", native_SF2P_RerollClientChallenge);
	
	CreateNative("SF2P_IsClientChased", native_SF2P_IsClientChased);
	
	CreateNative("SF2P_IsActiveBossStunnable", native_SF2P_IsActiveBossStunnable);
	
	RegPluginLibrary("SF2Plus");
	return APLRes_Success;
}

public void Call_SF2P_OnClientLevelUp(int client, int level)
{
	Call_StartForward(g_OnClientLevelUp);
	Call_PushCell(client);
	Call_PushCell(level);
	Call_Finish();
}

public void Call_SF2P_OnClientPrestigeUp(int client, int prestige)
{
	Call_StartForward(g_OnClientPrestigeUp);
	Call_PushCell(client);
	Call_PushCell(prestige);
	Call_Finish();
}

public void Call_SF2P_OnUtilityRegistered(char[] utility)
{
	Call_StartForward(g_OnUtilityRegistered);
	Call_PushString(utility);
	Call_Finish();
}

public void Call_SF2P_OnUtilityUsed(int client, char[] utility, int utility_slot)
{
	Call_StartForward(g_OnUtilityUsed);
	Call_PushCell(client);
	Call_PushString(utility);
	Call_PushCell(utility_slot);
	Call_Finish();
}

public void Call_SF2P_UtilityRegistered(int utility)
{
	Function invalid = GetFunctionByName(INVALID_HANDLE, "");
	Function func = GetFunctionByName(UtilityInfo[utility].handle, "SF2P_UtilityRegistered");
	if (func != invalid)
	{
		Call_StartFunction(UtilityInfo[utility].handle, func);
		Call_Finish();
	}
}

public bool Call_SF2P_UtilityRequirements(int client, int utility)
{
	bool result = true;
	Function invalid = GetFunctionByName(INVALID_HANDLE, "");
	Function func = GetFunctionByName(UtilityInfo[utility].handle, "SF2P_UtilityRequirements");
	if (func != invalid)
	{
		Call_StartFunction(UtilityInfo[utility].handle, func);
		Call_PushCell(client);
		Call_Finish(result);
	}
	return result;
}

public void Call_SF2P_UtilityUsed(int client, int utility)
{
	Function invalid = GetFunctionByName(INVALID_HANDLE, "");
	Function func = GetFunctionByName(UtilityInfo[utility].handle, "SF2P_UtilityUsed");
	if (func != invalid)
	{
		Call_StartFunction(UtilityInfo[utility].handle, func);
		Call_PushCell(client);
		Call_Finish();
	}
	else { LogError("[SF2+] !!! Function \"SF2P_UtilityUsed\" not found in utility plugin %s.", UtilityInfo[utility].Name); }
}

public void Call_SF2P_OnChallengeRegistered(char[] challenge)
{
	Call_StartForward(g_OnChallengeRegistered);
	Call_PushString(challenge);
	Call_Finish();
}

public void Call_SF2P_OnChallengeSelected(int client, char[] challenge)
{
	Call_StartForward(g_OnChallengeSelected);
	Call_PushCell(client);
	Call_PushString(challenge);
	Call_Finish();
	SF2PClientHudRefresh(client);
}

public void Call_SF2P_ChallengeRegistered(int challenge)
{
	Function invalid = GetFunctionByName(INVALID_HANDLE, "");
	Function func = GetFunctionByName(ChallengeInfo[challenge].handle, "SF2P_ChallengeRegistered");
	if (func != invalid)
	{
		Call_StartFunction(ChallengeInfo[challenge].handle, func);
		Call_Finish();
	}
}

public void Call_SF2P_ChallengeSelected(int client)
{
	int challenge = ClientInfo[client].Challenge;
	Function invalid = GetFunctionByName(INVALID_HANDLE, "");
	Function func = GetFunctionByName(ChallengeInfo[challenge].handle, "SF2P_ChallengeSelected");
	if (func != invalid)
	{
		Call_StartFunction(ChallengeInfo[challenge].handle, func);
		Call_PushCell(client);
		Call_Finish();
	}
	SF2PClientHudRefresh(client);
}

public void Call_SF2P_ClientChallengeFailed(int client, int reason)
{
	Call_StartForward(g_ClientChallengeFailed);
	Call_PushCell(client);
	Call_PushCell(reason);
	Call_Finish();
	SF2PClientHudRefresh(client);
}

//SF2P_AreUtilitiesActive()
public any native_SF2P_AreUtilitiesActive(Handle plugin, int numParams)
{
	return bUtilities;
}

//SF2P_IsPlayerEXPActive()
public any native_SF2P_IsPlayerEXPActive(Handle plugin, int numParams)
{
	return bEXP;
}

//SF2P_AreChallengesActive()
public any native_SF2P_AreChallengesActive(Handle plugin, int numParams)
{
	return bChallenges;
}

//SF2P_AreUtilityViewmodelsActive()
public any native_SF2P_AreUtilityViewmodelsActive(Handle plugin, int numParams)
{
	return Viewmodels_load;
}

//SF2P_ToggleUtilityUse()
public any native_SF2P_ToggleUtilityUse(Handle plugin, int numParams)
{
	if (bUtilities)bUtilities = false;
	else bUtilities = true;
	return bUtilities;
}

//SF2P_SetUtilityCharges(int client, int util_slot, int amount)
public any native_SF2P_SetUtilityCharges(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (SF2PClientCheck(client, false, true))
	{
		int util_slot = GetNativeCell(2);
		int amount = GetNativeCell(3);
		for (int i; i<3; i++)
		{
			if (util_slot == 3)ClientInfo[client].UtilityUses[i] = amount; 
			else 
			{
				ClientInfo[client].UtilityUses[util_slot] = amount;
				break;					
			} 
		}
		LogMessage("[SF2+] %N's utilities have been set to %i", client, amount);
		SF2PClientHudRefresh(client);
	}
	return true;
}

//SF2P_AddUtilityCharges(int client, bool util1, bool util2, bool util3, int amount)
public any native_SF2P_AddUtilityCharges(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int util_slot = GetNativeCell(2);
	int amount = GetNativeCell(3);
	for (int i; i<3; i++)
	{
		if (util_slot == 3)ClientInfo[client].UtilityUses[i] += amount;
		else 
		{
			ClientInfo[client].UtilityUses[util_slot] += amount;
			break;					
		} 
	}
	LogMessage("[SF2+] Gave %i utility charges to %N", amount, client);
	SF2PClientHudRefresh(client);
	return true;
} 

//SF2P_GetClientUtility(int client, int util_slot)
public int native_SF2P_GetClientUtility(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].Utility[GetNativeCell(2)];
}

//SF2P_SetClientUtility(int client, int util_slot, int new_utility, bool replace)
public any native_SF2P_SetClientUtility(Handle plugin, int numParams)
{
	SF2PChangeClientUtilities(GetNativeCell(1), GetNativeCell(2)+1, UtilityInfo[GetNativeCell(3)].Name, GetNativeCell(4));
	return true;
}

//SF2P_GetClientUtilityName(int client, int util_slot, char[] utility, int maxlength);
public any native_SF2P_GetClientUtilityName(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int util_slot = GetNativeCell(2);
	SetNativeString(3, UtilityInfo[ClientInfo[client].Utility[util_slot]].Name, GetNativeCell(4)); 
	return true;
}

//SF2P_UseClientUtility(int client, int util_slot)
public any native_SF2P_UseClientUtility(Handle plugin, int numParams)
{
	int util_slot = GetNativeCell(2);
	if (util_slot == 0)Cmd_SF2PUtil1Use(GetNativeCell(1), 0);
	else if (util_slot == 1)Cmd_SF2PUtil2Use(GetNativeCell(1), 0);
	else if (util_slot == 2)Cmd_SF2PUtil3Use(GetNativeCell(1), 0);
	return true;
}

//SF2P_IsClientUtilitySlotUnlocked
public any native_SF2P_IsClientUtilitySlotUnlocked(Handle plugin, int numParams)
{
	int client = GetNativeCell(1)
	int util_slot = GetNativeCell(2);
	switch (util_slot)
	{
		case 0:return ClientInfo[client].Level >= LevelUnlock.First_Utility;
		case 1:return ClientInfo[client].Level >= LevelUnlock.Second_Utility;
		case 2:return ClientInfo[client].Level >= LevelUnlock.Third_Utility;
	}
	LogMessage("!!! Invalid Utility Slot: %i", util_slot);
	return false;
}

//SF2P_IsClientUtilityEquipped(int client, int utility)
public any native_SF2P_IsClientUtilityEquipped(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int utility = GetNativeCell(2);
	for (int i; i<3; i++)
	{
		if (ClientInfo[client].Utility[i] == utility)return i;
	}
	return -1;
}


//SF2P_GetUtilityName(int util_index, char[] utility, int maxlength); 
public any native_SF2P_GetUtilityName(Handle plugin, int numParams)
{
	SetNativeString(2, UtilityInfo[GetNativeCell(1)].Name, GetNativeCell(3));
	return true;
}

//SF2P_GetUtilityHudName(int util_index, char[] utility, int maxlength); 
public any native_SF2P_GetUtilityHudName(Handle plugin, int numParams)
{
	SetNativeString(2, UtilityInfo[GetNativeCell(1)].HudName, GetNativeCell(3));
	return true;
}

//SF2P_GetUtilityIndex(char[] utility);
public int native_SF2P_GetUtilityIndex(Handle plugin, int numParams)
{
	char utility[UTILITYNAMESIZE];
	GetNativeString(1, utility, sizeof(utility))
	return SF2PGetUtilityIndex(utility);
}

//SF2P_GetUtilityCount();
public int native_SF2P_GetUtilityCount(Handle plugin, int numParams)
{
	return iUtilityCount;
}

//SF2P_GetClientCustomViewmodelEntity(int client)
public int native_SF2P_GetClientUtilityViewmodelEntity(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (!IsValidEntity(ClientInfo[client].ViewmodelEnt) && ClientInfo[client].ViewmodelEnt != -1) 
	{
		ClientInfo[client].ViewmodelEnt = -1;
	}
	return ClientInfo[client].ViewmodelEnt;
}

//SF2P_SetClientCustomViewmodelEntity(int client, int ent)
public any native_SF2P_SetClientUtilityViewmodelEntity(Handle plugin, int numParams)
{
	ClientInfo[GetNativeCell(1)].ViewmodelEnt = GetNativeCell(2);
	return true;
}

//(int client, int util_slot, int vm_index)
public int native_SF2P_SetClientUtilityViewmodel(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int util_slot = GetNativeCell(2);
	int util_idx = ClientInfo[client].Utility[util_slot];
	int vm_index = GetNativeCell(3);
	ClientInfo[client].Viewmodel[util_slot] = vm_index; 
	SQL_SaveClientUtilityViewmodel(client, util_slot);
	SF2PClientHudRefresh(client);
	LogMessage("[SF2+] Saving %N's %s Utility Viewmodel Preference: %s", client, UtilityInfo[util_idx].Name, UtilViewmodel[util_idx][vm_index].name);
	return ClientInfo[client].Viewmodel[util_slot];
}

//idx, name, model, skin, duration, delay, 
//hideMainViewmodel, screenfadecolor, screenfadein, screenholdtime, screenfadeout
//
//SF2P_GetClientCustomViewmodelValue(int client, int util_slot, char[] value, char[] buffer, int maxlength)
public any native_SF2P_GetClientUtilityViewmodelValue(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int util_slot = GetNativeCell(2);
	int util_idx = ClientInfo[client].Utility[util_slot];
	int vm_idx = ClientInfo[client].Viewmodel[util_slot];
	char value[PLATFORM_MAX_PATH];
	char[] buffer = new char[GetNativeCell(5)];
	GetNativeString(3, value, sizeof(value));
	if (StrEqual(value, "idx"))
	{
		IntToString(UtilViewmodel[util_idx][vm_idx].idx, buffer, 3);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "name"))SetNativeString(4, UtilViewmodel[util_idx][vm_idx].name, GetNativeCell(5));
	if (StrEqual(value, "hudname"))SetNativeString(4, UtilViewmodel[util_idx][vm_idx].hudname, GetNativeCell(5));
	if (StrEqual(value, "model"))SetNativeString(4, UtilViewmodel[util_idx][vm_idx].model, GetNativeCell(5));
	if (StrEqual(value, "skin"))
	{
		IntToString(UtilViewmodel[util_idx][vm_idx].skin, buffer, 3);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "body"))
	{
		IntToString(UtilViewmodel[util_idx][vm_idx].body, buffer, 3);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "duration"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].duration, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "delay"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].delay, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "sound"))
	{
		int class = _:TF2_GetPlayerClass(client);
		SetNativeString(4, UtilViewmdlSound[util_idx][vm_idx][class], GetNativeCell(5)); 
	}
	if (StrEqual(value, "hideMainViewmodel"))
	{
		int class = _:TF2_GetPlayerClass(client);
		IntToString(UtilViewmodel[util_idx][vm_idx].hideMainViewmodel[class], buffer, 5);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "screenfadecolor"))
	{
		FormatEx(buffer, 16, "%i %i %i %i", UtilViewmodel[util_idx][vm_idx].screenfadecolor[0], UtilViewmodel[util_idx][vm_idx].screenfadecolor[1], UtilViewmodel[util_idx][vm_idx].screenfadecolor[2], UtilViewmodel[util_idx][vm_idx].screenfadecolor[3]);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "screendelay"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].screendelay, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "screenfadein"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].screenfadein, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "screenholdtime"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].screenholdtime, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "screenfadeout"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].screenfadeout, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	return true;
}

//SF2P_GetUtilityViewmodelValue(int util_idx, int vm_idx, char[] value, char[] buffer, int maxlength)
public any native_SF2P_GetUtilityViewmodelValue(Handle plugin, int numParams)
{
	int class;
	int util_idx = GetNativeCell(1);
	int vm_idx = GetNativeCell(2);
	char value[PLATFORM_MAX_PATH];
	char[] buffer = new char[GetNativeCell(5)];
	GetNativeString(3, value, sizeof(value));
	for (int i; i<strlen(value); i++)
	{
		if (value[i] == ' ')
		{
			class = StringToInt(value[i+1]); // i+1 for int in next character
			strcopy(value, i+1, value); // i+1 for null terminator
			break;
		}
	}
	if (StrEqual(value, "idx"))
	{
		IntToString(UtilViewmodel[util_idx][vm_idx].idx, buffer, 3);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "name"))SetNativeString(4, UtilViewmodel[util_idx][vm_idx].name, GetNativeCell(5));
	if (StrEqual(value, "hudname"))SetNativeString(4, UtilViewmodel[util_idx][vm_idx].hudname, GetNativeCell(5));
	if (StrEqual(value, "model"))SetNativeString(4, UtilViewmodel[util_idx][vm_idx].model, GetNativeCell(5));
	if (StrEqual(value, "skin"))
	{
		IntToString(UtilViewmodel[util_idx][vm_idx].skin, buffer, 3);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "body"))
	{
		IntToString(UtilViewmodel[util_idx][vm_idx].body, buffer, 3);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "duration"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].duration, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "delay"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].delay, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "sound"))
	{
		SetNativeString(4, UtilViewmdlSound[util_idx][vm_idx][class], GetNativeCell(5)); 
	}
	if (StrEqual(value[17], "hideMainViewmodel"))
	{
		IntToString(UtilViewmodel[util_idx][vm_idx].hideMainViewmodel[class], buffer, 5);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "screendelay"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].screendelay, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "screenfadecolor"))
	{
		FormatEx(buffer, 16, "%i %i %i %i", UtilViewmodel[util_idx][vm_idx].screenfadecolor[0], UtilViewmodel[util_idx][vm_idx].screenfadecolor[1], UtilViewmodel[util_idx][vm_idx].screenfadecolor[2], UtilViewmodel[util_idx][vm_idx].screenfadecolor[3]);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "screenfadein"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].screenfadein, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "screenholdtime"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].screenholdtime, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	if (StrEqual(value, "screenfadeout"))
	{
		FloatToString(UtilViewmodel[util_idx][vm_idx].screenfadeout, buffer, 16);
		SetNativeString(4, buffer, GetNativeCell(5)); 
	}
	return true;
}

//SF2P_ActivateClientUtilityViewmodel(int client, int util_slot)
public any native_SF2P_ActivateClientUtilityViewmodel(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int util_slot = GetNativeCell(2);
	SF2P_ActivateUtilityViewmodel(client, util_slot);
	return true;
}

//SF2P_GetUtilityViewmodelCount(int utility)
public int native_SF2P_GetUtilityViewmodelCount(Handle plugin, int numParams)
{
	return iUtilViewmodel_count[GetNativeCell(1)];
}

//SF2P_GetClientHudPosition(int client, char[] axis)
public any native_SF2P_GetClientHudPosition(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	char axis[2];
	GetNativeString(2, axis, 2);
	if (axis[0] == 'x')return ClientInfo[client].HudPos[0]; 
	if (axis[0] == 'y')return ClientInfo[client].HudPos[1];
	else { return -1.0; }
}

//SF2P_SetClientHudPosition
public any native_SF2P_SetClientHudPosition(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	float x = GetNativeCell(2);
	float y = GetNativeCell(3);
	ClientInfo[client].HudPos[0] = x;
	ClientInfo[client].HudPos[1] = y;
	SQL_SaveClientHudPos(client);
	return true;
}

//SF2P_GetDefaultHudPosition
public any native_SF2P_GetDefaultHudPosition(Handle plugin, int numParams)
{
	char axis[2];
	GetNativeString(1, axis, 2);
	if (axis[0] == 'x')return fHud_Pos_Default[0];
	if (axis[0] == 'y')return fHud_Pos_Default[1];
	else { return -1.0; }
}

//SF2P_GetClientHudFlags(int client)
public int native_SF2P_GetClientHudFlags(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].HudFlags;
}

//SF2P_SetClientHudFlags(int client, int flags)
public int native_SF2P_SetClientHudFlags(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	if (ClientInfo[client].HudFlags & GetNativeCell(2))ClientInfo[client].HudFlags -= GetNativeCell(2);
	else ClientInfo[client].HudFlags += GetNativeCell(2);
	SQL_SaveClientHudFlags(client);
	LogMessage("%i %i", ClientInfo[client].HudFlags, GetNativeCell(2));
	return ClientInfo[client].HudFlags;
}

//SF2P_GetHudIcon(int index, char[] icon, int maxlength)
public any native_SF2P_GetHudIcon(Handle plugin, int numParams)
{
	SetNativeString(2, szHudIcons[GetNativeCell(1)], GetNativeCell(3));
	return true;
}

//SF2P_GetClientChatFlags(int client)
public int native_SF2P_GetClientChatFlags(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].ChatFlags;
}

//SF2P_SetClientChatFlags(int client, int flags)
public int native_SF2P_SetClientChatFlags(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	int flag = GetNativeCell(2);
	if (ClientInfo[client].ChatFlags & flag)ClientInfo[client].ChatFlags -= flag;
	else { ClientInfo[client].ChatFlags += flag; }
	SQL_SaveClientChatFlags(client);
	return ClientInfo[client].ChatFlags;
}

//SF2P_GetEXPInfo(int section)
public int native_SF2P_GetEXPInfo(Handle plugin, int numParams)
{
	int section = GetNativeCell(1);
	if (section == EXP_PrestigeUp)return EXPInfo.PrestigeUp;
	if (section == EXP_LevelUp)return EXPInfo.LevelUp;
	if (section == EXP_PageCollect)return EXPInfo.PageCollect;
	if (section == EXP_ClientEscape)return EXPInfo.ClientEscape;
	if (section == EXP_ChaseTakeover)return EXPInfo.ChaseTakeover;
	if (section == EXP_BossStun)return EXPInfo.BossStun;
	if (section == EXP_UsedDroppedUtility)return EXPInfo.UsedDroppedUtility;
	else { return -1; }
}

//SF2P_GetClientEXP(int client)
public int native_SF2P_GetClientEXP(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].EXP;
}

//SF2P_GetClientLevel(int client)
public int native_SF2P_GetClientLevel(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].Level;
}

//SF2P_GetClientPrestige(int client)
public int native_SF2P_GetClientPrestige(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].Prestige;
}

//SF2P_CanClientPrestige(int client)
public any native_SF2P_CanClientPrestige(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].Level >= EXPInfo.PrestigeUp;
}

//SF2P_AddClientEXP(int client, int amount)
public any native_SF2P_AddClientEXP(Handle plugin, int numParams)
{
	ClientInfo[GetNativeCell(1)].EXP += GetNativeCell(2);
	ClientEXPHandler(GetNativeCell(1));
	return ClientInfo[GetNativeCell(1)].EXP;
}

//SF2P_PrestigeClient(int client)
public any native_SF2P_PrestigeClient(Handle plugin, int numParams)
{
	return PrestigeClient(GetNativeCell(1));
}

//SF2P_GetClientTotalRoundsPlayed(int client)
public int native_SF2P_GetClientTotalRoundsPlayed(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].TotalRoundsPlayed;
}

//SF2P_GetClientTotalMapsPlayed(int client)
public int native_SF2P_GetClientTotalMapsPlayed(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].TotalMapsPlayed;
}

//SF2P_GetClientTotalPages(int client)
public int native_SF2P_GetClientTotalPages(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].TotalPages;
}

//SF2P_GetClientTotalEscapes(int client)
public int native_SF2P_GetClientTotalEscapes(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].Escapes;
}

//SF2P_GetClientTotalChaseCount(int client)
public int native_SF2P_GetClientTotalChaseCount(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].ChaseCount;
}

//SF2P_GetClientDeathCount(int client)
public int native_SF2P_GetClientDeathCount(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].Deaths;
}

//SF2P_GetClientTotalUtilityUses(int client)
public int native_SF2P_GetClientTotalUtilityUses(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].TotalUtilityUses;
}

//SF2P_GetClientTotalTravelDistance(int client)
public any native_SF2P_GetClientTotalTravelDistance(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].TravelDist;
}

//SF2P_GetClientCompletedChallengeCount(int client)
public int native_SF2P_GetClientCompletedChallengeCount(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].CompletedChallengeCount;
}

//SF2P_SetClientChallengeDescription(int client, char[] description, int maxlength)
public any native_SF2P_SetClientChallengeDescription(Handle plugin, int numParams)
{
	GetNativeString(2, ClientInfo[GetNativeCell(1)].ChallengeDescription, GetNativeCell(3));
	return true;
}

//SF2P_ChangeClientChallengeState(int client, int state, int reward)
public any native_SF2P_ChangeClientChallengeState(Handle plugins, int numParams)
{
	int client = GetNativeCell(1);
	int state = GetNativeCell(2);
	int reward = GetNativeCell(3);
	ClientInfo[client].ChallengeState = state;
	if (state == CHALLENGE_COMPLETED && bEXP)
	{
		SF2P_AddClientEXP(client, reward);
		if (ClientInfo[client].ChatFlags & CHATFLAGS_EXP_Challenge)CPrintToChat(client, "%s +%i EXP for {green}completing a challenge{default}. Total EXP: %i", SF2PPREFIX, reward, ClientInfo[client].EXP);
		SQL_SaveClientEXP(client);
		ClientInfo[client].CompletedChallengeCount++;
		SQL_SaveClientMisc(client);
	}
	return true;
}

//SF2P_RerollClientChallenge(int client)
public any native_SF2P_RerollClientChallenge(Handle plugins, int numParams)
{
	SF2P_RollClientChallenge(GetNativeCell(1));
	return true;
}

//SF2P_IsClientChased(int client)
public any native_SF2P_IsClientChased(Handle plugin, int numParams)
{
	return ClientInfo[GetNativeCell(1)].Chased;
}

//SF2P_IsActiveBossStunnable()
public any native_SF2P_IsActiveBossStunnable(Handle plugin, int numParams)
{
	bool stunnable;
	for (int i; i<iActiveBosses; i++)
	{
		if (SF2_IsBossStunnable(i))stunnable = true;
	}
	return stunnable;
}
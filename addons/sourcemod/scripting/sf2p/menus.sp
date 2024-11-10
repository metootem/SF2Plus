Handle g_MainMenu;

Handle g_UtilityAmountMenu;

Handle g_SpectatorMenu;

Handle g_HudSettingsMenu;
Handle g_StatusIconsMenu;
Handle g_SelectHudAxisMenu;

Handle g_RoundSettingsMenu;
Handle g_SetRoundDifficultyMenu;

int iClientSelectedFromMenu;

public void CreateMenus()
{
	// Main Menu
	g_MainMenu = CreateMenu(SF2P_Main_Menu); 
	SetMenuTitle(g_MainMenu, "SF2P Main Menu.");
	AddMenuItem(g_MainMenu, "1", "Player Info.")
	AddMenuItem(g_MainMenu, "2", "Utility Menus.", (SF2P_AreUtilitiesActive() ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
	AddMenuItem(g_MainMenu, "3", "EXP Menus.", (SF2P_IsPlayerEXPActive() ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
	AddMenuItem(g_MainMenu, "4", "Spectator Menus.");
	AddMenuItem(g_MainMenu, "5", "HUD Menus.");
	AddMenuItem(g_MainMenu, "6", "Commands.");
	//AddMenuItem(g_MainMenu, "7", "Round Settings."); // Admin Command
	
	
	// In-game Utilities Menu
	
	g_UtilityAmountMenu = CreateMenu(SF2P_Select_Utility_Amount_Menu);
	SetMenuTitle(g_UtilityAmountMenu, "Select Utility Amount");
	AddMenuItem(g_UtilityAmountMenu, "0", "reserved");
	AddMenuItem(g_UtilityAmountMenu, "1", "1");
	AddMenuItem(g_UtilityAmountMenu, "2", "2");
	AddMenuItem(g_UtilityAmountMenu, "3", "3");
	AddMenuItem(g_UtilityAmountMenu, "4", "4");
	AddMenuItem(g_UtilityAmountMenu, "5", "5");
	AddMenuItem(g_UtilityAmountMenu, "6", "6");
	AddMenuItem(g_UtilityAmountMenu, "7", "Custom");
	
	
	// Spectator Settings Menu
	g_SpectatorMenu = CreateMenu(SF2P_Spectator_Settings); 
	SetMenuTitle(g_SpectatorMenu, "SF2P Spectator Settings.");
	AddMenuItem(g_SpectatorMenu, "1", "Spectate Client.");
	AddMenuItem(g_SpectatorMenu, "2", "Enable Noclip When Spectating."); // Add Prefs?
	//AddMenuItem(g_SpectatorMenu, "3", "Change Spectating Speed."); // Currently Impossible Due To SF2 Setting Per Tick
	SetMenuExitBackButton(g_SpectatorMenu, true);
	
	
	// SF2P Hud Settings Menu
	g_HudSettingsMenu = CreateMenu(SF2P_Hud_Settings_Menu);
	SetMenuTitle(g_HudSettingsMenu, "SF2P Hud Settings Menu");
	AddMenuItem(g_HudSettingsMenu, "1", "Toggle HUD Sections.");
	AddMenuItem(g_HudSettingsMenu, "2", "Set HUD Position.");
	AddMenuItem(g_HudSettingsMenu, "3", "HUD Status Icons.");
	//AddMenuItem(g_HudSettingsMenu, "4", "Reload HUD Status Icons.");
	SetMenuExitBackButton(g_HudSettingsMenu, true);
	
	g_SelectHudAxisMenu = CreateMenu(SF2P_Select_Hud_Axis_Menu);
	SetMenuTitle(g_SelectHudAxisMenu, "Select Hud Axis To Change.")
	AddMenuItem(g_SelectHudAxisMenu, "x", "x");
	AddMenuItem(g_SelectHudAxisMenu, "y", "y");
	SetMenuExitBackButton(g_SelectHudAxisMenu, true);
	
	char display[64];
	g_StatusIconsMenu = CreateMenu(SF2P_Status_Icons_Menu);
	SetMenuTitle(g_StatusIconsMenu, "Status Icons Shown In HUD");
	
	SF2P_GetHudIcon(0, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- 1 UP (Second Life Available)", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED); // ❗ ❓
	
	SF2P_GetHudIcon(1, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- Chased By Boss", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SF2P_GetHudIcon(2, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- Heard By Boss", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SF2P_GetHudIcon(3, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- Healing", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SF2P_GetHudIcon(4, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- Speed Buffed", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SF2P_GetHudIcon(5, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- Stamina Drain", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SF2P_GetHudIcon(6, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- Stamina Recovery", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SF2P_GetHudIcon(7, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- Faster Stamina Recovery", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SF2P_GetHudIcon(8, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- Health Points", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SF2P_GetHudIcon(9, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- Grace Period", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SF2P_GetHudIcon(10, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- Marked For Death", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SF2P_GetHudIcon(11, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- On Fire", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SF2P_GetHudIcon(12, display, sizeof(display));
	FormatEx(display, sizeof(display), "%s- Bleeding", display);
	AddMenuItem(g_StatusIconsMenu, "0", display, ITEMDRAW_DISABLED);
	
	SetMenuExitBackButton(g_StatusIconsMenu, true);
	
	
	//Round Settings menu
	g_RoundSettingsMenu = CreateMenu(SF2P_Round_Settings_Menu);
	SetMenuTitle(g_RoundSettingsMenu, "SF2P Round Settings.")
	AddMenuItem(g_RoundSettingsMenu, "1", "Set Next Special Round.");
	AddMenuItem(g_RoundSettingsMenu, "2", "Activate Special Round.");
	AddMenuItem(g_RoundSettingsMenu, "3", "Toggle Infinite Overrides.");
	AddMenuItem(g_RoundSettingsMenu, "4", "Set Round Difficulty.");
	AddMenuItem(g_RoundSettingsMenu, "5", "Enable/Disable Utilities.");
	SetMenuExitBackButton(g_RoundSettingsMenu, true);
	
	g_SetRoundDifficultyMenu = CreateMenu(SF2P_Set_Round_Difficulty);
	SetMenuTitle(g_SetRoundDifficultyMenu, "Set Round Difficulty.");
	AddMenuItem(g_SetRoundDifficultyMenu, "1", "Normal");
	AddMenuItem(g_SetRoundDifficultyMenu, "2", "Hardcore");
	AddMenuItem(g_SetRoundDifficultyMenu, "3", "Insane");
	AddMenuItem(g_SetRoundDifficultyMenu, "4", "Nightmare");
	AddMenuItem(g_SetRoundDifficultyMenu, "5", "Apollyon");
	SetMenuExitBackButton(g_SetRoundDifficultyMenu, true);
	
}

public Action Cmd_SF2PMainMenu(int client, int args)
{
	if (!SF2_IsRunning())
	{
		PrintToChat(client, "[SF2+] SF2 is not enabled.")
		return Plugin_Handled;
	}
	char arg[4][33];
	if (args > 0)
	{
		if (args > 4)
		{
			CPrintToChat(client, "%s /sf2p commands", SF2PPREFIX);
			return Plugin_Handled;
		}
		for (int i; i < args; i++)
		{
			GetCmdArg(i+1, arg[i], sizeof(arg[]));
		}
		
		// arg[0] = command
		bool print_cmd=true;
		
		if (arg[0][0] == 'r' && SF2P_AreUtilitiesActive()) // /sf2p restock <player> <1,2,3,4> <amount> ADMIN
		{
			if (GetUserFlagBits(client) < ADMFLAG_GENERIC)CPrintToChat(client, "%s You don't have access to this command."), print_cmd = false;
			else if (arg[1][0] != 0) // arg[1] = player
			{
				int target;
				if (!StrEqual(arg[1], "all"))
				{
					target = FindTarget(client, arg[1], true, false);
					if (target == -1)
					{
						Menu_SelectClient(client, "set", true, true);
						return Plugin_Handled;
					}
					if (!SF2PClientCheck(target, false, true))
					{
						CPrintToChat(client, "%s Target player can't be chosen.");
						Menu_SelectClient(client, "set", true, true);
						return Plugin_Handled;
					}
					iClientSelectedFromMenu = target;
				}
				else
				{
					iClientSelectedFromMenu = -2; // -2 = all
				}
				
				if (arg[2][0] != 0) // arg[2] = utility slot
				{
					int util_slot = StringToInt(arg[2]) - 1;
					if (util_slot < 0 || util_slot > 3)
					{
						Menu_SelectUtility(client, "set");
						return Plugin_Handled;
					}
					
					if (arg[3][0] != 0) // arg[3] = amount
					{
						int amt = StringToInt(arg[3]);
						if (amt > 0)
						{
							if (iClientSelectedFromMenu == -2)
							{
								for (int i=1; i<MAXTF2PLAYERS; i++)if (IsValidClient(i))SF2P_SetUtilityCharges(i, util_slot, amt);
							}
							else { SF2P_SetUtilityCharges(target, util_slot, amt); }
							print_cmd = false;
						}
					}
					else 
					{
						char util_slot_str[3];
						char player[64] = "All";
						IntToString(util_slot+1, util_slot_str, 3);
						if (iClientSelectedFromMenu != -2)FormatEx(player, sizeof(player), "%N", target);
						RemoveMenuItem(g_UtilityAmountMenu, 0);
						InsertMenuItem(g_UtilityAmountMenu, 0, util_slot_str, player, ITEMDRAW_DISABLED);
						DisplayMenu(g_UtilityAmountMenu, client, 0);
					}
				}
				else { Menu_SelectUtility(client, "set"); }
			}
			else { Menu_SelectClient(client, "set", true, true); }
			if (print_cmd)CPrintToChat(client, "%s /sf2p <restock,r> <player> <utility slot, 4=all> <amount>", SF2PPREFIX);
		}
		else if (arg[0][0] == 'h') // /sf2p hudpos <x> <y>
		{
			if (arg[1][0] != 0) // arg[1] = x
			{
				float x;
				x = StringToFloat(arg[1]);
				if (x < 0.0 || x > 1.0)
				{
					Menu_SetHudAxis(client, "x");
					return Plugin_Handled;
				}
				
				SF2P_SetClientHudPosition(client, x, SF2P_GetClientHudPosition(client, "y"));
				
				if (arg[2][0] != 0) // arg[2] = y
				{
					float y;
					y = StringToFloat(arg[2]);
					if (y < 0.0 || y > 1.0)Menu_SetHudAxis(client, "y");
					else { SF2P_SetClientHudPosition(client, x, y); }
				}
				else { Menu_SetHudAxis(client, "y"); }
			}
			else { DisplayMenu(g_SelectHudAxisMenu, client, 0); }
			
			CPrintToChat(client, "%s /sf2p hudpos <x> <y>", SF2PPREFIX);
		}
		else if (arg[0][0] == 'c')Menu_CommandsMenu(client); // /sf2p commands
		else if (arg[0][0] == 's') // /sf2p spectate <player, noclip>
		{
			if (SF2PClientCheck(client, false, false))
			{
				CPrintToChat(client, "%s You are in-game.", SF2PPREFIX);
				return Plugin_Handled;
			}
			if (arg[1][0] == 'p')
			{
				int target = FindTarget(client, arg[1], false, false);
				if (target == -1)Menu_SelectClient(client, "spectate", true, false);
				else
				{
					SpectateClient(client, target);
				}
			}
			else if (arg[1][0] == 'n')
			{
				if (SF2_IsClientInGhostMode(client))PerformNoClip(client);
				else { CPrintToChat(client, "%s Not in ghost mode", SF2PPREFIX); }
			}
			else { Menu_SelectClient(client, "spectate", true, false); }
		}
		else if (arg[0][0] == 'd') // /sf2p difficulty <1,2,3,4,5> ADMIN
		{
			if (GetUserFlagBits(client) < ADMFLAG_GENERIC)CPrintToChat(client, "%s You don't have access to this command.");
			else if (arg[1][0] != 0)
			{
				int diff = StringToInt(arg[1]);
				if (diff > 0 && diff < 5)ClientCommand(client, "sm_sf2_set_difficulty %i", diff);
				else { CPrintToChat(client, "%s Invalid difficulty. Must be between 1 and 5.", SF2PPREFIX); }
			}
			else { DisplayMenu(g_SetRoundDifficultyMenu, client, 0); }
		}
		else if (arg[0][0] == 'i')
		{
			int target = FindTarget(client, arg[1], true, false);
			if (target == -1)
			{
				float pos[3];
				float ang[3];
				GetClientEyeAngles(client, ang);
				GetClientEyePosition(client, pos);
				Handle trace = TR_TraceRayFilterEx(pos, ang, MASK_SHOT, RayType_Infinite, RayHitPlayer, client);
				if (TR_DidHit(trace))
				{
					target = TR_GetEntityIndex(trace);
					LogMessage("Hit: %i", target);
					if (target > 0 && target < 33)Menu_PlayerInfo(client, target);
					else
					{
						Menu_SelectClient(client, "info", false, false);
					}
				}
				CloseHandle(trace);
			}
			else
			{
				Menu_PlayerInfo(client, target);
			}
		}
		else if (StringToInt(arg[0]) > 0) // /sf2p <main menu selection>
		{
			Menu fake = new Menu(SF2P_Main_Menu);
			SF2P_Main_Menu(fake, MenuAction_Select, client, StringToInt(arg[0])-1);
			delete fake;
		}
		else
		{
			CPrintToChat(client, "%s /sf2p commands", SF2PPREFIX);
			DisplaySF2PMainMenu(client);
		}
	}
	else
	{
		DisplaySF2PMainMenu(client);
	}
	//CPrintToChat(client, "%s /sf2p %s %s %s %s %i", SF2PPREFIX, arg[0], arg[1], arg[2], arg[3], args);
	return Plugin_Handled;
}

void DisplaySF2PMainMenu(int client)
{
	if (GetMenuItem(g_MainMenu, 6, "7", 2))RemoveMenuItem(g_MainMenu, 6);
	if (GetUserFlagBits(client) >= ADMFLAG_GENERIC)
	{
		if (!GetMenuItem(g_MainMenu, 6, "7", 2))AddMenuItem(g_MainMenu, "7", "Round Settings. ADMIN");
	}
	DisplayMenu(g_MainMenu, client, 0);
}

public SF2P_Main_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:Menu_SelectClient(param1, "info", false, false); // Player Info
			case 1:Menu_UtilityMenu(param1); // In-game Utilities.
			case 2:Menu_EXPMenus(param1); // EXP Menus.
			case 3:DisplayMenu(g_SpectatorMenu, param1, 0); // Spectator Settings.
			case 4: // SF2P HUD Settings.
			{
				DisplayMenu(g_HudSettingsMenu, param1, 0);
				SF2P_SetClientSettingHud(param1, true);
			}
			case 5:Menu_CommandsMenu(param1); // Commands.
			case 6: // Round Settings.
			{
				if (GetUserFlagBits(param1) >= ADMFLAG_GENERIC)DisplayMenu(g_RoundSettingsMenu, param1, 0);
				else { CPrintToChat(param1, "%s You don't have access to this command."); }
			}
		}
		if (GetUserFlagBits(param1) >= ADMFLAG_GENERIC)if(GetMenuItem(g_MainMenu, 6, "7", 2))RemoveMenuItem(g_MainMenu, 6);
	}
	if (action == MenuAction_Cancel)if(GetMenuItem(g_MainMenu, 6, "7", 2))RemoveMenuItem(g_MainMenu, 6); // Round Settings
}


// Global Menu Options

// command = set, spectate, info | ingame - if players need to be in game | round_active - if round additionally needs to be on-going
public void Menu_SelectClient(int client, char[] command, bool ingame, bool round_active)
{
	Menu menu = new Menu(SF2P_Select_Client_Menu);
	//menu.SetTitle("Select player.");
	if (StrEqual(command, "set"))
	{
		menu.SetTitle("Set Player Utility Amount.");
		//menu.AddItem(command, "Set Utility Amount", ITEMDRAW_DISABLED);
		menu.AddItem("-2", "All");
	}
	if (StrEqual(command, "spectate"))
	{
		menu.SetTitle("Spectate Player.");
		//menu.AddItem(command, "Select Player To Spectate", ITEMDRAW_DISABLED);
	}
	if (StrEqual(command, "info"))
	{
		menu.SetTitle("View Player Info.");
		//menu.AddItem(command, "View Player Info.", ITEMDRAW_DISABLED);
	}
	
	char player[64];
	char idx[3];
	IntToString(client, idx, sizeof(idx));
	FormatEx(player, sizeof(player), "%N", client);
	menu.AddItem(idx, player);
	
	for (int i = 1; i < MAXTF2PLAYERS; i++)
	{
		if (IsValidClient(i))
		{
			IntToString(i, idx, sizeof(idx));
			FormatEx(player, sizeof(player), "%N", client);
			
			if (i != client)menu.AddItem(idx, player, (SF2PClientCheck(i, ingame, round_active) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
		}
	}
	
	menu.ExitBackButton = true;
	
	menu.Display(client, MENU_TIME_FOREVER);
}

// Menu_SelectClient(int client, char[] command, bool ingame)
public SF2P_Select_Client_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	char command[16];
	menu.GetTitle(command, 16);
	if (action == MenuAction_Select)
	{
		char player_idx[3];
		menu.GetItem(param2, player_idx, sizeof(player_idx));
		iClientSelectedFromMenu = StringToInt(player_idx);
		
		if (strncmp(command, "set", 3, false)==0) // -> Select Utility Slot Menu
		{
			Menu_SelectUtility(param1, "set");
		}
		if (strncmp(command, "spe", 3, false)==0) // spectate
		{
			SpectateClient(param1, iClientSelectedFromMenu);
		}
		if (strncmp(command, "vie", 3, false)==0) // info
		{
			Menu_PlayerInfo(param1, iClientSelectedFromMenu);
		}
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)
		{
			if (strncmp(command, "set", 3, false)==0)Menu_UtilityMenu(param1);
			if (strncmp(command, "spe", 3, false)==0)DisplayMenu(g_SpectatorMenu, param1, 0);
			if (strncmp(command, "vie", 3, false)==0)DisplaySF2PMainMenu(param1);
		}
	}
	if (action == MenuAction_End)delete menu;
}


// Player Info Menu
void Menu_PlayerInfo(int client, int target)
{
	char title[512];
	char utility[UTILITYNAMESIZE];
	char vm_name[64];
	
	Menu menu = new Menu(SF2P_Player_Info_Menu);
	FormatEx(title, sizeof(title), "Player: %N\n", target);
	FormatEx(title, sizeof(title), "%s \n", title);
	if (SF2P_IsPlayerEXPActive())
	{
		FormatEx(title, sizeof(title), "%sEXP: %i\n", title, SF2P_GetClientEXP(target));
		FormatEx(title, sizeof(title), "%sLevel: %i\n", title, SF2P_GetClientLevel(target));
		FormatEx(title, sizeof(title), "%sPrestige: %i\n", title, SF2P_GetClientPrestige(target));
		FormatEx(title, sizeof(title), "%s \n", title);
	}
	if (SF2P_AreUtilitiesActive())
	{
		if (SF2P_IsClientUtilitySlotUnlocked(target, 0))
		{
			SF2P_GetClientUtilityName(target, 0, utility, sizeof(utility));
			SF2P_GetClientUtilityViewmodelValue(target, 0, "name", vm_name, sizeof(vm_name));
			FormatEx(title, sizeof(title), "%sFirst Utility: %s (%s)\n", title, utility, vm_name);
		}
		
		if (SF2P_IsClientUtilitySlotUnlocked(target, 1))
		{
			SF2P_GetClientUtilityName(target, 1, utility, sizeof(utility));
			SF2P_GetClientUtilityViewmodelValue(target, 1, "name", vm_name, sizeof(vm_name));
			FormatEx(title, sizeof(title), "%sSecond Utility: %s (%s)\n", title, utility, vm_name);
		}
		
		if (SF2P_IsClientUtilitySlotUnlocked(target, 2))
		{
			SF2P_GetClientUtilityName(target, 2, utility, sizeof(utility));
			SF2P_GetClientUtilityViewmodelValue(target, 2, "name", vm_name, sizeof(vm_name));
			FormatEx(title, sizeof(title), "%sThird Utility: %s (%s)\n", title, utility, vm_name);
		}
		
		FormatEx(title, sizeof(title), "%s \n", title);
	}
	
	FormatEx(title, sizeof(title), "%sHudPos: x %0.3f y %0.3f\n", title, SF2P_GetClientHudPosition(target, "x"), SF2P_GetClientHudPosition(target, "y"));
	
	
	char player_idx[3];
	IntToString(target, player_idx, 3);
	
	menu.SetTitle(title);
	menu.AddItem(player_idx, "Refresh.");
	menu.AddItem(player_idx, "Copy Utility.");
	menu.AddItem(player_idx, "Copy Hud Position.");
	menu.AddItem(player_idx, "Miscellaneous info.");
	
	menu.ExitBackButton = true;
	
	menu.Display(client, 0);
}

SF2P_Player_Info_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[3];
		menu.GetItem(param2, info, sizeof(info));
		iClientSelectedFromMenu = StringToInt(info);
		switch (param2)
		{
			case 0:Menu_PlayerInfo(param1, iClientSelectedFromMenu);
			case 1:Menu_SelectUtility(param1, "copy");
			case 2:SF2P_SetClientHudPosition(param1, SF2P_GetClientHudPosition(iClientSelectedFromMenu, "x"), SF2P_GetClientHudPosition(iClientSelectedFromMenu, "y")); 
			case 3:Menu_PlayerInfoMisc(param1, iClientSelectedFromMenu);
		}
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)Menu_SelectClient(param1, "info", false, false);
	}
	if (action == MenuAction_End)delete menu;
}

void Menu_PlayerInfoMisc(int client, int target)
{
	char title[512];
	
	Menu menu = new Menu(SF2P_Player_Info_Misc_Menu);
	FormatEx(title, sizeof(title), "Player: %N\n", target);
	FormatEx(title, sizeof(title), "%s \n", title, target);
	FormatEx(title, sizeof(title), "%sRounds Played: %i\n", title, SF2P_GetClientTotalRoundsPlayed(target));
	FormatEx(title, sizeof(title), "%sMaps Played: %i\n", title, SF2P_GetClientTotalMapsPlayed(target));
	FormatEx(title, sizeof(title), "%sDistance Travelled: %0.1f meters\n", title, SF2P_GetClientTotalTravelDistance(target));
	FormatEx(title, sizeof(title), "%sPages Collected: %i\n", title, SF2P_GetClientTotalPages(target));
	FormatEx(title, sizeof(title), "%sEscapes: %i\n", title, SF2P_GetClientTotalEscapes(target));
	FormatEx(title, sizeof(title), "%sChases: %i\n", title, SF2P_GetClientTotalChaseCount(target));
	FormatEx(title, sizeof(title), "%sDeaths: %i\n", title, SF2P_GetClientDeathCount(target));
	//Damage Taken?
	FormatEx(title, sizeof(title), "%sUtilities Used: %i\n", title, SF2P_GetClientTotalUtilityUses(target));
	FormatEx(title, sizeof(title), "%sChallenges Completed: %i", title, SF2P_GetClientCompletedChallengeCount(target));
	
	menu.SetTitle(title);
	
	char player_idx[3];
	IntToString(target, player_idx, 3);
	
	menu.AddItem(player_idx, "Refresh.");
	menu.AddItem(player_idx, "Main info.");
	menu.AddItem(player_idx, "List Maps Played.");
	menu.Display(client, 0);
}

SF2P_Player_Info_Misc_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[3];
		menu.GetItem(param2, info, sizeof(info));
		iClientSelectedFromMenu = StringToInt(info);
		switch (param2)
		{
			case 0:Menu_PlayerInfoMisc(param1, iClientSelectedFromMenu);
			case 1:Menu_PlayerInfo(param1, iClientSelectedFromMenu);
			case 2:Menu_PlayerInfoMapMisc(param1, iClientSelectedFromMenu);
		}
	}
}

void Menu_PlayerInfoMapMisc(int client, int target)
{
	ArrayList array = new ArrayList(ByteCountToCells(64));
	ReadMapList(array);
	int length = array.Length;
	int[] map_idx = new int[length];
	int[] map_val = new int[length];
	int[] map_blacklist = new int[length];
	int val = -1;
	
	Menu menu = new Menu(SF2P_Player_Info_Map_Misc_Menu);
	menu.SetTitle("%N's played maps.", target);
	
	char ClientAuthID[65], query[PLATFORM_MAX_PATH], Error[64];
	GetClientAuthId(client, AuthId_Steam2, ClientAuthID, sizeof(ClientAuthID));
	Handle SQLquery
	
	char map[64], player_idx[3];
	IntToString(target, player_idx, 3);
	
	for (int i; i<length; i++) // Put all values into array
	{
		array.GetString(i, map, sizeof(map));
		FormatEx(query, sizeof(query), "SELECT %s FROM player_maps WHERE id='%s'", map, ClientAuthID);
		SQLquery = SQL_Query(SQL_Connect("sf2plus", true, Error, sizeof(Error)), query);
		if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))
		{
			map_val[i] = SQL_FetchInt(SQLquery, 0);
		}
	}
	
	for (int i; i<length; i++)
	{
		for (int j; j<length; j++)
		{
			if (map_val[j] > val)
			{
				bool blacklist;
				for (int k; k<i; k++)if (map_blacklist[k] == j)blacklist = true;
				if (!blacklist)
				{
					val = map_val[j];
					map_idx[i] = j;
					map_blacklist[i] = j;
				}
			}
		}
		val = -1;
	}
	for (int i; i<length; i++)
	{
		array.GetString(map_idx[i], map, sizeof(map));
		FormatEx(query, sizeof(query), "SELECT %s FROM player_maps WHERE id='%s'", map, ClientAuthID);
		SQLquery = SQL_Query(SQL_Connect("sf2plus", true, Error, sizeof(Error)), query);
		if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))
		{
			FormatEx(map, sizeof(map), "%s: %i", map, SQL_FetchInt(SQLquery, 0));
			menu.AddItem(player_idx, map, ITEMDRAW_DISABLED);
		}
	}
	/*
	hospice 	3 0
	assault 	0 1
	gate3 		2 2
	mountain 	8 3 
	summercamp 	6 4
	idx = {3, 4, 0, 2, 1} 8 6 3 2 0 
	ADD MAP INDEX TO ARRAY THEN SWITCH HIGHEST TO LOWEST
	*/
	/*
	for (int i; i<length; i++)
	{
		array.GetString(i, map, sizeof(map));
		FormatEx(query, sizeof(query), "SELECT %s FROM player_maps WHERE id='%s'", map, ClientAuthID);
		SQLquery = SQL_Query(SQL_Connect("sf2plus", true, Error, sizeof(Error)), query);
		if (IsValidHandle(SQLquery) && SQL_FetchRow(SQLquery))
		{
			FormatEx(display, sizeof(display), "%s: %i", map, SQL_FetchInt(SQLquery, 0));
			menu.AddItem(player_idx, display, ITEMDRAW_DISABLED);
		}
	}
	*/
	CloseHandle(SQLquery);
	delete array;
	
	menu.AddItem("0", "Refresh.");
	menu.AddItem("1", "Main info.");
	menu.AddItem("2", "Miscellaneous info.");
	menu.Display(client, 0);
}

SF2P_Player_Info_Map_Misc_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[64];
		menu.GetItem(0, info, sizeof(info));
		int target = StringToInt(info);
		menu.GetItem(param2, info, sizeof(info));
		int selection = StringToInt(info);
		switch (selection)
		{
			case 0:Menu_PlayerInfoMapMisc(param1, target);
			case 1:Menu_PlayerInfo(param1, target);
			case 2:Menu_PlayerInfoMisc(param1, target);
		}
		LogMessage("Selection = %i %i", selection, param2);
	}
	if (action == MenuAction_End)delete menu;
}

void Menu_BossInfo(int client, int target)
{
	int ent = SF2_BossIndexToEntIndex(target)
	if (IsValidEntity(ent))
	{
		char title[512];
		char buffer[PLATFORM_MAX_PATH], profile_name[64];
		
		Menu menu = new Menu(SF2P_Boss_Info_Menu);
		SF2_GetBossName(target, profile_name, sizeof(profile_name))
		FormatEx(title, sizeof(title), "Boss Info:\n");
		SF2_GetBossProfileString(profile_name, "name", buffer, sizeof(buffer), profile_name);
		FormatEx(title, sizeof(title), "%sName: %s\n", title, buffer);
		if (SF2_GetBossType(target) ==  SF2BossType_Static)FormatEx(title, sizeof(title), "%sType: Static\n", title, buffer); 
		if (SF2_GetBossType(target) ==  SF2BossType_Statue)FormatEx(title, sizeof(title), "%sType: Statue\n", title, buffer); 
		if (SF2_GetBossType(target) ==  SF2BossType_Chaser)FormatEx(title, sizeof(title), "%sType: Chaser\n", title, buffer); 
		FormatEx(title, sizeof(title), "%s \n", title);
		
		FormatEx(title, sizeof(title), "%sKill On Touch: %s\n", title, (SF2_GetBossProfileNum(profile_name, "kill_radius") ? "Yes." : "No."));
		FormatEx(title, sizeof(title), "%sStatic On Look: %s\n", title, (SF2_GetBossProfileNum(profile_name, "static_on_look") ? "Yes." : "No."));
		FormatEx(title, sizeof(title), "%sStatic On Radius: %s\n", title, (SF2_GetBossProfileNum(profile_name, "static_on_radius") ? "Yes." : "No."));
		FormatEx(title, sizeof(title), "%s \n", title);
		FormatEx(title, sizeof(title), "%sStunnable: %s\n", title, (SF2_IsBossStunnable(target) ? "Yes." : "No."));
		FormatEx(title, sizeof(title), "%sFlashlight Stunnable: %s\n", title, (SF2_GetBossProfileNum(profile_name, "stun_damage_flashlight_enabled") ? "Yes." : "No."));
		if (SF2_IsBossStunnable(target))FormatEx(title, sizeof(title), "%sStun Health: %0.2f\n", title, SF2_GetBossStunHealth(target));
		if (SF2_IsBossStunnable(target))
		{
			//float time = SF2_GetBossNextStunTime(target) - GetGameTime();
			FormatEx(title, sizeof(title), "%s(DISABLED)Stun Cooldown:", title);
		}
		
		FormatEx(title, sizeof(title), "%sAttributes: \n", title);
		bool found;
		for (int i; i<SF2Attribute_Max; i++)
		{
			if (SF2_GetBossAttributeValue(target, i) > 0.0)FormatEx(title, sizeof(title), "%s%s: %0.1f\n", title, g_AttributesList[i], SF2_GetBossAttributeValue(target, i)), found = true;
		}
		if (!found)FormatEx(title, sizeof(title), "%sNone.\n", title);
		
		menu.SetTitle(title);
		IntToString(target, buffer, 5);
		menu.AddItem(buffer, "Refresh.");
		menu.Display(client, 0);
	}
}

SF2P_Boss_Info_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[5];
		menu.GetItem(param2, info, sizeof(info));
		Menu_BossInfo(param1, StringToInt(info));
	}
	if (action == MenuAction_End)delete menu;
}


// Utility Menus

void Menu_UtilityMenu(int client)
{
	
	Menu menu = new Menu(SF2P_Ingame_Utility_Menu);
	menu.SetTitle("SF2P In-game Utilities.");
	menu.AddItem("1", "Change Your Utility.");
	menu.AddItem("2", "Use Your Utility.", (SF2P_AreUtilitiesActive() ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
	menu.AddItem("3", "Change Utility Viewmodel.", (SF2P_AreUtilityViewmodelsActive() ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
	if (GetUserFlagBits(client) >= ADMFLAG_GENERIC)
	{
		menu.AddItem("4", "Set Client Utility Amount.", (SF2P_AreUtilitiesActive() ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
		menu.AddItem("5", "Toggle Utility Use.");
	}
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

public SF2P_Ingame_Utility_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		iClientSelectedFromMenu = param1;
		switch (param2)
		{
			case 0:Menu_SelectUtility(param1, "change"); // Change Your Utility.
			case 1:if (SF2PClientCheck(param1, true, true))Menu_SelectUtility(param1, "use"); // Use Your Utility.
			case 2:Menu_SelectUtility(param1, "select_vm"); // Change Utility Viewmodel.
			case 3:Menu_SelectClient(param1, "set", true, true); // Set Client Utility Amount. ADMIN
			case 4:SF2P_ToggleUtilityUse() // Enable/Disable Utilities. ADMIN
		}
	}
	if (action == MenuAction_Cancel)if (param2 == MenuCancel_ExitBack)DisplaySF2PMainMenu(param1);
	if (action == MenuAction_End)delete menu;
}

// command
// change (utility)
// use (utility)
// select_vm (select viewmodel)
// set (amount)
// copy
public Action Menu_SelectUtility(int client, char[] command)
{
	char buffer_display[32];
	
	Menu menu = new Menu(SF2P_Select_Utility_Menu);
	menu.SetTitle("Select utility.");
	
	char utility[UTILITYNAMESIZE];
	char utilityname[32];
	if (iClientSelectedFromMenu != -2)
	{
		for (int i; i < 3; i++)
		{
			if (SF2P_IsClientUtilitySlotUnlocked(iClientSelectedFromMenu, i))
			{
				SF2P_GetClientUtilityName(iClientSelectedFromMenu, i, utility, sizeof(utility));
				SF2P_GetClientUtilityViewmodelValue(iClientSelectedFromMenu, i, "hudname", utilityname, sizeof(utilityname))
				FormatEx(buffer_display, sizeof(buffer_display), "%s (%s)", utility, utilityname);
				menu.AddItem(command, buffer_display); // Add Target Utility Slots
			}	
		}
	}
	else
	{
		menu.AddItem(command, "First Utility");
		menu.AddItem(command, "Second Utility");
		menu.AddItem(command, "Third Utility");
	}
	
	if (StrEqual(command, "set"))
	{
		menu.AddItem("set", "All");
		char player_idx[3];
		IntToString(iClientSelectedFromMenu, player_idx, sizeof(player_idx));
		char player[64] = "All";
		if (iClientSelectedFromMenu != -2)FormatEx(player, sizeof(player), "%N", iClientSelectedFromMenu);
		menu.AddItem(player_idx, player, ITEMDRAW_DISABLED);
	}
	if (StrEqual(command, "copy"))
	{
		menu.AddItem(command, "All");
		char player_idx[3];
		IntToString(iClientSelectedFromMenu, player_idx, sizeof(player_idx));
		char player[64] = "All";
		FormatEx(player, sizeof(player), "%N", iClientSelectedFromMenu);
		menu.AddItem(player_idx, player, ITEMDRAW_DISABLED);
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
	return Plugin_Handled;
}

// Menu_SelectUtility(int client, char[] command)
public SF2P_Select_Utility_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[32];
		menu.GetItem(param2, info, sizeof(info));
		int util_slot = param2;
		
		if (StrEqual(info, "change")) // Change Utility
		{
			Menu_ChangeUtility(param1, util_slot);
		}
		if (StrEqual(info, "use")) // Use Utility
		{
			SF2P_UseClientUtility(param1, util_slot);
		}
		if (StrEqual(info, "set")) // Set Utility Amount On Client > Select_Utility_Amount_Menu
		{
			char util_slot_str[3];
			IntToString(util_slot + 1, util_slot_str, sizeof(util_slot_str));
			char player_idx[3];
			int position = menu.ItemCount - 1;
			menu.GetItem(position, player_idx, sizeof(player_idx));
			char player[64] = "All";
			int player_int = StringToInt(player_idx);
			if (player_int != -2)FormatEx(player, sizeof(player), "%N", player_int);
			
			RemoveMenuItem(g_UtilityAmountMenu, 0);
			InsertMenuItem(g_UtilityAmountMenu, 0, util_slot_str, player, ITEMDRAW_DISABLED);
			DisplayMenu(g_UtilityAmountMenu, param1, 0);
		}
		if (StrEqual(info, "select_vm"))
		{
			Menu_ChangeUtilityViewmodel(param1, util_slot);
		}
		if (StrEqual(info, "copy"))
		{
			char player_idx[3];
			int position = menu.ItemCount - 1;
			menu.GetItem(position, player_idx, 3);
			if (util_slot == 3)for (int i; i<3; i++)SF2P_SetClientUtility(param1, i, SF2P_GetClientUtility(StringToInt(player_idx), i), false);
			else { SF2P_SetClientUtility(param1, util_slot, SF2P_GetClientUtility(StringToInt(player_idx), util_slot), true); }
		}
	}
	if (action == MenuAction_End)delete menu;
}

// g_UtilityAmountMenu position 0 = reserved
public SF2P_Select_Utility_Amount_Menu(Menu menu, MenuAction action, int param1, int param2) // Set Utility Amount On Client
{
	if (action == MenuAction_Select)
	{
		char util_slot_str[3];
		char player_name[64];
		menu.GetItem(0, util_slot_str, sizeof(util_slot_str), _, player_name, sizeof(player_name));
		int util_slot = StringToInt(util_slot_str) - 1;
		
		char info[3];
		menu.GetItem(param2, info, sizeof(info));
		int amt = StringToInt(info);
		if (amt == 7)
		{
			CPrintToChat(param1, "%s /sf2p <restock, r> <player> <utility slot> <amount>", SF2PPREFIX);
		}
		else
		{
			if (StrEqual(player_name, "All"))
			{
				for (int i=1; i<MAXTF2PLAYERS; i++)
				{
					if (IsValidClient(i))SF2P_SetUtilityCharges(i, util_slot, amt);
				}
			}
			else
			{
				int player_idx = FindTarget(param1, player_name, true, false);
			
				SF2P_SetUtilityCharges(player_idx, util_slot, amt);
			}
		}
	}
}

// util_slot = 0 - First Utility, 1 - Second Utility, 2 - Third Utility
public void Menu_ChangeUtility(int client, int util_slot)
{
	char util_slot_str[5]; // Utility Slot Index To String
	char util_str[32]; // Utility Slot To String
	
	util_slot = (util_slot + 1) * -1;
	IntToString(util_slot, util_slot_str, sizeof(util_slot_str));
	
	if (util_slot == -1)util_str = "First Utility";
	else if (util_slot == -2)util_str = "Second Utility";
	else if (util_slot == -3)util_str = "Third Utility";
	else util_str = "Unknown";
	
	Menu menu = new Menu(SF2P_Change_Utility_Menu);
	menu.SetTitle("Change %s.", util_str);
	
	//menu.AddItem(util_slot_str, util_str, ITEMDRAW_DISABLED);
	
	char idx[3]; // Utility Index To String
	char utility[UTILITYNAMESIZE];
	for (int i; i < SF2P_GetUtilityCount(); i++)
	{
		SF2P_GetUtilityName(i, utility, sizeof(utility));
		IntToString(i, idx, sizeof(idx));
		menu.AddItem(idx, utility);
	}
	
	menu.Display(client, MENU_TIME_FOREVER);
}

// Menu_ChangeUtility(int client, int util_slot)
public SF2P_Change_Utility_Menu(Menu menu, MenuAction action, int param1, int param2) // Change Utility Preferences
{
	if (action == MenuAction_Select)
	{
		char title[9];
		menu.GetTitle(title, sizeof(title));
		LogMessage("title: %s", title);
		int util_slot_int
		
		if (title[7] == 'F')util_slot_int = 1
		if (title[7] == 'S')util_slot_int = 2
		if (title[7] == 'T')util_slot_int = 3
		
		char info[5];
		menu.GetItem(param2, info, sizeof(info));
		int util_idx = StringToInt(info);
		
		char utility[UTILITYNAMESIZE];
		SF2P_GetUtilityName(util_idx, utility, sizeof(utility))
		SF2PChangeClientUtilities(param1, util_slot_int, utility, true);
		
		SF2PClientHudRefresh(param1);
	}
	if (action == MenuAction_End)delete menu;
}

public void Menu_ChangeUtilityViewmodel(int client, int util_slot) // List All Utility Viewmodels For Selection
{
	char utility[UTILITYNAMESIZE];
	char display[32];
	SF2P_GetClientUtilityName(client, util_slot, utility, UTILITYNAMESIZE);
	int util_idx = SF2P_GetUtilityIndex(utility);
	int vm_count = SF2P_GetUtilityViewmodelCount(util_idx);
	Menu menu = new Menu(SF2P_Change_Utility_Viewmodel_Menu);
	menu.SetTitle("Select Preferred Utility Viewmodel.")
	
	if (util_slot == 0)
	{
		FormatEx(display, sizeof(display), "First Utility Slot: %s", utility);
		menu.AddItem("0", display, ITEMDRAW_DISABLED);
	}
	if (util_slot == 1)
	{
		FormatEx(display, sizeof(display), "Second Utility Slot: %s", utility);
		menu.AddItem("1", display, ITEMDRAW_DISABLED);
	}
	if (util_slot == 2)
	{
		FormatEx(display, sizeof(display), "Third Utility Slot: %s", utility);
		menu.AddItem("2", display, ITEMDRAW_DISABLED);
	}
	
	char idx[3];
	char vm_name[PLATFORM_MAX_PATH];
	char equipped_vm_name[PLATFORM_MAX_PATH];
	
	for (int i; i<vm_count; i++)
	{
		IntToString(i, idx, sizeof(idx));
		SF2P_GetUtilityViewmodelValue(util_idx, i, "name", vm_name, sizeof(vm_name));
		SF2P_GetClientUtilityViewmodelValue(client, util_slot, "name", equipped_vm_name, sizeof(equipped_vm_name));
		if (StrEqual(vm_name, equipped_vm_name))menu.AddItem(idx, vm_name, ITEMDRAW_DISABLED);
		else { menu.AddItem(idx, vm_name); }
	}
	menu.Display(client, 0);
}

// Menu_ChangeUtilityViewmodel(int client, int util_slot)
public SF2P_Change_Utility_Viewmodel_Menu(Menu menu, MenuAction action, int param1, int param2) // List All Utility Viewmodels For Selection
{
	if (action == MenuAction_Select)
	{
		char util_slot[3];
		menu.GetItem(0, util_slot, sizeof(util_slot));
		char vm_index[3];
		menu.GetItem(param2, vm_index, sizeof(vm_index));
		
		SF2P_SetClientUtilityViewmodel(param1, StringToInt(util_slot), StringToInt(vm_index));
	}
	if (action == MenuAction_End)delete menu;
}


// EXP Menus

void Menu_EXPMenus(int client)
{
	char buffer[128];
	Menu menu = new Menu(SF2P_EXP_Menus);
	FormatEx(buffer, sizeof(buffer), "EXP Menus.\n", buffer, client);
	FormatEx(buffer, sizeof(buffer), "%sPlayer: %N\n", buffer, client);
	FormatEx(buffer, sizeof(buffer), "%sEXP: %i Level: %i Prestige: %i", buffer, SF2P_GetClientEXP(client), SF2P_GetClientLevel(client), SF2P_GetClientPrestige(client));
	menu.SetTitle(buffer);
	if (!SF2P_CanClientPrestige(client))
	{
		FormatEx(buffer, sizeof(buffer), "Prestige. %i levels left.", SF2P_GetEXPInfo(EXP_PrestigeUp) - SF2P_GetClientLevel(client));
		menu.AddItem("0", buffer, ITEMDRAW_DISABLED);
	}
	else { menu.AddItem("0", "Prestige."); }
	
	menu.AddItem("0", "EXP Notifications.");
	menu.AddItem("0", "EXP Info.");
	menu.AddItem("0", "Level Rewards.");
	menu.AddItem("0", "Prestige Rewards.");
	
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

public SF2P_EXP_Menus(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:if (!SF2P_PrestigeClient(param1))CPrintToChat(param1, "%s You can prestige only in BLU.", SF2PPREFIX);
			case 1:Menu_EXPMenus_Notifications(param1);
			case 2:Menu_EXPMenus_Info(param1);
			case 3:Menu_EXPMenus_Level(param1);
			case 4:Menu_EXPMenus_PrestigeRewards(param1);
		}
	}
	if (action == MenuAction_Cancel)if (param2 == MenuCancel_ExitBack)DisplaySF2PMainMenu(param1);
	if (action == MenuAction_End)delete menu;
}

void Menu_EXPMenus_Notifications(int client)
{
	char buffer[64];
	Menu menu = new Menu(SF2P_EXP_Menus_Notifications);
	menu.SetTitle("Toggle EXP Notifications.");
	FormatEx(buffer, sizeof(buffer), "Page Collect: %s", (SF2P_GetClientChatFlags(client) & CHATFLAGS_EXP_PageCollect ? "Enabled." : "Disabled."));
	menu.AddItem("0", buffer);
	FormatEx(buffer, sizeof(buffer), "Escape: %s", (SF2P_GetClientChatFlags(client) & CHATFLAGS_EXP_Escape ? "Enabled." : "Disabled."));
	menu.AddItem("0", buffer);
	FormatEx(buffer, sizeof(buffer), "Boss Stun: %s", (SF2P_GetClientChatFlags(client) & CHATFLAGS_EXP_BossStun ? "Enabled." : "Disabled."));
	menu.AddItem("0", buffer);
	FormatEx(buffer, sizeof(buffer), "Challenge: %s", (SF2P_GetClientChatFlags(client) & CHATFLAGS_EXP_Challenge ? "Enabled." : "Disabled."));
	menu.AddItem("0", buffer);
	FormatEx(buffer, sizeof(buffer), "Prestige: %s", (SF2P_GetClientChatFlags(client) & CHATFLAGS_EXP_Prestige ? "Enabled." : "Disabled."));
	menu.AddItem("0", buffer);
	
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

SF2P_EXP_Menus_Notifications(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:SF2P_SetClientChatFlags(param1, CHATFLAGS_EXP_PageCollect);
			case 1:SF2P_SetClientChatFlags(param1, CHATFLAGS_EXP_Escape);
			case 2:SF2P_SetClientChatFlags(param1, CHATFLAGS_EXP_BossStun);
			case 3:SF2P_SetClientChatFlags(param1, CHATFLAGS_EXP_Challenge);
			case 4:SF2P_SetClientChatFlags(param1, CHATFLAGS_EXP_Prestige);
		}
		Menu_EXPMenus_Notifications(param1);
	}
	if (action == MenuAction_Cancel)if (param2 == MenuCancel_ExitBack)Menu_EXPMenus(param1);
	if (action == MenuAction_End)delete menu;
}

void Menu_EXPMenus_Info(int client)
{
	Menu menu = new Menu(SF2P_EXP_Menus_Info);
	
	char title[512];
	FormatEx(title, sizeof(title), "EXP Info.\n");
	FormatEx(title, sizeof(title), "%sPlayer: %N\n", title, client);
	FormatEx(title, sizeof(title), "%sEXP: %i Level: %i Prestige: %i\n", title, SF2P_GetClientEXP(client), SF2P_GetClientLevel(client), SF2P_GetClientPrestige(client));
	FormatEx(title, sizeof(title), "%s \n", title);
	FormatEx(title, sizeof(title), "%sPrestige: %i Levels\n", title, SF2P_GetEXPInfo(EXP_PrestigeUp));
	FormatEx(title, sizeof(title), "%sLevel: %i EXP\n", title, SF2P_GetEXPInfo(EXP_LevelUp));
	FormatEx(title, sizeof(title), "%sPage Collection: %i EXP\n", title, SF2P_GetEXPInfo(EXP_PageCollect));
	FormatEx(title, sizeof(title), "%sEscape: %i EXP\n", title, SF2P_GetEXPInfo(EXP_ClientEscape));
	FormatEx(title, sizeof(title), "%sChase Takeover: %i EXP\n", title, SF2P_GetEXPInfo(EXP_ChaseTakeover));
	FormatEx(title, sizeof(title), "%sBoss Stun: %i EXP\n", title, SF2P_GetEXPInfo(EXP_BossStun));
	FormatEx(title, sizeof(title), "%sUsed Dropped Utility: %i EXP\n", title, SF2P_GetEXPInfo(EXP_UsedDroppedUtility));
	menu.SetTitle(title);
	
	menu.AddItem("0", "Level Rewards.");
	menu.AddItem("0", "Prestige Rewards.");
	
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

SF2P_EXP_Menus_Info(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:Menu_EXPMenus_Level(param1);
			case 1:Menu_EXPMenus_PrestigeRewards(param1);
		}
	}
	if (action == MenuAction_Cancel)if (param2 == MenuCancel_ExitBack)Menu_EXPMenus(param1);
	if (action == MenuAction_End)delete menu;
}

void Menu_EXPMenus_Level(int client)
{
	char config[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, config, sizeof(config), CONFIG_PATH);
	KeyValues kv = new KeyValues("SF2Plus");
	if (kv.ImportFromFile(config))
	{
		kv.JumpToKey("EXP");
		kv.JumpToKey("Level Unlocks");
		char buffer[512], name[64];
		Menu menu = new Menu(SF2P_EXP_Menus_Level);
		FormatEx(buffer, sizeof(buffer), "Level Rewards.\n");
		FormatEx(buffer, sizeof(buffer), "%sPlayer: %N\n", buffer, client);
		FormatEx(buffer, sizeof(buffer), "%sEXP: %i Level: %i Prestige: %i\n", buffer, SF2P_GetClientEXP(client), SF2P_GetClientLevel(client), SF2P_GetClientPrestige(client));
		FormatEx(buffer, sizeof(buffer), "%s \n", buffer);
		
		if (kv.GotoFirstSubKey())
		{
			do 
			{
				kv.GetString("name", name, sizeof(name));
				FormatEx(buffer, sizeof(buffer), "%s%s: Level %i\n", buffer, name, kv.GetNum("required"));
			} while (kv.GotoNextKey())
		}
		menu.SetTitle(buffer);
		menu.AddItem("1", "EXP Info.");
		menu.AddItem("2", "Prestige Rewards.");
		
		menu.ExitBackButton = true;
		menu.Display(client, 0);
	}
	delete kv;
}

SF2P_EXP_Menus_Level(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[3];
		menu.GetItem(param2, info, sizeof(info));
		int selection = StringToInt(info);
		switch (selection)
		{
			case 1:Menu_EXPMenus_Info(param1);
			case 2:Menu_EXPMenus_PrestigeRewards(param1);
		}
	}
	if (action == MenuAction_Cancel)if (param2 == MenuCancel_ExitBack)Menu_EXPMenus(param1);
	if (action == MenuAction_End)delete menu;
}

void Menu_EXPMenus_PrestigeRewards(int client)
{
	char title[512];
	Menu menu = new Menu(SF2P_EXP_Menus_PrestigeRewards);
	FormatEx(title, sizeof(title), "Prestige Rewards.\n");
	FormatEx(title, sizeof(title), "%sPlayer: %N\n", title, client);
	FormatEx(title, sizeof(title), "%sEXP: %i Level: %i Prestige: %i\n", title, SF2P_GetClientEXP(client), SF2P_GetClientLevel(client), SF2P_GetClientPrestige(client));
	FormatEx(title, sizeof(title), "%s \n", title);
	FormatEx(title, sizeof(title), "%sSex\n", title);
	menu.SetTitle(title);
	menu.AddItem("1", "EXP Info.");
	menu.AddItem("2", "Level Rewards.");
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

SF2P_EXP_Menus_PrestigeRewards(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[3];
		menu.GetItem(param2, info, sizeof(info));
		int selection = StringToInt(info);
		switch (selection)
		{
			case 1:Menu_EXPMenus_Info(param1);
			case 2:Menu_EXPMenus_Level(param1);
		}
	}
	if (action == MenuAction_Cancel)if (param2 == MenuCancel_ExitBack)Menu_EXPMenus(param1);
	if (action == MenuAction_End)delete menu;
}


// Spectator Settings Menu

public SF2P_Spectator_Settings(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: // Spectate Client.
			{
				if (!SF2PClientCheck(param1, false, false))Menu_SelectClient(param1, "spectate", true, false);
				else { CPrintToChat(param1, "%s Can't spectate. You are in-game.", SF2PPREFIX); }
			}
			case 1: // Enable Noclip When Spectating.
			{
				if (SF2_IsClientInGhostMode(param1))PerformNoClip(param1);
				else { CPrintToChat(param1, "%s Not in ghost mode", SF2PPREFIX); }
			}
		}
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)DisplaySF2PMainMenu(param1);
	}
}

void SpectateClient(int client, int target)
{
	float pos[3];
	GetClientAbsOrigin(target, pos);
	float ang[3];
	GetClientAbsAngles(target, ang);
	if (SF2_IsClientInGhostMode(client))TeleportEntity(client, pos, ang, NULL_VECTOR);
	else
	{
		ClientCommand(client, "sm_slghost");
		TeleportEntity(client, pos, ang, NULL_VECTOR);
	}
}


// Hud Settings Menu

public SF2P_Hud_Settings_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: { Menu_SetHudSections(param1); }// Set Hud Sections
			case 1: { DisplayMenu(g_SelectHudAxisMenu, param1, 0); } // Set Hud Position
			case 2: { DisplayMenu(g_StatusIconsMenu, param1, 0); } // HUD Status Icons
			case 3: // Reload HUD Icons
			{ 
				LoadHudIconsConfig();
				SF2P_SetClientSettingHud(param1, false);
			}
		}
		//SF2P_SetClientSettingHud(param1, true);
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)DisplaySF2PMainMenu(param1);
		SF2P_SetClientSettingHud(param1, false);
	}
}

void Menu_SetHudSections(int client)
{
	Menu menu = new Menu(SF2P_Set_Hud_Sections_Menu);
	menu.SetTitle("Select Hud Sections To Display");
	
	int hudflags = SF2P_GetClientHudFlags(client);
	
	char display[64];
	FormatEx(display, sizeof(display), "HUD: %s", (hudflags & HUDFLAGS_ENABLEHUD ? "Enabled" : "Disabled"));
	menu.AddItem("1", display);
	
	FormatEx(display, sizeof(display), "Status Icons: %s", (hudflags & HUDFLAGS_STATUSICONS ? "Enabled" : "Disabled"));
	menu.AddItem("2", display);
	
	FormatEx(display, sizeof(display), "HP: %s", (hudflags & HUDFLAGS_HPICON ? "Enabled" : "Disabled"));
	menu.AddItem("4", display);
	
	FormatEx(display, sizeof(display), "Round Challenges: %s", (hudflags & HUDFLAGS_CHALLENGES ? "Enabled" : "Disabled"));
	menu.AddItem("8", display);
	
	menu.ExitBackButton = true;
	
	menu.Display(client, 0);
}

public SF2P_Set_Hud_Sections_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[4];
		menu.GetItem(param2, info, sizeof(info));
		SF2P_SetClientHudFlags(param1, StringToInt(info));
		SF2PClientHudRefresh(param1);
		Menu_SetHudSections(param1);
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)DisplayMenu(g_HudSettingsMenu, param1, 0);
		else { SF2P_SetClientSettingHud(param1, false); }
	}
	if (action == MenuAction_End)delete menu;
}

public SF2P_Select_Hud_Axis_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[2];
		menu.GetItem(param2, info, 2);
		Menu_SetHudAxis(param1, info);
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)DisplayMenu(g_HudSettingsMenu, param1, 0);
		else { SF2P_SetClientSettingHud(param1, false); }
	}
}

void Menu_SetHudAxis(int client, char[] axis)
{
	Menu menu = new Menu(SF2P_Set_Hud_Axis_Menu);
	float fl = SF2P_GetClientHudPosition(client, axis);
	menu.SetTitle("Set %s: %0.3f", axis, fl);
	
	menu.AddItem("0.1", "+0.1", ((fl + 0.1 < 1.0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
	menu.AddItem("0.01", "+0.01", ((fl + 0.01 < 1.0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
	menu.AddItem("0.001", "+0.001", ((fl + 0.001 < 1.0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
	
	menu.AddItem("-0.1", "-0.1", ((fl - 0.1 > 0.0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
	menu.AddItem("-0.01", "-0.01", ((fl - 0.01 > 0.0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
	menu.AddItem("-0.001", "-0.001", ((fl - 0.001 > 0.0) ? ITEMDRAW_DEFAULT : ITEMDRAW_DISABLED));
	
	char def[32];
	FormatEx(def, sizeof(def), "Default (%0.3f)", SF2P_GetDefaultHudPosition(axis[0]))
	if (axis[0] == 'x')menu.AddItem("default", def);
	if (axis[0] == 'y')menu.AddItem("default", def);
	
	menu.ExitBackButton = true;
	
	menu.Display(client, 0);
}

public SF2P_Set_Hud_Axis_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char title[6];
		menu.GetTitle(title, sizeof(title))
		char info[8];
		menu.GetItem(param2, info, sizeof(info))
		
		float flx = SF2P_GetClientHudPosition(param1, "x");
		float fly = SF2P_GetClientHudPosition(param1, "y");
		float fl = StringToFloat(info);
		
		if (title[4] == 'x')
		{
			if (StrEqual(info, "default"))
			{
				flx = SF2P_GetDefaultHudPosition("x");
				fl = 0.0;
			}
			SF2P_SetClientHudPosition(param1, flx + fl, fly);
			Menu_SetHudAxis(param1, "x");
		}
		if (title[4] == 'y')
		{
			if (StrEqual(info, "default"))
			{
				fly = SF2P_GetDefaultHudPosition("y");
				fl = 0.0;
			}
			SF2P_SetClientHudPosition(param1, flx, fly + fl);
			Menu_SetHudAxis(param1, "y");
		}
		SF2PClientHudRefresh(param1);
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)DisplayMenu(g_SelectHudAxisMenu, param1, 0);
		else { SF2P_SetClientSettingHud(param1, false); }
	}
	if (action == MenuAction_End)delete menu;
}

public SF2P_Status_Icons_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)DisplayMenu(g_HudSettingsMenu, param1, 0);
		else { SF2P_SetClientSettingHud(param1, false); }
	}
}


// Commands Menus

void Menu_CommandsMenu(int client)
{
	Menu menu = new Menu(SF2P_Commands_Menu);
	menu.SetTitle("SF2P Commands.");
	menu.AddItem("1", "Print All Commands In Console.");
	menu.AddItem("2", "Entity Info.");
	menu.AddItem("3", "Utilities.");
	menu.AddItem("4", "Hud Position.");
	if (GetUserFlagBits(client) >= ADMFLAG_GENERIC)
	{
		menu.AddItem("5", "Restock. ADMIN");
		menu.AddItem("6", "Round Difficulty. ADMIN");
	}
	menu.ExitBackButton = true;
	menu.Display(client, 0);
}

public SF2P_Commands_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0: // Print All Commands In Console.
			{
				CPrintToChat(param1, "%s Console Commands Printed.", SF2PPREFIX);
				PrintConsoleCommandsToClient(param1);
			}
			case 1: // Entity Info.
			{
				Menu_SelectClient(param1, "info", false, false);
				CPrintToChat(param1, "%s sf2p info - Show targeted player or boss' available info.", SF2PPREFIX);
				CPrintToChat(param1, "%s /sf2p info <player>(or aim at your target).", SF2PPREFIX);
			}
			case 2: // Utilities.
			{
				char utility[3][UTILITYNAMESIZE];
				for (int i; i<3; i++)
				{
					SF2P_GetClientUtilityName(param1, i, utility[i], UTILITYNAMESIZE);
				}
				CPrintToChat(param1, "%s sm_sf2putil1 - Use First Utility ({green}%s{default})", SF2PPREFIX, utility[0]);
				CPrintToChat(param1, "%s sm_sf2putil2 - Use Second Utility ({green}%s{default})", SF2PPREFIX, utility[1]);
				CPrintToChat(param1, "%s sm_sf2putil3 - Use Third Utility ({green}%s{default})", SF2PPREFIX, utility[2]);
				CPrintToChat(param1, "%s Use ; to separate commands.", SF2PPREFIX);
				CPrintToChat(param1, "%s Example: bind 1 \"slot1;sm_sf2putil1\"", SF2PPREFIX);
			}
			case 3: // Hud Position.
			{
				CPrintToChat(param1, "%s sf2p hudpos - Customize SF2Plus Hud Position. Accepted values between 0.0 and 1.0. -1 for default.", SF2PPREFIX);
				CPrintToChat(param1, "%s /sf2p hudpos <x> <y>.", SF2PPREFIX);
				DisplayMenu(g_SelectHudAxisMenu, param1, 0);
				SF2P_SetClientSettingHud(param1, true);
			}
			case 4: // Restock.
			{
				CPrintToChat(param1, "%s sf2p restock - ADMIN ONLY, Restock a player's (or everyone's) utility amount.", SF2PPREFIX);
				CPrintToChat(param1, "%s /sf2p <restock, r> <player, all> <utility slot, 4=all> <amount>.", SF2PPREFIX);
				Menu_SelectClient(param1, "set", true, true);
			}
			case 5: // Round Difficulty.
			{
				CPrintToChat(param1, "%s sf2p difficulty - ADMIN ONLY, Change current round's difficulty.", SF2PPREFIX);
				CPrintToChat(param1, "%s /sf2p difficulty <1,2,3,4,5>.", SF2PPREFIX);
				DisplayMenu(g_SetRoundDifficultyMenu, param1, 0);
			}
		}
	}
	if (action == MenuAction_End)delete menu;
}

void PrintConsoleCommandsToClient(int client)
{
	PrintToConsole(client, "[SF2+] ----------------------------------------------------------------------");
	PrintToConsole(client, "[SF2+] Commands can be used through console with a \"sm_\" prefix or in chat with a \"/\" prefix.");
	PrintToConsole(client, "[SF2+] sf2p - Show SF2 Plus Main Menu.");
	PrintToConsole(client, "[SF2+] sf2putil1 - Use Utility In Your First Slot.");
	PrintToConsole(client, "[SF2+] sf2putil2 - Use Utility In Your Second Slot.");
	PrintToConsole(client, "[SF2+] sf2putil3 - Use Utility In Your Third Slot.");
	PrintToConsole(client, "[SF2+]");
	PrintToConsole(client, "[SF2+] Chat commands are only available by first inputting \"sf2p\" command before and then their full command or only first letter.");
	//PrintToConsole(client, "[SF2+] The command structure usually goes by \"sf2p <command> <player> <utility slot> <amount>\"");
	PrintToConsole(client, "[SF2+] sf2p <number> - Display a menu through SF2P Main Menu Order. Example: 1 is player info, 2 is utility menu.");
	PrintToConsole(client, "[SF2+] /sf2p <number>.");
	PrintToConsole(client, "[SF2+]");
	PrintToConsole(client, "[SF2+] sf2p info - Show targeted player or boss' available info.");
	PrintToConsole(client, "[SF2+] /sf2p info <player>(or aim at your target).");
	PrintToConsole(client, "[SF2+]");
	PrintToConsole(client, "[SF2+] sf2p commands - Instantly show the commands menu.");
	PrintToConsole(client, "[SF2+] /sf2p commands.");
	PrintToConsole(client, "[SF2+]");
	PrintToConsole(client, "[SF2+] sf2p spectate - Spectate player or enable noclip in spectator mode.");
	PrintToConsole(client, "[SF2+] /sf2p spectate <player, noclip>.");
	PrintToConsole(client, "[SF2+]");
	PrintToConsole(client, "[SF2+] sf2p hudpos - Customize SF2Plus Hud Position. Accepted values between 0.0 and 1.0. -1 for default");
	PrintToConsole(client, "[SF2+] /sf2p hudpos <x> <y>.");
	if (GetUserFlagBits(client) >= ADMFLAG_GENERIC)
	{
		PrintToConsole(client, "[SF2+]");
		PrintToConsole(client, "[SF2+] sf2p restock - ADMIN ONLY, Restock a player's (or everyone's) utility amount.");
		PrintToConsole(client, "[SF2+] /sf2p restock <player, all> <utility slot, 4=all> <amount>.");
		PrintToConsole(client, "[SF2+]");
		PrintToConsole(client, "[SF2+] sf2p difficulty - ADMIN ONLY, Change current round's difficulty.");
		PrintToConsole(client, "[SF2+] /sf2p difficulty <1,2,3,4,5>.");
	}
	PrintToConsole(client, "[SF2+] ----------------------------------------------------------------------");
}

// Round Settings Menu

public SF2P_Round_Settings_Menu(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:Menu_SetNextSpecialRound(param1); // Set Next Special Round
			case 1:ClientCommand(param1, "sm_cvar sf2_specialround_forceenable 1"); // Activate Special Round
			case 2:Menu_ToggleInfiniteOverrides(param1); // Toggle Infinite Overrides
			case 3:DisplayMenu(g_SetRoundDifficultyMenu, param1, 0); // Set Round Difficulty
			case 4:SF2P_ToggleUtilityUse(); // Enable/Disable Utilities
		}
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)DisplaySF2PMainMenu(param1);
	}
}

public Action Menu_SetNextSpecialRound(int client)
{
	int special_count = 0;
	char rounds_config[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, rounds_config, sizeof(rounds_config), "configs/sf2/specialrounds.cfg");
	if (!FileExists(rounds_config))
	{
		CPrintToChat(client, "%s Couldn't get special rounds.", SF2PPREFIX);
	}
	else
	{
		KeyValues kv = new KeyValues("Special Rounds");
		if (!kv.ImportFromFile(rounds_config))
		{
			LogMessage("[SF2+] Can't parse keyvalues.");
			CPrintToChat(client, "%s Can't get special rounds.", SF2PPREFIX);
			return Plugin_Handled;
		}
		char parentbuffer[64];
		if (!kv.GotoFirstSubKey())
		{
			CPrintToChat(client, "%s Can't get special rounds.", SF2PPREFIX);
			return Plugin_Handled;
		}
		
		char info[3];
		char round[PLATFORM_MAX_PATH];
		Menu menu = new Menu(SF2P_Select_Special_Round);
		menu.SetTitle("Select Special Round.");
		
		do
		{
			kv.GetSectionName(parentbuffer, sizeof(parentbuffer));
			if (!StrEqual(parentbuffer, "jokes"))
			{
				special_count++;
				IntToString(special_count, info, sizeof(info));
				kv.GetString("display_text_hud", round, sizeof(round));
				menu.AddItem(info, round);
			}
		} while (kv.GotoNextKey())
			
		delete kv;
		menu.ExitBackButton = true;
		menu.Display(client, 0);
	}
	return Plugin_Continue;
}

public SF2P_Select_Special_Round(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[3];
		menu.GetItem(param2, info, sizeof(info));
		ClientCommand(param1, "sm_sf2_force_special_round %s", info);
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)DisplayMenu(g_RoundSettingsMenu, param1, 0);
	}
	if (action == MenuAction_End)delete menu;
}

void Menu_ToggleInfiniteOverrides(int client)
{
	char convar[PLATFORM_MAX_PATH];
	char info[3];
	Menu menu = new Menu(SF2P_Toggle_Infinite_Overrides)
	menu.SetTitle("Toggle Infinite Overrides.")
	
	IntToString(GetConVarInt(FindConVar("sf2_player_infinite_blink_override")), info, sizeof(info));
	FormatEx(convar, sizeof(convar), "Infinite Blink: %s", (GetConVarInt(FindConVar("sf2_player_infinite_blink_override")) == -1 ? "OFF" : "ON"));
	menu.AddItem(info, convar);
	
	IntToString(GetConVarInt(FindConVar("sf2_player_infinite_flashlight_override")), info, sizeof(info));
	FormatEx(convar, sizeof(convar), "Infinite Flashlight: %s", (GetConVarInt(FindConVar("sf2_player_infinite_flashlight_override")) == -1 ? "OFF" : "ON"));
	menu.AddItem(info, convar);
	
	IntToString(GetConVarInt(FindConVar("sf2_player_infinite_sprint_override")), info, sizeof(info));
	FormatEx(convar, sizeof(convar), "Infinite Stamina: %s", (GetConVarInt(FindConVar("sf2_player_infinite_sprint_override")) == -1 ? "OFF" : "ON"));
	menu.AddItem(info, convar);
	
	menu.ExitBackButton = true;
	menu.Display(client, 0)
}

public SF2P_Toggle_Infinite_Overrides(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		ConVar convar;
		char info[3];
		menu.GetItem(param2, info, sizeof(info));
		int val = StringToInt(info) * -1;
		switch (param2)
		{
			case 0: // Infinite Blink
			{
				convar = FindConVar("sf2_player_infinite_blink_override");
				SetConVarInt(convar, val);
				CPrintToChatAll("%s Infinite Blink Is %s.", SF2PPREFIX, (val == 1 ? "{green}Enabled{default}" : "{red}Disabled{default}"));
			}
			case 1: // Infinite Flashlight
			{
				convar = FindConVar("sf2_player_infinite_flashlight_override");
				SetConVarInt(convar, val);
				CPrintToChatAll("%s Infinite Flashlight Is %s.", SF2PPREFIX, (val == 1 ? "{green}Enabled{default}" : "{red}Disabled{default}"));
			}
			case 2: // Infinite Sprint
			{
				convar = FindConVar("sf2_player_infinite_sprint_override");
				SetConVarInt(convar, val);
				CPrintToChatAll("%s Infinite Sprint Is %s.", SF2PPREFIX, (val == 1 ? "{green}Enabled{default}" : "{red}Disabled{default}"));
			}
		}
		Menu_ToggleInfiniteOverrides(param1);
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)DisplayMenu(g_RoundSettingsMenu, param1, 0);
	}
	if (action == MenuAction_End)delete menu;
}

public SF2P_Set_Round_Difficulty(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_Select)
	{
		char info[3];
		menu.GetItem(param2, info, sizeof(info));
		ClientCommand(param1, "sm_sf2_set_difficulty %s", info);
	}
	if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack)DisplayMenu(g_RoundSettingsMenu, param1, 0);
	}
}
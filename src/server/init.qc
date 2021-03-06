/*
	gmapn_init.qc

	Copyright (C) 2007 Mark Olsen

	This program is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

	See the GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to:

		Free Software Foundation, Inc.
		59 Temple Place - Suite 330
		Boston, MA	02111-1307, USA

*/

/**
 * @file gmapn_init.qc
 * @author Mark Olsen
 * @brief All of the algorithms called by worldspawn at some point.
 *
 * Loads the appropriate configs for the current game_mode and sets up the environment vars.
 */

/**
 * @brief Loads rules, checks server extensions and populates the map list.
 */
void gmapn_init()
{
	string hostname, geo_city, geo_state, geo_country, modename;

	dbgprintln("=== gmapn_init() ===");
	gmapn_apply_gamemode(gmapn_gamemodefromstring(getkey(game_mode)));

	// to stop servers from idling in matchless mode
	if (serverflags & SV_MATCHLESS)
		gmapn_reset_starttimer();

	gmapn_detectserver();

	localcmd("serverinfo fpd 206\n");
	localcmd("serverinfo maxfps 77\n");
	localcmd("serverinfo pm_ktjump 1\n");
	localcmd("serverinfo status standby\n");

	// Version of progs info
	localcmd("serverinfo cspversion ", VERSION, "\n");
	localcmd("serverinfo cspdate ", DATE, "\n");

	// Configure hostname

	hostname = getkey(info_hostname);
	geo_city = getkey(info_city);
	geo_country = getkey(info_country);
	geo_state = getkey(info_state);
	if (getkey(game_lockrules) > 0)
		modename = gmapn_gamemodefullname(game_mode);
	else
		modename = "various";

	localcmd("serverinfo hostname \"");

	if (hostname != "")
	{
		localcmd(hostname);
		localcmd(" ");
		localcmd(modename);
	}
	else
	{
		hostname = infokey(world, "hostname");
		localcmd(hostname);
	}

	if (geo_city != "" || geo_state != "" || geo_country != "")
	{
		localcmd(" - ");

		if (geo_city != "")
		{
			localcmd(geo_city);

			if (geo_state != "" || geo_country != "")
			{
				localcmd(", ");
			}
		}

		if (geo_state != "")
		{
			localcmd(geo_state);

			if (geo_country != "")
			{
				localcmd(", ");
			}
		}

		if (geo_country != "")
		{
			localcmd(geo_country);
		}

	}

	localcmd(" - ");
	localcmd(NAME);
	localcmd("\"\n");

	if (gmapn_qsg_has_ext_csqc)
	{
		globalstat(STAT_MATCHSTARTTIME,		EV_FLOAT, "gmapn_matchstarttimems");	//dimman wanted match start times, this should be compatible with his fork of ezquake.
		clientstat(STAT_READY,			EV_FLOAT, ready);
		globalstat(STAT_GAMEMODE,		EV_FLOAT, "game_mode");
		globalstat(STAT_CURROUND,		EV_FLOAT, "gmapn_roundnum");
		globalstat(STAT_MAXROUND,		EV_FLOAT, "gmapn_roundslimit");
		globalstat(STAT_TEAMSCORES_RED,		EV_FLOAT, "gmapn_teamscores_red");
		globalstat(STAT_TEAMSCORES_BLUE,	EV_FLOAT, "gmapn_teamscores_blue");
	}

	//match stats
	gmapn_sql_init();

	gmapn_latency_check_init();

	vote_in_progress = FALSE;

	if (getkey(runtests) == 1)
	{
		entity test;

		test = spawn();
		test.think = gmapn_init_test;
		test.nextthink = time + 0.1;
	}

	// Remember coop/skill variables so if they changed somehow we would have to reload map.
	initial_coop = coop;
	initial_skill = skill;
};

void gmapn_detectserver()
{
	//make sure the extension checking mechanism exists
	if (!cvar("pr_checkextension"))
	{
		bprint(PRINT_HIGH, "Unsupported server\n");
		error("Unsupported server - lacks pr_checkextension\n");
	}

	//make sure our mandatory extensions exist.
	if (!checkextension("FRIK_FILE") && !checkextension("ZQ_QC_STRINGS"))
		error("Unsupported server - lacks both FRIK_FILE and ZQ_QC_STRINGS\n");
	if (!checkextension("KRIMZON_SV_PARSECLIENTCOMMAND"))
		error("Unsupported server - lacks KRIMZON_SV_PARSECLIENTCOMMAND\n");
	if (!checkextension("FTE_ISBACKBUFFERED"))
		error("Unsupported server - lacks FTE_ISBACKBUFFERED\n");

	//check for optional extensions.
	gmapn_qsg_has_fte_solid_ladder = checkextension("FTE_SOLID_LADDER");
	gmapn_qsg_has_dp_qc_fs_search = checkextension("DP_QC_FS_SEARCH");
	gmapn_qsg_has_fte_sql = checkextension("FTE_SQL");
	gmapn_qsg_has_zq_vwep = checkextension("ZQ_VWEP");
	gmapn_qsg_has_ext_csqc = checkextension("EXT_CSQC");

	if (checkextension("DP_QC_WHICHPACK"))
		if not (whichpack("progs/vwplayer.mdl"))
		{
			print("progs/vwplayer.mdl not found, disabling vweps\n");
			gmapn_qsg_has_zq_vwep = FALSE;
		}
};

void gmapn_init_test()
{
	game_mode_t rnd = floor(random()*GM_MODES);
	setkey("game_botskill", "3");
	gmapn_apply_gamemode(rnd);
	gmapn_game_beginpregamecountdown(10);
}

void gmapn_readconfig()
{
	filestream f;
	string s;
	float args;

	f = fopen("entities.conf", FILE_READ);
	if (f < 0)
		return;
	while ((s = fgets(f)))
	{
		args = tokenize(s);
		if (args >= 2)
		{
			entity e = spawn();
			e.classname = argv(0);
			e.origin_x = stof(argv(1));
			e.origin_y = stof(argv(2));
			e.origin_z = stof(argv(3));
			setorigin(e, e.origin);
		}
	}
	fclose(f);
}

//called at map start or config change.
void gmapn_init_entities()
{
	dbgprintln("=== gmapn_init_entities() ===");
	if (getkey(powerups_enabled) == 0)
	{
		gmapn_powerups_disable();
	}
	else
	{
		gmapn_powerups_enable();
	}

	gmapn_powerups_setitems();

	ctf_enableflags(game_mode == GM_CTF);
}

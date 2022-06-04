/*
    gmapn_config.qc

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
        Boston, MA  02111-1307, USA

*/

void gmapn_config_load()
{
	dbgprintln("=== gmapn_config_load() ===");

	string g_game_mode = getkey(game_mode);

	parseconfig("cfgs/default.conf");
	parseconfig("cfgs/rules/%s.conf", g_game_mode);
	parseconfig("cfgs/maps/%s/default.conf", mapname);
	parseconfig("cfgs/maps/%s/%s.conf", mapname, g_game_mode);

	if (framecount == 1)
		gmapn_update_defaults_start();
	
	localcmd("serverinfo config ", g_game_mode, "\n");

	gmapn_serverstate = gmapn_serverstate_prewar;

	gmapn_init_entities();
	gmapn_update_defaults_rules();
};

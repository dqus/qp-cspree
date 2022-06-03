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

/* Ugly, ugly, ugly */
float gmapn_config_version;

void gmapn_config_update()
{
	if (stof(infokey(world, "gmapn_config_version")) == gmapn_config_version)
	{
		gmapn_init_entities();
		gmapn_update_defaults_rules();
		remove(self);
		return;
	}

	self.nextthink = time + 0.001;
};

void gmapn_config_load()
{
	dbgprintln("=== gmapn_config_load() ===");

	string g_game_mode = getkey(game_mode);

	parseconfig("cfgs/default.conf");
	parseconfig("cfgs/rules/%s.conf", g_game_mode);
	parseconfig("cfgs/maps/%s/default.conf", mapname);
	parseconfig("cfgs/maps/%s/%s.conf", mapname, g_game_mode);

	if (gmapn_config_version == 0)
		gmapn_update_defaults_start();
	
	gmapn_config_version+= 1;
	if (gmapn_config_version == 65536)
		gmapn_config_version = 0;

	localcmd("localinfo gmapn_config_version ", ftos(gmapn_config_version), "\n");
	localcmd("serverinfo config ", g_game_mode, "\n");

	gmapn_serverstate = gmapn_serverstate_prewar;

	/* We need to wait for the server to actually load the config... */
	entity e = spawn();
	e.nextthink = time + 0.001;
	e.think = gmapn_config_update;
	e.health = gmapn_config_version;
};

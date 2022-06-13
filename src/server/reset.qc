/*
	gmapn_reset.qc

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

void gmapn_reset_think()
{
	serverflags = 0;
	localcmd("exec cfgs/reset.conf\n");

	remove(self);
}

void gmapn_reset_starttimer()
{
	dbgprintln("=== gmapn_reset_starttimer ===");

	// Remove previous timer.
	gmapn_reset_stoptimer();

	// Start new timer.
	entity e = spawn();
	e.classname = "gmapn_reset";
	e.solid = SOLID_NOT;
	e.nextthink = time + 5;
	e.think = gmapn_reset_think;
}

void gmapn_reset_stoptimer()
{
	dbgprintln("=== gmapn_reset_stoptimer ===");

	for (entity e = world; (e = find(e, classname, "gmapn_reset"));)
		remove(e);
}

void gmapn_reset_entities(string classnamestr)
{
	entity oself = self;
	entity e;

	e = find(world, classname, classnamestr);

	while (e)
	{
		if (classnamestr == "func_button")
		{
			self = e;
			button_reset();
			self = oself;
		}
		else if (classnamestr == "func_door")
		{
			self = e;
			door_reset();
			self = oself;
		}
		else if (classnamestr == "func_door_secret")
		{
			self = e;
			door_secret_reset();
			self = oself;
		}
		else if (classnamestr == "func_plat")
		{
			self = e;
			plat_reset();
			self = oself;
		}
		else if (classnamestr == "func_train")
		{
			self = e;
			train_reset();
			self = oself;
		}
		else if (classnamestr == "trigger_counter"
			  || classnamestr == "trigger_once"
			  || classnamestr == "trigger_onlyregistered")
		{
			self = e;
			trigger_reset();
			self = oself;
		}
		else if (classnamestr == "info_controlpoint")
		{
			self = e;
			controlpoint_reset();
			self = oself;
		}
		else // items
		{
			e.model = e.mdl;
			e.nextthink = 0;
			e.solid = SOLID_TRIGGER;
		}

		e = find(e, classname, classnamestr);
	}
}

void reset_all_entities()
{
	gmapn_reset_entities("func_button");
	gmapn_reset_entities("func_door");
	gmapn_reset_entities("func_door_secret");
	gmapn_reset_entities("func_plat");
	gmapn_reset_entities("func_train");
	gmapn_reset_entities("trigger_counter");
	gmapn_reset_entities("trigger_once");
	gmapn_reset_entities("trigger_onlyregistered");
	gmapn_reset_entities("info_controlpoint");
//	gmapn_reset_entities("item_flag");
}

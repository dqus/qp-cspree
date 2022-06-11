/*
	aliasstuffer.qc

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

static string stufflist[] =
{
	"alias toggleready cmd toggleready\n",
	"alias ready cmd ready\n",
	"alias break cmd break\n",
	"alias notready cmd notready\n",
	"alias forcestart cmd forcestart\n",
	"alias dmm1 cmd dmm 1\n",
	"alias dmm2 cmd dmm 2\n",
	"alias dmm3 cmd dmm 3\n",
	"alias dmm4 cmd dmm 4\n",
	"alias powerups cmd powerups\n",
	"alias ffa cmd ffa\n",
	"alias coop_mode cmd coop\n", // Conflicts with coop cvar so have to call it coop_mode.
	"alias 1on1 cmd 1on1\n",
	"alias 2on2 cmd 2on2\n",
	"alias 3on3 cmd 3on3\n",
	"alias 4on4 cmd 4on4\n",
	"alias time3 cmd time 3\n",
	"alias time5 cmd time 5\n",
	"alias time10 cmd time 10\n",
	"alias rpickup cmd rpickup\n",
	"alias yes cmd yes\n",
	"alias agree cmd agree\n",
	"alias no cmd no\n",
	"alias disagree cmd disagree\n",
	"alias abstain cmd abstain\n",
	"alias dontcare cmd dontcare\n",
	"alias rulemaker cmd rulemaker\n",
	"alias rndmap cmd rndmap\n",
	"alias shownick cmd shownick\n",
};

static void aliasstuffer_think()
{
	entity player = self.owner;

	while (!isbackbuffered(player))
	{
		if (self.cnt < stufflist.length)
			stuffcmd(player, stufflist[self.cnt]);
		else
		{
			string name = gmapn_map_pool_readidx(self.cnt - stufflist.length);
			if (name != "")
			{
				string aliascmd = sprintf("alias %s_map cmd votemap %s\n", name, name);
				stuffcmd(player, aliascmd);
			}
			else
			{
				sprint(player, PRINT_MEDIUM, "Aliases uploaded.\n");
				remove(self);
				return;
			}
		}

		self.cnt += 1;
	}

	self.nextthink = time + 0.01;
}

void aliasstuffer_start(entity player)
{
	entity e = spawn();
	e.netname = player.netname;
	e.classname = "aliasstuffer";
	e.solid = SOLID_NOT;
	e.nextthink = time + 0.2; /* Give a little room for the client to really connect, avoids weird delays when connecting. */
	e.think = aliasstuffer_think;
	e.owner = player;
	e.cnt = 0;
}

void aliasstuffer_stop(entity player)
{
	for (entity e = world; (e = find(e, classname, "aliasstuffer"));)
	{
		if (e.owner == player)
		{
			remove(e);
			return;
		}
	}
}

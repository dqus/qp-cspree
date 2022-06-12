//matchless modes persist over map changes until enough people 'break'.
float gmapn_ismatchless(game_mode_t m)
{
	switch(m)
	{
	case GM_FFA:			return TRUE;
	case GM_KING:			return TRUE;
	case GM_DA:			return TRUE;
	case GM_COOP:			return TRUE;
	case GM_DUEL:			return FALSE;
	case GM_HEADHUNTER:		return TRUE;
	case GM_TDEATHMATCH:		return FALSE;
	case GM_2ON2:			return FALSE;
	case GM_LASTMANSTANDING:	return FALSE;
	case GM_FREEZETAG:		return FALSE;
	case GM_DOMINATION:		return FALSE;
	case GM_ROVER:			return FALSE;
	case GM_CTF:			return FALSE;
	case GM_1FCTF:			return FALSE;
	case GM_HIDENSEEK:		return FALSE;
	case GM_COUNTERQUAKE:		return TRUE;

	default:			return FALSE;
	}
};

string gmapn_gamemodetostring(game_mode_t m)
{
	switch(m)
	{
	default:
	case GM_FFA:			return "ffa";
	case GM_KING:			return "king";
	case GM_DA:			return "darena";
	case GM_COOP:			return "coop";
	case GM_HEADHUNTER:		return "headhunt";
	case GM_DUEL:			return "duel";
	case GM_TDEATHMATCH:		return "tdm";
	case GM_2ON2:			return "2on2";
	case GM_LASTMANSTANDING:	return "last";
	case GM_FREEZETAG:		return "ftag";
	case GM_DOMINATION:		return "dom";
	case GM_ROVER:			return "rover";
	case GM_CTF:			return "ctf";
	case GM_1FCTF:			return "1fctf";
	case GM_HIDENSEEK:		return "hide";
	case GM_COUNTERQUAKE:		return "csqw";
	}
};
string gmapn_gamemodefullname(game_mode_t m)
{
	switch(m)
	{
	default:
	case GM_FFA:			return _("Free-For-All");
	case GM_KING:			return _("Kill The King");
	case GM_DA:			return _("Duel Arena");
	case GM_COOP:			return _("Co-Operative");
	case GM_HEADHUNTER:		return _("Head Hunters");
	case GM_DUEL:			return _("Duel");
	case GM_TDEATHMATCH:		return _("Team Deathmatch");
	case GM_2ON2:			return _("2-on-2");
	case GM_LASTMANSTANDING:	return _("Last Man Standing");
	case GM_FREEZETAG:		return _("Freezetag");
	case GM_DOMINATION:		return _("Domination");
	case GM_ROVER:			return _("Rover");
	case GM_CTF:			return _("Capture The Flag");
	case GM_1FCTF:			return _("One-Flag CTF");
	case GM_HIDENSEEK:		return _("Hide & Seek");
	case GM_COUNTERQUAKE:		return _("Counter Quake");
	}
};

game_mode_t gmapn_gamemodefromstring(string m)
{
	if (m == "ffa")
		return GM_FFA;
	else if (m == "deathmatch" || m == "tdm" || m == "4on4")
		return GM_TDEATHMATCH;
	else if (m == "2on2")
		return GM_2ON2;
	else if (m == "darena" || m == "da")
		return GM_DA;
	else if (m == "coop")
		return GM_COOP;
	else if (m == "duel")
		return GM_DUEL;
	else if (m == "king")
		return GM_KING;
	else if (m == "lastmanstanding" || m == "lms")
		return GM_LASTMANSTANDING;
	else if (m == "freezetag" || m == "ft" || m == "freeze" || m == "ftag")
		return GM_FREEZETAG;
	else if (m == "headhunter" || m == "hh" || m == "headhunt")
		return GM_HEADHUNTER;
	else if (m == "domination" || m == "dom")
		return GM_DOMINATION;
	else if (m == "rover")
		return GM_ROVER;
	else if (m == "ctf")
		return GM_CTF;
	else if (m == "1fctf")
		return GM_1FCTF;
	else if (m == "hide")
		return GM_HIDENSEEK;
	else if (m == "csqw")
		return GM_COUNTERQUAKE;
	else
		return GM_FFA;
};

float gmapn_gamemode_rounds(game_mode_t m)
{
	if (m == GM_DA)
		return getkey(game_rounds);
	if (m == GM_LASTMANSTANDING || m == GM_FREEZETAG || m == GM_ROVER)
		return getkey(game_rounds);
	if (m == GM_HIDENSEEK)
		return getkey(game_rounds);
	return 1;	//most game types don't do rounds.
};


float gmapn_gamemode_allowed(game_mode_t mode)
{
	float modes = tokenize(getkey(allowedmodes));

	if (!modes)	//if none listed, anything goes.
	{
		if (mode == GM_1FCTF)
			return FALSE; //NYI
		return TRUE;
	}

	while (modes --> 0)
	{
		if (mode == gmapn_gamemodefromstring(argv(modes)))
			return TRUE;
	}
	return FALSE;
}

string gmapn_nextmap()
{
	float maps = tokenize(getkey(maprotation));
	string nextmaprotate = argv(0);

	if (!maps)
		return __NULL__;

	for (int i = 0; i < maps - 1; i++)
	{
		if (mapname == argv(i))
		{
			nextmaprotate = argv(i + 1);
		}
	}

	return nextmaprotate;
}

void update_basic_rules()
{
//	fraglimit = cvar("fraglimit")
	timelimit = cvar("timelimit")*60;
	deathmatch = cvar("deathmatch");
	teamplay = cvar("teamplay");
	coop = cvar("coop");
	skill = coop ? cvar("skill") : 0; // Skill is valid only in coop mode.
}

void gmapn_updatemaxclients()
{
	float lim = getkey(game_clientlimit);
	float max;
	//enforce maxclients primarily so that extra players can't join mid-game and ruin it.
	if (teamplay && coop == 0)
		max = getkey(maxteamsize) * 2;
	else
		max = getkey(maxplayers);
	max = bound(0, max, lim);
	cvar_setf("maxclients", max);
	cvar_setf("maxspectators", lim - max);
};

void gmapn_apply_gamemode(game_mode_t newmode)
{
	setkey("game_mode", gmapn_gamemodetostring(newmode));
	game_mode = newmode;

	gmapn_config_load();
};

void gmapn_evaluategamemaster()
{
	entity o = gmapn_gamemaster;

	gmapn_gamemaster = world;
	if (gmapn_serverstate < gmapn_serverstate_playing)
	{
		//first look for VIPs.
		for (entity e = world; (e = find(e, classname, "player")); )
		{
			if (clienttype(e) == CLIENTTYPE_BOT)
				continue;	//bots don't count...
			if (stof(infokey(e, "*VIP")))
			{
				if (!gmapn_gamemaster || e.connectedtime < gmapn_gamemaster.connectedtime)
					gmapn_gamemaster = e;
			}
		}

		//have another look when there were no VIPs.
		if (!gmapn_gamemaster && !getkey(game_lockrules))
		for (entity e = world; (e = find(e, classname, "player")); )
		{
			if (clienttype(e) == CLIENTTYPE_BOT)
				continue;	//bots don't count...
			if (!gmapn_gamemaster || e.connectedtime < gmapn_gamemaster.connectedtime)
				gmapn_gamemaster = e;
		}
	}

	if (gmapn_gamemaster != world && gmapn_gamemaster != o)
	{
		bprint(PRINT_HIGH, gmapn_gamemaster.netname, " is now the rule maker\n");
	}
};
float gmapn_isgamemaster(entity e)
{
	if (stof(infokey(e, "*VIP")))
		return TRUE;
	if (e == gmapn_gamemaster)
		return TRUE;
	if (getkey(game_lockrules) < 0)
		return 2;	//anyone can change the rules
	return FALSE;
};

static entity findliveteamplayer(entity last, entity ignore, string theteam)
{
	while ((last = find(last, classname, "player")))
	{
		if (last == ignore)
			continue;
		if (last.deadflag)
			continue;
		if (last.teamname == theteam)
			return last;	//this one will do
	}
	return world;	//no more
}
void gmapn_checklastplayer(entity ignore, string theteam)
{
	if (!teamplay)
		return;
	entity player = findliveteamplayer(world, ignore, theteam);
	if (!player)
		return;	//err, that WAS the last player!
	if (findliveteamplayer(player, ignore, theteam))
		return;	//there's another player, no worries

	// FIXME: nonexistent sound file
	//stuffcmd(player, "play \"announcer/lastman.wav\"\n");
	if (random() < 0.5)
		centerprint(player, "You're our only hope!");
	else
		centerprint(player, "Your team is counting on you!");
};

void(entity killer, entity victim, float delta) gmapn_scorefrags =
{
	if (game_mode == GM_DA)
	{
		return; // points are dealt on round end
	}
	if (game_mode == GM_COUNTERQUAKE)
	{
		if (victim.classname == "player")
		{
			bprint(PRINT_HIGH, victim.netname, " accepts the defeat of ", killer.netname, "s superiority!\n");
			delta = 100;
			gmapn_game_end();
		}
		else if (victim.model == "progs/ogre.mdl")
		{
			bprint(PRINT_HIGH, killer.netname, " kills off an ogre\n");
		}
		else if (victim.model == "progs/soldier.mdl")
		{
			bprint(PRINT_HIGH, killer.netname, " snipes a soldier down\n");
		}
		else if (victim.model == "progs/tarbaby.mdl")
		{
			bprint(PRINT_HIGH, "A tarbaby explodes from ", killer.netname, "s weaponry\n");
		}
		else if (victim.model == "progs/dog.mdl")
		{
			bprint(PRINT_HIGH, killer.netname, " is not nice to dogs\n");
		}
		else if (victim.model == "progs/enforcer.mdl")
		{
			bprint(PRINT_HIGH, "An enforcer tastes ", killer.netname, "s shots\n");
		}
		else if (victim.model == "progs/knight.mdl")
		{
			bprint(PRINT_HIGH, killer.netname, " wins a duel with a knight\n");
		}
		else if (victim.model == "progs/dknight.mdl")
		{
			bprint(PRINT_HIGH, killer.netname, " exorcises a death knight\n");
		}
		else if (victim.model == "progs/shambler.mdl")
		{
			bprint(PRINT_HIGH, "A shambler loses his ground to ", killer.netname, "s fatal wish");
		}
		else if (victim.model == "progs/fish.mdl")
		{
			bprint(PRINT_HIGH, killer.netname, " puts down a fish\n");
		}
		else if (victim.model == "progs/vore.mdl")
		{
			bprint(PRINT_HIGH, killer.netname, " loads a vore full of holes\n");
		}
		else
		{
			bprint(PRINT_HIGH, killer.netname, " kills a monster\n");
		}
	}
	if (game_mode == GM_ROVER)
	{	//victims are moved over to the killer's team
		bprint(PRINT_HIGH, victim.netname, " was killed by ", killer.netname, "\n");
		victim.teamname = killer.teamname;
		forceinfokey(victim, "team", victim.teamname);
		forceinfokey(victim, "topcolor", infokey(killer, "topcolor"));
		forceinfokey(victim, "bottomcolor", infokey(killer, "bottomcolor"));
	}
	if (game_mode == GM_KING)
	{
		if (!gmapn_monarchofthemound || (victim == gmapn_monarchofthemound && killer != gmapn_monarchofthemound))
		{
			if (gmapn_monarchofthemound)
			{
				client_setteamandcolour(gmapn_monarchofthemound, "pleb", 3, 3);
			}
			else
			{
				//now that we actually have different teams, we need to enable teamplay so that skin forcing works.
				cvar_setf("teamplay", teamplay = 1);
			}
			gmapn_monarchofthemound = killer;
			bprint(PRINT_HIGH, gmapn_monarchofthemound.netname, " is now the king!\n");
			client_setteamandcolour(gmapn_monarchofthemound, "king", 13, 13);
		}
		//only the king is allowed to get points from killing.
		if (killer != gmapn_monarchofthemound)
			return;
	}
	if (game_mode == GM_DOMINATION)
	{
		//extra points if the killer is near a control point.
		for (entity e = world; (e = find(e, classname, "info_controlpoint")); )
		{
			if (vlen(e.origin - killer.origin) < 256)
			{
				if (e.teamname == killer.teamname)
				{
					// FIXME: nonexistent sound file
					//stuffcmd(killer, "play \"announcer/defence.wav\"\n");
					centerprint(killer, "Defended!");
					delta += getkey(domination_defense);
					break;
				}
			}
		}
	}
	if (game_mode == GM_CTF)
	{
		//extra points if the killer is near a control point.
		for (entity e = world; (e = find(e, classname, "info_controlpoint")); )
		{
			if (vlen(e.origin - killer.origin) < 256)
			{
				if (e.teamname == killer.teamname)
				{
					// FIXME: nonexistent sound file
					//stuffcmd(killer, "play \"announcer/defence.wav\"\n");
					centerprint(killer, "Defended!");
					delta += getkey(domination_defense);
					break;
				}
			}
		}
	}
	if (game_mode == GM_HEADHUNTER)
		return;	//headhunter only awards frags when you capture the heads.
/*	if (game_mode == GM_HIDENSEEK)
	{
		if (victim.teamname == gmapn_team_hiders && victim.found == FALSE && killer != world && killer != victim)
		{
			self.found = TRUE;
			client_setsemispectator(self);
		}

		return; //only award frags if all hidden players are killed
		}*/
	if (game_mode == GM_LASTMANSTANDING || game_mode == GM_FREEZETAG)
	{
		gmapn_checklastplayer(victim, victim.teamname);
		return;	//LMS awards points per-round rather than per-kill, so no points are rewarded here. FT is basically LMS+respawns
	}
	killer.frags += delta;
	if (teamplay)
		gmapn_game_score_teampoint(killer.teamname, delta);
};
void(entity victim, float delta) gmapn_suicidefrags =
{
	if (game_mode == GM_DA)
	{
		return;
	}

	if (game_mode == GM_LASTMANSTANDING || game_mode == GM_FREEZETAG)
	{
		gmapn_checklastplayer(victim, victim.teamname);
		return;	//LMS doesn't care too much about idiots
	}
	victim.frags += delta;
	if (teamplay)
		gmapn_game_score_teampoint(victim.teamname, delta);
};
void(entity killer, entity victim, float delta) gmapn_teamkillfrags =
{
	if (game_mode == GM_LASTMANSTANDING || game_mode == GM_FREEZETAG)
	{
		gmapn_checklastplayer(victim, victim.teamname);
		return;	//should probably disable team damage.
	}
	killer.frags += delta;
	if (teamplay)
		gmapn_game_score_teampoint(killer.teamname, delta);
};



//domination!
void controlpoint_reset()
{
	self.model = 0;
	self.effects = 0;
	self.teamname = 0;	//this is the name of the team that owns the controlpoint
	self.colormod = '0 0 0';

	self.pflags = 0;
	self.light_lev = 0;
	self.color = '0 0 0';
};

void controlpoint_updateindicator(entity cp)
{
	entity i, p = world;
	//find the player closest to capturing us
	i = find(world, classname, "player");
	do
	{
		if (i.thawplayer == cp)
			if (!p || i.thawtime < i.thawtime)
				p = i;
		i = find(i, classname, "player");
	} while(i);

	//and change our timer indicator to match
	if (!p)
		stuffcmdflags(p, STUFFCMD_BROADCAST, sprintf("//it -1 %g %g %g 64 0x0 \"CP\" %i\n", rint(cp.origin_x), rint(cp.origin_y), rint(cp.origin_z + cp.mins_z), cp));
	else if (p.teamname == "red")
		stuffcmdflags(p, STUFFCMD_BROADCAST, sprintf("//it %g/%g %g %g %g 64 0xff0000 \"CP\" %i\n", p.thawtime-time, getkey(domination_capturetime), rint(cp.origin_x), rint(cp.origin_y), rint(cp.origin_z + cp.mins_z), cp));
	else if (p.teamname == "blue")
		stuffcmdflags(p, STUFFCMD_BROADCAST, sprintf("//it %g/%g %g %g %g 64 0x0000ff \"CP\" %i\n", p.thawtime-time, getkey(domination_capturetime), rint(cp.origin_x), rint(cp.origin_y), rint(cp.origin_z + cp.mins_z), cp));
	else
		stuffcmdflags(p, STUFFCMD_BROADCAST, sprintf("//it %g/%g %g %g %g 64 0x808080 \"CP\" %i\n", p.thawtime-time, getkey(domination_capturetime), rint(cp.origin_x), rint(cp.origin_y), rint(cp.origin_z + cp.mins_z), cp));
}
static void controlpoint_touch()
{
	if (other.classname != "player" || other.deadflag || gmapn_serverstate != gmapn_serverstate_playing)
		return;
	if (other.thawplayer)	//player is already busy
		return;
	if (other.teamname == self.teamname)	//the guy's team already owns the point.
		return;
	other.thawplayer = self;
	other.thawtime = time + getkey(domination_capturetime);

	controlpoint_updateindicator(self);
};
static void controlpoint_think()
{
	entity p;
	for (p = world; (p = find(p, classname, "player")); )
	{
		if (p.teamname == self.teamname)
			p.frags += 1;
	}

	self.nextthink = time + getkey(domination_pointinterval);
};
/*QUAKEED stuff*/
void info_controlpoint()
{
	if (!self.mdl)
	{
		self.mdl = "progs/v_spike.mdl";	//vore-ball
		self.avelocity = '300 300 300';
		self.scale = 3;
	}
	precache_model(self.mdl);

	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;	//not active yet.
	self.touch = controlpoint_touch;
	self.think = controlpoint_think;

	//drop it to the floor, then make it big.
	//biased towards mins_z so that the control points are a little more visible relative to any items that may be at the same spot
	setsize(self, '-16 -16 -56', '16 16 0');
	droptofloor();
	setsize(self, '-128 -128 -56', '128 128 0');
};
//spawns a control point from an existing map entity, in the case of none provided by the map
float domination_legacycontrolpoints(string existing)
{
	float points = 0;

	entity e;
	for (e = world; (e = find(e, classname, existing)); )
	{
		self = spawn();
		self.origin = e.origin + [0,0,e.mins_z + 56];
		self.classname = "info_controlpoint";
		info_controlpoint();
		points += 1;
	}
	return points;
};
void domination_startup()
{
	float points = 0;
	for (self = world; (self = find(self, classname, "info_controlpoint")); )
		points += 1;

	if (!points)
	{
		if (points < 3)
			points += domination_legacycontrolpoints("item_sigil");
		if (points < 3)
			points += domination_legacycontrolpoints("item_key1");
		if (points < 3)
			points += domination_legacycontrolpoints("item_key2");
		if (points < 3)
			points += domination_legacycontrolpoints("weapon_rocketlauncher");
		if (points < 3)
			points += domination_legacycontrolpoints("weapon_lightning");
		if (points < 3)
			points += domination_legacycontrolpoints("weapon_grenadelauncher");
		if (points < 3)
			points += domination_legacycontrolpoints("item_armorInv");
		if (points < 3)
			points += domination_legacycontrolpoints("item_armor2");
		if (points < 3)
			points += domination_legacycontrolpoints("item_armor1");
		if (!points)
			points += domination_legacycontrolpoints("info_player_start");
		if (!points)
			points += domination_legacycontrolpoints("info_player_deathmatch");
	}

	for (self = world; (self = find(self, classname, "info_controlpoint")); )
	{
		self.solid = SOLID_TRIGGER;
		setmodel(self, self.mdl);
		setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
		self.effects = EF_NODEPTHTEST|EF_FULLBRIGHT;
	}
};

static void headhunter_altar_touch()
{
	if (other.classname != "player" || other.deadflag || gmapn_serverstate != gmapn_serverstate_playing)
		return;
	if (other.ammo_heads)
	{
		bprint(PRINT_MEDIUM, other.netname, " recovers ", ftos(other.ammo_heads), " heads.\n");
		centerprint(other, "The gods thank you for your contribution of\n", redify(ftos(other.ammo_heads)), " heads");

		//give them 3 seconds of pent for each head
		other.effects = EF_RED;
		other.items |= IT_PENT;
		if (other.pent_finished < time)
			other.pent_finished = time;
		other.pent_finished += 3.0*other.ammo_heads;

		//and frags, and stuff
		other.frags += other.ammo_heads;
		other.ammo_heads = 0;
	}
};
/*QUAKEED stuff*/
void info_altar()
{
	if (!self.mdl)
	{
		self.mdl = "progs/v_spike.mdl";	//vore-ball
		self.avelocity = '300 300 300';
		self.scale = 3;
		self.effects = EF_FULLBRIGHT;
	}
	precache_model(self.mdl);

	self.movetype = MOVETYPE_NOCLIP;
	self.solid = SOLID_NOT;	//not active yet.
	self.touch = headhunter_altar_touch;

	//drop it to the floor, then make it big.
	//biased towards mins_z so that the control points are a little more visible relative to any items that may be at the same spot
	setsize(self, '-16 -16 -56', '16 16 0');
	droptofloor();
	setsize(self, '-128 -128 -56', '128 128 0');
};
//spawns a control point from an existing map entity, in the case of none provided by the map
float headhunter_legacyaltar(string existing)
{
	float points = 0;

	entity e = find(world, classname, existing);
	if (e)
	{
		self = spawn();
		self.origin = e.origin + [0,0,e.mins_z + 56];
		self.classname = "info_altar";
		self.effects = EF_RED;
		info_altar();
		points += 1;
	}
	return points;
};
void headhunter_startup()
{
	float points = 0;
	for (self = world; (self = find(self, classname, "info_altar")); )
		points += 1;

	if (!points)
	{
		if (!points)
			points += headhunter_legacyaltar("item_artifact_super_damage");
		if (!points)
			points += headhunter_legacyaltar("item_sigil");
		if (!points)
			points += headhunter_legacyaltar("item_key1");
		if (!points)
			points += headhunter_legacyaltar("item_key2");
		if (!points)
			points += headhunter_legacyaltar("weapon_rocketlauncher");
		if (!points)
			points += headhunter_legacyaltar("weapon_lightning");
		if (!points)
			points += headhunter_legacyaltar("weapon_grenadelauncher");
		if (!points)
			points += headhunter_legacyaltar("item_armorInv");
		if (!points)
			points += headhunter_legacyaltar("item_armor2");
		if (!points)
			points += headhunter_legacyaltar("item_armor1");
		if (!points)
			points += headhunter_legacyaltar("info_player_start");
		if (!points)
			points += headhunter_legacyaltar("info_player_deathmatch");
	}

	for (self = world; (self = find(self, classname, "info_altar")); )
	{
		self.solid = SOLID_TRIGGER;
		setmodel(self, self.mdl);
		setsize(self, VEC_HULL_MIN, VEC_HULL_MAX);
	}
};

void gmapn_rules_autojointeam()
{
	if (coop)	//just force their team to coop in coop.
		forceinfokey(self, "team", (self.teamname = "coop"));
	else if (self.teamname == "red")
		client_setteamandcolour(self, "red", 4, 4);
	else if (self.teamname == "blue")
		client_setteamandcolour(self, "blue", 13, 13);
	else
	{
		//count existing players
		float red = 0, blue = 0;
		for(entity e = world; (e = find(e, classname, "player")); )
		{
			if (e.teamname == "red")
				red += 1;
			else if (e.teamname == "blue")
				blue += 1;
		}

		//try not to favour either team
		if (red == blue)
		{
			if (random() < 0.5)
				red += 1;
			else
				blue += 1;
		}

		//and put them on the smaller team
		if (red < blue)
			client_setteamandcolour(self, "red", 4, 4);
		else
			client_setteamandcolour(self, "blue", 13, 13);
	}
};

void gmapn_rules_cliententered()
{
	if (clienttype(self) == CLIENTTYPE_BOT)
		self.ready = TRUE; // bots are always ready on join

	client_spawn(FALSE);
}

//new client just joined the server
void gmapn_rules_handleconnect()
{
	// 0 = join instantly as a player
	// 1 = join as a spectator
	// 2 = join as a player spectator
	float dospec = 0;
	float totalplayers;
	entity p;

	//in case they're a VIP really
	gmapn_evaluategamemaster();

	totalplayers = -1; // subtract the client that is about to join
	p = find(world, classname, "player");
	while (p)
	{
		totalplayers++;
		p = find(p, classname, "player");
	}

	// if not spectating initialize some server settings
	if (self.classname == "player" && (serverflags & SV_MATCHLESS) && gmapn_ismatchless(game_mode))
	{
		// ready up on matchless games automatically
		self.ready = TRUE;

		if (game_mode == GM_HEADHUNTER)
		{
			stuffcmd(self, "cl_gibFilter 0\n");
			sprint(self, PRINT_HIGH, redify("The server turns your gib filter off\n"));
		}

		// start the next game when the first player connects
		if (totalplayers == 0)
		{
			gmapn_reset_stoptimer();
			gmapn_game_start();
			return;
		}
	}

	if (gmapn_serverstate != gmapn_serverstate_playing)
		return;

	switch(game_mode)
	{
	case GM_KING:	//joining players become plebs
		client_setteamandcolour(self, "pleb", 3, 3);
		break;
	case GM_ROVER:	//don't need to bother with teams. that'll be handled when spec-players are pulled in for the new round.
		dospec = 1;
		break;
	case GM_DA:	//new players should be spectators rather than instantly a challenger. because it would be unfair
		dospec = 1;
		break;
	case GM_DUEL:	//standard game modes allows players to join a running game if it needs player
	case GM_2ON2:
	case GM_TDEATHMATCH:
		if (totalplayers >= getkey(maxplayers))
			dospec = 1; // all player slots full
		break;
	case GM_HIDENSEEK:
	case GM_DOMINATION:
	case GM_CTF:
	case GM_FREEZETAG:
	case GM_LASTMANSTANDING:
		dospec = 1;
	case GM_COOP:
		gmapn_rules_autojointeam();
		break;
	}

	if (dospec != 0 && clienttype(self) != CLIENTTYPE_BOT)
	{
		if (dospec == 1)
			client_setspectator(self);
		else
			forceinfokey(self, "*spectator", "3");

		sprint(self, PRINT_HIGH, "Game is already in progress\n");
	}

	self.matchtime = time;
}

static void display_countdown()
{
	string str = sprintf("%s starts in %s\n\n\n\n\n",
		redify(gmapn_gamemodefullname(game_mode)),
		goldnmbr(ftos(ceil((gmapn_matchstarttimems/1000) - time))));
	centerprint(self, str);
}

float gmapn_display_rules()
{
	if (time < 1)	//can do weird things on loading screens
		return TRUE;

	if (gmapn_serverstate == gmapn_serverstate_countdown)
	{
		display_countdown();
		return FALSE;
	}
	else if (gmapn_serverstate == gmapn_serverstate_playing)
	{
		if (game_mode == GM_FREEZETAG)
		{
			if (self.viewingrules < time && self.deadflag)
			{
				self.viewingrules = time + 1;
				centerprint(self, "YOU ARE FROZEN!\nHARASS A TEAM MATE TO HELP YOU!");
			}
		}
		else if (game_mode == GM_HEADHUNTER)
		{
			if (self.viewingrules < time && self.ammo_heads > 0)
			{
				self.viewingrules = time + 1;
				if (self.ammo_heads > 1)
					centerprint(self, sprintf("YOU HAVE %s HEADS!\nBRING THEM TO THE ALTAR!", goldnmbr(ftos(self.ammo_heads))));
				else
					centerprint(self, sprintf("YOU HAVE %s HEAD!\nBRING IT TO THE ALTAR!", goldnmbr(ftos(self.ammo_heads))));
			}
		}
		return FALSE;
	}

	return FALSE;
}

//
// Q-Operative mode aka QP.
//

static int total_spots; // Total amount of monster spawn spots.

typedef struct
{
	string classname;		// monsters class name.
	void() spawn;			// spawn func.
	int hp_for_kill;		// how much hp player gains for killing such monster.
	int armor_for_kill;		// how much armor player gains for killing such monster.
//	bool boss_able;			// able to be a boss.
} monster_t;

monster_t monsters[] =
{
	{
		.classname = "monster_ogre",
		.spawn = monster_ogre,
		.hp_for_kill = 3,
		.armor_for_kill = 2
	},
	{
		.classname = "monster_demon1",
		.spawn = monster_demon1,
		.hp_for_kill = 4,
		.armor_for_kill = 4
	},
	{
		.classname = "monster_shambler",
		.spawn = monster_shambler,
		.hp_for_kill = 10,
		.armor_for_kill = 8
	},
	{
		.classname = "monster_knight",
		.spawn = monster_knight,
		.hp_for_kill = 1,
		.armor_for_kill = 1
	},
	{
		.classname = "monster_army",
		.spawn = monster_army,
		.hp_for_kill = 1,
		.armor_for_kill = 1
	},
	{
		.classname = "monster_wizard",
		.spawn = monster_wizard,
		.hp_for_kill = 2,
		.armor_for_kill = 2
	},
	{
		.classname = "monster_dog",
		.spawn = monster_dog,
		.hp_for_kill = 1,
		.armor_for_kill = 1
	},
	{
		.classname = "monster_zombie",
		.spawn = monster_zombie,
		.hp_for_kill = 1,
		.armor_for_kill = 1
	},
	{
		.classname = "monster_tarbaby",
		.spawn = monster_tarbaby,
		.hp_for_kill = 4,
		.armor_for_kill = 4
	},
	{
		.classname = "monster_hell_knight",
		.spawn = monster_hell_knight,
		.hp_for_kill = 4,
		.armor_for_kill = 3
	},
	{
		.classname = "monster_shalrath",
		.spawn = monster_shalrath,
		.hp_for_kill = 6,
		.armor_for_kill = 6
	},
	{
		.classname = "monster_enforcer",
		.spawn = monster_enforcer,
		.hp_for_kill = 2,
		.armor_for_kill = 1
	},
};

int monsters_alive_count(void)
{
	int count = 0;
	for (entity mon = nextent(world); mon != world; mon = nextent(mon))
	{
		if((mon.flags & FL_MONSTER) && mon.health > 0)
		{
			count++;
		}
	}
	return count;
}

bool remove_monster_if_location_occupied(void)
{
	if (game_mode == GM_QP)
	{
		setorigin(self, self.origin);

		if (is_location_occupied(self, self.origin))
		{
			remove(self);
			return true;
		}
	}
	return false;
}

static void monster_fade(void)
{
	self.alpha -= 0.025;
	if (self.alpha <= 0) {
		remove(self);
		return;
	}
	self.nextthink = time + 0.05;
}

// Init body fading in qp mode.
void monster_init_fade(void)
{
	if (game_mode == GM_QP)
	{
		return;
	}
	self.alpha = 1;
	self.think = monster_fade;
	self.nextthink = time + 2 + random() * 3;
}

void info_monster_start(void)
{
	total_spots++;
}

static entity spawn_one_monster_do(monster_t mon, entity spot)
{
	entity oself = self; // Remember self.
	entity spawned = spawn();
	self = spawned; // Changed self.
	self.angles = spot.angles;
	self.origin = spot.origin;
	mon.spawn();
	self = oself; // Restore self.
	if (wasfreed(spawned))
	{
		return __NULL__; // Seems spawned entity was removed.
	}
	return spawned;
}

static entity spawn_one_monster(void)
{
	int idx = 0;
	// Find random spawn point.
	entity spot = find_idx(classname, "info_monster_start", i_rnd(0, total_spots - 1));
	// Can't find.
	if (!spot)
	{
		return __NULL__;
	}
	// Randomly select monster.
	monster_t mon = monsters[i_rnd(0, monsters.length - 1)];
	// Spawn monster.
	return spawn_one_monster_do(mon, spot);
}

static void precache_monsters(void)
{
	for (int i = 0; i < monsters.length; i++) {
		monster_t mon = monsters[i];
		safe_remove(spawn_one_monster_do(mon, world));
	}
}

static void spawn_monsters(void)
{
	// Precache all monsters at frame 2.
	if (framecount == 2)
	{
		precache_monsters();
	}
	// Check various conditions if we are ready for spawning monsters.
	if (time < 3 || framecount < 100 || monsters_alive_count() >= 10)
	{
		return;
	}
	// Attempt to spawn one monster.
	// We trying to do it few times in row since we can fail because spawn point is busy or something.
	for (int i = 0; i < 30; i++)
	{
		if (spawn_one_monster())
		{
			return;
		}
	}
}

void qp_think(void)
{
	if (game_mode != GM_QP || total_spots == 0)
	{
		return; // qp mode disabled or map does not support it.
	}

	spawn_monsters();
}

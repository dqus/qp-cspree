// FIXME: move gibs to csqc.

vector VelocityForDamage(float dmg)
{
	vector v;

	v_x = 100 * crandom();
	v_y = 100 * crandom();
	v_z = 200 + 100 * random();

	if (dmg > -50) {
		v = v * 0.7;
	} else if (dmg > -200) {
		v = v * 2;
	} else {
		v = v * 10;
	}

	return v;
}

static void ThrowGibEx(string gibname, float dmg, bool head)
{
	entity gib = spawn();
	gib.movetype = MOVETYPE_BOUNCE;
	gib.solid = SOLID_NOT;
	setmodel(gib, gibname);
	setorigin(gib, self.origin); // <<< Using self!!!
	setsize(gib, '0 0 0', '0 0 0');
	gib.velocity = VelocityForDamage(dmg);
	gib.avelocity = randomv(head ? '0 600 0' : '600 600 600');

	monster_init_fade(gib);
}

void ThrowGib(string gibname, float dmg)
{
	ThrowGibEx(gibname, dmg, false);
}

void ThrowHead(string gibname, float dmg)
{
	// Spawn gib.
	ThrowGibEx(gibname, dmg, true);
	// Remove self.
	self.think = SUB_Remove;
	self.nextthink = time;
}

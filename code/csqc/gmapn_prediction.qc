float gmapn_playerpredraw()
{
    if (self.entnum == player_localentnum)
	{
        addentity(self);
        gmapn_playerorigin = self.origin;
        gmapn_playervelocity = self.velocity;
    }
	else
	{
        addentity(self);
    }
	
    return PREDRAW_NEXT;
}

float gmapn_playerupdate(float isnew)
{
	// Prepare rollback
	vector oldorigin = self.origin;
	vector oldvelocity = self.velocity;
	float oldmoveflags = self.pmove_flags;

	if (isnew == TRUE)
	{
        self.classname = "player";
        self.solid = SOLID_SLIDEBOX;
        self.predraw = gmapn_playerpredraw;
        self.drawmask = MASK_ENGINE;
        setmodel(self, "progs/player.mdl");
    }
	
	// Apply physics for every single input-frame that has not yet been
	// acknowledged by the server (servercommandframe = last acknowledged frame)
	for (float i = servercommandframe + 1; i <= clientcommandframe; i++)
	{
		getinputstate(i);
		runstandardplayerphysics(self);
		touchtriggers(self);
	}

	// Smooth stair stepping, this has to be done manually!
	gmapn_playeroldorigin = gmapn_playerorigin;

	if ((self.flags & FL_ONGROUND) && (self.origin_z - gmapn_playeroldorigin_z > 0))
	{
		gmapn_playeroldorigin_z += frametime * 150;

		if (gmapn_playeroldorigin_z > self.origin_z)
		{
			gmapn_playeroldorigin_z = self.origin_z;
		}
		if (self.origin_z - gmapn_playeroldorigin_z > 18)
		{
			gmapn_playeroldorigin_z = self.origin_z - 18;
		}
		gmapn_playerorigin_z += gmapn_playeroldorigin_z - self.origin_z;
	}
	else
	{
		gmapn_playeroldorigin_z = self.origin_z;
	}

	gmapn_playerorigin = [ self.origin_x, self.origin_y, gmapn_playeroldorigin_z ];
	gmapn_playervelocity = self.velocity;
	addentity(self);

	// Time to roll back
	self.origin = oldorigin;
	setorigin(self, self.origin);
	self.velocity = oldvelocity;
	self.pmove_flags = oldmoveflags;
	self.movetype = MOVETYPE_NONE;

	// Set renderflag for mirrors!
	self.renderflags = RF_EXTERNALMODEL;

	return TRUE;
}

void teleport_touch()
{
	entity destination;

	destination = findfloat(world, entnum, self.targetnum);

	if (!destination)
	{
		print("targetnum ", ftos(self.targetnum), "\n");
		print("teleport destination is null\n");
		return;
	}
	
	setorigin(other, destination.origin);
	other.angles = destination.angles;

	print("touch\n");
}

void gmapn_init_teleport()
{
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	self.touch = teleport_touch;
	print("teleport\n");
}

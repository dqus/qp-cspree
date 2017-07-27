float gmapn_sendentity(entity to, float sendflags)
{
	bprint(PRINT_HIGH, "classname: ", self.classname, "\n");
	if (self.classname == "info_teleport_destination")
	{
		bprint(PRINT_HIGH, "ssqc teleportdest\n");
		WriteByte(MSG_ENTITY, ENT_TELEPORTDEST);

		WriteShort(MSG_ENTITY, self.modelindex);
		
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);

		WriteAngle(MSG_ENTITY, self.angles_x);
		WriteAngle(MSG_ENTITY, self.angles_y);
		WriteAngle(MSG_ENTITY, self.angles_z);
	}

	if (self.classname == "trigger_teleport")
	{
		WriteByte(MSG_ENTITY, ENT_TELEPORTER);

		WriteShort(MSG_ENTITY, self.modelindex);
		
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
		
		WriteEntity(MSG_ENTITY, find(world, targetname, self.target));
	}
	
	return TRUE;
}

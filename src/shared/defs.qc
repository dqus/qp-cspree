// URL is a shortened link to the project page
const string URL     = "https://bit.ly/3zj5FcD";

typedef enum
{
	true = 1,
	false = 0,
	TRUE = 1,
	FALSE = 0
} bool;

enum
{
	STAT_ACTIVEWEAPON = 10,
	STAT_ITEMS = 15,
	STAT_MATCHSTARTTIME = 18,	//engine-specified
	STAT_READY = 32,		//mod-specific stats.
	STAT_GAMEMODE,
	STAT_CURROUND,
	STAT_MAXROUND,
	STAT_TEAMSCORES_RED,
	STAT_TEAMSCORES_BLUE,
};

#define ENT_TELEPORTDEST 1
#define ENT_TELEPORTER 2

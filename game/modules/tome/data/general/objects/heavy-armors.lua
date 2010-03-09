local Talents = require "engine.interface.ActorTalents"

newEntity{
	define_as = "BASE_HEAVY_ARMOR",
	slot = "BODY",
	type = "armor", subtype="heavy",
	add_name = " (#ARMOR#)",
	display = "[", color=colors.SLATE,
	require = { talent = { Talents.T_HEAVY_ARMOUR_TRAINING }, },
	encumber = 17,
	rarity = 5,
	desc = [[A suit of armour made of mail.]],
	egos = "/data/general/objects/egos/armor.lua", egos_chance = resolvers.mbonus(40, 5),
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	name = "iron mail armour",
	level_range = {1, 10},
	require = { stat = { str=14 }, },
	cost = 20,
	wielder = {
		combat_def = 2,
		combat_armor = 4,
		fatigue = 12,
	},
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	name = "steel mail armour",
	level_range = {10, 20},
	require = { stat = { str=20 }, },
	cost = 25,
	wielder = {
		combat_def = 2,
		combat_armor = 6,
		fatigue = 14,
	},
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	name = "dwarven-steel mail armour",
	level_range = {20, 30},
	require = { stat = { str=28 }, },
	cost = 30,
	wielder = {
		combat_def = 3,
		combat_armor = 8,
		fatigue = 16,
	},
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	name = "galvorn mail armour",
	level_range = {30, 40},
	cost = 40,
	require = { stat = { str=38 }, },
	wielder = {
		combat_def = 4,
		combat_armor = 8,
		fatigue = 16,
	},
}

newEntity{ base = "BASE_HEAVY_ARMOR",
	name = "mithril mail armour",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 50,
	wielder = {
		combat_def = 5,
		combat_armor = 10,
		fatigue = 16,
	},
}

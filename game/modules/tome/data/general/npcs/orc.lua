local Talents = require("engine.interface.ActorTalents")

newEntity{
	define_as = "BASE_NPC_ORC",
	type = "humanoid", subtype = "orc",
	display = "o", color=colors.UMBER,

	combat = { dam=resolvers.rngavg(5,12), atk=2, apr=6, physspeed=2 },

	body = { INVEN = 10, MAINHAND=1, OFFHAND=1, BODY=1, QUIVER=1 },
	resolvers.drops{chance=20, nb=1, {} },
	resolvers.drops{chance=20, nb=1, {type="money"} },

	life_rating = 11,

	autolevel = "warrior",
	ai = "dumb_talented_simple", ai_state = { talent_in=4, },
	energy = { mod=1 },
	stats = { str=20, dex=8, mag=6, con=16 },
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "HILL_ORC_WARRIOR",
	name = "hill orc warrior", color=colors.LIGHT_UMBER,
	desc = [[He is a hardy well-weathered survivor.]],
	level_range = {1, 50}, exp_worth = 1,
	rarity = 4,
	max_life = resolvers.rngavg(70,80),
	resolvers.equip{
		{type="weapon", subtype="longsword", autoreq=true},
		{type="armor", subtype="shield", autoreq=true},
	},
	combat_armor = 2, combat_def = 0,
	resolvers.talents{ [Talents.T_SHIELD_PUMMEL]=1, },
}

newEntity{ base = "BASE_NPC_ORC",
	define_as = "HILL_ORC_ARCHER",
	name = "hill orc archer", color=colors.UMBER,
	desc = [[He is a hardy well-weathered survivor.]],
	level_range = {1, 50}, exp_worth = 1,
	rarity = 7,
	max_life = resolvers.rngavg(70,80),
	combat_armor = 5, combat_def = 1,
	resolvers.talents{ [Talents.T_SHOOT]=1, },
	ai_state = { talent_in=1, },

	autolevel = "archer",
	resolvers.equip{
		{type="weapon", subtype="longbow", autoreq=true},
		{type="ammo", subtype="arrow", autoreq=true},
	},
}

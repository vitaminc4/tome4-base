-- ToME - Tales of Middle-Earth
-- Copyright (C) 2009, 2010 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org

newEntity{
	define_as = "BASE_SHIELD",
	slot = "OFFHAND",
	type = "armor", subtype="shield",
	add_name = " (#ARMOR#)",
	display = ")", color=colors.UMBER,
	rarity = 5,
	encumber = 7,
	desc = [[Handheld deflection devices]],
	egos = "/data/general/objects/egos/shield.lua", egos_chance = resolvers.mbonus(40, 5),
}

-- All shields have a "special_combat" field, this is used to compute damage mde with them
-- when using special talents

newEntity{ base = "BASE_SHIELD",
	name = "iron shield",
	level_range = {1, 10},
	require = { stat = { str=11 }, },
	cost = 5,
	special_combat = {
		dam = resolvers.rngavg(7,11),
		physcrit = 2.5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 2,
		combat_def = 4,
		fatigue = 6,
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "steel shield",
	level_range = {10, 20},
	require = { stat = { str=16 }, },
	cost = 10,
	special_combat = {
		dam = resolvers.rngavg(10,20),
		physcrit = 3,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 2,
		combat_def = 6,
		fatigue = 8,
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "dwarven-steel shield",
	level_range = {20, 30},
	require = { stat = { str=24 }, },
	cost = 15,
	special_combat = {
		dam = resolvers.rngavg(25,35),
		physcrit = 3.5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 2,
		combat_def = 8,
		fatigue = 12,
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "galvorn shield",
	level_range = {30, 40},
	require = { stat = { str=35 }, },
	cost = 25,
	special_combat = {
		dam = resolvers.rngavg(40,55),
		physcrit = 4.5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 2,
		combat_def = 10,
		fatigue = 14,
	},
}

newEntity{ base = "BASE_SHIELD",
	name = "mithril shield",
	level_range = {40, 50},
	require = { stat = { str=48 }, },
	cost = 35,
	special_combat = {
		dam = resolvers.rngavg(60,75),
		physcrit = 5,
		dammod = {str=1},
	},
	wielder = {
		combat_armor = 3,
		combat_def = 12,
		fatigue = 14,
	},
}

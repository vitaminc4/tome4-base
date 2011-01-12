-- ToME - Tales of Maj'Eyal
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

local Talents = require("engine.interface.ActorTalents")
local Stats = require "engine.interface.ActorStats"

load("/data/general/objects/egos/armor.lua")

newEntity{
	name = " of the dragon", suffix=true, instant_resolve=true,
	level_range = {20, 50},
	greater_ego = true,
	rarity = 20,
	cost = 60,
	wielder = {
		resists={
			[DamageType.ACID] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.LIGHTNING] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.FIRE] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.COLD] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
			[DamageType.PHYSICAL] = resolvers.mbonus_material(10, 5, function(e, v) return v * 0.15 end),
	},
		inc_stats = {
			[Stats.STAT_CON] = resolvers.mbonus_material(5, 1, function(e, v) return v * 3 end),
			[Stats.STAT_STR] = resolvers.mbonus_material(5, 1, function(e, v) return v * 3 end),
		},
		stun_immune = resolvers.mbonus_material(20, 20, function(e, v) v=v/100 return v * 80, v end),
		knockback_immune = resolvers.mbonus_material(20, 20, function(e, v) v=v/100 return v * 80, v end),
		disarm_immune = resolvers.mbonus_material(20, 20, function(e, v) v=v/100 return v * 80, v end),
		talent_cd_reduction={[Talents.T_RUSH]=10},
	},
}

newEntity{
	name = "impenetrable ", prefix=true, instant_resolve=true,
	level_range = {10, 50},
	rarity = 8,
	cost = 7,
	wielder = {
		combat_armor = resolvers.mbonus_material(12, 3, function(e, v) return v * 1 end),
	},
}

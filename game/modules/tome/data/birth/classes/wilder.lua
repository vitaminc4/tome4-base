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

newBirthDescriptor{
	type = "class",
	name = "Wilder",
	desc = {
		"Wilders are one with nature, in one manner or another. There are as many different wilders as there are aspects of nature.",
		"They can take on the aspects of creatures, summon creatures to them, feel the druidic call, ...",
	},
	descriptor_choices =
	{
		subclass =
		{
			__ALL__ = "never",
			Summoner = function() return profile.mod.allow_build.wilder_summoner and "allow" or "never" end,
			Wyrmic = function() return profile.mod.allow_build.wilder_wyrmic and "allow" or "never" end,
		},
	},
	copy = {
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Summoner",
	desc = {
		"Summoners never fight alone, they are always ready to summon one of their many minions to fight at their side.",
		"Summons can range from a combat hound to a fire drake.",
		"Their most important stats are: Willpower and Cunning",
	},
	stats = { wil=3, cun=2, con=1, },
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/summon-melee"]={true, 0.3},
		["wild-gift/summon-distance"]={true, 0.3},
		["wild-gift/summon-utility"]={true, 0.3},
		["wild-gift/summon-augmentation"]={false, 0.3},
		["cunning/survival"]={true, 0},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={false, 0},
		["technique/combat-training"]={false, 0},
	},
	talents = {
		[ActorTalents.T_WAR_HOUND] = 1,
		[ActorTalents.T_FIRE_IMP] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_TRAP_DETECTION] = 1,
	},
	copy = {
		max_life = 90,
		life_rating = 10,
		resolvers.equip{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true}
		},
	},
}

newBirthDescriptor{
	type = "subclass",
	name = "Wyrmic",
	desc = {
		"Wyrmics are fighters who have learnt how to mimic some of the aspects of the dragons.",
		"They have access to talents normally belonging to the various kind of drakes.",
		"Their most important stats are: Strength and Willpower",
	},
	stats = { str=3, wil=2, dex=1, },
	talents_types = {
		["wild-gift/call"]={true, 0.2},
		["wild-gift/sand-drake"]={true, 0.3},
		["wild-gift/fire-drake"]={true, 0.3},
		["wild-gift/cold-drake"]={true, 0.3},
		["cunning/survival"]={false, 0},
		["technique/shield-offense"]={false, -0.1},
		["technique/2hweapon-offense"]={false, -0.1},
		["technique/combat-techniques-active"]={false, 0},
		["technique/combat-techniques-passive"]={true, 0},
		["technique/combat-training"]={true, 0},
	},
	talents = {
		[ActorTalents.T_ICE_CLAW] = 1,
		[ActorTalents.T_BELLOWING_ROAR] = 1,
		[ActorTalents.T_MEDITATION] = 1,
		[ActorTalents.T_AXE_MASTERY] = 1,
	},
	copy = {
		max_life = 110,
		life_rating = 12,
		resolvers.equip{ id=true,
			{type="weapon", subtype="battleaxe", name="iron battleaxe", autoreq=true},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true}
		},
	},
}

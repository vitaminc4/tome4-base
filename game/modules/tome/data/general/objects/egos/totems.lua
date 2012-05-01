-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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

load("/data/general/objects/egos/charms.lua")

newEntity{
	name = "natural ", prefix=true,
	level_range = {10, 50},
	rarity = 12,
	cost = 5,

	charm_on_use = {
		[function(self, who)
			who:incEquilibrium(-self:getCharmPower(true) / 5)
		end] = {100, function(self, who) return ("regenerate %d equilibrium"):format(self:getCharmPower(true) / 5) end},
	}
}

newEntity{
	name = "forcefull ", prefix=true,
	level_range = {10, 50},
	rarity = 12,
	cost = 5,

	charm_on_use = {
		[function(self, who)
			who:incStamina(self:getCharmPower(true) / 6)
		end] = {100, function(self, who) return ("regenerate %d stamina"):format(self:getCharmPower(true) / 6) end},
	}
}

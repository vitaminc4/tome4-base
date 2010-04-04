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

newAchievement{
	name = "Deux Ex Machina",
	desc = [[Found both ever-refilling potions.]],
	mode = "player",
	can_gain = function(self, who, obj)
		if obj:getName{force_id=true} == "Ever Refilling Potion of Mana" then self.mana = true end
		if obj:getName{force_id=true} == "Ever Refilling Potion of Healing" then self.life = true end
		return self.mana and self.life
	end
}

-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2016 Nicolas Casalini
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

local def = {special="start", lite=true, remember=true}
defineTile(' ', "FLOOR", nil, nil, nil, def)
defineTile('#', "WALL", nil, nil, nil, def)
defineTile('+', "DOOR", nil, nil, nil, def)
defineTile(';', "SUMMON_CIRCLE", nil, nil, nil, def)
defineTile('N', "FLOOR", nil, "NECROMANCER", nil, def)

subGenerator{
	x = 0, y = 9, w = 50, h = 41,
	generator = "engine.generator.map.Roomer",
	data = {
		nb_rooms = 10,
		rooms = {"random_room"},
		['.'] = "FLOOR",
		['#'] = "WALL",
		up = "UP",
		door = "DOOR",
		force_tunnels = {
			{"random", {25, 8}, id=-500},
		},
	},
	define_up = true,
}

endx = 25
endy = 3

checkConnectivity({25,8}, "entrance", "start-area", "start-area")

return [[
############           ;;;;;          ############
############          ;;   ;;         ############
############          ;     ;         ############
############   ## N   ;     ;    ##   ############
############   ##     ;     ;    ##   ############
#############         ;;   ;;        #############
#############          ;;;;;         #############
#############     ##          ##     #############
########################++########################
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................
..................................................]]

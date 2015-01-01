-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2015 Nicolas Casalini
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

defineTile("#", "WALL")
defineTile("+", "LOCK")
defineTile("1", "WALL_SEE")
defineTile(".", "SAND")
defineTile("-", "FLOOR")

startx = 23
starty = 0
endx = 33
endy = 49

-- defineTile section
defineTile("#", "WALL")
defineTile("<", "UP")
defineTile("o", "FLOOR", nil, "ORC_GUARD")
defineTile("O", "FLOOR", nil, "BROTOQ")
defineTile(">", "IRON_COUNCIL")
defineTile(".", "FLOOR")

-- addSpot section

-- addZone section

-- ASCII map section
return [[
######################.<.#########################
######################...#########################
######################...#########################
######################...#########################
######################.#.#########################
######################.#.#########################
######################...#########################
######################...#########################
######################...#########################
######################.#.#########################
######################.#.#########################
######################...#########################
######################...#########################
##################...........#####################
##################...........#####################
##################..##...##..#####################
##################..##...##..#####################
##################...........#####################
##################....oOo....#####################
##################...........#####################
##################..##...##..#####################
##################..##...##..#####################
##################...........#####################
##################...........#####################
######################...#########################
######################...#########################
######################...#########################
######################.#.#########################
######################...#########################
######################...#########################
######################...#########################
######################.#.#########################
######################.#...........###############
######################.###.....#...###############
######################.............###############
################################...###############
################################...###############
################################...###############
################################...###############
################################.#.###############
################################.#.###############
################################...###############
################################...###############
################################...###############
################################...###############
################################...###############
################################.#.###############
################################.#.###############
################################...###############
################################.>.###############]]
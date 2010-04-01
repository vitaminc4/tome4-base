-- TE4 - T-Engine 4
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

-- Character movements
defineAction{
	default = { "sym:276:false:false:false:false", "sym:260:false:false:false:false" },
	type = "MOVE_LEFT",
	group = "movement",
	name = "Move left",
}
defineAction{
	default = { "sym:275:false:false:false:false", "sym:262:false:false:false:false" },
	type = "MOVE_RIGHT",
	group = "movement",
	name = "Move right",
}
defineAction{
	default = { "sym:273:false:false:false:false", "sym:264:false:false:false:false" },
	type = "MOVE_UP",
	group = "movement",
	name = "Move up",
}
defineAction{
	default = { "sym:274:false:false:false:false", "sym:258:false:false:false:false" },
	type = "MOVE_DOWN",
	group = "movement",
	name = "Move down",
}
defineAction{
	default = { "sym:263:false:false:false:false" },
	type = "MOVE_LEFT_UP",
	group = "movement",
	name = "Move diagonally left and up",
}
defineAction{
	default = { "sym:265:false:false:false:false" },
	type = "MOVE_RIGHT_UP",
	group = "movement",
	name = "Move diagonally right and up",
}
defineAction{
	default = { "sym:257:false:false:false:false" },
	type = "MOVE_LEFT_DOWN",
	group = "movement",
	name = "Move diagonally left and down",
}
defineAction{
	default = { "sym:259:false:false:false:false" },
	type = "MOVE_RIGHT_DOWN",
	group = "movement",
	name = "Move diagonally right and down",
}

defineAction{
	default = { "sym:261:false:false:false:false" },
	type = "MOVE_STAY",
	group = "movement",
	name = "Stay for a turn",
}

-- Running
defineAction{
	default = { "sym:276:false:true:false:false", "sym:260:false:true:false:false" },
	type = "RUN_LEFT",
	group = "movement",
	name = "Run left",
}
defineAction{
	default = { "sym:275:false:true:false:false", "sym:262:false:true:false:false" },
	type = "RUN_RIGHT",
	group = "movement",
	name = "Run right",
}
defineAction{
	default = { "sym:273:false:true:false:false", "sym:264:false:true:false:false" },
	type = "RUN_UP",
	group = "movement",
	name = "Run up",
}
defineAction{
	default = { "sym:274:false:true:false:false", "sym:258:false:true:false:false" },
	type = "RUN_DOWN",
	group = "movement",
	name = "Run down",
}
defineAction{
	default = { "sym:263:false:true:false:false" },
	type = "RUN_LEFT_UP",
	group = "movement",
	name = "Run diagonally left and up",
}
defineAction{
	default = { "sym:265:false:true:false:false" },
	type = "RUN_RIGHT_UP",
	group = "movement",
	name = "Run diagonally right and up",
}
defineAction{
	default = { "sym:257:false:true:false:false" },
	type = "RUN_LEFT_DOWN",
	group = "movement",
	name = "Run diagonally left and down",
}
defineAction{
	default = { "sym:259:false:true:false:false" },
	type = "RUN_RIGHT_DOWN",
	group = "movement",
	name = "Run diagonally right and down",
}

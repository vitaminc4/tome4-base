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

require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, level)
	engine.Generator.init(self, zone, map)
	self.level = level
	local data = level.data.generator.actor

	if data.adjust_level then
		self.adjust_level = {base=zone.base_level, lev = self.level.level, min=data.adjust_level[1], max=data.adjust_level[2]}
	else
		self.adjust_level = {base=zone.base_level, lev = self.level.level, min=0, max=0}
	end
	self.filters = data.filters
	self.nb_npc = data.nb_npc or {10, 20}
	self.guardian = data.guardian
end

function _M:generate()
	for i = 1, rng.range(self.nb_npc[1], self.nb_npc[2]) do
		local f = nil
		if self.filters then f = self.filters[rng.range(1, #self.filters)] end
		local m = self.zone:makeEntity(self.level, "actor", f)
		if m then
			local x, y = rng.range(0, self.map.w), rng.range(0, self.map.h)
			local tries = 0
			while not m:canMove(x, y) and tries < 100 do
				x, y = rng.range(0, self.map.w), rng.range(0, self.map.h)
				tries = tries + 1
			end
			if tries < 100 then
				self.zone:addEntity(self.level, m, "actor", x, y)
			end
		end
	end

	if self.level.level < self.zone.max_level then return end

	if self.guardian then
		local m = self.zone:makeEntityByName(self.level, "actor", self.guardian)
		if m then
			local x, y = rng.range(0, self.map.w), rng.range(0, self.map.h)
			local tries = 0
			while not m:canMove(x, y) and tries < 100 do
				x, y = rng.range(0, self.map.w), rng.range(0, self.map.h)
				tries = tries + 1
			end
			if tries < 100 then
				self.zone:addEntity(self.level, m, "actor", x, y)
				print("Guardian allocated: ", self.guardian, m.uid, m.name)
			end
		else
			print("WARNING: Guardian not found: ", self.guardian)
		end
	end
end

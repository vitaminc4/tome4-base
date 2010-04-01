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

--- Define a level
module(..., package.seeall, class.make)

--- Initializes the level with a "level" and a map
function _M:init(level, map)
	self.level = level
	self.map = map
	self.e_array = {}
	self.entities = {}
	self.entities_list = {}
end

--- Adds an entity to the level
-- Only entities that need to act need to be added. Terrain features do not need this usualy
function _M:addEntity(e)
	if self.entities[e.uid] then error("Entity "..e.uid.." already present on the level") end
	self.entities[e.uid] = e
	table.insert(self.e_array, e)
	game:addEntity(e)
end

--- Removes an entity from the level
function _M:removeEntity(e)
	if not self.entities[e.uid] then error("Entity "..e.uid.." not present on the level") end
	self.entities[e.uid] = nil
	for i = 1, #self.e_array do
		if self.e_array[i] == e then
			table.remove(self.e_array, i)
			break
		end
	end
	game:removeEntity(e)
	-- Tells it to delete itself if needed
	if e.deleteFromMap then e:deleteFromMap(self.map) end
end

--- Is the entity on the level?
function _M:hasEntity(e)
	return self.entities[e.uid]
end

--- Serialization
function _M:save()
	return class.save(self, {
	})
end
function _M:loaded()
	-- Loading the game has defined new uids for entities, yet we hard referenced the old ones
	-- So we fix it
	local nes = {}
	for uid, e in pairs(self.entities) do
		nes[e.uid] = e
	end
	self.entities = nes
end

--- Setup an entity list for the level, this allwos the Zone to pick objects/actors/...
function _M:setEntitiesList(type, list)
	self.entities_list[type] = list
	print("Stored entities list", type, list)
end

--- Gets an entity list for the level, this allows the Zone to pick objects/actors/...
function _M:getEntitiesList(type)
	return self.entities_list[type]
end

--- Removed, so we remove all entities
function _M:removed()
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		local z = i + j * self.map.w
		if self.map.map[z] then
			for _, e in pairs(self.map.map[z]) do
				e:removed()
			end
		end
	end end
end

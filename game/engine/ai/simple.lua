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

-- Defines a simple AI building blocks
-- Target nearest and move/attack it

local Astar = require "engine.Astar"

newAI("move_simple", function(self)
	if self.ai_target.actor then
		local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
		return self:moveDirection(tx, ty)
	end
end)

newAI("move_astar", function(self)
	if self.ai_target.actor then
		local tx, ty = self:aiSeeTargetPos(self.ai_target.actor)
		local a = Astar.new(game.level.map, self)
		local path = a:calc(self.x, self.y, tx, ty)
		if not path then
			return self:runAI("move_simple")
		else
			return self:move(path[1].x, path[1].y)
		end
	end
end)

-- Find an hostile target
-- this requires the ActorFOV interface, or an interface that provides self.fov.actors*
newAI("target_simple", function(self)
	if self.ai_target.actor and not self.ai_target.actor.dead and rng.percent(90) then return true end

	-- Find closer ennemy and target it
	-- Get list of actors ordered by distance
	local arr = self.fov.actors_dist
	local act
	for i = 1, #arr do
		act = self.fov.actors_dist[i]
--		print("AI looking for target", self.uid, self.name, "::", act.uid, act.name, self.fov.actors[act].sqdist)
		-- find the closest ennemy
		if act and self:reactionToward(act) < 0 and not act.dead then
			self.ai_target.actor = act
			self:check("on_acquire_target", act)
			return true
		end
	end
end)

newAI("target_player", function(self)
	self.ai_target.actor = game.player
	return true
end)

newAI("simple", function(self)
	if self:runAI(self.ai_state.ai_target or "target_simple") then
		return self:runAI(self.ai_state.ai_move or "move_simple")
	end
	return false
end)

newAI("none", function(self) end)

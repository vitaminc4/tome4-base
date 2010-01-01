require "engine.class"
local Map = require "engine.Map"
require "engine.Generator"

--- Generator that makes a map
module(..., package.seeall, class.inherit(engine.Generator))

function _M:init(zone, map, grid_list, data)
	engine.Generator.init(self, zone, map)
	self.floor = grid_list[data.floor]
	self.wall = grid_list[data.wall]
	self.door = grid_list[data.door]
	self.up = grid_list[data.up]
	self.down = grid_list[data.down]
	self.spots = {}
end

function _M:doRooms(room, no, tab)
	if room.w * room.h >= 60 and room.w >= 5 and room.h >= 5 and not room.no_touch and no > 0 then
		local sy, sx = rng.range(3, room.h - 2), rng.range(3, room.w - 2)
		local axis = rng.percent(50)
		if room.w < (room.h * 3) then axis = true else axis = false end
		if axis then
			for z = 0, room.w - 1 do
				self.map(room.x + z, room.y + sy, Map.TERRAIN, self.wall)
			end
			self:doRooms({ y=room.y, x=room.x, h=sy, w=room.w}, no-1,"  "..tab)
			self:doRooms({ y=room.y + sy + 1, x=room.x, h=room.h - sy - 1, w=room.w}, no-1,"  "..tab)
		else
			for z = 0, room.h - 1 do
				self.map(room.x + sx, room.y + z, Map.TERRAIN, self.wall)
			end
			self:doRooms({ y=room.y, x=room.x,      h=room.h, w=sx}, no-1,"  "..tab)
			self:doRooms({ y=room.y, x=room.x + sx + 1, h=room.h, w=room.w - sx - 1}, no-1,"  "..tab)
		end
		self.map(room.x + sx, room.y + sy, Map.TERRAIN, self.door)
	else
		-- Final room, select an interresting "spot"
		local spotx, spoty = rng.range(room.x, room.x + room.w - 1), rng.range(room.y, room.y + room.h - 1)
		table.insert(self.spots, {x=spotx, y=spoty})
	end
end

function _M:generate(lev, old_lev)
	for i = 0, self.map.w - 1 do for j = 0, self.map.h - 1 do
		if j == 0 or j == self.map.h - 1 or i == 0 or i == self.map.w - 1 then
			self.map(i, j, Map.TERRAIN, self.wall)
		else
			self.map(i, j, Map.TERRAIN, self.floor)
		end
	end end

	self:doRooms({ x=1, y=1, h=self.map.h - 2, w=self.map.w - 2 }, 10, "#")

	-- Select 2 spots, one for up and one for down, remove the up one, we dont want an actor generator to get smart
	-- and place a monster where the player should be!
	local up_spot = table.remove(self.spots, rng.range(1, #self.spots))
	local down_spot = self.spots[rng.range(1, #self.spots)]
	self.map(up_spot.x, up_spot.y, Map.TERRAIN, self.up)
	if lev < self.zone.max_level then
		self.map(down_spot.x, down_spot.y, Map.TERRAIN, self.down)
	end
	return up_spot.x, up_spot.y, self.spots
end

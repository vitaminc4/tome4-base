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
require "engine.Dialog"

module(..., package.seeall, class.inherit(engine.Dialog))

function _M:init(title, store_inven, actor_inven, store_filter, actor_filter, action, desc)
	self.action = action
	self.desc = desc
	self.store_inven = store_inven
	self.actor_inven = actor_inven
	self.store_filter = store_filter
	self.actor_filter = actor_filter
	engine.Dialog.init(self, title or "Store", game.w * 0.8, game.h * 0.8, nil, nil, nil, core.display.newFont("/data/font/VeraMono.ttf", 12))

	self:generateList()

	self.list = self.store_list
	self.sel = 1
	self.scroll = 1
	self.max = math.floor((self.ih * 0.8 - 5) / self.font_h) - 1

	self:keyCommands({
		__TEXTINPUT = function(c)
			if c:find("^[a-z]$") then
				self.sel = util.bound(1 + string.byte(c) - string.byte('a'), 1, #self.list)
				self:use()
			end
		end,
	},{
		MOVE_UP = function() self.sel = util.boundWrap(self.sel - 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_DOWN = function() self.sel = util.boundWrap(self.sel + 1, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_LEFT = function() self.list = self.store_list self.sel = util.bound(self.sel, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		MOVE_RIGHT = function() self.list = self.actor_list self.sel = util.bound(self.sel, 1, #self.list) self.scroll = util.scroll(self.sel, self.scroll, self.max) self.changed = true end,
		ACCEPT = function() self:use() end,
		EXIT = function() game:unregisterDialog(self) end,
	})
	self:mouseZones{
		{ x=2, y=5, w=350, h=self.font_h*self.max, fct=function(button, x, y, xrel, yrel, tx, ty)
			self.sel = util.bound(self.scroll + math.floor(ty / self.font_h), 1, #self.list)
			if button == "left" then self:use()
			elseif button == "right" then
			end
		end },
	}
end

function _M:updateStore()
	self:generateList()
	self.list = #self.store_list > 0 and self.store_list or self.actor_list
	self.sel = util.bound(self.sel, 1, #self.list)
	self.scroll = util.scroll(self.sel, self.scroll, self.max)
	self.changed = true
end

function _M:use()
	if self.list[self.sel] then
		if self.list == self.store_list then
			self.action("buy", self.list[self.sel].object, self.list[self.sel].item)
			self:updateStore()
		else
			self.action("sell", self.list[self.sel].object, self.list[self.sel].item)
			self:updateStore()
		end
	end
end

function _M:generateList()
	-- Makes up the list
	local list = {}
	local i = 0
	for item, o in ipairs(self.store_inven) do
		if not self.store_filter or self.store_filter(o) then
			list[#list+1] = { name=string.char(string.byte('a') + i)..") "..o:getName(), color=o:getDisplayColor(), object=o, item=item }
			i = i + 1
		end
	end
	self.store_list = list

	-- Makes up the list
	local list = {}
	local i = 0
	for item, o in ipairs(self.actor_inven) do
		if not self.actor_filter or self.actor_filter(o) then
			list[#list+1] = { name=string.char(string.byte('a') + i)..") "..o:getName(), color=o:getDisplayColor(), object=o, item=item }
			i = i + 1
		end
	end
	self.actor_list = list
end

function _M:drawDialog(s)
	if self.list[self.sel] then
		lines = self.desc(self.list == self.store_list and "buy" or "sell", self.list[self.sel].object):splitLines(self.iw - 10, self.font)
	else
		lines = {}
	end

	local sh = self.ih - 4 - #lines * self.font:lineSkip()
	h = sh
	self:drawWBorder(s, 3, sh, self.iw - 6)
	for i = 1, #lines do
		s:drawColorString(self.font, lines[i], 5, 2 + h)
		h = h + self.font:lineSkip()
	end

	self:drawSelectionList(s, 2, 5, self.font_h, self.store_list, self.list == self.store_list and self.sel or -1, "name", self.scroll, self.max)
	self:drawHBorder(s, self.iw / 2, 2, sh - 4)
	self:drawSelectionList(s, self.iw / 2 + 5, 5, self.font_h, self.actor_list, self.list == self.actor_list and self.sel or -1, "name", self.scroll, self.max)
end

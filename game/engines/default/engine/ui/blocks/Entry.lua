-- TE4 - T-Engine 4
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

require "engine.class"
local Block = require "engine.ui.blocks.Block"
local tween = require "tween"

--- An entry for any kind of lists and such
-- @classmod engine.ui.blocks.block
module(..., package.seeall, class.inherit(Block))

function _M:init(t, text, color, w, h, offset)
	color = color or {255,255,255}

	Block.init(self, t)

	self.selected = false

	t = t or {}

	self.frame = self.parent:makeFrameDO(t.frame or "ui/selector", w, h)
	self.frame.container:shown(false)
	self.frame_sel = self.parent:makeFrameDO(t.frame_sel or "ui/selector-sel", w, h)
	self.frame_sel.container:shown(false)
	self.cur_frame = self.frame

	self.w, self.h = w, h
	self.max_text_w = w - self.frame.b4.w - self.frame.b6.w
	self.up_text_h = (h - self.font_h) / 2
	self.text = core.renderer.text(self.parent.font)
	self.text:maxLines(1)
	self.text:textColor(color[1] / 255, color[2] / 255, color[3] / 255, 1)

	self.text_container = core.renderer.container()
	self.text_container:translate(self.frame.b4.w + (offset or 0), self.up_text_h, 10)
	self.text_container:add(self.text)

	self.do_container:add(self.frame.container)
	self.do_container:add(self.frame_sel.container)
	self.do_container:add(self.text_container)

	self.uses_own_renderer = false
	self.cur_v_scroll = 0

	self:setText(text)
end

function _M:onFocusChange(v)
	-- tween.stop(self.tweenid)
	self.focused = v
	self.cur_frame.container:shown(false)
	self.cur_frame = v and self.frame_sel or self.frame
	if self.selected then
		self.cur_frame.container:color(1, 1, 1, 1)
		self.cur_frame.container:shown(true)
	end

	if not v then
		self:stopScrolling()
	end
end

function _M:setText(text, color)
	if self.str == text then return end
	self.str = text
	if color then
		self.text:textColor(color[1] / 255, color[2] / 255, color[3] / 255, 1)
	end

	self.text:text(text)
	local w = self.text:getStats()
	if w <= self.max_text_w then
		if self.uses_own_renderer then
			self.text_container:remove(self.renderer)
			self.text_container:add(self.text)
			self.renderer = nil
			self.uses_own_renderer = false
		end
	else
		if not self.uses_own_renderer then
			self.renderer = core.renderer.renderer()
			self.renderer:cutoff(0, 0, self.max_text_w, self.h)
			self.text_container:remove(self.text)
			self.text_container:add(self.renderer)
			self.renderer:add(self.text)
			self.uses_own_renderer = true
		end
	end

	self:stopScrolling()
end

function _M:select(v)
	if self.selected == v then return end
	self.selected = v
	if v then
		self.cur_frame.container:color(1, 1, 1, 1)
		self.cur_frame.container:shown(v)
		self:startScrolling()
	else
		tween.stop(self.tweenid)
		self:stopScrolling()
		self.tweenid = tween(8, function(a) self.cur_frame.container:color(1, 1, 1, a) end, {1, 0}, "linear", function() self.cur_frame.container:shown(false) end)
	end
end

function _M:startScrolling()
	if not self.focused then return end
	if not self.uses_own_renderer then return end

	local dir
	local w = self.text:getStats()
	if not self.invert_scroll then
		dir = {0, -(w - self.max_text_w + 10)}
	else
		dir = {-(w - self.max_text_w + 10), 0}
	end
	tween.stop(self.scrolltween)
	self.scrolltween = tween(4 * #self.str, function(v) self.cur_v_scroll = v self.text:translate(v, 0, 0) end, dir, "inOutQuad", function() self.invert_scroll = not self.invert_scroll self:startScrolling() end)
end

function _M:stopScrolling()
	if not self.uses_own_renderer then return end

	self.invert_scroll = false
	tween.stop(self.scrolltween)
	self.scrolltween = tween(8, function(v) self.cur_v_scroll = v self.text:translate(v, 0, 0) end, {self.cur_v_scroll, 0}, "inQuad")
end

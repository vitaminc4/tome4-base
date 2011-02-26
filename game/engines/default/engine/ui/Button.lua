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
local Base = require "engine.ui.Base"
local Focusable = require "engine.ui.Focusable"

--- A generic UI button
module(..., package.seeall, class.inherit(Base, Focusable))

frame_ox1 = -5
frame_ox2 = 5
frame_oy1 = -5
frame_oy2 = 5

function _M:init(t)
	self.text = assert(t.text, "no button text")
	self.fct = assert(t.fct, "no button fct")
	self.force_w = t.width

	Base.init(self, t)
end

function _M:generate()
	self.mouse:reset()
	self.key:reset()

	-- Draw UI
	self.font:setStyle("bold")
	local w, h = self.font:size(self.text)
	if self.force_w then w = self.force_w end
	self.w, self.h = w - frame_ox1 + frame_ox2, h - frame_oy1 + frame_oy2

	local s = core.display.newSurface(w, h)
	s:drawColorStringBlended(self.font, self.text, 0, 0, 255, 255, 255, true)
	self.tex = {s:glTexture()}
	self.font:setStyle("normal")

	-- Add UI controls
	self.mouse:registerZone(0, 0, self.w, self.h, function(button, x, y, xrel, yrel, bx, by, event) if button == "left" and event == "button" then self.fct() end end)
	self.key:addBind("ACCEPT", function() self.fct() end)

	self.rw, self.rh = w, h
	self.frame = self:makeFrame("ui/button", self.w, self.h)
	self.frame_sel = self:makeFrame("ui/button_sel", self.w, self.h)

	-- Add a bit of padding
	self.w = self.w + 6
	self.h = self.h + 6
end

function _M:display(x, y, nb_keyframes)
	x = x + 3
	y = y + 3
	if self.focused then
		self:drawFrame(self.frame_sel, x, y)
		self.tex[1]:toScreenFull(x-frame_ox1, y-frame_oy1, self.rw, self.rh, self.tex[2], self.tex[3])
	else
		self:drawFrame(self.frame, x, y)
		if self.focus_decay then
			self:drawFrame(self.frame_sel, x, y, 1, 1, 1, self.focus_decay / self.focus_decay_max_d)
			self.focus_decay = self.focus_decay - nb_keyframes
			if self.focus_decay <= 0 then self.focus_decay = nil end
		end
		self.tex[1]:toScreenFull(x-frame_ox1, y-frame_oy1, self.rw, self.rh, self.tex[2], self.tex[3])
	end
end

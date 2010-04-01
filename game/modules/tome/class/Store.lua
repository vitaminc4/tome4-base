-- ToME - Tales of Middle-Earth
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
local Store = require "engine.Store"
local Dialog = require "engine.Dialog"

module(..., package.seeall, class.inherit(Store))

_M.stores_def = {}

function _M:loadStores(f)
	self.stores_def = self:loadList(f)
end

function _M:init(t, no_default)
	Store.init(self, t, no_default)
end

--- Called on object purchase
-- @param who the actor buying
-- @param o the object trying to be purchased
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to buy
-- @return true if allowed to buy
function _M:onBuy(who, o, item, nb)
	local price = o:getPrice()
	if who.money >= price * nb then
		who.money = who.money - price * nb
		return nb
	else
		Dialog:simplePopup("Not enough gold", "You do not have enough gold!")
	end
end

--- Called on object sale
-- @param who the actor selling
-- @param o the object trying to be sold
-- @param item the index in the inventory
-- @param nb number of items (if stacked) to sell
-- @return true if allowed to sell
function _M:onSell(who, o, item, nb)
	local price = o:getPrice() / 10
	if price <= 0 then return end
	who.money = who.money + price * nb
	o:identify(true)
	return nb
end

--- Called to describe an object, being to sell or to buy
-- @param who the actor
-- @param what either "sell" or "buy"
-- @param o the object
-- @return a string (possibly multiline) describing the object
function _M:descObject(who, what, o)
	if what == "buy" then
		local desc = ("Buy for: %0.2f gold (You have %0.2f gold)\n\n"):format(o:getPrice(), who.money)
		desc = desc .. o:getDesc()
		return desc
	else
		local desc = ("Sell for: %0.2f gold (You have %0.2f gold)\n\n"):format(o:getPrice() / 10, who.money)
		desc = desc .. o:getDesc()
		return desc
	end
end

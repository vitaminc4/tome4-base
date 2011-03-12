-- ToME - Tales of Maj'Eyal
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

load("/data/general/objects/objects.lua")

newEntity{ base = "BASE_WAND",
	power_source = {unknown=true, arcane=false},
	type = "chest", subtype = "sher'tul",
	define_as = "TRANSMO_CHEST",
	add_name = false,
	identified=true, force_lore_artifact=true,
	name = "Transmogrification Chest", display = '~', color=colors.GOLD, unique=true, image = "object/chest4.png",
	desc = [[This chest is an extension of Yiilkgur, any items dropped inside is transported to the Fortress, processed by the core and destroyed to extract energy.
The byproduct of this effect is the creation of gold, which is useless to the Fortress, so it is sent back to you.

When activated it will prompt to destroy items on the floor, if there are none it prompts for your inventory.]],
	cost = 0, quest=true,

	max_power = 1000, power_regen = 1,
	use_power = { name = "open a portal to send items to the Fortress core, extracting energies from it for the Fortress and sending back useless gold.", power = 0,
		use = function(self, who)
			local pricemod = function(o) if o.type == "gem" then return 0.40 else return 0.5 end end

			-- On the floor or inventory
			if game.level.map:getObjectTotal(who.x, who.y) > 0 then
				local x, y = who.x, who.y
				local d = require("engine.dialogs.ShowPickupFloor").new("Transmogrify", x, y, function(o) if o:getPrice() <= 0 or o.quest then return false end return true end, function(o, idx)
					local price = o:getPrice() * o:getNumber() * pricemod(o)
					price = math.min(price, 25)
					game.level.map:removeObject(x, y, idx)
					who:incMoney(price)
					who:hasQuest("shertul-fortress"):gain_energy(price/10)
					game.log("You gain %0.2f gold from the transmogrification of %s.", price, o:getName{do_count=true, do_color=true})
				end, "Transmogrify all")
				game:registerDialog(d)
			else
				local d = require("engine.dialogs.ShowInventory").new("Transmogrify", who:getInven("INVEN"), function(o) if o:getPrice() <= 0 or o.quest then return false end return true end, function(o, idx)
					local price = o:getPrice() * o:getNumber() * pricemod(o)
					price = math.min(price, 25)
					who:removeObject(who:getInven("INVEN"), idx, true)
					who:sortInven()
					who:incMoney(price)
					who:hasQuest("shertul-fortress"):gain_energy(price/10)
					game.log("You gain %0.2f gold from the transmogrification of %s.", price, o:getName{do_count=true, do_color=true})
				end, who)
				game:registerDialog(d)
			end
			return true
		end
	},
}

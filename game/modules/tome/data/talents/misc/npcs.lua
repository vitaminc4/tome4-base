-- race & classes
newTalentType{ type="physical/other", name = "other", hide = true, description = "Talents of the various entities of the world." }
newTalentType{ type="spell/other", name = "other", hide = true, description = "Talents of the various entities of the world." }
newTalentType{ type="other/other", name = "other", hide = true, description = "Talents of the various entities of the world." }

-- Multiply!!!
newTalent{
	name = "Multiply",
	type = {"other/other", 1},
	cooldown = 3,
	range = 20,
	action = function(self, t)
		print("Multiply *****BROKEN***** Fix it!")
		return nil
--[[
		if not self.can_multiply or self.can_multiply <= 0 then return nil end
		-- Find a place around to clone
		for i = -1, 1 do for j = -1, 1 do
			if not game.level.map:checkAllEntities(self.x + i, self.y + j, "block_move") then
				self.can_multiply = self.can_multiply - 1
				local a = self:clone()
				a.energy.val = 0
				a.exp_worth = 0.1
				a.inven = {}
				if a.can_multiply <= 0 then a:unlearnTalent(t.id) end
				print("multiplied", a.can_multiply, "uids", self.uid,"=>",a.uid, "::", self.player, a.player)
				a:move(self.x + i, self.y + j, true)
				game.level:addEntity(a)
				return true
			end
		end end
		return nil
]]
	end,
	info = function(self)
		return ([[Multiply yourself!]])
	end,
}

newTalent{
	short_name = "CRAWL_POISON",
	name = "Poisonous Crawl",
	type = {"physical/other", 1},
	cooldown = 2,
	range = 1,
	action = function(self, t)
		local x, y, target = self:getTarget()
		if math.floor(core.fov.distance(self.x, self.y, x, y)) > 1 then return nil end
		self:attackTarget(target, DamageType.POISON, 1)
		return true
	end,
	info = function(self)
		return ([[Multiply yourself!]])
	end,
}

newTalentType{ type="spell/arcane", name = "arcane", description = "Arcane manipulates the raw magic energies to shape them into both offensive and defensive spells." }
newTalentType{ type="spell/fire", name = "fire", description = "Harness the power of fire to burn your foes to ashes." }
newTalentType{ type="spell/earth", name = "earth", description = "Harness the power of the earth to protect and destroy." }
newTalentType{ type="spell/cold", name = "cold", description = "Harness the power of winter to shatter your foes." }
newTalentType{ type="spell/lightning", name = "lightning", description = "Harness the power of lightnings to fry your foes." }
newTalentType{ type="spell/conveyance", name = "conveyance", description = "Conveyance is the school of travel. It allows you to travel faster and to track others." }

newTalentType{ type="physical/2hweapon", name = "two handed weapons", description = "Allows the user to be more proficient with two handed weapons." }
newTalentType{ type="physical/1hweapon", name = "one handed weapons", description = "Allows the user to be more proficient with one handed weapons." }
newTalentType{ type="physical/dualweapon", name = "dual wielding", description = "Allows the user to be more proficient with dual wielding weapons." }
newTalentType{ type="physical/shield", name = "shields", description = "Allows the user to be more proficient with shields." }

newTalent{
	name = "Manathrust",
	type = {"spell/arcane", 1},
	mana = 10,
	tactical = {
		ATTACK = 10,
	},
	action = function(self)
		local t = {type="bolt", range=20}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.ARCANE, 10 + self:getMag())
		return true
	end,
	require = { stat = { mag=12 }, },
	info = function(self)
		return ([[Conjures up mana into a powerful bolt doing %0.2f arcane damage",
		The damage will increase with the Magic stat]]):format(10 + self:getMag())
	end,
}
newTalent{
	name = "Disruption Shield",
	type = {"spell/arcane",2},
	mana = 80,
	tactical = {
		DEFEND = 10,
	},
	action = function(self)
		return true
	end,
	require = { stat = { mag=12 }, },
	info = function(self)
		return ([[Uses mana instead of life to take damage",
		The damage to mana ratio increases with the Magic stat]]):format(10 + self:getMag())
	end,
}

newTalent{
	name = "Globe of Light",
	type = {"spell/fire",1},
	mana = 5,
	tactical = {
		ATTACKAREA = 3,
	},
	action = function(self)
		local t = {type="ball", range=0, friendlyfire=false, radius=5 + self:getMag(10)}
		self:project(t, self.x, self.y, DamageType.LIGHT, 1)
		return true
	end,
	require = { stat = { mag=10 }, },
	info = function(self)
		return ([[Creates a globe of pure light with a radius of %d that illuminates the area.",
		The radius will increase with the Magic stat]]):format(5 + self:getMag(10))
	end,
}

newTalent{
	name = "Fireflash",
	type = {"spell/fire",2},
	mana = 45,
	tactical = {
		ATTACKAREA = 10,
	},
	action = function(self)
		local t = {type="ball", range=15, radius=math.min(6, 3 + self:getMag(6))}
		local x, y = self:getTarget(t)
		if not x or not y then return nil end
		self:project(t, x, y, DamageType.FIRE, 28 + self:getMag(70))
		return true
	end,
	require = { stat = { mag=16 }, },
	info = function(self)
		return ([[Conjures up a flash of fire doing %0.2f fire damage in a radius of %d",
		The damage will increase with the Magic stat]]):format(8 + self:getMag(70), math.min(6, 3 + self:getMag(6)))
	end,
}

newTalent{
	name = "Phase Door",
	type = {"spell/conveyance",1},
	message = "@Source@ blinks.",
	mana = 15,
	tactical = {
		ESCAPE = 4,
	},
	action = function(self)
		self:teleportRandom(10 + self:getMag(10))
		return true
	end,
	require = { stat = { mag=16 }, },
	info = function(self)
		return ([[Teleports you randomly on a small scale range (%d)",
		The range will increase with the Magic stat]]):format(10 + self:getMag(10))
	end,
}

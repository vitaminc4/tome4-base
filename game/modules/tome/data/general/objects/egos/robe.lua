newEntity{
	name = " of fire resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.FIRE] = resolvers.mbonus(30, 10)},
	},
}
newEntity{
	name = " of cold resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.COLD] = resolvers.mbonus(30, 10)},
	},
}
newEntity{
	name = " of acid resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.ACID] = resolvers.mbonus(30, 10)},
	},
}
newEntity{
	name = " of lightning resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.LIGHTNING] = resolvers.mbonus(30, 10)},
	},
}
newEntity{
	name = " of nature resistance",
	level_range = {1, 50},
	rarity = 5,
	cost = 6,
	wielder = {
		resists={[DamageType.NATURE] = resolvers.mbonus(30, 10)},
	},
}

newEntity{
	name = "shimmering ", prefix=true,
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		max_mana = resolvers.mbonus(100, 10),
	},
}

newEntity{
	name = "slimy ", prefix=true,
	level_range = {10, 50},
	rarity = 7,
	cost = 6,
	wielder = {
		on_melee_hit={[DamageType.SLIME] = resolvers.mbonus(7, 3)},
	},
}

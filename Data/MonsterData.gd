extends Resource

class_name MonsterData

enum MonsterRarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

const WEIGHTS = {
	MonsterRarity.COMMON: 50,
	MonsterRarity.UNCOMMON: 25,
	MonsterRarity.RARE: 15,
	MonsterRarity.EPIC: 9,
	MonsterRarity.LEGENDARY: 1
}

@export var name: String
@export var description: String
@export var rarity: MonsterRarity
@export var damage: int

# Generate Weight according to rarity
func get_weight() -> int:
	return WEIGHTS.get(rarity, 1)

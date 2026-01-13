extends Node
class_name MonsterDatabase

var monsters: Array[MonsterData] = []

# Load all the monster resources
func _ready():
	monsters = [
		preload("res://Resources/Monsters/SimpleGoblin.tres"),
		preload("res://Resources/Monsters/Alice.tres")
	]
	print("DEBUG: %d monsters loaded" % monsters.size())

# Get a random monster
func spawn(rng: RandomNumberGenerator) -> MonsterData:
	var total_weight := 0
	
	for m in monsters:
		total_weight += m.get_weight()

	var roll = rng.randi_range(1, total_weight)
	
	var acc := 0
	
	for m in monsters:
		acc += m.get_weight()
		if roll <= acc:
			return m

	return monsters[0] # fallback

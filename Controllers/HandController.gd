extends RefCounted

class_name HandController

# Create signals
signal card_added(card: CardInstance)

var cards: Array[CardInstance] = []

func add(card: CardInstance) -> void:
	cards.append(card)
	emit_signal("card_added", card)  # for new instantiation

func reveal() -> void:
	for card in cards:
		if card.is_face_down:
			card.reveal()

# Get hand score
func get_score() -> int: 
	var total : int = 0
	var aces : int = 0

	for card in cards:
		if card.is_face_down:
			return 0
		
		var value = card.data.get_value()
		var rank = card.data.rank
	
		total += value
		if rank == 1:
			aces += 1

	while total > 21 and aces > 0:
		total -= 10
		aces -= 1

	return total

func is_busted() -> bool:
	return get_score() > 21

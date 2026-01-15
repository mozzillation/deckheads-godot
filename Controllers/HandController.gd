extends RefCounted

class_name HandController

# Create signals
signal card_added(card: CardInstance)
signal score_update(who: HandView.WHO)


var cards: Array[CardInstance] = []

func add(card: CardInstance, who: HandView.WHO) -> void:
	cards.append(card)
	emit_signal("card_added", card)  # for new instantiation
	emit_signal("score_update", who)

func reveal(who: HandView.WHO) -> void:
	for card in cards:
		if card.is_face_down:
			card.reveal()
			emit_signal("score_update", who)

# Get hand score
func get_score() -> int: 
	var total : int = 0
	var aces : int = 0

	for card in cards:
				
		var value = 0 if card.is_face_down else card.data.get_value() 
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

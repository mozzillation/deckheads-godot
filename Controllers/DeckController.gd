extends RefCounted

class_name DeckController

var cards: Array[CardData] = []

func _init():
	_build_deck()
	shuffle()

func _build_deck():
	cards.clear()
	for suit in CardData.Suit.values():
		for rank in range(1, 14):
			var card := CardData.new()
			card.suit = suit
			card.rank = rank
			cards.append(card)
	print("DEBUG: %d-card deck created" % cards.size())

func shuffle():
	cards.shuffle()
	print("DEBUG: deck shuffled")

func draw(is_face_down: bool = false) -> CardInstance:
	if cards.is_empty():
		push_error("DEBUG: deck is empty")
		return null
		
	var card_data: CardData = cards.pop_back()
	return CardInstance.new(card_data, is_face_down)

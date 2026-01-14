extends RefCounted

class_name DeckController

var cards: Array[CardData] = []

func _init():
	# Generate & shuffle
	create()

func _build():
	# Clear array
	cards.clear()
	
	# Generate decks
	for suit in CardData.Suit.values():
		for rank in range(1, 14):
			var card := CardData.new()
			card.suit = suit
			card.rank = rank
			cards.append(card)
	
	print("DEBUG: %d-card deck created" % cards.size())

func _shuffle():
	# Randomize deck
	cards.shuffle()
	print("DEBUG: deck shuffled")
	
func create():
	# Combine generation & shuffle 
	_build()
	_shuffle()

func draw(is_face_down: bool = false) -> CardInstance:
	# If deck is empty, create a new one before proceeding
	if cards.is_empty():
		print("DEBUG: Deck is empty")
		create()
	
	# Get & remove first card
	var card_data: CardData = cards.pop_back()
	
	# Return instance with additional props
	return CardInstance.new(card_data, is_face_down)

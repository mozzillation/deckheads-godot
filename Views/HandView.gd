extends HBoxContainer

class_name HandView

var card_views: Array[CardView] = []

@export var card_scene: PackedScene

func bind(hand: HandController):
	# Connect signals
	hand.connect("card_added", Callable.create(self, "_on_card_added"))

	# Initialize current cards
	for card in hand.cards:
		_on_card_added(card)

func _on_card_added(card: CardInstance):
	var view := card_scene.instantiate() as CardView
	add_child(view)
	view.bind(card)
	card_views.append(view)
	# listen directly to the card

#func _on_hand_changed(hand: HandController):
	## Only update existing cards (e.g., flipped or removed)
	#for card in hand.cards:
		#if card_views.has(card):
			#card_views[card]._update_visual()

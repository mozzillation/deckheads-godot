extends HBoxContainer

class_name HandView

var card_views: Array[CardView] = []
var card_positions := {}


@export var card_scene: PackedScene
@export var enter_direction := CardView.DIRECTIONS.UP

func _notification(what):
	if what == NOTIFICATION_SORT_CHILDREN:
		_on_layout_changed()

func _on_layout_changed():
	print("DEBUG: layout change")
	for card_view in card_views:
		var new_pos := card_view.global_position

		if not card_positions.has(card_view):
			card_positions[card_view] = new_pos
			continue

		var prev_pos: Vector2 = card_positions[card_view]
		var delta := prev_pos - new_pos

		if delta.length() > 0.5:
			
			card_view.animate_layout_delta(delta)

		card_positions[card_view] = new_pos

func bind(hand: HandController):
	# Connect signals
	hand.connect("card_added", Callable.create(self, "_on_card_added"))
	
	# Initialize current cards
	for card in hand.cards:
		_on_card_added(card)

func _on_card_added(card: CardInstance):
	var view := card_scene.instantiate() as CardView
	add_child(view)
	view.enter_direction = enter_direction
	view.bind(card)
	card_views.append(view)
	# listen directly to the card

#func _on_hand_changed(hand: HandController):
	## Only update existing cards (e.g., flipped or removed)
	#for card in hand.cards:
		#if card_views.has(card):
			#card_views[card]._update_visual()

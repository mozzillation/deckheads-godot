extends Control

class_name DeckView


@onready var stack: Control = $Stack
@onready var stackCountLabel: Label = $%StackCountLabel

var deck: DeckController

@export var card_back_scene: PackedScene
@export var max_visible_cards := 6
@export var stack_offset := Vector2(0, -2)

var stack_cards: Array[Control] = []
var is_hovered: bool = false
var is_pointer_inside: bool= false
var is_animating: bool= false

var _base_stack_position: Vector2

signal card_requested(card: CardInstance)

func _ready() -> void:
	# FOR DEBUG PURPOSES
	deck = DeckController.new()
	_base_stack_position = stack.position
	stack.visible = true
	_rebuild_stack()
	


func bind(deck_ref: DeckController):
	deck = deck_ref
	stack.position = Vector2(0, 40)
	stack.visible = false
	


func play_enter_animation():
	stack.visible = true
	_rebuild_stack()
	
	var tween := create_tween() \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT) 
	
	tween.tween_property(stack, "position:y", 0, 0.1)

func play_deck_exit_animation():
	var tween := create_tween() \
	.set_trans(Tween.TRANS_EXPO) \
	.set_ease(Tween.EASE_IN) 
	tween.tween_property(stack, "position:y", 40, 0.1) \
	.finished.connect(func():
		queue_free()
		)
	

	

func _rebuild_stack():
	# Clear old
	for c in stack_cards:
		c.queue_free()
	stack_cards.clear()
	
	
	
	var count: int = min(deck.cards.size(), max_visible_cards)

	for i in count:
		var _base_pos := Vector2.ZERO

		var back := card_back_scene.instantiate() as Control
		back.set_meta("base_pos", stack_offset * i)
		back.position = back.get_meta("base_pos")
		back.mouse_filter = Control.MOUSE_FILTER_PASS
		
		stack.add_child(back)

		back.position = stack_offset * i
		back.pivot_offset = Vector2(32, 40)
		
		stack_cards.append(back)
	
	stackCountLabel.text = "%s of 52" % deck.cards.size()


func _on_deck_clicked():
	#if deck.cards.is_empty():
		#return

	var card := deck.draw()
	if card == null:
		return
	
	play_exit_animation(card)
	#_rebuild_stack()


func _on_gui_input(event: InputEvent) -> void:
	if is_animating:
		return 
		
	if event is InputEventMouseButton \
	and event.pressed \
	and event.button_index == MOUSE_BUTTON_LEFT:
		print("DEBUG: deck clicked")
		_on_deck_clicked()
	


func play_mouse_entered_animation() -> void:
	
	if stack_cards.is_empty():
		return
	
	if is_hovered or is_animating:
		return
	
	var top: Control = stack_cards.back()
	var tween = create_tween() \
		.set_trans(Tween.TRANS_ELASTIC) \
		.set_ease(Tween.EASE_OUT) 

	stackCountLabel.show()

	
	#tween.parallel().tween_property(top, "rotation_degrees", 5, 0.25)
	#tween.parallel().tween_property(top, "position:y", top.get_meta("base_pos") + Vector2(0, -20), 0.1)
	tween\
		.tween_property(top, "scale", Vector2(1.1, 1.1), 0.1)
	
	tween \
		.parallel() \
		.tween_property(top, "position", top.get_meta("base_pos") + Vector2(0, -20), 0.1)
	
	tween \
		.parallel() \
		.tween_property(stackCountLabel, "position:y", -48, 0.1)
	


		
	is_hovered = true

func play_mouse_exited_animation() -> void:
	if stack_cards.is_empty():
		return
	
	if not is_hovered or is_animating:
		return
	

	
	var top: Control = stack_cards.back()
	var tween = create_tween() \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT) 
	
	tween.tween_property(top, "scale", Vector2(1, 1), 0.1)
	tween.parallel().tween_property(top, "position", top.get_meta("base_pos"), 0.1)
	
	tween \
		.parallel() \
		.tween_property(stackCountLabel, "position:y", 0, 0.1)
	
	stackCountLabel.hide()
		
	is_hovered = false



func play_exit_animation(card: CardInstance) -> void:
	if stack_cards.is_empty():
		return

	is_animating = true
	is_hovered = false
	var top: Control = stack_cards.back()

	create_tween() \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_IN) \
		.tween_property(top, "scale", Vector2(0, 1), 0.1)

	create_tween() \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_IN) \
		.tween_property(top, "position", top.position + Vector2(0, -40), 0.1) \
		.finished \
		.connect(func():
			top.queue_free()
			stack_cards.pop_back()
			_rebuild_stack()
			is_animating = false
			emit_signal("card_requested", card)


			# 🔑 THIS IS THE FIX
			if is_pointer_inside:
				play_mouse_entered_animation()
			)
	

func _on_mouse_entered() -> void:
	is_pointer_inside = true
	play_mouse_entered_animation()


func _on_mouse_exited() -> void:
	is_pointer_inside = false
	play_mouse_exited_animation()

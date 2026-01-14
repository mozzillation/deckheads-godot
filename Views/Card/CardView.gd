extends Control

class_name CardView

var card: CardInstance

enum DIRECTIONS {
	UP,
	DOWN
}

# Idle animation
@export var bob_amplitude := 4.0        # px
@export var bob_speed := 1.5            # rad/sec
@export var rot_amplitude := 4.0         # degrees

# Enter animation
@export var enter_direction: = DIRECTIONS.UP
@export var enter_amplitude := 80

# Shake on reveal animation
@export var reveal_shake_strength := 4.0
@export var reveal_shake_duration := 0.25
@export var reveal_shake_rot := 10.0

# Aliases
@onready var root: Control = %CardRoot
@onready var sides: Control = %CardSides
@onready var face: TextureRect = %CardFace
@onready var back: TextureRect = %CardBack
@onready var shadow: TextureRect = %Shadow
@onready var rankLabel: Label = %RankLabel

# Animation helpers
var _time := 0.0
var _phase := randf() * TAU

var _base_root_position: Vector2
var _base_sides_position: Vector2


func _ready(): 
	pass
	
func _process(delta):
	play_idle_animation(delta)
	

func bind(card_instance: CardInstance):
	card = card_instance
	_update_visual()
	play_enter_animation()
	
	card.connect("card_revealed", Callable.create(self, "_on_card_revealed"))

# Update Visual
func _update_visual():
	# Set Rank Label -- temporary
	rankLabel.text = card.data.get_rank()
	
	if card.is_face_down:
		back.visible = true
		face.visible = false
		rankLabel.visible = false
	else:
		back.visible = false
		face.visible = true
		rankLabel.visible = true
		#face.texture = CardAtlas.get_texture(
			#card.data.suit,
			#card.data.rank
		#)

func _on_card_revealed(card_instance: CardInstance):
	print("DEBUG: %s of %s revealed" % [
		card_instance.data.get_rank(),
		card_instance.data.get_suit()
	])
	_update_visual()
	play_reveal_shake()

func play_idle_animation(_delta: float):
	_time += _delta * bob_speed

	var y_offset = sin(_time + _phase) * bob_amplitude 
	var rot = sin(_time * 1 + _phase) * rot_amplitude
	
	sides.position = _base_sides_position + Vector2(0, y_offset)
	sides.rotation_degrees = rot


func play_enter_animation():
	var offset := enter_amplitude * (-1 if enter_direction == DIRECTIONS.UP else 1)

	root.scale = Vector2(0.6, 0.6)
	root.position = Vector2(0, offset)

	create_tween() \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT) \
		.tween_property(root, "scale", Vector2.ONE, 0.2)

	create_tween() \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT) \
		.tween_property(root, "position", Vector2.ZERO, 0.2)

func play_reveal_shake():
	var tween = create_tween()\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)

	# horizontal shake
	tween.tween_property(
		root,
		"position:y",
		_base_root_position.y + reveal_shake_strength,
		reveal_shake_duration * 0.25
	)

	tween.tween_property(
		root,
		"position:y",
		_base_root_position.y - reveal_shake_strength,
		reveal_shake_duration * 0.25
	)

	tween.tween_property(
		root,
		"position:y",
		_base_root_position.y,
		reveal_shake_duration * 0.5
	)

func animate_layout_delta(delta: Vector2):
	# Counteract container snap
	root.position += delta
	
	var tween = create_tween()\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_EXPO)

	tween.tween_property(root, "position", Vector2.ZERO, 0.2)

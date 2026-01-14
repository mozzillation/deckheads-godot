extends Control

class_name CardView

var card: CardInstance

# Idle animation
@export var bob_amplitude := 8.0        # px
@export var bob_speed := 1.5            # rad/sec
@export var rot_amplitude := 8.0         # degrees

# Shake on reveal animation
@export var reveal_shake_strength := 8.0
@export var reveal_shake_duration := 0.18
@export var reveal_shake_rot := 3.0

# Aliases
@onready var root: Control = %CardRoot
@onready var sides: Control = %CardSides
@onready var face: TextureRect = %CardFace
@onready var back: TextureRect = %CardBack
@onready var rankLabel: Label = %RankLabel

# Animation helpers
var _time := 0.0
var _phase := randf() * TAU

var _base_root_position: Vector2
var _base_sides_position: Vector2

func _process(delta):
	_time += delta * bob_speed

	var y_offset = sin(_time + _phase) * bob_amplitude 
	var rot = sin(_time * 0.8 + _phase) * rot_amplitude

	sides.position = _base_sides_position + Vector2(0, y_offset)
	sides.rotation_degrees = rot

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


func play_enter_animation():

	_base_root_position = root.position
	root.scale = Vector2(0.5, 0.5)
	root.position = _base_root_position + Vector2(0, 100)

	var tween = create_tween()\
	.set_trans(Tween.TRANS_EXPO)\
	.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(root, "scale", Vector2.ONE, 0.4)
	tween.parallel().tween_property(root, "position", _base_root_position, 0.4)
	
	# Normalize transforms
	tween.finished.connect(func():
		root.rotation_degrees = 0
		root.scale = Vector2.ONE
	)

func play_reveal_shake():
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)

	# horizontal shake
	tween.tween_property(
		root,
		"position:x",
		_base_root_position.x + reveal_shake_strength,
		reveal_shake_duration * 0.25
	)

	tween.tween_property(
		root,
		"position:x",
		_base_root_position.x - reveal_shake_strength,
		reveal_shake_duration * 0.25
	)

	tween.tween_property(
		root,
		"position:x",
		_base_root_position.x,
		reveal_shake_duration * 0.5
	)

	# tiny rotational kick
	tween.parallel().tween_property(
		root,
		"rotation_degrees",
		reveal_shake_rot,
		reveal_shake_duration * 0.25
	)

	tween.parallel().tween_property(
		root,
		"rotation_degrees",
		0.0,
		reveal_shake_duration * 0.5
	)

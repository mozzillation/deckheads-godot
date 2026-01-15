extends Control

class_name CardView

var card: CardInstance

enum DIRECTIONS {
	UP,
	DOWN
}

@export var suit_atlas_source: Texture2D = preload("res://assets/suits.png")


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
@onready var motion_base: Control = %MotionBase
@onready var motion_idle: Control = %MotionIdle

@onready var face: TextureRect = %CardFace
@onready var back: TextureRect = %CardBack
@onready var shadow: TextureRect = %Shadow
@onready var rankLabel: Label = %RankLabel
@onready var suitIcon: = %SuitIcon


var _suit_atlas = AtlasTexture.new()

# Animation helpers
var _time := 0.0
var _phase := randf() * TAU


func _ready(): 
	_suit_atlas.atlas = suit_atlas_source

	
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
	_update_suit_icon()
	
	if card.is_face_down:
		back.visible = true
		face.visible = false
		rankLabel.visible = false
		suitIcon.visible = false
	else:
		back.visible = false
		face.visible = true
		rankLabel.visible = true
		suitIcon.visible = true
		#face.texture = CardAtlas.get_texture(
			#card.data.suit,
			#card.data.rank
		#)

func _update_suit_icon(): 
	var suit_index := card.data.suit # 0..3
	var region_size := 16.00
	var spacing := 1
	
	# Compute x position
	var x := suit_index * (region_size + spacing)
	_suit_atlas.region = Rect2(x, 0, region_size, region_size)
	suitIcon.texture = _suit_atlas

func _on_card_revealed(card_instance: CardInstance):
	print("DEBUG: %s of %s revealed" % [
		card_instance.data.get_rank(),
		card_instance.data.get_suit()
	])
	play_reveal_shake()



func play_idle_animation(delta):
	_time += delta * bob_speed
	var bob := sin(_time + _phase)

	motion_idle.position.y = bob * bob_amplitude
	motion_idle.rotation_degrees = bob * rot_amplitude

	update_shadow(bob)


func play_enter_animation():
	var offset := enter_amplitude * (-1 if enter_direction == DIRECTIONS.UP else 1)

	motion_base.scale = Vector2(0, 1)
	motion_base.position = Vector2(0, offset)

	create_tween() \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT) \
		.tween_property(motion_base, "scale", Vector2.ONE, 0.2)

	create_tween() \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT) \
		.tween_property(motion_base, "position", Vector2.ZERO, 0.2)

func play_reveal_shake():
	var tween = create_tween()\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_ELASTIC)

	
	tween.tween_property(motion_base, "scale:x", 0.00, reveal_shake_duration * 0.25)\
	.finished\
	.connect(func():
			_update_visual()
	)
	
	tween.tween_property(
		motion_base, "scale:x", 1.00, reveal_shake_duration * 0.5
	)
	
	


func update_shadow(bob: float):
	shadow.rotation_degrees = bob * 4

func animate_layout_delta(delta: Vector2):
	# Counteract container snap
	motion_base.position += delta
	
	var tween = create_tween()\
	.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_EXPO)

	tween.tween_property(motion_base, "position", Vector2.ZERO, 0.2)

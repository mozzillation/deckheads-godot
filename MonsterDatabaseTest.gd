extends Control

@onready var hit_button: Button = $HitButton
@onready var stand_button: Button = $StandButton

@onready var playerHandView := $HandsContainer/PlayerHandView
@onready var monsterHandView := $HandsContainer/MonsterHandView

@export var start_delay : = 0.5
@export var deal_delay := 0.25

var rng := RandomNumberGenerator.new()

var deck := DeckController.new()
var playerHand := HandController.new()
var monsterHand := HandController.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize RNG
	rng.randomize()
	
	# Connect UI signals 
	hit_button.pressed.connect(_on_hit_pressed)
	stand_button.pressed.connect(_on_stand_pressed)
	
	# Deal initial cards
	deal()
	
	# Bind hands
	playerHandView.bind(playerHand)
	monsterHandView.bind(monsterHand)

	
func _on_hit_pressed():
	# Add 
	playerHand.add(deck.draw())
		
	if playerHand.is_busted():
		print("BUSTED!")

func deal() -> void:
	await get_tree().process_frame  # let scene settle
	await get_tree().create_timer(start_delay).timeout

	await _deal_card(playerHand)
	await _deal_card(monsterHand)
	
	await _deal_card(playerHand)
	await _deal_card(monsterHand, true)



func _deal_card(hand: HandController, is_face_down := false):
	hand.add(deck.draw(is_face_down))
	await get_tree().create_timer(deal_delay).timeout


func _on_stand_pressed() -> void:
	print("monster score before: ", monsterHand.get_score())

	playerHand.reveal()
	monsterHand.reveal()
	print("card revealed")
	print("monster score after: ", monsterHand.get_score())

	
	print("player score: ", playerHand.get_score())
